/**
 * ApiStartupService
*/
component accessors="true" extends="models.BaseModel" {
	
	// Dependency Injection
		
	
	/**
	 * Constructor
	 */
	ApiStartupService function init() {
		return this;
	}
	
	
	/**
	 * Check Atuhentication Token
	 */
	private any function checkAuthenticationToken(event, rc, prc) {
		/* Only accept application/json for content body on posts */
		if (reFindNoCase("(#METHODS.POST#|#METHODS.PUT#)", arguments.event.getHTTPMethod()) > 0 AND NOT arguments.prc.response.getError()) {
			if (findNoCase("application/json", arguments.event.getHTTPHeader("Content-Type")) == 0) {
				throw(message="Content-Type application/json is required", errorcode=STATUS.BAD_REQUEST);
			}
		}

		/* Extract the token from the authorization header */
		if (!len(arguments.rc.token) && structKeyExists(getHTTPRequestData().headers, "authorization")) {
			arguments.rc.token = listLast(getHTTPRequestData().headers.authorization, " ");
		}

		if (authService.validateToken(arguments.rc.token)) {
			/* Validate token and store token data in prc scope */
			arguments.prc.token = authService.decodeToken(arguments.rc.token);
		} else {
			throw(message=getResource(resource="validation.invalidToken"), errorcode=STATUS.BAD_REQUEST, detail=MESSAGES.BAD_REQUEST);
		}
	}
	
	/**
	 * Valida session del cliente, buscando por ID session.
	 */
	private void function validateSession(event, rc, prc) {
		if(NOT StructKeyExists(arguments.rc, 'id_evento') OR isEmpty(arguments.rc.id_evento)) {
			if(structkeyexists(arguments.rc, 'token')) arguments.rc.id_evento = authService.obtainIdEventoByToken(arguments.rc.token);
			if (isEmpty(arguments.rc.id_evento)) throw(message=MESSAGES.NOT_AUTHENTICATED, errorCode=STATUS.NOT_AUTHENTICATED);         
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
		var error = false;

		if (structKeyExists(arguments.rc, 'token')) {
			try {
				var data     = authService.decodeToken(arguments.rc.token);
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
				throw(message="Validation HTTTP action has failed", detail=e);
			}
		} else {
			error = true;
		}

		if(error) {
			throw(message=MESSAGES.NOT_AUTHORIZED, errorcode=STATUS.NOT_AUTHORIZED, detail="#MESSAGES.NOT_AUTHORIZED#: Action not allowed [#event.getHTTPMethod()#]");
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
			if(!isempty(errorcode)) keys = StructFindValue(STATUS, arguments.errorcode, "one"); 			
			for(msgs in keys) {
				return MESSAGES[msgs.key];
			}
		} catch(Any e) {
			log.error("Error: #e.message#", e);
			sendError(e, rc, event);
		}

		return MESSAGES.INTERNAL_ERROR;
	}

	private boolean	function isPrivatePages(event) {
		var private = true;
		
		if(reFindNoCase("(#arrayToList(PUBLIC_PAGES, "|")#)", arguments.event.getCurrentEvent()) > 0) {
			private = false;
		}

		return private;
	}

	private void function isClientToken(required event, required rc, prc) {
		var tokenData = authService.decodeToken(arguments.rc.token);

		if(reFindNoCase("(#METHODS.GET#|#METHODS.OPTIONS#)", arguments.event.getHTTPMethod()) == 0 
			&& structKeyExists(tokenData, "type") 
			&& tokenData.type == "C"
			&& listLen(arguments.rc.id_evento) > 1) {
			throw(message=getResource(resource='validation.idEventoIndexNotFound'), errorcode=STATUS.PARAMETERS_ERROR);
		}
	}
} 