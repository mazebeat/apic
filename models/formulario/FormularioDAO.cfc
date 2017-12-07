<!--
	Formulario DAO
-->
<cfcomponent hint="Formulario DAO" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->

	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="FormularioDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="get" returntype="query">
		<cfargument name="id_formulario" type="numeric" required="false" default="#session.id_evento#" displayname="" hint="">
		<cfargument name="event">
		<cfargument name="rc">

		<cfquery name="local.forms" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT id_formulario,
			id_tipo_participante,
			'' AS 'id_agrupacion',
			'' AS 'id_campo'
			FROM sige.vFormularios
			WHERE id_formulario = <cfqueryparam value="#arguments.id_formulario#" CFSQLType="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
		</cfquery>

		<cfreturn local.forms>
	</cffunction>
	<!--- 267237 96480555 --->
	
	<!--
		Obtiene todos los formularios según ID de un evento e idioma
		@id_evento 
		@id_idioma
	--> 
	<cffunction name="byEvento" returnType="query" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="true" hint="">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset var link = getURLLink(arguments.rc.token)>

		<cfquery name="local.forms" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT DISTINCT(id_formulario),
			<!--- id_tipo_participante, --->
			<!--- '' AS 'id_agrupacion',
			'' AS 'fields', --->
			CONCAT("#link#/formularios/", id_formulario) AS '_link'
			FROM sige.vFormularios
			WHERE id_evento = <cfqueryparam value="#arguments.id_evento#" CFSQLType="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">;
		</cfquery>
	
		<cfreturn local.forms>
	</cffunction>


	<cffunction name="getByIdTipoParticipante" returntype="query">
		<cfargument name="id_tipo_participante" type="numeric" required="false" displayname="" hint="">
		<cfargument name="event">
		<cfargument name="rc">

		<cfquery name="local.forms" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT id_formulario,
			id_tipo_participante,
			'' AS 'id_agrupacion',
			'' AS 'id_campo'
			FROM sige.vFormularios
			WHERE id_tipo_participante = <cfqueryparam value="#arguments.id_tipo_participante#" CFSQLType="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
		</cfquery>

		<cfreturn local.forms>
	</cffunction>

	<cffunction name="groupsByEvent" returnType="query" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_evento" type="numeric" required="false" default="#session.id_evento#" displayname="" hint="">

		<cfquery name="local.agrupacion" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT DISTINCT(id_agrupacion), titulo
			FROM vAgrupacionesDeCampos
			WHERE id_evento = <cfqueryparam value="#arguments.id_evento#" CFSQLType="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">			
		</cfquery>

		<cfreturn local.agrupacion>
	</cffunction>

	<cffunction name="groupsByForm" returnType="query" hint="Obtiene todos los formularios según ID de un formulario">
		<cfargument name="id_formulario" type="numeric" required="false" default="#session.id_evento#" displayname="" hint="">

		<cfquery name="local.agrupacion" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT id_agrupacion
			FROM vSeleccionAgrupacionesDeCamposFormularios
			WHERE id_formulario = <cfqueryparam value="#arguments.id_formulario#" CFSQLType="CF_SQL_INTEGER">
			AND activo = 1;
		</cfquery>

		<cfreturn local.agrupacion>
	</cffunction>

	<cffunction name="fieldsByGroup" returnType="query" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="id_agrupacion" type="numeric" required="true" hint="">

		<cfquery name="local.agrupacionCampos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT DISTINCT(id_campo)
			FROM vCampos
			WHERE id_agrupacion = <cfqueryparam value="#arguments.id_agrupacion#" CFSQLType="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" CFSQLType="CF_SQL_CHAR">;
		</cfquery>

		<cfreturn local.agrupacionCampos>
	</cffunction>

	<cffunction name="allFieldsByGroup" returnType="query" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="ids_agrupacion" type="any" required="true" hint="Lista de IDs agrupación separados por coma">

		<cfquery name="local.allFieldsByAgrupacion" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT id_campo,
				id_agrupacion,
				id_tipo_campo, 
				id_tipo_campo_fijo
			FROM vCampos
			WHERE id_idioma = <cfqueryparam value="#session.language#" CFSQLType="CF_SQL_CHAR">
			AND id_agrupacion IN (<cfqueryparam value="#arguments.ids_agrupacion#" CFSQLType="CF_SQL_INTEGER" list="yes">)
		</cfquery>

		<cfreturn local.allFieldsByAgrupacion>
	</cffunction>

	<cffunction name="allFieldsByGroupDefault" returnType="query" cache="true" cacheTimeout="30" cacheLastAccessTimeout="15" hint="Obtiene todos los formularios según ID de un evento e idioma">
		<cfargument name="ids_agrupacion" type="any" required="true" hint="Lista de IDs agrupación separados por coma">

		<cfquery name="local.allFields" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT DISTINCT(id_campo),
				id_agrupacion,
				id_tipo_campo, 
				id_tipo_campo_fijo
			FROM vCampos
			WHERE id_agrupacion IN (<cfqueryparam value="#arguments.ids_agrupacion#" CFSQLType="CF_SQL_INTEGER" list="yes">)		
			AND id_idioma = <cfqueryparam value="#session.language#" CFSQLType="CF_SQL_CHAR">
			AND id_tipo_campo = 1
			AND id_tipo_campo_fijo IN (4,6,9)
		</cfquery>

		<cfreturn local.allFields>
	</cffunction>

	<cffunction name="cargarValoresCampoGrupoFormulario" access="public" returntype="query" output="false">
		<cfargument name="id_campo" type="any">

		<cfquery name="qValoresCamposGruposFormulario" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT *
			FROM vValoresCamposLista
			WHERE id_campo = <cfqueryparam value="#arguments.id_campo#" cfsqltype="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
		</cfquery>

		
		<cfreturn qValoresCamposGruposFormulario>
	</cffunction>


</cfcomponent>