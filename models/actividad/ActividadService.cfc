<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:actividad.ActividadDAO">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ActividadService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = { ok = true, mensaje= "", data = { 'records':{},  'count'= 0}}>

		<cftry>
			<cfset var records = dao.all(arguments.event, arguments.rc, arguments.prc)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="Loading Activities failed" detail="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

	<cffunction name="byParticipante" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = { ok = true, mensaje= "", data = { 'records':{},  'count'= 0}}>

		<cftry>
			<cfset var records = dao.getByParticipante(arguments.event, arguments.rc, arguments.prc)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="Loading Activities of #arguments.rc.id_participante# failed" detail="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>
</cfcomponent>