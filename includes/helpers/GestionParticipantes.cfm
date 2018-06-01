<!--- <cffunction name="detectarBusquedaConOperador" returntype="struct" output="false">
	<cfargument name="valor" required="true">

	<cfset var s =
	{
		operadorEncontrado : false,
		valor : arguments.valor
	}>
	<cfset var valor = replace(arguments.valor, ' ', '', 'ALL')>
	<cfset valor = replace(valor, ',', '.', 'ALL')>

	<cfset var operadores = ['>=', '<=', '=', '>', '<']>

	<cfset var i = 1>
	<cfset var operadorBuscado = ''>
	<!--- <cfloop from="1" to="#operadores.len()#" index="i"> --->
	<cfloop condition="(i le operadores.len()) and not s.operadorEncontrado">
		<cfset operadorbuscado = operadores[i]>
		<cfif find(operadorbuscado, valor) gt 0>
			<!--- HEMOS ENCONTRADO UN OPERADOR --->
			<cfset s.operador = operadorBuscado>
			<cfset s.valorBuscado = replace(valor, operadorBuscado, '')>
			<cfif isNumeric(s.valorBuscado)>
				<cfset s.operadorEncontrado = true>
			</cfif>
		<cfelse>
		</cfif>
		<cfset i++>
	</cfloop>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereEstadoInvitacionesExpositor" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="valor" required="true">

	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfoutput>
	<cfswitch expression="#arguments.id_campo#">
		<!--- INVITACIONES ASIGNADAS --->
		<cfcase value="260">
			<cfsavecontent variable="s">
				<cfquery name="local.qCantidadInvitacionesAsignadas" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,5)#">
					select
					    p.id_participante
					from
					    vParticipantes p
					        INNER JOIN
					    vAreaExpositorTiposParticipantesInvitaciones aetpi ON p.id_tipo_participante = aetpi.id_tipo_participante
					        LEFT JOIN
					    vAreaExpositorInvitacionesParticipantes aeip ON p.id_participante = aeip.id_participante
					where p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and IFNULL(aeip.cantidad, aetpi.cantidad) = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
				</cfquery>

				#generarListaParticipantesAFiltrar(local.qCantidadInvitacionesAsignadas)#
			</cfsavecontent>
		</cfcase>

		<!--- INVITACIONES CARGADAS --->
		<cfcase value="261">
			<cfsavecontent variable="s">
				<cfquery name="local.qCantidadInvitacionesCargadas" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,5)#">
					select count(id_invitacion) as cantidad, ifnull(id_anfitrion, 0) as id_participante
					from vAreaExpositorInvitaciones
					where fecha_baja is null
						and id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					group by id_anfitrion
					having count(id_invitacion) = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
				</cfquery>

				#generarListaParticipantesAFiltrar(local.qCantidadInvitacionesCargadas)#
			</cfsavecontent>
		</cfcase>

		<!--- INVITACIONES USADAS --->
		<cfcase value="262">
			<cfsavecontent variable="s">
				<cfquery name="local.qCantidadInvitacionesUsadas" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,5)#">
					select count(id_invitacion) as cantidad, id_anfitrion as id_participante
					from vAreaExpositorInvitaciones
					where fecha_baja is null
						and fecha_envio_invitacion is not null
						and id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					group by id_anfitrion
					having count(id_invitacion) = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
				</cfquery>

				#generarListaParticipantesAFiltrar(local.qCantidadInvitacionesUsadas)#
			</cfsavecontent>
		</cfcase>

		<!--- INVITACIONES NO USADAS --->
		<cfcase value="263">
			<cfsavecontent variable="s">
				<cfquery name="local.qCantidadInvitacionesNoUsadas" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,5)#">
					select asignadas.cantidad as cantidadUsadas, asignadas.id_participante, ifnull(usadas.cantidad, 0), ifnull(usadas.id_participante, asignadas.id_participante)
					from
					(
						select
						    IFNULL(aeip.cantidad, aetpi.cantidad) as cantidad, p.id_participante
						from
						    vParticipantes p
						        INNER JOIN
						    vAreaExpositorTiposParticipantesInvitaciones aetpi ON p.id_tipo_participante = aetpi.id_tipo_participante
						        LEFT JOIN
						    vAreaExpositorInvitacionesParticipantes aeip ON p.id_participante = aeip.id_participante
						where p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					) as asignadas left join
					(
						select count(id_invitacion) as cantidad, aei.id_anfitrion as id_participante
						from vAreaExpositorInvitaciones aei
						where fecha_baja is null
							and fecha_envio_invitacion is not null
							and id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						group by id_anfitrion
					) as usadas
					on asignadas.id_participante = usadas.id_anfitrion
					where (asignadas.cantidad - ifnull(usadas.cantidad, 0)) = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
				</cfquery>

				#generarListaParticipantesAFiltrar(local.qCantidadInvitacionesNoUsadas)#
			</cfsavecontent>
		</cfcase>
	</cfswitch>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaEstadoInvitacionesExpositor" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="nombreCampo" required="true">

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfoutput>
	<cfswitch expression="#arguments.id_campo#">
		<cfdefaultcase>
			<cfsavecontent variable="s">
				"estadoInvitacionesExpositor_#id_campo#" as '#codificarNombreColumna(arguments.nombreCampo)#'
			</cfsavecontent>
		</cfdefaultcase>
	</cfswitch>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaCampoMultiActividadesWhere" access="public" returntype="string" output="false">
	<cfargument name="id_actividad" required="true">
	<cfargument name="valor" required="true">
	<cfargument name="que" required="true">

	<cfset var s = ''>
		<cfoutput>
		<cfswitch expression="#arguments.que#">
			<!--- LISTADO DE MULTIACTIVIDADES --->
			<cfcase value="ASIGNADA">
				<cfsavecontent variable="s">
					<!--- COGEMOS LOS TIPOS DE PARTICIPANTE DE ESTA ACTIVIDAD --->
					<cfquery name="local.qTipos" datasource="#application.datasource#">
						select id_tipo_participante
						from vSeleccionMultiActividadesTipoDeParticipante
						where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
							and seleccionada = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
					</cfquery>

					<!--- COGEMOS LOS PARTICIPANTES DE ESTOS TIPOS QUE LA TIENEN ASIGNADA --->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select id_participante
						from
						(
							select id_participante
							from vParticipantes
							where id_tipo_participante in (<cfqueryparam value="#valueList(local.qTipos.id_tipo_participante)#" list="true" cfsqltype="cf_sql_integer">)

							<cfif arguments.valor is 0>
								and id_participante not in
								(
									SELECT id_participante
								FROM vParticipantesSeleccionMultiactividades
						    	where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
						    		and asignada = 1
								)
							</cfif>

							union

							SELECT id_participante
							FROM vParticipantesSeleccionMultiactividades
					    	where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
					    		and asignada = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
						) a
					</cfquery>

					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- COGEMOS LOS PARTICIPANTES QUE TIENEN ESTA ACTIVIDAD CONFIRMADA --->
			<cfcase value="CONFIRMADA">
				<cfsavecontent variable="s">
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select id_participante
						from vParticipantesSeleccionMultiactividades
						where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
							and confirmada = 1
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaCampoMultiActividades" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="nombre" required="true"/>
	<cfargument name="id_actividad" required="true">
	<cfargument name="que" required="true">

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombre)>

	<cfoutput>
		<cfswitch expression="#arguments.que#">
			<!--- LISTADO DE MULTIACTIVIDADES --->
			<cfcase value="ASIGNADA">
				<cfsavecontent variable="s">
					(
						case estaMultiactividadAsignada(p.id_participante, p.id_tipo_participante, #arguments.id_actividad#)
                            when 0 then '#objTraducciones.getString(1237)#'
                            else '#objTraducciones.getString(1236)#'
                        end
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="CONFIRMADA">
				<cfsavecontent variable="s">
					(
						case estaMultiactividadConfirmada(p.id_participante, #arguments.id_actividad#)
                            when 0 then '#objTraducciones.getString(1237)#'
                            else '#objTraducciones.getString(1236)#'
                        end
					) as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaMensajeriaWhere" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>

	<cfset var s = ''>
	<cfswitch expression="#id_campo#">
		<!--- Cantidad de mensajes recibidos --->
		<cfcase value="256">
			<cfoutput>
			<cfsavecontent variable="s">
				<!--- COGEMOS LOS QUE HAN RECIBIDO ALGÚN MENSAJE --->
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select distinct(m.para) as id_participante
					from vMensajeria m inner join vParticipantes p
						on p.id_participante = m.de
						and p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					where m.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and isNull(m.fecha_baja_desde)
				</cfquery>
				<cfif valor is 1>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				<cfelse>
					#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
				</cfif>
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Cantidad de mensajes no leidos --->
		<cfcase value="257">
			<cfoutput>
			<cfsavecontent variable="s">
				<!--- COGEMOS LOS QUE HAN RECIBIDO ALGÚN MENSAJE NO LEIDO--->
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select distinct(m.para) as id_participante
					from vMensajeria m inner join vParticipantes p
						on p.id_participante = m.de
						and p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					where m.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and isNull(m.fecha_baja_desde)
						and leido = 0
				</cfquery>
				<cfif valor is 1>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				<cfelse>
					#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
				</cfif>
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Cantidad de mensajes enviados --->
		<cfcase value="258">
			<cfoutput>
			<cfsavecontent variable="s">
				<!--- COGEMOS LOS QUE HAN ENVIADO ALGÚN MENSAJE--->
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select distinct(m.de) as id_participante
					from vMensajeria m inner join vParticipantes p
						on p.id_participante = m.para
						and p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					where m.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and isNull(m.fecha_baja_desde)
				</cfquery>
				<cfif valor is 1>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				<cfelse>
					#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
				</cfif>
			</cfsavecontent>
			</cfoutput>
		</cfcase>
	</cfswitch>

	<cfreturn s>
</cffunction>


<!---Julia--->

<cffunction name="generarUnaColumnaAreaPrivada" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfswitch expression="#id_campo#">
		<!--- USUARIO --->
			<cfcase value="1">
				<cfoutput>
				<cfsavecontent variable="s">
					p.login as "#n#"
				</cfsavecontent>
				</cfoutput>
			</cfcase>
		<!--- ENCUESTAS REALIZADAS --->
		<cfcase value="245">
			<cfoutput>
			<cfsavecontent variable="s">
				<!--- participantesListaEncuestasRealizadas(p.id_participante) as "#n#" --->
				("LISTADO_ENCUESTAS_REALIZADAS") as "#n#"
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- log_app --->
		<cfcase value="266">
			<cfoutput>
			<cfsavecontent variable="s">
				(

					"LOG_APP"

				) as "#n#"

			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Ultima fecha Log_app --->
		<cfcase value="267">
			<cfoutput>
			<cfsavecontent variable="s">

				date_format(p.last_login, '%d/%m/%Y %H:%i:%s') as "#n#"

			</cfsavecontent>
			</cfoutput>
		</cfcase>

			<!--- AREA DEL EXPOSITOR : DATOS DEL EXPOSITOS --->
		<cfcase value="558">
			<cfoutput>
				<cfsavecontent variable="s">
					<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
					<!--- <cfif objEvento.id_evento is 1> --->
						("DATOS_EXPOSITOR_QUE_ME_INVITA") as "#n#"
					<!--- <cfelse>
						datosExpositorQueMeInvita(p.id_participante, p.id_evento) as "#n#"
					</cfif> --->
				</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- PASSWORD --->
		<cfcase value="2">
			<cfoutput>
			<cfsavecontent variable="s">
				p.password as "#n#"
			</cfsavecontent>
			</cfoutput>
		</cfcase>

	</cfswitch>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereAreaPrivada" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>

	<cfset var s = ''>
	<cfswitch expression="#id_campo#">


		<cfcase value="1">
				<!--- USUARIO --->
				<cfoutput>
				<cfsavecontent variable="s">
					login like "%#valor#%"
				</cfsavecontent>
				</cfoutput>
			</cfcase>

		<!--- ENCUESTAS REALIZADAS --->
		<cfcase value="245">
			<cfoutput>
			<cfsavecontent variable="s">
				<cfif replaceNoCase(valor, "'", "", "ALL") neq 0>
					<!--- HEMOS FILTRADO POR ALGUNA ENCUESTA --->

					<!--- <cfif objEvento.id_evento neq 191>
						<cfset var aIn = arrayNew(1)>
						<cfloop list="#valor#" index="id_valor">
							<cfset aIn.append("find_in_set(convert(#id_valor# using utf8), participantesListaIdsEncuestasRealizadas(p.id_participante))")>
						</cfloop>
						(
							#arrayToList(aIn, ' and ')#
						)
					<cfelse> --->
						<cfset var listaEncuestas = replace(arguments.valor, ',', '|', 'ALL')>
						<!--- FILTRAMOS POR LOS QUE TIENEN ALGUNA DE LAS ENCUESTAS BUSCADAS REALIZADAS --->
						<cfquery name="local.qParticipantesConEncuestas" datasource="#application.datasource#">
							select er.id_participante
							from vEncuestaRealizada er
							where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							<cfif listLen(listaEncuestas, '|') gt 1>
								and concat(',', er.id_encuesta, ',') REGEXP ",(#listaEncuestas#),"
							<cfelse>
								and er.id_encuesta = <cfqueryparam value="#listaEncuestas#" cfsqltype="cf_sql_integer">
							</cfif>
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConEncuestas)#
					<!--- </cfif> --->
				<cfelse>
					<!--- FILTRAMOS POR LOS QUE NO TIENEN ENCUESTAS RELLENAS --->
					<!--- participantesListaIdsEncuestasRealizadas(p.id_participante) is null --->
					<cfquery name="local.qParticipantesConEncuestas" datasource="#application.datasource#">
						select participante_id_participante as id_participante
						from encuestaRealizada
						where fecha_baja is null
						and evento_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConEncuestas)#
				</cfif>
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Log_App (SI/NO (Cantidad)) --->
		<cfcase value="266">
			<cfoutput>
			<cfsavecontent variable="s">
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select distinct(participantes_id_participante) as id_participante
					from participantesAccesos
					where eventos_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif valor is 1>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				<cfelse>
					#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
				</cfif>
			</cfsavecontent>
			</cfoutput>
		</cfcase>


			<cfcase value="267">
				<!---LOG_APP_ULTIMA_FECHA--->
				<cfoutput>
				<cfsavecontent variable="s">

	            	<cfquery name="local.qValorCampoTexto" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vParticipantes
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and date_format(last_login,'%d/%m/%Y') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">

					</cfquery>

						#generarListaParticipantesAFiltrar(local.qValorCampoTexto)#

	            </cfsavecontent>
	            </cfoutput>
			</cfcase>

	<!--- AREA DEL EXPOSITOR : DATOS DEL EXPOSITOS --->
			<cfcase value="558">
				<cfsavecontent variable="s">
					datosExpositorQueMeInvita(p.id_participante, p.id_evento) like '%#valor#%'
				</cfsavecontent>
			</cfcase>

			<cfcase value="2">
				<!--- PASSWORD --->
				<cfsavecontent variable="s">
					<cfinclude template="/admin/helpers/participantes/cs.cfm">
					password like "%#encriptar(valor)#%"
				</cfsavecontent>
			</cfcase>
	</cfswitch>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaComunicaciones" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfswitch expression="#id_campo#">

		<!--- IDS DE COMUNICACIONES --->
			<cfcase value="249">
				<cfoutput>
				<cfsavecontent variable="s">
					<!--- idsComunicaciones(p.id_participante) as '#n#' --->
					"IDS_COMUNICACIONES" as "#n#"
				</cfsavecontent>
				</cfoutput>
			</cfcase>

			<cfcase value="241">
				<!--- TIENE COMUNICACIONES--->
				<cfoutput>
				<cfsavecontent variable="s">
					<!--- case cuantasComunicaciones(p.id_participante) when 0 then
						'#objTraducciones.getString(1237)#'
					else
						concat('#objTraducciones.getString(1236)#', ' (', desgloseCuantasComunicaciones(p.id_participante), ')')
					end
					as "#n#" --->
					("TIENE_COMUNICACIONES") as "#n#"
				</cfsavecontent>
				</cfoutput>
			</cfcase>

	</cfswitch>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereComunicaciones" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>

	<cfset var s = ''>
	<cfswitch expression="#id_campo#">

		<!--- LISTA DE IDS COMUNICACIONES--->
			<cfcase value="249">
				<cfoutput>
				<cfsavecontent variable="s">
					<cfquery name="local.qListaIdsComunicaciones" datasource="#application.datasource#">
						select id_participante
						from vParticipantesComunicaciones
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and id_participante_comunicacion like <cfqueryparam value="%#valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qListaIdsComunicaciones)#
				</cfsavecontent>

				</cfoutput>

			</cfcase>

			<!--- NÚMERO DE COMUNICACIONES --->
			<cfcase value="241">
				<cfoutput>
				<cfsavecontent variable="s">
					<cfif valor is 0>
						cuantasComunicaciones(p.id_participante) = 0
					<cfelse>
						<!---cuantasComunicaciones(p.id_participante) > 0--->
						<cfquery name="local.qParticipantesConComunicacion" datasource="#application.datasource#">
							select id_participante
							from vParticipantesComunicaciones
							where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConComunicacion)#
					</cfif>
				</cfsavecontent>
				</cfoutput>
			</cfcase>

	</cfswitch>

	<cfreturn s>
</cffunction>


<cffunction name="generarUnaColumnaMensajeria" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfswitch expression="#id_campo#">
		<!--- Cantidad de mensajes recibidos --->
		<cfcase value="256">
			<cfoutput>
			<cfsavecontent variable="s">
				(
					<!--- select count(p2.id_participante) as total
					from vMensajeria m inner join vParticipantes p2
						on p2.id_participante = m.de
						and p2.id_evento = p2.id_evento
					where m.id_evento = p.id_evento
						and m.para = p.id_participante
						and isNull(m.fecha_baja_para) --->
					"MENSAJES_RECIBIDOS"
				)  as '#n#'
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Cantidad de mensajes no leidos --->
		<cfcase value="257">
			<cfoutput>
			<cfsavecontent variable="s">
				(
					<!--- select count(p2.id_participante) as total
					from vMensajeria m inner join vParticipantes p2
						on p2.id_participante = m.de
						and p2.id_evento = p2.id_evento
					where m.id_evento = p.id_evento
						and m.para = p.id_participante
						and isNull(m.fecha_baja_para)
						and leido = 0 --->
					"MENSAJES_NO_LEIDOS"
				)  as '#n#'
			</cfsavecontent>
			</cfoutput>
		</cfcase>

		<!--- Cantidad de mensajes enviados --->
		<cfcase value="258">
			<cfoutput>
			<cfsavecontent variable="s">
				(
					<!--- select count(p2.id_participante) as total
					from vMensajeria m inner join vParticipantes p2
						on p2.id_participante = m.para
						and p2.id_evento = p2.id_evento
					where m.id_evento = p.id_evento
						and m.de = p.id_participante
						and isNull(m.fecha_baja_para) --->
					"MENSAJES_ENVIADOS"
				)  as '#n#'
			</cfsavecontent>
			</cfoutput>
		</cfcase>
	</cfswitch>

	<cfreturn s>
</cffunction>
--->

