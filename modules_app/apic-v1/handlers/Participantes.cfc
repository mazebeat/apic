<cfcomponent output="false" hint="Handler Participantes" extends="handlers.Base" rest="true">
	<cftimer label= "apic/v1/handlers/Participantes"></cftimer>

	<cfproperty name="service" inject="model:participante.ParticipanteService">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		this.allowedMethods = {
			"index" = '#METHODS.GET#,#METHODS.HEAD#',
			"get"   = '#METHODS.GET#',
			"list"  = '#METHODS.GET#',
			"byType"= '#METHODS.GET#',
			"create"= '#METHODS.POST#',
			"modify"= '#METHODS.PUT#'
		};
	</cfscript>

	<!------------------------------------------- PUBLIC EVENTS ------------------------------------------>


	<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>

	<!--- 
		Obtiene todos los participantes
		@return JSON
	 --->
	<cffunction name="index" output="false" hint="Obtiene todos los participantes">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">	

		<cfset s = service.all(arguments.event, arguments.rc, arguments.prc)>

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

		<cfset s = service.get(arguments.event, arguments.rc, arguments.rc.id_evento, arguments.rc.id_participante)>
		
		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<!--- COMMENT: Arreglar método. --->
	<cffunction name="info" output="false" hint="Obtener participante por ID">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfquery name="local.metaParticipantes" datasource="#application.datasource#">
			SELECT COUNT(*) FROM vParticipantes 
		</cfquery>

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

		<cfset s = service.byType(arguments.event, sanatizeDump(arguments.rc))>

		<cfif NOT structIsEmpty(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>
		
		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<!--- 
		Obtiene el o los participantes que contengan el tipo de participante especificado
		@return JSON
	 --->
	 <cffunction name="byEmail" output="false" hint="Obtener participante por tipo de participante">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfif structKeyExists(arguments.rc, "email")>
			<cfparam name="arguments.rc.contraints.email.regex" default="^[\w!##$%&'*+/=?`{|}~^-]+(?:\.[\w!##$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$">

			<cfset arguments.rc.email = sanatize(arguments.rc.email)>

			<cfif arrayLen(reMatch(arguments.rc.contraints.email.regex, arguments.rc.email)) GT 0>
				<cfset s = service.byEmail(arguments.event, arguments.rc)>
				
				<cfif NOT structIsEmpty(s.data.records)>
					<cfset s.data.records = QueryToStruct(s.data.records)>
				</cfif>
				
				<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
				
				<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
			</cfif>
		</cfif>
	</cffunction>

	<!--- 
		Crea uno o varios participantes
		@return JSON
	 --->
	<cffunction name="create" output="false" hint="Crea un participante">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.create(arguments.event, arguments.rc, arguments.prc)>
		<cfset arguments.prc.response.setData(s.data)
			.setStatusCode(STATUS.CREATED)
			.setStatusText(MESSAGES.CREATED)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<!--- 
		Modifica uno o varios participantes 
	 --->
	<cffunction name="modify" output="false" hint="Actualiza un participante">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.modify(arguments.event, arguments.rc, arguments.rc.id_evento)>
		<cfset arguments.prc.response.setData(s.data)
			.setStatusCode(STATUS.ACCEPTED)
			.setStatusText(MESSAGES.ACCEPTED)>  
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<cffunction name="filterBy" output="false" hint="Actualiza un participante">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.modify(arguments.event, arguments.rc, arguments.rc.id_evento)>
		<cfset arguments.prc.response.setData(s.data)> 
		
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	
</cfcomponent>