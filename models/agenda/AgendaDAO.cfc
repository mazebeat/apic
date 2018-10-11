<cfcomponent hint="AgendaDAO" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="trad" 		inject="model:traduccion.TraduccionService">


<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="AgendaDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<!--- 
		Obtiene todas las agendas
	 --->
	<cffunction name="index" hint="Todos las agendas" output="false" returntype="Query">	
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="language">

		<cfquery name="local.agenda" datasource="#application.datasource#">
			SELECT *
			FROM (
				SELECT
					dia,
					hora_inicio,
					hora_fin,
					s.nombre AS sala,
					act.titulo AS actividad,
					'' AS comentariosYTPTMA,
					ag.id_participante AS participante1,
					CAST('' AS UNSIGNED) AS participante2
				FROM vActividadesGeneradas ag
					INNER JOIN vActividades act 
					ON ag.id_actividad = act.id_actividad 
					AND act.id_idioma = <cfqueryparam value="#arguments.language#" cfsqltype="cf_sql_char">
					INNER JOIN vSalasSeleccionadasParaActividades sspa 
					ON sspa.id_actividad = act.id_actividad
					INNER JOIN vSalasSeleccionadasParaActividadesHoras sspah 
					ON sspah.id_sala_seleccionada = sspa.id_sala_seleccionada 
					AND sspah.id_situacion = ag.id_situacion
					INNER JOIN vHoras h
					ON h.id_hora = sspah.id_hora
					INNER JOIN vDias d 
					ON h.dias_id_dia = d.id_dia
					INNER JOIN vSalas s 
					ON s.id_sala = sspa.id_sala
				UNION
				SELECT
					dia,
					hora_inicio,
					hora_fin,
					s.nombre AS sala,
					CONCAT('#trad.get(1523, arguments.language)# ', IFNULL(p2.nombre_empresa, ''), ' (', IFNULL(p2.nombre, ''), ' ', IFNULL(p2.apellidos, ''),')') AS actividad,
					IF (rg.asignacion = '_solicitada', getComentariosYTPTMA(p.id_evento, p.id_participante, p2.id_participante), '') AS comentariosYTPTMA,
					rg.participante1,
					CAST(rg.participante2 AS UNSIGNED)
				FROM vParticipantes p
					INNER JOIN vReunionesGeneradas rg 
					ON p.id_participante = rg.participante1
					INNER JOIN vHoras h 
					ON rg.id_hora = h.id_hora
					INNER JOIN vDias d 
					ON h.dias_id_dia = d.id_dia 
					INNER JOIN vSalas s 
					ON s.id_sala = rg.id_sala
					INNER JOIN vParticipantes p2 
					ON p2.id_participante = rg.participante2
					AND p.id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="cf_sql_integer" list="true">)
					AND p2.id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			) agendas
			ORDER BY dia, hora_inicio
		</cfquery>

		<cfreturn local.agenda>
	</cffunction>

	<!--- 
		Se obtiene la agenda de un participante en concreto
	 --->
	<cffunction name="get" hint="Agenda de un participante" output="false" returntype="Query">	
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="language">
		
		<cfquery name="local.agenda" datasource="#application.datasource#">
			SELECT *
			FROM (
				SELECT
					dia,
					hora_inicio,
					hora_fin,
					s.nombre AS sala,
					act.titulo AS actividad,
					'' AS comentariosYTPTMA,
					ag.id_participante AS participante1,
					CAST('' AS UNSIGNED) AS participante2
				FROM vActividadesGeneradas ag
					INNER JOIN vActividades act 
					ON ag.id_actividad = act.id_actividad 
					AND act.id_idioma = <cfqueryparam value="#arguments.language#" cfsqltype="cf_sql_char">
					INNER JOIN vSalasSeleccionadasParaActividades sspa 
					ON sspa.id_actividad = act.id_actividad
					INNER JOIN vSalasSeleccionadasParaActividadesHoras sspah 
					ON sspah.id_sala_seleccionada = sspa.id_sala_seleccionada 
					AND sspah.id_situacion = ag.id_situacion
					INNER JOIN vHoras h
					ON h.id_hora = sspah.id_hora
					INNER JOIN vDias d 
					ON h.dias_id_dia = d.id_dia
					INNER JOIN vSalas s 
					ON s.id_sala = sspa.id_sala
				WHERE ag.id_participante = <cfqueryparam value="#arguments.rc.id_participante#" cfsqltype="cf_sql_integer">

				UNION

				SELECT
					dia,
					hora_inicio,
					hora_fin,
					s.nombre AS sala,
					CONCAT('#trad.get(1523, arguments.language)# ', IFNULL(p2.nombre_empresa, ''), ' (', IFNULL(p2.nombre, ''), ' ', IFNULL(p2.apellidos, ''),')') AS actividad,
					IF (rg.asignacion = '_solicitada', getComentariosYTPTMA(p.id_evento, p.id_participante, p2.id_participante), '') AS comentariosYTPTMA,
					rg.participante1,
					CAST(rg.participante2 AS UNSIGNED)
				FROM vParticipantes p
					INNER JOIN vReunionesGeneradas rg 
					ON p.id_participante = rg.participante1
					INNER JOIN vHoras h 
					ON rg.id_hora = h.id_hora
					INNER JOIN vDias d 
					ON h.dias_id_dia = d.id_dia 
					INNER JOIN vSalas s 
					ON s.id_sala = rg.id_sala
					INNER JOIN vParticipantes p2 
					ON p2.id_participante = rg.participante2
					AND p.id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="cf_sql_integer" list="true">)
					AND p2.id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="cf_sql_integer" list="true">)
				WHERE rg.participante1 = <cfqueryparam value="#arguments.rc.id_participante#" cfsqltype="cf_sql_integer">
			) agendas
			ORDER BY dia, hora_inicio
		</cfquery>

		<cfreturn local.agenda>
	</cffunction>

</cfcomponent>