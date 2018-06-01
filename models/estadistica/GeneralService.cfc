<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:estadistica.GeneralDAO">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="generalService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" hint="Estadisticas Generales" output="false" returntype="struct">
		<cfargument name="id_evento" required="true" type="any">

		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cftry>
			<cfset var records = dao.all(arguments.id_evento)>
			
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

</cfcomponent>