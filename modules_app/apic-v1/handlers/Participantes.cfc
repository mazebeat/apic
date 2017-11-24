<cfcomponent output="false" hint="Handler Participantes" extends="handlers.Base">
	<cftimer label= "apic/v1/handlers/Participantes"></cftimer>

	<cfproperty name="service" inject="model:participante.ParticipanteService">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		// REST HTTP Methods Allowed for actions.
		// Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'} */
		this.allowedMethods = {
			"index" = '#METHODS.GET#,#METHODS.HEAD#',
			"get"   = '#METHODS.GET#',
			"list"  = '#METHODS.GET#',
			"byType"= '#METHODS.GET#'
		};
	</cfscript>

<!----------------------------------------- IMPLICIT EVENTS ------------------------------------------>

	<!--- UNCOMMENT HANDLER IMPLICIT EVENTS
	
	<!--- preHandler --->
	<cffunction name="preHandler" returntype="void" output="false" hint="Executes before any event in this handler">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="action" hint="The intercepted action"/>
		<cfargument name="eventArguments" hint="The event arguments an event is executed with (if any)"/>
		
	</cffunction>

	<!--- postHandler --->
	<cffunction name="postHandler" returntype="void" output="false" hint="Executes after any event in this handler">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="action" 			hint="The intercepted action"/>
		<cfargument name="eventArguments" 	hint="The event arguments an event is executed with (if any)"/>
		
	</cffunction>
	
	<!--- aroundHandler --->
	<cffunction name="aroundHandler" returntype="void" output="false" hint="Executes around any event in this handler">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="targetAction" 	hint="The intercepted action UDF method"/>
		<cfargument name="eventArguments" 	hint="The event arguments an event is executed with (if any)"/>
		<cfscript>
			// process targeted action
			argument.targetAction( event );
		</cfscript>
	</cffunction>

	<!--- onMissingAction --->
	<cffunction name="onMissingAction" returntype="void" output="false" hint="Executes if a request action (method) is not found in this handler">
		<cfargument name="event" >
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="missingAction" 	hint="The requested action string"/>
		<cfargument name="eventArguments" 	hint="The event arguments an event is executed with (if any)"/>
		
	</cffunction>
	
	<!--- onError --->
	<cffunction name="onError" output="false" hint="Executes if ANY action causes an exception">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfargument name="faultAction" 		hint="The action that caused the error"/>
		<cfargument name="exception"  		hint="The exception structure"/>
		<cfargument name="eventArguments" 	hint="The event arguments an event is executed with (if any)"/>
		
	</cffunction>
	
	--->

<!------------------------------------------- PUBLIC EVENTS ------------------------------------------>
	<!--- 
		Obtiene todos los participantes
		@return JSON
	 --->
	<cffunction name="index" output="false" hint="Obtiene todos los participantes">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">	

		<cfset s = service.all(arguments.event, arguments.rc)>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<!--- 
		Obtiene un particiante especifico por su ID
		@return JSON
	 --->
	<cffunction name="get" output="false" hint="Obtener participante por ID">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.get(arguments.event, arguments.rc, rc.id_participante)>
		
		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	// COMMENT: Arreglar método.
	<cffunction name="info" output="false" hint="Obtener participante por ID">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfquery name="local.metaParticipantes" datasource="#application.datasource#">
			SELECT COUNT(*) FROM vParticipantes 
		</cfquery>

		<cfdump var="#local.metaParticipantes#">		

		<cfdump var="GETINFO"><cfabort>		
	</cffunction>

	<!--- 
		Obtiene el o los participantes que contengan el tipo de participante especificado
		@return JSON
	 --->
	<cffunction name="byType" output="false" hint="Obtener participante por tipo de participante">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.byType(arguments.event, arguments.rc, clearArgumentWhiteSpace(arguments.rc.tipo_participante))>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>
		
		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>
<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>

</cfcomponent>

