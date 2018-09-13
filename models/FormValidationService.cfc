
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
		<cfargument name="rc" type="struct" required="true">

		<cfset var keyList     = []>
		<cfset var validEmails = []>

		<!--- Se valida la estructura de la respuesta --->
		<cfif NOT structKeyExists(arguments.rc, 'data') OR NOT isStruct(arguments.rc.data)>
			<cfthrow message="Invalid data: The key 'data' does not exists or is not a object" errorcode="400">
		
			<cfif NOT structKeyExists(arguments.rc.data, 'records') OR NOT isArray(rc.data.records)>
				<cfthrow message="Invalid data: The key 'data.records' does not exists or is not an array" errorcode="400">
			</cfif>
		</cfif>

		<cfset var clientDataFields = arguments.rc.data>
		<!--- Se obtienen los campos básicos --->
		<cfset var defaultFields = dao.defaultValues(arguments.rc.id_evento, false)>

		<!--- Se recorre cada uno de los registros entregados --->
		<cfloop collection="#clientDataFields.records#" item="key">
			<cfset var record             = clientDataFields.records[key]>
			<cfset var login              = "">
			<cfset var email              = "">
			<cfset var password           = "">
			<cfset var inscrito           = "">
			<cfset var idEventoBorrado    = false>
			<cfset var idtipoparticipante = 0>
			
			<!--- Se validan campos login/password --->
			<!--- <cfset validateLoginPassword(record, arguments.rc.id_evento)> --->
			
			<!--- Validamos si existe el campo "id_tipo_participante" --->
			<cfif structKeyExists(record, 'id_tipo_participante')>
				<cfset idtipoparticipante = trim(record.id_tipo_participante)>
				<cfset structDelete(record, 'id_tipo_participante')>
			<cfelse>
				<cfthrow message="Invalid data: ID tipo participante does not exists" errorcode="400">
			</cfif>
			<!--- Validamos si existe el campo "login-password-id_participante-id_tipo_participante-etc..." --->
			<cfif structKeyExists(record, 'id_participante')>
				<cfset structDelete(record, 'id_participante')>
			</cfif>
			<cfif structKeyExists(record, 'login')>
				<cfset login = trim(record.login)>
				<cfset structDelete(record, 'login')>
			</cfif>
			<cfif structKeyExists(record, 'email')>
				<cfset email = trim(record.email)>
				<cfset structDelete(record, 'email')>
			</cfif>
			<cfif structKeyExists(record, 'password') OR structKeyExists(record, 'PASSWORD')>
				<cfset password = trim(record.password)>
				<cfset structDelete(record, 'password')>
			</cfif>

			<cfif structKeyExists(record, 'inscrito')>
				<cfset inscrito = trim(record.inscrito)>
				<cfset structDelete(record, 'inscrito')>
			</cfif>

			<cfif structKeyExists(record, 'id_evento')>
				<cfset idEventoBorrado = true>
				<cfset structDelete(record, 'id_evento')>
			</cfif>

			<!--- Validamos que al menos venga el campo correo --->			
			<cfquery name="local.findout" dbtype="query">
				SELECT id_campo
				FROM defaultFields
				WHERE id_campo IN (#structKeyList(record)#)
				AND (titulo LIKE '%correo%' OR titulo LIKE '%mail%')
			</cfquery>

			<cfif local.findout.recordcount == 0>
				<cfthrow message="Field ID of 'Email' does not exists in register [#key#]" errorcode="400">
			</cfif>

			<!--- Renovamos variables para el proceso de guardado en BBDD --->
			<cfset var emailp = arrayFirst(structFindKey(record, local.findout.id_campo)).value>

			<!--- 
				Comprobamos que el participante no exista en BBDD, pero solo cuando es una nueva inserción. 
				@url.allow_duplicate Fuerza la inserción de datos.
			---> 
			<cfif getHTTPRequestData().method EQ 'POST' AND (NOT structKeyExists(url, 'allow_duplicate') OR url.allow_duplicate == false)>
				<cfset this.existsParticipant(record, arguments.rc.id_evento)>
			</cfif>

			<!--- Se validan emails duplicados --->
			<cfif arrayFind(validEmails, emailp) GT 0>
				<cfthrow message="Invalid data: Email ['#emailp#'] already exists" errorcode="400">
			</cfif>

			<!--- Obtenemos las keys de los campos para continuar con el proceso. --->
			<cfset keyList = arrayMerge(keyList, structKeyArray(record), true)>
		
			<cfset arrayAppend(validEmails, emailp)>

			<!--- Reintegramos las variables para continuar con las validaciones --->
			<cfif !isEmpty(emailp)>
				<cfset structInsert(record, 'email', emailp)>
			</cfif>
			<cfif !isEmpty(login)>
				<cfset structInsert(record, 'login', login)>
			</cfif>
			<cfif !isEmpty(password)>
				<cfset structInsert(record, 'password', password)>
			</cfif>
			<cfif !isEmpty(inscrito)>
				<cfset structInsert(record, 'inscrito', inscrito)>
			</cfif>
			<cfif !isEmpty(idtipoparticipante)>
				<cfset structInsert(record, 'id_tipo_participante', idtipoparticipante)>
			</cfif>

			<cfif idEventoBorrado>
				<cfset structInsert(record, 'id_evento', arguments.rc.id_evento)>
			</cfif>

			<cfset clientDataFields.records[key] = record>
		</cfloop>

		<cfset var ff = formS.formFields(arguments.rc.id_evento)>

		<!--- Validamos campos obligatorios --->
		<cfset this.requiredFields(keyList, clientDataFields.records, ff)>

		<!--- Validamos por tipo de campo - configuración --->
		<cfset this.configurationFields(keyList, clientDataFields.records, ff)>

		<cfset this.formFiles(keyList, clientDataFields.records, ff, arguments.rc.id_evento)>

		<cfreturn clientDataFields>
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
			reqFields = structFilter(arguments.formFields, function(key, value) {
				return structKeyExists(value.configuration, 'required') AND value.configuration.required == true;
			});

			// Obtenemos las keys como lista
			var myKeyList = structKeyList(reqFields);

			// Validamos que los campos entregados por el cliente contengan todas las keys obligatorias
			for(value in listToArray(myKeyList)) {
				if(arrayFind(arguments.keyList, value) == 0) {
					throw(message="Have not been found [#value#] into [#arrayToList(keyList)#] of the required fields [#myKeyList#]" );
				}
			}
		</cfscript>
		
		<cfreturn reqFields>
	</cffunction>

	<!--- 
		Valida campos por su configuración según el tipo de campo al que pertenezca
	 --->
	<cffunction name="configurationFields" output="false" returntype="any">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">
		<cfargument name="formFields" type="any" required="true">

		<cfset var reqFields = {}>

		<cfscript>
			try {
				for(f in arguments.fields) {
					for(k in structKeyArray(f)) {
						if(NOT structKeyExists(arguments.formFields, k)) { continue; }
						
						var fval = structFind(arguments.formFields, k);

						if(isValid('string', fval.type)) {
							switch (fval.type) {
								case "text"    : validateText(structFind(f, k), fval); break;
								case "number"  : validateNumber(structFind(f, k), fval); break;
								case "email"   : validateEmail(structFind(f, k), fval); break;
								case "date"    : validateDate(structFind(f, k), fval); break;
								case "checkbox": validateCheckbox(structFind(f, k), fval); break;
								case "radio"   : validateRadio(structFind(f, k), fval); break;
								case "select"  : validateList(structFind(f, k), fval); break;
								case "file"    : validateFile(structFind(f, k), fval); break;
								case "list"    : validateList(structFind(f, k), fval); break;
								default        : break;
							}
						}
					}
				}
			} catch(any e) { 
				throw(message="#e.message#", detail="#e.detail#"); 
			} 
		</cfscript>

		<cfreturn reqFields>
	</cffunction>

	<!--- TODO: Agregar extension imagen --->
	<cffunction name="formFiles" output="false" returntype="any">
		<cfargument name="keyList"		type="array"	required="true">
		<cfargument name="fields"		type="any"		required="true">
		<cfargument name="formFields"	type="any"		required="true">
		<cfargument name="id_evento" required="true">

		<cfset var reqFields = {}>

		<cfscript>
			// Filtramos los registros para obtener solo los campos "obligatorios"
			reqFields = structFilter(arguments.formFields, function(key, value) {
				return (value.type == 'file');
			});

			// Obtenemos las keys como lista
			var myKeyList = structKeyList(reqFields);
			var toupload = {};
			
			for(data in fields) {
				for(key in listToArray(myKeyList)) {
					if(structKeyExists(data, key)) data[key] = cdao.uploadFile(data[key], arguments.id_evento);
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
				throw(message="Error Validation. Not valid text");
			}
			if(structKeyExists(validation.configuration, 'minlength') AND validation.configuration.minlength GT 0 AND len(fvalue) LT validation.configuration.minlength) {
				throw(message="Error Validation. minlenght");
			}
			if(structKeyExists(validation.configuration, 'maxlength') AND validation.configuration.maxlength GT 0 AND len(fvalue) GT validation.configuration.maxlength) {
				throw(message="Error Validation. maxlenght");
			}
			if(validation.type EQ "url") {
				if (reFindNoCase("(^(ht|f)tp(s?)://0-9a-zA-Z(:(0-9))(/?)([a-zA-Z0-9-.?,:'/+=&%$##]_)?$)", fvalue) LT 1) {
					throw(message="Error Validation. url");
				}									
			}	
			if(structKeyExists(validation.configuration, 'dninie') AND validation.configuration.dninie) {
				validateDNINIECIF(fvalue)				
			}
			if(validation.type EQ "text") {
				if(validation.configuration.onlyAlpha AND (NOT reFindNoCase('(^[a-zA-Z0-9 .-]+$)', fvalue) LT 1)) {
					throw(message="Error Validation. only alpha");
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
			if (reFindNoCase("(^[\w!##$%&'*+/=?`{|}~^-]+(?:\.[\w!##$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$)", fvalue) EQ 0) {
				throw(message="Error Validation. email [#fvalue#]");
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

		<cfif isdefined("url.debug")>
			<cfdump var="#dni#" label="dni">
		</cfif>

		<cfscript>
			if (!isEmpty(dni)) {
				var expresion_regular_dni = '([XYZ]?[0-9]{5,8}[A-Z])';
			
				dni = ucase(dni);
				
				// LIMPIAMOS
				dni = rereplace(dni, '\ ', "", 'all');
				dni = rereplace(dni, '\,', "", 'all');
				dni = rereplace(dni, '\.', "", 'all');
				dni = rereplace(dni, '\-', "", 'all');

				if(isdefined("url.debug")) {
					writeDump(var="#dni#", label="dni");
					abort;
				}

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
				var temp    = 0;
				var temp1   = 0;
				var dc      = '';
				
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
			if(findNoCase(fvalue, ',')) fvalue = listToArray(fvalue, ',');

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
		<cfargument name="id_evento"> 

		<cfscript>	
			if(getHTTPRequestData().method == 'POST') {
				if(structKeyExists(arguments.record, 'login') OR structKeyExists(arguments.record, 'password')) {
					// if(structKeyExists(arguments.record, 'login') AND NOT structKeyExists(arguments.record, 'password')) {
					// 	throw(message="Error Validation. It has not been found login or password");
					// }

					// if(structKeyExists(arguments.record, 'password') AND NOT structKeyExists(arguments.record, 'login')) {
					// 	throw(message="Error Validation. It has not been found login or password");
					// }

					
					if(structKeyExists(arguments.record, 'login') AND isEmpty(arguments.record.login)) {
						throw(message="Error Validation. Login's empty ");
					} 

					if(structKeyExists(arguments.record, 'password') AND isEmpty(arguments.record.password)) {
						throw(message="Error Validation. Password's empty ");
					} 

					var us = dao.getByLogin(arguments.record.login, arguments.id_evento);

					if(us.recordcount GT 0) {
						for(u in us) {
							if(dao.desEncriptar(u.password) EQ arguments.record.password) {
								throw(message="Error Validation. Participante already exists");
							} 
							if(dao.desEncriptar(u.password) NEQ arguments.record.password) { 
							}
						}				
					} else {
					}
				}
			}
			if(getHTTPRequestData().method == 'PUT') {
				if(structKeyExists(arguments.record, 'email') AND structKeyExists(arguments.record, 'login')) {
					if(NOT structKeyExists(arguments.record, 'login')) {
						throw(message="Error Validation. It has not been found login");
					}

					if(structKeyExists(arguments.record, 'login') AND isEmpty(arguments.record.login)) {
						throw(message="Error Validation. Login's empty ");
					} 

					var us = dao.getByLogin(arguments.record.login, arguments.id_evento);

					if(us.recordcount LTE 0) {
						var us = dao.getByLogin(arguments.record.email, arguments.id_evento);
						if(us.recordcount GT 0) {
							throw(message="Error Validation. Participante does not exists [#arguments.record.email#].");
						}
					}
				} 
				if(structKeyExists(arguments.record, 'email') AND NOT structKeyExists(arguments.record, 'login')) {
					var us = dao.getByLogin(arguments.record.email, arguments.id_evento);

					if(us.recordcount LTE 0) {
						var us = dao.getByLogin(arguments.record.email, arguments.id_evento);
						if(us.recordcount GT 0) {
							throw(message="Error Validation. Participante does not exists [#arguments.record.login#].");
						}
					}
				}
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

	<!--- 
		Valida si existe un participante
	 --->
	<cffunction name="existsParticipant" output="false" returntype="void">
		<cfargument name="record">
		<cfargument name="id_evento">
		
		<cfset var valFieldBasic = formS.defaultFields(arguments.id_evento, session.language)>
		<cfset var validation = {}>

		<cfset validation.id_evento = arguments.id_evento>

		<cfif valFieldBasic.recordCount GT 0>
			<cfset var fieldList = structKeyList(arguments.record)>

			<cfloop query="#valFieldBasic#">
				<cfif NOT listFind(fieldList, id_campo)>
					<cfthrow message="Invalid data: Basic field [#id_campo#] does not exits" errorcode="400">		
				</cfif>

				<cfset valFieldBasic.val[currentRow] = arguments.record[id_campo]>
				<cfset structInsert(validation, descripcion, arguments.record[id_campo], true)>
			</cfloop>
		<cfelse>
			<cfthrow message="Invalid data: Basic fields are not recognized" errorcode="400">
		</cfif>

		<cfset var exists = dao.exists(validation)>

		<cfif exists>
			<cfthrow message="Invalid data: Participant already exists, can not be duplicated." errorcode="400">
		</cfif>
	</cffunction>
</cfcomponent>