/**
 * Authenticate
 */
component extends="Base" {

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	  = "";
	this.prehandler_except 	  = "";
	this.posthandler_only 	  = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";		

	// REST Allowed HTTP Methods Ex: this.allowedMethods = 
	this.allowedMethods = {
		"index"               = METHODS.POST & "," & METHODS.OPTIONS,
		"generatePassword"    = METHODS.POST & "," & METHODS.OPTIONS,
		"obtainPassword"      = METHODS.POST & "," & METHODS.OPTIONS,
		"activateDesactivate" = METHODS.POST & "," & METHODS.OPTIONS
	};

	/**
	 * Get an API access token \ Obtener API token de acceso
	 *
	 * Headers: Content-Type: application/json
	 * Method: POST
	 * Data: JSON
	 	{
	 		"password": "coldbox" 
	 	}
	 * @rc.password Contraseña asignada al usuario
	 *
	 * @returnType model:Response
	 */
	any function index(event, rc, prc) {

		event.paramValue("password", "");

		try {
			var jsonData = event.getHTTPContent(json=true);

			if(isStruct(jsonData) && !structIsEmpty(jsonData)) {
				
				if(jsonData.keyExists('password')) {
					rc.password = jsonData.password;

					// Development Enviroment
					if(getSetting("environment") == "development" && isdefined('url.debug')) {
						var token = authservice.grantToken(1);
						session.clientSession = { 
							clientPassword= { type= "cliente", id= 1, token= token },
							auth          = authservice.validate(rc.password)
						};
						session.id_evento = '= 1';
						prc.response.addMessage("enviroment = #getSetting("environment")#");
	
						// return;
					}
					// END Development Enviroment

					var authuser = authservice.validate(rc.password);

					if (!isNull(authuser)) {

						var token = authuser.token;

						if(structkeyexists(authuser, 'id_cliente')) {
							id    = authuser.getId_cliente();
							type  = "cliente";
						} elseif(structkeyexists(authuser, 'id_evento')) {
							id    = authuser.getId_evento();
							type  = "evento";
						} 

						if(!authservice.validateToken(token)) {
							if(type EQ 'cliente') {
								token = authservice.grantToken(authuser.getId_cliente(), "c");
							} elseif(type EQ 'evento') {
								token = authservice.grantToken(authuser.getId_evento(), "e");
							} else {
								prc.response.setError(true)
									.addMessage("Client validation failed!")
									.setStatusCode(STATUS.NOT_AUTHENTICATED)
									.setStatusText(MESSAGES.NOT_AUTHENTICATED);
							}
						}
					
						session.clientsession = { 
							clientPassword= { type= type, id= id, token= token },
							auth          = authuser
						};
						session.id_evento = authuser.getId_evento();

						rc.token = token;
						prc.response.setData({"token" = token});
					} else {
						prc.response.setError(true)
									.addMessage("Client validation failed!")
									.setStatusCode(STATUS.NOT_AUTHENTICATED)
									.setStatusText(MESSAGES.NOT_AUTHENTICATED);
					}
				} else {
					prc.response.setError(true)
								.addMessage("Parameters username or password incorrect/empty")
								.setStatusCode(STATUS.NOT_AUTHENTICATED)
								.setStatusText(MESSAGES.NOT_AUTHENTICATED);
				}
			} else {
				prc.response.setError(true)
							.addMessage("Parameters are empty")
							.setStatusCode(STATUS.NOT_AUTHENTICATED)
							.setStatusText(MESSAGES.NOT_AUTHENTICATED);
			}
		} catch(Any e) {
			prc.response
				.setError(true)
				.addMessage("General application error: #e.message#")
				.setStatusCode(STATUS.NOT_AUTHENTICATED)
				.setStatusText(MESSAGES.NOT_AUTHENTICATED);			
			
			// Development additions
			if(getSetting("environment") eq "development") {
				// TODO: Modificar el modo de mostrar errores en desarrollo.		
				prc.response.addMessage("Detail: #e.detail#")
							.addMessage("StackTrace: #e.stacktrace#");
			}
		}
	}

	/**
	 * Genera una nueva contraseña para entregar al cliente. Esta contraseña sirve para identificar al usuario.
	 * 
	 * @rc.id ID de Cliente o Evento que se requiera generar
	 * @rc.password Contraseña o secretWord para validar que es alguien de Tufabricadeventos.com quien está generandolo.
	 * @rc.isevent Boolean \ Optional: Default false
	 *
	 * @returnType model:Response
	 */
	any function generatePassword( event, rc, prc ) {
		jsonData = event.getHTTPContent( json=true );
		isevent = false;

		if(isStruct(jsonData) && !structIsEmpty(jsonData)) {
			if(NOT jsonData.keyExists('password') && (NOT jsonData.password EQ authservice.secretWord)) {
				prc.response.setError(true)
						.addMessage("Parameters password incorrect/empty")
						.setStatusCode(STATUS.BAD_REQUEST)
						.setStatusText(MESSAGES.BAD_REQUEST);
				return;
			} 

			if(NOT jsonData.keyExists('id')) {
				prc.response.setError(true)
		 					.addMessage("Parameters ID incorrect/empty")
		 					.setStatusCode(STATUS.BAD_REQUEST)
		 					.setStatusText(MESSAGES.BAD_REQUEST);
				return;
			}

			id = jsonData.id;

			if(jsonData.keyExists('isevent')) {
				isevent  = jsonData.isevent;
			}

			// try {
				rsp = authservice.generatePassword(id, isevent);

				prc.response.setData({ 
					"id"       = id, 
					"password" = rsp
				});
			// } catch(any e) {
			// 	prc.response.setData({ 
			// 		"id"       = id, 
			// 		"password" = 'No existe contraseña, por favor generar.'
			// 	});
			// 	prc.response.setError(true)
			// 					.addMessage("Error when was trying to generate password")
			// 					.setStatusCode(STATUS.BAD_REQUEST)
			// 					.setStatusText(MESSAGES.BAD_REQUEST);
							
			// 	if(getSetting("environment") eq "development") {
			// 		prc.response.addMessage(e.message);
			// 	}
			// }
		} else {
			prc.response.setError(true)
								.addMessage("JSON POST Data incorrect")
								.setStatusCode(STATUS.BAD_REQUEST)
								.setStatusText(MESSAGES.BAD_REQUEST);
		}
	}

	/**
	 * Obtener una nueva contraseña para entregar al cliente. Esta contraseña sirve para identificar al usuario.
	 * 
	 * @rc.id ID de Cliente o Evento que se requiera generar
	 * @rc.password Contraseña o secretWord para validar que es alguien de Tufabricadeventos.com quien está generandolo.
	 * @rc.isevent Boolean \ Optional: Default false
	 *
	 * @returnType model:Response
	 */
	any function obtainPassword( event, rc, prc ) {
		jsonData = event.getHTTPContent( json=true );
		isevent = false;

		if(isStruct(jsonData) && !structIsEmpty(jsonData)) {
			if(NOT jsonData.keyExists('password') && (NOT jsonData.password EQ authservice.secretWord)) {
				prc.response.setError(true)
						.addMessage("Parameters password incorrect/empty")
						.setStatusCode(STATUS.BAD_REQUEST)
						.setStatusText(MESSAGES.BAD_REQUEST);
				return;
			} 

			if(NOT jsonData.keyExists('id')) {
				prc.response.setError(true)
		 					.addMessage("Parameters ID incorrect/empty")
		 					.setStatusCode(STATUS.BAD_REQUEST)
		 					.setStatusText(MESSAGES.BAD_REQUEST);
				return;
			}

			id = jsonData.id;

			if(jsonData.keyExists('isevent')) {
				isevent  = jsonData.isevent;
			}

			try {
				rsp = authservice.obtainPassword(id, isevent);

				if(isEmpty(rsp.password)) {
					prc.response.addMessage("El cliente no tiene contraseña asiganada.");
				}
				prc.response.setData({ 
					"id"         = id, 
					"password"   = rsp.password,
					"fecha_baja" = (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja
				});				
			} catch(any e) {
				prc.response.setError(true)
								.addMessage("Error when was trying to get password")
								.setStatusCode(STATUS.BAD_REQUEST)
								.setStatusText(MESSAGES.BAD_REQUEST);
							
				if(getSetting("environment") eq "development") {
					prc.response.addMessage(e.message);
				}
			}
		} else {
			prc.response.setError(true)
								.addMessage("JSON POST Data incorrect")
								.setStatusCode(STATUS.BAD_REQUEST)
								.setStatusText(MESSAGES.BAD_REQUEST);
		}
	}

	/**
	 * ActivateDesactivate Tal cual como dice su nombre, activa o desactiva un objeto ApiClienteToken|ApiEventoToken según su estado.
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	any function activateDesactivate( event, rc, prc ) {
		jsonData = event.getHTTPContent( json=true );
		isevent = false;

		var rsp = authservice.activateDesactivate(jsonData.id, jsonData.isevent);

		prc.response.setData({ 
			"id"         = jsonData.id,
			"fecha_baja" = (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja
		})
		.addMessage('Fecha baja actualizada');
	}

	/**
	 * CreateSessionEvent Crea variable de sesión para gestionar más de un idevento por cliente.
	 *
	 * @authuser ApiClienteToken|ApiEventoToken
	 */
	private any function createSessionEvento(required any authuser) {
		
	}
}