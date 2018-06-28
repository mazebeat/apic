<cfcomponent output="false" hint="I am a new handler" extends="handlers.Base">
	
	<cfproperty name="service"	inject="model:formulario.FormularioService">
	<cfproperty name="cache"	inject="cachebox:default">

	<cfscript>
		this.prehandler_only 		= "";
		this.prehandler_except 		= "";
		this.posthandler_only 		= "";
		this.posthandler_except 	= "";
		this.aroundHandler_only 	= "";
		this.aroundHandler_except 	= "";		
		this.allowedMethods 	= {
			index= METHODS.GET,
			get  = METHODS.GET,
			meta = METHODS.GET,
			getByTipoParticipante = METHODS.GET
		};
	</cfscript>
	
	<cffunction name="index" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = service.all(arguments.rc.id_evento, event, rc)>

		<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)>
			<cfset prc.response.addMessage(s.mensaje)>
		</cfif>	
	</cffunction>

	<cffunction name="meta" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cftry>
			<cfset var cacheKey = 'q-formH-meta-#arguments.rc.id_evento#'>

			<cfif cache.lookup(cacheKey)>
				<cfset var s = cache.get(cacheKey)>
				<cfset prc.response.setCachedResponse(true)>
			<cfelse>
				<cfset var s = service.meta(arguments.rc.id_evento)>

				<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
					<cfset s.data.records = QueryToStruct(s.data.records)>
				</cfif>
				<cfset cache.set(cacheKey, s, 60, 30)>
			</cfif>

			<cfset prc.response.setData(s.data).setError(!s.ok)> 
			<cfif NOT isEmpty(s.mensaje)>
				<cfset prc.response.addMessage(s.mensaje)>
			</cfif>			
		<cfcatch type="any">
			<cfthrow type="any" message="Error getting form metadata" detail="#cfcatch.detail#">
		</cfcatch>
		</cftry> 
	</cffunction>

	<cffunction name="get" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var cacheKey = 'q-formH-get-#rc.id_formulario#'>
		
		<cfif cache.lookup(cacheKey)>
			<cfset var s = cache.get(cacheKey)>
			<cfset prc.response.setCachedResponse(true)>
		<cfelse>
			<cfset var s = service.get(rc.id_formulario, event, rc)>

			<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
				<cfset s.data.records = QueryToStruct(s.data.records)>
			</cfif>
			<cfset cache.set(cacheKey, s, 60, 30)>
		</cfif>
	
		<cfset prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)>
			<cfset prc.response.addMessage(s.mensaje)>
		</cfif>	
	</cffunction>

	<cffunction name="getByTipoParticipante" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var s = service.getByTipoParticipante(rc.id_tipo_participante, event, rc)>

		<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)>
			<cfset prc.response.addMessage(s.mensaje)>
		</cfif>	
	</cffunction>

</cfcomponent>