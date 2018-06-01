<cfcomponent output="false" extends="campoFormulario">

	<cffunction name="init" returntype="campoFormularioImagen">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<!--- <cfquery name="local.qConfig" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,1,0)#">
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
	
	<cffunction name="uploadImage" output="false" returntype="string" access="public">
		<cfargument name="urlImage">
		<cfargument name="newNameImage">
		<cfargument name="pathDestiny">

		<cfhttp  method="get" url="#urlImage#" result="result" useragent="#cgi.HTTP_USER_AGENT#" throwonerror="false" getasbinary="yes" />

		<cfscript>
			if(isImageFile(urlImage)){ 

				if(right(pathDestiny, 1) NEQ '/') {
					pathDestiny &= '/';
				}

				var ext = "jpg"
					
				switch(result.mimetype) {
					case "image/jpg": case "image/jpeg":
						ext = "jpg";
						break; 
					case "image/png":
						ext = "png";
						break; 
					case "image/gif":
						ext = "gif";
						break; 
					case "image/raw":
						ext = "raw";
						break; 
					case "image/bpmn":
						ext = "bpmn";
						break;
					default: 
						ext = "jpg";
						break;
				}
 
				newNameImage &= ".#ext#";
				imageWrite(ImageNew(urlImage), "#pathDestiny##newNameImage#");				
			}
		</cfscript>

		<cfreturn newNameImage>
	</cffunction>
</cfcomponent>