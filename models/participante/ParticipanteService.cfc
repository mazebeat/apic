<!--
  Participante Service
 -->
<cfcomponent output="false" accessors="true" hint="ParticipanteService">
	<cftimer label= "models/ParticipanteService"></cftimer>

	<!--- Properties --->
	<cfproperty name="dao"		inject="model:participante.ParticipanteDAO">
    <cfproperty name="log"		inject="logbox:logger:{this}">
	<cfproperty name="tpDAO"	inject="model:tipoparticipante.TipoParticipanteDAO">
    
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

		<cftry>
			<cfset var records = dao.get(event, rc, id_participante)>
			<cfif isdefined("url.debug")>
				<cfdump var="#records#" label="records">
				<cfabort>
			</cfif>
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
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

</cfcomponent>