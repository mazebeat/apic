<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="dao"			inject="model:producto.ProductoDAO">
    <cfproperty name="log" 			inject="logbox:logger:{this}">
    <cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ProductoService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" hint="Todos los productos por grupo" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">

		<cfset var s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<!--- <cftry> --->
			<cfset var records = dao.all(arguments.id_evento)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>

	<cffunction name="get" hint="Todos los productos por grupo" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfargument name="id_producto" type="numeric" required="true">

		<cfset var s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<!--- <cftry> --->
			<cfset var records = dao.get(arguments.id_evento, arguments.id_producto)>	
		
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>

	<!--- 
		Obtiene todos los productos seleccionados
	 --->
	<cffunction name="allSelected" hint="Obtiene todos los productos seleccionados" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset var s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<!--- <cftry> --->
			<cfset var records = dao.allSelected(arguments.id_evento, arguments.event, arguments.rc)>	

			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>	

	<!--- 
		Obtiene todos los productos seleccionados por id_participante
	 --->
	<cffunction name="selectedByParticipante" hint="Todos los productos por grupo" output="false" returntype="struct">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset var s = { ok = true, mensaje= "", data = { "records":{},  "count"= 0}}>

		<!--- <cftry> --->
			<cfset var records = dao.selectedByParticipante(arguments.id_evento, arguments.event, arguments.rc)>
			
			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<!--- <cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry>  --->
		
		<cfreturn s>
	</cffunction>	
</cfcomponent>