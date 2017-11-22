<cfcomponent output="false" extends="models.campo.CampoFormularioList">

	<cffunction name="init" returntype="campoFormulario">
		<cfset super.init()>
		<cfreturn this>

	</cffunction>
		
	<cffunction name="getConfiguracion" access="public" returntype="struct" output="false">
		<cfreturn variables.instancia.configuracion>
	</cffunction>

	<cffunction name="getListaValoresPorOrden" access="public" returntype="query">
		<cfargument name="id_idioma" required="false" default="#session.language#">
		<cfscript>
			include '/default/admin/helpers/external/campoFormularioProvincias.cfm';
			var s = exCargarProvincias();
			return s;
		</cfscript>
	</cffunction>

	<cffunction name="cargarProvincias" access="public" returntype="query">
		<cfscript>
			include '/default/admin/helpers/external/campoFormularioProvincias.cfm';
			var s = exCargarProvincias();
			return s;
		</cfscript>
	</cffunction>
</cfcomponent>