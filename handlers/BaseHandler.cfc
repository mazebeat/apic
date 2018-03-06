/**
* ********************************************************************************
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ********************************************************************************
* Base RESTFul handler spice up as needed.
* This handler will create a Response model and prepare it for your actions to use
* to produce RESTFul responses.
*/
component extends="coldbox.system.EventHandler"{
	// Inject AuthenticationService
	property name="authService" type="any" 			inject="model:security.AuthenticationService";
	property name="emaillogger" type="any" 			inject="logBox:logger:emaillogger"; 
	property name="maxRequest"	type="numeric" 		inject="coldbox:setting:maxUserRequest";
	property name="waitTimeRequest"	type="numeric" 	inject="coldbox:setting:waitTimeRequest";

	// Pseudo "constants" used in API Response/Method parsing
	property name="METHODS";
	property name="STATUS";
	property name="MESSAGES";

	// Verb aliases - in case we are dealing with legacy browsers or servers (e.g. IIS7 default)
	METHODS = {
		"HEAD"    = "HEAD",
		"GET"     = "GET",
		"POST"    = "POST",
		"PATCH"   = "PATCH",
		"PUT"     = "PUT",
		"DELETE"  = "DELETE",
		"OPTIONS" = "OPTIONS"
	};
	
	// HTTP STATUS CODES
	STATUS                    = {
		"CONTINUE"               = 100,
		"CHECKPONT"              = 103,
		"SUCCESS"                = 200,
		"CREATED"                = 201,
		"ACCEPTED"               = 202,
		"NO_CONTENT"             = 204,
		"RESET"                  = 205,
		"PARTIAL_CONTENT"        = 206,
		"MULTI_STATUS"           = 207,
		"ALREADY_REPORTED"       = 208,
		"BAD_REQUEST"            = 400,
		"NOT_AUTHORIZED"         = 403,
		"NOT_AUTHENTICATED"      = 401,
		"NOT_FOUND"              = 404,
		"NOT_ALLOWED"            = 405,	
		"NOT_ACCEPTABLE"         = 406,
		"GONE"                   = 410,
		"CONFLICT"               = 409,
		"UNSUPPORTED_MEDIA_TYPE" = 415,
		"EXPECTATION_FAILED"     = 417,
		"TOO_MANY_REQUESTS"      = 429,
		"INTERNAL_ERROR"         = 500,
		"NOT_IMPLEMENTED"        = 501,
		"PARAMETERS_ERROR"       = 502,
		"SERVICE_UNAVAILABLE"    = 503
	};

	MESSAGES = {
		"CONTINUE"               = "Continue",
		"CHECKPONT"              = "Checkpoint",
		"SUCCESS"                = "Success",
		"CREATED"                = "Created",
		"ACCEPTED"               = "Accepted",
		"NO_CONTENT"             = "No content",
		"RESET"                  = "Reset",
		"PARTIAL_CONTENT"        = "Partial content",
		"MULTI_STATUS"           = "Multi status",
		"ALREADY_REPORTED"       = "Already reported",
		"BAD_REQUEST"            = "Bad request",
		"NOT_AUTHORIZED"         = "Unauthorized Resource",
		"NOT_AUTHENTICATED"      = "Invalid or Missing Credentials",
		"NOT_FOUND"              = "Not found",
		"NOT_ALLOWED"            = "Invalid HTTP Method",
		"NOT_ACCEPTABLE"         = "Unacceptable",
		"GONE"                   = "Gone",
		"CONFLICT"               = "Conflict",
		"UNSUPPORTED_MEDIA_TYPE" = "Unsupported media type",
		"EXPECTATION_FAILED"     = "Expectation Failed",
		"TOO_MANY_REQUESTS"      = "Too many request",
		"INTERNAL_ERROR"         = "General application error",
		"NOT_IMPLEMENTED"        = "Not implemented",
		"PARAMETERS_ERROR"       = "Parameters error",
		"SERVICE_UNAVAILABLE"    = "Service Unavailable"
	}

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 		= "";
	this.prehandler_except 		= "";
	this.posthandler_only 		= "";
	this.posthandler_except 	= "";
	this.aroundHandler_only 	= "";
	this.aroundHandler_except 	= "";		

	// REST Allowed HTTP Methods Ex= this.allowedMethods = {delete='#METHODS.POST#,#METHODS.DELETE#',index='#METTHOD.GET#'}
	this.allowedMethods = {
		"index" : METHODS.GET & "," & METHODS.HEAD,
		"get" 	: METHODS.GET,
		"create": METHODS.POST,
		"list" 	: METHODS.GET,
		"update": METHODS.PUT & "," & METHODS.PATCH,
		"delete": METHODS.DELETE
	};

	function init() {
        // init super
		super.init(application.cbController);
        // my stuff here
        return this;
    }

	/**
	 * PreHandler for all actions it inherits
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 * @targetAction 
	 * @eventArguments 
	 */
	function preHandler(event, rc, prc, targetAction, eventArguments) {
		try {
			// Start time
			var stime    = getTickCount();
			
			// prepare our response object
			prc.response = getModel("Response");

			try {
				if (isJSON(request._body)) {
					structAppend( rc, deserializeJSON(request._body), true );
				} else if( isJSON( event.getHTTPContent() ) ){
					structAppend( rc, event.getHTTPContent( json=true ), true );
				}
			} catch(Any e) {
				throw(message="Invalid JSON Format!", errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
			}
			
			if (findNoCase("Echo", event.getCurrentEvent()) == 0 && 
				findNoCase("Authenticate", event.getCurrentEvent()) == 0 && 
				findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {

				// Limiter
				limiterByTime(maxRequest, waitTimeRequest, prc, event);
				
				// Validat user actions
				validateActions(event, rc, prc);	
			}				
		} catch(Any e){
			// Log Locally
			log.error("[PreHandler] Error calling #event.getCurrentEvent()#: #e.message# #e.detail#", e);			

			// Setup General Error Response
			prc.response
				.setError(true)
				.addMessage("General application error: #e.message#")
				.setStatusCode(STATUS.INTERNAL_ERROR)
				.setStatusText(MESSAGES.INTERNAL_ERROR);			
			
			// Development additions
			if(getSetting("environment") eq "development") {
				// TODO: Modificar el modo de mostrar errores en desarrollo.		
				prc.response.addMessage("Detail: #e.detail#")
							.addMessage("StackTrace: #e.stacktrace#");
			}
		}
		
		// end timer
		prc.response.setResponseTime(getTickCount() - stime);
	}

	/**
	* Around handler for all actions it inherits
	*/
	function aroundHandler(event, rc, prc, targetAction, eventArguments) {
		try{
			var stime    = getTickCount();

			// prepare our response object
			prc.response = getModel("Response");
			
			// prepare argument execution
			var args = { event = event, rc = rc, prc = prc };
			structAppend(args, eventArguments);

			// Incoming Format Detection
			if(structKeyExists(rc, "format")){
				prc.response.setFormat(rc.format);
			}

			// Check APIc Token
			checkAuthenticationToken(event, rc, prc, targetAction, eventArguments, args);

			// Check Sessions			
			validateSession(event, rc, prc);

			// Execute action
			if (!prc.response.getError()) {
				var actionResults = targetAction(argumentCollection=args);
			}
		} catch(Any e){	
			// Log Locally
			log.error("[AroundHandler] Error calling #event.getCurrentEvent()#: #e.message# #e.detail#", e);			

			// Setup General Error Response
			prc.response
				.setError(true)
				// .addMessage("General application error: #e.message#")
				.addMessage("General application error")
				.setStatusCode(STATUS.INTERNAL_ERROR)
				.setStatusText(MESSAGES.INTERNAL_ERROR);	
				
			// Development additions
			if((getSetting("environment") eq "development") ) { 
				// TODO: Modificar el modo de mostrar errores en desarrollo.		
				prc.response.addMessage("Detail: #e.detail#")
							.addMessage("StackTrace: #e.stacktrace#");
			}

			sendError(e, rc, event);
		}
		// Development additions
		if(getSetting("environment") eq "development"){
			prc.response.addHeader("x-current-route", event.getCurrentRoute())
				.addHeader("x-current-routed-url", event.getCurrentRoutedURL())
				.addHeader("x-current-routed-namespace", event.getCurrentRoutedNamespace())
				.addHeader("x-current-event", event.getCurrentEvent());
		}

		// end timer
		prc.response.setResponseTime(getTickCount() - stime);

		// If results detected, just return them, controllers requesting to return results
		if(!isNull(actionResults)){
			return actionResults;
		}
		
		// Verify if controllers doing renderdata overrides? If so, just short-circuit out.
		if(!structIsEmpty(event.getRenderData())){
			return;
		}
		
		// Get response data
		var responseData = prc.response.getDataPacket();
		// If we have an error flag, render our messages and omit any marshalled data
		if(prc.response.getError()){
			responseData = prc.response.getDataPacket(reset=true);
		}
		
		// Did the controllers set a view to be rendered? If not use renderdata, else just delegate to view.
		// if(getSetting("environment") EQ "development" && isdefined("url.debug")) {
		if(isdefined("url.debug")) {
			writeDump(var="#event.getCurrentEvent()#", label="Event");
			writeDump(var="#prc.response.getDataPacket()#", label="JSON Response");
			writeDump(var="#session#", label="Session");

			if(isdefined('url.show')) {
				abort;
			}
		}

		if(!len(event.getCurrentView())){
			
			// Magical Response renderings
			event.renderData(
				type		= prc.response.getFormat(),
				data 		= prc.response.getDataPacket(),
				contentType = prc.response.getContentType(),
				statusCode 	= prc.response.getStatusCode(),
				statusText 	= prc.response.getStatusText(),
				location 	= prc.response.getLocation(),
				isBinary 	= prc.response.getBinary()
			);
		}

		// Global Response Headers
		prc.response.addHeader("x-response-time", prc.response.getResponseTime()).addHeader("x-cached-response", prc.response.getCachedResponse());
	
		
		// Response Headers
		for(var thisHeader in prc.response.getHeaders()){
			event.setHTTPHeader(name=thisHeader.name, value=thisHeader.value);
		}
	}

	/**
	* on localized errors
	*/
	function onError(event, rc, prc, faultAction, exception, eventArguments){

		if(isdefined("url.debug")) {
			writeDump(var="#event#", label="event OnError");
			abort;
		}

		// Log Locally
		log.error("Error in base handler (#faultAction#): #exception.message# #exception.detail#", exception);
		
		// Verify response exists, else create one
		if(!structKeyExists(prc, "response")){ 
			prc.response = getModel("Response"); 
		}

		// Setup General Error Response
		prc.response
			.setError(true)
			.addMessage("Base Handler Application Error: #exception.message#")
			.setStatusCode(STATUS.INTERNAL_ERROR)
			.setStatusText(MESSAGES.INTERNAL_ERROR);
		
		// Development additions
		if(getSetting("environment") eq "development"){
			prc.response.addMessage("Detail: #exception.detail#")
				.addMessage("StackTrace: #exception.stacktrace#");
		}

		// Send error mail
		sendError(exception, rc, event);
		
		// If in development, then it will show full trace error template, else render data
		if(getSetting("environment") neq "development"){
			// Render Error Out
			event.renderData(
				type		= prc.response.getFormat(),
				data 		= prc.response.getDataPacket(reset=true),
				contentType = prc.response.getContentType(),
				statusCode 	= prc.response.getStatusCode(),
				statusText 	= prc.response.getStatusText(),
				location 	= prc.response.getLocation(),
				isBinary 	= prc.response.getBinary()
			);
		}

	}

	/**
	* on invalid http verbs
	*/
	function onInvalidHTTPMethod(event, rc, prc, faultAction, eventArguments){
		// Log Locally
		log.warn("InvalidHTTPMethod Execution of (#faultAction#): #event.getHTTPMethod()#", getHTTPRequestData());
		// Setup Response
		prc.response = getModel("Response")
			.setError(true)
			// .addMessage("InvalidHTTPMethod Execution of (#faultAction#): #event.getHTTPMethod()#")
			.addMessage("InvalidHTTPMethod Execution: #event.getHTTPMethod()#")
			.setStatusCode(STATUS.NOT_ALLOWED)
			.setStatusText(MESSAGES.NOT_ALLOWED);
		// Render Error Out
		event.renderData(
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket(reset=true),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);
	}

	/**
	* Invalid method execution
	**/
	function onMissingAction(event, rc, prc, missingAction, eventArguments){
		// Log Locally
		log.warn("Invalid HTTP Method Execution of (#missingAction#): #event.getHTTPMethod()#", getHTTPRequestData());
		// Setup Response
		prc.response = getModel("Response")
			.setError(true)
			.addMessage("Action '#missingAction#' could not be found")
			.setStatusCode(STATUS.NOT_ALLOWED)
			.setStatusText("Invalid Action");
		
		// Render Error Out
		event.renderData(
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket(reset=true),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);			
	}

	/**************************** RESTFUL UTILITIES ************************/

	/**
	* Utility function for miscellaneous 404's
	**/
	private function routeNotFound(event, rc, prc){
		
		if(!structKeyExists(prc, "response")){
			prc.response = getModel("Response");
		}

		prc.response.setError(true)
			.setStatusCode(STATUS.NOT_FOUND)
			.setStatusText(MESSAGES.NOT_FOUND)
			.addMessage("The object requested could not be found");
	}

	/**
	* Utility method for when an expectation of the request failes (e.g. an expected paramter is not provided)
	**/
	private function onExpectationFailed( event = getRequestContext(), rc = getRequestCollection(), prc = getRequestCollection(private=true) ) {
		if(!structKeyExists(prc, "response")){
			prc.response = getModel("Response");
		}

		prc.response.setError(true)
			.setStatusCode(STATUS.EXPECTATION_FAILED)
			.setStatusText(MESSAGES.EXPECTATION_FAILED)
			.addMessage("An expectation for the request failed. Could not proceed");		
	}

	/**
	* Utility method to render missing or invalid authentication credentials
	**/
	private function onAuthenticationFailure( event	= getRequestContext(), rc = getRequestCollection(), prc = getRequestCollection(private=true), abort = false ) {
		if(!structKeyExists(prc, "response")){
			prc.response = getModel("Response");
		}

		log.warn("Invalid Authentication", getHTTPRequestData());

		prc.response.setError(true)
			.setStatusCode(STATUS.NOT_AUTHENTICATED)
			.setStatusText(MESSAGES.NOT_AUTHENTICATED)
			.addMessage("Invalid or Missing Authentication Credentials");
	}

	/**
	* Utility method to render a failure of authorization on any resource
	*
	*/
	private function onAuthorizationFailure( event = getRequestContext(), rc = getRequestCollection(), prc = getRequestCollection(private=true), abort = false ){
		if(!structKeyExists(prc, "response")){
			prc.response = getModel("Response");
		}

		log.warn("Authorization Failure", getHTTPRequestData());

		prc.response.setError(true)
			.setStatusCode(STATUS.NOT_AUTHORIZED)
			.setStatusText(MESSAGES.NOT_AUTHORIZED)
			.addMessage("Your permissions do not allow this operation");

		/**
		* When you need a really hard stop to prevent further execution (use as last resort)
		**/
		if(abort){

			event.setHTTPHeader(
				name 	= "Content-Type",
	        	value 	= "application/json"
			);

			event.setHTTPHeader(
				statusCode = "#STATUS.NOT_AUTHORIZED#",
	        	statusText = "Not Authorized"
			);
			
			writeOutput(
				serializeJSON(prc.response.getDataPacket(reset=true)) 
			);
			flush;
			abort;
		}
	}

	/**
	 * Check Atuhentication Token
	 */
	private any function checkAuthenticationToken(event, rc, prc, targetAction, eventArguments, args) {
	
		/* Only accept application/json for content body on posts */
			if ((event.getHTTPMethod() == "POST" || event.getHTTPMethod() == "PUT") && !prc.response.getError()) {
				if (findNoCase("application/json", event.getHTTPHeader("Content-Type")) == 0) {
					prc.response.setError(true)
								.addMessage("Content-Type application/json is required!")
								.setStatusCode(STATUS.BAD_REQUEST)
								.setStatusText(MESSAGES.BAD_REQUEST);
				}

				// try {
				// 	if (isJSON(request._body)) {
				// 		structAppend( rc, deserializeJSON(request._body), true );
				// 	} else if( isJSON( event.getHTTPContent() ) ){
				// 		structAppend( rc, event.getHTTPContent( json=true ), true );
				// 	}
				// } catch(Any e) {
				// 	throw(message="Invalid JSON Format!", errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
				// }

			}

		/* Do not check authentication for the authenticate handler */
		if (findNoCase("Echo", event.getCurrentEvent()) == 0 && 
			findNoCase("Authenticate", event.getCurrentEvent()) == 0 && 
			findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {

			event.paramValue("token", "");

			if(getSetting("environment") == "development" && 
				(rc.token EQ "TOKEN" || !len(rc.token)) && isdefined('url.debug')) {
				session.id_evento   = 1;
				rc.contraints.token = "";
				rc.token            = authService.grantToken(session.id_evento);
			}	

			/* Extract the token from the authorization header */
			if (!len(rc.token) && structKeyExists(getHTTPRequestData().headers, "authorization")) {
				rc.token = listLast(getHTTPRequestData().headers.authorization," ");
			}

			if (authService.validateToken(rc.token)) {
				/* Validate token and store token data in prc scope */
				prc.token = authService.decodeToken(rc.token);
			} else {
				// sessionInvalidate();
				throw(message="The access token is not valid!", errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
			}
		}
	}
	
	/**
	 * Valida session del cliente, buscando por ID session.
	 */
	private void function validateSession(event, rc, prc) {
		if (findNoCase("authenticate", event.getCurrentEvent()) == 0 &&
			findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {

			if(NOT StructKeyExists(session, 'id_evento')) {
				if(structkeyexists(session, 'token')) {
					if(structkeyexists(session.token, 'isvalid')) {
						if (StructKeyExists(session, 'usersession') AND StructKeyExists(session.usersession, 'auth')) {
							session.id_evento = session.usersession.auth.id_evento;  
						} else {
							throw("Has not been found a client authenticated");
						}         
					}
				}
			}
		}
	}

	/**
	 * Validate user http actions by HTTP methods
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	private void function validateActions(event, rc, prc) {
		
		if(structKeyExists(session, 'usersession')) {
			try {
				if (structKeyExists(session.usersession, 'auth')) {
					var usr  = {};
					var temp = {};
					
					if(session.usersession.type EQ 'cliente'){
						usr = wirebox.getInstance("ClientesToken");
					} else {
						usr = wirebox.getInstance("EventosToken");
					}

					var temp = DeserializeJSON(decrypt(session.usersession.auth, "WTq8zYcZfaWVvMncigHqwQ==", "AES", "Base64"));
					
					var id       = temp.id_permisosToken;
					var permisos = usr.permisosById(id);
					var error    = false;

					switch (event.getHTTPMethod()) {
						case "GET":
							if(permisos.getLectura() != 1) {
								error = true;
							}						
							break;
						case "POST":
							if(permisos.getEscritura() != 1) {
								error = true;
							}						
							break;
						case "PUT":
							break;
						case "DELETE":
							if(permisos.getBorrado() != 1) {
								error = true;
							}						
							break;
						case "OPTIONS":
							break;
						default:								
					}

					if(error) {
						throw(message="Action not allowed [#event.getHTTPMethod()#]", errorcode=STATUS.NOT_AUTHORIZED, detail=MESSAGES.NOT_AUTHORIZED);
					}
				}
			} catch(Any e){
				rethrow();
			}
		}
	}
}