<cfcomponent output="false" hint="I am a new handler" extends="handlers.Base">
	<cftimer label= "apic/v1/handlers/Reuniones"></cftimer>

	<cfproperty name="service" inject="model:estadistica.ReunionService">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		this.allowedMethods		 	= {};
	</cfscript>

	<cffunction name="index" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = service.all(arguments.event, arguments.rc, arguments.prc)>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<cffunction name="all" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = service.all2(arguments.event, arguments.rc, arguments.prc)>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<cffunction name="get" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		
		<cfset var s = service.get(arguments.event, arguments.rc, arguments.prc)>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>
</cfcomponent>

