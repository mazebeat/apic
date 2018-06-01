<cfcomponent hint="ActividadDAO" output="false" accessors="true">

	<!--- Properties --->
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ActividadDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" hint="Todos las reuniones" output="false" returntype="Query">
		<cfargument name="id_evento" type="any" required="true">

		<cftry>
			<cfquery name="local.rooms" datasource="#application.datasource#">
				SELECT
				id_sala, 
				nombre, 
				capacidad, 
				IF(id_tipo_sala = 1, 'Sala para reunión', 'Sala para actividad') AS tipo
				FROM vSalas
				WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfquery name="local.calendar" datasource="#application.datasource#">
				SELECT 
				id_hora,
				dia,
				hora_inicio,
				hora_fin,
				networking,
				activa
				FROM vCalendarios
				WHERE id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfquery name="local.reunions" datasource="#application.datasource#">
				SELECT
				-- id_reunion,
				participante1 AS 'id_participante1',
				participante2 AS 'id_participante2',
				id_sala AS 'sala',
				id_hora AS 'calendario'
				FROM vReunionesGeneradas
				WHERE id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfset result = {}>

			<cfloop query="#local.reunions#">
				<!--- Agregamos las salas --->
				<cfquery name="local.findSala" dbtype="query">
					SELECT *
					FROM [local].rooms
					WHERE id_sala = #sala#
				</cfquery>
				
				<cfset queryDeleteColumn(local.findSala, 'id_sala')>

				<cfset local.reunions.sala[currentrow] = local.findSala>	
				
				<!--- Agregamos los horarios--->
				<cfquery name="local.findCalendar" dbtype="query">
					SELECT *
					FROM [local].calendar
					WHERE id_hora = #calendario#
				</cfquery>
				
				<cfset queryDeleteColumn(local.findCalendar, 'id_hora')>

				<cfset local.reunions.calendario[currentrow] = local.findCalendar>
			</cfloop>

			<cfreturn local.reunions>
		<cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction>

	<cffunction name="getByParticipante" hint="Todos las reuniones" output="false" returntype="Query">
		<cfargument name="id_evento" type="any" required="true">
		<cfargument name="id_participante" type="numeric" required="true">

		<cftry>
			<cfquery name="local.rooms" datasource="#application.datasource#">
				SELECT
				id_sala, 
				nombre, 
				capacidad, 
				IF(id_tipo_sala = 1, 'Sala para reunión', 'Sala para actividad') AS tipo
				FROM vSalas
				WHERE eventos_id_evento IN (#id_evento#)
			</cfquery>

			<cfquery name="local.calendar" datasource="#application.datasource#">
				SELECT 
				id_hora,
				dia,
				hora_inicio,
				hora_fin,
				networking,
				activa
				FROM vCalendarios
				WHERE id_evento IN (#id_evento#)
			</cfquery>

			<cfquery name="local.reunions" datasource="#application.datasource#">
				SELECT
				-- id_reunion,
				participante1 AS 'id_participante1',
				participante2 AS 'id_participante2',
				id_sala AS 'sala',
				id_hora AS 'calendario'
				FROM vReunionesGeneradas
				WHERE id_evento IN (#id_evento#)
				AND participante1 = <cfqueryparam value="#id_participante#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfset result = {}>

			<cfloop query="#local.reunions#">
				<!--- Agregamos las salas --->
				<cfquery name="local.findSala" dbtype="query">
					SELECT *
					FROM [local].rooms
					WHERE id_sala = #sala#
				</cfquery>
				
				<cfset queryDeleteColumn(local.findSala, 'id_sala')>

				<cfset local.reunions.sala[currentrow] = local.findSala>	
				
				<!--- Agregamos los horarios--->
				<cfquery name="local.findCalendar" dbtype="query">
					SELECT *
					FROM [local].calendar
					WHERE id_hora = #calendario#
				</cfquery>
				
				<cfset queryDeleteColumn(local.findCalendar, 'id_hora')>

				<cfset local.reunions.calendario[currentrow] = local.findCalendar>
			</cfloop>

			<cfreturn local.reunions>
		<cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction>

</cfcomponent>