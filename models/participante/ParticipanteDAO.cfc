<!--
  ParticipanteDAO
 -->
<cfcomponent output="false" accessors="true" hint="ParticipanteDAO" extends="models.BaseModel">
	<cftimer label= "models/ParticipanteDAO"></cftimer>

	<!--- Properties --->
	<cfproperty name="tParticipanteService" inject="model:tipoparticipante.TipoParticipanteService">
	<cfproperty name="qs" inject="model:QueryService">
	<cfproperty name="formS" inject="model:formulario.FormularioService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="ParticipanteDAO" output="false" hint="constructor">
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
	<cffunction name="all" hint="Todos los participantes" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset arguments.event.paramValue('total', '')>
		<cfset arguments.event.paramValue('page', 1)>
		<cfset arguments.event.paramValue('rows', queryLimit)>

		<cfif arguments.rc.total EQ ''>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_evento = <cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
			</cfquery>
			<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
		</cfif>

		<cfset var pagination = "#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">

		<cfset var link = getURLLink(arguments.rc.token)>

		<cfif NOT structKeyExists(arguments.rc, 'ids')>			
			<cfif NOT isdefined('session.clientsession.defaults.form.fields')>					
				<cfset session.clientsession.defaults.form.fields = defaultValues()>
			<cfelseif isEmpty(session.clientsession.defaults.form.fields)>
				<cfset session.clientsession.defaults.form.fields = defaultValues()>
			</cfif>
			<cfset arguments.event.paramValue('ids', session.clientsession.defaults.form.fields)>			
		</cfif>
	
		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
		
		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT DISTINCT p.id_participante, 
					#datosConsulta#,
				CONCAT("#link#/participantes/", id_participante) AS _link
				FROM vParticipantes p
				WHERE p.id_evento = #session.id_evento#
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfsavecontent>
		</cfoutput>
		
		<cfquery name="local.qParticipantes" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			#consulta#
		</cfquery>

		<cfset local.qParticipantes = qs.rellenarDatosInforme(consulta, local.qParticipantes)>

		<cfreturn local.qParticipantes>
	</cffunction>

	<!--- 
		Obtiene participante por ID
		@event 
		@rc 
		@id_participante numeric ID del participante que se requiere
	 --->
	<cffunction name="get" hint="Obtiene participante por ID" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_participante" type="numeric" required="true">

		<!--- <cftry> --->
			<cfif NOT structKeyExists(arguments.rc, 'ids')>			
				<cfif NOT isdefined('session.clientsession.defaults.form.fields')>					
					<cfset session.clientsession.defaults.form.fields = defaultValues()>
				<cfelseif isEmpty(session.clientsession.defaults.form.fields)>
					<cfset session.clientsession.defaults.form.fields = defaultValues()>
				</cfif>
				<cfset arguments.event.paramValue('ids', session.clientsession.defaults.form.fields)>			
			</cfif>
		
			<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
			
			<cfoutput>
				<cfsavecontent variable = "consulta">
					SELECT 
						p.id_participante, 
						p.id_tipo_participante AS 'id_tipo_participante',
						#datosConsulta#
					FROM vParticipantes p
					WHERE p.id_participante=#arguments.id_participante#
					AND p.id_evento=#session.id_evento#
				</cfsavecontent>
			</cfoutput>
		
			<cfquery name="local.participantesByID" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				#consulta#
			</cfquery>

			<cfset local.participantesByID = qs.rellenarDatosInforme(consulta, local.participantesByID)>

			<cfreturn local.participantesByID>
		<!--- <cfcatch type="any">
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
	<cffunction name="byType" hint="Obtiene todos los participantes por tipo de participante" output="false" returntype="Query">
		 			<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="tipo_participante" type="string" required="true">

		<cfset arguments.event.paramValue('total', '')>
		<cfset arguments.event.paramValue('page', 1)>
		<cfset arguments.event.paramValue('rows', queryLimit)>

		<!--- <cftry> --->
			<cfquery name="local.tipoParticipante" datasource="#application.datasource#">
				SELECT id_tipo_participante 
				FROM vTiposDeParticipantes 
				WHERE LOWER(nombre)=<cfqueryparam value="#arguments.tipo_participante#" CFSQLType="CF_SQL_VARCHAR">
				AND eventos_id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
			</cfquery>

			<cfif arguments.rc.total EQ ''>
				<cfquery name="local.qTotal" datasource="#application.datasource#">
					SELECT COUNT(*) AS cantidad
					FROM vParticipantes
					WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
					AND id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
				</cfquery>
				<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
			</cfif>

			<cfset var pagination="#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">
			
			<cfset var link=getURLLink(arguments.rc.token)>

			<cfquery name="local.participantesByTipo" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT nombre, apellidos, email_participante, nombre_empresa,
				CONCAT("#link#/participantes/", id_participante) AS _link
				FROM vParticipantes
				WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfquery>
			
			<!--- <cfcatch type="any">
				<cfthrow type="any" message="#cfcatch.Message#">
			</cfcatch>
		</cftry>  --->
		
		<cfreturn local.participantesByTipo>
	</cffunction>

	<cffunction name="defaultValues" returntype="any">
		<cfset var campos = formS.camposPorEvento()>
	
		<cfreturn campos>
	</cffunction>
</cfcomponent>