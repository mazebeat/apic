<cfcomponent output="false" hint="I am a new handler" extends="handlers.Base">
	
	<cfproperty name="service"	inject="model:producto.ProductoService">
	<cfproperty name="cache"	inject="cachebox:default">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		this.allowedMethods 		= {};
	</cfscript>

	<cffunction name="index" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var cacheKey = 'q-product-all-#session.id_evento#-#session.language#'>

		<cfif cache.lookup(cacheKey)>
			<cfset var s = cache.get(cacheKey)>
			<cfset prc.response.setCachedResponse(true)>
		<cfelse>
			<cfset var s = service.all(session.id_evento)>

			<cfif NOT structIsEmpty(s.data.records)>
				<cfset s.data.records = QueryToStruct(s.data.records)>
			</cfif>

			<cfset cache.set(cacheKey, s, 60, 30)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<cffunction name="get" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">
		<cfset event.setView( "Productos/get" )>
	</cffunction>

	<cffunction name="allSelected" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var cacheKey = 'q-product-allSelected-#session.id_evento#-#session.language#'>

		<cfif cache.lookup(cacheKey)>
			<cfset var s = cache.get(cacheKey)>
			<cfset prc.response.setCachedResponse(true)>
		<cfelse>
			<cfset var s = service.allSelected(session.id_evento, arguments.event, arguments.rc)>

			<cfif NOT structIsEmpty(s.data.records)>
				<cfset s.data.records = QueryToStruct(s.data.records)>
			</cfif>

			<cfset cache.set(cacheKey, s, 60, 30)>
		</cfif>

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

	<cffunction name="byParticipante" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var cacheKey = 'q-product-selectedByParticipante-#session.id_evento#-#session.language#'>

		<!--- <cfif cache.lookup(cacheKey)>
			<cfset var s = cache.get(cacheKey)>
			<cfset prc.response.setCachedResponse(true)>
		<cfelse> --->
			<cfset var s = service.selectedByParticipante(session.id_evento, arguments.event, arguments.rc)>

			<cfif NOT structIsEmpty(s.data.records)>
				<cfset s.data.records = QueryToStruct(s.data.records)>
			</cfif>

			<!--- <cfset cache.set(cacheKey, s, 60, 30)>
		</cfif> --->

		<cfset arguments.prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)><cfset arguments.prc.response.addMessage(s.mensaje)></cfif>
	</cffunction>

</cfcomponent>

