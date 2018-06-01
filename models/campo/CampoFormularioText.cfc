<cfcomponent output="false" extends="models.campo.CampoFormulario">

	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfargument name="campo" type="query"> 

		<cfif campo.id_encapsulado is 6>
			<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT comprobacion
				FROM vCamposTipoEmailConfiguracion
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfif local.qConfig.recordCount gt 0>
				<cfset campo.comprobacion = local.qConfig.comprobacion>
			<cfelse>
				<cfset campo.comprobacion = 0>
			</cfif>

		<cfelseif campo.id_encapsulado is 7>
			<!--- NUMERO --->	
			<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT 
					IFNULL(min_chars, 0) AS min_chars,
					IFNULL(max_chars, 1000) AS max_chars
				FROM vCamposTipoNumeroConfiguracion
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
	<cfif local.qConfig.recordCount gt 0>
				<cfset campo.min_chars = local.qConfig.min_chars>
				<cfset campo.max_chars = local.qConfig.max_chars>
			<cfelse>
				<cfset campo.min_chars = 0>
				<cfset campo.max_chars = 0>
			</cfif>

		<cfelseif campo.id_encapsulado is 8>
			<!--- TELEFONO --->
			<!--- <cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				<!---SELECT solo_lectura
				FROM vCamposTipoTelefonoConfiguracion
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">--->
				SELECT solo_lectura
				FROM vCampos
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
				and id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
			</cfquery>

			<cfif local.qConfig.recordCount gt 0>
				<cfset variables.instancia.configuracion.solo_lectura= local.qConfig.solo_lectura>
			<cfelse>
				<cfset variables.instancia.configuracion.solo_lectura = 0>
			</cfif> --->
		
		<cfelseif campo.id_encapsulado is 10>
			<!--- URL --->
			<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				<!---SELECT solo_lectura
				FROM vCamposTipoUrlConfiguracion
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">--->
				SELECT solo_lectura
				FROM vCampos
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
				AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
			</cfquery>

			<cfif local.qConfig.recordCount gt 0>
				<cfset campo.solo_lectura= local.qConfig.solo_lectura>
			<cfelse>
				<cfset campo.solo_lectura = 0>
			</cfif>
		
		<cfelseif campo.id_encapsulado is 17>
			<!--- CUPON DESCUENTO --->
			<!--- <cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				<!---SELECT solo_lectura
				FROM vCamposTipoCuponConfiguracion
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">--->
				SELECT solo_lectura
				FROM vCampos
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
				AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
			</cfquery>

			<cfif local.qConfig.recordCount gt 0>
				<cfset variables.instancia.configuracion.solo_lectura= local.qConfig.solo_lectura>
			<cfelse>
				<cfset variables.instancia.configuracion.solo_lectura = 0>
			</cfif> --->
 		

		<cfelseif campo.id_encapsulado is 1>
			<!--- TEXTO --->
			<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
				SELECT 
					IFNULL(min_chars, 0) AS min_chars,
					IFNULL(max_chars, 1000) AS max_chars,
					IFNULL(dninie, 0) AS dninie,
					CASE WHEN alfabetico IS NULL OR alfabetico = '' OR alfabetico = 0 THEN 0 ELSE alfabetico END AS 'alfabetico' 
				FROM vCamposTipoTextoConfiguracion				
				WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>

			<cfif local.qConfig.recordCount gt 0>
				<cfset campo.min_chars  = local.qConfig.min_chars>
				<cfset campo.max_chars  = local.qConfig.max_chars>
				<cfset campo.dninie     = local.qConfig.dninie>
				<cfset campo.alfabetico = local.qConfig.alfabetico>				
			<cfelse>
				<cfset campo.min_chars  = 0>
				<cfset campo.max_chars  = 1000>
				<cfset campo.dninie     = 0>
				<cfset campo.alfabetico = 0>
			</cfif>
		<cfelse>
			<cfset campo.solo_lectura = 0>
		</cfif>	

		<cfreturn campo>
	</cffunction>
</cfcomponent>