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
		<cfargument name="id_evento">

		<cfset var s = { ok = true, mensaje= "", data = { 'records':{},  'count'= 0}}>

		<cftry>
			<cfset var records = dao.all(arguments.id_evento)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="Loading Activities failed" detail="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

	<cffunction name="byParticipante" hint="Todos los eventos" output="false" returntype="struct">
		<cfargument name="id_evento">
		<cfargument name="id_participante">

		<cfset var s = { ok = true, mensaje= "", data = { 'records':{},  'count'= 0}}>

		<cftry>
			<cfset var records = dao.getByParticipante(arguments.id_evento, arguments.id_participante)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="Loading Activities of #arguments.id_participante# failed" detail="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>
</cfcomponent>