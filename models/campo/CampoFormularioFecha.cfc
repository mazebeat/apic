<cfcomponent output="false" extends="models.campo.CampoFormulario">
	
	<cffunction name="init" returntype="campoFormularioFecha">
		<cfreturn this>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfargument name="campo" type="query"> 

		 <cfquery name="local.qConfig" datasource="#application.datasource#">
			SELECT solo_lectura
			FROM vCampos
			WHERE id_campo = <cfqueryparam value="#campo.id_campo#" cfsqltype="cf_sql_integer">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
		</cfquery>
	
		<cfif local.qConfig.recordCount gt 0>
			<cfset campo.solo_lectura= local.qConfig.solo_lectura>
		<cfelse>
			<cfset campo.solo_lectura = 0>
		</cfif>
		
		<cfreturn campo>	
	</cffunction>
</cfcomponent>