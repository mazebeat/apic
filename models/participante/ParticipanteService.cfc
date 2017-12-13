<!--
  Participante Service
 -->
<cfcomponent output="false" accessors="true" hint="ParticipanteService">
	<cftimer label= "models/ParticipanteService"></cftimer>

	<!--- Properties --->
	<cfproperty name="dao"		inject="model:participante.ParticipanteDAO">
    <cfproperty name="log"		inject="logbox:logger:{this}">
	<cfproperty name="tpDAO"	inject="model:tipoparticipante.TipoParticipanteDAO">
	<cfproperty name="cache" 	inject="cachebox:default">
	<cfproperty name="formS" inject="model:formulario.FormularioService">

    
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="ParticipanteService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- 
		Todos los participantes
		@event 
		@rc
	 --->
	<cffunction name="all" hint="Todos los participantes" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1" } }>

		<cfset var records = dao.all(arguments.event, arguments.rc)>
		
		<cfif queryColumnExists(records, 'id_tipo_participante')>
			<cfset var tipoParticipantes = tpDAO.all(arguments.event, arguments.rc)>
			<!--
				Se modifica el valor de cada tipo participante por el los datos relacionados a el mismo.
			-->
			<cfloop query = "records">
				<cfif NOT isQuery(records.id_tipo_participante)>
					<cfset var tp = QueryFilter(tipoParticipantes, function(tp) {
								return tp.id_tipo_participante IS id_tipo_participante;
						})>
					<cfset records['id_tipo_participante'] [records.currentRow] = tp> 
				</cfif>
			</cfloop>
		</cfif>
		
		<cfset s.data.records = records>
		<cfset s.data.count   = records.recordCount>
		<cfset s.data.total   = arguments.rc.total>

		<cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
			<cfset var pages =  arguments.rc.page & " of " & round(arguments.rc.total/arguments.rc.rows  + 0.6)>
			<cfset s.data.pages   = pages>
		</cfif>
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Obtiene participante por ID
		@event 
		@rc 
		@id_participante numeric ID del participante que se requiere
	 --->
	<cffunction name="get" hint="Obtiene participante por ID" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_participante" type="numeric" required="true">

		<cfset s = { ok =true, mensaje="", data ={ "records"={},  "count"=0 } }>

		<!--- <cftry> --->
			<!--- <cfset var cacheKey = 'q-participante-get-#id_participante#'>

			<cfif cache.lookup(cacheKey)>
				<cfset var records = cache.get(cacheKey)>
			<cfelse> --->
				<cfset var records = dao.get(event, rc, id_participante)>

				<!--- <cfset cache.set(cacheKey, records, 60, 30)> --->
			<!--- </cfif> --->

			<cfset s.data.records = records>
			<cfset s.data.count   = records.recordCount>
	<!--- 	<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Obtiene todos los participantes por tipo de participante
		@event
		@rc 
		@ tipo_participante string Tipo de participante
	 --->
	<cffunction name="byType" hint="Obtiene todos los participantes por tipo de participante" output="false" returntype="struct">
		<cfargument name="event"> 
		<cfargument name="rc">
		<cfargument name="tipo_participante" type="string" required="true">

		<cfset s = { ok= true, mensaje= "", data= { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1"} }>

		<!--- <cftry> --->
			<cfset var records = dao.byType(event, rc, tipo_participante)>			
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
			<cfset s.data.total = arguments.rc.total>

			<cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
				<cfset var pages =  arguments.rc.page & " of " & round(arguments.rc.total/arguments.rc.rows  + 0.45)>
				<cfset s.data.pages   = pages>
			</cfif>
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Crea un participante
	 --->
	<cffunction name="create" hint="" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset s = { ok= true, mensaje= "", data= { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1"} }>

		<!--- <cftry> --->
			<cfset dataFields = validateCreateDataFields(event.getHTTPContent( json=true ))>
			<cfset out = {}>
				
			<cfloop collection="#dataFields.data.records#" item="key">
				<cfset record = dataFields.data.records[key]>
				<cfset structAppend(out, dao.create(event, rc, record))>
			</cfloop>

			<cfif isdefined("url.debug")>
				<cfdump var="#out#" label="out">
				<cfabort>
			</cfif>

			<cfset s.data.records = out>
		
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->

		<cfreturn s>
	</cffunction>

	<cffunction name="validateCreateDataFields" returntype="struct">
		<cfargument name="dataFields" type="struct" required="true">

		<!--- Se valida la estructura de la respuesta --->
		<cfif NOT structKeyExists(dataFields, 'data') OR NOT isStruct(dataFields.data)>
			<cfthrow message="Invalida JSON Data. The key 'data' does not exists or is not a object">
		</cfif>

		<cfif NOT structKeyExists(dataFields.data, 'records') OR NOT isArray(dataFields.data.records)>
			<cfthrow message="Invalida JSON Data. The key 'data.records' does not exists or is not an array">
		</cfif>
		
		<!--- Se obtienen los campos básicos --->
		<cfset var defaultFields = dao.defaultValues(filtered=false)>

		<!--- Se recorre cada uno de los registros entregados --->
		<cfloop collection="#dataFields.data.records#" item="key">
			<cfset record = dataFields.data.records[key]>

			<!--- Validamos si existe el campo "id_tipo_participante" --->
			<cfif structKeyExists(record, 'id_tipo_participante')>
				<cfset idtipoparticipante = record.id_tipo_participante>
				<cfset structDelete(record, 'id_tipo_participante')>
			<cfelse>
				<cfthrow message="Invalida JSON Data. ID tipo participante does not exists">
			</cfif>

			<!--- Validamos que al menos venga el campo correo --->
			<cfquery name="local.findout" dbtype="query"> 
				SELECT * AS q 
				FROM defaultFields
				WHERE id_campo IN (#structKeyList(record, ",")#)
				AND (titulo LIKE '%mail%' OR titulo LIKE '%correo%')
			</cfquery>

			<cfif local.findout.recordcount LTE 0>
				<cfthrow message="ID field 'Email' does not exists in register [#key#] ">
			</cfif>

			<!--- Validamos campos obligatorios --->

			<!--- Validamos por tipo de campo - configuración --->

			<!--- Renovamos variables para el proceso de guardado en BBDD --->
			<cfset structInsert(record, 'email', arrayFirst(structFindKey(dataFields, local.findout.id_campo)).value)>
			<cfset structInsert(record, 'id_tipo_participante', idtipoparticipante)>
			<cfset dataFields.data.records[key] = record>
		</cfloop>

		<cfreturn dataFields>
	</cffunction>

</cfcomponent>