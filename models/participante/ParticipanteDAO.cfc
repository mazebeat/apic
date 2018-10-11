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
		<cfargument name="prc">

		<cfparam name="arguments.rc.total" default="0" type="numeric">
		<cfparam name="arguments.rc.page" default="1" type="numeric">
		<cfparam name="arguments.rc.rows" default="#queryLimit#">
		<cfparam name="arguments.rc.ids" default="#valueList(this.defaultValues(arguments.rc.id_evento).id_campo)#">

		<cfif arguments.rc.total IS 0>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			<cfset arguments.rc.total = local.qTotal.cantidad>
		</cfif>

		<cfset var pagination    = qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)>
		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids, arguments.rc.id_evento)>
		<cfset var link          = getURLLink(arguments.rc.token)>

		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT 
				DISTINCT p.id_participante, 
				#(arguments.prc.token.type EQ 'C') ? 'id_evento,' : ''# 
				#!isEmpty(datosConsulta) ? this.sanatizeQuery(datosConsulta) & ',' : ''#
				CONCAT('#link#/participantes/',id_participante,'?ids=#this.sanatizeQueryColumn(arguments.rc.ids)#') AS _link
				FROM vParticipantes p 
				WHERE p.id_evento IN (#this.sanatizeQuery(arguments.rc.id_evento)#)
				LIMIT #this.sanatizeQuery(arguments.rc.rows)# OFFSET #pagination.inicio#	
			</cfsavecontent>
		</cfoutput>

		<cfquery name="local.qParticipantes" datasource="#application.datasource#">
			#consulta#		
		</cfquery>

		<cfset local.qParticipantes = qs.rellenarDatosInforme(consulta, local.qParticipantes, arguments.rc.id_evento)>

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
		<cfargument name="prc">
		
		<cfparam name="arguments.rc.total" default="0" type="numeric">
		<cfparam name="arguments.rc.page" default="1" type="numeric">
		<cfparam name="arguments.rc.rows" default="#queryLimit#">
		<cfparam name="arguments.rc.ids" default="#valueList(this.defaultValues(arguments.rc.id_evento).id_campo)#">
		
		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids, arguments.rc.id_evento)>

		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT 
					p.id_participante, 
					#(arguments.prc.token.type EQ 'C') ? 'id_evento,' : ''# 
					p.id_tipo_participante AS 'id_tipo_participante',
					#datosConsulta#
				FROM vParticipantes p
				WHERE p.id_participante=#javacast('int', arguments.rc.id_participante)#
				AND p.id_evento IN (#arguments.rc.id_evento#)
			</cfsavecontent>
		</cfoutput>
	
		<cfquery name="local.participantesByID" datasource="#application.datasource#">
			#consulta#
		</cfquery>

		<cfset local.participantesByID = qs.rellenarDatosInforme(consulta, local.participantesByID, arguments.rc.id_evento)>

		<cfreturn local.participantesByID>
	</cffunction>

	<cffunction name="findByEmail">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		
		<cfset local.participantesByEmail = queryNew("id")>
		
		<cfif !structKeyExists(arguments.rc, 'email')>
			<cfreturn local.participantesByEmail>
		</cfif>

		<cfparam name="arguments.rc.total" default="0" type="numeric">
		<cfparam name="arguments.rc.page" default="1" type="numeric">
		<cfparam name="arguments.rc.rows" default="#queryLimit#">
		<cfparam name="arguments.rc.ids" default="#valueList(this.defaultValues(arguments.rc.id_evento).id_campo)#">

		<cfif arguments.rc.total IS 0>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE email_participante=<cfqueryparam value="#arguments.rc.email#" CFSQLType="CF_SQL_VARCHAR">
				AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			<cfset arguments.rc.total = local.qTotal.cantidad>
		</cfif>

		<cfset var pagination    = qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)>
		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids, arguments.rc.id_evento)>
		<cfset var link          = getURLLink(arguments.rc.token)>

		<cfsavecontent variable = "consulta">
			<cfoutput>
				SELECT 
				p.id_participante, 
				p.id_tipo_participante AS 'id_tipo_participante',
				#(arguments.prc.token.type EQ 'C') ? 'id_evento,' : ''# 
				#!isEmpty(datosConsulta) ? datosConsulta & ',' : ''#
				CONCAT("#link#/participantes/",id_participante,"?ids=#arguments.rc.ids#") AS _link
				FROM vParticipantes p
				WHERE p.email_participante = '#javacast('string', arguments.rc.email)#'
				AND p.id_evento IN (#arguments.rc.id_evento#)
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfoutput>
		</cfsavecontent>
	
		<cfquery name="local.participantesByEmail" datasource="#application.datasource#">
			#consulta#
		</cfquery>

		<cfset local.participantesByEmail = qs.rellenarDatosInforme(consulta, local.participantesByEmail, arguments.rc.id_evento)>

		<cfreturn local.participantesByEmail>
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
		<cfargument name="prc">

		<cfparam name="arguments.rc.total" default="0" type="numeric">
		<cfparam name="arguments.rc.page" default="1" type="numeric">
		<cfparam name="arguments.rc.rows" default="#queryLimit#">
		<cfparam name="arguments.rc.ids" default="#valueList(this.defaultValues(arguments.rc.id_evento).id_campo)#">

		<cfquery name="local.tipoParticipante" datasource="#application.datasource#">
			SELECT id_tipo_participante 
			FROM vTiposDeParticipantes 
			WHERE eventos_id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND LOWER(nombre)=LOWER(<cfqueryparam value="#reReplace(arguments.rc.tipo_participante, "[-_]", " ")#" CFSQLType="CF_SQL_VARCHAR">)
		</cfquery>

		<cfif arguments.rc.total IS 0>
			<cfquery name="local.qTotal" datasource="#application.datasource#">
				SELECT COUNT(*) AS cantidad
				FROM vParticipantes
				WHERE id_tipo_participante=<cfqueryparam value="#local.tipoParticipante.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
				AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			</cfquery>
			<cfset arguments.rc.total = local.qTotal.cantidad>
		</cfif>

		<cfset var pagination    = qs.generarPaginacion(arguments.rc.total, arguments.rc.page, arguments.rc.rows)>
		<cfset var datosConsulta = qs.generarConsultaInforme(arguments.rc.ids, arguments.rc.id_evento)>
		<cfset var link          = getURLLink(arguments.rc.token)>

		<cfoutput>
			<cfsavecontent variable = "consulta">
				SELECT 
				DISTINCT p.id_participante, 
				#(arguments.prc.token.type EQ 'C') ? 'id_evento,' : ''# 
				#!isEmpty(datosConsulta) ? datosConsulta & ',' : ''#
				CONCAT("#link#/participantes/",id_participante,"?ids=#arguments.rc.ids#") AS _link
				FROM vParticipantes p 
				WHERE p.id_evento IN (#arguments.rc.id_evento#)
				AND id_tipo_participante='#local.tipoParticipante.id_tipo_participante#'
				LIMIT #arguments.rc.rows# OFFSET #pagination.inicio#
			</cfsavecontent>
		</cfoutput>

		<cfquery name="local.participantesByTipo" datasource="#application.datasource#">
			#consulta#
		</cfquery>

		<cfset local.participantesByTipo = qs.rellenarDatosInforme(consulta, local.participantesByTipo, arguments.rc.id_evento)>

			
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

		<cfinclude template = "/default/admin/helpers/string.cfm">
		<!--- Default values of login and password --->
		<cfscript>
			// Se obtiene el tipo de formulario que se require usar
			var fs = formS.getByTipoParticipante(arguments.record.id_tipo_participante, arguments.event, arguments.rc)

			if (fs.data.records.recordCount LTE 0) throw(message="'Tipo de Participante' or 'Formulario' are incorrect", detail="Invalid id_tipo_participante");

			// Se agrega id_formulario a record
			arguments.record["id_formulario"] = javacast('int', fs.data.records.id_formulario);

			var e = generateEmailAndPassword(arguments.record.email);
			var ep = {			
				'login'                                     = e.email,
				'password'                                  = e.password,
				'fecha_alta'                                = NOW(),
				'activo'                                    = 1,
				'formulariosEventos_id_formulariosEventos'  = this.sanatizeQueryColumn(arguments.record.id_formulario),
				'tiposDeParticipantes_id_tipo_participante' = this.sanatizeQueryColumn(arguments.record.id_tipo_participante),
				'importado'                                 = 1,
				'inscrito'                                  = 0,
				'id_evento'                                 = this.sanatizeQueryColumn(arguments.rc.id_evento),
				'idiomas_id_idioma'                         = this.sanatizeQueryColumn(session.language),
				'insitu'                                    = 0,
				'ip_alta'                                   = cgi.REMOTE_ADDR,
				'user_agent_alta'                           = cgi.HTTP_USER_AGENT,
				'email'                                     = this.sanatizeQueryColumn(e.email)
			};
			// Validamos campo login en record
			if(structKeyExists(arguments.record, 'login')) { structInsert(ep, 'login', arguments.record.login, true); }
			
			// Validamos campo password en record
			if(structKeyExists(arguments.record, 'password')) { structInsert(ep, 'password', arguments.record.password, true); } 
			
			// Asignamos a record el campo password
			if(getHTTPRequestData().method EQ 'POST') {
				if(!structKeyExists(arguments.record, 'login')) { 
					structInsert(arguments.record, 'login', e.email, true); 
				}
				if(!structKeyExists(arguments.record, 'password')) { 
					structInsert(arguments.record, 'password', e.password, true); 
				}
			} 
			
			if(getHTTPRequestData().method EQ 'PUT') {
				if(structKeyExists(arguments.record, 'login') AND !structKeyExists(ep, 'login'))  { 
					structInsert(ep, 'login', arguments.record.login, true); 
				}
				if(structKeyExists(arguments.record, 'password') AND !structKeyExists(ep, 'password'))  { 
					structInsert(ep, 'password', arguments.record.password, true); 
				}
			}

			// Validamos campo inscrito en record
			if(structKeyExists(record, 'inscrito')) ep.inscrito = arguments.record.inscrito;
		</cfscript>

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

		<cfset b = genCreateDatos(arguments.record, arguments.rc.id_evento, k)>
		<cfset c = genUpdateParticipante(arguments.record, k, arguments.rc)>

		<cfreturn { 'a' = ep, 'b' = b, 'c' = c }>
	</cffunction>

	<cffunction name="genCreateDatos" output="false" returntype="array">
		<cfargument name="record">
		<cfargument name="id_evento">
		<cfargument name="k">

		<cfset var out = []>

		<cfset rec = structFilter(arguments.record, function(_r, _k){
			return arrayLen(reMatch('(\d)',_r)) GT 0; 
		})>

		<cfinclude template="/includes/helpers/ApplicationHelper.cfm">

		<cfloop collection="#rec#" item="key">
			<cfif arrayLen(reMatch('(^\d{4}(-\d\d(-\d\d(T\d\d:\d\d(:\d\d)?(\.\d+)?(([+-]\d\d:\d\d)|Z)?)?)?)?$)', rec[key])) GT 0>
				<cfset rec[key] = ISOToDateTime(rec[key])>
			</cfif>
			<cfset arrayAppend(out, "#key#|[IDFIELD_#k#]|#this.sanatizeQueryColumn(rec[key])#|#arguments.id_evento#")>
		</cfloop>

		<cfreturn out>
	</cffunction>

	<cffunction name="genUpdateParticipante" output="false" returntype="any">
		<cfargument name="record">
		<cfargument name="k">
		<cfargument name="rc">

		<cfscript>
			include ("/default/admin/helpers/string.cfm");

			var datos = {
				'fecha_modif'      = 'NOW()',
				'user_agent_modif' =  this.sanatizeQueryColumn(cgi.HTTP_USER_AGENT),
				'ip_modif'         =  this.sanatizeQueryColumn(cgi.REMOTE_ADDR),
				'id_participante'  = '[IDFIELD_#k#]',
				'id_evento'        =  this.sanatizeQueryColumn(arguments.rc.id_evento)
			};
			var updateConsulta = '';
			var QCamposFijos   = listadoCamposFijosFormulario(arguments.record.id_formulario);
			
			if(QCamposFijos.recordCount GT 0) {			
				if(structKeyExists(arguments.record, 'login')) {
					structInsert(datos, 'login', this.sanatizeQueryColumn(arguments.record.login));
				}

				if(structKeyExists(arguments.record, 'password')) {
					structInsert(datos, 'password', this.sanatizeQueryColumn(arguments.record.password));
				}

				if(structKeyExists(arguments.record, 'id_tipo_participante')) {
					structInsert(datos, 'id_tipo_participante', this.sanatizeQueryColumn(arguments.record.id_tipo_participante));
					structInsert(datos, 'id_formulario', this.sanatizeQueryColumn(arguments.record.id_formulario));
				}

				if(structKeyExists(arguments.record, 'inscrito')) {
					structInsert(datos, 'inscrito', this.sanatizeQueryColumn(arguments.record.inscrito));
				}

				for (row in QCamposFijos) {
					if(structKeyExists(arguments.record, row.id_campos)) {
						var val_cf = valorCampo(arguments.record, row.id_campos);
						
						switch (row.descripcion) {
							case 'email_participante': case 'email_empresa':
								val_cf = lcase(val_cf);
								break;
							case 'nombre_participante': case 'apellidos_participante': case 'nombre_empresa':
								val_cf = initCap(val_cf);
								break;
							case 'baja_newsletter':
								if(val_cf is '') val_cf = 1;
								break;
							default:
								val_cf = lcase(val_cf);
								break;
						}
						structInsert(datos, 'cf_#row.descripcion#',  this.sanatizeQueryColumn(val_cf));
					}
				}
			}
		</cfscript>

		<cfreturn datos>
	</cffunction>

	<cffunction name="doCreate" hint="Inserta un nuevo participante" output="false" returntype="string">
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
			<cfloop from="1" to="#arraylen(vList.a)#" index="u"> 
				<cfif u NEQ 1>,</cfif>
				(
					<cfqueryparam value="#vList.a[u].login#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#vList.a[u].password#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#vList.a[u].fecha_alta#" cfsqltype="CF_SQL_TIMESTAMP">,
					<cfqueryparam value="#vList.a[u].activo#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].formulariosEventos_id_formulariosEventos#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].tiposDeParticipantes_id_tipo_participante#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].importado#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].inscrito#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].id_evento#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].idiomas_id_idioma#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#vList.a[u].insitu#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#vList.a[u].ip_alta#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#vList.a[u].user_agent_alta#" cfsqltype="CF_SQL_VARCHAR">
				)
			</cfloop>
		</cfquery>

		<cfset var ids = rnewp.generatedkey>

		<cfif listLen(ids) NEQ arraylen(vList.a)>
			<cfthrow message="ERROR AL INSERTAR PARTICIPANTE">
		</cfif>

		<cfloop list="#ids#" item="id" index="i">
			<cfloop array="#vList.b#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
					<cfset vList.b[f] = replace(vList.b[f], "[IDFIELD_#i#]", id)>		
				</cfif>
			</cfloop>

			<cfloop array="#vList.c#" item="va" index="f">
				<cfif findNoCase("[IDFIELD_#i#]", va.id_participante) != 0>
					<cfset vList.c[f].id_participante = replace(vList.c[f].id_participante, "[IDFIELD_#i#]", id)>			
				</cfif>
			</cfloop>
		</cfloop>

		<cfset var idsD  = doCreateDatos(vList.b)>
		<cfset var idsDE = doCreateExtension(ids, arguments.rc)>
		<cfset doUpdateParticipante(vList.c)>

		<cfreturn ids>
	</cffunction>
	
	<cffunction name="doCreateDatos" returntype="any">
		<cfargument name="vList"> 

		<!--- -- #replace(arrayToList(vList, ","), '|', ',', 'ALL')# --->
		<cfquery name="local.createDatos" result="rnewpd" datasource="#application.datasource#">
			INSERT INTO participantesDatos 
				(campos_id_campos, participantes_id_participante, valor, eventos_id_evento, fecha_alta)
			VALUES
			<cfloop from="1" to="#arraylen(vList)#" index="u"> 
				<cfif u NEQ 1>,</cfif>
				<cfset var data = listToArray(vList[u], '|')>
				(
					<cfqueryparam value="#data[1]#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#data[2]#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#data[3]#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#data[4]#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_TIMESTAMP">
				)
			</cfloop>
		</cfquery>

		<cfreturn rnewpd.generatedkey>
	</cffunction>

	<cffunction name="doCreateExtension" returntype="any">
		<cfargument name="ids"> 
		<cfargument name="rc"> 		

		<cfset var idss = listToArray(arguments.ids)>
		<cfquery name="local.extension" result="rnewpde" datasource="#application.datasource#">
			INSERT INTO participantesDatosExtension 
			(
				id_participante, 
				id_evento, 
				fecha_alta_api
			)
			VALUES 
			<cfloop from="1" to="#arraylen(idss)#" index="u"> 
				<cfif u NEQ 1>,</cfif>		
				(
					<cfqueryparam value="#idss[u]#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_TIMESTAMP">
				)
			</cfloop>
			ON DUPLICATE KEY UPDATE fecha_modif_api = NOW()
		</cfquery>

		<cfreturn rnewpde.generatedkey>
	</cffunction>

	<cffunction name="doUpdateExtension" returntype="any">
		<cfargument name="ids"> 
		<cfargument name="rc"> 

		<cfif isArray(ids)>
			<cfloop array=#ids# item="it" index="i">
				<cfquery name="local.extension" result="rnewpde" datasource="#application.datasource#">
					UPDATE participantesDatosExtension 
					SET fecha_modif_api = NOW()
					WHERE id_participante = #it#
					AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				</cfquery>

				<cfif rnewpde.recordCount EQ 0>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="doUpdateParticipante" access="public" returntype="void" output="false">
		<cfargument name="vList" required="true"> 

		<cfset updated = 0>

		<cfinclude template="/default/admin/helpers/string.cfm">
		<cfinclude template = "/default/admin/helpers/participantes/cs.cfm">
		<!--- https://stackoverflow.com/questions/6299326/coldfusion-multiple-sql-statements-in-a-query --->
		<cfloop array="#arguments.vList#" item="upd" index="i">
			<cfquery name="local.update" result="rupdp" datasource="#application.datasource#">
				UPDATE participantes
				SET 
				user_agent_modif = <cfqueryparam value="#cgi.HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR">,					
				ip_modif         = <cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">,
				<cfif structKeyExists(upd, 'login')>
					login = <cfqueryparam value="#upd.login#" cfsqltype="CF_SQL_VARCHAR">,
				</cfif>
				<cfif structKeyExists(upd, 'password')>
					password = <cfqueryparam value="#encriptar(upd.password)#" cfsqltype="CF_SQL_VARCHAR">,
				</cfif>
				<cfif structKeyExists(upd, 'id_tipo_participante')>
					tiposDeParticipantes_id_tipo_participante = <cfqueryparam value="#upd.id_tipo_participante#" cfsqltype="CF_SQL_INTEGER">,
					formulariosEventos_id_formulariosEventos = <cfqueryparam value="#upd.id_formulario#" cfsqltype="CF_SQL_INTEGER">,
				</cfif>
				<cfif structKeyExists(upd, 'inscrito')>
					inscrito = <cfqueryparam value="#javacast('int', upd.inscrito)#" cfsqltype="CF_SQL_INTEGER">,
				</cfif>
				<cfset d = structFilter(upd, function(key, value){
					return reFindNoCase('(^(cf_\w+)$)', key);
				})>					
				<cfloop collection="#d#" index="key" item="val">
					#key# = 
					<cfswitch expression="#val#">
						<cfcase value="cf_email_participante,cf_email_empresa" delimiters=",">
							<cfqueryparam value="#lcase(val)#" cfsqltype="CF_SQL_VARCHAR">
						</cfcase>
						<cfcase value="cf_nombre_participante,cf_apellidos_participante,cf_nombre_empresa" delimiters=",">
							<cfqueryparam value="#initCap(val)#" cfsqltype="CF_SQL_VARCHAR">
						</cfcase>
						<cfcase value="cf_baja_newsletter">
							<cfif (val is '')>
								<cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						</cfcase>
						<cfcase value="cf_email_valido">
							<cfif (val is '')>
								<cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
							</cfif>
						</cfcase>
						<cfdefaultcase>
							<cfqueryparam value="#val#" cfsqltype="CF_SQL_VARCHAR">
						</cfdefaultcase>
					</cfswitch>
					, 
				</cfloop>
				fecha_modif = NOW()
				WHERE id_participante = <cfqueryparam value="#upd.id_participante#" cfsqltype="CF_SQL_INTEGER">
				AND id_evento         = <cfqueryparam value="#upd.id_evento#" cfsqltype="CF_SQL_INTEGER">;
			</cfquery>
			<cfset updated = updated + rupdp.recordCount>
		</cfloop>

		<!--- <cfif NOT updated EQ arrayLen(arguments.vList)> <cfthrow message="Update failed"> </cfif> --->

		<!--- <cfreturn updated> --->
	</cffunction>

	<cffunction name="configFields">
		<cfargument name="keyList" type="array" required="true">
		<cfargument name="fields" type="any" required="true">

		<cfset var ff = formS.formFields(arguments.id_evento)>
		<cfset var reqFields = {}>

		<cfscript>
			reqFields = structFilter(ff, function(key, value) {
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
		
		<cfscript>
		var part_email = (isEmpty(arguments.email)) ? 'part@#right(gettickCount(), 7)#': arguments.email;
		var password   = listFirst(part_email, '@') & '_' & right(gettickcount(), 5);

		return {
			'email'= part_email,
			'password'= password
		}
		</cfscript>
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
		<cfargument name="id_evento">

		<cfquery name="local.bylogin" datasource="#application.datasource#">
			SELECT login, password FROM participantes
			WHERE login = <cfqueryparam value="#arguments.login#" cfsqltype="CF_SQL_VARCHAR">
			AND fecha_baja IS NULL
			AND id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfquery>

		<cfreturn local.bylogin>
	</cffunction>

	<cffunction name="genUpdateDatos" output="false" returntype="void">
		
	</cffunction>

	<!--- 
		Realiza la modificacion de uno o más participantes, validandolo por el correo
	 --->
	<cffunction name="doUpdate"  output="false" returntype="string">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="vList">

		<cfset var out = []>
		<cfset var lgs = []> 
		<cfset var ids = []>

		<!--- <cfloop array="#vList.d#" index="i" item="item"> --->
		<cfloop array="#arguments.vList.c#" index="i" item="item">
			<!--- 
			SELECT id_participante AS 'id' FROM participantes
			WHERE (
				login = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
				OR cf_email_participante = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
			)
			AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND fecha_baja IS NULL
			---
			SELECT id_participante AS 'id' 
				FROM participantes
				WHERE cf_email_participante = <cfqueryparam value="#trim(replace(item, "'", "", 'all'))#" cfsqltype="CF_SQL_VARCHAR">
				AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND fecha_baja IS NULL
			--->
			<cfquery name="local.logins" datasource="#application.datasource#">
				SELECT id_participante AS 'id' 
				FROM participantes
				WHERE cf_email_participante = <cfqueryparam value="#item.cf_email_participante#" cfsqltype="CF_SQL_VARCHAR">
				AND cf_nombre_participante = <cfqueryparam value="#item.cf_nombre_participante#" cfsqltype="CF_SQL_VARCHAR">
				AND cf_apellidos_participante = <cfqueryparam value="#item.cf_apellidos_participante#" cfsqltype="CF_SQL_VARCHAR">
				AND id_evento IN (<cfqueryparam value="#arguments.rc.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
				AND fecha_baja IS NULL
			</cfquery>

			<cfif local.logins.recordcount EQ 0 AND NOT isdefined('url.allow_duplicate')>
				<cfthrow message="El participante [#item.cf_email_participante#|#item.cf_nombre_participante#|#item.cf_apellidos_participante#] does not exists or could be duplicated">
			</cfif>
			
			<cfset arrayAppend(ids, local.logins.id)>

			<cfloop array="#ids#" item="id" index="i">
				<cfloop array="#arguments.vList.b#" item="va" index="f">
					<cfif findNoCase("[IDFIELD_#i#]", va) != 0>
						<cfset vList.b[f] = replace(arguments.vList.b[f], "[IDFIELD_#i#]", id)>		
					</cfif>
				</cfloop>
	
				<cfloop array="#arguments.vList.c#" item="va" index="f">
					<cfif findNoCase("[IDFIELD_#i#]", va.id_participante) != 0>
						<cfset vList.c[f].id_participante = replace(vList.c[f].id_participante, "[IDFIELD_#i#]", id)>			
					</cfif>
				</cfloop>
			</cfloop>
		</cfloop>

		<cfset doUpdateDatos(arguments.vList.b)>
		<cfset doUpdateExtension(ids, arguments.rc)>
		<cfset doUpdateParticipante(arguments.vList.c)>

		<cfreturn arrayToList(ids)>
	</cffunction>

	<!--- TODO: Terminar método de actualizar datos --->
	<cffunction name="doUpdateDatos" returntype="any">
		<cfargument name="vList">

		<cfset var out = []>
		<cfset var out2 = {}>
		<cfset var tmp = []>
		<cfset var tempid = 0>

		<cfinclude template="/includes/helpers/ApplicationHelper.cfm">

		<cfloop collection="#arguments.vList#" item="key">
			<cfset var list = listToArray(arguments.vList[key], '|')>

			<cfquery>
				INSERT INTO participantesDatos 
				(campos_id_campos, valor, participantes_id_participante, eventos_id_evento)
				VALUES ( 
					<cfqueryparam value="#list[1]#" cfsqltype="CF_SQL_INTEGER">, 
					<cfqueryparam value="#list[3]#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#list[2]#" cfsqltype="CF_SQL_INTEGER">, 
					<cfqueryparam value="#list[4]#" cfsqltype="CF_SQL_INTEGER"> 
				)
				ON DUPLICATE KEY UPDATE
				valor = <cfqueryparam value="#list[3]#" cfsqltype="CF_SQL_VARCHAR">, 
				fecha_modif = NOW()
			</cfquery>
		</cfloop>
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
			<cfif structKeyExists(arguments.fields, 'id_evento') and isNumeric(arguments.fields.id_evento)>
				AND id_evento = <cfqueryparam value="#arguments.fields.id_evento#" cfsqltype="cf_sql_integer">
			</cfif>
		</cfquery>

		<cfif local.allFields.recordcount GT 0>
			<cfset exists = local.allFields.exists GT 0 ? true : false>
		</cfif>

		<cfreturn exists>
	</cffunction>
</cfcomponent>