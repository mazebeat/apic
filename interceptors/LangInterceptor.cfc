<cfcomponent hint="Language Interceptor" output="false">

	<cffunction name="configure" access="public" returntype="void" output="false" hint="Interceptor config">
		<cfscript>
			return false;
		</cfscript>
	</cffunction>

	<cffunction name="preProcess" returntype="void" output="false" access="public">
		<cfargument name="event"			hint="The request context object" />
		<cfargument name="rc"				hint="Request Context struct" />
		<cfargument name="prc"				hint="Private Request Context struct" />
		<cfargument name="interceptData" 	hint="A structure containing intercepted information." />
		<cfargument name="buffer" 			hint="A request buffer to produce elegant output from the interceptor" />

		<cfparam name="arguments.rc.language" default="ES">

		<cfset local.countryLanguage = {
			"es": "es_ES",
			"en": "en_US",
			"fr": "fr_FR"
		}>

		<cfif structKeyExists(arguments.rc, "lang")>
			<cfset session.language = uCase(mid(arguments.rc.lang, 1, 2))>
			<cfset arguments.rc.language = session.language>

			<cfif NOT arrayFind(application.languages, arguments.rc.language)>
				<cfscript>
					if(!structKeyExists(prc, "response")){ 
						prc.response = getModel("Response"); 
					}

					prc.response
						.setError(true)
						.addMessage("Language not found")
						.setStatusCode(400)
						.setStatusText("Bad request");
						
					event.renderData(
						type		= prc.response.getFormat(),
						data 		= prc.response.getDataPacket(reset=true),
						contentType = prc.response.getContentType(),
						statusCode 	= prc.response.getStatusCode(),
						statusText 	= prc.response.getStatusText(),
						location 	= prc.response.getLocation(),
						isBinary 	= prc.response.getBinary()
					);
				</cfscript>		
			</cfif>
			<cfset setFWLocale(local.countryLanguage[lCase(rc.language)])>	
		<cfelse>
			<cfset setFWLocale(local.countryLanguage[lCase(application.language)])>	
			<cfset session.language = application.language>
		</cfif>	
	</cffunction>

	<cffunction name="postProcess" returntype="void" output="false" access="public">
	</cffunction>
</cfcomponent>

