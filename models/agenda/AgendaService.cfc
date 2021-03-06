<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:agenda.AgendaDAO">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="AgendaService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="index" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="language">

		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cfset var records = dao.index(arguments.event, arguments.rc, arguments.prc, arguments.language)>	
	
		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="get" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="language">

		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cfset var records = dao.get(arguments.event, arguments.rc, arguments.prc, arguments.language)>	
	
		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		
		<cfreturn s>
	</cffunction>

</cfcomponent>