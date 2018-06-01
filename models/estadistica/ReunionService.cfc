<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:estadistica.ReunionDAO">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="reunionService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cfset var records = dao.all(arguments.id_evento)>	
	
		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="all2" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cfset var records = dao.all2(arguments.id_evento, arguments.event, arguments.rc)>
	
		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		
		<cfreturn s>
	</cffunction>

	<cffunction name="get" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfargument name="id_participante" required="true">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cfset var records = dao.get(arguments.id_evento, arguments.id_participante, arguments.event, arguments.rc)>

		<cfset s.data.records = records>
		<cfset s.data.count = records.recordCount>
		
		<cfreturn s>
	</cffunction>
</cfcomponent>