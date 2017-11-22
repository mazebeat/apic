<cfcomponent output="false" extends="models.campo.CampoFormularioList">

	<cffunction name="init" returntype="campoFormulario">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	
	
	<cffunction name="getConfiguracion" access="public" returntype="struct" output="false">
<!--- 	
		<cfquery name="local.qConfig" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,1,0)#">
			<!---select solo_lectura
			from vCamposTipoMultiseleccionConfiguracion
			where id_campo = <cfqueryparam value="#variables.instancia.id_campo#" cfsqltype="cf_sql_integer">--->
			SELECT
				solo_lectura
			FROM vCampos
			WHERE id_campo = <cfqueryparam value="#variables.instancia.id_campo#" cfsqltype="cf_sql_integer">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="cf_sql_char">
		</cfquery>
	
		<cfif local.qConfig.recordCount gt 0>
			<cfset variables.configuracion.solo_lectura= local.qConfig.solo_lectura>
		<cfelse>
			<cfset variables.configuracion.solo_lectura = 0>
		</cfif>
	
		<cfreturn variables.configuracion> --->
	</cffunction>
</cfcomponent>