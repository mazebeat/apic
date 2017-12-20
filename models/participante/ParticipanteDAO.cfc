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
		<cfargument name="event">
		<cfargument name="rc">

		<cfset arguments.event.paramValue('total', '')>
		<cfset arguments.event.paramValue('page', 1)>
		<cfset arguments.event.paramValue('rows', queryLimit)>

		<cfif arguments.rc.total EQ ''>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_evento = <cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
			</cfquery>
			<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
		</cfif>

		<cfset var pagination = "#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">

		<cfset var link = getURLLink(arguments.rc.token)>

		<cfif NOT structKeyExists(arguments.rc, 'ids')>			
			<cfif NOT isdefined('session.usersession.defaults.form.fields') OR isEmpty(session.usersession.defaults.form.fields)>					
				<cfset session.usersession.defaults.form.fields = valueList(defaultValues().id_campo)>
			</cfif>
			<cfset arguments.event.paramValue('ids', session.usersession.defaults.form.fields)>			
		</cfif>

		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
		
		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT DISTINCT p.id_participante, 
					#datosConsulta#,
				CONCAT("#link#/participantes/", id_participante, "?ids=#arguments.rc.ids#") AS _link
				FROM vParticipantes p 
				WHERE p.id_evento = #session.id_evento#
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfsavecontent>
		</cfoutput>
		
		<cfquery name="local.qParticipantes" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
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
		<cfargument name="id_participante" type="numeric" required="true">

		<!--- <cftry> --->
			<cfif NOT structKeyExists(arguments.rc, 'ids')>			
				<cfif NOT isdefined('session.usersession.defaults.form.fields')>					
					<cfset session.usersession.defaults.form.fields = valueList(defaultValues().id_campo)>
				<cfelseif isEmpty(session.usersession.defaults.form.fields)>
					<cfset session.usersession.defaults.form.fields = valueList(defaultValues().id_campo)>
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
					AND p.id_evento=#session.id_evento#
				</cfsavecontent>
			</cfoutput>
		
			<cfquery name="local.participantesByID" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				#consulta#
			</cfquery>

			<cfset local.participantesByID = qs.rellenarDatosInforme(consulta, local.participantesByID)>

			<cfreturn local.participantesByID>
		<!--- <cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
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

		<!--- <cftry> --->
			<cfquery name="local.tipoParticipante" datasource="#application.datasource#">
				SELECT id_tipo_participante 
				FROM vTiposDeParticipantes 
				WHERE LOWER(nombre)=<cfqueryparam value="#arguments.tipo_participante#" CFSQLType="CF_SQL_VARCHAR">
				AND eventos_id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
			</cfquery>

			<cfif arguments.rc.total EQ ''>
				<cfquery name="local.qTotal" datasource="#application.datasource#">
					SELECT COUNT(*) AS cantidad
					FROM vParticipantes
					WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
					AND id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
				</cfquery>
				<cfset arguments.event.setValue('total', local.qTotal.cantidad)>
			</cfif>

			<cfset var pagination="#qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)#">
			
			<cfset var link=getURLLink(arguments.rc.token)>

			<!--- TODO: Agregar ids de filtro campos para esta consulta. --->

			<cfquery name="local.participantesByTipo" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT nombre, apellidos, email_participante, nombre_empresa,
				CONCAT("#link#/participantes/", id_participante) AS _link
				FROM vParticipantes
				WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento=<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfquery>
			
			<!--- <cfcatch type="any">
				<cfthrow type="any" message="#cfcatch.Message#">
			</cfcatch>
		</cftry>  --->
		
		<cfreturn local.participantesByTipo>
	</cffunction>

	<cffunction name="defaultValues" returntype="any">
		<cfargument name="filtered" type="boolean" default="false" required="false">

		<cfset var campos = formS.camposPorEvento(filtered)>
	
		<cfreturn campos>
	</cffunction>

	<cffunction name="genCreate" hint="Inserta un nuevo participante" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="record">
		<cfargument name="k">

		<cfset e = { email= '', password= '' }>

		<cfset fs = formS.getByTipoParticipante(arguments.record.id_tipo_participante, arguments.event, arguments.rc)>
		<cfset arguments.record["id_formulario"] = fs.data.records.id_formulario>
		
		<cfif structKeyExists(record, 'login') AND structKeyExists(record, 'password')>
			<cfset ep.email    = arguments.record.login>
			<cfset ep.password = arguments.record.password>
		<cfelse>
			<cfset ep          = generateEmailAndPassword(arguments.record.email)>
			<cfset ep.password = ep.password>
		</cfif>
		<cfset arguments.record["password"] = ep.password>

		<cfset a = "('#ep.email#', '#encriptar(ep.password)#', NOW(), 1, #arguments.record.id_formulario#, #arguments.record.id_tipo_participante#, 0, 0, #session.id_evento#, '#session.language#', 0, '#cgi.REMOTE_ADDR#', '#cgi.HTTP_USER_AGENT#')">
		<cfset b = genCreateDatos(structCopy(record), arguments.k)>
		<cfset c = genUpdateParticipante(arguments.record, arguments.k)>
		
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

		<cfinclude template="/includes/helpers/ApplicationHelper.cfm">

		<cfloop collection="#arguments.record#" item="key">
			<cfif isDate(arguments.record[key])>
				<cfset arguments.record[key] = ISOToDateTime(arguments.record[key])>
			<!--- <cfelseif isNumeric(arguments.record[key])>
				<cfset arguments.record[key] = lsParseNumber(arguments.record[key])>
			<cfelse>
				<cfset arguments.record[key] = "'" & arguments.record[key] & "'"> --->
			</cfif>
			<cfset arrayAppend(out, "(#key#, [IDFIELD_#k#], '#arguments.record[key]#', #session.id_evento#, NOW())")>
		</cfloop>

		<cfreturn out>
	</cffunction>

	<cffunction name="genUpdateParticipante" output="false" returntype="string">
		<cfargument name="record">
		<cfargument name="k">

		<cfset QCamposFijos = listadoCamposFijosFormulario(arguments.record.id_formulario)>

		<cfif QCamposFijos.RecordCount gt 0>
			
			<cfinclude template = "/default/admin/helpers/string.cfm">
			<!--- <cfinclude template = "/default/admin/helpers/participantes/cs.cfm"> --->
			<cfset var login = NOT structKeyExists(record, 'login') AND structKeyExists(record, 'email') ? record.email : record.login>
			<cfoutput>
				<cfsavecontent variable = "updateConsulta">
					UPDATE participantes
					SET 
						fecha_modif               = NOW(),
						login                     = '#encodeString(login)#',
						password                  = '#encriptar(arguments.record.password)#',
						ip_modif                  = '#cgi.REMOTE_ADDR#',
						user_agent_modif          = '#encodeString(cgi.HTTP_USER_AGENT)#'
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
					AND id_evento         = #session.id_evento#;
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
		<cfset var idsU	 = doUpdateParticipante(vList.c)>

		<cfreturn { 
			"new_id_participante"      : ids, 
			"new_id_participantesDatos": idsD
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

	<cffunction name="doCreateExtension">
		<cfargument name="ids"> 

		<cfquery name="local.extension" result="rnewpde" datasource="#application.datasource#">
			INSERT INTO participantesDatosExtension 
				(id_participante)
			VALUES 
				(#replace(arguments.ids, ',', '),(', 'ALL')#)
		</cfquery>

		<cfreturn rnewpde.generatedkey>
	</cffunction>

	<cffunction name="doUpdateParticipante" access="public" returntype="void" output="false">
		<cfargument name="vList"> 
		
		<!--- https://stackoverflow.com/questions/6299326/coldfusion-multiple-sql-statements-in-a-query --->
		<!--- #arrayToList(vList, ' ')# --->
		<cfset updated = 0>

		<cfloop array="#vList#" item="upd" index="i">
			<cfquery name="local.update" result="rupdp" datasource="#application.datasource#">
				#upd#
			</cfquery>
			<cfset updated = updated + rupdp.recordCount>
		</cfloop>

		<cfif NOT updated EQ arrayLen(vList)>
			<cfthrow message="Update failed">
		</cfif>
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

		<cfif part_email is ''>
			<cfset part_email = 'part@#right(gettickCount(), 7)#'>
		</cfif>

		<cfset var password = listFirst(part_email, '@') & '_' & right(gettickcount(), 5)>

		<cfreturn {
			'email'= part_email,
			'password'= password
		}>
	</cffunction>

	<cffunction name="listadoCamposFijosFormulario" access="public" returntype="query" output="false">
		<cfargument name="id_formulario" required="true" type="string">

		<cfquery name="local.QCamposFijos" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,10,0)#">
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

	<cffunction name="getByLoginPassword" returntype="query">
		<cfargument name="login" type="any" required="true">
		<cfargument name="password" type="any" required="false">

		<!--- <cfif isdefined("url.debug")>
			<cfdump var="#arguments#" label="arguments">
			<cfabort>
		</cfif> --->
		<!--- <cftry> --->
			<cfquery name="local.bylogin" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT login, password FROM participantes
				WHERE login = <cfqueryparam value="#login#" cfsqltype="CF_SQL_VARCHAR">
				AND fecha_baja IS NULL
				AND id_evento = <cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER">
				<cfif NOT isEmpty(password)>
					AND password = <cfqueryparam value="#password#" cfsqltype="CF_SQL_VARCHAR">
				</cfif> 
			</cfquery>

			<cfreturn local.bylogin>
		<!--- <cfcatch type="any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
	</cffunction>
</cfcomponent>