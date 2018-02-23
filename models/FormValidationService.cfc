<!-- 
	Validation Service
 -->
<cfcomponent hint="Validation Service" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="formS"	inject="model:formulario.FormularioService">
	<cfproperty name="dao"		inject="model:participante.ParticipanteDAO">
	<cfproperty name="cdao"		inject="model:campo.CampoDAO">

	<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="FormValidationService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- 
		Método de validación principal para POST/PUT de participantes.
		@dataFields
	 --->
	<cffunction name="validateCreateDataFields" returntype="struct">
		<cfargument name="dataFields" type="struct" required="true">

		<cfset var keyList     = []>
		<cfset var validEmails = []>

		<!--- Se valida la estructura de la respuesta --->
		<cfif NOT structKeyExists(arguments.dataFields, 'data') OR NOT isStruct(arguments.dataFields.data)>
			<cfthrow message="Invalida JSON Data. The key 'data' does not exists or is not a object">
		</cfif>
		<cfif NOT structKeyExists(arguments.dataFields.data, 'records') OR NOT isArray(dataFields.data.records)>
			<cfthrow message="Invalida JSON Data. The key 'data.records' does not exists or is not an array">
		</cfif>
		
		<!--- Se obtienen los campos básicos --->
		<cfset var defaultFields = dao.defaultValues(filtered = false)>

		<!--- Se recorre cada uno de los registros entregados --->
		<cfloop collection="#dataFields.data.records#" item="key">
		
			<cfset record = dataFields.data.records[key]>

			<!--- Validamos si existe el campo "id_tipo_participante" --->
			<cfif structKeyExists(record, 'id_tipo_participante')>
				<cfset var idtipoparticipante = record.id_tipo_participante>
				<cfset structDelete(record, 'id_tipo_participante')>
			<cfelse>
				<cfthrow message="Invalida JSON Data. ID tipo participante does not exists">
			</cfif>

			<!--- Se validan campos login/password --->
			<cfset validateLoginPassword(record)>

			<!--- Validamos si existe el campo "login-password" --->
			<cfif structKeyExists(record, 'login')>
				<cfset var login = record.login>
				<cfset structDelete(record, 'login')>
			</cfif>
			<cfif structKeyExists(record, 'password')>
				<cfset var password = record.password>
				<cfset structDelete(record, 'password')>
			</cfif>
			<cfif structKeyExists(record, 'inscrito')>
				<cfset var inscrito = record.inscrito>
				<cfset structDelete(record, 'inscrito')>
			</cfif>

			<!--- Validamos que al menos venga el campo correo --->
			<cfquery name="local.findout" dbtype="query" cachedWithin="#createTimeSpan( 0, 0, dao.queryExpiration, 0 )#">
				SELECT * 
				FROM defaultFields
				WHERE id_campo IN (#structKeyList(record)#)
				AND (titulo LIKE '%mail%' OR titulo LIKE '%correo%')
			</cfquery>
			
			<cfif local.findout.recordcount LTE 0>
				<cfthrow message="Field 'Email' does not exists in register [#key#] ">
			</cfif>

			<!--- Renovamos variables para el proceso de guardado en BBDD --->
			<cfset emailp = arrayFirst(structFindKey(record, local.findout.id_campo)).value>

			<!--- 
				Comprobamos que el participante no exista en BBDD, pero solo cuando es una nueva inserción. 
				@url.force Fuerza la inserción de datos.
			---> 
			<cfif getHTTPRequestData().method EQ 'POST' AND (NOT structKeyExists(url, 'force') OR url.force == false)>
				<cfquery name="local.logins" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, dao.queryExpiration, 0 )#">
					SELECT COUNT(*) AS 'exists' FROM participantes
					WHERE login = <cfqueryparam value="#replace((structKeyExists(record, 'login') ? record.login : emailp), "'", "", 'all')#" cfsqltype="CF_SQL_VARCHAR">
					AND id_evento IN (#session.id_evento#)
					AND fecha_baja IS NULL
				</cfquery>

				<cfif local.logins.exists NEQ 0>
					<cfthrow message="Invalida JSON Data. Email ['#emailp#'] can not be duplicated">
				</cfif>
			</cfif>

			<!--- Se validan emails duplicados --->
			<cfif arrayFind(validEmails, emailp) GT 0>
				<cfthrow message="Invalida JSON Data. Email ['#emailp#'] already exists">
			</cfif>

			<!--- Obtenemos las keys de los campos para continuar con el proceso. --->
			<cfset keyList = arrayMerge(keyList, structKeyArray(record), true)>
		
			<cfset arrayAppend(validEmails, emailp)>

			<!--- Reintegramos las variables para continuar con las validaciones --->
			<cfif isdefined('emailp')>
				<cfset structInsert(record, 'email', trim(emailp))>
				<cfset emailp = JavaCast( "null", 0 ) >
			</cfif>
			<cfif isdefined('login')>
				<cfset structInsert(record, 'login', trim(login))>
				<cfset login = JavaCast( "null", 0 ) >
			</cfif>
			<cfif isdefined('password')>
				<cfset structInsert(record, 'password', trim(password))>
				<cfset password = JavaCast( "null", 0 ) >
			</cfif>
			<cfif isdefined('inscrito')>
				<cfset structInsert(record, 'inscrito', trim(inscrito))>
				<cfset inscrito = JavaCast( "null", 0 ) >
			</cfif>
			<cfif isdefined('idtipoparticipante')>
				<cfset structInsert(record, 'id_tipo_participante', trim(idtipoparticipante))>
				<cfset idtipoparticipante = JavaCast( "null", 0 ) >
			</cfif>

			<cfset dataFields.data.records[key] = record>
		</cfloop>

		<cfset var formFields = formS.formFields()>
		
		<!--- Validamos campos obligatorios --->
		<cfset requiredFields(keyList, dataFields.data.records, formFields)>

		<!--- Validamos por tipo de campo - configuración --->
		<cfset configFields(keyList, dataFields.data.records, formFields)>

		<cfset formFiles(keyList, dataFields.data.records, formFields)>
		
		<cfreturn arguments.dataFields>
	</cffunction>

	<!--- 
		Valida campos obligatorios, "requiered"
		@ñkeyList
		@fields 
		@formFields
	 --->
	<cffunction name="requiredFields" output="false" returntype="any">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">
		<cfargument name="formFields" type="any" required="true">

		<cfset var reqFields = {}>

		<cfscript>
			// Filtramos los registros para obtener solo los campos "obligatorios"
			reqFields = structFilter(formFields, function(key, value) {
				return structKeyExists(value.configuration, 'required') AND value.configuration.required == true;
			});

			// Obtenemos las keys como lista
			var myKeyList = structKeyList(reqFields);

			// Validamos que los campos entregados por el cliente contengan todas las keys obligatorias
			for(value in listToArray(myKeyList)) {
				if(arrayFind(keyList, value) == 0) {
					throw(message="Have not been found [#value#] into [#arrayToList(keyList)#] of the required fields [#myKeyList#]" );
				}
			}
		</cfscript>
		
		<cfreturn reqFields>
	</cffunction>

	<!--- 
		Valida campos por su configuración según el tipo de campo al que pertenezca
	 --->
	<cffunction name="configFields" output="false" returntype="any">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">
		<cfargument name="formFields" type="any" required="true">

		<cfset var reqFields = {}>

		<cfscript>
			try {
				for(f in fields) {
					for(k in structKeyArray(f)) {
						if(NOT structKeyExists(formFields, k)) { continue; }
						
						var fval = structFind(formFields, k);

						if(isValid('string', fval.type)) {
							switch (fval.type) {
								case "text":
									validateText(structFind(f, k), fval);
									break;
								case "number":
									validateNumber(structFind(f, k), fval);
									break;
								case "email":
									validateEmail(structFind(f, k), fval);
									break;
								case "date":
									validateDate(structFind(f, k), fval);
									break;
								case "checkbox":
									validateCheckbox(structFind(f, k), fval);
									break;
								case "radio":
									validateRadio(structFind(f, k), fval);
									break;
								case "select":
									validateList(structFind(f, k), fval);
									break;
								case "file":
									validateFile(structFind(f, k), fval);
									break;
								default:								
									break;
							}
						}
					}
				}
		 	} catch(any e) { if(isdefined("url.debug")) { writeDump(var="#k#", label="e"); writeDump(var="#e#", label="e"); abort; } }
		</cfscript>

		<cfreturn reqFields>
	</cffunction>

	<!--- TODO: Agregar extension imagen --->
	<cffunction name="formFiles" output="false" returntype="any">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">
		<cfargument name="formFields" type="any" required="true">

		<cfset var reqFields = {}>

		<cfscript>
			// Filtramos los registros para obtener solo los campos "obligatorios"
			reqFields = structFilter(formFields, function(key, value) {
				return (value.type == 'file');
			});

			// Obtenemos las keys como lista
			var myKeyList = structKeyList(reqFields);

			var toupload = {};
			
			for(data in fields) {
				for(key in listToArray(myKeyList)) {
					if(structKeyExists(data, key)) {
						data[key] = cdao.uploadFile(data[key]);
					}
				}							
			}			
		</cfscript>
		
		<cfreturn reqFields>
	</cffunction>

	<!---  
		Valida Textos y sus derivados 
		@fvalue
		@validation
	--->
	<cffunction name="validateText" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			if(NOT isValid("string", fvalue)) {
				throw(message="Error Validation");
			}
			if(structKeyExists(validation.configuration, 'minlength') AND validation.configuration.minlength GT 0 AND len(fvalue) LT validation.configuration.minlength) {
				throw(message="Error Validation. minlenght");
			}
			if(structKeyExists(validation.configuration, 'maxlength') AND validation.configuration.maxlength GT 0 AND len(fvalue) GT validation.configuration.maxlength) {
				throw(message="Error Validation. maxlenght");
			}
			if(validation.type EQ "url") {
				if (reFindNoCase("^(http://|https://)[\w\.-]+\.[a-zA-Z]{2,3}(/?)$", fvalue) LT 1) {
					throw(message="Error Validation. url");
				}									
			}	
			if(structKeyExists(validation.configuration, 'dninie') AND validation.configuration.dninie) {
				validateDNINIECIF(fvalue)				
			}
			if(validation.type EQ "text") {
				if(validation.configuration.onlyAlpha AND (NOT reFindNoCase('[^\w.]', fvalue) LT 1)) {
					throw(message="Error Validation. onlyAlpha");
				}
			}
		</cfscript>
	</cffunction>

	<!--- 
		Valida solo nùmeros 
		@fvalue
		@validation
	--->
	<cffunction name="validateNumber" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			if (isValid("integer", fvalue)) {
				throw(message="Error Validation. integer");
			}
		</cfscript>
	</cffunction>

	<!--- 
		Valida emails 
		@fvalue
		@validation
	--->
	<cffunction name="validateEmail" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			if (reFindNoCase("^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,3}$", fvalue) LT 1) {
				throw(message="Error Validation. email");
			}								
		</cfscript>
	</cffunction>

	<!--- 
		Valida campos "lista" 
		@val
	--->
	<cffunction name="ValidateList" output="false" returntype="void">
		<cfargument name="val">
	</cffunction>

	<!--- 
		Valida DNI-NIE-CIF 
		@val
	--->
	<cffunction name="validateDNINIECIF"  output="false" returntype="void">
		<cfargument name="val">

		<cfscript>
			valor = uCase(val);
			// LIMPIAMOS
			valor = reReplace(valor, "\ ", "", 'all');
			valor = reReplace(valor, "\,", "", 'all');
			valor = reReplace(valor, "\.", "", 'all');
			valor = reReplace(valor, "\-", "", 'all');

			ok = (validateDNI(valor) OR validateCIF(valor));
			
			if (!ok) {
				throw(message="Error Validation. dni-nif-pasaporte");
			}
		</cfscript>
	</cffunction>

	<!--- 
		Sub validación de DNI-NIE 
		@dni
	--->
	<cffunction name="validateDNI" output="false" returntype="boolean">
		<cfargument name="dni">

		<cfscript>
			if (dni != '') {
				var expresion_regular_dni = '([XYZ]?[0-9]{5,8}[A-Z])';
			
				dni = ucase(dni);
				
				// LIMPIAMOS
				dni = rereplace(dni, '\ ', "", 'all');
				dni = rereplace(dni, '\,', "", 'all');
				dni = rereplace(dni, '\.', "", 'all');
				dni = rereplace(dni, '\-', "", 'all');

				if(reFindNoCase(expresion_regular_dni, dni) EQ 1) {
					numero = mid(dni, 1, len(dni) - 1)
					numero = replace(numero, 'X', 0, 'all');
					numero = replace(numero, 'Y', 1, 'all');
					numero = replace(numero, 'Z', 2, 'all');
					let    = mid(dni, len(dni), 1);
					
					numero = numero % 23;
					letra  = 'TRWAGMYFPDXBNJZSQVHLCKET';
					letra  = mid(letra, numero + 1, 1);

					if (letra != let) {
						return false;
					} else {
						return true;
					}
				} else {
					return false;
				}
			} else {
				return true
			}
		</cfscript>
	</cffunction>
	
	<!--- 
		Sub validación de CIF 
		@cif
	--->
	<cffunction name="validateCIF" output="false" returntype="boolean">
		<cfargument name="cif">

		<cfscript>
			if (cif != '') {
				var v1 = [0,2,4,6,8,1,3,5,7,9];
				
				cif = ucase(cif);
				
				cif = replace(cif, '\ ', "", 'all');
				cif = replace(cif, '\,', "", 'all');
				cif = replace(cif, '\.', "", 'all');
				cif = replace(cif, '\-', "", 'all');
				
				var tempStr = cif; // pasar a mayúsculas
				var temp = 0;
				var temp1 = 0;
				var dc = '';

				// Comprueba el formato
				// var regExp = new RegExp(this.CIF_regExp);
				
				// if (!tempStr.match(regExp)) return false;    // Valida el formato?
				
				if (reFindNoCase('([ABCDEFGHKLMNPQS])', tempStr) LT 1) return false;  // Es una letra de las admitidas ?
		
				for( i = 2; i <= 7; i += 2 ) {
						temp = temp + v1[Int(mid(cif, i, 1))];
						temp = temp + Int(mid(cif, i + 1, 1));
				};
				temp = temp + v1[Int(mid(cif, 7, 1))];
				temp = (10 - ( temp % 10));
				
				if (temp==10) temp=0;
				
				dc  = mid(uCase(cif), 9, 1);

				return (dc==temp) || (temp==1 && dc=='A') || (temp==2 && dc=='B') || (temp==3 && dc=='C') || (temp==4 && dc=='D') || (temp==5 && dc=='E') || (temp==6 && dc=='F') || (temp==7 && dc=='G') || (temp==8 && dc=='H') || (temp==9 && dc=='I') || (temp==0 && dc=='J');
			} else {
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- 
		Valida checkbox 
		@fvalue
		@validation		
	--->
	<cffunction name="validateCheckbox" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			if(findNoCase(fvalue, ',')) {
				fvalue = listToArray(fvalue, ',');
			}

			var vals = structKeyExists(validation, 'values') ? validation.values : {};

			for(fv in fvalues) {
				var val = vals[fvalue];
	
				if(val EQ '') { throw(message="Error Validation. radio button"); }
			}
		</cfscript>
	</cffunction>

	<!--- 
		Valida radio buttons
		@fvalue
		@validation	
	 --->
	<cffunction name="validateRadio" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			var vals = structKeyExists(validation, 'values') ? validation.values : {};
			var val = vals[fvalue];

			if(val EQ '') { throw(message="Error Validation. radio button"); }
		</cfscript>
	</cffunction>

	<!--- 
		Valida fechas en formato ISO 8601 
		@fvalue
		@validation	
	--->
	<cffunction name="validateDate" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			include '/includes/helpers/ApplicationHelper.cfm';
			
			if(NOT isDate(fvalue)) {
				throw(message="Error Validation. field date is not a date"); 
			}
		</cfscript>
	</cffunction>

	<!--- 
		Valida la existencia de login y password para crear o modificarlas 
		@record
	--->
	<cffunction name="validateLoginPassword" output="false" returntype="void">
		<cfargument name="record"> 

		<cfscript>	
			if(getHTTPRequestData().method == 'POST') {
				// if(structKeyExists(record, 'login') OR structKeyExists(record, 'password')) {
				// 	// if(structKeyExists(record, 'login') AND NOT structKeyExists(record, 'password')) {
				// 	// 	throw(message="Error Validation. It has not been found login or password");
				// 	// }

				// 	// if(structKeyExists(record, 'password') AND NOT structKeyExists(record, 'login')) {
				// 	// 	throw(message="Error Validation. It has not been found login or password");
				// 	// }

					
				// 	if(structKeyExists(record, 'login') AND isEmpty(record.login)) {
				// 		throw(message="Error Validation. Login's empty ");
				// 	} 

				// 	if(structKeyExists(record, 'password') AND isEmpty(record.password)) {
				// 		throw(message="Error Validation. Password's empty ");
				// 	} 

				// 	var us = dao.getByLogin(record.login);

				// 	if(us.recordcount GT 0) {
				// 		for(u in us) {
				// 			if(dao.desEncriptar(u.password) EQ record.password) {
				// 				throw(message="Error Validation. Participante already exists");
				// 			} 
				// 			if(dao.desEncriptar(u.password) NEQ record.password) { 
				// 			}
				// 		}				
				// 	} else {
				// 	}

				// 	if(isdefined("url.debug")) {
				// 		writeDump(var="#record#", label="record");
				// 		abort;
				// 	}

				// }
			}
			if(getHTTPRequestData().method == 'PUT') {
			// 	if(structKeyExists(record, 'email') AND structKeyExists(record, 'login')) {
			// 		if(NOT structKeyExists(record, 'login')) {
			// 			throw(message="Error Validation. It has not been found login");
			// 		}

			// 		if(structKeyExists(record, 'login') AND isEmpty(record.login)) {
			// 			throw(message="Error Validation. Login's empty ");
			// 		} 

			// 		var us = dao.getByLogin(record.login);

			// 		if(us.recordcount LTE 0) {
			// 			var us = dao.getByLogin(record.email);
			// 			if(us.recordcount GT 0) {
			// 				throw(message="Error Validation. Participante does not exists [#record.email#].");
			// 			}
			// 		}
			// 	} 
			// 	if(structKeyExists(record, 'email') AND NOT structKeyExists(record, 'login')) {
			// 		var us = dao.getByLogin(record.email);

			// 		if(us.recordcount LTE 0) {
			// 			var us = dao.getByLogin(record.email);
			// 			if(us.recordcount GT 0) {
			// 				throw(message="Error Validation. Participante does not exists [#record.login#].");
			// 			}
			// 		}
			// 	}
			}
		</cfscript>
	</cffunction>

	<!--- 
		Valida archivos/url formulario multipart 
		@fvalue
		@validation	
	--->
	<cffunction name="validateFile" output="false" returntype="void">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			include '/includes/helpers/ApplicationHelper.cfm';
			
			if(NOT isValid('URL', fvalue)) {
				throw(message="Error Validation. field date is not a date"); 
			}
		</cfscript>
	</cffunction>

</cfcomponent>