<cfcomponent output="false" extends="models.campo.CampoFormulario">
	
	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfargument name="campo" type="query"> 

		<cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT desplegable
			FROM vCamposTipoRadioConfiguracion
			WHERE id_campo = <cfqueryparam value="#arguments.campo.id_campo#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif local.qConfig.recordCount gt 0>
			<cfset campo.desplegable = local.qConfig.desplegable>
		<cfelse>
			<cfset campo.desplegable = 0>
			<cfset campo.solo_lectura = 0>
		</cfif>
		
		<cfreturn campo>
	</cffunction>
</cfcomponent>