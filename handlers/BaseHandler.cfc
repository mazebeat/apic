component extends="coldbox.system.EventHandler" {

	// Inject AuthenticationService
	property name="authService" type="any" 	inject="model:security.AuthenticationService";
	property name="i18n" 		type="any"	inject="i18n@cbi18n"; 
	
	// Pseudo "constants" used in API Response/Method parsing
	property name="METHODS";
	property name="STATUS";
	property name="MESSAGES";
	property name="PUBLIC_PAGES";

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
	STATUS = {
		"CONTINUE"               = 100,
		"CHECKPONT"              = 103,
		"SUCCESS"                = 200,
		"CREATED"                = 201,
		"ACCEPTED"               = 202,
		"NO_CONTENT"             = 204,
		"RESET_CONTENT"          = 205,
		"PARTIAL_CONTENT"        = 206,
		"MULTI_STATUS"           = 207,
		"ALREADY_REPORTED"       = 208,
		"NOT_MODIFIED"           = 304, 
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
		"RESET_CONTENT"          = "Reset Content",
		"PARTIAL_CONTENT"        = "Partial content",
		"MULTI_STATUS"           = "Multi status",
		"ALREADY_REPORTED"       = "Already reported",
		"NOT_MODIFIED"           = "Not Modified",
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
	};

	// Public pages list - Those pages are allow to access without an API Token
	PUBLIC_PAGES = [
		"Echo", 
		"Authenticate", 
		"apic-v1:home",
		"Dashboard",		
	];

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

	BaseHandler function init() {
		super.init(application.cbController);
        return this;
	}

	function preHandler(event, rc, prc, targetAction, eventArguments) {
		param name="rc.id_evento" default="" type="string";

		try {
			// prepare our response object
			prc.response = getModel("Response");
			prc.i18n = variables.i18n;

			// Check if body request is JSON type
			try {
				if (isJSON(request._body)) {
					structAppend(rc, deserializeJSON(request._body), true);
				} else if( isJSON(event.getHTTPContent())) {
					structAppend(rc, event.getHTTPContent(json=true), true);
				}
			} catch(Any e) {
				throw(message=getResource(resource='validation.invalidJSONFormat'), errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
			}
		} catch(Any e) {
			log.error("[PREHANDLER] ERROR CALLING #event.getCurrentEvent()#: #e.message# #e.detail#", e);			
			sendError(e, rc, event);

			if(isdefined('url.show')) {
				writeDump(e);
			}
		}
	}
	
	/**
	* Around handler for all actions it inherits
	*/
	function aroundHandler(event, rc, prc, targetAction, eventArguments) {
		try{
			if(application.maintenanceMode) {
				throw(message=getResource(resource='api.maintenanceMode'), errorcode=STATUS.SERVICE_UNAVAILABLE);
			}

			var stime = getTickCount();

			// prepare our response object
			prc.response = getModel("Response");
			prc.i18n = variables.i18n;
			
			// Sanatize all variables
			rc = sanatizeDump(rc);

			// prepare argument execution
			var args = { event = event, rc = rc, prc = prc };

			structAppend(args, eventArguments);

			// Incoming Format Detection
			if(structKeyExists(rc, "format")) prc.response.setFormat(rc.format);

			// While evento does not be one of these pages
			if (isPrivatePages(event)) {
				// Check APIc Token
				this.checkAuthenticationToken(event, rc, prc);			
				// Validat user actions
				this.validateActions(event, rc, prc);
				// Check if user has a valid session (token)
				this.validateSession(event, rc, prc);
				// Check an unique ID_EVENTO when type of API Token is client type
				this.isClientToken(event, rc, prc);
				// Check request per seconds by user
				limiterByTime(event, rc, prc, getSetting('maxUserRequest'), getSetting('waitTimeRequest'));
			}		

			// Execute action
			if (!prc.response.getError()) var actionResults = targetAction(argumentCollection=args); 
		} catch(Any e){	
			// Log Locally
			log.error("[AROUNDHANDLER] ERROR CALLING #event.getCurrentEvent()#: #e.message# #e.detail#", e);			

			// Send email error
			sendError(e, rc, event);			

			// Setup General Error Response
			var code = empty(e.errorcode) ? STATUS.INTERNAL_ERROR: e.errorcode;
			var msg  = findStatusMessage(code);
		
			prc.response
				.setError(true)
				.addMessage(e.message)
				.setStatusCode(code)
				.setStatusText(msg);

			if((getSetting("environment") eq "development") ) { 
				prc.response.addMessage("Detail: #e.detail#").addMessage("StackTrace: #e.stacktrace#");
			}

			if(isdefined('url.show')) {
				writeDump(e);
			}
		}

		// Development additions
		if(getSetting("environment") eq "development"){
			prc.response.addHeader("x-current-route", event.getCurrentRoute())
				.addHeader("x-current-routed-url", event.getCurrentRoutedURL())
				.addHeader("x-current-routed-namespace", event.getCurrentRoutedNamespace())
				.addHeader("x-current-event", event.getCurrentEvent());
		}

		// End timer
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
			if(structKeyExists(prc, 'token')) writeDump(var="#prc.token#", label="API Token");
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
		param name="faultAction" default="";
	
		// Log Locally
		log.error("Error in base handler (#faultAction#): #exception.message# #exception.detail#", exception);
		
		// Verify response exists, else create one
		if(!structKeyExists(prc, "response")){ 
			prc.response = getModel("Response"); 
		}

		// Setup General Error Response
		var code = empty(exception.errorcode) ? STATUS.INTERNAL_ERROR: exception.errorcode;
		var msg = findStatusMessage(code);
	
		prc.response
			.setError(true)
			.addMessage(exception.message)
			.setStatusCode(code)
			.setStatusText(msg);
		
		// Development additions
		if(getSetting("environment") eq "development"){
			prc.response.addMessage("Detail: #exception.detail#").addMessage("StackTrace: #exception.stacktrace#");
		}

		// Send error mail
		sendError(exception, rc, event);

		if(isdefined("url.debug")) {
			writeDump(var="#exception#", label="event OnError");
			abort;
		}
		
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
		param name="faultAction" default="";

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
	function onMissingAction(event, rc, prc, missingAction, eventArguments) {
		param name="missingAction" default="";

		// Log Locally
		log.warn("Invalid HTTP Method Execution of (#missingAction#): #event.getHTTPMethod()#", getHTTPRequestData());
		
		// Setup Response
		prc.response = getModel("Response")
			.setError(true)
			.addMessage("Action '#missingAction#' could not be found")
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

	/**************************** RESTFUL UTILITIES ************************/

	/**
	* Utility function for miscellaneous 404's
	**/
	private function routeNotFound(event, rc, prc){
		if(!structKeyExists(prc, "response")) {
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
	private function onExpectationFailed(event=getRequestContext(), rc=getRequestCollection(), prc=getRequestCollection(private=true)) {
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
	private function onAuthenticationFailure(event=getRequestContext(), rc=getRequestCollection(), prc=getRequestCollection(private=true), abort=false) {
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
	private function onAuthorizationFailure(event=getRequestContext(), rc=getRequestCollection(), prc=getRequestCollection(private=true), abort=false){
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

	/**************************** PRIVATE METHODS ************************/

	/**
	 * 1.- Check Atuhentication Token
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	private any function checkAuthenticationToken(event, rc, prc) {
		/* Only accept application/json for content body on posts */
		if (reFindNoCase("(#METHODS.POST#|#METHODS.PUT#)", event.getHTTPMethod()) > 0 AND NOT prc.response.getError()) {
			if (findNoCase("application/json", event.getHTTPHeader("Content-Type")) == 0) {
				throw(message="Content-Type application/json is required", errorcode=STATUS.BAD_REQUEST);
			}
		}

		/* Extract the token from the authorization header */
		if (!len(rc.token) && structKeyExists(getHTTPRequestData().headers, "authorization")) {
			rc.token = listLast(getHTTPRequestData().headers.authorization, " ");
		}

		if (authService.validateToken(rc.token)) {
			/* Validate token and store token data in prc scope */
			prc.token = authService.decodeToken(rc.token);
		} else {
			throw(message=getResource(resource="validation.invalidToken"), errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
		}
	}

	/**
	 * 2.- Validate user http actions by HTTP methods
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	private void function validateActions(event, rc, prc) {
		var error = false;

		if (structKeyExists(rc, 'token')) {
			try {
				var data     = authService.decodeToken(rc.token);
				var usr      = (data.type IS 'C') ? wirebox.getInstance("ClientesToken") : wirebox.getInstance("EventosToken");
				var permisos = usr.permisosById(data.sub);

				switch (event.getHTTPMethod()) {
					case METHODS.GET:
						error = (permisos.getLectura() != 1) ? true : false;
						break;
					case METHODS.POST:
						error = (permisos.getEscritura() != 1) ? true : false;
						break;
					case METHODS.PUT:
						break;
					case METHODS.DELETE:
						error = (permisos.getLegetBorradoctura() != 1) ? true : false;
						break;
					case METHODS.OPTIONS:
						break;
					default:								
				}
			} catch (Any e) {
				throw(message="Validation HTTP action has failed", detail=e);
			}
		} else {
			error = true;
		}

		if(error) {
			throw(message=MESSAGES.NOT_AUTHORIZED, errorcode=STATUS.NOT_AUTHORIZED, detail="#MESSAGES.NOT_AUTHORIZED#: Action not allowed [#event.getHTTPMethod()#]");
		}
	}

	/**
	 * 3.- Valida session del cliente, buscando por ID session.
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	private void function validateSession(event, rc, prc) {
		/**
		 * Valida si existe ID_EVENTO en los parametros recibidos
		 * - Si no existe, obtiene los IDs desde el API Token enviado
		 */ 
		if(NOT structKeyExists(rc, 'id_evento') OR isEmpty(rc.id_evento)) {
			// Valida si existe token
			// if(structkeyexists(rc, 'token')) { 
			// 	rc.id_evento = javacast("string", authService.obtainIdEventoByToken(rc.token));
			// }
			rc.id_evento = prc.token.id_evento;

			// Mensaje erro si id_evento es vacio
			if (isEmpty(rc.id_evento)) {
				throw(message=MESSAGES.NOT_ALLOWED, errorCode=STATUS.NOT_ALLOWED);
			}
		} 
	}

	/**
	 * 4.- Check if a API Token type of client type is been using
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	private void function isClientToken(required event, required rc, required prc) {
		// var tokenData = authService.decodeToken(rc.token);
		if(reFindNoCase("(#METHODS.GET#|#METHODS.OPTIONS#)", event.getHTTPMethod()) == 0) {
			if(structKeyExists(prc.token, "type") && prc.token.type == "C" && listLen(rc.id_evento) > 1) {
				throw(message=getResource(resource='validation.idEventoIndexNotFound'), errorcode=STATUS.PARAMETERS_ERROR);
			} 
			
			// Obtiene todos los IDS evento del token clie
			var idsEvento = javacast("string", authService.obtainIdEventoByToken(rc.token));
			rc.id_evento = javacast("string", rc.id_evento);
			
			if(listFind(idsEvento, rc.id_evento) == 0) {
				throw(message=getResource(resource="validation.invalidIdEvento"), errorCode=STATUS.NOT_ALLOWED, detail=MESSAGES.NOT_ALLOWED);         
			}
		}
	}

	/**
	 * Retorna mensaje según código de error
	 *
	 * @errorcode 
	 */
	private string function findStatusMessage(errorcode) {
		var keys = [];

		try {
			if(!isempty(errorcode)) keys = StructFindValue(STATUS, errorcode, "one"); 			
			for(msgs in keys) {
				return MESSAGES[msgs.key];
			}
		} catch(Any e) {
			log.error("Error: #e.message#", e);
			sendError(e, rc, event);
		}

		return MESSAGES.INTERNAL_ERROR;
	}

	/**
	 * Check if the page/event required special validations
	 *
	 * @event 
	 */
	private boolean	function isPrivatePages(event) {
		var isPrivated = true;
		
		if(reFindNoCase("(#arrayToList(PUBLIC_PAGES, "|")#)", event.getCurrentEvent()) > 0) {
			isPrivated = false;
		}

		return isPrivated;
	}
}