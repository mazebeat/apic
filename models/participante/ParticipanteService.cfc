<!--
  Participante Service
 -->
<cfcomponent output="false" accessors="true" hint="ParticipanteService">
	<cftimer label= "models/ParticipanteService"></cftimer>

	<!--- Properties --->
	<cfproperty name="cache" 	inject="cachebox:default">
	<cfproperty name="tpDAO"	inject="model:tipoparticipante.TipoParticipanteDAO">
	<cfproperty name="valS"		inject="model:FormValidationService">
	<cfproperty name="dao"		inject="model:participante.ParticipanteDAO">
	<cfproperty name="log" 		inject="logbox:logger:{this}">

    
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
		<cfargument name="prc">
		
		<cfset var s = { ok = true, mensaje= "", data = { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1" } }>

		<cfset var records = dao.all(arguments.event, arguments.rc, arguments.prc)>

		<cfif queryColumnExists(records, 'id_tipo_participante')>
			<cfset var tipoParticipantes = tpDAO.all(arguments.event, arguments.rc, arguments.prc)>
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
		S
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
		<cfargument name="prc">

		<cfset var s = { ok =true, mensaje="", data ={ "records"={},  "count"=0 } }>

		<!--- <cfset var cacheKey = 'q-participante-get-#arguments.rc.id_participante#'>

		<cfif cache.lookup(cacheKey)>
			<cfset var records = cache.get(cacheKey)>
		<cfelse> --->
			<cfset var records = dao.get(arguments.event, arguments.rc, arguments.prc)>

			<!--- <cfset cache.set(cacheKey, records, 60, 30)>
		</cfif> --->

		<cfset s.data.records = records>
		<cfset s.data.count   = records.recordCount>
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Obtiene todos los participantes por tipo de participante
		@event
		@rc 
		@tipo_participante string Tipo de participante
	 --->
	<cffunction name="byType" hint="Obtiene todos los participantes por tipo de participante" output="false" returntype="struct">
		<cfargument name="event"> 
		<cfargument name="rc">
		<cfargument name="prc">		

		<cfset var s = { ok= true, mensaje= "", data= { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1"} }>
		
		<cfset var records = dao.byType(arguments.event, arguments.rc, arguments.prc)>
		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		<cfset s.data.total = arguments.rc.total>

		<cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
			<cfset var pages =  arguments.rc.page & " of " & round(arguments.rc.total/arguments.rc.rows  + 0.45)>
			<cfset s.data.pages = pages>
		</cfif>
		
		<cfreturn s>
	</cffunction>

	<!--- 

	 --->
	<cffunction name="byEmail" hint="Obtiene participante(s) por email" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = { ok= true, mensaje= "", data= { "records"={},  "count"= 0, "total"= 0, "pages"= "1 of 1"} }>

		<cfif !structKeyExists(arguments.rc, "email")>
			<cfset s.ok = false>
			<cfset s.message = "It haven't found a valid Email">
			<cfreturn s>
		</cfif>
		
		<cfset var cacheKey = 'q-participante-findByemail-#arguments.rc.email#'>
		
		<!--- <cfif cache.lookup(cacheKey)>
			<cfset var records = cache.get(cacheKey)>
		<cfelse> --->
			<cfset var records = dao.findByEmail(arguments.event, arguments.rc, arguments.prc)>

			<!--- <cfset cache.set(cacheKey, records, 60, 30)>
		</cfif> --->

		<cfset s.data.records = records>
		<cfset s.data.count   = records.recordCount>
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Crea un participante
		@event
		@rc
	 --->
	<cffunction name="create" hint="" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = { mensaje= "", data= { "records"=[] } }>
		<cfset var out = ''>

		<cfset var dataFields = valS.validateCreateDataFields(arguments.rc)>
		<cfset var vList = { a = [], b = [], c = [] }>

		<cfloop collection="#dataFields.records#" item="key">
			<cfset var result = dao.genCreate(event, rc, dataFields.records[key], key)>

			<cfset arrayAppend(vList.a, result.a)>
			<cfset vList.b = arrayMerge(vList.b, result.b)>
			<cfset arrayAppend(vList.c, result.c)>
		</cfloop>

		<cftransaction> 
			<cftry> 				
				<cfset out = dao.doCreate(event, rc, vList)>

				<cfif isdefined('url.view_detail')>
					<cfloop list="#out#" item="l">
						<cfset arguments.rc.id_participante = l>
						<cfset arrayAppend(s.data.records, get(arguments.event, arguments.rc, arguments.prc).data.records)>
					</cfloop>
				<cfelse>
					<cfset s.data.records = {
						'new_id_participante' = out
					}>		
				</cfif>
				<cfset s.mensaje = "Participantes have been created successfuly">

				<cftransaction action="commit" /> 
			<cfcatch type="any"> 
				<cftransaction action="rollback" />	
				<cfrethrow>
			</cfcatch> 
			</cftry> 
		</cftransaction>
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Modifica un participante
		@modify
		@rc
	 --->
	<cffunction name="modify" hint="" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = { mensaje= "", data= { "records"=[] } }>
		<cfset out = ''>

		<cfset dataFields = valS.validateCreateDataFields(arguments.rc)>
		<cfset vList = { a = [], b = [], c = [], d = [] }>
		
		<cfloop collection="#dataFields.records#" item="key">
			<cfset record = dataFields.records[key]>
			<cfset result = dao.genCreate(event, rc, record, key)>

			<cfset arrayAppend(vList.a, result.a)>
			
			<cfset vList.b = arrayMerge(vList.b, result.b)>

			<cfset arrayAppend(vList.c, result.c)>
			<cfset arrayAppend(vList.d, record.email)>
		</cfloop>

		<cftransaction> 
			<cftry> 
				<cfset out = dao.doUpdate(event, rc, vList)>

				<cfif isdefined('url.view_detail')>
					<cfloop list="#out#" item="l">
						<cfset arguments.rc.id_participante = l>
						<cfset arrayAppend(s.data.records, get(arguments.event, arguments.rc, arguments.prc).data.records)>
					</cfloop>
				<cfelse>
					<cfset s.data.records = { "modif_id_participante" : out }>
				</cfif>

				<cfset s.mensaje = "Participantes have been updated successfuly">

				<cftransaction action="commit" /> 					
			<cfcatch type="any"> 
				<cftransaction action="rollback" /> 					
				<cfrethrow>
			</cfcatch> 
			</cftry>
		</cftransaction>

		<cfreturn s>
	</cffunction>

	<cffunction name="defaultValues" returntype="any">
		<cfargument name="filtered" type="boolean" default="false" required="false">
	
		<cfreturn dao.defaultValues(filtered)>
	</cffunction>
</cfcomponent>