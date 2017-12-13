<!--
  ParticipanteDAO
 -->
<cfcomponent output="false" accessors="true" hint="ParticipanteDAO" extends="models.BaseModel">
	<cftimer label= "models/ParticipanteDAO"></cftimer>

	<!--- Properties --->
	<cfproperty name="tParticipanteService" inject="model:tipoparticipante.TipoParticipanteService">
	<cfproperty name="qs" inject="model:QueryService">
	<cfproperty name="formS" inject="model:formulario.FormularioService">

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
				<cfset session.usersession.defaults.form.fields = defaultValues()>
			</cfif>
			<cfset arguments.event.paramValue('ids', session.usersession.defaults.form.fields)>			
		</cfif>

		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids)>
		
		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT DISTINCT p.id_participante, 
					#datosConsulta#,
				CONCAT("#link#/participantes/", id_participante) AS _link
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
					<cfset session.usersession.defaults.form.fields = defaultValues()>
				<cfelseif isEmpty(session.usersession.defaults.form.fields)>
					<cfset session.usersession.defaults.form.fields = defaultValues()>
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
		
		<cfreturn s>
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

	<cffunction name="create" hint="Inserta un nuevo participante" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="dataFields">

		<cfset var dataFields = event.getHTTPContent( json=true )>
		
		<cftry>
			<cfset var idtipoparticipante = dataFields.id_tipo_participante>
			<cfset var idformulario = 1>
			<cfset structDelete(dataFields, 'id_tipo_participante')>
		<cfcatch>
			<cfthrow message="ID Tipo Participante did not found it">
		</cfcatch>
		</cftry>
		
		<cfset var defaultFields = formS.camposPorEvento(filtered=false)>

		<cfquery name="local.findout" dbtype="query"> 
			SELECT * AS q 
			FROM defaultFields
			WHERE id_campo IN (#structKeyList(dataFields, ",")#)
			AND (titulo LIKE '%mail%' OR titulo LIKE '%correo%')
		</cfquery>

		<cfif local.findout.recordcount LTE 0>
			<cfthrow message="Email does not exists">
		</cfif>

		<cfset var email = structFindKey(dataFields, local.findout.id_campo)>

		<cfset var p = new Participante()>
		<cfset p.setEmail_Participante(arrayFirst(email).value)>
		<cfset p.generateEmail()>
		
		<cftransaction> 
			<cftry> 
				<!--- code to run ---> 
				<cfquery name="local.newp" result="rnewp" datasource="#application.datasource#">
					INSERT INTO participantes
					(
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
					)
					VALUES
					(
						<cfqueryparam value="#p.getLogin()#" CFSQLType="CF_SQL_VARCHAR">,
						<cfqueryparam value="#p.getPassword()#" CFSQLType="CF_SQL_VARCHAR">,
						<cfqueryparam value="#NOW()#" CFSQLType="CF_SQL_TIMESTAMP">,
						<cfqueryparam value="#1#" CFSQLType="CF_SQL_TINYINT">,
						<cfqueryparam value="#idformulario#" CFSQLType="CF_SQL_INTEGER">,
						<cfqueryparam value="#idtipoparticipante#" CFSQLType="CF_SQL_INTEGER">,
						<cfqueryparam value="#0#" CFSQLType="CF_SQL_TINYINT">,
						<cfqueryparam value="#0#" CFSQLType="CF_SQL_TINYINT">,
						<cfqueryparam value="#session.id_evento#" CFSQLType="CF_SQL_INTEGER">,
						<cfqueryparam value="#session.language#" CFSQLType="CF_SQL_VARCHAR">,
						<cfqueryparam value="#0#" CFSQLType="CF_SQL_TINYINT">,
						<cfqueryparam value="#cgi.REMOTE_ADDR#" CFSQLType="CF_SQL_VARCHAR">,
						<cfqueryparam value="#cgi.HTTP_USER_AGENT#" CFSQLType="CF_SQL_VARCHAR">
					)
				</cfquery>

				<cfset id = LSParseNumber(rnewp.generatedkey)>
				<cfset var newpd = createDatos(id, dataFields)>
				<cfset createExtension(id)>
				
				<cftransaction action="commit" /> 

			<cfcatch type="any"> 
				<cftransaction action="rollback" /> 
				<cfif isdefined("url.debug")>
					<cfdump var="#cfcatch.detail#" label="cfcatch">
					<cfabort>
				</cfif>
			</cfcatch> 
			</cftry> 
		</cftransaction>

		<cfreturn { "new_id": id, "new_datos_id" : newpd }>
	</cffunction>

	<cffunction name="createDatos" returntype="any">
		<cfargument name="id" type="numeric"> 
		<cfargument name="datos"> 

		<cfset finaldata = []>
		
		<cfloop collection="#datos#" item="key">
			<cfset arrayAppend(finaldata, "(" & key & "," & id & ",'" & datos[key] & "'," & session.id_evento & ",NOW())")>
		</cfloop>

		<cfquery name="local.createDatos" result="rnewpd" datasource="#application.datasource#">
			INSERT INTO participantesDatos 
				(campos_id_campos, participantes_id_participante, valor, eventos_id_evento, fecha_alta)
			VALUES
				#arrayToList(finaldata, ",")#
		</cfquery>

		<cfreturn rnewpd.generatedkey>
	</cffunction>


	<cffunction name="createExtension">
		<cfargument name="id"> 

		<cfquery name="local.extension" datasource="#application.datasource#">
			INSERT INTO participantesDatosExtension 
				(id_participante)
			VALUES 
				(#arguments.id#)
		</cfquery>
	</cffunction>
</cfcomponent>