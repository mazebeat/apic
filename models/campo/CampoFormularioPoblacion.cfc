<cfcomponent output="false" extends="models.campo.CampoFormularioList">

	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>
		
	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfreturn variables.configuracion>
	</cffunction>

	<cffunction name="cargarPoblaciones" access="public" returntype="query">
		<cfargument name="rc" required="no">
		<cfscript>
			include '/default/admin/helpers/external/campoFormularioPoblaciones.cfm';
			var s = exCargarPoblaciones(arguments.rc);
			return s;
		</cfscript>
	</cffunction>
</cfcomponent>