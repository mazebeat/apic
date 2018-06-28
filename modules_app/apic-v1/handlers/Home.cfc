<cfcomponent output="false" hint="Home Handler" extends="handlers.Base">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		// REST HTTP Methods Allowed for actions.
		// Ex= this.allowedMethods = {delete='POST,DELETE',index='GET'} */
		this.allowedMethods = {
			"index"= METHODS.GET,
			"doc"  = METHODS.GET
		};
	</cfscript>

	<!--- 
		Home del modulo APIc V1
		@return JSON
	--->
    <cffunction name="index" output="false" hint="Index">
    	<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset arguments.prc.response.setMessages([]).addMessage(getResource(resource='api.welcomeAPI'))>
	</cffunction>

	<cffunction name="doc" hint="Despliega documentación APIc V1">	
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset arguments.event.setView("home/documentation").noLayout()>
	</cffunction>
</cfcomponent>
