<cfcomponent hint="I am a new Model Object" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->
	<cfproperty name="partServ"			inject="model:participante.ParticipanteDAO">


	<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="reunionDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- 
		Obtiene todos las reuniones por tipo de participante
	--->
	<cffunction name="all" returntype="Query" outoput="false">
		<cfargument name="id_evento" type="any" required="true">
		
		<cfquery name="all" datasource="#application.datasource#">
			SELECT 
				IF(cantidad != '', cantidad, 0) AS reunionesGeneradas,
				tp.id_tipo_participante,
				nombre,
				COUNT(acc.id_tipo_participante) AS asistenciasReales
			FROM (
				SELECT COUNT(participante1) AS cantidad, p.id_tipo_participante
				FROM vParticipantes p
				INNER JOIN vReunionesGeneradas rg ON rg.participante1 = p.id_participante
				AND p.id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				GROUP BY p.id_tipo_participante
			) AS a
			RIGHT JOIN vTiposDeParticipantes tp ON tp.id_tipo_participante = a.id_tipo_participante
			LEFT JOIN (
				SELECT DISTINCT id_tipo_participante, re.id_participante, p.id_evento
				FROM vAcredRegistrosEntrada re
				INNER JOIN vParticipantes p ON p.id_participante = re.id_participante
				AND re.id_evento = p.id_evento
				AND p.id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			) acc ON acc.id_tipo_participante = tp.id_tipo_participante
			AND tp.eventos_id_evento = acc.id_evento
			WHERE tp.eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			GROUP BY tp.id_tipo_participante
			ORDER BY tp.nombre
		</cfquery>
		
		<cfreturn all>
	</cffunction>

	<!--- 
		Retorna todos las reuniones modo detalle / no detalle (url.nodetail)
	 --->
	<cffunction name="all2" returntype="Query" outoput="false">
		<cfargument name="id_evento" type="any" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfquery name="local.allReunion" datasource="#application.datasource#">
			SELECT participante1, participante2, salas_id_sala AS 'sala', horas_id_hora AS 'horario'
			FROM reunionesGeneradas
			WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND fecha_baja IS NULL
		</cfquery>

		<cfif NOT isdefined('url.nodetail')>
			<cfset local.allReunion = addDetail(local.allReunion, arguments.id_evento, arguments.event, arguments.rc)>
		</cfif>
		
		<cfreturn local.allReunion>
	</cffunction>

	<!--- 
		Obtiene todas las reuniones de una participante en cocreto
	 --->
	<cffunction name="get" returntype="Query" outoput="false">
		<cfargument name="id_evento" type="any" required="true">
		<cfargument name="id_participante" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfquery name="local.getReunion" datasource="#application.datasource#">
			SELECT participante1, participante2, salas_id_sala AS 'sala', horas_id_hora AS 'horario'
			FROM reunionesGeneradas
			WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND participante1 = #arguments.id_participante#
			AND fecha_baja IS NULL
		</cfquery>

		<cfif NOT isdefined('url.nodetail')>
			<cfset local.getReunion = addDetail(local.getReunion, arguments.id_evento, arguments.event, arguments.rc)>
		</cfif>

		<cfreturn local.getReunion>
	</cffunction>

	<!--- 
		Expande el detalle de cada reunión por id de participante1, participante2, id_horario (sala), id_hora (horario)
	 --->
	<cffunction name="addDetail"  output="false" returntype="query">
		<cfargument name="queryReunion" type="query" required="true">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset local.allParticipantes = partServ.all(arguments.id_evento, arguments.event, arguments.rc, true)>

		<cfif arguments.queryReunion.recordCount GT 0>

			<cfset queryAddColumn(arguments.queryReunion, 'participantes', 'varchar', [])>
			
			<cfloop query="#arguments.queryReunion#">
				<cfset local.participantes = []>

				<cfquery name="local.findParticipantes" dbtype="query">
					SELECT *
					FROM [local].allParticipantes
					WHERE id_participante = (#participante1#)
				</cfquery>
				<cfset arrayAppend(local.participantes, local.findParticipantes)>

				<cfquery name="local.findParticipantes" dbtype="query">
					SELECT *
					FROM [local].allParticipantes
					WHERE id_participante = (#participante2#)
				</cfquery>
				<cfset arrayAppend(local.participantes, local.findParticipantes)>

				<cfset arguments.queryReunion.participantes[currentRow] = local.participantes>

				<cfquery name="local.findHorario" datasource="#application.datasource#">
					SELECT id_hora, hora_inicio, hora_fin, dias_id_dia AS 'fecha'
					FROM vHoras
					WHERE id_hora = (#horario#)
				</cfquery>

				<cfloop query="#local.findHorario#">
					<cfquery name="local.findDia" datasource="#application.datasource#">
						SELECT dia
						FROM vDias
						WHERE id_dia = (#fecha#)
					</cfquery>
					
					<cfset local.findHorario.fecha[currentRow] = local.findDia.dia>
				</cfloop>

				<cfset arguments.queryReunion.horario[currentRow] = local.findHorario>

				<cfquery name="local.findSala" datasource="#application.datasource#">
					SELECT id_sala, nombre
					FROM vSalas
					WHERE id_sala = (#sala#)
				</cfquery>

				<cfset arguments.queryReunion.sala[currentRow] = local.findSala>
			</cfloop>

			<cfset queryDeleteColumn(arguments.queryReunion, 'participante1')>
			<cfset queryDeleteColumn(arguments.queryReunion, 'participante2')>
		</cfif>

		<cfreturn arguments.queryReunion>
	</cffunction>

</cfcomponent>