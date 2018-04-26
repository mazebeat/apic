/**
 * Authenticate
 */
component extends="Base" {

	property name="prmToken" 		type="any"	inject="model:security.PermisosTokenService";
	property name="cService" 		type="any"	inject="model:security.ClientesTokenService";
	property name="eService" 		type="any"	inject="model:security.EventosTokenService";
	property name="authSecretKey"  	type="any"	inject="coldbox:setting:authSecretKey";


	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	  = "";
	this.prehandler_except 	  = "";
	this.posthandler_only 	  = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";		

	// REST Allowed HTTP Methods Ex: this.allowedMethods = 
	this.allowedMethods = {
		"index"               = METHODS.POST,
		"generatePassword"    = METHODS.POST,
		"obtainPassword"      = METHODS.POST,
		"activateDesactivate" = METHODS.POST,
		"permissionsUser"     = METHODS.POST,
		"savePermissionsUser" = METHODS.POST,
		"tokenInformation"    = METHODS.POST
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
			if(structKeyExists(rc, "password")) {
				var authuser = authservice.validate(rc.password);

				if (!isNull(authuser)) {
					var token = authuser.token;
					var id = '';
					var type = '';

					if(structkeyexists(authuser, 'id_cliente')) {
						id    = authuser.getId_cliente();
						type  = "cliente";
					} else if(structkeyexists(authuser, 'id_evento')) {
						id    = authuser.getId_evento();
						type  = "evento";
					} 

					if(isdefined('token') && !authservice.validateToken(token)) {
						if(type EQ 'cliente') {
							token = authservice.grantToken(authuser.getId_cliente(), "c");
						} else if(type EQ 'evento') {
							token = authservice.grantToken(authuser.getId_evento(), "e");
						} else {
							throw(message="Error: We truly sorry but client validation has failed", errorcode=STATUS.NOT_AUTHENTICATED);
						}
					}

					if(isNull(token)) {
						throw(message="Error: Password or Token does not exists", errorcode=STATUS.NOT_AUTHENTICATED);					
					}

					aut = encrypt(serializeJSON(authuser), getSetting('authSecretKey'), "AES", "Base64");
					
					session["usersession"] = { 
						"type"     = type, 
						"auth"     = aut,
						"defaults" = {
								"form" = {
									"fields" = ""
							}
						}
					};
				
					session["id_evento"] = authuser.getId_evento();
						
					rc.token = token;
					var data = {"token" = token};
					
					if(type == "cliente") {
						structInsert(data, 'eventos', '');
					}
					prc.response.setData(data);
				} else {
					throw(message="Error: Client validation has failed", errorcode=STATUS.NOT_AUTHENTICATED);
				}
			} else {
				throw(message="Error: Parameters are empty", errorcode=STATUS.NOT_AUTHENTICATED);
			}
		} catch(Any e) {
			throw(message="Error: Generating token", errorcode=e.errorcode, detail=e);
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
	any function generatePassword(event, rc, prc) {
		var jsonData = event.getHTTPContent( json=true );
		var isevent = false;

		if(NOT structKeyExists(rc, 'password') && (NOT rc.password EQ getSetting('secretWord'))) {
			throw(message="Parameters password incorrect/empty", errorcode=STATUS.BAD_REQUEST);
		} 

		if(NOT structkeyExists(rc, 'id')) {
			throw(message="Parameters ID incorrect/empty", errorcode=STATUS.BAD_REQUEST);
			return;
		}

		var id = rc.id;

		if(structkeyExists(rc, 'isevent')) {
			isevent  = rc.isevent;
		}

		try {
			rsp = authservice.generatePassword(id, isevent);

			prc.response.setData({ 
				"id"       = id, 
				"password" = rsp
			});
		} catch(any e) {
			prc.response.setData({ 
				"id"       = id, 
				"password" = 'No existe contraseña, por favor generar.'
			});
			prc.response.setError(true)
							.addMessage("Error when was trying to generate password")
							.setStatusCode(STATUS.BAD_REQUEST)
							.setStatusText(MESSAGES.BAD_REQUEST);
						
			
			if(getSetting("environment") eq "development") {
				prc.response.addMessage(e.message);
			}
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
	any function obtainPassword(event, rc, prc) {

		var isevent = false;
	
		if(NOT structkeyExists(rc, 'password') && (NOT rc.password EQ getSetting('secretWord'))) {
			throw(message="Parameters password incorrect/empty", errorcode=STATUS.BAD_REQUEST)
		} 

		if(NOT structkeyExists(rc, 'id')) {
			throw(message="Parameters ID incorrect/empty", errorcode=STATUS.BAD_REQUEST)
		}

		var id = rc.id;

		if (structkeyExists(rc, 'isevent')) {
			isevent  = rc.isevent;
		}

		try {
			rsp = authservice.obtainPassword(id, isevent);

			if(isEmpty(rsp.password)) {
				var message = "Client does not have an assigned password";
				// if(session.language IS 'ES') {
				// 	message = "El cliente no tiene contraseña asiganada.";
				// }
				prc.response.addMessage(message).setError(true);
			}
			prc.response.setData({ 
				"id"         = id, 
				"password"   = rsp.password,
				"fecha_baja" = (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja
			});				
		} catch(any e) {
			throw(message="Error when was trying to get password", errorcode=STATUS.BAD_REQUEST, detail=e)
		}
	}

	/**
	 * ActivateDesactivate Tal cual como dice su nombre, activa o desactiva un objeto ApiClienteToken|ApiEventoToken según su estado.
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	any function activateDesactivate(event, rc, prc) {
		var jsonData = event.getHTTPContent( json=true );
		var isevent = false;

		var rsp = authservice.activateDesactivate(rc.id, rc.isevent);

		try {
			prc.response.setData({ 
				"id"         = rc.id,
				"fecha_baja" = (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja
			})
			.addMessage('Date of low updated');
		} catch (Any e) { 
			throw(message="Activate/Deactivate failed", detail=e);
		}
	}

	/**
	 * CreateSessionEvent Crea variable de sesión para gestionar más de un idevento por cliente.
	 *
	 * @authuser ApiClienteToken|ApiEventoToken
	 */
	private any function createSessionEvento(required any authuser) {
	}

	/**
	 * PermissionsUser Obtiene todos los permisos asoociados a ese Objeto ClientesToken | EventosToken
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	any function permissionsUser(event, rc, prc) {
		if(!rc.isevent){
			var usr = cService.get(rc.id);
		} else {
			var usr = eService.get(rc.id);
		}

		if(isnull(usr.getId_permisosToken())) {
			throw(message = "Error: Empty object, please generate password first.", errorcode = 500);
		}

		var permisos = usr.permisos();
		
		prc.response.setData({ 
			"lectura"    = permisos.lectura,
			"escritura"  = permisos.escritura,
			"borrado"    = permisos.borrado
		});
	}

	/**
	 * SavePermissionsUser Actualiza cambios en los permisos previamente creados cuando se genera una password de API
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	any function savePermissionsUser(event, rc, prc) {
		if(!rc.isevent){
			var usr = cService.get(rc.id);
		} else {
			var usr = eService.get(rc.id);
		}

		if(arrayLen(rc.permissions) < 3) {
			throw(message = "Error: Permissions count incorrect.", errorcode = 500);
		}

		if(isnull(usr.getId_permisosToken())) {
			throw(message = "Error: Empty object, please generate password first.", errorcode = 500);
		}
			
		var permisos = usr.permisos();

		for (i = 1; i <= arrayLen(rc.permissions); i++) {
			var value = rc.permissions[i];

			if(i == 1) {
				permisos.setLectura(value);
			} else if(i == 2) {
				permisos.setEscritura(value);
			} else if(i == 3) {
				permisos.setBorrado(value);
			}
		}
		
		try {
			permisos.updateModel();
			prc.response.addMessage("User permissions changed");
		} catch(Any e) {
			throw(message="Error when were saving user permissions", errorcode=e.errorcode, detail=e);
		}
	}

	any function tokenInformation(event, rc, prc) {		
		try {
			if(isdefined('url.tfe') && url.tfe == getSetting('secretWord')) {
				prc.response.setData(authservice.decodeToken(arguments.rc.token));	
			}
		} catch(Any e) {
			throw(message="Error getting token information", errorcode=e.errorcode, detail=e);
		}
	}
}	