<!--- 
	Query Service
 --->
<cfcomponent hint="Query Service" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->
	<cfproperty name="trad" inject="model:traduccion.TraduccionService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="QueryService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- 
		Limita la cantidad de registros por paginación en una consulta SQL sobre cfquery
		@total Cantidad total de registros.
		@pagina 
		@registrosPorPagina 
	--->
	<cffunction name="generarPaginacion" returntype="struct" hint="Limita la cantidad de registros por paginación en una consulta SQL sobre cfquery">
		<cfargument name="total"				required="true"	type="numeric" hint="">
		<cfargument name="pagina" 				required="true"	type="numeric" hint="">
		<cfargument name="registrosPorPagina"	required="true"	type="numeric" hint="" default="#queryLimit#">
		

		<cfscript>
			var salida = {
				total   = 0,
				records = 0,
				inicio  = 0,
				fin     = 0,
				page    = 1
			};
			
			if(arguments.registrosPorPagina GT arguments.total) {
				arguments.registrosPorPagina = arguments.total;
			}

			/* if(arguments.registrosPorPagina GT queryLimit) {
				arguments.registrosPorPagina = queryLimit;
			} */

			salida.records = arguments.total;

			// PAGINAS
			salida.page = arguments.pagina;
			if (salida.records gt 0) {				
				if(salida.records == 0) { salida.records = 1 }
				salida.total = ceiling(salida.records/arguments.registrosPorPagina);
			} else {
				salida.total = 0;
			}

			var inicio = (arguments.registrosPorPagina * arguments.pagina) - arguments.registrosPorPagina;
			var fin    = (inicio + arguments.registrosPorPagina);
			
			fin = min(fin, salida.records);

			salida.inicio = inicio;
			salida.fin = fin;

			return salida;
		</cfscript>
	</cffunction>

	<!--- 
		Obtiene los campos que se requieren mostrar para una query.
	 --->
	<cffunction name="generarConsultaInforme" returnType="string" hint="">
		<cfargument name="ids_campo" type="string" required="true" default="" displayname="Obtiene campos por ID" hint="Lista de IDs campo separados por coma">

		<cfquery name="local.qCamposInforme" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT id_campo, id_tipo_campo, id_agrupacion, id_tipo_campo_fijo
			FROM  vCampos  
			WHERE id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
			AND id_campo IN (<cfqueryparam value="#arguments.ids_campo#" CFSQLType="CF_SQL_INTEGER" list="yes">)
			ORDER BY NULL
		</cfquery>

		<cfset var listaCampos = valuelist(local.qCamposInforme.id_campo)>

		<cfset var sColumnas           = createObject("java", "java.util.LinkedHashMap").init()>	
		<cfset var sColumnasInnerWhere = createObject("java", "java.util.LinkedHashMap").init()>

		<cfreturn arraytolist(generarColumnas(local.qCamposInforme))>
	</cffunction>

	<cffunction name="generarColumnas" access="public" returntype="any" output="false">
		<cfargument name="qCamposInforme" type="Query" required="true" hint="">

		<cfset s=[]>
		<cfset w=[]>
		
		<cfinclude template="/includes/helpers/QuerysHelper.cfm">		
		<cfinclude template = "/default/admin/helpers/string.cfm">

		<cfloop query="qCamposInforme">
			<cfswitch expression="#id_campo#">
				<cfcase value="3,4,5,6,7,8,9,99,109,110,111,112,118,119,120,131,133,134,135,235,236,237,238,239,240,248,242,246,244,154,157,158,159,247,250,253,254,255,259,559,560,264,265,160,268,168,169,170">
					<cfif (arrayFind([3,4,6,7,8,9,109,110,111,112,118,119,120,131,235,236,237,238,239,240,248,244,157,158,254,255,559,560,160], id_campo) gt 0)>
						<!--- CAMPOS NORMALES --->
						<!--- <cfset ArrayAppend(s, generarUnaColumnaCampoOtros(id_campo, titulo))> --->
						<cfset ArrayAppend(s, generarUnaColumnaCampoOtros(id_campo))>
						
						<!--- <cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
							<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
							
							<cfif listfind('3,4,101', id_campo) and valor neq '-'>
								<cfset ArrayAppend(w, generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento))>
							<cfelseif listFind('112', id_campo) gt 0>
								<cfset ArrayAppend(w, generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento))>
							<cfelse>
								<cfif isArray(valor)>
									<cfset valor = "'" & arrayToList(valor, ''',''') & "'">
								</cfif>
							
								<cfset valor = replace(valor, "'-'", "-", "ALL")>
							
								<cfif valor neq '-'>
									<cfset ArrayAppend(w, generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento))>
								</cfif>
							</cfif>
						</cfif> --->
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<!--- <cfset ArrayAppend(s, trim(generarUnaColumna(titulo, id_agrupacion, id_campo, id_tipo_campo, id_tipo_campo_fijo)))> --->
					<cfset ArrayAppend(s, trim(generarUnaColumna(id_agrupacion, id_campo, id_tipo_campo, id_tipo_campo_fijo)))>
					
					<!--- <cfif listfind('2,3,4', id_tipo_campo) gt 0>
						<cfset ArrayAppend(w,  generarUnaColumnaWhere(id_agrupacion, id_campo, valor, id_tipo_campo_fijo))>
					</cfif> --->
				</cfdefaultcase>
			</cfswitch>		
		</cfloop>		

		<cfreturn s>
	</cffunction>

	<cffunction name="generarUnaColumna" access="public" returntype="string" output="false">
		<!--- <cfargument name="titulo"				type="string" 	required="true"/> --->
		<cfargument name="id_agrupacion" 		type="numeric"	required="true"/>
		<cfargument name="id_campo" 			type="numeric"	required="true"/>
		<cfargument name="id_tipo_campo" 		type="numeric"	required="true"/>
		<cfargument name="id_tipo_campo_fijo"	type="any"		required="true"/>		

		<cfset var s=''>

		<cfoutput>
			<cfswitch expression="#arguments.id_tipo_campo#">
				
				<cfcase value="1" delimiters=",">
					<!--- CAMPOS FIJOS --->
					<cfswitch expression="#arguments.id_tipo_campo_fijo#">
						<cfcase value="9">
							<!--- APELLIDOS DEL PARTICIPANTE --->
							<cfsavecontent variable="s">
								p.apellidos AS '#arguments.id_campo#'
							</cfsavecontent>
						</cfcase>

						<!--- EMAIL DEL PARTICIPANTE --->
						<cfcase value="6">
							<cfsavecontent variable="s">
								p.email_participante AS '#arguments.id_campo#'
							</cfsavecontent>
						</cfcase>

						<!--- NOMBRE DEL PARTICIPANTE --->
						<cfcase value="4">
							<cfsavecontent variable="s">
								p.nombre AS '#arguments.id_campo#'
							</cfsavecontent>
						</cfcase>

						<!--- NOMBRE DE LA EMPRESA --->
						<cfcase value="3">
							<cfsavecontent variable="s">
								p.nombre_empresa AS '#arguments.id_campo#'
							</cfsavecontent>
						</cfcase>

						<!--- CUALQUIER OTRO CAMPO FIJO --->
						<cfdefaultcase>
							<cfsavecontent variable="s">
								("CAMPO_#arguments.id_campo#") AS '#arguments.id_campo#'
							</cfsavecontent>
						</cfdefaultcase>
					</cfswitch>
				</cfcase>

				<!--- CAMPOS DE LISTA --->
				<cfcase value="2" delimiters=",">
					<cfsavecontent variable="s">
						("CAMPOLISTA_#arguments.id_campo#") AS '#arguments.id_campo#'
					</cfsavecontent>
				</cfcase>

				<!--- CAMPOS DE LISTA MULTISELECCION--->
				<cfcase value="3" delimiters=",">
					<cfsavecontent variable="s">
						("CAMPOMULTISELECCION_#arguments.id_campo#") AS '#arguments.id_campo#'
					</cfsavecontent>
				</cfcase>

				<!--- CAMPOS SI/NO --->
				<cfcase value="4">
					<cfsavecontent variable="s">
						(<cfif arguments.id_tipo_campo_fijo eq 41>
								case emailValido(p.email_participante)
									when 0 THEN '#trad.get(1237)#'
									when 1 THEN '#trad.get(1236)#'
									else '#trad.get(1237)#'
								end
							<cfelseif arguments.id_tipo_campo_fijo eq 39>
								case p.baja_newsletter
									when 0 THEN '#trad.get(1237)#'
									when 1 THEN '#trad.get(1236)#'
									else '#trad.get(1237)#'
								end
							<cfelseif arguments.id_tipo_campo_fijo eq 42>
								<!---"FORMA_DE_PAGO"--->
								<!--- case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
									when "TPV" THEN '#trad.get(3231)#'
									when "1" THEN '#trad.get(3231)#'
									when "TRANSFERENCIA" THEN '#trad.get(3232)#'
									when "2" THEN '#trad.get(3232)#'
									else '#trad.get(1237)#'
								end --->
								"FORMA_DE_PAGO_SELECCIONADA_#arguments.id_campo#"
							<cfelse>
								<!---case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
									when 0 THEN '#trad.get(1237)#'
									when 1 THEN '#trad.get(1236)#'
									else '#trad.get(4399)#'
								end--->
								"CAMPOSINO_#arguments.id_campo#"
							</cfif>) AS '#arguments.id_campo#'
					</cfsavecontent>
				</cfcase>

				<cfcase value="9">
					<cfsavecontent variable="s">
						<!---datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)--->
						("CAMPO_#arguments.id_campo#") AS '#arguments.id_campo#'
					</cfsavecontent>
				</cfcase>

				<!--- LISTA DE PROVINCIAS --->
				<cfcase value="12">
					<cfsavecontent variable="s">
					<!--- 	<cfset var objCampo=objAgrupacion.getCampo(arguments.id_campo)>
						(
							<!---case find_in_set(p.id_idioma, 'ES')--->
							<!---case DATOPARTICIPANTE2(p.id_participante, #arguments.id_campo#, p.id_evento) REGEXP '[0-9]+'
								when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
								else ifnull((select nombre from vPaisesNivel1 where id_nivel1=datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
							end--->
							"PROVICIASELECCIONADA_#arguments.id_campo#"
						) AS "#arguments.id_campo#" --->
					</cfsavecontent>
				</cfcase>

				<!--- LISTA DE POBLACIONES --->
				<cfcase value="13">
					<cfsavecontent variable="s">
					<!--- 	<cfset var objCampo=objAgrupacion.getCampo(arguments.id_campo)>
						(
							<!---case find_in_set(p.id_idioma, 'ES')--->
							<!---case DATOPARTICIPANTE2(p.id_participante, #arguments.id_campo#, p.id_evento) REGEXP '[0-9]+'
								when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
								else ifnull((select nombre from vPaisesNivel2 where id_nivel2=datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
							end--->
							"POBLACIONSELECCIONADA_#arguments.id_campo#"
						) AS "#arguments.id_campo#" --->
					</cfsavecontent>
				</cfcase>

				<cfcase value="14">
					<!--- LISTA DE PAISES --->
					<cfsavecontent variable="s">
						<!--- <cfset var objCampo=objAgrupacion.getCampo(arguments.id_campo)>
						(
							<!---case find_in_set(p.id_idioma, p.id_idioma)
								when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
								else
								ifnull((select texto_es from vPaises where id_pais=datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
							end--->

							<!---<cfquery name="local.listaPaises" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,1,0,0)#">
								select texto_es AS nombre, id_pais
								from vPaises
							</cfquery>

							case datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
								<cfloop query="#local.listaPaises#">
									when #id_pais# THEN '#nombre#'
								</cfloop>
								else datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
							end--->
							"PAISSELECCIONADO_#arguments.id_campo#"
						) AS "#arguments.id_campo#" --->
					</cfsavecontent>
				</cfcase>

				<cfcase value="16">
					<!---CAMPO RELACION ENTRE TIPOS DE PARTICIPANTES --->
					<cfsavecontent variable="s">
						(
							SELECT CONCAT(nombre_empresa, ' (', id_participante, ')')
							FROM vParticipantes
							WHERE id_participante=datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)
						) AS '#arguments.id_campo#'
					</cfsavecontent>
				</cfcase>

				<cfdefaultcase>
					<cfsavecontent variable="s">
						("CAMPO_#arguments.id_campo#") AS '#arguments.id_campo#'
				</cfsavecontent>
				</cfdefaultcase>
			</cfswitch>
		</cfoutput>

		<cfreturn s>
	</cffunction>

	<cffunction name="generarUnaColumnaCampoOtros" access="public" rturntype="string" output="false">
		<cfargument name="id_campo" required="true"/>
		<!--- <cfargument name="titulo" required="true"/> --->

		<cfset var s = ''>
		<cfinclude template="/default/admin/helpers/string.cfm">
		<!--- <cfset var n = codificarNombreColumna(arguments.titulo)> --->

		<cfoutput>
			<cfswitch expression="#arguments.id_campo#">
				<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
				<cfcase value="169">
					<cfsavecontent variable="s">
						("FECHA_ULTIMO_PAGO_POR_TRANSFERENCIA") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA --->
				<cfcase value="170">
					<cfsavecontent variable="s">
						("CANTIDAD_ULTIMO_PAGO_POR_TRANSFERENCIA") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- TEMÁTICAS DE LAS COMUNICACIONES --->
				<cfcase value="268">
					<cfsavecontent variable="s">
						("TEMATICAS_COMUNICACIONES") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- DOBLE OPT-IN --->
				<cfcase value="255">
					<cfsavecontent variable="s">
						CASE p.doble_opt_in WHEN 0 THEN '#trad.get(4636)#' WHEN 1 THEN '#trad.get(4635)#' ELSE '#trad.get(4634)#' END AS "#arguments.id_campo#"
						
						
					</cfsavecontent> 
				</cfcase>

				<!--- RESULTADOS DE PAGOS EN PAYPAL --->
				<cfcase value="254">
					<cfsavecontent variable="s">
						(
							SELECT DISTINCT(GROUP_CONCAT(valor SEPARATOR '<br>'))
							FROM resultadosDePagos rp
							INNER JOIN resultadosDePagosPasarelasDatos rppd ON rp.id_resultado = rppd.id_resultado
							WHERE rp.id_evento IN (#session.id_evento#)
							AND rppd.id_evento IN (#session.id_evento#)
							AND rp.id_participante = p.id_participante
							AND metodointro = 'auto'
							AND rp.resultado IN ('ok')
							AND campo IN ('payer_id' , 'payment_status')
							AND valor != 'completed'
							GROUP BY rp.id_participante
						) AS "#arguments.id_campo#"
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
								rp.id_evento = #session.id_evento#
								and rppd.id_evento = #session.id_evento#
									and rp.id_participante = p.id_participante
									and metodointro = 'auto'
									and rp.resultado in ('ok')
									and campo = 'Ds_AuthorisationCode'
							group by rp.id_participante--->
							"RESULTADOS_DE_PAGO_REDSYS"
						) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>


				<!--- CONCEPTOS PAGADOS --->
				<cfcase value="238">
					<cfsavecontent variable="s">
						("CONCEPTOS_PAGADOS") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- CONCEPTOS NO PAGADOS --->
				<cfcase value="239">
					<cfsavecontent variable="s">
						("CONCEPTOS_NO_PAGADOS") AS "#arguments.id_campo#"
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
						) AS "#arguments.id_campo#" --->
						("MEDIO_DE_PAGO_UTILIZADO") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- PERMISOS PARA VER ESTE PARTICIPANTE --->
				<cfcase value="133">
					<cfsavecontent variable="s">
						REPLACE(listaNombresPermisosParticipante(p.id_participante, #session.id_evento#), CONVERT(',' USING utf8), '<br>') AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- USUARIO QUE LO CREO --->
				<cfcase value="134">
					<cfsavecontent variable="s">
						nombreUsuario(p.id_usuario_alta, #session.id_evento#) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- USUARIO QUE LO MODIFICO --->
				<cfcase value="135">
					<cfsavecontent variable="s">
						nombreUsuario(p.id_usuario_modif, #session.id_evento#) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- CODIGO DE participante --->
				<cfcase value="236">
					<cfsavecontent variable="s">
						<!--- codigoParticipante(p.id_tipo_participante) AS "#arguments.id_campo#" --->
						"CODIGO_PARTICIPANTE_1" AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- OBSERVACIONES --->
				<cfcase value="559">
					<cfsavecontent variable="s">
						(
							SELECT GROUP_CONCAT(CONCAT(texto) SEPARATOR '<br>')
							FROM vCRMObservaciones
							WHERE id_participante = p.id_participante
							GROUP BY id_participante
							ORDER BY fecha_alta
						) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- CÓDIGOS DE LAS ACTIVIDADES SELECCIONADAS --->
				<cfcase value="560">
					<cfsavecontent variable="s">
						"CODIGOS_ACTIVIDADES_SELECCIONADAS_#arguments.id_campo#" AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- CODIGO DE participante 2--->
				<cfcase value="237">
					<cfsavecontent variable="s">
						codigoParticipante2(p.id_tipo_participante) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>



				<cfcase value="248">
					<!--- IDIOMA DE INSCRIPCION--->
					<cfquery name="local.qIdiomas" datasource="#application.datasource#">
						SELECT
							wia.id_idioma,
							wia.nombre AS titulo
						FROM vWebsIdiomasActivos wia 
						INNER JOIN webs w ON w.id_web = wia.id_web
						AND w.eventos_id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
						AND w.tiposWebs_id_tipo_web = 1
						ORDER BY wia.nombre
					</cfquery>

					<cfsavecontent variable="s">
						CASE p.id_idioma
						<cfloop query="local.qIdiomas">
							WHEN '#id_idioma#' THEN '#(titulo)#'
						</cfloop>
						END AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>


				<!--- DUPLICADOS --->
				<cfcase value="244">
					<cfsavecontent variable="s">
						CASE IFNULL(cantidadDuplicados, 0) WHEN 0 THEN
						
							'#trad.get(1237)#'
						ELSE
							CONCAT('#trad.get(1236)#', ' (', cantidadDuplicados, ')')
						END AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- INSCRITO --->
				<cfcase value="3">
					<cfset var objTraducciones = createObject('component', 'default.admin.model.traduccionesV2')>
					<cfsavecontent variable="s">
						CASE p.inscrito WHEN 1 THEN '#trad.get(1236)#' ELSE '#trad.get(1237)#' END AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- PAGADO --->
				<cfcase value="4">
					<cfsavecontent variable="s">
						<!---case pagadoParticipante(p.id_participante) WHEN 1 THEN '#trad.get(1236)#' ELSE '#trad.get(1237)#' END--->
						("PAGO_COMPLETADO") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- TOTAL_A_PAGAR --->
				<cfcase value="6">
					<cfsavecontent variable="s">
						round(p.total_a_pagar, 2) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- TIPO DE PARTICIPANTE --->
				<cfcase value="7">
					<cfsavecontent variable="s">
						(
							<!---nombreTipoParticipante(p.id_tipo_participante, p.id_evento)--->
							<cfset var listaTipos = this.objEvento.getQueryListaTiposDeParticipante()>
							<cfif listaTipos.recordCount gt 0>
								CASE p.id_tipo_participante
								<cfloop query="#listaTipos#">
									WHEN #id_tipo_participante# THEN '#nombre#'
								</cfloop>
								END
							<cfelse>
								''
							</cfif>
						) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- fecha_alta --->
				<cfcase value="8">
					<cfsavecontent variable="s">
						<cfquery name="local.qGetZonaHorariaEvento" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select zonaHorariaEvento(#session.id_evento#) AS zonaHoraria
						</cfquery>
						<cfif local.qGetZonaHorariaEvento.zonaHoraria is 'Europe/Madrid'>
							p.fecha_alta
						<cfelse>
							DATE_FORMAT(CONVERT_TZ(STR_TO_DATE(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid', '#local.qGetZonaHorariaEvento.zonaHoraria#'), '%d/%m/%Y %T')
						</cfif> AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- ID_PARTICIPANTE --->
				<cfcase value="9">
					<cfsavecontent variable="s">
						p.id_participante AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>


				<!--- IVA_A_PAGAR  --->
				<cfcase value="109">
					<cfsavecontent variable="s">
						("CALCULAR_TOTAL_IVA_A_PAGAR") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- TOTAL_SIN_IVA  --->
				<cfcase value="110">
					<cfsavecontent variable="s">
						("CALCULAR_TOTAL_A_PAGAR_BI") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- IMPORTE_PAGADO  --->
				<cfcase value="111">
					<cfsavecontent variable="s">
						("IMPORTE_PAGADO") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- PENDIENTE_PAGO  --->
				<cfcase value="112">
					<cfsavecontent variable="s">
						("PENDIENTE_DE_PAGO") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!---NUMERO_FACTURA--->
				<cfcase value="118">
					<cfsavecontent variable="s">
						("NUMERO_FACTURA") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- FACTURA EMITIDA--->
				<cfcase value="157">
					<cfsavecontent variable="s">
						("FACTURA_EMITIDA") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- SE HA ENVIADO LA FACTURA POR EMAIL --->
				<cfcase value="158">
					<cfsavecontent variable="s">
						("FACTURA_ENVIADA_POR_EMAIL") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!---FECHA_FACTURA--->
				<cfcase value="119">
					<cfsavecontent variable="s">
						("FECHA_FACTURA") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!---TIPO_FACTURA--->
				<cfcase value="120">
					<cfsavecontent variable="s">
						(SELECT tipo_plantilla FROM vFacturas vf WHERE vf.id_participante = p.id_participante) AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- fecha_modif --->
				<cfcase value="131">
					<cfsavecontent variable="s">
						<!--- DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T')  --->
						<cfquery name="local.qGetZonaHorariaEvento" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,1,0)#">
							select zonaHorariaEvento(#session.id_evento#) AS zonaHoraria
						</cfquery>
						<cfif local.qGetZonaHorariaEvento.zonaHoraria is 'Europe/Madrid'>
							p.fecha_modif
						<cfelse>
							DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid', '#local.qGetZonaHorariaEvento.zonaHoraria#'), '%d/%m/%Y %T')
						</cfif> AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>

				<!--- numero de pagos por TPV --->
				<cfcase value="235">
					<cfsavecontent variable="s">
						<!--- numeroPagosTPVParticipante(p.id_participante)  --->
						("NUMERO_PAGOS_POR_TPV_PARTICIPANTE") AS "#arguments.id_campo#"
					</cfsavecontent>
				</cfcase>
			</cfswitch>

		</cfoutput>
		<cfreturn s>
	</cffunction>
	
	<cffunction name="generarUnaColumnaWhere" access="public" returntype="string" output="false">
		<cfargument name="id_agrupacion" 		required="true"/>

		<cfargument name="id_campo" 			required="true"/>
		<cfargument name="valor" 				required="true"/>
		<cfargument name="id_tipo_campo_fijo" 	required="true"/>

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
						<cfset var busquedaPorNoRelleno = pos gt 0>
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
						<cfelseif busquedaPorNoRelleno>
							<!--- BUSCAMOS POR NO RELLENO --->
							<cfquery name="local.qDatosRelleno" datasource="#application.datasource#">
								select id_participante
								from vParticipantesDatos
								where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
									and id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="cf_sql_integer">
									and (valor != '' and valor is not null)
							</cfquery>
							#generarListaParticipantesAFiltrarNegativo(local.qDatosRelleno)#
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
						when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
						else ifnull((select nombre from vPaisesNivel1 where id_nivel1 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
					end) like '%#arguments.valor#%'
				</cfsavecontent>
				</cfcase>

				<cfcase value="13">
					<cfsavecontent variable="s">
					(case find_in_set(p.id_idioma, 'ES')
						when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
						else ifnull((select nombre from vPaisesNivel2 where id_nivel2 = datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento)), datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci)
					end) like '%#arguments.valor#%'
				</cfsavecontent>
				</cfcase>

				<cfcase value="14">
					<!--- LISTA DE PAISES --->
					<cfsavecontent variable="s">
					(
						case find_in_set(p.id_idioma, p.id_idioma)
							when 0 THEN datoParticipante2(p.id_participante, #arguments.id_campo#, p.id_evento) COLLATE utf8_spanish_ci
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

	<cffunction name="generarUnaColumnaCampoOtrosWhere" access="public" rturntype="string" output="false">
		<cfargument name="id_campo" required="true"/>
		<cfargument name="valor" required="true"/>

		<cfset var s = ''>

		<cfoutput>
			<cfswitch expression="#arguments.id_campo#">
				<!--- CANTIDAD DEL ULTIMO PAGO POR TRANSFERENCIA --->
				<cfcase value="170">
					<cfsavecontent variable="s">
						<cfif trim(arguments.valor) is '=0'>
							<!--- LOS QUE TENGAN ALGÚN PAGO POR TRANSFERENCIA --->
							<cfquery name="local.qParticipantesConPagosConTransferencia" datasource="#application.datasource#">
								SELECT id_participante
								FROM resultadosDePagos
								WHERE id_evento = <cfqueryparam value="#arguments.objEvento.id_evento#" cfsqltype="cf_sql_integer">
								AND id_tipo_pago = 2
								AND resultado = 'ok'
								AND cantidad > 0
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
									select id_participante, DATE_FORMAT(max(fecha_alta), '%d/%m/%Y %T') AS fecha, cantidad/100 AS cantidad
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
									select id_participante, DATE_FORMAT(max(CONVERT_TZ(fecha_alta, 'Europe/Madrid', zonaHorariaEvento(#arguments.objEvento.id_evento#))), '%d/%m/%Y %T') AS fecha
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
							select distinct(pc.id_participante) AS id_participante
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
							<cfset aIn.append("find_in_set(convert(#id_valor# using utf8), (listaIdsConceptos2(p.id_participante, 1, '#session.id_idioma#', #session.id_evento#)))")>
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
						select distinct(id_participante) AS id_participante
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
							a1.id_participante AS id_participante
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
											p.total_a_pagar)) AS pagado,
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
						<!--- DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%' --->

						<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
							select id_participante
							from vParticipantes p
							where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_alta, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%'
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
						cast(ifnull((select sum(cantidad-base_imponible)/100 from resultadosDePagos where id_participante = p.id_participante),0) AS decimal(11,2)) like "%#valor#%"
					</cfsavecontent>
				</cfcase>

				<cfcase value="110">
					<!--- TOTAL_SIN_IVA  --->
					<cfsavecontent variable="s">
						cast(ifnull((select sum(base_imponible)/100 from resultadosDePagos where id_participante = p.id_participante),0) AS decimal(11,2)) like "%#valor#%"
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
										round(sum(cantidad/100), 2) AS importePagado,
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
											round(sum(cantidad/100), 2) AS importePagado,
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
										round(sum(cantidad/100), 2) AS importePagado,
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
						<!--- cast((p.total_a_pagar - ifnull((select sum(cantidad)/100 from resultadosDePagos where id_participante = p.id_participante and resultado = 'ok'),0)) AS decimal(11,2)) like "%#valor#%" --->
						<cftry>
							<cfquery name="local.qPendientesDePago" datasource="#application.datasource#">
								select id_participante
								from
								(
									SELECT
										p.id_participante,
										p.total_a_pagar,
										SUM(ifnull(cantidad, 0)) / 100 AS pagado,
										cast((p.total_a_pagar - SUM(ifnull(cantidad, 0)) / 100) AS decimal(11,2)) AS resto
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
							cast((p.total_a_pagar - ifnull((select sum(cantidad)/100 from resultadosDePagos where id_participante = p.id_participante and resultado = 'ok'),0)) AS decimal(11,2)) like "%#valor#%"
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
								participantes_id_participante AS id_participante
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
								and DATE_FORMAT(fecha_factura,'%d/%m/%Y') like '%#valor#%'
						</cfquery>

						#generarListaParticipantesAFiltrar(local.qValorCampoLista)#

						<!---(select DATE_FORMAT(fecha_factura,'%d/%m/%Y') from vFacturas vf where vf.id_participante = p.id_participante) like '%#valor#%'--->
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
						<!--- DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%' --->

						<cfquery name="local.qListaParticipantes" datasource="#application.datasource#">
							select id_participante
							from vParticipantes p
							where id_evento = <cfqueryparam value="#objEvento.id_evento#" cfsqltype="cf_sql_integer">
								and DATE_FORMAT(CONVERT_TZ(str_to_date(p.fecha_modif, '%d/%m/%Y %T'), 'Europe/Madrid',zonaHorariaEvento(p.id_evento)), '%d/%m/%Y %T') like '%#valor#%'
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

	<cffunction name="rellenarDatosInforme" returntype="query" output="false">
		<cfargument name="consulta" required="true" type="string" >
		<cfargument name="query" required="true" type="query">

		<cfset var q = arguments.query>

		<cfinclude template="/includes/helpers/QuerysHelper.cfm">
		<cfinclude template = "/default/admin/helpers/string.cfm">

		<cfif arguments.query.recordCount gt 0>
			<cfset q = rellenarDatosCampos(arguments.consulta, q)>
			<cfset q = rellenarDatosCampoSiNo(arguments.consulta, q)>
			<cfset q = rellenarDatosCamposLista(arguments.consulta, q)>
			<cfset q = rellenarDatosCamposMultiSeleccion(arguments.consulta, q)>
		</cfif>
		
		<cfreturn q>
	</cffunction>

	<cffunction name="rellenarDatosCampos" returntype="query" output="false">
		<cfargument name="consulta" required="true" type="string" >
		<cfargument name="query" required="true" type="query">
		<cfargument name="nombresCampos" required="false" default="#structNew()#">
		
		<cfset var q = arguments.query>

		<!--- CUALQUIER CAMPO TIPO TEXTO DE PARTICIPANTESDATOS --->
		<cfset var posCampos = reMultiMatch("(CAMPO_[_\d+]+)", arguments.consulta)>
		
		<cfif posCampos.len() gt 0>
			<cfset var listaIds = valueList(q.id_participante)>
			<cfset var sCampos = {}>
			<cfset var id_campo = ''>
			<cfset var aCampos = []>
			
			<cfset sCampos = obtenerValores(posCampos, listaIds)>

			<cfset var sLocal = {}>
			<cfset var nombreColumna = ''>

			<cfloop query="q">
				<cfloop from ="1" to="#posCampos.len()#" index="i">
					<cfset id_campo = listLast(posCampos[i], '_')>
					<cfif structKeyExists(sCampos, id_campo)>										
						<cfset sLocal = sCampos[id_campo]>
						<cfif structKeyExists(sLocal, q.id_participante)>
							<cfset q[id_campo][currentRow] = sLocal[q.id_participante].valor>
						<cfelse>
							<cfset q[id_campo][currentRow] = "">
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>		
		</cfif>
		<!--- FIN CAMPOS TIPO TEXTO --->

		<cfreturn q>
	</cffunction>

	<cffunction name="rellenarDatosCampoSiNo" returntype="query" output="false">
		<cfargument name="consulta" required="true" type="string" >
		<cfargument name="query" required="true" type="query">
		
		<cfset var q = arguments.query>

		<!--- CAMPOSINO --->
		<cfset var posCampoSiNo = reMultiMatch("(CAMPOSINO_[_\d+]+)", arguments.consulta)>
		
		<cfif posCampoSiNo.len() gt 0>
			<cfset var listaIds = valueList(q.id_participante)>
			<cfset var sCamposSiNo = {}>
			<cfset var id_campo = ''>
			<cfset var aCampos = []>

			<cfset sCamposSiNo = obtenerValores(posCampoSiNo, listaIds)>

			<cfloop query="q">
				<cfloop from ="1" to="#posCampoSiNo.len()#" index="i">
					<cfset id_campo = listLast(posCampoSiNo[i], '_')>
					<cfif structKeyExists(sCamposSiNo, id_campo)>
						<cfset sLocal = sCamposSiNo[id_campo]>
						<cfif structKeyExists(sLocal, q.id_participante)>
							<cfif sLocal[q.id_participante].valor is 1>
								<cfset q[id_campo][currentRow] = '#trad.get(1236)#'>
							<cfelseif sLocal[q.id_participante].valor is 0>
								<cfset q[id_campo][currentRow] = '#trad.get(1237)#'>
							<cfelse>
								<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
							</cfif>
						<cfelse>
							<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
						</cfif>
					<cfelse>
						<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- FIN CAMPOSINO --->

		<cfreturn q>
	</cffunction>

	<cffunction name="rellenarDatosCamposMultiSeleccion" returntype="query" output="false">
		<cfargument name="consulta" required="true" type="string" >
		<cfargument name="query" required="true" type="query">
		
		<cfset var q = arguments.query>

		<!--- CAMPO MULTISELECCION --->
		<cfset var posCamposMultiseleccion = reMultiMatch("(CAMPOMULTISELECCION_[_\d+]+)", arguments.consulta)>
				
		<cfif posCamposMultiseleccion.len() gt 0>
			<cfset var listaIds = valueList(q.id_participante)>
			<cfset var sCamposMultiSeleccion = {}>
			<cfset var id_campo = ''>
			<cfset var aCampos = []>
			
			<cfset sCamposMultiSeleccion = obtenerValores(posCamposMultiseleccion, listaIds)>

			<cfloop query="q">
				<cfloop from ="1" to="#posCamposMultiseleccion.len()#" index="i">
					<cfset id_campo = listLast(posCamposMultiseleccion[i], '_')>

					<cfif structKeyExists(sCamposMultiSeleccion, id_campo)>
						<cfset sLocal = sCamposMultiSeleccion[id_campo]>
						<cfif structKeyExists(sLocal, q.id_participante)>

							<cfif sLocal[q.id_participante].valor neq '' and listLen(sLocal[q.id_participante].valor) gt 0>
								<cfif listLen(sLocal[q.id_participante].valor) is 1>
									<cfset q[id_campo][currentRow] = '#sLocal[q.id_participante].valor#'>
								<cfelse>
									<!--- VARIOS VALORES SELECCIONADOS --->
									<cfset var valor = []>
									<cfset var valores = listToArray(sLocal[q.id_participante].valor)>
									<cfloop from="1" to="#valores.len()#" index="iValores">
										<cfset valor.append(iValores)>
									</cfloop>
									<cfset q[id_campo][currentRow] = '#arrayToList(valor, ",")#'>
								</cfif>
							<cfelse>
								<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
							</cfif>
						<cfelse>
							<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
						</cfif>
					<cfelse>
						<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<!--- FIN CAMPO MULTISELECCION --->

		<cfreturn q>
	</cffunction>

	<cffunction name="rellenarDatosCamposLista" returntype="query" output="false">
		<cfargument name="consulta" required="true" type="string" >
		<cfargument name="query" required="true" type="query">

		<cfset var q = arguments.query>

		<!--- CAMPOS LISTA --->
		<cfset var posCamposLista = reMultiMatch("(CAMPOLISTA_[_\d+]+)", arguments.consulta)>
		
		<cfif posCamposLista.len() gt 0>
			<cfset var listaIds = valueList(q.id_participante)>
			<cfset var sCamposLista = {}>
			<cfset var id_campo = ''>
			<cfset var aCampos = []>
			
			<cfset sCamposLista = obtenerValores(posCamposLista	, listaIds)>

			<cfloop query="q">
				<cfloop from ="1" to="#posCamposLista.len()#" index="i">
					<cfset id_campo = listLast(posCamposLista[i], '_')>

					<cfif structKeyExists(sCamposLista, id_campo)>
						<cfset sLocal = sCamposLista[id_campo]>

						<cfif structKeyExists(sLocal, q['id_participante'])>
							<cfif sLocal[q.id_participante].valor NEQ '' AND listLen(sLocal[q.id_participante].valor) IS 1>
								<cfset q[id_campo][currentRow] = sLocal[q.id_participante].valor>
							<cfelse>
								<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
							</cfif>
						<cfelse>
							<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
						</cfif>
					<cfelse>
						<cfset q[id_campo][currentRow] = '#trad.get(4399)#'>
					</cfif>
				</cfloop>
			</cfloop>
			
		</cfif>
		<!--- FIN CAMPOS LISTA --->

		<cfreturn q>
	</cffunction>

	<cffunction name="obtenerValores">
		<cfargument name="posCampos" type="array" required="true" default="[]">
		<cfargument name="listaIds" type="any" required="true">

		<cfset var aCampos = []>
		<cfset var sCamposLista = {}>

		<cfloop from ="1" to="#arguments.posCampos.len()#" index="i">
			<cfset id_campo = listLast(arguments.posCampos[i], '_')>
			
			<cfquery name="local.qDatosParticipantes" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT id_participante, valor, id_campo
				FROM vParticipantesDatos
				WHERE id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND id_participante IN (<cfqueryparam value="#arguments.listaIds#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND id_campo = <cfqueryparam value="#id_campo#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfset campos[id_campo] = QueryToStruct2(local.qDatosParticipantes, 'id_participante')>
			<cfset aCampos.append(id_campo)>
		</cfloop>

		<cfreturn campos>
	</cffunction>
</cfcomponent>