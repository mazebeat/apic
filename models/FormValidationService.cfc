
<!-- 
	Validation Service
 -->
<cfcomponent hint="Validation Service" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="formS"	inject="model:formulario.FormularioService">
	<cfproperty name="dao"		inject="model:participante.ParticipanteDAO">
	<cfproperty name="cdao"		inject="model:campo.CampoDAO">
	<cfproperty name="log" 		inject="logbox:logger:{this}">

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
	<cffunction name="validateCreateDataFields" output="false" returntype="struct">
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
			<cfif !structKeyExists(record, 'id_tipo_participante')>
				<cfthrow message="Invalid data: ID tipo participante does not exists" errorcode="400">
			</cfif>
			<!--- Validamos si existe el campo "login-password-id_participante-id_tipo_participante-etc..." --->
			<cfif structKeyExists(record, 'id_participante')>
				<cfset structDelete(record, 'id_participante')>
			</cfif>
			<!--- Validamos que al menos venga el campo correo --->			
			<cfquery name="local.findout" dbtype="query">
				SELECT id_campo
				FROM defaultFields
				WHERE id_campo IN (#arrayToList(reMatch('\b\d+(?=,|$)\b', structKeyList(record)))#)
				AND (titulo LIKE '%correo%' OR titulo LIKE '%mail%' OR titulo LIKE '%mail%')
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
			
			<cfset clientDataFields.records[key] = record>
		</cfloop>

		<cfset var ff = formS.formFields(arguments.rc.id_evento)>
		
		<!--- Validamos campos obligatorios --->
		<cfset this.requiredFields(keyList, clientDataFields.records, ff)>

		<!--- Validamos por tipo de campo - configuración --->
		<cfset this.configurationFields(clientDataFields.records, ff)>

		<!--- Se suben los ficheros tipo archivo --->
		<cfset this.formFiles(keyList, clientDataFields.records, ff, arguments.rc.id_evento)>

		<!--- TODO: Agregar el rollback del upload --->

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
	<cffunction name="configurationFields" output="false" returntype="void">		
		<cfargument name="fields" type="any" required="true">
		<cfargument name="formFields" type="any" required="true">

		<cfscript>
			try{
				for(f in arguments.fields) {
					for(k in structKeyArray(f)) {
						if(NOT structKeyExists(arguments.formFields, k)) { continue; }
						
						var fval = structFind(arguments.formFields, k);
						var val = structFind(f, k);

						if(isValid('string', fval.type)) {
							switch (fval.type) {
								case "text"    : validateText(val, fval); break;
								case "number"  : validateNumber(val, fval); break;
								case "email"   : validateEmail(val, fval); break;
								case "date"    : validateDate(val, fval); break;
								case "checkbox": validateCheckbox(val, fval); break;
								case "radio"   : validateRadio(val, fval); break;
								case "select"  : validateList(val, fval); break;
								case "file"    : validateFile(val, fval); break;
								default        : break;
							}
						}
					}
				}
			} catch(any ex) {
				if(isdefined("url.debug")) {
					writeDump(var="#ex#", label="ex");
					abort;
				}
				rethrow;
			}
		</cfscript>
	</cffunction>

	<!--- TODO: Agregar extension imagen --->
	<cffunction name="formFiles" output="false" returntype="any">
		<cfargument name="keyList"		type="array"	required="true">
		<cfargument name="fields"		type="any"		required="true">
		<cfargument name="formFields"	type="any"		required="true">
		<cfargument name="id_evento" 	required="true">

		<cfset var reqFields = {}>

		<cfscript>
			// Filtramos los registros para obtener solo los campos "obligatorios"
			reqFields = structFilter(arguments.formFields, function(key, value) {
				return (value.type == 'file');
			});

			// Obtenemos las keys como lista
			var myKeyList = structKeyList(reqFields);
			var toupload = {};

			for(data in arguments.fields) {
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
			if(NOT isValid("string", arguments.fvalue)) {
				throw(message="Error Validation. Not valid text on [#arguments.fvalue#]");
			}
			if(structKeyExists(arguments.validation.configuration, 'minlength') AND arguments.validation.configuration.minlength GT 0 AND len(arguments.fvalue) LT arguments.validation.configuration.minlength) {
				throw(message="Error Validation. minlenght on [#arguments.fvalue#]");
			}
			if(structKeyExists(arguments.validation.configuration, 'maxlength') AND arguments.validation.configuration.maxlength GT 0 AND len(arguments.fvalue) GT arguments.validation.configuration.maxlength) {
				throw(message="Error Validation. maxlenght on [#arguments.fvalue#]");
			}
			if(arguments.validation.type EQ "url") {				
				if (reFindNoCase('(^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$)', arguments.fvalue) LT 1) {
					throw(message="Error URL validation on [#arguments.fvalue#]");
				}									
			}				
			if(arguments.validation.type EQ "text") {
				if(arguments.validation.configuration.onlyAlpha AND reFindNoCase('((?!\s)(?:\d|\W))', arguments.fvalue) GT 0) {					
					throw(message="Error Validation. only alpha on [#arguments.fvalue#]");
				}
			}
			if(structKeyExists(arguments.validation.configuration, 'dninie') AND arguments.validation.configuration.dninie) {
				validateDNINIECIF(arguments.fvalue)				
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
 
		<cfscript>
			if (!isEmpty(arguments.dni)) {
				var expresion_regular_dni = '([XYZ]?[0-9]{5,8}[A-Z])';
			
				arguments.dni = ucase(arguments.dni);
				
				// LIMPIAMOS
				arguments.dni = rereplace(arguments.dni, '\ ', "", 'all');
				arguments.dni = rereplace(arguments.dni, '\,', "", 'all');
				arguments.dni = rereplace(arguments.dni, '\.', "", 'all');
				arguments.dni = rereplace(arguments.dni, '\-', "", 'all');

				if(reFindNoCase(expresion_regular_dni, arguments.dni) EQ 1) {
					numero = mid(arguments.dni, 1, len(arguments.dni) - 1)
					numero = replace(numero, 'X', 0, 'all');
					numero = replace(numero, 'Y', 1, 'all');
					numero = replace(numero, 'Z', 2, 'all');
					let    = mid(arguments.dni, len(arguments.dni), 1);
					
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
	<cffunction name="validateDate" output="false" returntype="boolean">
		<cfargument name="fvalue">
		<cfargument name="validation">

		<cfscript>
			var regex = '(^\d{4}(-\d\d(-\d\d(T\d\d:\d\d(:\d\d)?(\.\d+)?(([+-]\d\d:\d\d)|Z)?)?)?)?$)';
			
			if(arrayLen(reMatch(regex, fvalue)) LTE 0) {
				throw(message="Error Validation. Field date is not a date"); 
			} 

			return true;
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
			
			if(!isValid('URL', fvalue) 
				// OR !isFileObject(fvalue) 
				// OR !isImageFile(fvalue) 
				// OR !isPDFFile(fvalue)
				) {
				throw(message="Error Validation. Field 'file' is not a valid URL file"); 
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
			<cfset var fieldList = listFilter(structKeyList(arguments.record), function(_i) {
				return reFind('(\d)', _i) GT 0;
			})>
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