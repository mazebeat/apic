<cfcomponent hint="Language Interceptor" output="false">

<!------------------------------------------- CONFIGURATOR -------------------------------------------------->

	<cffunction name="configure" access="public" returntype="void" output="false" hint="Interceptor config">
		<cfscript>
			
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="preProcess" returntype="void" output="false" access="public">
		<cfargument name="event" hint="The request context object" />
		<cfargument name="rc" hint="Request Context struct" />
		<cfargument name="prc" hint="Private Request Context struct" />
		<cfargument name="interceptData" hint="A structure containing intercepted information." />
		<cfargument name="buffer" hint="A request buffer to produce elegant output from the interceptor" />

		<cfif structkeyexists(arguments.rc, "lang")>
			<cfset session.language = uCase(mid(arguments.rc.lang, 1, 2))>

			<cfif NOT arrayFind(application.languages, session.language)>
				<cfset prc.response = getModel("Response")>
				<cfset prc.response.setError(true)
									.addMessage("Language not found")
									.setStatusCode(400)
									.setStatusText("Bad request")>
				<cfset event.renderData(
						type		= prc.response.getFormat(),
						data 		= prc.response.getDataPacket(reset=true),
						contentType = prc.response.getContentType(),
						statusCode 	= prc.response.getStatusCode(),
						statusText 	= prc.response.getStatusText(),
						location 	= prc.response.getLocation(),
						isBinary 	= prc.response.getBinary()
					)>
			</cfif>
		<cfelse>
			<cfset session.language = application.language>
		</cfif>
	</cffunction>


	<cffunction name="postProcess" returntype="void" output="false" access="public">
		<cfargument name="event" hint="The request context object" />
		<cfargument name="rc" hint="Request Context struct" />
		<cfargument name="prc" hint="Private Request Context struct" />
		<cfargument name="interceptData" hint="A structure containing intercepted information." />
		<cfargument name="buffer" hint="A request buffer to produce elegant output from the interceptor" />
		
	</cffunction>

</cfcomponent>

