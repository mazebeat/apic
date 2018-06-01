<!--  
	Evento DAO
-->
<cfcomponent hint="Evento DAO" output="false" accessors="true" extends="models.BaseModel">

	<!-- Properties -->
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="EventoDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<!--- // BUG: Cambiar id_evento por uno dinámico. --->
	<!-- 
		Obtiene todos los eventos asociados al cliente.
	 -->
	<cffunction name="all" hint="Todos los eventos" output="false" returntype="Query">
		<cfargument name="id_evento">

		<cftry>
			<cfquery name="local.configEventos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT -- id_evento_configuracion,
					nombre,
					descripcion,
					lugar,
					-- fecha_alta,
					-- fecha_baja,
					-- fecha_modif,
					-- eventos_id_evento,
					fecha_inicio,
					fecha_fin,
					identificacion,
					nombreSalasReuniones,
					organizador,
					-- id_tipo_control_acceso,
					-- zona_horaria,
					emailOrganizador,
					max_inscritos,
					max_inscritos_activo,
					mensajes_sin_leer_para_avisar,
					-- pie_activo_pag_web,
					-- pie_activo_formulario,
					-- notificaciones_push,
					id_moneda
				FROM vConfiguracionEventos
				WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfif queryColumnExists(local.configEventos, 'id_moneda')>
			<cfquery name="local.moneda" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#"> 
					SELECT texto_#session.language# AS texto 
					FROM sige.vMonedas
					WHERE id_moneda = <cfqueryparam value = "#local.configEventos.id_moneda#" CFSQLType="CF_SQL_INTEGER">
				</cfquery>

				<cfset queryDeleteColumn(local.configEventos, "id_moneda")> 
				<cfset queryAddColumn(local.configEventos, "moneda", "varchar", [local.moneda.texto])>
			</cfif>

			<cfquery name="local.eventos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT 
					id_evento,
					nombre,
					-- clientes_id_cliente,
					-- fecha_alta,
					-- fecha_caducidad,
					-- fecha_baja,
					-- fecha_modif,
					-- activo,
					tiposEventos_id_tipo_evento AS id_tipo_evento
					-- texto_ES,
					-- texto_EN,
					-- id_gestor
				FROM vEventos
				WHERE id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>

			<cfinclude template = "/includes/helpers/QuerysHelper.cfm">		

			<cfset var union = QueryAppend2(local.eventos, local.configEventos)>			

			<cfreturn union>
		<cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction>

	<cffunction name="getByIdCliente" hint="Todos los eventos" output="false" returntype="Query">
		<cfargument name="id_cliente" type="numeric" required="true">

		<cftry>
			<cfquery name="local.eventoByIdCliente" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT GROUP_CONCAT(id_evento) AS id_evento, id_tipo_evento, clientes_id_cliente, activo, id_gestor FROM sige.vEventos
				WHERE clientes_id_cliente = <cfqueryparam value="#arguments.id_cliente#" CFSQLType="CF_SQL_INTEGER">
			</cfquery>

			<cfreturn local.eventoByIdCliente>
		<cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
	</cffunction>

	

</cfcomponent>