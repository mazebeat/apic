<!--
 * Handler Estadisticas
 ->
<cfcomponent output="false" hint="Estadisticas Handler" extends="handlers.Base">
	<cftimer label= "apic/v1/handlers/Estadisticas"></cftimer>

	<cfproperty name="generalServ" inject="model:estadistica.GeneralService">
	<cfproperty name="reunionServ" inject="model:estadistica.ReunionService">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		// REST HTTP Methods Allowed for actions.
		// Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'} */
		this.allowedMethods 	= {
			"index"    = METHODS.GET,
			"reunions" = METHODS.GET
		};
	</cfscript>


<!------------------------------------------- PUBLIC EVENTS ------------------------------------------>
	<cffunction name="index" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		
		<cfset var s = generalServ.all(session.id_evento)>
		
		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>

</cfcomponent>

