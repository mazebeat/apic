<cfcomponent output="false" extends="models.campo.CampoDAO">
	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>

	<cffunction name="setconfiguracion" returntype="void" output="false">
		<cfargument name="configuracion" required="true" type="Query">

		<cfset variables.configuracion = duplicate(arguments.configuracion)>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfreturn variables.configuracion>
	</cffunction>
</cfcomponent>