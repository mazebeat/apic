<!--  
	Evento Service
-->
<cfcomponent hint="Evento Service" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:evento.EventoDAO">
	<cfproperty name="clientedao" 	inject="model:cliente.Cliente">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="EventoService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="all" hint="Todos los eventos" output="false" returntype="struct">
		<cfset s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<cftry>
			<cfset var records = dao.all()>	

			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

</cfcomponent>