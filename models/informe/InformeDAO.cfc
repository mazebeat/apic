<!--
  ParticipanteDAO
 -->
<cfcomponent output="false" accessors="true" hint="InformeDAO" extends="models.BaseModel">
	<cftimer label= "models/InformeDAO"></cftimer>

	<!--- Properties --->
	<cfproperty name="qs" inject="model:QueryService">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="InformeDAO" output="false" hint="constructor">
		<cfscript>	
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<!--- 
		Todos los Informes
		@event 
		@rc
	 --->
	<cffunction name="getFields" hint="Todos los campos de un informes" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">

		<cftry> 
			<cfquery name="local.camposInforme" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT titulo , id_campo , id_agrupacion , id_tipo_campo_fijo
				FROM
				(
					SELECT titulo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion, ci.id_tipo_campo_fijo
					FROM vInformesCamposFormularios ic 
					INNER JOIN vCampos ci 
					ON ic.id_campo = ci.id_campo
					WHERE id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
					AND id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="CF_SQL_INTEGER">

					UNION

					SELECT titulo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion, 0 AS id_tipo_campo_fijo
					FROM vInformesCamposFormularios ic 
					INNER JOIN vCamposAgrupacionesAutomaticas ci 
					ON ic.id_campo = ci.id_campo
					WHERE id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
					AND id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="CF_SQL_INTEGER">
				) a
				ORDER BY orden, id_campo
			</cfquery>

			<cfreturn local.camposInforme>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction>

	<!--- <!--- 
		Obtiene participante por ID
		@event 
		@rc 
		@id_participante numeric ID del participante que se requiere
	 --->
	<cffunction name="get" hint="Obtiene participante por ID" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_participante" type="numeric" required="true">

		<cftry>
			<cfquery name="local.participantesByID" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT nombre, apellidos, email_participante AS email, nombre_empresa, id_tipo_participante, id_sala
				FROM vParticipantes
				WHERE id_participante = <cfqueryparam value="#arguments.id_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			
			<cfif queryColumnExists(local.participantesByID, 'id_tipo_participante')>
				<cfquery name="local.vTipoParticipante" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#"> 
					SELECT nombre FROM vTiposDeParticipantes
					WHERE id_tipo_participante = <cfqueryparam value = "#local.participantesByID.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				</cfquery>

				<cfset queryDeleteColumn(local.participantesByID, "id_tipo_participante")> 
				<cfset queryAddColumn(local.participantesByID, "tipo_participante", "varchar", [local.vTipoParticipante.nombre])>
			</cfif>

			<cfif queryColumnExists(local.participantesByID, 'id_sala')>
				<cfquery name="local.vSalas" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#"> 
					SELECT nombre FROM vSalas
					WHERE id_sala = <cfqueryparam value = "#local.participantesByID.id_sala#" CFSQLType="CF_SQL_INTEGER">
				</cfquery>

				<cfset queryDeleteColumn(local.participantesByID, "id_sala")> 
				<cfset queryAddColumn(local.participantesByID, "sala", "varchar", [local.vSalas.nombre])>
			</cfif>

			<cfreturn local.participantesByID>
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
	<cffunction name="byType" hint="Obtiene todos los participantes por tipo de participante" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="tipo_participante" type="string" required="true">

		<cfset arguments.event.paramValue('total', '')>
		<cfset arguments.event.paramValue('page', 1)>
		<cfset arguments.event.paramValue('rows', queryLimit)>

		<cftry>
			<cfquery name="local.tipoParticipante" datasource="#application.datasource#">
				SELECT id_tipo_participante 
				FROM vTiposDeParticipantes 
				WHERE LOWER(nombre) = <cfqueryparam value="#arguments.tipo_participante#" CFSQLType="CF_SQL_VARCHAR">
				AND eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfif arguments.rc.total EQ ''>
				<cfquery name="local.qTotal" datasource="#application.datasource#">
					SELECT COUNT(*) AS cantidad
					FROM vParticipantes
					WHERE id_tipo_participante = <cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
					AND id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				</cfquery>
				<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
			</cfif>

			<cfset var pagination = "#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">
			
			<cfset var link = getURLLink(arguments.rc.token)>

			<cfquery name="local.participantesByTipo" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT nombre, apellidos, email_participante, nombre_empresa,
				CONCAT("#link#/participantes/", id_participante) AS _link
				FROM vParticipantes
				WHERE id_tipo_participante = <cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfquery>
			
			<cfreturn local.participantesByTipo>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction> --->


</cfcomponent>