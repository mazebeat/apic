<cfcomponent output="false" extends="models.campo.CampoFormulario">
	<cffunction name="init" returntype="campoFormulario">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="struct" output="false">
		<!--- <cfquery name="local.qConfig" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT solo_lectura
			FROM vCampos
			WHERE id_campo = <cfqueryparam value="#variables.instancia.id_campo#" cfsqltype="cf_sql_integer">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
		</cfquery>
	
		<cfif local.qConfig.recordCount gt 0>
			<cfset variables.instancia.configuracion.solo_lectura= local.qConfig.solo_lectura>
		<cfelse>
			<cfset variables.instancia.configuracion.solo_lectura = 0>
		</cfif>
		
		<cfreturn variables.instancia.configuracion> --->
		
	</cffunction>
</cfcomponent>