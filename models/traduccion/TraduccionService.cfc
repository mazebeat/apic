<cfcomponent hint="Traduccion Service" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao" inject="model:traduccion.TraduccionDAO">
	<cfproperty name="cache" inject="cachebox:default">


<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="TraduccionService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="get" access="public" returntype="string" output="false">
		<cfargument name="id_traduccion" type="numeric" required="true">
		<cfargument name="language" type="string" default="#session.language#">

		<cfset var cacheKey = 'q-trad-#arguments.id_traduccion#-#arguments.language#'>

		<!--- <cfif cache.lookup(cacheKey)>
			<cfset result = cache.get(cacheKey)>
		<cfelse> --->
			<cfset result = dao.get(arguments.id_traduccion, arguments.language)>
			<!--- <cfset cache.set(cacheKey, result, 60, 30)> --->
		<!--- </cfif> --->

		<cfreturn result>
	</cffunction>

</cfcomponent>