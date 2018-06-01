<cfcomponent output="false" extends="models.campo.CampoFormularioList">
	
	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfreturn variables.configuracion>
	</cffunction>

	<cffunction name="getListaValoresPorOrden" access="public" returntype="query">
		<cfargument name="id_idioma" required="false" default="#session.language#">
		<cfscript>
			include '/default/admin/helpers/external/campoFormularioPais.cfm';
			var s = exCargarPaises();
			return s;
		</cfscript>
	</cffunction>

	<cffunction name="cargarPaises" access="public" returntype="query">
		<cfargument name="id_idioma" required="false" default="ES">
		<cfscript>
			include '/default/admin/helpers/external/campoFormularioPais.cfm';
			var s = exCargarPaises(arguments.id_idioma);
			return s;
		</cfscript>
	</cffunction>	
</cfcomponent>