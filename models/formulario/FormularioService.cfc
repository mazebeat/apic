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

		<cfset var cacheKey = 'q-form-all-#id_evento#'>

		<cfif cache.lookup(cacheKey)>
			<cfset var allForms = cache.get(cacheKey)>
		<cfelse>
			<cfset var allForms = dao.byEvento(arguments.id_evento)>

			<cfset cache.set(cacheKey, allForms, 60, 30)>
		</cfif>
		
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
		<cfset var campos   = createObject("java", "java.util.LinkedHashMap").init()>
		
		<cfset var cacheKey = 'q-formS-get-#id_formulario#'>

			<cfif cache.lookup(cacheKey)>
			<cfset campos = cache.get(cacheKey)>
		<cfelse>
			<cfset var allGroups = dao.get(arguments.id_formulario)>
		</cfif>

		<cfset s.data.records           = campos>
		<cfset s.data.totalCampos       = structCount(campos)>
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
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje: "", data : { "records":{},  "count": 0, "total": 0 } }>
		<cfset var campos  = createObject("java", "java.util.LinkedHashMap").init()>
		
		<cfset var allForms  = dao.byEvento(arguments.id_evento)>
		
		<cfset var allGroups = dao.groupsByEvent()>
		<cfset var fields 	 = dao.allFieldsByGroup(valueList(allGroups.id_agrupacion))>

		<cfloop query="fields">
			<cfset campos[id_agrupacion][id_campo] = obtainMetaOfField(id_campo)>
		</cfloop>

		<cfset s.data.records           = campos>
		<cfset s.data.totalAgrupaciones = allGroups.recordCount>
		<cfset s.data.totalCampos       = structCount(campos)>
		<cfset s.data.total             = structCount(campos) +  allGroups.recordCount>

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
			'configuracion': {}
			<!---
			'type'         : 'text',
			'configuracion': {
				'required'    : false,
				'readonly'    : false,
				'comprobacion': false,
				'onlyAlpha'   : '',
				'minlength'   : 0,
				'maxlength'   : 0,
			}, 
			'valores' : {} 
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
				<cfset meta['configuracion']['onlyAlpha'] = numericToBoolean(config.alfabetico)>
				<cfset meta['configuracion']['required']  = numericToBoolean(config.obligatorio)>
				<cfset meta['configuracion']['readonly']  = numericToBoolean(config.solo_lectura)>
				<cfset meta['configuracion']['minlength'] = config.min_chars>
				<cfset meta['configuracion']['maxlength'] = config.max_chars>
			</cfcase>

			<!-- CAMPO DE EMAIL -->
			<cfcase value="6,19,20" delimiters=",">
				<cfset objCampo = wirebox.getInstance('CampoFormularioText')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['inputType']                     = 'input'>
				<cfset meta['name']                          = isEmpty(config.titulo) ? campo.titulo: config.titulo>
				<cfset meta['type']                          = 'email'>
				<cfset meta['configuracion']['onlyAlpha']    = numericToBoolean(config.alfabetico)>
				<cfset meta['configuracion']['required']     = numericToBoolean(config.obligatorio)>
				<cfset meta['configuracion']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuracion']['comprobacion'] = numericToBoolean(config.comprobacion)>
				<cfset meta['configuracion']['minlength']    = config.min_chars>
				<cfset meta['configuracion']['maxlength']    = config.max_chars>
			</cfcase>
			
			<!-- CAMPO LISTA -->
			<cfcase value="2" delimiters=",">
				<cfset meta['inputType'] = 'select'>

				<cfset meta['inputType']                     = 'select'>
				<cfset meta['name']                          = campo.titulo>
				<cfset meta['type']                          = 'email'>
				<cfset meta['configuracion']['required']     = numericToBoolean(campo.obligatorio)>
				<cfset meta['configuracion']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuracion']['comprobacion'] = numericToBoolean(campo.comprobacion)>
				<cfset meta['valores']                    	 = obtainValues(campo.id_campo)>
			</cfcase>
			
			<!-- CAMPO MULTISELECCION -->
			<cfcase value="3" delimiters=",">
				<cfset meta['inputType'] = 'input'>
				<cfset meta['name']      = campo.titulo>
				<cfset meta['type']      = 'checkbox'>
				<cfset meta['valores']   = obtainValues(campo.id_campo)>
			</cfcase>
			
			<!-- CAMPO RADIO -->
			<cfcase value="4" delimiters=",">
				<cfset objCampo = wirebox.getInstance('CampoFormularioRadio')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['inputType']                     = 'input'>
				<cfset meta['name']                          = config.titulo>
				<cfset meta['type']                          = 'radio'>
				<cfset meta['configuracion']['onlyAlpha']    = numericToBoolean(config.alfabetico)>
				<cfset meta['configuracion']['required']     = numericToBoolean(config.obligatorio)>
				<cfset meta['configuracion']['readonly']     = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuracion']['comprobacion'] = numericToBoolean(config.comprobacion)>
				<cfset meta['configuracion']['minlength']    = config.min_chars>
				<cfset meta['configuracion']['maxlength']    = config.max_chars>
				<cfset meta['valores']                       = { '#ucase(traduc.get(35))#': 1, '#ucase(traduc.get(36))#': 0 }>
			</cfcase>
			
			<!-- CAMPO MEMO -->
			<cfcase value="5" delimiters=",">
				<cfset objCampo = wirebox.getInstance('campoFormularioText')>
				
				<cfset var config = objCampo.getConfiguracion(local.campo)>	

				<cfset meta['name']                       = isEmpty(config.titulo) ? campo.titulo: config.titulo>
				<cfset meta['inputType']                  = 'textarea'>
				<cfset meta['configuracion']['onlyAlpha'] = numericToBoolean(config.alfabetico)>
				<cfset meta['configuracion']['required']  = numericToBoolean(config.obligatorio)>
				<cfset meta['configuracion']['readonly']  = numericToBoolean(campo.solo_lectura)>
				<cfset meta['configuracion']['minlength'] = config.min_chars>
				<cfset meta['configuracion']['maxlength'] = config.max_chars>
			</cfcase>
			
			<!-- CAMPO IMAGEN -->
			<cfcase value="9" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['inputType']                 = 'img'>
				<cfset meta['configuracion']['readonly'] = numericToBoolean(campo.solo_lectura)>
			</cfcase>
			
			<!-- CAMPO WEB -->
			<cfcase value="10" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'url'>
				<cfset meta['inputType']                 = 'input'>
				<cfset meta['configuracion']['readonly'] = numericToBoolean(campo.solo_lectura)>
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

				<cfset meta['name']                       = campo.titulo>
				<cfset meta['type']                       = 'date'>
				<cfset meta['inputType']                  = 'input'>
				<cfset meta['configuracion']['readonly']  = numericToBoolean(campo.solo_lectura)>
			</cfcase>
			
			<!-- CAMPO RELACIÓN ENTRE PARTICIPANTES -->
			<cfcase value="16" delimiters=",">
				<cfset meta['name']                      = campo.titulo>
				<cfset meta['type']                      = 'none'>
				<cfset meta['inputType']                 = 'none'>
				<cfset meta['configuracion']['readonly'] = numericToBoolean(campo.solo_lectura)>
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
		
		<cfset valores = {}>
		
		<cfset var cacheKey = 'q-form-obtainValues-#id_campo#'>
		
		<cfif cache.lookup(cacheKey)>
			<cfset valores = cache.get(cacheKey)>
		<cfelse>
			<cfset var tmpVal = dao.cargarValoresCampoGrupoFormulario(arguments.id_campo)>
			
			<cfloop query="tmpVal">
				<cfset valores[id_valor] = titulo>
			</cfloop>

			<cfset cache.set(cacheKey, valores, 60, 30)>
		</cfif>
	
		<cfreturn valores>
	</cffunction>

	<cffunction name="camposPorEvento" returnType="any" output="false"  hint="">
		<cfset var allGroups = dao.groupsByEvent()>
		<cfset var fields 	 = dao.allFieldsByGroupDefault(valueList(allGroups.id_agrupacion))>
	
		<cfset fields = valueList(fields.id_campo)>

		<cfreturn fields>
	</cffunction>
</cfcomponent>