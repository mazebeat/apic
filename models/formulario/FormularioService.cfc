<!--
	Formulario Service
-->
<cfcomponent hint="Formulario Service" output="false" accessors="true">

	<!-- Properties -->
	<cfproperty name="dao"		inject="model:formulario.FormularioDAO">
	<cfproperty name="campoDao"	inject="model:campo.CampoDAO">
	<cfproperty name="traduc"	inject="model:traduccion.TraduccionService">
	<cfproperty name="wirebox"	inject="wirebox">
	<cfproperty name="cache" 	inject="cachebox:default">
	

	<!------------------------------------------ CONSTRUCTOR ------------------------------------------>

	<cffunction name="init" access="public" returntype="FormularioService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------ PUBLIC ------------------------------------------>

	<!--
		* Obtiene todos los formularios según ID de un evento e idioma
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="all" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0, "total"= 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>

		<!--- <cfset var cacheKey = 'q-form-all-#id_evento#'> --->
		
		<!--- <cfif cache.lookup(cacheKey)>
			<cfset var allForms = cache.get(cacheKey)>
		<cfelse> --->
			<cfset var allForms = dao.byEvento(id_evento, event, rc)>
			<!--- <cfset queryAddColumn(allForms, 'id_agrupacion')>
			<cfset queryAddColumn(allForms, 'fields')> --->
			
			<cfloop query="allForms">
				<cfset var groups = dao.groupsByForm(id_formulario)>
				<!--- <cfset querySetCell(allForms, 'id_agrupacion', valueList(groups.id_agrupacion), allForms.CurrentRow)>
				<cfset querySetCell(allForms, 'fields', dao.allFieldsByGroup(valueList(groups.id_agrupacion)), allForms.CurrentRow)> --->
			</cfloop>

			<!--- <cfset cache.set(cacheKey, allForms, 60, 30)>
		</cfif> --->
		
		<cfset s.data.records = allForms>
		<cfset s.data.total   = allForms.recordCount>
		<cfreturn s>
	</cffunction>

	<!--
		* Obtiene todos los formularios según ID de un evento e idioma
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="get" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_formulario" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0, "total"= 0 } }>
		<cfset var campos = createObject("java", "java.util.LinkedHashMap").init()>
		<cfset var cacheKey = 'q-formS-get-#id_formulario#'>

		<!--- <cfif cache.lookup(cacheKey)> --->
			<!--- <cfset var allGroups = cache.get(cacheKey)> --->
		<!--- <cfelse> --->
		<cfset var frm = dao.get(id_formulario, event, rc)>

		<cfloop query="frm">
			<cfset var groups = dao.groupsByForm(id_formulario)>
			<cfset querySetCell(frm, 'id_agrupacion', valueList(groups.id_agrupacion), frm.CurrentRow)>
			<!--- <cfset querySetCell(frm, 'id_campo', valueList(dao.allFieldsByGroup(valueList(groups.id_agrupacion)).id_campo), frm.CurrentRow)> --->
			<cfset querySetCell(frm, 'id_campo', dao.allFieldsByGroup(valueList(groups.id_agrupacion)), frm.CurrentRow)>
		</cfloop>
		<!--- </cfif> --->
		<!--- <cfif isdefined("url.debug")>
			<cfdump var="#frm#" label="fmr">
			<cfabort>
		</cfif> --->

		<cfset s.data.records = frm>
		<cfset s.data.total   = frm.recordCount>
		<cfreturn s>
	</cffunction>

	<!--
		* Obtiene la meta del formulario de participantes de un evento
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="meta" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="sortBy" type="string" required="false" default="field" hint="Could be by 'field', 'form', 'group'">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0, "total"= 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>

		<!--- <cfset var cacheKey = 'q-form-meta-#id_evento#-#sortBy#'> --->

		<!--- <cfif cache.lookup(cacheKey)>
			<cfset campos = cache.get(cacheKey)>
		<cfelse> --->
			<cfset var allGroups = dao.groupsByEvent(id_evento)>
			<cfset var fields 	 = dao.allFieldsByGroup(valueList(allGroups.id_agrupacion))>

			<cfif sortBy EQ 'field'>

				<cfloop query="fields">				
					<cfif NOT structKeyExists(campos, id_campo)>
						<cfset campos[id_campo] = obtainMetaOfField(id_campo)>
					</cfif>
				</cfloop>
			
			<cfelseif sortBy EQ 'form'>
				<cfloop query="fields">				
					<cfif NOT structKeyExists(campos, id_campo)>
						<cfset campos[id_campo] = obtainMetaOfField(id_campo)>
					</cfif>
				</cfloop>
			<cfelseif sortBy EQ 'group'>
				<cfloop query="fields">
					<cfif !structKeyExists(campos, id_agrupacion)>
						<cfquery name="local.title" dbtype="query" cachedWithin="#createTimeSpan( 0, 0, 1, 0 )#">
							SELECT titulo FROM allGroups WHERE id_agrupacion = #id_agrupacion#
						</cfquery>
						<cfset campos['groups'][id_agrupacion]['title'] = local.title.titulo>
					</cfif>
					<cfset campos['groups'][id_agrupacion]['fields'][id_campo] = obtainMetaOfField(id_campo)>
				</cfloop>
			</cfif>
	
			<!--- <cfset cache.set(cacheKey, campos, 60, 30)> --->
		<!--- </cfif> --->
		
		<cfset s.data.records = campos>
		<cfset s.data.total   = structCount(campos)>

		<cfreturn s>
	</cffunction>

		<!--
		* Obtiene todos los formularios según ID de un evento e idioma
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="byEvento" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0, "total"= 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>

		<cfset var cacheKey = 'q-form-byEvento-#id_evento#'>

		<cfif cache.lookup(cacheKey)>
			<cfset allGroups = cache.get(cacheKey)>
		<cfelse>
			<cfset var allGroups = dao.groupsByEvent(arguments.id_evento)>
			<!--- <cfset var fields 	 = dao.allFieldsByGroup(valueList(allGroups.id_agrupacion))>

			<cfloop query="fields">
				<cfset campos[id_agrupacion][id_campo] = obtainMetaOfField(id_campo)>
			</cfloop> --->

			<cfset cache.set(cacheKey, allGroups, 60, 30)>
		</cfif>
		
		<cfset s.data.records           = allGroups>
		<cfset s.data.total             = allGroups.recordCount>

		<cfreturn s>
	</cffunction>

	<!--
		* Obtiene todos los formularios según ID de un evento e idioma
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="fieldsByEvento" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0, "total"= 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>

		<cfset var cacheKey = 'q-form-fieldsByEvento-#id_evento#'>

		<cfif cache.lookup(cacheKey)>
			<cfset campos = cache.get(cacheKey)>
		<cfelse>
			<cfset var allGroups = dao.groupsByEvent()>
			<cfset var fields 	 = dao.allFieldsByGroup(valueList(allGroups.id_agrupacion))>

			<cfloop query="fields">
				<cfset campos[id_agrupacion][id_campo] = obtainMetaOfField(id_campo)>
			</cfloop>

			<cfset cache.set(cacheKey, campos, 60, 30)>
		</cfif>
		
		<cfset s.data.records           = campos>
		<cfset s.data.totalAgrupaciones = allGroups.recordCount>
		<cfset s.data.totalCampos       = structCount(campos)>
		<cfset s.data.total             = structCount(campos) +  allGroups.recordCount>

		<cfreturn s>
	</cffunction>

	<!--
		* Obtiene todos los formularios según ID de un evento e idioma
		* @id_evento 
		* @id_idioma
	--> 
	<cffunction name="getByTipoParticipante" returnType="struct" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_tipo_participante" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje: "", data : { "records":{},  "count": 0, "total": 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>
		
		<!--- <cfset var cacheKey = 'q-formS-bytp-#id_tipo_participante#'> --->

		<!--- <cfif cache.lookup(cacheKey)> --->
			<!--- <cfset var allGroups = cache.get(cacheKey)> --->
		<!--- <cfelse> --->
		<cfset var frm = dao.getByIdTipoParticipante(id_tipo_participante, event, rc)>
				
		<cfloop query="frm">
			<cfset var groups = dao.groupsByForm(id_formulario)>
			<cfset querySetCell(frm, 'id_agrupacion', valueList(groups.id_agrupacion), frm.CurrentRow)>
			<!--- <cfset querySetCell(frm, 'id_campo', valueList(dao.allFieldsByGroup(valueList(groups.id_agrupacion)).id_campo), frm.CurrentRow)> --->
			<cfset querySetCell(frm, 'id_campo', dao.allFieldsByGroup(valueList(groups.id_agrupacion)), frm.CurrentRow)>
		</cfloop>
		
		<cfset s.data.records = frm>
		<cfset s.data.total   = frm.recordCount>
		
		<cfreturn s>
	</cffunction>

	<!--
		*
		*
		*
	-->
	<cffunction name="obtainMetaOfField" access="public" returntype="any" output="false">
		<cfargument name="id_campo" type="numeric" required="true">
		
		<cfinclude template="/default/admin/helpers/camposGruposFormularios.cfm">
		
		<cfset var cacheKey = 'q-field-#id_campo#'>

		<cfif cache.lookup(cacheKey)>
			<cfset var campo = cache.get(cacheKey)>
		<cfelse>
			<cfset var campo = campoDao.get(arguments.id_campo)>
			<cfset cache.set(cacheKey, campo, 60, 30)>
		</cfif>

		<cfif NOT queryColumnExists(campo, 'min_chars')>
			<cfset queryAddColumn(campo, 'min_chars')>
		</cfif>	
		<cfif NOT queryColumnExists(campo, 'max_chars')>
			<cfset queryAddColumn(campo, 'max_chars')>
		</cfif>
		<cfif NOT queryColumnExists(campo, 'dninie')>
			<cfset queryAddColumn(campo, 'dninie')>
		</cfif>
		<cfif NOT queryColumnExists(campo, 'solo_lectura')>
			<cfset queryAddColumn(campo, 'solo_lectura')>
		</cfif>
		<cfif NOT queryColumnExists(campo, 'alfabetico')>
			<cfset queryAddColumn(campo, 'alfabetico')>
		</cfif>
		<cfif NOT queryColumnExists(campo, 'comprobacion')>
			<cfset queryAddColumn(campo, 'comprobacion')>
		</cfif>
		<cfif NOT queryColumnExists(campo, 'desplegable')>
			<cfset queryAddColumn(campo, 'desplegable')>
		</cfif>		

		<cfset var objCampo = ''>
		<cfset var meta = {
			'name'         : '',
			'inputType'    : 'input',
			'type'         : '',
			'configuration': {}
			<!---
			'type'         : 'text',
			'configuration': {
				'required'    : false,
				'readonly'    : false,
				'comprobacion': false,
				'onlyAlpha'   : '',
				'minlength'   : 0,
				'maxlength'   : 0,
			}, 
			'values' : {} 
			--->
			}>

		<cfswitch expression="#local.campo.id_encapsulado#">
			<!-- CAMPO DE TEXTO -->
			<cfcase value="1,7,8,17" delimiters=",">
				<cfset objCampo = wirebox.getInstance('campoFormularioText')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['name']                       = isEmpty(config.titulo) ? campo.titulo: config.titulo>
				<cfset meta['type']                       = 'text'>
				<cfset meta['inputType']                  = 'input'>
				<cfset meta['configuration']['onlyAlpha'] = numericToBoolean(config.alfabetico)>
				<cfset meta['configuration']['required']  = numericToBoolean(config.obligatorio)>
				<cfset meta['configuration']['readonly']  = numericToBoolean(config.solo_lectura)>
				<cfset meta['configuration']['minlength'] = config.min_chars>
				<cfset meta['configuration']['maxlength'] = config.max_chars>
				<cfif config.dninie GT 0>
					<cfset meta['configuration']['dninie'] = numericToBoolean(config.dninie)>
				</cfif>
				
			</cfcase>

			<!-- CAMPO DE EMAIL -->
			<cfcase value="6,19,20" delimiters=",">
				<cfset objCampo = wirebox.getInstance('CampoFormularioText')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['inputType']                     = 'input'>
				<cfset meta['name']                          = isEmpty(config.titulo) ? campo.titulo: config.titulo>
				<cfset meta['type']                          = 'email'>
				<cfset meta['configuration']['onlyAlpha']    = numericToBoolean(config.alfabetico)>
				<cfset meta['configuration']['required']     = numericToBoolean(config.obligatorio)>
				<cfset meta['configuration']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuration']['comprobacion'] = numericToBoolean(config.comprobacion)>
				<cfset meta['configuration']['minlength']    = config.min_chars>
				<cfset meta['configuration']['maxlength']    = config.max_chars>
			</cfcase>
			
			<!-- CAMPO LISTA -->
			<cfcase value="2" delimiters=",">
				<cfset meta['inputType'] = 'select'>

				<cfset meta['inputType']                     = 'select'>
				<cfset meta['name']                          = campo.titulo>
				<cfset meta['type']                          = 'email'>
				<cfset meta['configuration']['required']     = numericToBoolean(campo.obligatorio)>
				<cfset meta['configuration']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuration']['comprobacion'] = numericToBoolean(campo.comprobacion)>
				<cfset meta['values']                    	 = obtainValues(campo.id_campo)>
			</cfcase>
			
			<!-- CAMPO MULTISELECCION -->
			<cfcase value="3" delimiters=",">
				<cfset meta['inputType'] = 'input'>
				<cfset meta['name']      = campo.titulo>
				<cfset meta['type']      = 'checkbox'>
				<cfset meta['values']   = obtainValues(campo.id_campo)>
			</cfcase>
			
			<!-- CAMPO RADIO -->
			<cfcase value="4" delimiters=",">
				<cfset objCampo = wirebox.getInstance('CampoFormularioRadio')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['inputType']                     = 'input'>
				<cfset meta['name']                          = config.titulo>
				<cfset meta['type']                          = 'radio'>
				<cfset meta['configuration']['onlyAlpha']    = numericToBoolean(config.alfabetico)>
				<cfset meta['configuration']['required']     = numericToBoolean(config.obligatorio)>
				<cfset meta['configuration']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuration']['comprobacion'] = numericToBoolean(config.comprobacion)>
				<cfset meta['configuration']['minlength']    = config.min_chars>
				<cfset meta['configuration']['maxlength']    = config.max_chars>
				<cfset meta['values']                       = { 1: '#ucase(traduc.get(35))#', 0: '#ucase(traduc.get(36))#' }>
			</cfcase>
			
			<!-- CAMPO MEMO -->
			<cfcase value="5" delimiters=",">
				<cfset objCampo = wirebox.getInstance('campoFormularioText')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['name']                       = isEmpty(config.titulo) ? campo.titulo: config.titulo>
				<cfset meta['inputType']                  = 'textarea'>
				<cfset meta['configuration']['onlyAlpha'] = numericToBoolean(config.alfabetico)>
				<cfset meta['configuration']['required']  = numericToBoolean(config.obligatorio)>
				<cfset meta['configuration']['readonly']  = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuration']['minlength'] = config.min_chars>
				<cfset meta['configuration']['maxlength'] = config.max_chars>
			</cfcase>
			
			<!-- CAMPO IMAGEN -->
			<cfcase value="9" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'file'>
				<cfset meta['inputType']                 = 'img'>
				<cfset meta['configuration']['readonly'] = numericToBoolean(campo.solo_lectura)>
			</cfcase>
			
			<!-- CAMPO WEB -->
			<cfcase value="10" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'url'>
				<cfset meta['inputType']                 = 'input'>
				<cfset meta['configuration']['readonly'] = numericToBoolean(campo.solo_lectura)>
			</cfcase>
			
			<!--- TODO: Quedan pendientes a verificar como entregar información. --->
			<!-- CAMPO PROVINCIA -->
			<cfcase value="11" delimiters=",">
				<!--- <cfset objCampo = wirebox.getInstance('campoFormularioProvincia').init(local.campo)> --->
			</cfcase>
			
			<!-- CAMPO POBLACIÓN -->
			<cfcase value="12" delimiters=",">
				<!--- <cfset objCampo = wirebox.getInstance('campoFormularioPoblacion').init(local.campo)> --->
			</cfcase>
			
			<!-- CAMPO PAÍS -->
			<cfcase value="13" delimiters=",">
				<!--- <cfset objCampo = wirebox.getInstance('campoFormularioPais').init(local.campo)> --->
			</cfcase>
			<!--- ENDTODO: END PENDIENTE --->
			
			<!-- CAMPO FECHA -->
			<cfcase value="14" delimiters=",">
				<cfset objCampo = wirebox.getInstance('campoFormularioFecha')>

				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'date'>
				<cfset meta['inputType']                 = 'input'>
				<cfset meta['format']                    = 'ISO 8601'>
				<cfset meta['timezone']                  = 'Europe/Madrid'>
				<cfset meta['configuration']['readonly'] = numericToBoolean(campo.solo_lectura)>
			</cfcase>
			
			<!-- CAMPO RELACIÓN ENTRE PARTICIPANTES -->
			<cfcase value="16" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'none'>
				<cfset meta['inputType']                 = 'none'>
				<cfset meta['configuration']['readonly'] = numericToBoolean(campo.solo_lectura)>
			</cfcase> 
		</cfswitch>
		
		<cfreturn meta>
	</cffunction>

	<cffunction name="numericToBoolean" returnType="boolean">
		<cfargument name="value" type="any" required="true" default="0">
		
		<cfset var out = false>

		<cfif IsValid('numeric', arguments.value)>
			<cfswitch expression="#arguments.value#">
				<cfcase value="0"><cfset out = false></cfcase>
				<cfcase value="1"><cfset out = true></cfcase>
				<cfdefaultcase><cfset out = false></cfdefaultcase> 
			</cfswitch>
		</cfif>		

		<cfreturn out>
	</cffunction>

	<cffunction name="obtainValues" returnType="any">
		<cfargument name="id_campo" type="any" required="true" default="0">
		
		<cfset values = {}>
		
		<cfset var cacheKey = 'q-form-obtainValues-#id_campo#'>
		
		<cfif cache.lookup(cacheKey)>
			<cfset values = cache.get(cacheKey)>
		<cfelse>
			<cfset var tmpVal = dao.cargarValoresCampoGrupoFormulario(arguments.id_campo)>
			<cfloop query="tmpVal">
				<!--- <cfset StructInsert(values, id_valor, { 'id' : id_valor, 'title': titulo })> --->
				<cfset values[id_valor] = titulo>
			</cfloop>
			
			<cfset cache.set(cacheKey, values, 60, 30)>
		</cfif>
	
		<cfreturn values>
	</cffunction>

	<cffunction name="camposPorEvento" returnType="any" output="false"  hint="">
		<cfargument name="filtered" type="any" required="false" default="true">

		<cfset var allGroups = dao.groupsByEvent()>
		<cfset var fields 	 = dao.allFieldsByGroupDefault(valueList(allGroups.id_agrupacion))>
		
		<cfif filtered>
			<cfset fields = valueList(fields.id_campo)>
		</cfif>

		<cfreturn fields>
	</cffunction>

	<cffunction name="formFields">
		<cfset var formFields = this.meta(session.id_evento)>

		<cfreturn formFields.data.records>
	</cffunction>

	<cffunction name="defaultFields">
		<cfargument name="id_evento" type="any" required="true">
		<cfargument name="language" type="any" required="true">

		<cfreturn dao.defaultFields(arguments.id_evento, arguments.language)>
	</cffunction>
</cfcomponent>