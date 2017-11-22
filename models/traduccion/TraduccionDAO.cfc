<cfcomponent hint="I am a new Model Object" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="TraduccionDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="get" access="public" returntype="string" output="false">
		<cfargument name="id_traduccion" type="numeric" required="true">
		
		<cfquery name="local.traduccion" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, queryExpiration, 0 )#">
			SELECT texto_#session.language# AS texto
			FROM traducciones
			WHERE id_traduccion = <cfqueryparam value="#arguments.id_traduccion#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfreturn local.traduccion.texto>
	</cffunction>

</cfcomponent>