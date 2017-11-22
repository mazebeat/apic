<!--- RESTO DE AGRUPACIONES --->
<cfswitch expression="#id_campo#">
	<!--- CAMPOS OTROS --->
	<cfcase value="3,4,5,6,7,8,9,99,109,110,111,112,118,119,120,131,133,134,135,235,236,237,238,239,240,248,242,246,244,154,157,158,159,247,250,253,254,255,259,559,560,264,265,160,268,168,169,170">
		<!--- <cfif listFind('5', id_campo) gt 0>
			<!--- LISTA DE ACTIVIDADES --->
			<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
			<cfset var objGrupo = ''>
			<cfset var id_grupo = ''>
			<cfset var listaActividades = ''>
			<cfset var objActividad = ''>
			<cfset var id_actividad = ''>
			<cfloop list="#listaGrupos#" index="id_grupo">
				<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
				<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
				<cfloop list="#listaActividades#" index="id_actividad">
					<cfset objActividad = objGrupo.getActividad(id_actividad)>
					<cfset i++>
					<cfset sColumnas[i] = generarUnaColumnaActividad(id_actividad, objActividad.nombre)>

					<cfif structKeyExists(arguments.rc, 'ACT_#id_actividad#')>
						<cfset valor = evaluate('arguments.rc.ACT_#id_actividad#')>
						<cfif (valor neq '') and (valor neq '-')>
							<cfset sColumnasInnerWhere[i] = generarUnaColumnaActividadWhere(id_actividad, valor)>
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelseif id_campo is 168>
			<!--- ACTIVIDADES ASOCIADAS A L PARTICIPANTE (SÓLO PARA PONENTES) --->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaActividadesAsociadasAPonentes(id_campo, titulo)>

			<cfif structKeyExists(arguments.rc, 'CAMPO_168')>
				<cfset valor = arguments.rc.campo_168>
				<cfif valor neq ''>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaActividadesAsociadasAPonentesWhere(valor)>
				</cfif>
			</cfif>
		<cfelseif id_campo is 264>
			<!--- LISTA DE ACTIVIDADES SELECCIONADAS CON PRECIO --->
			<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
			<cfset var objGrupo = ''>
			<cfset var id_grupo = ''>
			<cfset var listaActividades = ''>
			<cfset var objActividad = ''>
			<cfset var id_actividad = ''>
			<cfloop list="#listaGrupos#" index="id_grupo">
				<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
				<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
				<cfloop list="#listaActividades#" index="id_actividad">
					<cfset objActividad = objGrupo.getActividad(id_actividad)>
					<cfset i++>
					<cfset sColumnas[i] = generarUnaColumnaActividadSeleccionadaConPrecio(id_actividad, objActividad.nombre)>
					<cfif structKeyExists(arguments.rc, 'ACTIVIDAD_SELECCIONADA_CON_PRECIO_#id_actividad#')>
						<cfset valor = evaluate('arguments.rc.ACTIVIDAD_SELECCIONADA_CON_PRECIO_#id_actividad#')>
						<cfif (valor neq '') and (valor neq '-')>
							<cfset sColumnasInnerWhere[i] = generarUnaColumnaActividadSeleccionadaConPrecioWhere(id_actividad, valor)>
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelseif id_campo is 265>
			<!--- LISTA DE ACTIVIDADES SELECCIONADAS CON PRECIO Y PAGADAS--->
			<cfset var listaGrupos = objEvento.listaGruposActividadesPorNombre()>
			<cfset var objGrupo = ''>
			<cfset var id_grupo = ''>
			<cfset var listaActividades = ''>
			<cfset var objActividad = ''>
			<cfset var id_actividad = ''>
			<cfloop list="#listaGrupos#" index="id_grupo">
				<cfset objGrupo = objEvento.getGrupoActividades(id_grupo)>
				<cfset listaActividades = objGrupo.listaActividadesPorNombre()>
				<cfloop list="#listaActividades#" index="id_actividad">
					<cfset objActividad = objGrupo.getActividad(id_actividad)>
					<cfset i++>
					<cfset sColumnas[i] = generarUnaColumnaActividadSeleccionadaConPrecioPagadas(id_actividad, objActividad.nombre)>
					<cfif structKeyExists(arguments.rc, 'ACTIVIDAD_SELECCIONADA_CON_PRECIO_PAGADA_#id_actividad#')>
						<cfset valor = evaluate('arguments.rc.ACTIVIDAD_SELECCIONADA_CON_PRECIO_PAGADA_#id_actividad#')>
						<cfif (valor neq '') and (valor neq '-')>
							<cfset sColumnasInnerWhere[i] = generarUnaColumnaActividadSeleccionadaConPrecioPagadaWhere(id_actividad, valor)>
						</cfif>
					</cfif>
				</cfloop>
			</cfloop>
		<cfelseif id_campo is 242>
			<!---MODALIDAD SELECCIONADA --->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaModalidadSeleccionada('Modalidad seleccionada')>
			<cfif structKeyExists(arguments.rc, 'MOD_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.MOD_#id_campo#')>
				<cfif isArray(valor) or ((valor neq '') and (valor neq '-'))>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaModalidadSeleccionadaWhere(valor)>
				</cfif>
			</cfif>
		<cfelseif listFind('246', id_campo) gt 0>
			<!--- CUPONES USADOS --->
			<cfset i++>
			<cfset sColumnas[i] = cargarColumnaInformeCampo246(id_campo, titulo, objEvento.id_evento)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif (valor neq '')>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCuponesUsadosWhere(valor)>
				</cfif>
			</cfif>
		<cfelseif listfind('154', id_campo) gt 0>
			<!--- OPCIONES ADICIONALES SELECCIONADAS --->
			<cfinclude template="/default/admin/helpers/generarConsultaInformeCampo154.cfm" />
		<cfelseif listFind('159', id_campo) gt 0>
			<!--- LISTA DE ENTRADAS COMPRADAS --->
			<cfinclude template="/default/admin/helpers/generarConsultaInformeCampo159.cfm" />
		<cfelseif listFind('247', id_campo) gt 0>
			<!--- CANTIDAD DE ENTRADAS COMPRADAS --->
			<cfinclude template="/default/admin/helpers/generarConsultaInformeCampo247.cfm" />
		<cfelseif id_campo is 259>
			<!--- LISTADO DE MULTIACTIVIDADES --->
			<cfset var objGestorMA = createObject('component', 'default.admin.model.parametrosEvento.multiActividades').init(objEvento.id_evento, session.id_idioma, session.id_idioma_relleno)>
			<cfset var args = {}>
			<cfset args.rc =
				{
				_search : false,
				select : 'id_actividad',
				page : 1,
				rows : 2000
				}>
			<cfset var actividades = objgestorMA.getActividades(argumentCollection: args).actividades>
			<cfloop query="actividades">
				<cfset i++>
				<cfset titulo = 'MULTIACTIVIDAD_ASIGN_#id_Actividad#'>
				<cfset sColumnas[i] = generarUnaColumnaCampoMultiActividades(id_campo, titulo, id_actividad, 'ASIGNADA')>
				<cfif structKeyExists(arguments.rc, 'MULTIACTIVIDAD_ASIGN_#id_actividad#')>
					<cfset valor = evaluate('arguments.rc.MULTIACTIVIDAD_ASIGN_#id_actividad#')>
					<cfif valor neq '-'>
						<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoMultiActividadesWhere(id_actividad, valor, 'ASIGNADA')>
					</cfif>
				</cfif>
				<cfset i++>
				<cfset titulo = 'MULTIACTIVIDAD_CONFIRM_#id_Actividad#'>
				<cfset sColumnas[i] = generarUnaColumnaCampoMultiActividades(id_campo, titulo, id_actividad, 'CONFIRMADA')>
				<cfif structKeyExists(arguments.rc, 'MULTIACTIVIDAD_CONFIRM_#id_actividad#')>
					<cfset valor = evaluate('arguments.rc.MULTIACTIVIDAD_CONFIRM_#id_actividad#')>
					<cfif valor neq '-'>
						<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoMultiActividadesWhere(id_actividad, valor, 'CONFIRMADA')>
					</cfif>
				</cfif>
			</cfloop>
		<cfelseif listfind('99', id_campo) gt 0>
			<!--- LISTADO DE PRODUCTOS --->
			<cfinclude template="/default/admin/helpers/generarConsultaInformeCampo99.cfm" />
		<cfelseif id_campo is 169>
			<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA--->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaCampoOtros(id_campo, titulo)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif trim(valor) neq ''>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
				</cfif>
			</cfif>
		<cfelseif id_campo is 170>
			<!--- FECHA DEL ULTIMO PAGO POR TRANSFERENCIA--->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaCampoOtros(id_campo, titulo)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif trim(valor) neq ''>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
				</cfif>
			</cfif>
		<cfelseif (arrayFind([3,4,6,7,8,9,109,110,111,112,118,119,120,131,235,236,237,238,239,240,248,244,157,158,254,255,559,560,160], id_campo) gt 0)>
			<!--- CAMPOS NORMALES --->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaCampoOtros(id_campo, titulo)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif listfind('3,4,101', id_campo) and valor neq '-'>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
				<cfelseif listFind('112', id_campo) gt 0>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
				<cfelse>
					<cfif isArray(valor)>
						<cfset valor = "'" & arrayToList(valor, ''',''') & "'">
					</cfif>
					<cfset valor = replace(valor, "'-'", "-", "ALL")>
					<cfif valor neq '-'>
						<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
					</cfif>
				</cfif>
			</cfif>
		<cfelseif listfind('133,134,135', id_campo) gt 0>
			<!--- PERMISOS PARA VER ESTE PARTICIPANTE --->
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaCampoOtros(id_campo, titulo)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif isArray(valor)>
					<cfset valor = arrayToList(valor)>
				</cfif>
				<cfif valor neq '-'>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor)>
				</cfif>
			</cfif>
		<cfelseif arrayFind([268], id_campo) gt 0>
			<cfset i++>
			<cfset sColumnas[i] = generarUnaColumnaCampoOtros(id_campo, titulo)>
			<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
				<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
				<cfif valor neq ''>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaCampoOtrosWhere(id_campo, valor, this.objEvento)>
				</cfif>
			</cfif>
		</cfif> --->
	</cfcase>
	<cfdefaultcase>
		<cfset i++>
		<cfset sColumnas[i] = generarUnaColumna(id_agrupacion, id_campo, id_tipo_campo_fijo)>
		<cfdump var="#sColumnas#"><cfabort>
		
		<cfif structKeyExists(arguments.rc, 'CAMPO_#id_campo#')>
			<cfset valor = evaluate('arguments.rc.CAMPO_#id_campo#')>
			<cfset var objAgrupacion = objEvento.getAgrupacionDeCampos(id_agrupacion)>
			<cfset var objCampo = objAgrupacion.getCampo(id_campo)>
			<cfif listfind('2,3,4', objCampo.id_tipo_campo) gt 0>
				<cfif isArray(valor) or ((valor neq '') and (valor neq '-'))>
					<cfset sColumnasInnerWhere[i] = generarUnaColumnaWhere(id_agrupacion, id_campo, valor, id_tipo_campo_fijo)>
				</cfif>
			<cfelse>
				<cfset sColumnasInnerWhere[i] = generarUnaColumnaWhere(id_agrupacion, id_campo, valor, id_tipo_campo_fijo)>
			</cfif>
		</cfif>
	</cfdefaultcase>
</cfswitch>
