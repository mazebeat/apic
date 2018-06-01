<cfcomponent output="false" extends="models.campo.CampoFormulario">

	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfargument name="campo" type="query"> 
		
		<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT 
				IFNULL(ct.min_chars, 0) AS min_chars,
				IFNULL(ct.max_chars, 1000) AS max_chars,
			FROM vCamposTipoMemoConfiguracion
			WHERE id_campo = <cfqueryparam value="#variables.instancia.id_campo#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfif local.qConfig.recordCount gt 0>
			<cfset campo.min_chars = local.qConfig.min_chars>
			<cfset campo.max_chars = local.qConfig.max_chars>
		<cfelse>
			<cfset campo.min_chars = 0>
			<cfset campo.max_chars = 0>
			<cfset campo.max_chars = 0>
			<cfset campo.solo_lectura = 0>
		</cfif>

		<cfreturn campo>	
	</cffunction>
</cfcomponent>