<cffunction name="generarUnaColumna" access="public" returntype="string" output="false">
	<cfargument name="id_agrupacion" required="true"/>
	<cfargument name="id_campo" required="true"/>
	<cfargument name="id_tipo_campo_fijo" required="true"/>

	<cfset var s = ''>

	<cfquery name="local.agrupacionDeCampos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
		SELECT COUNT(*) FROM vAgrupacionesDeCampos 
		WHERE id_agrupacion = #arguments.id_agrupacion#
		AND id_idioma = '#session.language#'
	</cfquery>

	<cfif local.agrupacionDeCampos.recordCount GT 0>
		<cfquery name="local.agrupacionDeCampos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT *
			FROM vCampos
			WHERE id_agrupacion = #arguments.id_agrupacion#
			AND id_idioma = '#session.language#'
			AND id_campo = #arguments.id_campo#
			ORDER BY orden 
		</cfquery>
	</cfif>

	<cfif objEvento.existeAgrupacionDeCampos(arguments.id_agrupacion)>
		<cfset var objAgrupacion = objEvento.getAgrupacionDeCampos(arguments.id_agrupacion)>

		<cfif objAgrupacion.existeCampo(arguments.id_campo).esta>
			<cfset var objCampo = objAgrupacion.getCampo(arguments.id_campo)>
			<cfinclude template = "/default/admin/helpers/string.cfm">
			<cfset var n        = codificarNombreColumna(objCampo.nombre)>
			<cfoutput>
				
				<cfswitch expression="#objCampo.id_tipo_campo#">
					<cfcase value="16">
						<!---CAMPO RELACION ENTRE TIPOS DE PARTICIPANTES --->
						<cfsavecontent variable="s">
							(
								select concat(nombre_empresa, ' (', id_participante, ')')
								from vParticipantes
								where id_participante = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
							) as '#n#'
						</cfsavecontent>
					</cfcase>
					<cfcase value="1" delimiters=",">
						
						<!--- CAMPOS FIJOS --->
						<cfswitch expression="#arguments.id_tipo_campo_fijo#">
							<cfcase value="9">
								<!--- APELLIDOS DEL PARTICIPANTE --->
								<cfsavecontent variable="s">
									p.apellidos as "#n#"
								</cfsavecontent>
							</cfcase>

							<!--- EMAIL DEL PARTICIPANTE --->
							<cfcase value="6">
								<cfsavecontent variable="s">
									p.email_participante as "#n#"
								</cfsavecontent>
							</cfcase>

							<!--- NOMBRE DEL PARTICIPANTE --->
							<cfcase value="4">
								<cfsavecontent variable="s">
									p.nombre as "#n#"
								</cfsavecontent>
							</cfcase>

							<!--- NOMBRE DE LA EMPRESA --->
							<cfcase value="3">
								<cfsavecontent variable="s">
									p.nombre_empresa  as '#n#'
								</cfsavecontent>
							</cfcase>

							<!--- CUALQUIER OTRO CAMPO FIJO --->
							<cfdefaultcase>
								<cfsavecontent variable="s">
									(
										"CAMPO_#arguments.id_campo#"
									)
									 as "#n#"
								</cfsavecontent>
							</cfdefaultcase>
						</cfswitch>
					</cfcase>

					<!--- CAMPOS DE LISTA --->
					<cfcase value="2" delimiters=",">
						<!---<cfquery name="local.qValoresDeCampo" datasource="#application.datasource#">
							select id_valor, titulo, id_idioma
							from vValoresCamposLista
							where id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
								and titulo is not null
						</cfquery>--->

						<cfsavecontent variable="s">
							(
								<!---case concat(ifnull(datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento), p.id_idioma), p.id_idioma)
								<cfif local.qValoresDeCampo.recordCount gt 0>
									<cfloop query="local.qValoresDeCampo">
										when concat(#id_valor#, '#id_idioma#') then '#encodeString(titulo)#'
									</cfloop>
								<cfelse>
									when '' then ''
								</cfif>
								else '#objTraducciones.getString(4399)#'
								end--->
								"CAMPOLISTA_#arguments.id_campo#"
							) as "#n#"
						</cfsavecontent>
					</cfcase>

					<!--- CAMPOS DE LISTA MULTISELECCION--->
					<cfcase value="3" delimiters=",">
						<cfsavecontent variable="s">
							<cfif trim(n) is ''>
								ifnull((
									select
									    replace(group_concat(titulo SEPARATOR '|'), '|', '<BR>') as titulo
									from
									    vValores v
									        inner join
									    vValoresIdiomas vi ON v.id_valor = vi.id_valor
									        and v.id_campo = #arguments.id_campo#
									where
										vi.id_idioma = p.id_idioma
									    and FIND_IN_SET(v.id_valor,
									            (datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)))
								), '#objTraducciones.getString(4399)#') as "#n#"
							<cfelse>
								(
									"CAMPOMULTISELECCION_#arguments.id_campo#"
								) as "#n#"
							</cfif>
						</cfsavecontent>
					</cfcase>

					<!--- CAMPOS SI/NO --->
					<cfcase value="4">
						<cfsavecontent variable="s">
	                    	(
		                    	<cfif arguments.id_tipo_campo_fijo eq 41>
		                            case emailValido(p.email_participante)
		                                when 0 then '#objTraducciones.getString(1237)#'
		                                when 1 then '#objTraducciones.getString(1236)#'
		                                else '#objTraducciones.getString(1237)#'
		                            end
								<cfelseif arguments.id_tipo_campo_fijo eq 39>
		                        	case p.baja_newsletter
		                                when 0 then '#objTraducciones.getString(1237)#'
		                                when 1 then '#objTraducciones.getString(1236)#'
		                                else '#objTraducciones.getString(1237)#'
		                            end
		                        <cfelseif arguments.id_tipo_campo_fijo eq 42>
		                        	<!---"FORMA_DE_PAGO"--->
									<!--- case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
										when "TPV" then '#objTraducciones.getString(3231)#'
										when "1" then '#objTraducciones.getString(3231)#'
										when "TRANSFERENCIA" then '#objTraducciones.getString(3232)#'
										when "2" then '#objTraducciones.getString(3232)#'
										else '#objTraducciones.getString(1237)#'
									end --->
									"FORMA_DE_PAGO_SELECCIONADA_#arguments.id_campo#"
		                        <cfelse>
									<!---case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
										when 0 then '#objTraducciones.getString(1237)#'
										when 1 then '#objTraducciones.getString(1236)#'
										else '#objTraducciones.getString(4399)#'
									end--->
									"CAMPOSINO_#arguments.id_campo#"
		                        </cfif>
	                        ) as "#n#"
						</cfsavecontent>
					</cfcase>

					<cfcase value="9">
						<cfsavecontent variable="s">
							(
								"CAMPO_#arguments.id_campo#"
								<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)--->
							) as "#n#"
						</cfsavecontent>
					</cfcase>

					<!--- LISTA DE PROVINCIAS --->
					<cfcase value="12">
						<cfsavecontent variable="s">
							<cfset var objCampo = objAgrupacion.getCampo(arguments.id_campo)>
							(
								<!---case find_in_set(p.id_idioma, 'ES')--->
								<!---case DATOPARTICIPANTE2(p.id_participante, #arguments.id_campo#, p.id_evento) REGEXP '[0-9]+'
									when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
									else ifnull((select nombre from vPaisesNivel1 where id_nivel1 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
								end--->
								"PROVICIASELECCIONADA_#arguments.id_campo#"
							) AS "#n#"
						</cfsavecontent>
					</cfcase>

					<!--- LISTA DE POBLACIONES --->
					<cfcase value="13">
						<cfsavecontent variable="s">
							<cfset var objCampo = objAgrupacion.getCampo(arguments.id_campo)>
							(
								<!---case find_in_set(p.id_idioma, 'ES')--->
								<!---case DATOPARTICIPANTE2(p.id_participante, #arguments.id_campo#, p.id_evento) REGEXP '[0-9]+'
									when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
									else ifnull((select nombre from vPaisesNivel2 where id_nivel2 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
								end--->
								"POBLACIONSELECCIONADA_#arguments.id_campo#"
							) AS "#n#"
						</cfsavecontent>
					</cfcase>

					<cfcase value="14">
						<!--- LISTA DE PAISES --->
						<cfsavecontent variable="s">
							<cfset var objCampo = objAgrupacion.getCampo(arguments.id_campo)>
							(
								<!---case find_in_set(p.id_idioma, p.id_idioma)
									when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
									else
									ifnull((select texto_es from vPaises where id_pais = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
								end--->

								<!---<cfquery name="local.listaPaises" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,1,0,0)#">
									select texto_es as nombre, id_pais
									from vPaises
								</cfquery>

								case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
									<cfloop query="#local.listaPaises#">
										when #id_pais# then '#nombre#'
									</cfloop>
									else datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
								end--->
								"PAISSELECCIONADO_#arguments.id_campo#"
							) AS "#n#"
						</cfsavecontent>
					</cfcase>

					<cfdefaultcase>
						<cfsavecontent variable="s">
						(
							"CAMPO_#arguments.id_campo#"
							<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)--->
						) as "#n#"
					</cfsavecontent>
					</cfdefaultcase>
				</cfswitch>

			</cfoutput>
		<cfelse>
			<cfset s = "'' as ND_#arguments.id_campo#_#arguments.id_agrupacion#">
		</cfif>
	<cfelse>
		<cfset s = "'' as ND">
	</cfif>


	<cfreturn s>
</cffunction>

<!---
<cffunction name="generarUnaColumnaWhere" access="public" returntype="string" output="false">
	<cfargument name="id_agrupacion" required="true"/>
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="id_tipo_campo_fijo" required="true"/>

	<cfset var s = ''>
	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
	<cfset var objAgrupacion = objEvento.getAgrupacionDeCampos(arguments.id_agrupacion)>
	<cfset var objCampo = objAgrupacion.getCampo(arguments.id_campo)>

	<cfinclude template="/default/admin/helpers/string.cfm">

	<cfoutput>

		<cfswitch expression="#objCampo.id_tipo_campo#">
			<!---CAMPO RELACION ENTRE TIPOS DE PARTICIPANTES --->
			<cfcase value="16">
				<cfsavecontent variable="s">
					(
						select concat(nombre_empresa, '(', id_participante, ')')
						from vParticipantes
						where id_participante = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
					) like '%#valor#%'
				</cfsavecontent>
			</cfcase>
			<cfcase value="1" delimiters=",">
				<cfswitch expression="#arguments.id_tipo_campo_fijo#">
					<cfcase value="9">
						<cfsavecontent variable="s">
							apellidos like '%#encodeString(arguments.valor)#%'
						</cfsavecontent>
					</cfcase>

					<cfcase value="6">
						<cfsavecontent variable="s">
							email_participante like '%#encodeString(arguments.valor)#%'
						</cfsavecontent>
					</cfcase>

					<cfcase value="4">
						<cfsavecontent variable="s">
							nombre like '%#encodeString(arguments.valor)#%'
						</cfsavecontent>
					</cfcase>

					<cfcase value="3">
						<cfsavecontent variable="s">
							nombre_empresa like '%#encodeString(arguments.valor)#%'
						</cfsavecontent>
					</cfcase>

					<cfdefaultcase>
						<cfsavecontent variable="s">
							<cfquery name="local.qValorCampoTexto" datasource="#application.datasource#">
								select id_participante
								from vParticipantesDatos
								where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
									and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
									and valor like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
							</cfquery>
							#generarListaParticipantesAFiltrar(local.qValorCampoTexto)#
						</cfsavecontent>
					</cfdefaultcase>
				</cfswitch>

			</cfcase>
			<cfcase value="2,3" delimiters=",">
				<!--- CAMPOS DE LISTA --->
				<cfsavecontent variable="s">
				<cfset var arr = arrayNew(1)>

				<cfif isArray(arguments.valor)>
					<cfset arr = arguments.valor>
				<cfelse>
					<cfset arr[1] = valor>
				</cfif>
				<cfset var hayValorNulo = false>
				<cfif objCampo.id_tipo_campo is 2>
					<!--- COMBO. SOLO SE PUEDE TENER UN VALOR. --->
					(
						<cfset hayValorNulo = arr[1] is '' or arrayFind(arr, '-') gt 0>

						<cfset var pos = arrayFind(arr, '-')>
						<cfif pos gt 0>
							<cfset arrayDeleteAt(arr, pos)>
						</cfif>

						<cfset var pos = arrayFind(arr, '')>
						<cfif pos gt 0>
							<cfset arrayDeleteAt(arr, pos)>
						</cfif>

						<cfif arr.len() gt 0>
							<cfset arraySort(arr, 'text', 'asc')>
							<!--- DETECTAMOS SI BUSCAMOS POR UN VALOR NULO --->

							<cfif hayValorNulo>
								<!--- <cfset arrayDeleteAt(arr, 1)> --->
								<cfif arr.len() gt 0>
									<cfquery name="local.qValorCampoLista1" datasource="#application.datasource#">
										select id_participante
										from vParticipantesDatos
										where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
											and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
											and valor
											<cfif arr.len() is 1>
												= <cfqueryparam value="#arr[1]#" cfsqltype="cf_sql_integer" >
											<cfelse>
												in (<cfqueryparam value="#arrayToList(arr)#" list="true" cfsqltype="cf_sql_integer">)
											</cfif>
									</cfquery>
									#generarListaParticipantesAFiltrar(local.qValorCampoLista1)#
									or
									<cfquery name="local.qValorCampoLista2" datasource="#application.datasource#">
										select id_participante
										from vParticipantesDatos
										where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
											and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
											and (valor != '' and valor is not null)
									</cfquery>
									#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista2)#
									or
									<cfquery name="local.qValorCampoLista3" datasource="#application.datasource#">
										select id_participante
										from vParticipantesDatos
										where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
											and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
											and (valor = '' or valor is null)
									</cfquery>
									#generarListaParticipantesAFiltrar(local.qValorCampoLista3)#
								<cfelse>
									<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) is null--->
									<cfquery name="local.qValorCampoLista4" datasource="#application.datasource#">
										select id_participante
										from vParticipantesDatos
										where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
											and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
											and (valor != '' and valor is not null)
									</cfquery>
									#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista4)#
									or
									<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) = ''--->
									<cfquery name="local.qValorCampoLista5" datasource="#application.datasource#">
										select id_participante
										from vParticipantesDatos
										where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
											and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
											and (valor = '' or valor is null)
									</cfquery>
									#generarListaParticipantesAFiltrar(local.qValorCampoLista5)#
								</cfif>
							<cfelse>
								<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) in (#arrayToLIst(arr)#)--->
								<cfquery name="local.qValorCampoLista6" datasource="#application.datasource#">
									select id_participante
									from vParticipantesDatos
									where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
										and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
										and valor
										<cfif arr.len() is 1>
											= <cfqueryparam value="#arr[1]#" cfsqltype="cf_sql_integer" >
										<cfelse>
											in (<cfqueryparam value="#arrayToList(arr)#" list="true" cfsqltype="cf_sql_integer">)
										</cfif>
								</cfquery>
								#generarListaParticipantesAFiltrar(local.qValorCampoLista6)#
							</cfif>
						<cfelse>
							<!---true = true--->
							<!---(datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) is null or datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) = '')--->

							<!--- QUEREMOS LOS VACÍOS. SACAMOS LOS QUE LO TIENEN RELLENO --->
							<cfquery name="local.qValorCampoLista7" datasource="#application.datasource#">
								select id_participante
								from vParticipantesDatos
								where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
									and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
									and (valor != '' and valor is not null)
							</cfquery>
							#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista7)#
						</cfif>
					)
				<cfelse>
					<!--- MULTISELECCION --->
					(
					<cfset var pos = arrayFind(arr, '-')>
					<cfif pos gt 0>
						<cfset arrayDeleteAt(arr, pos)>
					</cfif>

					<cfif arr.len() gt 0>
						<cfset var aInsert = arrayNew(1)>
						<cfset arraySort(arr, 'text', 'asc')>
						<cfset hayValorNulo = arr[1] is ''>
						<cfif hayValorNulo>
							<cfset arrayDeleteAt(arr, 1)>
							<cfif arr.len() gt 0>
								'#arrayToList(arr)#' =
								<cfloop from="1" to="#arrayLen(arr)#" index="aIndex">
									<cfset aInsert.append("split_str(SPLIT_SORT(datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento), ','), ',', #aIndex#), ','")>
								</cfloop>
								replace(concat(#arrayToList(aInsert)#, ',' COLLATE utf8_spanish_ci), ',,', '')
								or
									datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) is null
								or
									datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) = ''
							<cfelse>
									datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) is null
								or
									datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) = ''
							</cfif>
						<cfelse>
							'#arrayToList(arr)#' =
								<cfloop from="1" to="#arrayLen(arr)#" index="aIndex">
									<cfset aInsert.append("split_str(SPLIT_SORT(datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento), ','), ',', #aIndex#), ','")>
								</cfloop>
								replace(concat(#arrayToList(aInsert)#, ',' COLLATE utf8_spanish_ci), ',,', '')
						</cfif>
					<cfelse>
						true = true
					</cfif>
					)
				</cfif>
			</cfsavecontent>
			</cfcase>

			<cfcase value="4">
				<cfsavecontent variable="s">
		            <cfif arguments.id_tipo_campo_fijo eq 41>
		            	emailValido(p.email_participante) like '%#valor#%'
					<cfelseif arguments.id_tipo_campo_fijo eq 39>
					(
						p.baja_newsletter = #valor#
					)
					<cfelseif arguments.id_tipo_campo_fijo eq 42>
						(
							exists
							(
		                        select valor
		                        from vParticipantesDatos
		                        where id_evento = #objEvento.id_evento#
		                        	and id_participante = p.id_participante
		                            and id_campo = #arguments.id_campo#
		                            and valor = '#arguments.valor#'
		                    )
						)
		            <cfelse>
	                    (
		                    <cfif (valor is 1) or (valor is 0)>
								<cfquery name="local.qValorCampoSINO_1" datasource="#application.datasource#">
									select id_participante
									from vParticipantesDatos
									where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
										and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
										and valor = <cfqueryparam value="#valor#" cfsqltype="cf_sql_bit">
										and trim(valor) != ''
								</cfquery>
								#generarListaParticipantesAFiltrar(local.qValorCampoSINO_1)#
							<cfelse>
								<cfquery name="local.qValorCampoSINO_2" datasource="#application.datasource#">
									select id_participante, valor
									from vParticipantesDatos
									where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
										and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
										and valor in (1,0)
										and trim(valor) != ''
								</cfquery>
								#generarListaParticipantesAFiltrarNegativo(local.qValorCampoSINO_2)#
		                    </cfif>
						)
	            	</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="12">
				<cfsavecontent variable="s">
				(case find_in_set(p.id_idioma, 'ES')
					when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
					else ifnull((select nombre from vPaisesNivel1 where id_nivel1 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
				end) like '%#arguments.valor#%'
			</cfsavecontent>
			</cfcase>

			<cfcase value="13">
				<cfsavecontent variable="s">
				(case find_in_set(p.id_idioma, 'ES')
					when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
					else ifnull((select nombre from vPaisesNivel2 where id_nivel2 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
				end) like '%#arguments.valor#%'
			</cfsavecontent>
			</cfcase>

			<cfcase value="14">
				<!--- LISTA DE PAISES --->
				<cfsavecontent variable="s">
				(
					case find_in_set(p.id_idioma, p.id_idioma)
						when 0 then datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
						else ifnull((select texto_es from vPaises where id_pais = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
					end
				) like '%#arguments.valor#%'
			</cfsavecontent>
			</cfcase>

			<cfdefaultcase>
				<cfsavecontent variable="s">
					<!---exists (
						select id_campo
						from vParticipantesDatos
						where id_participante = p.id_participante
							and id_campo = #arguments.id_campo#
							and valor like '%#arguments.valor#%'
					)--->
					<cfquery name="local.qValorCampoTexto" datasource="#application.datasource#">
						select id_participante
						from vParticipantesDatos
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
							and valor like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qValorCampoTexto)#
				</cfsavecontent>
			</cfdefaultcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaDiasAsistenciaWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_dia" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
		<cfif arguments.valor is 1>exists<cfelse>not exists</cfif>
		(
			select ph.id_hora
			from vParticipantesHoras ph inner join vHoras h
				on ph.id_hora = h.id_hora
			    and h.dias_id_dia = #arguments.id_dia#
			where ph.id_participante = p.id_participante
				and ph.activo = 1
		)
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
			<!---<cfif arguments.valor is 1>exists<cfelse>not exists</cfif>
			(
				select prioridad
				from vActividadesSeleccionadas
				where id_participante = p.id_participante
					and id_actividad = #arguments.id_actividad#
			)--->
			<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
				select id_participante
				from vActividadesSeleccionadas
				where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif valor is 1>
				#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
			<cfelse>
				#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
			</cfif>
		</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadSeleccionadaConPrecioWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
			<!---<cfif arguments.valor is 1>exists<cfelse>not exists</cfif>
			(
				select prioridad
				from vActividadesSeleccionadas
				where id_participante = p.id_participante
					and id_actividad = #arguments.id_actividad#
			)--->

			<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
				select id_participante
				from vActividadesSeleccionadas
				where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif valor is 1>
				#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
			<cfelse>
				#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
			</cfif>

		</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaOpcionAdicionalWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_opcion" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
		<cfif arguments.valor is 1>exists<cfelse>not exists</cfif>
		(
			select id_opcion_adicional
			from vOpcionesAdicionalesSeleccionadas
			where id_participante = p.id_participante
				and id_opcion_adicional = #arguments.id_opcion#
		)
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadGeneradaWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
			<!---(
				estaActividadAgendada(p.id_evento, p.id_participante, #arguments.id_actividad#) = #arguments.valor#
			)--->

			<cfquery name="local.qActividadesAgendadas" datasource="#application.datasource#">
				select id_participante
				from vActividadesGeneradas
				where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif valor is 1>
				#generarListaParticipantesAFiltrar(local.qActividadesAgendadas)#
			<cfelse>
				#generarListaParticipantesAFiltrarNegativo(local.qActividadesAgendadas)#
			</cfif>

		</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaProductoWhere" access="public" returntype="string" output="false">
	<cfargument name="id_producto" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="queColumna" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
			<!--- exists
			(
				select #arguments.queColumna#
				from vProductosSeleccionados
				where id_participante = p.id_participante
					and id_producto = #arguments.id_producto#
					and #arguments.queColumna# = #arguments.valor#
			) --->

			<!--- cogemos los que tienen este producto a 1 en "queColumna" --->
			<cfquery name="local.qProductosComprarVenderColaborar" datasource="#application.datasource#">
				select id_participante
				from vProductosSeleccionados
				where id_producto = <cfqueryparam value="#arguments.id_producto#" cfsqltype="cf_sql_integer">
					and #arguments.queColumna# = 1
			</cfquery>

			<cfif arguments.valor is 1>
				#generarListaParticipantesAFiltrar(local.qProductosComprarVenderColaborar)#
			<cfelse>
				<cfif local.qProductosComprarVenderColaborar.recordCount gt 0>
					<!--- HAY ALGÚN PARTICIPANTE QUE HA SELECCIONADO --->
					#generarListaParticipantesAFiltrarNegativo(local.qProductosComprarVenderColaborar)#
				<cfelse>
					<!--- NINGUN PARTICIPANTE HA SELECCIONADO. filtramos por los que no han seleccionado --->
					<cfquery name="local.qProductosComprarVenderColaborar" datasource="#application.datasource#">
						select id_participante
						from vProductosSeleccionados
						where id_producto = <cfqueryparam value="#arguments.id_producto#" cfsqltype="cf_sql_integer">
							and #arguments.queColumna# IN (0)
					</cfquery>
					#generarListaParticipantesAFiltrarNegativo(local.qProductosComprarVenderColaborar)#
				</cfif>
			</cfif>
		</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaCampoOtros" access="public" rturntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombeCampo" required="true"/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombeCampo)>
	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
			<cfcase value="169">
				<cfsavecontent variable="s">
					("FECHA_ULTIMO_PAGO_POR_TRANSFERENCIA") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
			<cfcase value="170">
				<cfsavecontent variable="s">
					("CANTIDAD_ULTIMO_PAGO_POR_TRANSFERENCIA") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- TEMÁTICAS DE LAS COMUNICACIONES --->
			<cfcase value="268">
				<cfsavecontent variable="s">
					("TEMATICAS_COMUNICACIONES") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- DOBLE OPT-IN --->
			<cfcase value="255">
				<cfsavecontent variable="s">
					case p.doble_opt_in
					when 0 then '#objtraducciones.getString(4636)#'
					when 1 then '#objtraducciones.getString(4635)#'
					else '#objtraducciones.getString(4634)#'
					end
				</cfsavecontent> as "#n#"
			</cfcase>

			<!--- RESULTADOS DE PAGOS EN PAYPAL --->
			<cfcase value="254">
				<cfsavecontent variable="s">
					(
						SELECT distinct(GROUP_CONCAT(valor SEPARATOR '<br>'))
						FROM
						    resultadosDePagos rp
						        INNER JOIN
						    resultadosDePagosPasarelasDatos rppd ON rp.id_resultado = rppd.id_resultado
						WHERE
						    rp.id_evento = #this.objEvento.id_evento#
						    and rppd.id_evento = #this.objEvento.id_evento#
						        AND rp.id_participante = p.id_participante
						        AND metodointro = 'auto'
						        AND rp.resultado IN ('ok')
						        AND campo IN ('payer_id' , 'payment_status')
						        and valor != 'completed'
						GROUP BY rp.id_participante
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- RESULTADOS DE PAGOS EN REDSYS --->
			<cfcase value="160">
				<cfsavecontent variable="s">
					(
						<!---select distinct(GROUP_CONCAT(valor SEPARATOR '<br>'))
						from
						    resultadosDePagos rp
						        INNER JOIN
						    resultadosDePagosPasarelasDatos rppd ON rp.id_resultado = rppd.id_resultado
						where
						    rp.id_evento = #this.objEvento.id_evento#
						    and rppd.id_evento = #this.objEvento.id_evento#
						        and rp.id_participante = p.id_participante
						        and metodointro = 'auto'
						        and rp.resultado in ('ok')
						        and campo = 'Ds_AuthorisationCode'
						group by rp.id_participante--->
						"RESULTADOS_DE_PAGO_REDSYS"
					) as "#n#"
				</cfsavecontent>
			</cfcase>


			<!--- CONCEPTOS PAGADOS --->
			<cfcase value="238">
				<cfsavecontent variable="s">
					("CONCEPTOS_PAGADOS")
					as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- CONCEPTOS NO PAGADOS --->
			<cfcase value="239">
				<cfsavecontent variable="s">
					("CONCEPTOS_NO_PAGADOS") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- MEDIOS DE PAGO UTILIZADOS --->
			<cfcase value="240">
				<cfsavecontent variable="s">
					<!--- (
						select group_concat(distinct(concat(descripcion, '<BR>')) SEPARATOR '')
						from vTiposDePago tdp inner join resultadosDePagos rp2
							on tdp.id_tipo_pago = rp2.id_tipo_pago
						where tdp.id_idioma = '#session.id_idioma#'
						and rp2.id_participante = p.id_participante
						and rp2.resultado = 'ok'
						and rp2.id_evento = p.id_evento
					) as "#n#" --->
					("MEDIO_DE_PAGO_UTILIZADO") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- PERMISOS PARA VER ESTE PARTICIPANTE --->
			<cfcase value="133">
				<cfsavecontent variable="s">
					replace(listaNombresPermisosParticipante(p.id_participante, #this.objevento.id_evento#), CONVERT(',' USING utf8), '<br>') as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- USUARIO QUE LO CREO --->
			<cfcase value="134">
				<cfsavecontent variable="s">
					nombreUsuario(p.id_usuario_alta, #this.objevento.id_evento#) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- USUARIO QUE LO MODIFICO --->
			<cfcase value="135">
				<cfsavecontent variable="s">
					nombreUsuario(p.id_usuario_modif, #this.objevento.id_evento#) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- CODIGO DE participante --->
			<cfcase value="236">
				<cfsavecontent variable="s">
					<!--- codigoParticipante(p.id_tipo_participante) as "#n#" --->
					"CODIGO_PARTICIPANTE_1" as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- OBSERVACIONES --->
			<cfcase value="559">
				<cfsavecontent variable="s">
					(
						SELECT
						    GROUP_CONCAT(CONCAT(texto)
						        SEPARATOR '<br>')
						FROM
						    vCRMObservaciones
						WHERE
						    id_participante = p.id_participante
						GROUP BY id_participante
						ORDER BY fecha_alta
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- CÓDIGOS DE LAS ACTIVIDADES SELECCIONADAS --->
			<cfcase value="560">
				<cfsavecontent variable="s">
					"CODIGOS_ACTIVIDADES_SELECCIONADAS_#arguments.id_campo#" as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- CODIGO DE participante 2--->
			<cfcase value="237">
				<cfsavecontent variable="s">
					codigoParticipante2(p.id_tipo_participante) as "#n#"
				</cfsavecontent>
			</cfcase>



			<cfcase value="248">
				<!--- IDIOMA DE INSCRIPCION--->
				<cfquery name="local.qIdiomas" datasource="#application.datasource#">
					select
						wia.id_idioma,
						wia.nombre as titulo
					from vWebsIdiomasActivos wia inner join webs w on w.id_web = wia.id_web
						and w.eventos_id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and w.tiposWebs_id_tipo_web = 1
					order by wia.nombre
				</cfquery>

				<cfsavecontent variable="s">
					case p.id_idioma
					<cfloop query="local.qIdiomas">
						when '#id_idioma#' then '#(titulo)#'
					</cfloop>
					end as "#n#"
				</cfsavecontent>
			</cfcase>


			<!--- DUPLICADOS --->
			<cfcase value="244">
				<cfsavecontent variable="s">
					case ifnull(cantidadDuplicados, 0) when 0 then
						'#objTraducciones.getString(1237)#'
					else
						concat('#objTraducciones.getString(1236)#', ' (', cantidadDuplicados, ')')
					end
					as "#n#"
				</cfsavecontent>
			</cfcase>



			<!--- INSCRITO --->
			<cfcase value="3">
				<cfset var objTraducciones = createObject('component', 'default.admin.model.traduccionesV2')>
				<cfsavecontent variable="s">
					case p.inscrito when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- PAGADO --->
			<cfcase value="4">
				<cfsavecontent variable="s">
					<!---case pagadoParticipante(p.id_participante) when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END--->
					("PAGO_COMPLETADO")
					as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- TOTAL_A_PAGAR --->
			<cfcase value="6">
				<cfsavecontent variable="s">
					round(p.total_a_pagar, 2) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- TIPO DE PARTICIPANTE --->
			<cfcase value="7">
				<cfsavecontent variable="s">
					(
						<!---nombreTipoParticipante(p.id_tipo_participante, p.id_evento)--->
						<cfset var listaTipos = this.objEvento.getQueryListaTiposDeParticipante()>
						<cfif listaTipos.recordCount gt 0>
							case p.id_tipo_participante
							<cfloop query="#listaTipos#">
								when #id_tipo_participante# then '#nombre#'
							</cfloop>
							end
						<cfelse>
							''
						</cfif>
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- fecha_alta --->
			<cfcase value="8">
				<cfsavecontent variable="s">
					<cfquery name="local.qGetZonaHorariaEvento" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
						select zonaHorariaEvento(#this.objEvento.id_evento#) as zonaHoraria
					</cfquery>
					<cfif local.qGetZonaHorariaEvento.zonaHoraria is 'Europe/Madrid'>
						p.fecha_alta
					<cfelse>
						date_format(CONVERT_TZ(str_to_date(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid', '#local.qGetZonaHorariaEvento.zonaHoraria#'), '%d/%m/%Y %T')
					</cfif>
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- ID_PARTICIPANTE --->
			<cfcase value="9">
				<cfsavecontent variable="s">
					p.id_participante as "#n#"
				</cfsavecontent>
			</cfcase>


			<!--- IVA_A_PAGAR  --->
			<cfcase value="109">
				<cfsavecontent variable="s">
					("CALCULAR_TOTAL_IVA_A_PAGAR") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- TOTAL_SIN_IVA  --->
			<cfcase value="110">
				<cfsavecontent variable="s">
					("CALCULAR_TOTAL_A_PAGAR_BI") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- IMPORTE_PAGADO  --->
			<cfcase value="111">
				<cfsavecontent variable="s">
					("IMPORTE_PAGADO") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- PENDIENTE_PAGO  --->
			<cfcase value="112">
				<cfsavecontent variable="s">
					("PENDIENTE_DE_PAGO") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!---NUMERO_FACTURA--->
			<cfcase value="118">
				<cfsavecontent variable="s">
	            	("NUMERO_FACTURA") as "#n#"
	            </cfsavecontent>
			</cfcase>

			<!--- FACTURA EMITIDA--->
			<cfcase value="157">
				<cfsavecontent variable="s">
	            	("FACTURA_EMITIDA") as "#n#"
	            </cfsavecontent>
			</cfcase>

			<!--- SE HA ENVIADO LA FACTURA POR EMAIL --->
			<cfcase value="158">
				<cfsavecontent variable="s">
					("FACTURA_ENVIADA_POR_EMAIL") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!---FECHA_FACTURA--->
			<cfcase value="119">
				<cfsavecontent variable="s">
	            	("FECHA_FACTURA") as "#n#"
	            </cfsavecontent>
			</cfcase>

			<!---TIPO_FACTURA--->
			<cfcase value="120">
				<cfsavecontent variable="s">
	            	(select tipo_plantilla from vFacturas vf where vf.id_participante = p.id_participante) as "#n#"
	            </cfsavecontent>
			</cfcase>

			<!--- fecha_modif --->
			<cfcase value="131">
				<cfsavecontent variable="s">
					<!--- date_format(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T')  --->
					<cfquery name="local.qGetZonaHorariaEvento" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
						select zonaHorariaEvento(#this.objEvento.id_evento#) as zonaHoraria
					</cfquery>
					<cfif local.qGetZonaHorariaEvento.zonaHoraria is 'Europe/Madrid'>
						p.fecha_modif
					<cfelse>
						date_format(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid', '#local.qGetZonaHorariaEvento.zonaHoraria#'), '%d/%m/%Y %T')
					</cfif>
					as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- numero de pagos por TPV --->
			<cfcase value="235">
				<cfsavecontent variable="s">
					<!--- numeroPagosTPVParticipante(p.id_participante)  --->
					("NUMERO_PAGOS_POR_TPV_PARTICIPANTE") as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaCampoOtrosWhere" access="public" rturntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="objEvento" required="false"/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<!--- CANTIDAD DEL ULTIMO PAGO POR TRANSFERENCIA --->
			<cfcase value="170">
				<cfsavecontent variable="s">
					<cfif trim(arguments.valor) is '=0'>
						<!--- LOS QUE TENGAN ALGÚN PAGO POR TRANSFERENCIA --->
						<cfquery name="local.qParticipantesConPagosConTransferencia" datasource="#application.datasource#">
							select id_participante
							from resultadosDePagos
							where id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and id_tipo_pago = 2
								and resultado = 'ok'
								and cantidad > 0
						</cfquery>

						<cfif local.qParticipantesConPagosConTransferencia.recordCount gt 0>
							<!--- HAY ALGUIN CON PAGOS POR TRANSFERENCIA --->
							#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConPagosConTransferencia)#
						<cfelse>
							(true)
						</cfif>
					<cfelse>
						<!--- COGEMOS LOS QUE TIENEN POR ULTIMA FECHA DE PAGO POR TANSFERENCIA LA FECHA QUE NOS PASAN --->
						<cfquery name="local.qParticipantesConPagosConTransferencia" datasource="#application.datasource#">
							select *
							from
							(
								select id_participante, date_format(max(fecha_alta), '%d/%m/%Y %T') as fecha, cantidad/100 as cantidad
								from resultadosDePagos
								where id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
									and id_tipo_pago = 2
									and resultado = 'ok'
									and cantidad > 0
								group by id_participante
								order by null
							) a
							where cantidad like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConPagosConTransferencia)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
			<cfcase value="169">
				<cfsavecontent variable="s">
					<cfif trim(arguments.valor) is '=0'>
						<!--- LOS QUE TENGAN ALGÚN PAGO POR TRANSFERENCIA --->
						<cfquery name="local.qParticipantesConPagosConTransferencia" datasource="#application.datasource#">
							select id_participante
							from resultadosDePagos
							where id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and id_tipo_pago = 2
								and resultado = 'ok'
								and cantidad > 0
						</cfquery>

						<cfif local.qParticipantesConPagosConTransferencia.recordCount gt 0>
							<!--- HAY ALGUIN CON PAGOS POR TRANSFERENCIA --->
							#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConPagosConTransferencia)#
						<cfelse>
							(true)
						</cfif>
					<cfelse>
						<!--- COGEMOS LOS QUE TIENEN POR ULTIMA FECHA DE PAGO POR TANSFERENCIA LA FECHA QUE NOS PASAN --->
						<cfquery name="local.qParticipantesConPagosConTransferencia" datasource="#application.datasource#">
							select *
							from
							(
								select id_participante, date_format(max(CONVERT_TZ(fecha_alta, 'Europe/Madrid', zonaHorariaEvento(#arguments.objEvento.id_evento#))), '%d/%m/%Y %T') as fecha
								from resultadosDePagos
								where id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
									and id_tipo_pago = 2
									and resultado = 'ok'
									and cantidad > 0
								group by id_participante
								order by null
							) a
							where fecha like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConPagosConTransferencia)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- COGEMOS LOS PARTICIPANTES QUE TIENEN ESTA TEMÁTICA --->
			<cfcase value="268">
				<cfif arguments.valor neq ''>
					<cfquery name="local.qTematicas" datasource="#application.datasource#">
						select distinct(pc.id_participante) as id_participante
						from vParticipantesComunicaciones pc inner join comunicacionesTematicasIdiomas cti on
							pc.id_tematica = cti.comunicacionesTematicas_id_tematica
						and pc.id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						and cti.nombre like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfsavecontent variable="s">
						#generarListaParticipantesAFiltrar(local.qTematicas)#
					</cfsavecontent>
				</cfif>
			</cfcase>

			<!--- DOBLE OPT-IN --->
			<cfcase value="255">
				<cfsavecontent variable="s">
					(
						ifnull(p.doble_opt_in, 2) = #valor#
					)
				</cfsavecontent>
			</cfcase>

			<!--- RESULTADOS DE PAGOS DE PAYPAL --->
			<cfcase value="254">
				<cfsavecontent variable="s">
					<cfquery name="local.qGetResultados" datasource="#application.datasource#">
						SELECT rp.id_participante
						FROM
						    resultadosDePagos rp
						        INNER JOIN
						    resultadosDePagosPasarelasDatos rppd ON rp.id_resultado = rppd.id_resultado
						WHERE
						    rp.id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						        AND metodointro = 'auto'
						        AND rp.resultado IN ('ok')
						        AND campo IN ('payer_id')
						        and valor like <cfqueryparam value="%#valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qGetResultados)#
				</cfsavecontent>
			</cfcase>

			<cfcase value="238">
				<!--- CONCEPTOS PAGADOS --->
				<cfsavecontent variable="s">
					<!---<cfset var aIn = arrayNew(1)>

					<cfloop list="#valor#" index="id_valor">
						<cfset aIn.append("find_in_set(convert(#id_valor# using utf8), (listaIdsConceptos2(p.id_participante, 1, '#session.id_idioma#', #this.objEvento.id_evento#)))")>
					</cfloop>
					(
						#arrayToList(aIn, ' and ')#
					)--->
					<cfset var aIn = []>
					<cfloop list="#valor#" index="id_valor">
						<cfset id_valor = replace(id_valor, "'", "", "ALL")>
						<cfif listFirst(id_valor, '_') is 1>
							<!--- ACTIVIDADES --->
							<cfset var id_actividad = listLast(id_valor, '_')>
							<cfquery name="local.actividadesPagadas" datasource="#application.datasource#">
								select id_participante
								from vActividadesSeleccionadas
								where id_actividad = <cfqueryparam value="#id_actividad#" cfsqltype="cf_sql_integer">
									and pagada = 1
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.actividadesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 2>
							<!--- MODALIDADES --->
							<cfset var id_modalidad = listLast(id_valor, '_')>
							<cfquery name="local.modalidadesPagadas" datasource="#application.datasource#">
								select id_participante
								from vModalidadesSeleccionadas
								where id_modalidad = <cfqueryparam value="#id_modalidad#" cfsqltype="cf_sql_integer">
									and pagada = 1
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.ModalidadesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 3>
							<!--- OPCIONES ADICIONALES --->
							<cfset var id_opcion_adicional = listLast(id_valor, '_')>
							<cfquery name="local.opcionesAdicionalesPagadas" datasource="#application.datasource#">
								select id_participante
								from vOpcionesAdicionalesSeleccionadas
								where id_opcion_adicional = <cfqueryparam value="#id_opcion_adicional#" cfsqltype="cf_sql_integer">
									and pagada = 1
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.opcionesAdicionalesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 4>
							<!--- NETWORKING --->
							<cfquery name="local.qnetworkingPagado" datasource="#application.datasource#">
								select id_participante
								from vParticipantesPreciosProductos
								where pagada = 1
									and id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.qnetworkingPagado))>
						</cfif>
					</cfloop>
					#arrayToList(aIn, ' and ')#
				</cfsavecontent>
			</cfcase>

			<!--- CONCEPTOS NO PAGADOS --->
			<cfcase value="239">
				<cfsavecontent variable="s">
					<!---<cfset var aIn = arrayNew(1)>

					<cfloop list="#valor#" index="id_valor">
						<cfset aIn.append("find_in_set(convert(#id_valor# using utf8), (listaIdsConceptos2(p.id_participante, 0, '#session.id_idioma#', #this.objEvento.id_evento#)))")>
					</cfloop>
					(
						#arrayToList(aIn, ' and ')#
					)--->

					<cfset var aIn = []>
					<cfloop list="#valor#" index="id_valor">
						<cfset id_valor = replace(id_valor, "'", "", "ALL")>
						<cfif listFirst(id_valor, '_') is 1>
							<!--- ACTIVIDADES --->
							<cfset var id_actividad = listLast(id_valor, '_')>
							<cfquery name="local.actividadesPagadas" datasource="#application.datasource#">
								select id_participante
								from vActividadesSeleccionadas
								where id_actividad = <cfqueryparam value="#id_actividad#" cfsqltype="cf_sql_integer">
									and pagada = 0
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.actividadesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 2>
							<!--- MODALIDADES --->
							<cfset var id_modalidad = listLast(id_valor, '_')>
							<cfquery name="local.modalidadesPagadas" datasource="#application.datasource#">
								select id_participante
								from vModalidadesSeleccionadas
								where id_modalidad = <cfqueryparam value="#id_modalidad#" cfsqltype="cf_sql_integer">
									and pagada = 0
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.ModalidadesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 3>
							<!--- OPCIONES ADICIONALES --->
							<cfset var id_opcion_adicional = listLast(id_valor, '_')>
							<cfquery name="local.opcionesAdicionalesPagadas" datasource="#application.datasource#">
								select id_participante
								from vOpcionesAdicionalesSeleccionadas
								where id_opcion_adicional = <cfqueryparam value="#id_opcion_adicional#" cfsqltype="cf_sql_integer">
									and pagada = 0
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.opcionesAdicionalesPagadas))>
						<cfelseif listFirst(id_valor, '_') is 4>
							<!--- NETWORKING --->
							<cfquery name="local.qnetworkingPagado" datasource="#application.datasource#">
								select id_participante
								from vParticipantesPreciosProductos
								where pagada = 0
									and id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							</cfquery>
							<cfset aIn.append(generarListaParticipantesAFiltrar(local.qnetworkingPagado))>
						</cfif>
					</cfloop>
					#arrayToList(aIn, ' and ')#
				</cfsavecontent>
			</cfcase>

			<!--- MEDIOS DE PAGO UTILIZADOS --->
			<cfcase value="240">
				<cfsavecontent variable="s">
					<!--- <cfset var aIn = arrayNew(1)> --->
					<!--- BUSCAMOS LOS QUE HAN TENIDO ESTOS MEDIOS DE PAGO --->

					<cfset valor = replace(valor, "'", '', 'ALL')>
					<cfquery name="local.qMediosDePago" datasource="#application.datasource#">
						select distinct id_participante
						from resultadosDePagos rp2
						where resultado = 'ok'
							and rp2.id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and id_tipo_pago in (<cfqueryparam value="#valor#" list="true" cfsqltype="cf_sql_integer">)
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qMediosDePago)#
				</cfsavecontent>
			</cfcase>

			<cfcase value="133">
				<!--- PERMISOS PARA VER ESTE PARTICIPANTE --->
				<cfsavecontent variable="s">
				(
					<cfset var a = arrayNew(1)>
					<cfloop list="#valor#" index="id_usuario">
						<cfset a.append('pu.id_usuario = #id_usuario#')>
					</cfloop>
					#arrayToLIst(a, ' OR ')#
				)
			</cfsavecontent>
			</cfcase>

			<!--- USUARIO QUE LO CREO --->
			<cfcase value="134">
				<cfsavecontent variable="s">
					p.id_usuario_alta in (#valor#)
				</cfsavecontent>
			</cfcase>

			<!--- USUARIO QUE LO MODIFICO --->
			<cfcase value="135">
				<cfsavecontent variable="s">
					p.id_usuario_modif in (#valor#)
				</cfsavecontent>
			</cfcase>

			<cfcase value="236">
				<!--- CODIGO DE participante --->
				<cfsavecontent variable="s">
					codigoParticipante(p.id_tipo_participante) like "%#valor#%"
				</cfsavecontent>
			</cfcase>

			<!--- OBSERVACIONES --->
			<cfcase value="559">
				<!--- COGEMOS LOS PARTICIPANTES QUE TIENEN ALGUNA OBSERVACION CON ESE TEXTO --->
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select distinct(id_participante) as id_participante
					from vCRMObservaciones
					where texto like <cfqueryparam value="%#valor#%" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfsavecontent variable="s">
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- CÓDIGOS DE LAS ACTIVIDADES SELECCIONADAS POR LOS PARTICIPANTES --->
			<cfcase value="560" >
				<!--- COGEMOS LOS PARTICIPANTE QUE TIENEN ALGUNA ACTIVIDAD SELECCIONADAS CON ESE CÓDIGO --->
				<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
					select
					    a1.id_participante as id_participante
					from
					    vActividadesSeleccionadas a1
					        inner join
					    vActividades a2 ON a1.id_actividad = a2.id_actividad
					        and a2.id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_char">
					        and id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
		        			and a2.codigo like <cfqueryparam value="%#valor#%" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfsavecontent variable="s">
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- CODIGO DE participante 2 --->
			<cfcase value="237">
				<cfsavecontent variable="s">
					codigoParticipante2(p.id_tipo_participante) like "%#valor#%"
				</cfsavecontent>
			</cfcase>

			<!--- IDIOMA DE INSCRIPCION --->
			<cfcase value="248">
				<cfsavecontent variable="s">
					<cfif trim(arguments.valor) neq ''>
						p.id_idioma in (#arguments.valor#)
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- DUPLICADO --->
			<cfcase value="244">
				<cfsavecontent variable="s">
					<cfif valor is 0>
						cantidadDuplicados is null
					<cfelse>
						cantidadDuplicados > 0
					</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="3">
				<!--- INSCRITO --->
				<cfsavecontent variable="s">
					p.inscrito = '#valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="4">
				<!--- PAGADO --->
				<cfoutput>
					<cfsavecontent variable="s">
						<!--- COGEMOS LOS QUE HAN RECIBIDO ALGÚN MENSAJE --->
						<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
						<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
							select id_participante, pagado
							from
							(
								select
							        ((if(isnull(sum(r.cantidad)),
							            0,
							            round(sum(r.cantidad)) / 100)) >= if(isnull(p.total_a_pagar),
							            '0',
							            p.total_a_pagar)) as pagado,
							             p.id_participante
							    from
							        (vParticipantes p
							        left join resultadosDePagos r ON (((p.id_participante = r.id_participante) and (r.resultado = 'ok') and (r.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">)    )))
							    where p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							    <!---and r.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">--->
							    group by p.id_participante
							) a
							where pagado = 1
						</cfquery>

						<cfif valor is 1>
							#generarListaParticipantesAFiltrar(local.qListaParticipantes)#
						<cfelse>
							#generarListaParticipantesAFiltrarNegativo(local.qListaParticipantes)#
						</cfif>
					</cfsavecontent>
				</cfoutput>
			</cfcase>

			<!--- TOTAL_A_PAGAR --->
			<cfcase value="6">
				<cfsavecontent variable="s">
					<!--- p.total_a_pagar like "%#valor#%" --->
					<cfset var buscamosConOperador = detectarBusquedaConOperador(valor)>
					<cfif buscamosConOperador.operadorEncontrado>
						p.total_a_pagar #buscamosConOperador.operador# #buscamosConOperador.valorBuscado#
					<cfelse>
						p.total_a_pagar like "%#valor#%"
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- TIPO DE PARTICIPANTE --->
			<cfcase value="7">
				<cfsavecontent variable="s">

					<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
						select id_participante
						from vParticipantes p
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and p.id_tipo_participante in (<cfqueryparam value="#replace(valor, "'", "", "ALL")#" list="true" cfsqltype="cf_sql_integer">)
					</cfquery>
					<cfif local.qListaParticipantes.recordCount gt 0>
						#generarListaParticipantesAFiltrar(local.qListaParticipantes)#
					<cfelse>
						p.id_tipo_participante in (#valor#)
					</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="8">
				<!--- FECHA_ALTA --->
				<cfsavecontent variable="s">
					<!--- date_format(CONVERT_TZ(str_to_date(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%' --->

					<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
						select id_participante
						from vParticipantes p
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(CONVERT_TZ(str_to_date(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%'
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qListaParticipantes)#
				</cfsavecontent>
			</cfcase>

			<!--- ID_PARTICIPANTE --->
			<cfcase value="9">
				<cfsavecontent variable="s">
					<cfif listLen(valor) gt 1>
						p.id_participante in (#valor#)
					<cfelse>
						p.id_participante = '#valor#'
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- IVA_A_PAGAR  --->
			<cfcase value="109">
				<cfsavecontent variable="s">
					cast(ifnull((select sum(cantidad-base_imponible)/100 from resultadosDePagos where id_participante = p.id_participante),0) as decimal(11,2)) like "%#valor#%"
				</cfsavecontent>
			</cfcase>

			<cfcase value="110">
				<!--- TOTAL_SIN_IVA  --->
				<cfsavecontent variable="s">
					cast(ifnull((select sum(base_imponible)/100 from resultadosDePagos where id_participante = p.id_participante),0) as decimal(11,2)) like "%#valor#%"
				</cfsavecontent>
			</cfcase>

			<cfcase value="111">
				<!--- IMPORTE_PAGADO  --->
				<cfset var buscamosConOperador = detectarBusquedaConOperador(valor)>

				<cfsavecontent variable="s">
					<!--- ifnull((select sum(cantidad)/100 from resultadosDePagos where id_participante = p.id_participante and resultado = 'ok'),0) like "%#valor#%" --->

					<cfif buscamosConOperador.operadorEncontrado>
						<cfif buscamosConOperador.operador is "=" and buscamosConOperador.valorBuscado is 0>
							<!--- COGEMOS LOS QUE HAN PAGADO ALGO --->
							<cfquery name="local.qImportePagado" datasource="#application.datasource#">
								select
									round(sum(cantidad/100), 2) as importePagado,
									id_participante
								from resultadosDePagos
								where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_Sql_integer">
									and resultado = 'ok'
								group by id_participante
								order by null
							</cfquery>
							#generarListaParticipantesAFiltrarNEGATIVO(local.qImportePagado)#
						<cfelse>
							<!--- BUSCAMOS LOS QUE HAN PAGADO ALGO --->
							<cfquery name="local.qImportePagado" datasource="#application.datasource#">
								select *
								from (
									select
										round(sum(cantidad/100), 2) as importePagado,
										id_participante
									from resultadosDePagos
									where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_Sql_integer">
										and resultado = 'ok'
									group by id_participante
									order by null
								) a
								where a.importePagado #buscamosConOperador.operador# #buscamosConOperador.valorBuscado#
								order by null
							</cfquery>
							#generarListaParticipantesAFiltrar(local.qImportePagado)#
						</cfif>
					<cfelse>
						<cfquery name="local.qImportePagado" datasource="#application.datasource#">
							select *
							from (
								select
									round(sum(cantidad/100), 2) as importePagado,
									id_participante
								from resultadosDePagos
								where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_Sql_integer">
									and resultado = 'ok'
								group by id_participante
								order by null
							) a
							where a.importePagado like '%#arguments.valor#%'
							order by null
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qImportePagado)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="112">
				<!--- PENDIENTE_PAGO  --->
				<cfsavecontent variable="s">
					<!--- cast((p.total_a_pagar - ifnull((select sum(cantidad)/100 from resultadosDePagos where id_participante = p.id_participante and resultado = 'ok'),0)) as decimal(11,2)) like "%#valor#%" --->
					<cftry>
						<cfquery name="local.qPendientesDePago" datasource="#application.datasource#">
							select id_participante
							from
							(
								SELECT
								    p.id_participante,
								    p.total_a_pagar,
								    SUM(ifnull(cantidad, 0)) / 100 as pagado,
								    cast((p.total_a_pagar - SUM(ifnull(cantidad, 0)) / 100) as decimal(11,2)) as resto
								FROM
								    vParticipantes p left join resultadosDePagos rp on p.id_participante = rp.id_participante
								    AND rp.resultado = 'ok'
								    and rp.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
								WHERE
								    p.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
								group by p.id_participante
							) a
							where a.resto like '%#valor#%'
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qPendientesDePago)#
					<cfcatch type="any">
						cast((p.total_a_pagar - ifnull((select sum(cantidad)/100 from resultadosDePagos where id_participante = p.id_participante and resultado = 'ok'),0)) as decimal(11,2)) like "%#valor#%"
					</cfcatch>
					</cftry>
				</cfsavecontent>
			</cfcase>

			<cfcase value="118">
				<!---NUMERO_FACTURA--->
				<cfsavecontent variable="s">

					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select id_participante
						from vFacturas f
						where f.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and factura like '%#valor#%'
					</cfquery>

					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#

	            	<!---(select factura from vFacturas vf where vf.id_participante = p.id_participante) like '%#valor#%'--->
	            </cfsavecontent>
			</cfcase>

			<cfcase value="157">
				<!--- FACTURA EMITIDA--->
				<cfsavecontent variable="s">

					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select id_participante
						from vFacturas f
						where f.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>

	            	<!---(select count(factura) from vFacturas vf where vf.id_participante = p.id_participante)  = '#valor#'--->
	            </cfsavecontent>
			</cfcase>

			<cfcase value="158">
				<!--- FACTURA ENVIADA POR EMAIL --->
				<cfsavecontent variable="s">

					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						SELECT
						    participantes_id_participante as id_participante
						FROM
						    comRegEnvio cre
						        INNER JOIN
						    comRegEnvioAdjuntos crea ON cre.id_reg_envio = crea.comRegEnvio_id_reg_envio
						where cre.eventos_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
	        		<!---(
						SELECT
						    count(id_reg_envio)
						FROM
						    comRegEnvio cre
						        INNER JOIN
						    comRegEnvioAdjuntos crea ON cre.id_reg_envio = crea.comRegEnvio_id_reg_envio
						where cre.participantes_id_participante = p.id_participante
					)
					<cfif valor is 1>
					 >=
					 <cfelse>
					  =
					</cfif>
					 #valor#--->
	        	</cfsavecontent>
			</cfcase>

			<cfcase value="119">
				<!---FECHA_FACTURA--->
				<cfsavecontent variable="s">

	            	<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select id_participante
						from vFacturas f
						where f.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(fecha_factura,'%d/%m/%Y') like '%#valor#%'
					</cfquery>

					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#

	            	<!---(select date_format(fecha_factura,'%d/%m/%Y') from vFacturas vf where vf.id_participante = p.id_participante) like '%#valor#%'--->
	            </cfsavecontent>
			</cfcase>

			<cfcase value="120">
				<!---TIPO_FACTURA--->
				<cfsavecontent variable="s">
	            	(select tipo_plantilla from vFacturas vf where vf.id_participante = p.id_participante) like '%#valor#%'
	            </cfsavecontent>
			</cfcase>

			<cfcase value="131">
				<!--- FECHA_MODIF --->
				<cfsavecontent variable="s">
					<!--- date_format(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%' --->

					<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
						select id_participante
						from vParticipantes p
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%'
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qListaParticipantes)#

				</cfsavecontent>
			</cfcase>

			<cfcase value="235">
				<!--- numero de pagos por TPV --->
				<cfsavecontent variable="s">
					<!--- COGEMOS LOS QUE TIENEN ALGÚN PAGO POR TPV --->
					<cfquery name="local.qParticipantesConPagosPorTPV" datasource="#application.datasource#">
						SELECT id_participante
						FROM resultadosDePagos
						where metodoIntro = 'auto'
						and resultado = 'ok'
						and id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						order by null
					</cfquery>
					<cfif valor is 0>
						#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConPagosPorTPV)#
					<cfelse>
						#generarListaParticipantesAFiltrar(local.qParticipantesConPagosPorTPV)#
					</cfif>

					<!--- numeroPagosTPVParticipante(p.id_participante)
					<cfif valor is 0>=0<cfelse> > 0</cfif> --->
				</cfsavecontent>
			</cfcase>

		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaModalidadSeleccionada" access="public" returntype="string"
            output="false">
	<cfargument name="nombre" required="true"/>

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombre)>

	<cfoutput>

		<cfsavecontent variable="s">
			<!---nombreModalidadSeleccionadaConUnidades(p.id_participante, '#session.id_idioma#')--->
			("MODALIDAD_SELECCIONADA") as "#n#"
		</cfsavecontent>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaModalidadSeleccionadaWhere" access="public" returntype="string"
            output="false">
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>

		<cfsavecontent variable="s">
			<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
				select id_participante
				from vModalidadesSeleccionadas
				where id_modalidad in (<cfqueryparam value="#arrayToList(valor)#" list="true" cfsqltype="cf_sql_integer">)
			</cfquery>

			#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
			<!---idModalidadSeleccionada(p.id_participante) in (#arrayToLIst(valor)#)--->
		</cfsavecontent>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaDiasAsistencia" access="public" returntype="string"
            output="false">
	<cfargument name="id_dia" required="true"/>
	<cfargument name="dia" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.dia)>

	<cfset n = "DIA_SELECCIONADO_#arguments.id_dia#">
	<cfoutput>

		<cfsavecontent variable="s">
			(
				<!--- select case count(ph.id_hora) when 0 then '#objTraducciones.getString(1237)#' else concat('#objTraducciones.getString(1236)# (', cast(count(ph.id_hora) as char), ')') end as "#n#"
				from vParticipantesHoras ph inner join vHoras h
					on ph.id_hora = h.id_hora
				    and h.dias_id_dia = #arguments.id_dia#
				where ph.id_participante = p.id_participante
					and ph.activo = 1 --->
				"DIA_SELECCIONADO_RELLENO_#arguments.id_dia#"
			) as "#n#"
		</cfsavecontent>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaOpcionAdicional" access="public" returntype="string" output="false">
	<cfargument name="id_opcion" required="true"/>
	<cfargument name="nombreOpcion" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreOpcion)>

	<cfset n = "OPC_ADIC_#arguments.id_opcion#">
	<cfoutput>

		<cfsavecontent variable="s">
		(
			select case count(id_participante) when 0 then '#objTraducciones.getString(1237)#' else '#objTraducciones.getString(1236)#' end as "#n#"
			from vOpcionesAdicionalesSeleccionadas
			where id_participante = p.id_participante
				and id_opcion_adicional = #arguments.id_opcion#
			limit 1
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaEntradas" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="nombre" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombre)>

	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<!--- LISTADO DE ENTRADAS --->
			<cfcase value="159">
				<cfsavecontent variable="s">
					(
						replace(participantesListaEntradasGeneradas(p.id_evento, p.id_participante), ',', '<br>')
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- CANTIDAD DE ENTRADAS --->
			<cfcase value="247">
				<cfsavecontent variable="s">
					(
						participantesCantidadEntradasGeneradas(p.id_evento, p.id_participante)
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- MIS TICKETS --->
			<cfcase value="251">
				<cfsavecontent variable="s" >
					<!--- participantesMisEntradas(p.id_participante, p.id_evento) as "#n#" --->
					"MIS_ENTRADAS" AS "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- QUIEN HA PAGADO MI ENTRADA --->
			<cfcase value="250">
				<cfsavecontent variable="s" >
					(
						<!--- nombreParticipanteConIdFormateado(p.participantePadre, p.id_evento) --->
						"DATOS_PAGADOR_ENTRADA"
					)
					as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- ENTRADAS MULTIPLES --->
			<cfcase value="252">
				<cfsavecontent variable="s">
					<!--- (
						select count(id_participante)
						from vParticipantes
						where participantePadre = p.id_participante
							and id_evento = p.id_evento
					) as "#n#" --->
					"ENTRADAS_MULTIPLES" as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- EL PAGADOR HA PAGADO --->
			<cfcase value="253">
				<cfsavecontent variable="s">
					case when p.participantePadre is null then
						'-'
					else
						case pagadoParticipante(p.participantePadre) when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END
					end
					as "#n#"
				</cfsavecontent>
			</cfcase>


		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadesAsociadasAPonentesWhere" access="public" returntype="string" output="false">
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>

	<!---
		1.- COGEMOS LOS QUE TIENEN ALGUNA ACTIVIDAD ASOCIADA
	--->
	<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>


	<cfoutput>
		<cfsavecontent variable="s">
			<cfif trim(valor) is '=0'>
				<!--- ESTAMOS BUSCANDO LOS QUE NO TIENEN ACTIVIDAD ASOCIADA --->
				<cfquery name="local.qParticipantesConActividadesComoPonente" datasource="#application.datasource#">
					SELECT
					    distinct(id_ponente) as id_participante
					FROM
					    vSalasSeleccionadasParaActividadesPonentes sspp
					where sspp.sspa_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfif local.qParticipantesConActividadesComoPonente.recordCount gt 0>
					<!---  HAY ALGÚN PARTICIPANTE CON ASIGNACIÓN DE ACTIVIDADES COMO PONENTE --->
					#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConActividadesComoPonente)#
				<cfelse>
					<!--- NO HAY NINGÚN PONENTE CON ACTIVIDADES ASIGNADAS = TENEMOS QUE PONTAR TODOS LOS PARTICIPANTES --->
					(
						true
					)
				</cfif>
			<cfelse>
				<!--- BUSCAMOS LOS QUE TIENEN ESTA ACTIVIDAD ASOCIADA --->
				<cfquery name="local.qParticipantesConActividadesComoPonente" datasource="#application.datasource#">
					SELECT
					    distinct(id_ponente) as id_participante
					FROM
					    vSalasSeleccionadasParaActividadesPonentes sspp
					        INNER JOIN
					    vSalasSeleccionadasParaActividades sspa on sspp.id_sala_seleccionada = sspa.id_sala_seleccionada
							inner join vActividades as act on sspa.id_actividad = act.id_actividad
					        and act.id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
					        and id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_char">
					where titulo like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
				</cfquery>
				#generarListaParticipantesAFiltrar(local.qParticipantesConActividadesComoPonente)#
			</cfif>
		</cfsavecontent>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaEntradasWhere" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="valor" required="true"/>

	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<!--- LISTADO DE ENTRADAS --->
			<cfcase value="159">
				<cfsavecontent variable="s">
					(
						participantesListaEntradasGeneradas(p.id_evento, p.id_participante) like '%#arguments.valor#%'
					)
				</cfsavecontent>
			</cfcase>

			<!--- CANTIDAD DE ENTRADAS --->
			<cfcase value="247">
				<cfsavecontent variable="s">
					(
						participantesCantidadEntradasGeneradas(p.id_evento, p.id_participante) = '#arguments.valor#'
					)
				</cfsavecontent>
			</cfcase>

			<!--- MIS ENTRADAS --->
			<cfcase value="251">
				<cfsavecontent variable="s">
					(
						<!--- participantesMisEntradas(p.id_participante, p.id_evento) like '%#arguments.valor#%' --->
						<cfquery name="local.qParticipantesConEntradasMultiples" datasource="#application.datasource#">
							select
								p.participantePadre as id_participante
						    from vParticipantes p
						    where id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						    	and participantePadre is not null
						    	<!--- and participantesMisEntradas(p.id_participante, #arguments.objEvento.id_evento#) like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar"> --->
						    	and concat(ifnull(nombre_empresa, ''), ' (', ifnull(nombre, '') , ' ', ifnull(apellidos, '') ,', id = ', id_participante, ')') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
						</cfquery>

						#generarListaParticipantesAFiltrar(local.qParticipantesConEntradasMultiples)#
					)
				</cfsavecontent>
			</cfcase>

			<!--- ENTRADAS MULTIPLES --->
			<cfcase value="252">
				<cfsavecontent variable="s">
					(
						<cfif valor eq '=0'>
							<cfquery name="local.qParticipantesConEntradasMultiples" datasource="#application.datasource#">
								select
									count(participantePadre),
								    participantePadre as id_participante
								from vParticipantes
								where participantePadre is not null
									and id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								group by participantePadre
								having count(participantePadre) >= 1
								order by null
							</cfquery>
							#generarListaParticipantesAFiltrarNegativo(local.qParticipantesConEntradasMultiples)#
						<cfelse>
							<cfquery name="local.qParticipantesConEntradasMultiples" datasource="#application.datasource#">
								select
									count(participantePadre),
								    participantePadre as id_participante
								from vParticipantes
								where participantePadre is not null
									and id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								group by participantePadre
								having count(participantePadre) #valor#
								order by null
							</cfquery>
							#generarListaParticipantesAFiltrar(local.qParticipantesConEntradasMultiples)#
						</cfif>
					)
				</cfsavecontent>
			</cfcase>

			<!--- QUIEN ME HA COMPRADO LA ENTRADA --->
			<cfcase value="250">
				<cfsavecontent variable="s">
					<cfif not isNumeric(trim(arguments.valor))>
						<!--- COGEMOS LOS PARTICIPANTESPADRES CON ESTE NOMBRE --->
						<cfquery name="local.qParticipantesConPadre" datasource="#application.datasource#">
							SELECT p1.id_participante
							FROM vParticipantes p1 inner join vParticipantes p2 on
								p1.participantePadre = p2.id_participante
							    and p1.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							    and p2.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							    and concat(ifnull(p2.nombre_empresa, ''), ' (', ifnull(p2.nombre, '') , ' ', ifnull(p2.apellidos, '') ,', id = ', p2.id_participante, ')') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConPadre)#
					<cfelse>
						p.participantePadre = #arguments.valor#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- MI PAGADOR HA PAGADO --->
			<cfcase value="253">
				<cfsavecontent variable="s">
					<cfif arguments.valor is '-'>
						p.participantePadre is null
					<cfelse>
						pagadoParticipante(p.participantePadre) = #arguments.valor#
					</cfif>
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividad" access="public" returntype="string" output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="nombreActividad" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreActividad)>

	<cfoutput>

		<cfsavecontent variable="s">
		(
			"ACT_#arguments.id_actividad#"
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadSeleccionadaConPrecio" access="public" returntype="string" output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="nombreActividad" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreActividad)>

	<cfoutput>

		<cfsavecontent variable="s">
		(
			"ACTIVIDAD_SELECCIONADA_CON_PRECIO_#arguments.id_actividad#"
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadesAsociadasAPonentes" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfoutput>
		<cfsavecontent variable="s">
		(
			"ACTIVIDAD_ASOCIADA_A_PONENTE_#arguments.id_campo#"
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadSeleccionadaConPrecioPagadas" access="public" returntype="string" output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="nombreActividad" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreActividad)>

	<cfoutput>

		<cfsavecontent variable="s">
		(
			"ACTIVIDAD_SELECCIONADA_CON_PRECIO_PAGADA_#arguments.id_actividad#"
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadSeleccionadaConPrecioPagadaWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>
	<cfoutput>
		<cfsavecontent variable="s">
			<!---<cfif arguments.valor is 1>exists<cfelse>not exists</cfif>
			(
				select prioridad
				from vActividadesSeleccionadas
				where id_participante = p.id_participante
					and id_actividad = #arguments.id_actividad#
			)--->

			<cfquery name="local.qValorCampoListaPagada" datasource="#application.datasource#">
				select id_participante
				from vActividadesSeleccionadas
				where id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
					and
					(
						(
							pagada = 1 and precio_con_dto > 0
						)
						or
						(
							pagada = 0 and precio_con_dto = 0
						)
					)
			</cfquery>

			<cfif valor is 1>
				#generarListaParticipantesAFiltrar(local.qValorCampoListaPagada)#
			<cfelse>
				#generarListaParticipantesAFiltrarNegativo(local.qValorCampoListaPagada)#
			</cfif>

		</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaActividadGenerada" access="public" returntype="string" output="false">
	<cfargument name="id_actividad" required="true"/>
	<cfargument name="nombreActividad" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreActividad)>

	<!---<cfset n = 'ESTA_ACTIVIDAD_AGENDADA_#arguments.id_actividad#'>--->
	<cfoutput>
		<cfsavecontent variable="s">
		(
			<!---case estaActividadAgendada(p.id_evento, p.id_participante, #arguments.id_actividad#)
			when 0 then '#objTraducciones.getString(1237)#'
				when 1 then '#objTraducciones.getString(1236)#'
				end--->
			'ESTA_ACTIVIDAD_AGENDADA_#arguments.id_actividad#'
		) as "#n#"
	</cfsavecontent>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaProducto" access="public" returntype="string" output="false">
	<cfargument name="id_producto" required="true"/>
	<cfargument name="nombreProducto" required="true"/>
	<cfargument name="queColumna" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">

	<cfset var n = codificarNombreColumna(arguments.nombreProducto)>

	<cfset n = "PROD_#arguments.queColumna#_#arguments.id_producto#">
	<cfoutput>

		<cfsavecontent variable="s">
		(
			<!--- select case count(id_producto) when 0 then '#objTraducciones.getString(1237)#'
			else case #arguments.queColumna#
				when 0 then '#objTraducciones.getString(1237)#'
				when 1 then '#objTraducciones.getString(1236)#'
				end
			end
			from vProductosSeleccionados
			where id_participante = p.id_participante
				and id_producto = #arguments.id_producto#
			limit 1 --->

			"PROD_#arguments.queColumna#_RELLENO_#arguments.id_producto#"
		) as "#n#"
	</cfsavecontent>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaAlojamiento2" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>

	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfoutput>
		<cfswitch expression="#id_campo#">
			<!--- RESERVA HOTEL --->
			<cfcase value="140">
				<cfsavecontent variable="s" >
					(
						cantidadReservas(p.id_participante, #this.objEvento.id_evento#)
					)	as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>


<cffunction name="generarUnaColumnaAlojamiento" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="10,11,12,14,16,18,20,23,24,27" delimiters=",">
				<cfsavecontent variable="s">
					(
						select #nombreColumna#
						from vParticipantesReservasHabitaciones
						where id_participante = p.id_participante
							and id_evento = p.id_evento
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="13,15,17,19,21,22" delimiters=",">
				<cfsavecontent variable="s">
					(case
						(
							select #nombreColumna#
							from vParticipantesReservasHabitaciones
							where id_participante = p.id_participante
								and id_evento = p.id_evento
							limit #arguments.filaADevolver - 1#, 1
						)
					when 0 then '#objTraducciones.getString(1237)#'
					when 1 then '#objTraducciones.getString(1236)#'
					else ''
					end)
					 as "#n#"
				</cfsavecontent>
			</cfcase>
			<cfcase value="25">
				<cfsavecontent variable="s">
				(
					select nombreHotel(#nombreColumna#)
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="26">
				<cfsavecontent variable="s">
				(
					select nombreAlojamiento(#nombreColumna#, '#session.id_idioma_relleno#')
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="28">
				<cfsavecontent variable="s">
				(
					select nombreRegimenAlojamiento(#nombreColumna#, '#session.id_idioma_relleno#')
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="29">
				<cfsavecontent variable="s">
				(
					select #nombreColumna#
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="136">
				<cfsavecontent variable="s">
				(
					select nombreTipoHabitacion(#nombreColumna#, '#session.id_idioma_relleno#')
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="137">
				<cfsavecontent variable="s">
				(
					select nombreUsoHabitacion(#nombreColumna#, '#session.id_idioma_relleno#')
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="138">
				<cfsavecontent variable="s">
				(
					select #nombreColumna#
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="139">
				<cfsavecontent variable="s">
				(
					select concat(#nombreColumna#, logoMonedaEvento(#this.objevento.id_evento#)) as #nombreColumna#
					from vParticipantesReservasHabitaciones
					where id_participante = p.id_participante
						and id_evento = p.id_evento
					limit #arguments.filaADevolver - 1#, 1
				)  as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="243">
				<!---PRECIO POR NOCHE --->
				<cfsavecontent variable="s">
					(
						select CONCAT(precioHabitacionUso(id_habitacion, id_uso), logoMonedaEvento(#this.objevento.id_evento#))
						from vParticipantesReservasHabitaciones
						where id_participante = p.id_participante
							and id_evento = p.id_evento
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaViajeIda" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="30">
				<cfsavecontent variable="s">
					(
						select nombreTipoTransporte(id_tipo_transporte, '#session.id_idioma_relleno#')
						from vTodosTransportesLLegada
						where id_participante = p.id_participante
							and trayecto = 'LLEGADA'
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="31">
				<cfsavecontent variable="s">
					(
						select nombreTransporte(idTransporte(id_trayecto), '#session.id_idioma_relleno#')
						from vTodosTransportesLLegada t
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="32,33,34,35,36,37,38,40,42,43,45,47,56,57,58,59,60" delimiters=",">
				<cfsavecontent variable="s">
					(

							select #nombreColumna#
							from vTodosTransportesLLegada
							where id_participante = p.id_participante
							limit #arguments.filaADevolver - 1#, 1

					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="39,41,44,46,54,55" delimiters=",">
				<cfsavecontent variable="s">
					(case
						(
							select #nombreColumna#
							from vTodosTransportesLLegada
							where id_participante = p.id_participante
							limit #arguments.filaADevolver - 1#, 1
						)
					when 0 then '#objTraducciones.getString(1237)#'
					when 1 then '#objTraducciones.getString(1236)#'
					else ''
					end)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="48,51" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombrePais(#nombreColumna#, '#session.id_idioma_relleno#')
						from vTodosTransportesLLegada
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="49,52" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombreProvincia(#nombreColumna#)
						from vTodosTransportesLLegada
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="50,53" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombrePoblacion(#nombreColumna#)
						from vTodosTransportesLLegada
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaViajeRegreso" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="nombreCampo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(arguments.nombreCampo)>

	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="61">
				<cfsavecontent variable="s">
					(
						select nombreTipoTransporte(id_tipo_transporte, '#session.id_idioma_relleno#')
						from vTodosTransportesRegreso
						where id_participante = p.id_participante
							and trayecto = 'REGRESO'
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="62">
				<cfsavecontent variable="s">
					(
						select nombreTransporte(tet.id_transporte, '#session.id_idioma_relleno#')
						from vTodosTransportesRegreso t inner join vTransportesEventosTrayectos tet on t.id_trayecto = tet.id_trayecto
						where id_participante = p.id_participante
							and t.trayecto = 'REGRESO'
						limit #arguments.filaADevolver - 1#, 1
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="63,64,65,66,67,68,69,71,73,74,76,78,87,88,89,90,91" delimiters=",">
				<cfsavecontent variable="s">
					(

							select #nombreColumna#
							from vTodosTransportesRegreso
							where id_participante = p.id_participante
							limit #arguments.filaADevolver - 1#, 1

					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="70,72,75,77,85,86" delimiters=",">
				<cfsavecontent variable="s">
					(case
						(
							select #nombreColumna#
							from vTodosTransportesRegreso
							where id_participante = p.id_participante
							limit #arguments.filaADevolver - 1#, 1
						)
					when 0 then '#objTraducciones.getString(1237)#'
					when 1 then '#objTraducciones.getString(1236)#'
					else ''
					end)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="79,82" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombrePais(#nombreColumna#, '#session.id_idioma_relleno#')
						from vTodosTransportesRegreso
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="80,83" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombreProvincia(#nombreColumna#)
						from vTodosTransportesRegreso
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="81,84" delimiters=",">
				<cfsavecontent variable="s">
					(
						select nombrePoblacion(#nombreColumna#)
						from vTodosTransportesRegreso
						where id_participante = p.id_participante
						limit #arguments.filaADevolver - 1#, 1
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaAlojamientoWhere2" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true">
	<cfargument name="valor" required="true"/>

	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="140">
				<!--- NUMERO DE RESERVAS DE HOTEL --->
				<cfsavecontent variable="s">
					cantidadReservas(p.id_participante, #this.objEvento.id_evento#)
					<cfif valor is 1>
						> 0
					<cfelse>
						= 0
					</cfif>
				</cfsavecontent>
			</cfcase>


		</cfswitch>
	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaAlojamientoWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>

	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="10,11,12,14,16,18,20,23,24,27" delimiters=",">

				<cfswitch expression="#arguments.id_campo#">
					<cfcase value="10,11,14,16,18,20,23,24,27" delimiters=",">
						<cfsavecontent variable="s">
							(
								select
							    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
								from
									vParticipantesReservasHabitaciones
								where
									id_participante = p.id_participante
							) like '%#arguments.valor#%'
						</cfsavecontent>
					</cfcase>

					<cfcase value="12">
						<!--- TOTAL NOCHES --->
						<cfsavecontent variable="s">
							<!--- (
								select
							    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
								from
									vParticipantesReservasHabitaciones
								where
									id_participante = p.id_participante
							) = '#arguments.valor#' --->
							<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
							<cfquery name="local.qParticipantesConHotelEnPosicion" datasource="#application.datasource#">
								SELECT
						            id_participante
						        FROM
						            vParticipantesReservasHabitaciones
						        where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
								group by id_participante
						        having SPLIT_STR(GROUP_CONCAT(#nombreColumna#), ',', #arguments.filaADevolver#) = <cfqueryparam value="#arguments.valor#" cfsqltype="cf_sql_integer">
							</cfquery>
							#generarListaParticipantesAFiltrar(local.qParticipantesConHotelEnPosicion)#
						</cfsavecontent>
					</cfcase>

				</cfswitch>

			</cfcase>

			<cfcase value="13,15,17,19,21,22,28" delimiters=",">
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vParticipantesReservasHabitaciones
						where
							id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="25" delimiters=",">
				<!--- HOTELES --->
				<cfsavecontent variable="s">
					<cfif nombreColumna is 'id_hotel'>
						<cfset var listaHoteles = ''>

						<cfif isArray(valor)>
							<cfset listaHoteles = arrayToList(valor)>
						<cfelse>
							<cfset listaHoteles = valor>
						</cfif>

						<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
						<cfquery name="local.qParticipantesConHotelEnPosicion" datasource="#application.datasource#">
							SELECT
					            id_participante
					        FROM
					            vParticipantesReservasHabitaciones
							where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							group by id_participante
					        having SPLIT_STR(GROUP_CONCAT(#nombreColumna#), ',', #arguments.filaADevolver#) in (<cfqueryparam value="#listaHoteles#" list="true" cfsqltype="cf_sql_integer">)
						</cfquery>
						#generarListaParticipantesAFiltrar(local.qParticipantesConHotelEnPosicion)#
					<cfelse>
						(
							select
						    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#)
							from
								vParticipantesReservasHabitaciones
							where
								id_participante = p.id_participante
						)in
						(
						<cfif isArray(valor)>
							#arrayToList(valor)#
						<cfelse>
							#valor#
						</cfif>
						)
					</cfif>


				</cfsavecontent>
			</cfcase>

			<cfcase value="26">
				<!--- ALOJAMIENTOS --->
				<cfsavecontent variable="s">
					(
						select split_str(group_concat(aeh.id_alojamiento), ',', #arguments.filaADevolver#)
						from vParticipantesReservasHabitaciones a inner join vAlojamientosEventosHoteles aeh on a.id_hotel = aeh.id_hotel
						where a.id_participante = p.id_participante
					)
					in
					(
					<cfif isArray(valor)>
						#arrayToList(valor)#
					<cfelse>
						#valor#
					</cfif>
					)
				</cfsavecontent>
			</cfcase>

			<cfcase value="29">
				<!--- BONO DEL HOTEL --->
				<cfsavecontent variable="s">
					(
						select
							split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#)
							from vParticipantesReservasHabitaciones a inner join vAlojamientosEventosHoteles aeh on a.id_hotel = aeh.id_hotel
							where a.id_participante = p.id_participante
					)
					<cfif arguments.valor is 1> != ''<cfelse>= ''</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="136,137,138" delimiters=",">
				<cfsavecontent variable="s">
					<!--- (
						select
							split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!---COLLATE utf8_spanish2_ci--->
							from vParticipantesReservasHabitaciones a
							where a.id_participante = p.id_participante
								and a.id_evento = p.id_evento
					)
					in
					(
					<cfif isArray(valor)>
						#arrayToList(valor)#
					<cfelse>
						#valor#
					</cfif>
					) --->

					<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
					<cfquery name="local.qReservasDeHabitacion" datasource="#application.datasource#">
						select id_participante
						from vParticipantesReservasHabitaciones
						where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and id_habitacion in (<cfqueryparam value="#arrayToList(valor)#" list="true" cfsqltype="cf_sql_integer">)
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qReservasDeHabitacion)#
				</cfsavecontent>
			</cfcase>

			<cfcase value="243">
				<!---PRECIO POR NOCHE --->
				<cfsavecontent variable="s">
					<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
					<cfquery name="local.qPrecioporNocheEnPosicion" datasource="#application.datasource#">
						SET @currcount = NULL, @currvalue = NULL;
						SELECT id_reserva, id_participante, rank, precio
						FROM
						(
						    SELECT
						        id_reserva,
						        id_participante,
						        @currcount := IF(@currvalue = id_participante, @currcount + 1, 1) AS rank,
						        @currvalue := id_participante AS whatever,
						        precio
						    FROM vParticipantesReservasHabitaciones prh inner join vAlojamientosEventosUsosHabitaciones aeuh on prh.id_habitacion = aeuh.id_tipo_habitacion
								and prh.id_uso = aeuh.id_uso
						    where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						) AS whatever
						WHERE rank = <cfqueryparam value="#arguments.filaADevolver#" cfsqltype="cf_sql_integer">
							and precio like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qPrecioporNocheEnPosicion)#
					<!--- (
						select precioHabitacionUso(id_habitacion, id_uso)
						from vParticipantesReservasHabitaciones
						where id_participante = p.id_participante
							and id_evento = p.id_evento
						limit #arguments.filaADevolver - 1#, 1
					) LIKE '%#valor#%' --->
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaViajeIdaWhere" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>

	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="32,33,34,35,36,37,38,40,42,45,47,56,57,58,59,60">
				<!--- CAMPOS DE TEXTO --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) like '%#arguments.valor#%'
				</cfsavecontent>
			</cfcase>
			<cfcase value="48,51">
				<!--- PAISES DE SALIDA Y LLEGADA --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idPais(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="31">
				<!--- TRANSPORTE --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(idTransporte(id_trayecto)), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = #arguments.valor#
				</cfsavecontent>
			</cfcase>

			<cfcase value="50,53">
				<!--- POBLACIONES SALIDA Y REGRESO --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idPoblacion(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="49,52" delimiters=",">
				<!--- PROVINCIAS DE SALIDA Y REGRESO --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idProvincia(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="39,41,44,46,54,55">
				<!--- SI/NO --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="30">
				<!--- TIPO DE TRANSPORTE --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="43">
				<!--- BILLETE --->
				<cfsavecontent variable="s">
					(
						select
						split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from vTodosTransportesLLegada ttll
						where ttll.id_participante = p.id_participante
					)
					<cfif arguments.valor is 1> != ''<cfelse>= ''</cfif>
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaViajeRegresoWhere" access="public" returntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="filaADevolver" required="true"/>
	<cfargument name="nombreColumna" required="true"/>
	<cfargument name="valor" required="true"/>

	<cfset var s = ''>

	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="63,64,65,66,67,68,69,71,73,76,78,87,88,89,90,91">
				<!--- CAMPOS DE TEXTO --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) like '%#arguments.valor#%'
				</cfsavecontent>
			</cfcase>
			<cfcase value="79,82">
				<!--- PAISES DE SALIDA Y LLEGADA --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idPais(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="62">
				<!--- TRANSPORTE --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(idTransporte(id_trayecto)), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = #arguments.valor#
				</cfsavecontent>
			</cfcase>

			<cfcase value="81,84">
				<!--- POBLACIONES SALIDA Y REGRESO --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idPoblacion(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="80,83" delimiters=",">
				<!--- PROVINCIAS DE SALIDA Y REGRESO --->
				<cfsavecontent variable="s">
					(
						select
						    split_str(group_concat(idProvincia(#nombreColumna#)),
						            ',',
						            1) <!--- COLLATE utf8_spanish2_ci --->
						from
						    vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="70,72,75,77,85,86">
				<!--- SI/NO --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="61">
				<!--- TIPO DE TRANSPORTE --->
				<cfsavecontent variable="s">
					(
						select
					    	split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from
							vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					) = '#arguments.valor#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="74">
				<!--- BILLETE --->
				<cfsavecontent variable="s">
					(
						select
						split_str(group_concat(#nombreColumna#), ',', #arguments.filaADevolver#) <!--- COLLATE utf8_spanish2_ci --->
						from vTodosTransportesRegreso ttll
						where ttll.id_participante = p.id_participante
					)
					<cfif arguments.valor is 1> != ''<cfelse>= ''</cfif>
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>
	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaEstadisticaEnvios" access="public" returntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="id_envio" required="true"/>
	<cfargument name="titulo" required="true"/>
	<cfargument name="enlace" required="false" default=''/>

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(titulo)>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="115">
				<!--- APERTURAS --->
				<cfsavecontent variable="s">
					<cfif arguments.id_envio neq 0>
						<!---numeroAperturas(#arguments.id_envio#, p.id_participante)--->
						"NUMERO_APERTURAS_#arguments.id_envio#"
					<cfelse>
						0
					</cfif> as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="116">
				<!--- CLICS --->
				<cfsavecontent variable="s">
					<cfif arguments.id_envio neq 0>
						<!---numeroClics(#arguments.id_envio#, p.id_participante)--->
						"NUMERO_CLICS_#arguments.id_envio#"
					<cfelse>
						0
					</cfif>
					 as '#n#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="117">
				<cfsavecontent variable="s">
					<cfif arguments.id_envio neq 0>
						<!--- <cfif isdefined("url.debug")> --->
							<!---  aquí ponemos el símbolo de $ como separador porque en la url del final de la expressión pueden ir "-" --->
							"CUANTOS$CLICS$EN$ENLACE$#arguments.id_envio#$#arguments.enlace#$"
						<!--- <cfelse>
							cuantosClicsEnEnlace(#arguments.id_envio#, p.id_participante, '#arguments.enlace#')
						</cfif> --->
					<cfelse>
						0
					</cfif>
					 as '#n#'
				</cfsavecontent>
			</cfcase>

			<cfcase value="121">
				<cfsavecontent variable="s">
					(
						case
							<cfif arguments.id_envio neq 0>
								emailEnviado(#arguments.id_envio#, p.id_participante)
							<cfelse>
								0
							</cfif>
							when 0 then '#objTraducciones.getString(1237)#'
							when 1 then '#objTraducciones.getString(1236)#'
							else ''
						end
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- LISTA DE EMAILS ENVIADOS --->
			<cfcase value="151">
				<cfsavecontent variable="s">
					<!---ifnull(participantesListaEmailsEnviados2(p.id_participante, p.id_evento), '#objTraducciones.getString(4399)#')--->
					"LISTA_EMAILS_ENVIADOS"
					as "#n#"
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaEstadisticaRegistros" access="public" returntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="titulo" required="true"/>
	<cfargument name="id_actividad" required="false"/>
	<cfargument name="fecha" required="false"/>
	<cfargument name="eOs" required="false"/>

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(titulo)>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="149">
				<!---REGISTRADO EN LA FECHA QUE NOS PASAN --->
				<cfsavecontent variable="s">
					(
						<!---case
							estaRegistradoEnEventoYDia(p.id_participante, p.id_evento, '#arguments.fecha#')
						when 0 then '#objTraducciones.getString(1237)#'
						else '#objTraducciones.getString(1236)#'
						end--->
						"#objTraducciones.getString(1237)#"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="150">
				<!---REGISTRADO EN LA FECHA QUE NOS PASAN --->
				<cfsavecontent variable="s">
					(
						<!---date_format(fechaRegistroEnEventoEnDia(p.id_participante, p.id_evento, '#arguments.fecha#'), '%d/%m/%Y %H:%i:%s')--->
						"#n#"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- REGISTRADO --->
			<cfcase value="122">
				<cfsavecontent variable="s">
					(
						<!---case estaRegistradoEnEvento(p.id_participante, p.id_evento)
						when 0 then '#objTraducciones.getString(1237)#'
						else concat('#objTraducciones.getString(1236)#', ' (',  estaRegistradoEnEvento(p.id_participante, p.id_evento), ')')
						end--->
						"REGISTRADO_EN_EVENTO"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<cfcase value="123">
				<!--- FECHA DEL PRIMER REGISTRO --->
				<cfsavecontent variable="s">
					(
						<!---date_format(fechaRegistroEnEvento(p.id_participante, p.id_evento), '%d/%m/%Y %H:%i:%s')--->
						"FECHA_PRIMER_REGISTRO_EN_EVENTO"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- AZAFATA QUE HA REGISTRADO EN EL EVENTO --->
			<cfcase value="152">
				<cfsavecontent variable="s">
					(
						"AZAFATA_REGISTRO"
						<!---nombreAzafataRegistro(p.id_evento, p.id_participante)--->
					)
					 as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- FECHA/HORAS DE REGISTRO --->
			<cfcase value="162">
				<cfsavecontent variable="s">
					(
						"FECHA_TODOS_REGISTROS_EN_EVENTO"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- UNA ASISTENCIA A UNA ACTIVIDAD --->
			<cfcase value="124">
				<cfif arguments.eOs is "E">
					<cfset n = "ACTASIS_#arguments.id_actividad#">
					<cfsavecontent variable="s">
						('#objTraducciones.getString(1237)#') as "#n#"
					</cfsavecontent>
				<cfelse>
					<cfset n = "ACTASISSALIDA_#arguments.id_actividad#">
					<cfsavecontent variable="s">
						('#objTraducciones.getString(1237)#') as "#n#"
					</cfsavecontent>
				</cfif>
			</cfcase>

			<!--- CODIGO DE ACCESO --->
			<cfcase value="125">
				<cfsavecontent variable="s">
					(
						<!---codigoAccesoParticipante(p.id_participante, p.id_evento, p.id_tipo_participante)--->
						"CODIGO_ACCESO_FERIA"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- REGISTRO IN-SITU --->
			<cfcase value="130">
				<cfsavecontent variable="s">
					(case
							p.insitu
						when 0 then '#objTraducciones.getString(1237)#'
						else '#objTraducciones.getString(1236)#'
						end)
						 as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- IMPORTADO --->
			<cfcase value="132">
				<cfsavecontent variable="s">
				(case
						p.importado
					when 0 then '#objTraducciones.getString(1237)#'
					else '#objTraducciones.getString(1236)#'
					end
				) as "#n#"
			</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaAgendas" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="titulo" required="true"/>
	<cfargument name="id_actividad" required="false"/>

	<cfset var s = ''>
	<cfinclude template="/default/admin/helpers/string.cfm">
	<cfset var n = codificarNombreColumna(titulo)>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<cfcase value="101">
				<!--- ACTIVO_EN_NETWORKING --->
				<cfsavecontent variable="s">
					case p.activo_en_reuniones when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- ACTIVO_EN_ACTIVIDADES --->
			<cfcase value="102">
				<cfsavecontent variable="s">
					case p.activo_en_actividades when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END as "#n#"
				</cfsavecontent>
			</cfcase>
			<!--- NOMBRE DE LA SALA PROPIA  --->
			<cfcase value="113">
				<cfsavecontent variable="s">
					nombreSalaReuniones(p.id_sala) as "#n#"
				</cfsavecontent>
			</cfcase>
			<!--- TIENE SALA PROPIA  --->
			<cfcase value="114">
				<cfsavecontent variable="s">
					case tieneSalaPropia(p.id_tipo_participante) when 1 then '#objTraducciones.getString(1236)#' else '#objTraducciones.getString(1237)#' END as "#n#"
				</cfsavecontent>
			</cfcase>
			<!--- CANTIDAD DE REUNIONES QUE HA SOLICITADO --->
			<cfcase value="161">
				<cfsavecontent variable="s">
					("CANTIDAD_REUNIONES_SOLICITADAS") as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- ¿TIENE NREUNIONES AGENDADAS? --->
			<cfcase value="126">
				<cfsavecontent variable="s">
				(
					"CANTIDAD_REUNIONES_GENERADAS"
				) as "#n#"
			</cfsavecontent>
			</cfcase>

			<!--- REUNIONES AGENDADAS --->
			<cfcase value="142">
				<cfsavecontent variable="s">
					(
						"CANTIDAD_REUNIONES_AGENDADAS"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

			<!--- ACTIVIDAD AGENDADAS --->
			<cfcase value="127">
				<cfsavecontent variable="s">
					(
						"ACTIVIDADES_AGENDADAS"
					) as "#n#"
			</cfsavecontent>
			</cfcase>

			<cfcase value="128">
				<!--- SELECCION PREFERENCIAS --->
				<cfsavecontent variable="s">
					(
						"CANTIDAD_PREFERENCIAS"
					) as "#n#"
				</cfsavecontent>
			</cfcase>

		</cfswitch>

	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereEstadisticaEnvio" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="id_envio" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="enlace" required="false" default=''/>

	<cfset var s = ''>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
	<cfoutput>
		<cfswitch expression="#arguments.id_campo#">
			<!--- APERTURAS --->
			<cfcase value="115">
				<cfsavecontent variable="s">
					<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
					<!---numeroAperturas(#arguments.id_envio#, p.id_participante)
					<cfif valor is 0>=<cfelse>>=</cfif> '#arguments.valor#'--->

					<cfquery name="local.qAperturasEnvio" datasource="#application.datasource#">
						select
							participante_id_participante as id_participante
						from comResumenAperturasClics
						where eventos_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and envios_id_envio = <cfqueryparam value="#arguments.id_envio#" cfsqltype="cf_sql_integer">
							and num_aperturas > 0
					</cfquery>
					<cfif valor neq 0>
						<!--- ALGUNA APERTURA --->
						#generarListaParticipantesAFiltrar(local.qAperturasEnvio)#
					<cfelse>
						<!--- NO LO HAN ABIERTO --->
						#generarListaParticipantesAFiltrarNegativo(local.qAperturasEnvio)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- CLICS --->
			<cfcase value="116">
				<cfsavecontent variable="s">
					<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
					<!---numeroClics(#arguments.id_envio#, p.id_participante)
					<cfif valor is 0>=<cfelse>>=</cfif> '#arguments.valor#'--->
					<cfquery name="local.qAperturasEnvio" datasource="#application.datasource#">
						select
							participante_id_participante as id_participante
						from comResumenAperturasClics
						where eventos_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and envios_id_envio = <cfqueryparam value="#arguments.id_envio#" cfsqltype="cf_sql_integer">
							and num_clics > 0
					</cfquery>
					<cfif valor neq 0>
						<!--- ALGUNA APERTURA --->
						#generarListaParticipantesAFiltrar(local.qAperturasEnvio)#
					<cfelse>
						<!--- NO LO HAN ABIERTO --->
						#generarListaParticipantesAFiltrarNegativo(local.qAperturasEnvio)#
					</cfif>

				</cfsavecontent>
			</cfcase>

			<!--- LSTA DE CLICS DE UN ENVIO --->
			<cfcase value="117">
				<cfsavecontent variable="s">
					<cfquery name="local.qParticipantesClicksEnEnlace" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,1,0)#">
						SELECT
						    participantes_id_participante as id_participante
						FROM
						    comRegClics USE INDEX (IDX_COMREGCLICKS_TOTAL)
						WHERE
						    comEnvio_id_envio = <cfqueryparam value="#arguments.id_envio#" cfsqltype="cf_sql_integer">
						        AND url = (CASE '#arguments.enlace#' REGEXP '(partCode=)[0-9A-F]+'
						        WHEN 1 THEN GETTRADUCCION(2078, 'ES')
						        ELSE CASE '#arguments.enlace#' REGEXP 'snvbpa'
						            WHEN 1 THEN 'Si no ves bien pincha aquí'
						            ELSE '#arguments.enlace#'
						        END
						    END) COLLATE utf8_spanish_ci
					</cfquery>

					<cfif valor is 0>
						p.id_participante not in (#valueList(local.qParticipantesClicksEnEnlace.id_participante)#)
					<cfelse>
						p.id_participante in (#valueList(local.qParticipantesClicksEnEnlace.id_participante)#)
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!---LISTA DE EMAILS ENVIADOS --->
			<cfcase value="151">
				<cfsavecontent variable="s">
					<cfif valor neq 0>
						<cfif listLen(valor) gt 0>
							<!---true
							<cfloop list="#valor#" item="id_valor">
								or FIND_IN_SET(#id_valor#, participantesListaIdsEmailsEnviados(p.id_participante))
							</cfloop>--->

							<!--- SACAMOS LA LISTA DE LOS PARTICIPANTES DE ESTE EVENTO A LOS QUE SE LES HA ENVIADO ESTE EMAIL --->
							<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
							<cfquery name="local.qSacarEmailsEnviados" datasource="#application.datasource#">
								select id_participante
								from vComRegEnvio
								where id_plantilla in (<cfqueryparam value="#valor#" list="true" cfsqltype="cf_sql_integer">)
									and fecha_envio is not null
									and id_tipo_envio != 3
									and cre_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							</cfquery>
							#generarListaParticipantesAFiltrar(local.qSacarEmailsEnviados)#
						</cfif>
					<cfelse>
						<!--- SACAMOS LA LISTA DE LOS PARTICIPANTES DE ESTE EVENTO A LOS QUE SE LES HA ENVIADO ALGÚN EMAIL --->
						<cfset var objEvento = getPlugin('sessionstorage').getVar('objEvento')>
						<cfquery name="local.qSacarEmailsEnviados" datasource="#application.datasource#">
							select id_participante
							from vComRegEnvio
							where fecha_envio is not null
								and id_tipo_envio != 3
								and cre_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
						</cfquery>
						#generarListaParticipantesAFiltrarNegativo(local.qSacarEmailsEnviados)#
						<!--- ifnull(participantesListaIdsEmailsEnviados2(p.id_participante, p.id_evento), '0') = 0 --->
					</cfif>
				</cfsavecontent>
			</cfcase>

			<cfcase value="121">
				<cfsavecontent variable="s">
					emailEnviado(#arguments.id_envio#, p.id_participante) = #arguments.valor#
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereEstadisticaRegistro" access="public" returntype="string"
            output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="id_Actividad" required="false"/>
	<cfargument name="fecha" required="false"/>

	<cfset var s = ''>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<!---REGISTRADO EN EL EVENTO POR DIA --->
			<cfcase value="149">
				<cfsavecontent variable="s">
					<!---estaRegistradoEnEventoYDia(p.id_participante, p.id_evento, '#arguments.fecha#') <cfif valor is 1> != 0<cfelse> = 0</cfif>--->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vAcredRegistrosEntrada
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and fecha like <cfqueryparam value="%#arguments.fecha#%" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!---REGISTRADO EN LA FECHA QUE NOS PASAN --->
			<cfcase value="150">
				<cfsavecontent variable="s">
					<!---date_format(fechaRegistroEnEventoEnDia(p.id_participante, p.id_evento, '#arguments.fecha#'), '%d/%m/%Y %H:%i:%s') like '%#valor#%'--->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vAcredRegistrosEntrada
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(fecha, '%d/%m/%Y') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- REGISTRO EN EL EVENTO --->
			<cfcase value="122">
				<cfsavecontent variable="s">
					<!---estaRegistradoEnEvento(p.id_participante, p.id_evento) <cfif valor is 1> != 0<cfelse> = 0</cfif>--->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vAcredRegistrosEntrada
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- REGISTRO EN EL EVENTO --->
			<cfcase value="123">
				<cfsavecontent variable="s">
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vAcredRegistrosEntrada
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(fecha, '%d/%m/%Y %T'') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- FECHA/HORAS DE REGISTRO --->
			<cfcase value="162">
				<cfsavecontent variable="s">
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vAcredRegistrosEntrada
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and date_format(fecha, '%d/%m/%Y %T') like <cfqueryparam value="%#arguments.valor#%" cfsqltype="cf_sql_varchar">
					</cfquery>
					#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
				</cfsavecontent>
			</cfcase>

			<!--- AZAFATA DE ENTRADA --->
			<cfcase value="152">
				<cfsavecontent variable="s">
					<!--- idAzafataRegistro(p.id_evento, p.id_participante) in (#arrayToList(valor)#) --->
					<cfquery name="local.qAzafataRegistro" datasource="#application.datasource#">
						SELECT
							are.id_participante
						FROM
							vAcredRegistrosEntrada are
						where are.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and are.id_usuario in (<cfqueryparam value="#arrayToList(valor)#" list="true" cfsqltype="cf_sql_integer">)
					</cfquery>

					#generarListaParticipantesAFiltrar(local.qAzafataRegistro)#
				</cfsavecontent>
			</cfcase>

			<!--- UNA ASISTCENCIA A UNA ACTIVIDAD --->
			<cfcase value="124">
				<cfsavecontent variable="s">
					<cfif arguments.entradaOsalida is 'E'>
						<!---estaRegistradoEnActividadEntrada2(p.id_evento, p.id_participante, #arguments.id_actividad#) <cfif valor is 1> != 0<cfelse> = 0</cfif>--->
						<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
							select distinct(id_participante) as id_participante
							from vAcredRegistrosActividades
							where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and entradaOsalida = 'E'
								and id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<!---estaRegistradoEnActividadSalida2(p.id_evento, p.id_participante, #arguments.id_actividad#) <cfif valor is 1> != 0<cfelse> = 0</cfif>--->

						<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
							select distinct(id_participante) as id_participante
							from vAcredRegistrosActividades
							where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and entradaOsalida = 'S'
								and id_actividad = <cfqueryparam value="#arguments.id_actividad#" cfsqltype="cf_sql_integer">
						</cfquery>
					</cfif>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- CODIGO DE ACCESO --->
			<cfcase value="125">
				<cfsavecontent variable="s">
					codigoAccesoParticipante(p.id_participante, p.id_evento, p.id_tipo_participante) like '%#valor#%'
				</cfsavecontent>
			</cfcase>

			<!--- REGISTRADO IN-SITU --->
			<cfcase value="130">
				<cfsavecontent variable="s">
					p.insitu = '#valor#'
				</cfsavecontent>
			</cfcase>

			<!--- IMPORTADO --->
			<cfcase value="132">
				<cfsavecontent variable="s">
					p.importado = '#valor#'
				</cfsavecontent>
			</cfcase>
		</cfswitch>
	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="generarUnaColumnaWhereAgendas" access="public" returntype="string" output="false">
	<cfargument name="id_campo" required="true"/>
	<cfargument name="valor" required="true"/>
	<cfargument name="id_Actividad" required="false"/>

	<cfset var s = ''>
	<cfoutput>

		<cfswitch expression="#arguments.id_campo#">
			<!--- ACTIVO_EN_NETWORKING --->
			<cfcase value="101">
				<cfsavecontent variable="s">
					p.activo_en_reuniones = '#valor#'
				</cfsavecontent>
			</cfcase>

			<!--- ACTIVO_EN_ACTIVIDADES --->
			<cfcase value="102">
				<cfsavecontent variable="s">
					p.activo_en_actividades = '#valor#'
				</cfsavecontent>
			</cfcase>

			<!--- NOMBRE DE LA SALA PROPIA  --->
			<cfcase value="113">
				<cfsavecontent variable="s">
					nombreSalaReuniones(p.id_sala) like '%#valor#%'
				</cfsavecontent>
			</cfcase>
			<cfcase value="114">
				<!--- NOMBRE DE LA SALA PROPIA  --->
				<cfsavecontent variable="s">
					tieneSalaPropia(p.id_tipo_participante) = '#valor#'
				</cfsavecontent>
			</cfcase>
			<!--- AGENDAS GENERADAS --->
			<cfcase value="126">
				<cfsavecontent variable="s">
					<!--- cantidadReuniones(p.id_participante) <cfif valor is 1> != 0<cfelse> = 0</cfif> --->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(participante1) as id_participante
						from vReunionesGeneradas
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- AGENDAS GENERADAS --->
			<cfcase value="142">
				<cfsavecontent variable="s">
					(cantidadReuniones(p.id_participante) div 2) = #arguments.valor#
				</cfsavecontent>
			</cfcase>

			<!--- ACTIVIDADES GENERADAS --->
			<cfcase value="127">
				<cfsavecontent variable="s">
					<!---cantidadActividades(p.id_participante) <cfif valor is 1> != 0<cfelse> = 0</cfif>--->
					<!--- COGEMOS LOS QUE TIENEN ACTIVIDADES GENERADAS --->
					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select distinct(id_participante) as id_participante
						from vActividadesGeneradas
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- CANTIDAD DE REUNIONES SOLICITADAS --->
			<cfcase value="161">
				<!--- COGEMOS LOS QUE HAN HECHO ALGUNA SOLICITUD DE REUNION --->
				<cfsavecontent variable="s">
					<cfquery name="local.qReunionesSolicitadas" datasource="#application.datasource#" cachedwithin="#this.cache5Segundos#">
						select
							distinct(solicitante) as id_participante
						from vSolicitudesReunionesSolicitadas
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and fecha_envio is not null
					</cfquery>

					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qReunionesSolicitadas)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qReunionesSolicitadas)#
					</cfif>
				</cfsavecontent>
			</cfcase>

			<!--- SELECCION PREFERENCIAS --->
			<cfcase value="128">
				<cfsavecontent variable="s">
					<!--- cantidadPreferencias(p.id_participante) <cfif valor is 1> != 0<cfelse> = 0</cfif> --->

					<cfquery name="local.qValorCampoLista" datasource="#application.datasource#">
						select
							distinct(id_participante) as id_participante
						from vParticipantesSeleccion
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif valor is 1>
						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#
					<cfelse>
						#generarListaParticipantesAFiltrarNegativo(local.qValorCampoLista)#
					</cfif>
				</cfsavecontent>
			</cfcase>
		</cfswitch>

	</cfoutput>

	<cfreturn s>
</cffunction>

<cffunction name="exCargarColumnasInforme" access="public" returntype="any" output="false">
	<cfargument name="event"/>
	<cfargument name="rc"/>

	<cfset var s = {}>
	<cfset var objEvento = this.session.getVar('objEvento')>
	<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>

	<!---<cftry>--->
	<!--- PRIMERO PASAMOS LOS CAMPOS DE LA TABLA OTROS A LA DE NORMALES --->
	<cftransaction action="begin">
		<cftry>
			<cfquery name="local.qTraspasoCampos" datasource="#application.datasource#" result="local.result">
				insert into informesCamposFormularios
				(
					campos_id_campo,
					informes_id_informe,
					agrupacionesDeCampos_id_agrupacion,
					orden
				)
				select id_campo, id_informe, id_agrupacion, orden
				from vInformesCamposOtros
				where id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif local.result.recordcount gt 0>
				<cfquery name="local.qBorrar" datasource="#application.datasource#" result="local.resultBorrar">
					update informesCamposOtros
					set fecha_baja = now()
					where informes_id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="cf_sql_integer">
						and fecha_baja is null
				</cfquery>
			</cfif>
			<cftransaction action="commit"/>
		<cfcatch type="any">
			<cftransaction action="rollback"/>
			<cfset s.ok = false>
			<cfset s.message = cfcatch.message>
			<cfinclude template="/admin/helpers/funciones.cfm">
			<cfset enviarCorreoError('cargarColumnasInforme', cfcatch)>
		</cfcatch>
		</cftry>
	</cftransaction>

	<!--- CARGAMOS LOS CAMPOS DEL INFORME --->
	<cfquery name="local.qCamposInforme" datasource="#application.datasource#">
		select *
		from
		(
			select titulo as nombreCampo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion,
			ci.id_encapsulado, ci.id_tipo_campo_fijo
			from vInformesCamposFormularios ic inner join vCampos ci on ic.id_campo = ci.id_campo
			where id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_varchar">
			and id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="cf_sql_integer">
			union
			select titulo as nombreCampo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion,
			id_encapsulado, 0 as id_tipo_campo_fijo
			from vInformesCamposFormularios ic inner join vCamposAgrupacionesAutomaticas ci on ic.id_campo =
			ci.id_campo
			where id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_varchar">
			and id_informe = <cfqueryparam value="#arguments.rc.id_informe#" cfsqltype="cf_sql_integer">
		) a
		order by orden, id_campo
	</cfquery>

	<cfset s.colModel = arrayNew(1)>
	<cfset s.agrupacionColumnas = arrayNew(1)>

	<cfset var listaColumnas = local.qCamposInforme.columnList>

	<cfset var i = 1>

	<!--- COLUMNA DE ACCIONES --->
	<cfset var objUsuario = this.session.getVar('objUsuario')>
	<cfset var formatter = 'selectFormatterAccionesParticipantes'>
	<cfset s.colModel[i] = {name="acciones", label=" ", index="acciones", editable=false,
	                         sortable=false,search=false, width=120, title=false, align='center',
	                         formatter=formatter,frozen=true, classes='columnaAccionesParticipantes'}>

	<cfset i++>
	<cfset s.colModel[i] = {width=50, name='id_participante', label='id_participante', align='center',
	                         sortable=true,editable=true, hidden=true, search=true}>

	<cfset i++>
	<cfset s.colModel[i] = {width=150, name='id_formulario', label='id_formulario', align='center',
	                         sortable=false,editable=true, hidden=true, search=false}>

	<cfset session.posicionPasswordEnInforme = "-4">
	<cfset session.posicionCodigoEnInforme = "-4">

	<cfset session.posicionesDocumentosEnInforme = ''>

	<cfset session.posicionPrimerCampoAlojamientoGestionado = -2>
	<cfset session.cantidadAlojamientosGestionados = 0>
	<cfset session.consultaCamposAlojamientos = ''>
	<cfset session.clicks = {}>

	<cfset session.noCodificar = []>

	<cfset var alojamientosPuestos = false>
	<cfset var viajesIdaPuestos = false>
	<cfset var viajesVueltaPuestos = false>

	<cfset var objGeneradorColumnas = createObject('component', 'default.admin.model.informes.generadorColumnas').init(this.objEvento.id_evento, session.id_idioma, session.id_idioma_relleno)>

	<cfloop query="local.qCamposInforme">

		<cfswitch expression="#id_agrupacion#">
			<!--- SEATING --->
			<cfcase value="181">
				<cfset i++>
				<cfset s.colModel[i] = objGeneradorColumnas.cargarColumnaInformeSeating(id_campo, nombreCampo)>
				<cfif id_campo is 164>
					<cfset session.noCodificar.append(i)>
				</cfif>
			</cfcase>

			<!--- AREA PRIVADA --->
			<cfcase value="180">
				<!---
					266 = log_app
					267 = log_app_Ultima_Fecha
					2 = Password
					1 = Usuario
					245 = ENCUESTAS REALIZADAS
					558 = Area Privada - Datos Expositor
				 --->

				<cfif listfind('266', id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo266(id_campo, nombreCampo)>
				<cfelseif listfind('267', id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo267(id_campo, nombreCampo)>
				<cfelseif listfind('2', id_campo) gt 0>
					<cfset i++>
					<cfset session.posicionPasswordEnInforme = i>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo2(id_campo, nombreCampo)>
				<cfelseif listfind('1', id_campo) gt 0>
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo1(id_campo, nombreCampo)>
				<cfelseif listfind('245', id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo245(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('558', id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo558(id_campo, nombreCampo)>
				</cfif>
			</cfcase>

			<!---COMUNICACIONES --->
			<cfcase value="25">
				<cfif listfind('249', id_campo) gt 0>
					<!--- LISTA DE IDS DE COMUNICACIONES --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo249(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				</cfif>

				<cfif listfind('241', id_campo) gt 0>
					<!--- NUMERO DE COMUNICACIONES --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo241(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				</cfif>
			</cfcase>

			<!---ENTRADAS--->
			<cfcase value="38">
				<cfif listfind('252', id_campo) gt 0>
					<!--- ENTRADAS MULTIPLES --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo252(id_campo, nombreCampo)>
				<cfelseif listfind('251', id_campo) gt 0>
					<!--- QUIEN ME HA COMPRADO LA ENTRADA --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo251(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('250', id_campo) gt 0>
					<!--- QUIEN ME HA COMPRADO LA ENTRADA --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo250(id_campo, nombreCampo)>
				<cfelseif listfind('253', id_campo) gt 0>
					<!--- EL PAGADOR HA PAGADO --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo253(id_campo, nombreCampo)>
				</cfif>
			</cfcase>


			<!--- MENSAJERIA --->
			<cfcase value="36">
				<!---
					256 = CANTIDAD DE MENSAJES RECIBIDOS
					257 = CANTIDAD DE MENSAJES NO LEIDOS
					258 = CANTIDAD DE MENSAJES ENVIADOS
				 --->
				<cfif arrayFind([256,257,258], id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo256_257_258(id_campo, nombreCampo)>
				</cfif>
			</cfcase>

			<!--- AGENDAS --->
			<cfcase value="27">
				<cfif arrayfind([126,127,128,161], id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo126_127_128_161(id_campo, nombreCampo)>
				<cfelseif listfind('142', id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo142(id_campo, nombreCampo)>
				<!--- ACTIVO EN ACTIVIDADES, ACTIVO EN NETWORKING --->
				<cfelseif listfind('102,101', id_campo)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo101_102(id_campo, nombreCampo)>
				<cfelseif listfind('114', id_campo)>
					<!--- SALA PROPIA --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo114(id_campo, nombreCampo)>
				<cfelseif listfind('153', id_campo) gt 0>
					<!--- LISTA DE ACTIVIDADES AGENDADAS--->
					<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
					<cfset var objGrupo = ''>
					<cfset var id_grupo = ''>

					<cfset var listaActividades = ''>
					<cfset var objActividad = ''>
					<cfset var id_actividad = ''>
					<cfset var sAgrupacion = {}>
					<cfloop list="#listaGrupos#" index="id_grupo">
						<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
						<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
						<cfif listlen(listaActividades) gt 0>
							<cfset sAgrupacion = {}>
							<cfset sAgrupacion.startColumnName = 'ACTGEN_#listfirst(listaActividades)#'>

							<cfloop list="#listaActividades#" index="id_actividad">
								<cfset objActividad = objGrupo.getActividad(id_actividad)>
								<cfset i++>
								<cfset s.colModel[i] = cargarColumnaInformeCampo153(id_actividad, objActividad.nombre)>
							</cfloop>

							<cfset sAgrupacion.numberOfColumns = listlen(listaActividades)>
							<cfset sAgrupacion.titleText = nombreCampo & ": " & objGrupo.nombre>
							<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
						</cfif>
					</cfloop>
				<cfelseif listfind('113', id_campo)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo113(id_campo, nombreCampo)>
				</cfif>
			</cfcase>

			<!--- CALENDARIO SELECCIONADO --->
			<cfcase value="8">
				<cfif listFind('155', id_campo)>
					<!--- DÍAS DE ASISTENCIA --->
					<cfset var dias = structSort(objEvento.calendario.dias, 'textnocase', 'asc', 'diaOrden')>
					<cfset var listaDias = arrayToList(dias)>
					<cfif listlen(listaDias) gt 0>
						<cfset sAgrupacion = {}>
						<cfset sAgrupacion.startColumnName = 'DIA_SELECCIONADO_#listfirst(listaDias)#'>

						<cfloop list="#listaDias#" index="id_dia">
							<cfset i++>
							<cfset nombreCampoIndividual = objEvento.calendario.dias[id_dia].diaFULL>
							<cfset s.colModel[i] = cargarColumnaInformeCampo155(id_dia, nombreCampoIndividual)>
						</cfloop>
						<cfset sAgrupacion.numberOfColumns = listlen(listaDias)>
						<cfset sAgrupacion.titleText = nombreCampo>
						<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
					</cfif>
				<cfelseif listFind('156', id_campo)>
					<!--- HORAS SELECCIONADAS --->
				</cfif>
			</cfcase>

			<!--- ESTADISTICAS DE LAS INVITACIONES --->
			<cfcase value="37">
				<cfset i++>
				<cfset s.colModel[i] = cargarColumnaInformeCamposAgrupacion37(id_campo, nombreCampo)>
			</cfcase>

			<!--- ESTADISTICAS DE REGISTRO EN EL EVENTO --->
			<cfcase value="7">
				<cfif listfind('122', id_campo)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo122(id_campo, nombreCampo)>
				<cfelseif listfind('123', id_campo)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo123(id_campo, nombreCampo)>
				<cfelseif listfind('152', id_campo)>
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo152(id_campo, nombreCampo)>
				<cfelseif listfind('162', id_campo)>
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo162(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('124', id_campo)>
					<!--- LISTA DE ACTIVIDADES ASISTIDAS --->
					<cfinclude template="/default/admin/helpers/listas.cfm">
					<cfquery name="local.qActividadesAsistidas" datasource="#application.datasource#">
						SELECT group_concat(distinct(ara.id_actividad)) as ids
						FROM vAcredRegistrosActividades ara
						where id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
					</cfquery>

					<cfset var listaActividadesAsistidas = local.qActividadesAsistidas.ids>

					<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
					<cfset var objGrupo = ''>
					<cfset var id_grupo = ''>

					<cfset var listaActividades = ''>
					<cfset var objActividad = ''>
					<cfset var id_actividad = ''>
					<cfset var sAgrupacion = {}>
					<cfloop list="#listaGrupos#" index="id_grupo">
						<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
						<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
						<cfset listaActividades = listIntersect(listaActividades, listaActividadesAsistidas)>
						<cfif listlen(listaActividades) gt 0>
							<cfset sAgrupacion = {}>
							<cfset sAgrupacion.startColumnName = 'ACTASIS_#listfirst(listaActividades)#'>

							<cfloop list="#listaActividades#" index="id_actividad">
								<cfset objActividad = objGrupo.getActividad(id_actividad)>
								<cfset i++>
								<cfset s.colModel[i] = cargarColumnaInformeCampoActividadesAsistidasEntrada(objActividad)>

								<cfset i++>
								<cfset s.colModel[i] = cargarColumnaInformeCampoActividadesAsistidasSalida(objActividad)>
							</cfloop>
							<cfset sAgrupacion.numberOfColumns = listlen(listaActividades) * 2>
							<cfset sAgrupacion.titleText = nombreCampo & ': ' & objGrupo.nombre>
							<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
						</cfif>
					</cfloop>
				<cfelseif listfind('125', id_campo)>
					<!--- CODIGO DE ACCESO --->
					<cfset i++>
					<cfset session.posicionCodigoEnInforme = i>
					<cfset s.colModel[i] = cargarColumnaInformeCampo125(id_campo, nombreCampo)>
				<cfelseif listfind('130', id_campo)>
					<!--- REGISTRO IN-SITU --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo130(id_campo, nombreCampo)>
				<cfelseif listfind('132', id_campo)>
					<!--- IMPORTADO --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo132(id_campo, nombreCampo)>
				<cfelseif listfind('149', id_campo)>
					<!---REGISTRO POR DÍAS --->
					<!---COGEMOS EL CALENDARIO --->
					<cfset var dias = structSort(objEvento.calendario.dias, 'textnocase', 'asc', 'diaOrden')>
					<cfset var listaDias = arrayToList(dias)>
					<cfif listlen(listaDias) gt 0>
						<cfinclude template="/default/admin/helpers/string.cfm">
						<cfset sAgrupacion = {}>
						<cfset sAgrupacion.startColumnName = 'REGISTROSDIAS_#listfirst(listaDias)#'>

						<cfloop list="#listaDias#" index="id_dia">
							<cfset i++>
							<cfset s.colModel[i] = cargarColumnaInformeCampo149(id_dia, format2(objTraducciones.getString(3825), objEvento.calendario.dias[id_dia].diaFULL))>
						</cfloop>
						<cfset sAgrupacion.numberOfColumns = listlen(listaDias)>
						<cfset sAgrupacion.titleText = nombreCampo>
						<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
					</cfif>
				<cfelseif listfind('150', id_campo)>
					<!---FECHAS REGISTRO POR DÍAS --->
					<!---COGEMOS EL CALENDARIO --->
					<cfset var dias = structSort(objEvento.calendario.dias, 'textnocase', 'asc', 'diaOrden')>
					<cfset var listaDias = arrayToList(dias)>
					<cfinclude template="/default/admin/helpers/string.cfm">
					<cfset var nombreCampoIndividual = ''>

					<cfset sAgrupacion = {}>
					<cfset sAgrupacion.startColumnName = 'FECHAHORAREGISTROSPORDIAS_#listfirst(listaDias)#'>

					<cfloop list="#listaDias#" index="id_dia">
						<cfset i++>
						<cfset nombreCampoIndividual = format2(objTraducciones.getString(3826), objEvento.calendario.dias[id_dia].diaFULL)>
						<cfset s.colModel[i] = cargarColumnaInformeCampo150(id_dia, nombreCampoIndividual)>
					</cfloop>
					<cfset sAgrupacion.numberOfColumns = listlen(listaDias)>
					<cfset sAgrupacion.titleText = nombreCampo>
					<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
				</cfif>
			</cfcase>

			<!--- ESTADISTICAS ENVIOS --->
			<cfcase value="6">
				<cfset arguments.event.paramValue('id_envio', 0)>
				<cfif listfind('115,116', id_campo)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo115_116(id_campo, nombreCampo)>
				<cfelseif (id_campo is 117)>
					<!--- COGEMOS LA LISTA DE CLICS DE LOS PARTICIPANTES QUE HAN HECHO CLIC --->
					<cfset arguments.event.paramValue('id_envio', 0)>
					<cfset structClear(session.clicks)>
					<cfif arguments.rc.id_envio neq 0>
						<cfquery name="local.qClicksRealizados" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select
							 <!---distinct url laurl--->
							 distinct CASE url REGEXP '(partCode=)[0-9A-F]+'
						        WHEN 1 THEN getTraduccion(2078, 'ES')
						        else
									CASE url REGEXP 'snvbpa'
						            when 1 then 'Si no ves bien pincha aquí'
						            else  url
						            end
						    END laurl
							from
							 comRegClics crc
							 inner join
							 comResumenAperturasClics crac ON crc.participantes_id_participante =
							crac.participante_id_participante
							inner join vParticipantes p on crac.participante_id_participante = p.id_participante
							 and crc.comEnvio_id_envio = crac.envios_id_envio
							 and crc.comEnvio_id_envio = <cfqueryparam value="#arguments.rc.id_envio#" cfsqltype="cf_sql_integer">
							order by url
						</cfquery>

						<cfif local.qClicksRealizados.recordCount gt 0>
							<cfset var objTraducciones = getColdBoxOCM().get('objTraducciones')>
							<cfset sAgrupacion = {}>
							<cfset sAgrupacion.startColumnName = 'CLICK_1'>
							<cfloop query="local.qClicksRealizados">
								<cfset session.clicks[currentRow] = laurl>
								<cfset var nc = objTraducciones.getString(2444) & " #currentRow#">

								<cfset i++>
								<cfset s.colModel[i] =
								{
									width=75,
									name='CLICK_#currentRow#',
									label='#nc#',
									align='center',
								    sortable=false,
								    editable=true,
								    search=true,
								    stype='select',
									title=true,
									tooltip='#laurl#',
								    searchOptions=
								    {
								    	search=true,
								    	value='-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'
								    }
								}>
							</cfloop>
							<cfset sAgrupacion.numberOfColumns = local.qClicksRealizados.recordCount>
							<cfset sAgrupacion.titleText = objTraducciones.getString(2445)>
							<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
						<cfelse>
							<cfset i++>
							<cfset s.colModel[i] = cargarColumnaInformeCampoPorDefecto(id_campo, nombreCampo)>
						</cfif>
					<cfelse>
						<cfset i++>
						<cfset s.colModel[i] = cargarColumnaInformeCampoPorDefecto(id_campo, nombreCampo)>
					</cfif>
				<cfelseif (id_campo is 121)>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo121(id_campo, nombreCampo)>
				<cfelseif (id_campo is 151)>
					<!--- LISTA DE EMAILS ENVIADOS --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo151(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				</cfif>
			</cfcase>

			<!--- ALOJAMIENTOS GESTIONADOS --->
			<cfcase value="3">

				<cfif listfind('140', id_campo) gt 0>
					<!---RESERVA DE HOTEL --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo140(id_campo, nombreCampo)>

				<cfelse>
				<cfif not alojamientosPuestos>
					<!--- SACAMOS LA CANTIDAD DE ALOJAMIENTOS GESTIONADOS --->
					<cfset session.posicionPrimerCampoAlojamientoGestionado = i>
					<cfquery name="local.qCantidadAlojamientosGestionados" datasource="#application.datasource#">
						select
						 count(a.id_participante) as cantidad
						from
						 vParticipantesReservasHabitaciones a
						 inner join
						 vParticipantes p ON a.id_participante = p.id_participante
						 and p.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						 group by a.id_participante
						order by cantidad desc
						limit 0, 1
					</cfquery>

					<cfset session.cantidadAlojamientosGestionados = local.qCantidadAlojamientosGestionados.cantidad>

					<!--- PINTAMOS TANTOS GRUPOS DE CAMPOS COMO ALOJAMIENTOS --->
					<cfquery name="local.qCamposAlojamientos" dbtype="query">
						select *
						from local.qCamposInforme
						where id_agrupacion = 3
						and id_campo != 140
						order by orden
					</cfquery>

					<cfset session.consultaCamposAlojamientos = local.qCamposAlojamientos>

					<cfset var listaCampos = valuelist(local.qCamposAlojamientos.id_campo)>
					<cfset var j = 1>
					<cfset var sAgrupacion = {}>

					<!--- MIRAMOS SI HAY QUE SACAR LA LISTAS --->
					<cfset var sComboHoteles = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboAlojamientos = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboSiNo = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'>
					<cfset var sComboRegimen = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboBono = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'>
					<cfset var sCombo = ''>
					<cfset var sComboTipoHabitacion = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboUsos = '-:#objTraducciones.getString(1268)#'>

					<cfset var cantidad = 0>
					<cfif local.qCantidadAlojamientosGestionados.cantidad neq ''>
						<cfset cantidad = local.qCantidadAlojamientosGestionados.cantidad>
					</cfif>

					<cfset var objAlojamientos = createObject('component',
					                                          'default.admin.model.viajes.alojamientos').init(this.objevento.id_evento,
					                                                                                          '',
					                                                                                          session.id_idioma_relleno)>
					<cfloop from="1" to="#cantidad#" index="j">
						<cfset sAgrupacion = {}>

						<cfset sAgrupacion.startColumnName = 'ALOJA_#j#_#local.qCamposAlojamientos.id_campo#'>

						<cfloop query="local.qCamposAlojamientos">
							<cfset i++>
							<cfset s.colModel[i] = cargarColumnaInformeCampoAlojamiento(j, id_campo, nombreCampo)>

							<cfif local.qCamposAlojamientos.id_campo is 25>
								<!--- SELECCIONAMOS LA LISTA DE HOTELES --->
								<cfquery name="local.qHoteles" datasource="#application.datasource#">
									select ah.id_hotel, ah.nombre
									from vAlojamientosEventosHoteles ah inner join vAlojamientosEventos a
										on a.id_alojamiento = ah.id_alojamiento
									where a.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
										and a.id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_char">
									order by nombre
								</cfquery>
								<cfloop query="local.qHoteles">
									<cfset sComboHoteles = listAppend(sComboHoteles, '#id_hotel#:#nombre#', ';')>
								</cfloop>
							</cfif>

							<cfif local.qCamposAlojamientos.id_campo is 26>
								<!--- SELECCIONAMOS LA LISTA DE ALOJAMIENTOS --->
								<cfquery name="local.qAlojamientos" datasource="#application.datasource#">
									select id_alojamiento, nombre
									from vAlojamientosEventos a
									where a.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
										and a.id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_char">
									order by nombre
								</cfquery>
								<cfloop query="local.qAlojamientos">
									<cfset sComboAlojamientos = listAppend(sComboAlojamientos, '#id_alojamiento#:#nombre#', ';')>
								</cfloop>
							</cfif>

							<cfif local.qCamposAlojamientos.id_campo is 28>
								<!--- SELECCIONAMOS LA LISTA DE ALOJAMIENTOS --->
								<cfset var objSistema = getColdBoxOCM().get('objSistema')>
								<cfquery name="local.qRegimenesAlojamiento" dbtype="query">
									select id_regimen, texto_#session.id_idioma# as texto
									from objSistema.regimenesAlojamiento
									order by texto
								</cfquery>
								<cfloop query="local.qRegimenesAlojamiento">
									<cfset sComboRegimen = listAppend(sComboRegimen, '#id_regimen#:#texto#', ';')>
								</cfloop>
							</cfif>

							<cfif local.qCamposAlojamientos.id_campo is 136>
								<!--- SELECCIONAMOS LA LISTA DE TIPOS DE HABITACIONES --->
								<cfset var args = {}>
								<cfset args.rc = {}>
								<cfset args.rc.id_hotel = ''>
								<cfset var qTiposhabitaciones = objAlojamientos.getListaTiposHabitaciones(args.rc)>

								<cfloop query="local.qTiposhabitaciones">
									<cfset sComboTipoHabitacion = listAppend(sComboTipoHabitacion, '#id_tipo_habitacion#:#nombre#',';')>
								</cfloop>
							</cfif>

							<cfif local.qCamposAlojamientos.id_campo is 137>
								<!--- SELECCIONAMOS LA LISTA DE USOS --->
								<cfset var args = {}>
								<cfset args.rc = {}>
								<cfset args.rc.id_hotel = ''>
								<cfset var qUsos = objAlojamientos.getListaUsos(args.rc)>

								<cfloop query="local.qUsos">
									<cfset sComboUsos = listAppend(sComboUsos, '#id_uso#:#nombre#', ';')>
								</cfloop>
							</cfif>

							<cfswitch expression="#local.qCamposAlojamientos.id_campo#">
								<cfcase value="25,26,13,15,17,19,21,22,28,29,136,137" delimiters=",">
									<!--- ALOJAMIENTO, HOTEL --->
									<cfif local.qCamposAlojamientos.id_campo is 25>
										<cfset sCombo = sComboHoteles>
									<cfelseif (local.qCamposAlojamientos.id_campo is 26)>
										<!--- SELECCIONAMOS LA LISTA DE ALOJAMIENTOS --->
										<cfset sCombo = sComboAlojamientos>
									<cfelseif listfind('13,15,17,19,21,22', local.qCamposAlojamientos.id_campo) gt 0>
										<cfset sCombo = sComboSiNo>
									<cfelseif (local.qCamposAlojamientos.id_campo is 28)>
										<cfset sCombo = sComboRegimen>
									<cfelseif (local.qCamposAlojamientos.id_campo is 29)>
										<cfset sCombo = sComboBono>
									<cfelseif (local.qCamposAlojamientos.id_campo is 136)>
										<cfset sCombo = sComboTipoHabitacion>
									<cfelseif (local.qCamposAlojamientos.id_campo is 137)>
										<cfset sCombo = sComboUsos>
									</cfif>
									<cfset var sFunc = 'dataInitMultiselect'>
									<cfset var = sLocal = {stype='select', searchOptions={sopt=['eq', 'ne'], value='#sCombo#', attr={multiple='multiple', size=4}, dataInit=#sFunc#}}>
									<cfset StructAppend(s.colModel[i], sLocal)>
								</cfcase>
							</cfswitch>

						</cfloop>

						<cfset sAgrupacion.numberOfColumns = local.qCamposAlojamientos.recordcount>
						<cfset sAgrupacion.titleText = objTraducciones.getString(2175)>

						<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>

					</cfloop>

					<cfset alojamientosPuestos = true>

				</cfif>
				</cfif>

			</cfcase>


			<!--- VIAJES DE IDA GESTIONADOS --->
			<cfcase value="4">
				<cfif not viajesIdaPuestos>
					<cfset viajesIdaPuestos = true>

					<!--- SACAMOS LA CANTIDAD DE VIAJES DE IDA GESTIONADOS --->
					<cfset session.posicionPrimerCampoViajesIdaGestionado = i>
					<cfquery name="local.qCantidadViajesIdaGestionados" datasource="#application.datasource#">
						select
						 count(t.id_participante) as cantidad
						from
						 vTodosTransportesLLegada t
						 inner join
						 vParticipantes p ON p.id_participante = t.id_participante
						 and p.id_evento = <cfqueryparam value="#this.objEvento.id_evento#" cfsqltype="cf_sql_integer">
						 group by p.id_participante
						order by cantidad desc
						limit 0 , 1
					</cfquery>

					<cfset session.cantidadViajesIdaGestionados = local.qCantidadViajesIdaGestionados.cantidad>

					<!--- PINTAMOS TANTOS GRUPOS DE CAMPOS COMO ALOJAMIENTOS --->
					<cfquery name="local.qCamposViajesIda" dbtype="query">
						select *
						from local.qCamposInforme
						where id_agrupacion = 4
						order by orden
					</cfquery>

					<cfset session.consultaCamposViajesIda = local.qCamposViajesIda>

					<cfset var listaCampos = valuelist(local.qCamposViajesIda.id_campo)>
					<cfset var j = 1>
					<cfset var sAgrupacion = {}>

					<cfset var cantidad = 0>
					<cfif local.qCantidadViajesIdaGestionados.cantidad neq ''>
						<cfset cantidad = local.qCantidadViajesIdaGestionados.cantidad>
					</cfif>

					<cfset var sComboSiNo = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'>
					<cfset var sComboTipoTransporte = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboPaises = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboPoblacionesSalida = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboPoblacionesLLegada = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboProvinciasSalida = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboProvinciasLLegada = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboTransportes = '-:#objTraducciones.getString(1268)#'>

					<cfset var sCombo = ''>
					<cfloop from="1" to="#cantidad#" index="j">
						<cfset sAgrupacion = {}>
						<cfset sAgrupacion.startColumnName = 'VIAJE_IDA_#j#_#local.qCamposViajesIda.id_campo#'>

						<cfloop query="local.qCamposViajesIda">
							<cfset i++>
							<cfset s.colModel[i] = {width=90, name='VIAJE_IDA_#j#_#local.qCamposViajesIda.id_campo#',
							                               label='#nombreCampo#',align='center', sortable=false,
							                               editable=true,search=true}>
							<!--- AQU? VAN LOS COMBOS DEL FILTRO --->
							<cfif local.qCamposViajesIda.id_campo is 30>
								<cfif listlen(sComboTipoTransporte, ';') is 1>
									<cfquery name="local.qDatos" datasource="#application.datasource#">
										select id_tipo_transporte, texto_#session.id_idioma_relleno# as texto
										from vTiposTransportes
										order by texto
									</cfquery>
									<cfloop query="local.qDatos">
										<cfset sComboTipoTransporte = listAppend(sComboTipoTransporte,
										                                         '#id_tipo_transporte#:#texto#',';')>
									</cfloop>
								</cfif>
							<cfelseif listFind('48,51', local.qCamposViajesIda.id_campo) gt 0>
								<cfif listlen(sComboPaises, ';') is 1>
									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPaises = objLocalizaciones.getListaPaises()>
									<cfloop query="local.qPaises">
										<cfset sComboPaises = listAppend(sComboPaises, '#id_pais#:#nombre#', ';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesIda.id_campo is 53>
								<cfif listlen(sComboPoblacionesLLegada, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel2 as id_nivel2
										from vTodosTransportesLLegada ttll inner join vLocalizaciones l on
										ttll.llegada_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPoblaciones = objLocalizaciones.getNombrePoblaciones(valuelist(local.qDistintasLocalizaciones.id_nivel2))>
									<cfloop query="local.qPoblaciones">
										<cfset sComboPoblacionesLLegada = listAppend(sComboPoblacionesLLegada,
										                                             '#id_nivel2#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesIda.id_campo is 50>
								<cfif listlen(sComboPoblacionesSalida, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel2 as id_nivel2
										from vTodosTransportesLLegada ttll inner join vLocalizaciones l on
										ttll.salida_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPoblaciones = objLocalizaciones.getNombrePoblaciones(valuelist(local.qDistintasLocalizaciones.id_nivel2))>
									<cfloop query="local.qPoblaciones">
										<cfset sComboPoblacionesSalida = listAppend(sComboPoblacionesSalida,
										                                            '#id_nivel2#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesIda.id_campo is 52>
								<cfif listlen(sComboProvinciasLLegada, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel1 as id_nivel1
										from vTodosTransportesLLegada ttll inner join vLocalizaciones l on
										ttll.llegada_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qProvincias = objLocalizaciones.getNombreProvincias(valuelist(local.qDistintasLocalizaciones.id_nivel1))>
									<cfloop query="local.qProvincias">
										<cfset sComboProvinciasLLegada = listAppend(sComboProvinciasLLegada,
										                                            '#id_nivel1#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesIda.id_campo is 49>
								<cfif listlen(sComboProvinciasSalida, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel1 as id_nivel1
										from vTodosTransportesLLegada ttll inner join vLocalizaciones l on
										ttll.salida_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qProvincias = objLocalizaciones.getNombreProvincias(valuelist(local.qDistintasLocalizaciones.id_nivel1))>
									<cfloop query="local.qProvincias">
										<cfset sComboProvinciasSalida = listAppend(sComboProvinciasSalida,
										                                           '#id_nivel1#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesIda.id_campo is 31>
								<cfif listlen(sComboTransportes, ';') is 1>
									<cfquery name="local.qTransportes" datasource="#application.datasource#">
										select
										 distinct tet.id_transporte, nombreTransporte(tet.id_transporte, '#session.id_idioma_relleno#
										') as nombre
										from
										 vTransportesEventosTrayectos tet inner join vTransportes t on t.id_trayecto =
										tet.id_trayecto
										where trayecto = 'LLEGADA'
										and idEvento(id_participante) = #this.objEvento.id_evento#order by nombre
									</cfquery>
									<cfloop query="local.qTransportes">
										<cfset sComboTransportes = listAppend(sComboTransportes, '#id_transporte#:#nombre#', ';')>
									</cfloop>
								</cfif>
							</cfif>

							<cfswitch expression="#local.qCamposViajesIda.id_campo#">
								<cfcase value="30,31,39,41,43,44,46,48,49,50,51,52,53,54,55" delimiters=",">
									<cfif listfind('39,41,43,44,46,54,55', local.qCamposViajesIda.id_campo)>
										<cfset sCombo = sComboSiNo>
									<cfelseif local.qCamposViajesIda.id_campo is 31>
										<cfset sCombo = sComboTransportes>
									<cfelseif local.qCamposViajesIda.id_campo is 30>
										<cfset sCombo = sComboTipoTransporte>
									<cfelseif listfind('51,48', local.qCamposViajesIda.id_campo) gt 0>
										<cfset sCombo = sComboPaises>
									<cfelseif listfind('50', local.qCamposViajesIda.id_campo) gt 0>
										<cfset sCombo = sComboPoblacionesSalida>
									<cfelseif listfind('53', local.qCamposViajesIda.id_campo) gt 0>
										<cfset sCombo = sComboPoblacionesLLegada>
									<cfelseif listfind('49', local.qCamposViajesIda.id_campo) gt 0>
										<cfset sCombo = sComboProvinciasSalida>
									<cfelseif listfind('52', local.qCamposViajesIda.id_campo) gt 0>
										<cfset sCombo = sComboProvinciasLLegada>
									</cfif>

									<cfset var = sLocal = {stype='select', searchOptions={search=true, value='#sCombo#'}}>
									<cfset StructAppend(s.colModel[i], sLocal)>
								</cfcase>
							</cfswitch>

						</cfloop>

						<cfset sAgrupacion.numberOfColumns = local.qCamposViajesIda.recordcount>
						<cfset sAgrupacion.titleText = objTraducciones.getString(2221)>

						<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
					</cfloop>
				</cfif>
			</cfcase>

			<!--- VIAJES DE VUELTA GESTIONADOS --->
			<cfcase value="5">
				<cfif not viajesVueltaPuestos>
					<cfset viajesVueltaPuestos = true>

					<!--- SACAMOS LA CANTIDAD DE VIAJES DE IDA GESTIONADOS --->
					<cfset session.posicionPrimerCampoViajesRegresoGestionado = i>
					<cfquery name="local.qCantidadViajesRegresoGestionados" datasource="#application.datasource#">
						select
						 count(t.id_participante) as cantidad
						from
						 vTodosTransportesRegreso t
						 inner join
						 vParticipantes p ON p.id_participante = t.id_participante
						 	and p.id_evento = #this.objEvento.id_evento#
						 group by p.id_participante
						order by cantidad desc
						limit 0 , 1
					</cfquery>

					<cfset session.cantidadViajesRegresoGestionados = local.qCantidadViajesRegresoGestionados.cantidad>

					<!--- PINTAMOS TANTOS GRUPOS DE CAMPOS COMO ALOJAMIENTOS --->
					<cfquery name="local.qCamposViajesRegreso" dbtype="query">
						select *
						from local.qCamposInforme
						where id_agrupacion = 5
						order by orden
					</cfquery>

					<cfset session.consultaCamposViajesRegreso = local.qCamposViajesRegreso>

					<cfset var listaCampos = valuelist(local.qCamposViajesRegreso.id_campo)>
					<cfset var j = 1>
					<cfset var sAgrupacion = {}>

					<!--- AQU? VAN LOS COMBOS DEL FILTRO --->
					<cfset var cantidad = 0>
					<cfif local.qCantidadViajesRegresoGestionados.cantidad neq ''>
						<cfset cantidad = local.qCantidadViajesRegresoGestionados.cantidad>
					</cfif>

					<cfset var sComboSiNo = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'>
					<cfset var sComboTipoTransporte = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboPaises = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboPoblacionesSalida = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboPoblacionesLLegada = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboProvinciasSalida = '-:#objTraducciones.getString(1268)#'>
					<cfset var sComboProvinciasLLegada = '-:#objTraducciones.getString(1268)#'>

					<cfset var sComboTransportes = '-:#objTraducciones.getString(1268)#'>

					<cfset var sCombo = ''>
					<cfloop from="1" to="#cantidad#" index="j">
						<cfset sAgrupacion = {}>
						<cfset sAgrupacion.startColumnName = 'VIAJE_REGRESO_#j#_#local.qCamposViajesRegreso.id_campo#'>

						<cfloop query="local.qCamposViajesRegreso">
							<cfset i++>
							<cfset s.colModel[i] = {width=90,
							                               name='VIAJE_REGRESO_#j#_#local.qCamposViajesRegreso.id_campo#',
							                               label='#nombreCampo#',align='center', sortable=false,
							                               editable=true,search=true}>
							<!--- AQU? VAN LOS COMBOS DEL FILTRO --->
							<cfif local.qCamposViajesRegreso.id_campo is 61>
								<cfif listlen(sComboTipoTransporte, ';') is 1>
									<cfquery name="local.qDatos" datasource="#application.datasource#">
										select id_tipo_transporte, texto_#session.id_idioma_relleno# as texto
										from vTiposTransportes
										order by texto
									</cfquery>
									<cfloop query="local.qDatos">
										<cfset sComboTipoTransporte = listAppend(sComboTipoTransporte,
										                                         '#id_tipo_transporte#:#texto#',';')>
									</cfloop>
								</cfif>
							<cfelseif listFind('79,82', local.qCamposViajesRegreso.id_campo) gt 0>
								<cfif listlen(sComboPaises, ';') is 1>
									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPaises = objLocalizaciones.getListaPaises()>
									<cfloop query="local.qPaises">
										<cfset sComboPaises = listAppend(sComboPaises, '#id_pais#:#nombre#', ';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesRegreso.id_campo is 84>
								<cfif listlen(sComboPoblacionesLLegada, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel2 as id_nivel2
										from vTodosTransportesRegreso ttll inner join vLocalizaciones l on
										ttll.llegada_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPoblaciones = objLocalizaciones.getNombrePoblaciones(valuelist(local.qDistintasLocalizaciones.id_nivel2))>
									<cfloop query="local.qPoblaciones">
										<cfset sComboPoblacionesLLegada = listAppend(sComboPoblacionesLLegada,
										                                             '#id_nivel2#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesRegreso.id_campo is 81>
								<cfif listlen(sComboPoblacionesSalida, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel2 as id_nivel2
										from vTodosTransportesRegreso ttll inner join vLocalizaciones l on
										ttll.salida_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qPoblaciones = objLocalizaciones.getNombrePoblaciones(valuelist(local.qDistintasLocalizaciones.id_nivel2))>
									<cfloop query="local.qPoblaciones">
										<cfset sComboPoblacionesSalida = listAppend(sComboPoblacionesSalida,
										                                            '#id_nivel2#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesRegreso.id_campo is 83>
								<cfif listlen(sComboProvinciasLLegada, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel1 as id_nivel1
										from vTodosTransportesRegreso ttll inner join vLocalizaciones l on
										ttll.llegada_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qProvincias = objLocalizaciones.getNombreProvincias(valuelist(local.qDistintasLocalizaciones.id_nivel1))>
									<cfloop query="local.qProvincias">
										<cfset sComboProvinciasLLegada = listAppend(sComboProvinciasLLegada,
										                                            '#id_nivel1#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesRegreso.id_campo is 80>
								<cfif listlen(sComboProvinciasSalida, ';') is 1>
									<cfquery name="local.qDistintasLocalizaciones" datasource="#application.datasource#">
										select distinct id_nivel1 as id_nivel1
										from vTodosTransportesRegreso ttll inner join vLocalizaciones l on
										ttll.salida_id_localizacion = l.id_localizacion
										where idEvento(id_participante) = #this.objEvento.id_evento#
									</cfquery>

									<cfset var objLocalizaciones = createObject('component',
									                                            'default.admin.model.localizaciones')>
									<cfset var qProvincias = objLocalizaciones.getNombreProvincias(valuelist(local.qDistintasLocalizaciones.id_nivel1))>
									<cfloop query="local.qProvincias">
										<cfset sComboProvinciasSalida = listAppend(sComboProvinciasSalida,
										                                           '#id_nivel1#:#nombre#',';')>
									</cfloop>
								</cfif>
							<cfelseif local.qCamposViajesRegreso.id_campo is 62>
								<cfif listlen(sComboTransportes, ';') is 1>
									<cfquery name="local.qTransportes" datasource="#application.datasource#">
										select
										 distinct tet.id_transporte, nombreTransporte(tet.id_transporte, '#session.id_idioma_relleno#
										') as nombre
										from
										 vTransportesEventosTrayectos tet inner join vTransportes t on t.id_trayecto =
										tet.id_trayecto
										where trayecto = 'LLEGADA'
										and idEvento(id_participante) = #this.objEvento.id_evento#order by nombre
									</cfquery>
									<cfloop query="local.qTransportes">
										<cfset sComboTransportes = listAppend(sComboTransportes, '#id_transporte#:#nombre#', ';')>
									</cfloop>
								</cfif>
							</cfif>

							<cfswitch expression="#local.qCamposViajesRegreso.id_campo#">
								<cfcase value="61,62,70,72,74,75,77,79,80,81,82,83,84,85,86" delimiters=",">
									<cfif listfind('70,72,74,75,77,85,85,86', local.qCamposViajesRegreso.id_campo)>
										<cfset sCombo = sComboSiNo>
									<cfelseif local.qCamposViajesRegreso.id_campo is 62>
										<cfset sCombo = sComboTransportes>
									<cfelseif local.qCamposViajesRegreso.id_campo is 61>
										<cfset sCombo = sComboTipoTransporte>
									<cfelseif listfind('82,79', local.qCamposViajesRegreso.id_campo) gt 0>
										<cfset sCombo = sComboPaises>
									<cfelseif listfind('81', local.qCamposViajesRegreso.id_campo) gt 0>
										<cfset sCombo = sComboPoblacionesSalida>
									<cfelseif listfind('84', local.qCamposViajesRegreso.id_campo) gt 0>
										<cfset sCombo = sComboPoblacionesLLegada>
									<cfelseif listfind('80', local.qCamposViajesRegreso.id_campo) gt 0>
										<cfset sCombo = sComboProvinciasSalida>
									<cfelseif listfind('83', local.qCamposViajesRegreso.id_campo) gt 0>
										<cfset sCombo = sComboProvinciasLLegada>
									</cfif>

									<cfset var = sLocal = {stype='select', searchOptions={search=true, value='#sCombo#'}}>
									<cfset StructAppend(s.colModel[i], sLocal)>
								</cfcase>
							</cfswitch>

						</cfloop>

						<cfset sAgrupacion.numberOfColumns = local.qCamposViajesRegreso.recordcount>
						<cfset sAgrupacion.titleText = objTraducciones.getString(2222)>

						<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
					</cfloop>
				</cfif>
			</cfcase>

			<cfdefaultcase>
				<cfif id_campo is 259>
					<!--- LISTADO DE MULTIACTIVIDADES --->

					<cfset var columnasCampo259 = cargarColumnasInforme259(this.objEvento.id_evento, id_campo)>

					<!--- PONEMOS LAS COLUMNAS --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo259.colModel.len()#" index="jj">
						<cfset i++>
						<cfset s.ColModel[i] = columnasCampo259.colModel[jj]>
					</cfloop>

					<!--- PONEMOS LAS AGRUPACIONES --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo259.agrupaciones.len()#" index="jj">
						<cfset s.agrupacionColumnas.append(columnasCampo259.agrupaciones[jj])>
					</cfloop>
				<cfelseif id_campo is 169>
					<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampoTexto(id_campo, nombreCampo)>
				<cfelseif id_campo is 170>
					<!--- CANTIDAD DEL ULTIMO PAGO POR TRANSFERENCIA --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampoTexto(id_campo, nombreCampo)>
				<cfelseif arrayFind([133,134,135], id_campo) gt 0>
					<!---
					    133 = PROPIETARIOS DEL PARTICIPANTE
					    134 = USUARIO ALTA
					    135 = USUARIO MODIF
					 --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo133_134_135(id_campo, nombreCampo)>
					<cfif id_campo is 133>
						<cfset session.noCodificar.append(i)>
					</cfif>
				<cfelseif id_campo is 168>
					<cfset i++>
					<cfset s.coLmodel[i] = cargarColumnaInformeCampoTexto(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif id_campo is 154>
					<!--- OPCIONES ADICIONALES SELECCIONADAS --->
					<cfset var listaOpcionesAdicionales = objEvento.listaOpcionesAdicionales()>
					<cfset var objOpcion = ''>
					<cfset var id_opcion = ''>
					<cfloop list="#listaOpcionesAdicionales#" index="id_opcion">
						<cfset objOpcion = objEvento.getOpcionAdicional(id_opcion)>
						<cfset i++>
						<cfset s.colModel[i] = cargarColumnaInformeCampo154(id_opcion, objOpcion.Titulo(session.id_idioma))>
					</cfloop>
				<cfelseif id_campo is 159>
					<!--- LISTA DE ENTRADAS COMPRADAS --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo159(id_campo, nombreCampo)>
				<cfelseif id_campo is 247>
					<!--- CANTIDAD DE ENTRADAS COMPRADAS --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo247(id_campo, nombreCampo)>

				<cfelseif id_campo is 99>
					<!--- LISTA DE PRODUCTOS --->
					<cfset var listaGrupos = objEvento.listaGruposProductosPorNombre()>
					<cfset var objGrupo = ''>
					<cfset var id_grupo = ''>

					<cfset var listaProductos = ''>
					<cfset var objProducto = ''>
					<cfset var id_producto = ''>
					<cfset var sAgrupacion = {}>

					<cfloop list="#listaGrupos#" index="id_grupo">
						<cfset objGrupo = objEvento.getGrupoProductos(id_grupo)>
						<cfset listaProductos = objGrupo.listaProductosPorNombre()>
						<cfif listlen(listaProductos) gt 0>
							<cfloop list="#listaProductos#" index="id_producto">
								<cfset objProducto = objGrupo.getProducto(id_producto)>

								<cfset sAgrupacion = {}>
								<cfset sAgrupacion.startColumnName = 'PROD_COMPRAR_#id_producto#'>

								<cfset i++>
								<cfset s.colModel[i] = {width=75, name='PROD_COMPRAR_#id_producto#',
								                                label='#objTraducciones.getString(958)#',align='center',
								                                sortable=true,editable=true, stype='select', search=true,
								                                searchOptions={value='-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'}}>

								<cfset i++>
								<cfset s.colModel[i] = {width=75, name='PROD_VENDER_#id_producto#',
								                                label='#objTraducciones.getString(959)#',align='center',
								                                sortable=true,editable=true, stype='select', search=true,
								                                searchOptions={value='-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'}}>

								<cfset i++>
								<cfset s.colModel[i] = {width=75, name='PROD_COLABORAR_#id_producto#',
								                                label='#objTraducciones.getString(960)#',align='center',
								                                sortable=true,editable=true, stype='select', search=true,
								                                searchOptions={value='-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'}}>

								<cfset sAgrupacion.numberOfColumns = 3>
								<cfset sAgrupacion.titleText = objProducto.nombre>
								<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
							</cfloop>
						</cfif>
					</cfloop>
				<cfelseif id_campo is 242>
					<!---MODALIDAD DE PARTICIPACION --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo242(id_campo, nombreCampo)>

				<cfelseif id_campo is 5>
					<!--- LISTA DE ACTIVIDADES --->
					<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
					<cfset var objGrupo = ''>
					<cfset var id_grupo = ''>

					<cfset var listaActividades = ''>
					<cfset var objActividad = ''>
					<cfset var id_actividad = ''>
					<cfset var sAgrupacion = {}>
					<cfloop list="#listaGrupos#" index="id_grupo">
						<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
						<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
						<cfif listlen(listaActividades) gt 0>
							<cfset sAgrupacion = {}>
							<cfset sAgrupacion.startColumnName = 'ACT_#listfirst(listaActividades)#'>

							<cfloop list="#listaActividades#" index="id_actividad">
								<cfset objActividad = objGrupo.getActividad(id_actividad)>
								<cfset i++>
								<cfset s.colModel[i] =
								{
									width=150,
									name='ACT_#objActividad.id_actividad#',
									label='#objActividad.nombre#',
									align='center',
								    sortable=true,
								    editable=true,
								    stype='select',
								    search=true,
									searchOptions=
									{
										value='-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#'
									}
								}>
							</cfloop>
							<cfset sAgrupacion.numberOfColumns = listlen(listaActividades)>
							<cfset sAgrupacion.titleText = nombreCampo & ": " & objGrupo.nombre>
							<cfset arrayAppend(s.agrupacionColumnas, sAgrupacion)>
						</cfif>
					</cfloop>
				<cfelseif id_campo is 264>
					<!--- LISTA DE ACTIVIDADES SELECCIONADAS CON PRECIO --->
					<cfset var columnasCampo264 = cargarColumnasInforme264(this.objEvento, id_campo)>

					<!--- PONEMOS LAS COLUMNAS --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo264.colModel.len()#" index="jj">
						<cfset i++>
						<cfset s.ColModel[i] = columnasCampo264.colModel[jj]>
					</cfloop>

					<!--- PONEMOS LAS AGRUPACIONES --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo264.agrupaciones.len()#" index="jj">
						<cfset s.agrupacionColumnas.append(columnasCampo264.agrupaciones[jj])>
					</cfloop>
				<cfelseif id_campo is 265>
					<!--- LISTA DE ACTIVIDADES SELECCIONADAS CON PRECIO Y PAGADAS --->
					<cfset var columnasCampo265 = cargarColumnasInforme265(this.objEvento, id_campo)>

					<!--- PONEMOS LAS COLUMNAS --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo265.colModel.len()#" index="jj">
						<cfset i++>
						<cfset s.ColModel[i] = columnasCampo265.colModel[jj]>
					</cfloop>

					<!--- PONEMOS LAS AGRUPACIONES --->
					<cfset var jj = 1>
					<cfloop from="1" to="#columnasCampo265.agrupaciones.len()#" index="jj">
						<cfset s.agrupacionColumnas.append(columnasCampo265.agrupaciones[jj])>
					</cfloop>
				<cfelseif arrayFind([6,109,110,111,112], id_campo) gt 0>
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo6_109_110_111_112_119(id_campo, nombreCampo)>
				<cfelseif listfind('119', id_campo)>
					<!--- FECHA DE LA FACTURA --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo119(id_campo, nombreCampo)>
				<cfelseif listfind('118', id_campo)>
					<!--- NÚMERO DE LA FACTURA --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo118(id_campo, nombreCampo)>
				<cfelseif listfind('238', id_campo)>
					<!--- CONCEPTOS PAGADOS --->
					<!---PARA EL BUSCADOR COGEMOS LOS CONCEPTOS QUE HA PAGADO ALGUIEN--->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo238(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('239', id_campo)>
					<!--- CONCEPTOS NO PAGADOS --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo239(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('240', id_campo)>
					<!--- MEDIO DE PAGO --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo240(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('235', id_campo)>
					<!--- PAGO REALIZADO POR TPV --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo235(id_campo, nombreCampo)>
				<cfelseif listfind('157', id_campo)>
					<!--- FACTURA GENERADA --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo157(id_campo, nombreCampo)>
				<cfelseif listfind('254', id_campo) gt 0>
					<!--- RESULTADOS DE PAGOS POR TPV PAYPAL --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo254(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('160', id_campo) gt 0>
					<!--- RESULTADOS DE PAGOS POR TPV REDSYS --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo160(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('255', id_campo) gt 0>
					<!--- DOBLE OPT-IN --->
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo255(id_campo, nombreCampo)>
				<cfelseif listfind('158', id_campo)>
					<!--- SE HA ENVIADO LA FACTURA --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo158(id_campo, nombreCampo)>
				<cfelseif listfind('236', id_campo)>
					<!--- CODIGO DE PARTICIPANTE --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo236(id_campo, nombreCampo)>

				<cfelseif listfind('559', id_campo)>
					<!--- OBSERVACIONES --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo559(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('560', id_campo)>
					<!--- OBSERVACIONES --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo560(id_campo, nombreCampo)>
					<cfset session.noCodificar.append(i)>
				<cfelseif listfind('7', id_campo)>
					<!--- TIPO DE PARTICIPANTE --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo7(id_campo, nombreCampo)>
				<cfelseif listfind('8,131', id_campo)>
					<!--- fecha de alta --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo8_131(id_campo, nombreCampo)>
				<cfelseif (id_campo is 9)>
					<!--- ID. --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo9(id_campo, nombreCampo)>
				<cfelseif listfind('3,4', id_campo)>
					<!--- INSCRITO(3), PAGADO(4) --->
					<cfset i++>
					<cfset s.colModel[i] = cargarColumnaInformeCampo3_4(id_campo, nombreCampo)>
				<cfelseif listFind('248', id_campo) gt 0>
					<cfset i++>
					<cfset s.ColModel[i] = cargarColumnaInformeCampo248(id_campo, nombreCampo, objEvento.id_evento)>
				<cfelse>

					<cfif listfind('2,3', id_tipo_campo) gt 0>
						<cfquery name="local.qValores" datasource="#application.datasource#">
							select v.id_valor, titulo
							from vValoresIdiomas vi inner join vValores v
								on vi.id_valor = v.id_valor
							where id_campo = <cfqueryparam value="#id_campo#" cfsqltype="cf_sql_integer">
								and id_idioma = <cfqueryparam value="#session.id_idioma_relleno#" cfsqltype="cf_sql_char">
							order by orden
						</cfquery>

						<!--- CLAVE:TEXTO --->
						<cfset var sValores = '-:#objTraducciones.getString(1268)#;:#objTraducciones.getString(4399)#'>
						<cfset var sValores = '-:#objTraducciones.getString(4399)#'>
						<cfloop query="local.qValores">
							<cfset sValores = listAppend(sValores, '#id_valor#:#titulo#', ';')>
						</cfloop>

						<cfset i++>
						<cfif listFind('2,3', id_tipo_campo) gt 0>
							<cfset var sFunc = 'dataInitMultiselect'>

							<cfset s.colModel[i] = {width=150, name='CAMPO_#id_campo#', label='#nombreCampo#',
							                               align='left',sortable=true, editable=true, search=true,
							                               stype='select',
							                               searchOptions={sopt=['eq', 'ne'], value=#sValores#, attr={multiple='multiple', size=4}, dataInit=#sFunc#}}>
						<cfelse>
							<cfset s.colModel[i] = {width=150, name='CAMPO_#id_campo#', label='#nombreCampo#',
							                               align='left',sortable=true, editable=true, search=true,
							                               stype='select',searchOptions={value=#sValores#}}>
						</cfif>
					<cfelseif (id_tipo_campo is 4)>
						<cfset var tmp_ancho = 150>
						<cfif id_tipo_campo_fijo eq 41>
							<cfset var tmp_ancho = 80>
						</cfif>

						<cfset var combo = ''>
						<cfif id_tipo_campo_fijo is 42>
							<!--- FORMA DE PAGO SELECCIONADA EN EL FORMULARIO --->
							<cfset combo = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(3231)#;2:#objTraducciones.getString(3232)#'>
						<cfelse>
							<cfset combo = '-:#objTraducciones.getString(1268)#;1:#objTraducciones.getString(1236)#;0:#objTraducciones.getString(1237)#;null:#objTraducciones.getString(4399)#'>
						</cfif>

						<cfset i++>
						<cfset s.colModel[i] = {width=#tmp_ancho#, name='CAMPO_#id_campo#', label='#nombreCampo#',
						                              align='center',sortable=true, editable=true, search=true,
						                              stype='select',searchOptions={value='#combo#'}}>

					<cfelseif (id_tipo_campo is 8)>
						<cfset i++>
						<cfset var formatter = 'fmtLink'>
						<cfset s.colModel[i] = {width=150, name='CAMPO_#id_campo#', label='#nombreCampo#',
						                              align='left',sortable=true, editable=true, search=true,
						                              formatter=formatter,formatoptions={target='_blank'}}>
					<cfelse>
						<cfif (id_encapsulado is 9)>
							<cfset i++>
							<cfset session.posicionesDocumentosEnInforme = listAppend(session.posicionesDocumentosEnInforme,
							                                                          i)>

							<cfset var formatter = 'fmtLink'>
							<cfset s.colModel[i] = {width=150, name='CAMPO_#id_campo#', label='#nombreCampo#',
							                               align='left',sortable=true, editable=true, search=true,
							                               formatter=formatter,formatoptions={target='_blank'}}>
						<cfelse>

							<cfset i++>
							<cfset s.colModel[i] = {width=150, name='CAMPO_#id_campo#', label='#nombreCampo#',
							                               align='left',sortable=true, editable=true, search=true}>

							<cfif arrayFind([246], id_campo) gt 0>
								<cfset session.noCodificar.append(i)>
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			</cfdefaultcase>
		</cfswitch>

	</cfloop>

	<cfset s.id_informe = arguments.rc.id_informe>
	<cfset s.ok = true>
	<!---<cfcatch type="any">
	    <cfset s.ok = false>
	       <cfset s.message = cfcatch.message>
	    <cfinclude template="/admin/helpers/funciones.cfm">
	    <cfset enviarCorreoError('cargarColumnasInforme', cfcatch)>
	</cfcatch>
	</cftry>--->
	<cfreturn s>
</cffunction> --->

<cffunction name="generarConsultaInforme" access="public" returntype="struct" output="false">
	<cfargument name="id_informe" required="true"/>
	<cfargument name="paraExcel" required="true" refault="false"/>
	<cfargument name="listaParticipantes" required="true" refault=""/>
	<cfargument name="rc" required="true"/>

	<cftimer label="generarConsultaInforme">
	    <!--- <cfset var objEvento  = this.objevento> --->
		<cfset var id_informe = arguments.id_informe>
		<!--- <cfset var objUsuario = this.objUsuario> --->

		<!--- CARGAMOS LOS CAMPOS DEL INFORME --->
		<cfquery name="local.qCamposInforme" datasource="#application.datasource#">
			select titulo , id_campo , id_agrupacion , id_tipo_campo_fijo
			from
			(
				select titulo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion, ci.id_tipo_campo_fijo
				from vInformesCamposFormularios ic inner join vCampos ci on ic.id_campo = ci.id_campo
				where id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
					and id_informe = <cfqueryparam value="#arguments.id_informe#" cfsqltype="cf_sql_integer">

				union

				select titulo, ic.orden, ic.id_campo, id_tipo_campo, ic.id_agrupacion, 0 as id_tipo_campo_fijo
				from vInformesCamposFormularios ic inner join vCamposAgrupacionesAutomaticas ci on ic.id_campo =
					ci.id_campo
				where id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
					and id_informe = <cfqueryparam value="#arguments.id_informe#" cfsqltype="cf_sql_integer">
			) a
			order by orden, id_campo
		</cfquery>

		<!--- SI VENIMOS DEL GESTOR DE PONENTES FORZAMOS A PONER EL TIPO DE PARTICIPANTE --->
		<cfif structkeyexists(arguments.rc, "id_objGestorGrid") and (arguments.rc.id_objGestorGrid is 'objPonentes') and (listFind(valueList(local.qCamposInforme.id_campo), 7) is 0)>
			<!--- ES EL DE PONENTES Y NO TIENE PUESOT EN EL INFORME EL TIPO DE PARTICIPANTE. LO PONEMOS A MANO EN LA QUERY --->
			<cfset queryAddRow(local.qCamposInforme, ['tipo_de_participante', 7, 1,0])>
		</cfif>

		<cfset var listaCampos = valuelist(local.qCamposInforme.id_campo)>

		<cfset var sColumnas                          = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasInnerWhere                = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereAlojamientos         = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereViajesIda            = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereViajesRegreso        = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereEstadisticaEnvios    = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereEstadisticaRegistros = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereAgendas              = createObject("java", "java.util.LinkedHashMap").init()>

		<!---Julia--->
		<cfset var sColumnasWhereAreaPrivada    = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var sColumnasWhereComunicaciones = createObject("java", "java.util.LinkedHashMap").init()>

		<cfset var sColumnasWhereSeating  = {}>
		<cfset var sColumnasWhereEntradas = createObject("java", "java.util.LinkedHashMap").init()>

        

		<cfset var valor = ''>
		<cfset var i = 0>

		<cfparam name="arguments.rc.id_envio" default="0">

		<!--- <cftry> --->
		<cfset var alojamientosPuestos  = false>
		<cfset var viajesIdaPuestos     = false>
		<cfset var viajesRegresoPuestos = false>
		<!--- <cfset var objGeneradorColumnas = createObject('component', 'default.admin.model.informes.generadorColumnas').init(this.objEvento.id_evento, session.language, session.language)> --->
		
		<cfloop query="local.qCamposInforme">

			<cfswitch expression="#id_agrupacion#">

				<!--- ALOJAMIENTOS GESTIONADOS --->
				<!--- <cfcase value="3">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion3.cfm">
				</cfcase>

				<!--- VIAJES DE IDA GESTIONADOS --->
				<cfcase value="4">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion4.cfm">
				</cfcase>

				<!--- VIAJES DE VUELTA GESTIONADOS --->
				<cfcase value="5">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion5.cfm">
				</cfcase>

				<!--- ESTADISTICAS ENVIOS --->
				<cfcase value="6">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion6.cfm">
				</cfcase>

				<!--- ESTADISTICAS REGISTROS EN EL EVENTO --->
				<cfcase value="7">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion7.cfm">
				</cfcase>

				<!--- HORAS DE ASISTENCIA --->
				<cfcase value="8">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion8.cfm">
				</cfcase>

				<!--- COMUNICACIONES --->
				<cfcase value="25">
					<cfinclude template="/default/admin/helpers/generarConsultaInformes/generarConsultaInformeAgrupacion25.cfm">
				</cfcase>

				<!--- AGENDAS --->
				<cfcase value="27">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion27.cfm">
				</cfcase>
				
				<!--- MENSAJERIA --->
				<cfcase value="36">
					<cfinclude template="/default/admin/helpers/generarConsultaInformeAgrupacion36.cfm">
				</cfcase>

				<!--- ESTADISTICAS REGISTROS EN EL EVENTO --->
				<cfcase value="37">
					<cfinclude template="/default/admin/helpers/generarConsultaInformes/generarConsultaInformeAgrupacion37.cfm">
				</cfcase>

				<!--- ENTRADAS --->
				<cfcase value="38">
					<cfinclude template="/default/admin/helpers/generarConsultaInformes/generarConsultaInformeAgrupacion38.cfm">
				</cfcase>

				<!---Julia--->
				<!--- AREA PRIVADA --->
				<cfcase value="180">
					<cfinclude template="/default/admin/helpers/generarConsultaInformes/generarConsultaInformeAgrupacion180.cfm">
				</cfcase> --->

				<!--- SEATING --->
			<!--- 	<cfcase value="181">
					<cfset i++>
					<cfset sColumnas[i] = objGeneradorColumnas.generarUnaColumnaSeating(id_campo, titulo)>

					<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
						<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
						<cfset sColumnasWhereSeating[i] = objGeneradorColumnas.generarUnaColumnaWhereSeating(id_campo, valor)>
					</cfif>
				</cfcase> --->

				<cfdefaultcase>
					<cfinclude template="/includes/helpers/GenerarConsultaInformeAgrupacionRestoAgrupaciones.cfm">
				</cfdefaultcase>
			</cfswitch>

		</cfloop>

		<cfset var ponerGroup = false>
		<cfset var sPartesConsulta = {}>
		<cfoutput>
			<cfset var aAux = []>
			<cfif not arguments.paraExcel>
				<cfset arrayAppend(aAux, 'p.id_participante  as jr_random2')>
				<cfset arrayAppend(aAux, 'p.id_participante  as jr_random')>
				<cfset arrayAppend(aAux, 'id_formulario')>
			<cfelse>
				<cfset arrayAppend(aAux, 'p.id_participante')>
			</cfif>

			<cfloop collection="#sColumnas#" item="id_columna">
				<cfset aAux.append(detectarNombreColumnaDuplicado(aAux, sColumnas[id_columna]))>
			</cfloop>

			<cfset sSelect = "select distinct " & arrayToList(aAux)>

			<cfsaveContent variable="sFrom">
				from vParticipantes p
				<!--- PARA VER SI UN PARTICIPANTE ESTÁ DUPLICADO --->
				<cfif listfind(listaCampos, 244) gt 0>
					left join
					(
						select email_participante email_participanteDuplicado, count(*) as cantidadDuplicados
						from vParticipantes p
						where id_evento = #objEvento.id_evento#
						<cfif arguments.rc._search>
							<!--- GENERA LOS FILTROS DEL BUSCADOR --->
							<cfloop collection="#sColumnasInnerWhere#" item="id_columna">
								<cfif findnocase('cantidadDuplicados', sColumnasInnerWhere[id_columna]) is 0>
									and #sColumnasInnerWhere[id_columna]#
								</cfif>
							</cfloop>
						</cfif>
						GROUP BY email_participanteDuplicado
						HAVING COUNT(*) > 1
						order by null
					) pDuplicados
					on p.email_participante = pDuplicados.email_participanteDuplicado
				</cfif>

				<!--- PERMISO PARA VER A TODOS LOS PARTICIPANTES --->

				<cfif not objUsuario.tengoPermiso(263) or (listfind(listaCampos, 133) gt 0)>
					<cfif (listfind(listaCampos, 133) gt 0) and (objUsuario.tengoPermiso(263))>
						left
					<cfelse>
						inner
					</cfif>
					join vParticipantesUsuarios pu on p.id_participante = pu.id_participante
					<cfif not objUsuario.tengoPermiso(263)>
						and pu.id_usuario = #objusuario.id_usuario#
					</cfif>
					<cfset ponerGroup = true>
				</cfif>

				<cfif arguments.rc._search>
					<!---PARA LOS REGISTROS EN EVENTO POR DÍAS --->
					<cfif listfind(listaCampos, 149) gt 0>
						<cfset var algunValorOK = false>
						<cfset var dias = structSort(objEvento.calendario.dias, 'textnocase', 'asc', 'diaOrden')>
						<cfset var listaDias = arrayToList(dias)>

						<cfloop list="#listaDias#" index="id_dia">
							<cfif structkeyexists(arguments.rc, "REGISTROSDIAS_#id_dia#")>
								<cfset valor = evaluate("arguments.rc.REGISTROSDIAS_#id_dia#")>
								<cfset algunValorOK = listfind('1', valor)>
								<cfif algunValorOK>
									<cfbreak>
								</cfif>
							</cfif>
						</cfloop>

						<cfif algunValorOK>
							inner join vAcredRegistrosEntrada are on p.id_participante = are.id_participante
						</cfif>
					</cfif>

					<!--- CUPONES USADOS POR LOS PARTICIPANTES --->
					<cfif listFind(listaCampos, 246) gt 0>
						<cfif structkeyexists(arguments.rc, "CAMPO_246")>
							<cfset valor = evaluate("arguments.rc.CAMPO_246")>
							<cfif trim(valor) neq ''>
							 inner join vParticipantesCuponesUsados pcu
    						on p.id_participante = pcu.id_participante
							</cfif>
						</cfif>
					</cfif>

					<cfif listfind(listaCampos, 150) gt 0>
						<cfset var algunValorOK = false>
						<cfset var dias = structSort(objEvento.calendario.dias, 'textnocase', 'asc', 'diaOrden')>
						<cfset var listaDias = arrayToList(dias)>

						<cfloop list="#listaDias#" index="id_dia">
							<cfif structkeyexists(arguments.rc, "FECHAREGISTROSDIAS_#id_dia#")>
								<cfset valor = evaluate("arguments.rc.FECHAREGISTROSDIAS_#id_dia#")>
								<cfset algunValorOK = listfind('1', valor)>
								<cfif algunValorOK>
									<cfbreak>
								</cfif>
							</cfif>
						</cfloop>

						<cfif algunValorOK>
							inner join vAcredRegistrosEntrada are on p.id_participante = are.id_participante
								and are.id_evento = #objEvento.id_evento#
						</cfif>
					</cfif>

					<!---PARA LAS RESERVAS DE HOTELES --->
					<cfif listfind(listaCampos, 140) gt 0>
						<cfset valor = evaluate('arguments.rc.CAMPO_140')>
						<cfif listfind('1', valor)>
							inner join vParticipantesReservasHabitaciones prh on p.id_participante = prh.id_participante
						</cfif>
					</cfif>

					<!---PARA LOS CONCEPTOS DE PAGO --->
					<cfif (listfind(listaCampos, 238) gt 0 and structkeyexists(arguments.rc, 'CAMPO_238')) or (listfind(listaCampos, 239) gt 0 and structkeyexists(arguments.rc, 'CAMPO_239')) or (listfind(listaCampos, 240) gt 0 and structkeyexists(arguments.rc, 'CAMPO_240'))>
						-- inner join resultadosDePagos rp on p.id_participante = rp.id_participante
					</cfif>

					<!---PARA LAS MODALIDADES SELECCIONADAS --->
					<cfif (listFind(listaCampos, 242) gt 0) and structkeyexists(arguments.rc, "MOD_242")>
						<cfset valor = evaluate("arguments.rc.MOD_242")>
						<cfif isArray(valor) or ((valor neq '') and (valor neq '-'))>
							inner join vModalidadesSeleccionadas modSel on modSel.id_participante = p.id_participante
						</cfif>
					</cfif>

					<!---PARA LA CANTIDAD DE COMUNICACIONES DE UN PARTICIPANTE --->
					<cfif listfind(listaCampos, 241) gt 0 AND ISDEFINED("")>
						<cfset valor = evaluate('arguments.rc.CAMPO_241')>
						<cfif listFind(valor, 1) gt 0>
							inner join
							vParticipantesComunicaciones pc2 on pc2.id_participante = p.id_participante
						</cfif>
					</cfif>

					<!--- EMAILS ENVIADOS --->
					<cfif listFind(listaCampos, 151) gt 0 and structkeyexists(arguments.rc, "CAMPO_151")>
						<cfset valor = evaluate('arguments.rc.CAMPO_151')>
						<cfif isArray(valor)>
							<cfset valor = arrayToList(valor)>
						</cfif>
						<cfif valor neq '' and valor neq '-' and valor neq '0'>
							inner join vComRegEnvio cre on cre.id_participante = p.id_participante
								and cre.cre_id_evento = p.id_evento
						</cfif>
					</cfif>

					<!--- ENCUESTAS REALIZADAS --->
					<!--- <cfif listFInd(listaCampos, 245) gt 0 and isdefined("arguments.rc.CAMPO_245")>
						<cfset valor = evaluate('arguments.rc.CAMPO_245')>
						<cfif isArray(valor)>
							<cfset valor = arrayToList(valor)>
						</cfif>

						<cfif valor neq '' and valor neq '-' and valor neq 0>
							inner join vEncuestaRealizada er on er.id_participante = p.id_participante
						</cfif>
					</cfif> --->

					<!--- AZAFATA/ACREDITACION --->
					<cfif listFind(listaCampos, 152) gt 0 and structkeyexists(arguments.rc, "CAMPO_152")>
						<cfset valor = evaluate('arguments.rc.CAMPO_152')>
						<cfif isArray(valor)>
							inner join vAcredRegistrosEntrada are on are.id_participante = p.id_participante
						</cfif>
					</cfif>

					<!--- LISTA DE ACTIVIDADES AGENDADAS --->
					<!---<cfif listFind(listaCampos, 153) gt 0>
						<cfset var listaActividades = structKeyList(objEvento.actividades())>
						<cfset algunaActividadOK = false>
						<cfloop list="#listaActividades#" index="id_actividad">
							<cfif isdefined('arguments.rc.ACTGEN_#id_actividad#')>
								<cfset valor = evaluate('arguments.rc.ACTGEN_#id_actividad#')>
								<cfset algunaActividadOK = valor neq '-'>

								<cfif algunaActividadOK>
									<cfbreak>
								</cfif>
							</cfif>
						</cfloop>

						<cfif algunaActividadOK>
							<!---inner join vActividadesGeneradas actGen on p.id_participante = actGen.id_participante--->
						</cfif>
					</cfif>--->

					<!--- PARA LAS FACTURAS EMITIDAS --->
					<cfif listFind(listaCampos, 157) gt 0 and structkeyexists(arguments.rc, "CAMPO_157")>
						<cfset valor = evaluate('arguments.rc.CAMPO_157')>
						<!--- COMENTADO PORQUE TARDA MENOS SIN EL INNER JOIN --->
						<cfif valor is 1>
							<!---inner join vFacturas vf on vf.id_participante = p.id_participante--->
						</cfif>
					</cfif>

					<!--- LISTA DE OPCIONES ADICIONALES SELECCIONADAS --->
					<cfif listFind(listaCampos, 154) gt 0>
						<cfset var listaOpcionesAdicionales = objEvento.listaOpcionesAdicionales()>
						<cfset var id_opcion = ''>
						<cfset var algunaOpcionOK = false>
						<cfloop list="#listaOpcionesAdicionales#" index="id_opcion">
							<cfif structkeyexists(arguments.rc, 'OPCION_ADICIONAL_#id_opcion#')>
								<cfset valor = evaluate('arguments.rc.OPCION_ADICIONAL_#id_opcion#')>
								<cfset algunaOpcionOK = valor neq '-'>

								<cfif algunaOpcionOK>
									<cfbreak>
								</cfif>
							</cfif>
						</cfloop>

						<cfif algunaOpcionOK>
							left join vOpcionesAdicionalesSeleccionadas opcAdic on p.id_participante = opcAdic.id_participante
						</cfif>
					</cfif>

					<!--- PARA LAS ENTRADAS --->
					<cfif listFind(listaCampos, 159) gt 0 and structkeyexists(arguments.rc, "CAMPO_159")>
						<cfset valor = evaluate('arguments.rc.CAMPO_159')>
						<cfif valor neq ''>
							inner join vParticipantesCuponesUsados pcu on pcu.participante_generador = p.id_participante
						</cfif>
					<cfelseif listFind(listaCampos, 247) gt 0 and structkeyexists(arguments.rc, "CAMPO_247")>
						<cfset valor = evaluate('arguments.rc.CAMPO_247')>
						<cfif isNumeric(valor)>
							inner join vParticipantesCuponesUsados pcu on pcu.participante_generador = p.id_participante
						</cfif>
					</cfif>
				</cfif>

				<!--- <cfif arguments.rc.id_envio neq 0>
					 inner join vComRegEnvio cre2 on p.id_participante = cre2.id_participante
						 and cre2.id_envio = #arguments.rc.id_envio#
						 and p.id_evento = #objEvento.id_evento#
						 and cre2.cre_id_evento = #objEvento.id_evento#
				</cfif> --->

				<cfif objUSuario.tipoUsuario is 8>
					<!---ES UN EVALUADOR. SOLO PUEDE VER A LOS QUE SE LE ASIGNEN POR TIPO DE COMUNICACION Y TEM?TICA --->
					inner join
					    vParticipantesComunicaciones pc ON pc.id_participante = p.id_participante
					and pc.id_comunicacion in (0#objUsuario.comunicaciones#,0)
					and pc.id_tematica in (0#objUsuario.tematicas#,0)
				</cfif>
			</cfsaveContent>
			<cfset sPartesConsulta.from = sFrom>

			<cfset sPartesConsulta.select = sSelect>
			<cfset var valor = ''>
			<cfsavecontent variable="sInnerWhere">
				where p.id_evento = #objEvento.id_evento#

				<cfif arguments.rc.id_envio neq 0>
					 <!--- inner join vComRegEnvio cre2 on p.id_participante = cre2.id_participante
						 and cre2.id_envio = #arguments.rc.id_envio#
						 and p.id_evento = #objEvento.id_evento#
						 and cre2.cre_id_evento = #objEvento.id_evento# --->
						 <!--- COGEMOS LOS PARTICIPANTES A LOS QUE SE LES HA HECHO ESE ENVIO --->
						 <cfquery name="local.qListaParticipantesEnvio" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select group_concat(id_participante) as listaParticipantes
							from vComRegEnvio
							where cre_id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
							and id_envio = <cfqueryparam value="#arguments.rc.id_envio#" cfsqltype="cf_sql_integer">
						</cfquery>

						<cfif local.qListaParticipantesEnvio.listaParticipantes neq ''>
							and p.id_participante in (#local.qListaParticipantesEnvio.listaParticipantes#)
						</cfif>
				</cfif>

				<cfif arguments.listaParticipantes neq ''>
					and p.id_participante in (#arguments.listaParticipantes#)
				</cfif>

				<cfif structkeyexists(arguments.rc, "acceso_situacion")>
                    and p.id_participante in (
                        select
                            res_id_participante
                          from acredRegistroParticipante
                          where
                            id_evento = #objEvento.id_evento#
                              and acceso > 0
                        <cfif arguments.rc.acceso_situacion neq 'EVENTO'>
                            <cfset var id_situacion = listLast(arguments.rc.acceso_situacion,'_')>
                            and id_situacion = #id_situacion#
                          </cfif>
                	)
                </cfif>

				<cfif structkeyexists(arguments.rc, "soloFacturas") and arguments.rc.soloFacturas eq 1>
                    and p.id_participante in (
                        select id_participante
                        from vFacturas
                        where
                            id_evento = #objEvento.id_evento#
                            and not isNull(fecha_pdf)
                    )
                </cfif>

				<cfif arguments.rc._search>
					<!--- GENERA LOS FILTROS DEL BUSCADOR --->
					<cfloop collection="#sColumnasInnerWhere#" item="id_columna">
						and #sColumnasInnerWhere[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereAlojamientos#" item="id_columna">
						and #sColumnasWhereAlojamientos[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereViajesIda#" item="id_columna">
						and #sColumnasWhereViajesIda[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereViajesRegreso#" item="id_columna">
						and #sColumnasWhereViajesRegreso[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereEstadisticaEnvios#" item="id_columna">
						and #sColumnasWhereEstadisticaEnvios[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereEstadisticaRegistros#" item="id_columna">
						and #sColumnasWhereEstadisticaRegistros[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereAgendas#" item="id_columna">
						and #sColumnasWhereAgendas[id_columna]#
					</cfloop>
					<!---Julia--->
					<cfloop collection="#sColumnasWhereAreaPrivada#" item="id_columna">
						and #sColumnasWhereAreaPrivada[id_columna]#
					</cfloop>
					<cfloop collection="#sColumnasWhereComunicaciones#" item="id_columna">
						and #sColumnasWhereComunicaciones[id_columna]#
					</cfloop>
					<cfloop collection="#sColumnasWhereEntradas#" item="id_columna">
						and #sColumnasWhereEntradas[id_columna]#
					</cfloop>

					<cfloop collection="#sColumnasWhereSeating#" item="id_columna">
						<cfif sColumnasWhereSeating[id_columna] neq ''>
							and #sColumnasWhereSeating[id_columna]#
						</cfif>
					</cfloop>

					<cfif structkeyexists(arguments.rc, "id_participante")>
						and p.id_participante in (#arguments.rc.id_participante#)
					</cfif>
				</cfif>
			</cfsavecontent>

			<cfset sPartesConsulta.innerWhere = sInnerWhere>

			<cfset var ordenacion = 1>
			<cfset var listaOrdenesRaros = 'id_participante,campo_8,campo_131,campo_7,campo_3,campo_111,campo_6,campo_252,campo_250,campo_126,campo_128,campo_256,campo_257,campo_258,campo_118,campo_560,campo_161'>

			<cfparam name="arguments.rc.sIdx" default="id_participante">
			<cfparam name="arguments.rc.sOrd" default="asc">

			<cfif listfindnocase(listaOrdenesRaros, arguments.rc.sIdx) gt 0>
				<cfset ordenacion = generarOrdenacionOrdenesRaros(arguments.rc, this.objEvento)>
			<cfelse>
				<cfif listfirst(arguments.rc.sidx, '_') is 'ACT'>
					<cfloop collection="#sColumnas#" item="id_columna">
						<cfif find(arguments.rc.sidx, sColumnas[id_columna]) gt 0>
							<cfset ordenacion = id_columna + 2>
							<cfbreak>
						</cfif>
					</cfloop>
				<cfelse>
					<cfparam name="arguments.rc.id_envio" default="0">
					<cfset ordenacion = generarOrdenesNormales(local.qCamposInforme, arguments.rc.sidx, arguments.rc.id_envio, objEvento.id_evento)>
				</cfif>
			</cfif>

			<cfsavecontent variable="sOrder">
				order by #ordenacion# #arguments.rc.sord#
			</cfsavecontent>
			<cfset sPartesConsulta.order = sOrder>

			<cfsavecontent variable="sGroup">
				<cfif ponerGroup>
					group by p.id_participante
				</cfif>
			</cfsavecontent>
			<cfset sPartesConsulta.group = sGroup>

			<cfsavecontent variable="s">
				#sSelect#
				#sFrom#
				#sInnerWhere#
				#sOrder#
				#sGroup#
			</cfsavecontent>
			<cfset sPartesConsulta.consulta = s>
		</cfoutput>

		<cfset sPartesConsulta.listaCampos = listaCampos>

		<!--- <cfcatch type="any">

		</cfcatch>
		</cftry> --->
	</cftimer>
	<cfreturn sPartesConsulta>
</cffunction>

<!--- <cffunction name="detectarNombreColumnaDuplicado" returntype="string" output="false">
	<cfargument name="aColumnas" required="true"/>
	<cfargument name="nombreColumna" required="true"/>

	<cfset var alias = ''>
	<cfset var alias2 = ''>
	<cfset var matches = []>
	<cfset var matches2 = []>
	<cfset var salida = ''>

	<cfloop from="1" to="#arguments.aColumnas.len()#" index="i">
		<cftry>
			<cfset matches = REMatch('"([^"]*)"', arguments.aColumnas[i])>
			<cfif matches.len() gt 0>
				<cfset alias = replacenocase(matches[1], '"', '', 'ALL')>
				<cfset matches2 = REMatch('"([^"]*)"', arguments.nombreColumna)>
				<cfif matches2.len() gt 0>
					<cfset alias2 = replacenocase(matches2[1], '"', '', 'ALL')>

					<!--- PARA ACTIVIDADES ASISTIDAS NO SE CAMBIA NADA, NO PASA NADA SI ESTÁN REPETIDOS LOS NOMBRES --->
					<cfif listFindNoCase('ACTASIS,ACTASISSALIDA', listFirst(alias2, '_')) is 0>
						<cfif alias is alias2>
							<!--- COINCIDEN --->
							<cfset tick = right(getTickCount(), 3)>
							<cfset arguments.nombreColumna = replaceNocase(arguments.nombreColumna, alias2, alias2 & "_#tick#", 'ALL')>

							<!--- parchecito para las observaciones --->
							<cfif findNoCase('vCRMObservaciones_#tick#', arguments.nombreColumna) gt 0>
								<cfset arguments.nombreColumna = replaceNoCase(arguments.nombreColumna, 'vCRMObservaciones_#tick#', "vCRMObservaciones", '')>
							</cfif>
						<cfelse>
							<!--- NO COINCIDEN --->
						</cfif>
					<cfelse>
						
					</cfif>
				</cfif>
			</cfif>
		<cfcatch type="any">
		</cfcatch>
		</cftry>
		<cfset salida = arguments.nombreColumna>
	</cfloop>

	<cfreturn salida>
</cffunction> --->
