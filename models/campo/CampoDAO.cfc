<cfcomponent hint="I am a new Model Object" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->
	<cfproperty name="formularioDAO" inject="model:formulario.FormularioDAO">
	<cfproperty name="imgDAO" inject="model:campo.CampoFormularioImagen">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init"returntype="campoDAO">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="getAgrupacionesDeCamposGrid" access="public" returntype="string" output="false">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset var objEvento = this.objEvento>
		<cfset var s = {}>
		<cfset s.datos = objEvento.agrupacionesDeCampos>
		<cfset s.objTraducciones = this.objTraducciones>

		<cfquery name="local.qInfoSistemaAgrupaciones" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT titulo, id_tipo_agrupacion
			FROM vAgrupacionesFijasDeCampos
			FROM id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
			ORDER BY titulo
		</cfquery>

		<cfset s.infoSistema = QueryToStruct(local.qInfoSistemaAgrupaciones, 'id_tipo_agrupacion')>

		<!--- COGEMOS LA CONFIGURACION DE CADA AGRUPACION --->
		<cfquery name="local.qGetConfiguraciones" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT *
			FROM vAgrupacionesDeCamposConfiguracion
			FROM id_agrupacion in (<cfqueryparam value="#objEvento.getListaAgrupacionesDeCampos()#" list="true" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>

		<cfset s.configuraciones = QueryToStruct(local.qGetConfiguraciones, 'id_agrupacion')>

		<cfset var argsView = {}>
		<cfset argsView.view = 'formularios/agrupacionesDeCampos'>
		<cfset argsView.args =
		{
			s : s
		}>
		<cfset event.setLayOut('Layout.JSON')>
		<cfset arguments.event.setView(argumentCollection: argsView)>
	</cffunction>

	<cffunction name = "tablaSeleccionAgrupaciones">
		<cfset var formIds = imgDAO.byEvento(1)>		
	</cffunction>

	<cffunction name="agrupacionDeCampos">
		<cfquery name = "local.agrupaciones" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT *
			FROM vAgrupacionesDeCampos
			WHERE id_evento = 1 
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
		</cfquery>		

		<cfquery name = "local.agrupaciones" datasource = "" username = "[ ]" password = "[ ]">
			SELECT id_agrupacion, orden, activo, activo_acreditaciones, activo_dossier
			FROM vSeleccionAgrupacionesDeCamposFormularios
			WHERE id_formulario = 6837 
		</cfquery>
	</cffunction>

	<cffunction name="cargarValoresCampoGrupoFormulario" access="public" returntype="query" output="false">
		<cfargument name="id_campo" type="any" required="true">

		<cfquery name="qValoresCamposGruposFormulario" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT *
			FROM vValoresCamposLista
			WHERE id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfreturn qValoresCamposGruposFormulario>
	</cffunction>

	<cffunction name="get" access="public" returntype="query" output="false">
		<cfargument name="id_campo" type="numeric" required="true">
		<cfargument name="id_agrupacion" type="numeric" required="false" default="0">
		
		<cfquery name="local.qUnCampo" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT
				id_campo,
				obligatorio,
				id_encapsulado,
				titulo,
				id_tipo_campo_fijo,
				IFNULL(min_chars, 0) AS min_chars,
				IFNULL(max_chars, 1000) AS max_chars,
				desplegable,
				solo_lectura
			FROM vCampos
			WHERE id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="CF_SQL_INTEGER">
			<cfif arguments.id_agrupacion GT 0>
				AND id_agrupacion = <cfqueryparam value="#arguments.id_agrupacion#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			AND id_idioma = <cfqueryparam value="#session.language#" CFSQLType="CF_SQL_CHAR">
		</cfquery>

		<cfreturn local.qUnCampo>
	</cffunction>

	<cffunction name="uploadFile" access="public" returntype="string" output="false">
		<cfargument name="file" type="string" required="true">

		<cfset var nombreFichero = ''>
		<cfif isValid('URL', arguments.file)>
			<cftry>
				<cfquery name="local.web" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
					SELECT id_web FROM sige.webs
					WHERE eventos_id_evento IN (<cfqueryparam value="#session.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
					AND tiposWebs_id_tipo_web = 1
					AND activa = 1
					AND fecha_baja IS NULL
				</cfquery>

				<cfif local.web.recordCount IS 1>
					<cfset var rutaDescargaDocumentos = "/web/sitios/default/admin/uploads/#local.web.id_web#/docs/descargas">
					
					<cfinclude template="/default/admin/helpers/dirs.cfm">
				
					<cfset testAndCreateDir(rutaDescargaDocumentos)>

					<cfset var nuevoNombreFichero = "#01#_#local.web.id_web#_api_#getTickCount()#_#(getTickCount()*4/2)#">

					<cfset nombreFichero = imgDAO.uploadImage(arguments.file, nuevoNombreFichero, rutaDescargaDocumentos)>
				</cfif>
			<cfcatch type="any">
				<cfinclude template="/default/admin/helpers/funciones.cfm">
				<cfset enviarCorreoError('uploadFile subiendo fichero', cfcatch)>
			</cfcatch>
			</cftry>
		</cfif>

		<cfreturn nombreFichero>
	</cffunction>

</cfcomponent>