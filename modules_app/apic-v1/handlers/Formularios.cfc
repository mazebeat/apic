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
		// REST HTTP Methods Allowed for actions.
		// Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'} */
		this.allowedMethods 	= {
			index= METHODS.GET,
			get  = METHODS.GET
		};
	</cfscript>


<!------------------------------------------- PUBLIC EVENTS ------------------------------------------>
	<cffunction name="index" output="false" hint="index">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset s = service.all(session.id_evento)>

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

		<cfset s = service.byEvento(session.id_evento)>

		<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)>
			<cfset prc.response.addMessage(s.mensaje)>
		</cfif>	
	</cffunction>

	<cffunction name="get" output="false" hint="get">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="prc">

		<cfset var cacheKey = 'q-formH-get-#rc.id_formulario#'>
		
		<cfif cache.lookup(cacheKey)>
			<cfset var s = cache.get(cacheKey)>
		<cfelse>
			<cfset s = service.get(rc.id_formulario)>

			<cfif NOT len(s.data.records) AND isQuery(s.data.records)>
				<cfset var s.data.records = QueryToStruct(s.data.records)>
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

		<cfset s = service.getByTipoParticipante(rc.id_tipo_participante)>

		<cfif NOT structIsEmpty(s.data.records) AND isQuery(s.data.records)>
			<cfset s.data.records = QueryToStruct(s.data.records)>
		</cfif>

		<cfset prc.response.setData(s.data).setError(!s.ok)> 
		<cfif NOT isEmpty(s.mensaje)>
			<cfset prc.response.addMessage(s.mensaje)>
		</cfif>	
	</cffunction>

<!------------------------------------------- PRIVATE EVENTS ------------------------------------------>

</cfcomponent>

