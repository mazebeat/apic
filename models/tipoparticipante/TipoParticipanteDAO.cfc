<!--  
	Tipo de Participante DAO
-->
<cfcomponent hint="Tipo de Participante DAO" output="false" accessors="true" extends="models.BaseModel">
	<cftimer label= "models/tipoparticipante/TipoParticipanteDAO"></cftimer>

	<!--- Properties --->
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="TipoParticipanteDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<!-- 
		Obtiene todos los tipos de participantes
		@event 
		@rc 
	-->
	<cffunction name="all" hint="Todos los tipos de participantes" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_evento">

		<cfset var link = getURLLink(arguments.rc.token)>

		<cftry>
			<cfquery name="local.configEventos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, variables.queryExpiration, 0 )#">
				SELECT id_tipo_participante, nombre, codigo,
				CONCAT("#link#/tiposparticipantes/", id_tipo_participante) AS _link
				FROM vTiposDeParticipantes
				WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">);
			</cfquery>

			<cfreturn local.configEventos>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch> 
		</cftry> 
	</cffunction>

	<!-- 
		Obtiene todos los tipos de participantes
		@event 
		@rc 
	-->
	<cffunction name="get" hint="Retorna un tipo de participante especifico por ID" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_evento" type="any" required="true">
		<cfargument name="id_tipo_participante" type="numeric" required="true">

		<cftry>
			<cfquery name="local.configEventos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, variables.queryExpiration, 0 )#">
				SELECT id_tipo_participante, nombre, codigo, cantidad_limite_reuniones, max_inscritos, max_comunicaciones
				FROM vTiposDeParticipantes
				WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND id_tipo_participante = <cfqueryparam value = "#arguments.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">;
			</cfquery>

			<cfreturn local.configEventos>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch> 
		</cftry> 
	</cffunction>


</cfcomponent>