<!--
  ParticipanteDAO
 -->
	<cfcomponent output="false" accessors="true" hint="ParticipanteDAO" extends="models.BaseModel">
	<cftimer label= "models/ParticipanteDAO"></cftimer>

	<!--- Properties --->
	<cfproperty name="tParticipanteService" inject="model:tipoparticipante.TipoParticipanteService">
	<cfproperty name="qs" inject="model:QueryService">
	<cfproperty name="formS" inject="model:formulario.FormularioService">
	<cfproperty name="SECRET_KEY" default='zTHCdTeo782ox5QBtpu1q8d2gwKe8fHp'>


	<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="ParticipanteDAO" output="false" hint="constructor">
		<cfscript>	
			return this;
		</cfscript>
	</cffunction>

	<!------------------------------------------- PUBLIC ------------------------------------------->
	<!--- 
		Todos los participantes
		@event 
		@rc	
	 --->
	<cffunction name="all" hint="Todos los participantes" output="false" returntype="Query">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="nopagination" type="boolean" default="false">

		<cfset arguments.event.paramValue('total', '')>
		<cfset arguments.event.paramValue('page', 1)>
		<cfset arguments.event.paramValue('rows', queryLimit)>

		<cfif arguments.rc.total EQ ''>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
		</cfif>

		<cfset var pagination = "#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">

		<cfset var link = getURLLink(arguments.rc.token)>

		<cfif NOT structKeyExists(arguments.rc, 'ids')>			
			<cfif NOT isdefined('session.usersession.defaults.form.fields') OR isEmpty(session.usersession.defaults.form.fields)>					
				<cfset session.usersession.defaults.form.fields = valueList(defaultValues(arguments.id_evento).id_campo)>
			</cfif>
			<cfset arguments.event.paramValue('ids', session.usersession.defaults.form.fields)>			
		</cfif>

		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
		
		<cfset var link = getURLLink(arguments.rc.token)>
		
		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT 
				DISTINCT p.id_participante, 
				#datosConsulta#,
				CONCAT("#link#/participantes/",id_participante,"?ids=#arguments.rc.ids#") AS _link
				FROM vParticipantes p 
				WHERE p.id_evento IN (#arguments.id_evento#)
				<cfif NOT nopagination>
					LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
				</cfif>
			</cfsavecontent>
		</cfoutput>

		<cfquery name="local.qParticipantes" datasource="#application.datasource#">
			#consulta#
		</cfquery>

		<cfset local.qParticipantes = qs.rellenarDatosInforme(consulta, local.qParticipantes)>

		<cfreturn local.qParticipantes>
	</cffunction>

	<!--- 
		Obtiene participante por ID
		@event 
		@rc 
		@id_participante numeric ID del participante que se requiere
	 --->
	<cffunction name="get" hint="Obtiene participante por ID" output="false" returntype="Query">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_evento">
		<cfargument name="id_participante" type="numeric" required="true">

		<cfif NOT structKeyExists(arguments.rc, 'ids')>			
			<cfif NOT isdefined('session.usersession.defaults.form.fields')>					
				<cfset session.usersession.defaults.form.fields = valueList(defaultValues(arguments.id_evento).id_campo)>
			<cfelseif isEmpty(session.usersession.defaults.form.fields)>
				<cfset session.usersession.defaults.form.fields = valueList(defaultValues(arguments.id_evento).id_campo)>
			</cfif>
			<cfset arguments.event.paramValue('ids', session.usersession.defaults.form.fields)>			
		</cfif>

		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
		
		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT 
					p.id_participante, 
					p.id_tipo_participante AS 'id_tipo_participante',
					#datosConsulta#
				FROM vParticipantes p
				WHERE p.id_participante=#arguments.id_participante#
				AND p.id_evento IN (#session.id_evento#)
			</cfsavecontent>
		</cfoutput>
	
		<cfquery name="local.participantesByID" datasource="#application.datasource#">
			#consulta#
		</cfquery>

		<cfset local.participantesByID = qs.rellenarDatosInforme(consulta, local.participantesByID)>

		<cfreturn local.participantesByID>
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

		<cfquery name="local.tipoParticipante" datasource="#application.datasource#">
			SELECT id_tipo_participante 
			FROM vTiposDeParticipantes 
			WHERE LOWER(nombre)=<cfqueryparam value="#arguments.tipo_participante#" CFSQLType="CF_SQL_VARCHAR">
			AND eventos_id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfquery>

		<cfif arguments.rc.total EQ ''>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
		</cfif>

		<cfset var pagination="#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">
		
		<cfset var link=getURLLink(arguments.rc.token)>

		<!--- TODO: Agregar ids de filtro campos para esta consulta. --->

		<cfquery name="local.participantesByTipo" datasource="#application.datasource#">
			SELECT nombre, apellidos, email_participante, nombre_empresa,
			CONCAT("#link#/participantes/", id_participante) AS _link
			FROM vParticipantes
			WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
			AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
		</cfquery>
			
		<cfreturn local.participantesByTipo>
	</cffunction>

	<cffunction name="defaultValues" returntype="any">
		<cfargument name="id_evento" required="true">
		<cfargument name="filtered" type="boolean" default="false" required="false">

		<cfset var campos = formS.camposPorEvento(arguments.id_evento, arguments.filtered)>

		<cfreturn campos>
	</cffunction>

	<cffunction name="genCreate" hint="Inserta un nuevo participante" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="record">
		<cfargument name="k">

		<cfset fs = formS.getByTipoParticipante(record.id_tipo_participante, event, rc)>

		<cfif fs.data.records.recordCount LTE 0>
			<cfthrow message="'Tipo de Participante' or 'Formulario' or incorrect" detail="Invalid id_tipo_participante">
		</cfif>

		<cfset record["id_formulario"] = fs.data.records.id_formulario>

		<cfset var e = generateEmailAndPassword(record.email)>
		<cfset ep.email = e.email>
		<cfset hasLogin = "'#ep.email#',">
		<cfset ep.password = e.password>

		<cfif structKeyExists(record, 'login')>
			<cfset ep.email    = record.login>
			<cfset hasLogin = "'#record.login#',">
		<!--- <cfelse>
			<cfset hasLogin = "'#ep.email#',"> --->
		</cfif>

		<cfset hasPassword = ''>
		<cfif structKeyExists(record, 'password')>
			<cfset ep.password = record.password>
			<cfset hasPassword = "'#encriptar(record.password)#',">
		<cfelse>
			<cfset hasPassword = "'#encriptar(ep.password)#',">
		</cfif>

		<cfif getHTTPRequestData().method EQ 'POST'>
			<!--- <cfset record["login"] = ep.email> --->
			<cfset record["password"] = ep.password>
		</cfif>

		<cfif NOT structKeyExists(record, 'inscrito')>
			<cfset record.inscrito = 0>
		</cfif>
			
		<!--- login,
				password,
				fecha_alta,
				activo,
				formulariosEventos_id_formulariosEventos,
				tiposDeParticipantes_id_tipo_participante,
				importado,
				inscrito,
				id_evento,
				idiomas_id_idioma,
				insitu,
				ip_alta,
				user_agent_alta --->
		
		<cfset a = "(
			#hasLogin#
			#hasPassword#
			NOW(),  
			1,  
			#record.id_formulario#, 
			#record.id_tipo_participante#, 
			1, 
			#record.inscrito#, 
			#session.id_evento#, 
			'#session.language#', 
			0, 
			'#cgi.REMOTE_ADDR#', 
			'#cgi.HTTP_USER_AGENT#'
		)"> 

		<cfset b = genCreateDatos(structCopy(record), k)>
		<cfset c = genUpdateParticipante(record, k)>

		<cfreturn { 'a' = a, 'b' = b, 'c' = c }>
	</cffunction>

	<cffunction name="genCreateDatos" output="false" returntype="array">
		<cfargument name="record">
		<cfargument name="k">

		<cfset var out = []>

		<cfset structDelete(arguments.record, 'id_formulario')>
		<cfset structDelete(arguments.record, 'id_tipo_participante')>
		<cfset structDelete(arguments.record, 'email')>
		<cfset structDelete(arguments.record, 'login')>
		<cfset structDelete(arguments.record, 'password')>
		<cfset structDelete(arguments.record, 'inscrito')>

		<cfinclude template="/includes/helpers/ApplicationHelper.cfm">

		<cfloop collection="#arguments.record#" item="key">
			<cfif isDate(arguments.record[key])>
				<cfset arguments.record[key] = ISOToDateTime(arguments.record[key])>
			</cfif>
			<cfset arrayAppend(out, "(#key#, [IDFIELD_#k#], '#arguments.record[key]#', #session.id_evento#, NOW())")>
		</cfloop>

		<cfreturn out>
	</cffunction>

	<cffunction name="genUpdateParticipante" output="false" returntype="string">
		<cfargument name="record">
		<cfargument name="k">

		<cfset updateConsulta = ''>

		<cfset QCamposFijos = listadoCamposFijosFormulario(arguments.record.id_formulario)>

		<cfif QCamposFijos.RecordCount gt 0>
			
			<cfinclude template = "/default/admin/helpers/string.cfm">
			<!--- <cfinclude template = "/default/admin/helpers/participantes/cs.cfm"> --->
			
			<cfset hasLogin = ''>
			<cfif structKeyExists(record, 'login')>
				<cfset hasLogin = "login = '#encodeString(record.login)#',">
			</cfif>

			<cfset hasPassword = ''>
			<cfif structKeyExists(record, 'password')>
				<cfset hasPassword = "password = '#encriptar(record.password)#',">
			</cfif>

			<cfset hasTipoParticipante = ''>
			<cfif structKeyExists(record, 'id_tipo_participante')>
				<cfset hasTipoParticipante = "tiposDeParticipantes_id_tipo_participante = #record.id_tipo_participante#,">
			</cfif>
			<!--- <cfset var email = NOT structKeyExists(record, 'login') AND structKeyExists(record, 'email') ? record.email : record.login> --->
			
			<cfset hasinscrito = ''>
			<cfif structKeyExists(record, 'inscrito')>
				<cfset hasinscrito = "inscrito = #record.inscrito#">
			</cfif>
			<cfoutput>
				<cfsavecontent variable = "updateConsulta">
					UPDATE participantes
					SET 
						fecha_modif      = NOW(),
						#hasLogin#
						#hasPassword#
						#hasTipoParticipante#
						user_agent_modif = '#encodeString(cgi.HTTP_USER_AGENT)#',					
						ip_modif         = '#cgi.REMOTE_ADDR#',			
						#hasinscrito#			
					<cfloop query="QCamposFijos">
						<cfif structKeyExists(arguments.record, id_campos)>
							<cfset var VAL_CF = valorCampo(arguments.record, id_campos)>

							<cfswitch expression="#descripcion#">
								<cfcase value="email_participante,email_empresa" delimiters=",">
									<cfset val_cf = lcase(val_cf)>
								</cfcase>
								<cfcase value="nombre_participante,apellidos_participante,nombre_empresa" delimiters=",">
									<cfset val_cf = initCap(val_cf)>
								</cfcase>
								<cfcase value="baja_newsletter">
									<cfif (val_cf is '')>
										<cfset val_cf = 1>
									</cfif>
								</cfcase>
								<cfcase value="email_valido">
									<cfif (val_cf is '')>
										<cfset val_cf = 1>
									</cfif>
								</cfcase>
								<cfdefaultcase>
									<cfset val_cf = lcase(val_cf)>
								</cfdefaultcase>
							</cfswitch>
							, cf_#descripcion# = '#encodeStringWithStrip(VAL_CF)#'
						</cfif>
					</cfloop>
					
					WHERE id_participante = [IDFIELD_#k#]
					AND id_evento IN (#session.id_evento#);
				</cfsavecontent>
			</cfoutput>

		</cfif>

		<cfreturn updateConsulta>
	</cffunction>

	<cffunction name="doCreate" hint="Inserta un nuevo participante" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="vList">

		<cfquery name="local.newp" result="rnewp" datasource="#application.datasource#">
			INSERT INTO participantes (
				login,
				password,
				fecha_alta,
				activo,
				formulariosEventos_id_formulariosEventos,
				tiposDeParticipantes_id_tipo_participante,
				importado,
				inscrito,
				id_evento,
				idiomas_id_idioma,
				insitu,
				ip_alta,
				user_agent_alta
			) VALUES
			#arrayToList(vList.a, ",")#
		</cfquery>

		<cfset var ids = rnewp.generatedkey>

		<cfloop list="#ids#" item="id" index="i">
			<cfloop array="#vList.b#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
					<cfset vList.b[f] = replace(vList.b[f], "[IDFIELD_#i#]", id)>			
				</cfif>
			</cfloop>
			<cfloop array="#vList.c#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
					<cfset vList.c[f] = replace(vList.c[f], "[IDFIELD_#i#]", id)>			
				</cfif>
			</cfloop>
		</cfloop>

		<cfset var idsD  = doCreateDatos(vList.b)>
		<cfset var idsDE = doCreateExtension(ids)>
		<cfset doUpdateParticipante(vList.c)>

		<cfreturn { 
			"new_id_participante" : ids, 
			<!--- "new_id_participantesDatos" : idsD  --->
		}>
	</cffunction>
	
	<cffunction name="doCreateDatos" returntype="any">
		<cfargument name="vList"> 

		<cfquery name="local.createDatos" result="rnewpd" datasource="#application.datasource#">
			INSERT INTO participantesDatos 
				(campos_id_campos, participantes_id_participante, valor, eventos_id_evento, fecha_alta)
			VALUES
				#arrayToList(vList, ",")#
		</cfquery>

		<cfreturn rnewpd.generatedkey>
	</cffunction>

	<cffunction name="doCreateExtension" returntype="any">
		<cfargument name="ids"> 

		<cfset ids = listToArray(ids)>

		<cfloop item="id" array="#ids#">			
			<cfsavecontent variable="insert">
				<cfoutput>
					INSERT INTO participantesDatosExtension 
					(
						id_participante, 
						id_evento, 
						fecha_alta_api
					)
					VALUES 
					(
					#replace(id, '),(', ',',  'ALL')#, 
					#session.id_evento#,
					NOW()
					)
					ON DUPLICATE KEY UPDATE fecha_modif_api = NOW()
				</cfoutput>
			</cfsavecontent>
		
			<cfquery name="local.extension" result="rnewpde" datasource="#application.datasource#">
				#insert#
			</cfquery>
		</cfloop>

		<cfreturn rnewpde.generatedkey>
	</cffunction>

	<cffunction name="doUpdateExtension" returntype="any">
		<cfargument name="ids"> 

		<cfif isArray(ids)>
			<cfloop array=#ids# item="it" index="i">
				<cfquery name="local.extension" result="rnewpde" datasource="#application.datasource#">
					UPDATE participantesDatosExtension 
					SET fecha_modif_api = NOW()
					WHERE id_participante = #it#
					AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				</cfquery>

				<cfif rnewpde.recordCount EQ 0>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="doUpdateParticipante" access="public" returntype="void" output="false">
		<cfargument name="vList" required="true"> 

		<cfset updated = 0>

		<!--- https://stackoverflow.com/questions/6299326/coldfusion-multiple-sql-statements-in-a-query --->
		<cfloop array="#arguments.vList#" item="upd" index="i">
			<cfquery name="local.update" result="rupdp" datasource="#application.datasource#">
				#upd#
			</cfquery>
		
			<cfset updated = updated + rupdp.recordCount>
		</cfloop>

		<!--- <cfif NOT updated EQ arrayLen(arguments.vList)> <cfthrow message="Update failed"> </cfif> --->

		<!--- <cfreturn updated> --->
	</cffunction>

	<cffunction name="configFields">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">

		<cfset var formFields = formS.formFields()>
		<cfset var reqFields = {}>

		<cfscript>
			reqFields = structFilter(formFields, function(key, value) {
				return structKeyExists(value.configuration, 'required') AND value.configuration.required == true;
			});

			var myKeyList = structKeyList(reqFields);

			for(value in listToArray(myKeyList)) {
				if(arrayFind(keyList, value) == 0) {
					throw(message="Have not been found [#value#] into [#arrayToList(keyList)#] of the required fields [#myKeyList#]" );
				}
			}
		</cfscript>
		
		<cfreturn reqFields>
	</cffunction>

	<cffunction name="generateEmailAndPassword">
		<cfargument name="email">
		
		<cfset part_email = arguments.email>

		<cfif part_email is ''> <cfset part_email = 'part@#right(gettickCount(), 7)#'> </cfif>

		<cfset var password = listFirst(part_email, '@') & '_' & right(gettickcount(), 5)>

		<cfreturn {
			'email'= part_email,
			'password'= password
		}>
	</cffunction>

	<cffunction name="listadoCamposFijosFormulario" access="public" returntype="query" output="false">
		<cfargument name="id_formulario" required="true" type="string">

		<cfquery name="local.QCamposFijos" datasource="#application.datasource#">
			SELECT
				c.id_campos,
				c.tiposCamposFijos_id_tipo_campo_fijo AS campoFijo,
				tcf.descripcion
			FROM campos c
			INNER JOIN tiposCamposFijos tcf 
			ON tcf.id_tipo_campo_fijo = c.tiposCamposFijos_id_tipo_campo_fijo
			INNER JOIN agrupacionesDeCampos gf 
			ON gf.id_agrupacion = c.agrupacionesDeCampos_id_agrupacion
			INNER JOIN seleccionAgrupacionesDeCamposFormularios sac 
			ON gf.id_agrupacion = sac.agrupacionesDeCampos_id_agrupacion
			AND sac.formulariosEventos_id_formulariosEventos = <cfqueryparam value="#arguments.id_formulario#" cfsqltype="cf_sql_integer">
			WHERE (
				c.fijo = 1
				OR c.tiposCamposFijos_id_tipo_campo_fijo in (1, 3, 2, 5, 4, 6, 9, 11)
			)
			AND c.fecha_baja IS NULL
		</cfquery>

		<cfreturn local.QCamposFijos>
	</cffunction>

	<cffunction name="encriptar" return="string" output="false">
		<cfargument name="cadena" required="true">
		
		<cfset var s = encrypt(arguments.cadena, SECRET_KEY, 'DESEDE', 'HEX')>
		
		<!--- ENCRIPTAMOS --->
		<cfreturn s>
	</cffunction>

	<cffunction name="desEncriptar" return="string" output="false">
		<cfargument name="cadena" required="true">
		<cfset var s = ''>
		
		<cftry>
			<!--- DESENCRIPTAMOS --->
			<cfset s = decrypt(arguments.cadena, SECRET_KEY, 'DESEDE', 'HEX')>
		<cfcatch type="any">
			<cfset s = '-'>
		</cfcatch>
		</cftry>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="valorCampo" access="private" returntype="string">
		<cfargument name="CAMPOS" type="struct" required="true">
		<cfargument name="name" type="string" required="true">

		<cfset var valor = ''>
		<cfif StructKeyExists(arguments.CAMPOS, name)>
			<cfset valor = arguments.CAMPOS[name]>
		</cfif>
		<cfreturn valor>
	</cffunction>

	<cffunction name="getByLogin" returntype="query">
		<cfargument name="login" type="any" required="true">

		<cfquery name="local.bylogin" datasource="#application.datasource#">
			SELECT login, password FROM participantes
			WHERE login = <cfqueryparam value="#login#" cfsqltype="CF_SQL_VARCHAR">
			AND fecha_baja IS NULL
			AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfquery>

		<cfreturn local.bylogin>
	</cffunction>

	<cffunction name="genUpdateDatos" output="false" returntype="array">
		<cfargument name="record">
		<cfargument name="k">

		<cfset var out = []>
		<cfset var out2 = {}>
		<cfset var tmp = []>
		<cfset var tempid = 0>

		<cfinclude template="/includes/helpers/ApplicationHelper.cfm">

		<cfset now  = now()>

		<cfloop collection="#arguments.record#" item="key">
			<cfset list = listToArray(arguments.record[key])>

			<cfset id = rEReplaceNoCase(list[2],"[^\d]","")>

			<cfif id != tempid>
				<cfset tmp = []>
			</cfif>

			<cfset campo = REReplaceNoCase(list[1],"[^\d]","")>

			<cfset value = list[3]>
			<cfif isDate(value)>
				<cfset value = "'" & ISOToDateTime(value) & "'">
			</cfif>

			<cfset idevento = rEReplaceNoCase(list[4],"[^\d]","")>

			<!--- <cfset arrayAppend(out, "UPDATE participantesDatos 
									SET valor=#value# 
									WHERE campos_id_campos=#campo#
									AND eventos_id_evento=#idevento# 
									AND participantes_id_participante=#id#")> --->
			<cfset arrayAppend(out, "INSERT INTO participantesDatos (campos_id_campos, valor, participantes_id_participante, eventos_id_evento)
									VALUES(#campo#, #value#, #id#, #idevento#)
									ON DUPLICATE KEY UPDATE
									valor = #value#")>
		</cfloop>

		<cfreturn out>
	</cffunction>

	<!--- 
		Realiza la modificacion de uno o más participantes, validandolo por el correo
	 --->
	<cffunction name="doUpdate"  output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="vList">

		<cfset var out = []>
		<cfset var lgs = []> 
		<cfset var ids = []>

		<cfloop array="#vList.d#" index="i" item="item">			
			<!--- 
			SELECT id_participante AS 'id' FROM participantes
			WHERE (
				login = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
				OR cf_email_participante = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
			)
			AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND fecha_baja IS NULL
			--->
			<cfquery name="local.logins" datasource="#application.datasource#">
				SELECT id_participante AS 'id' FROM participantes
				WHERE cf_email_participante = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
				AND id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND fecha_baja IS NULL
			</cfquery>

			<cfif local.logins.recordcount EQ 0>
				<cfthrow message="Email ['#item#'] does not exists or could be duplicated">
			</cfif>
			
			<cfset arrayAppend(ids, local.logins.id)>

			<cfloop array="#vList.b#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
					<cfset vList.b[f] = replace(vList.b[f], "[IDFIELD_#i#]", local.logins.id)>			
				</cfif>
			</cfloop>
			
			<cfloop array="#vList.c#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
					<cfset vList.c[f] = replace(vList.c[f], "[IDFIELD_#i#]", local.logins.id)>			
				</cfif>
			</cfloop>
		</cfloop>

		<cfset doUpdateDatos(vList.b)>
		<cfset doUpdateExtension(ids)>
		<cfset doUpdateParticipante(vList.c)>

		<cfreturn { "modif_id_participante" : arrayToList(ids) }>
	</cffunction>

	<!--- TODO: Terminar método de actualizar datos --->
	<cffunction name="doUpdateDatos" returntype="any">
		<cfargument name="vList"> 

		<cfset queries = genUpdateDatos(vList)>

		<cfset doUpdateParticipante(queries)>
	</cffunction>

	<cffunction name="getTipoParticipante" access="public" returntype="Query" output="false">
		<cfargument name="id_evento" required="false" default="id_evento">
		<cfargument name="sidx" required="false" default="id_tipo_participante">
		<cfargument name="sord" required="true" default="ASC">

		<cfquery name="local.qTiposDeParticipantes" datasource="#application.datasource#">
			SELECT id_tipo_participante, nombre
			FROM vTiposDeParticipantes
			WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			ORDER BY #arguments.sidx# #arguments.sord#
		</cfquery>

		<cfreturn local.qTiposDeParticipantes>

		<cfreturn valueList(local.qTiposDeParticipantesPorNombre.id_tipo_participante)>
	</cffunction>

	<!--- 
		Valida la existencia de un participante según los tres campos básicos del formulario; Nombre, Apellido, Email
	 --->
	<cffunction name="exists" access="public" returntype="boolean" output="false">
		<cfargument name="fields" type="struct" required="true">

		<cfset var exists = false>
	
		<cfquery name="local.allFields" datasource="#application.datasource#">
			SELECT COUNT(id_participante) AS 'exists'
			FROM participantes
			WHERE cf_nombre_participante = <cfqueryparam value="#arguments.fields['nombre_participante']#" cfsqltype="CF_SQL_VARCHAR">
			AND cf_apellidos_participante = <cfqueryparam value="#arguments.fields['apellidos_participante']#" cfsqltype="CF_SQL_VARCHAR">
			AND cf_email_participante = <cfqueryparam value="#arguments.fields['email_participante']#" cfsqltype="CF_SQL_VARCHAR">
			AND fecha_baja IS NULL
		</cfquery>

		<cfif local.allFields.recordcount GT 0>
			<cfset exists = local.allFields.exists GT 0 ? true : false>
		</cfif>

		<cfreturn exists>
	</cffunction>
</cfcomponent>