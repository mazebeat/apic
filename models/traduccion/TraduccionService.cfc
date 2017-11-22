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

		<cfset var cacheKey = 'q-trad-#id_traduccion#'>

		<cfif cache.lookup(cacheKey)>
			<cfset result = cache.get(cacheKey)>
		<cfelse>
			<cfset result = dao.get(id_traduccion)>
			<cfset cache.set(cacheKey, result, 60, 30)>
		</cfif>

		<cfreturn result>
	</cffunction>

</cfcomponent>