/**
 * Authenticate
 */
component extends="Base" {

	property name="cliService" 	type="any"	inject="model:security.ClientesTokenService";
	property name="eService" 	type="any"	inject="model:security.EventosTokenService";
	property name="prmToken" 	type="any"	inject="model:security.PermisosTokenService";

	this.prehandler_only 	  = "";
	this.prehandler_except 	  = "";
	this.posthandler_only 	  = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";

	// REST Allowed HTTP Methods 
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
		try {
			if(structKeyExists(arguments.rc, "password") AND !isEmpty(arguments.rc.password)) {
				var authuser = authservice.validate(arguments.rc.password);
					
				if (!isNull(authuser) AND !isNull(authuser.getId())) {
					var type  = findNoCase("ClientesToken", getMetadata(authuser).name) GT 0 ? 'C' : 'E';
					var token = isEmpty(authuser.token) ? "" : authuser.token;
					
					if(isdefined("authuser.token") && isNull(token) OR isEmpty(token) || !authservice.validateToken(token)) {
						var idsEvento = (isEmpty(authuser.getId_evento()) && type IS 'C') ? authuser.getEvents() : authuser.getId_evento();
						token = authservice.grantToken(authuser.getId(), type, idsEvento);
					}
					
					if(isNull(token) OR isEmpty(token)) {
						throw(message="API Key or API Token does not exists", errorcode=STATUS.NOT_AUTHENTICATED);					
					}
					
					arguments.prc.response.setData({ "token" = token });

					// var aut = encrypt(serializeJSON(authuser), getSetting('authSecretKey'), "AES", "Base64");
					// session["usersession"] = { 
					// 	"type"     = type, 
					// 	"auth"     = aut,
					// 	"defaults" = { "form" = { "fields" = "" } }
					// };
					// arguments.rc.token = token;
				} else {
					throw(message="Client validation has failed");
				}
			} else {
				throw(message="Parameters are empty");
			}
		} catch(Any e) {
			throw(message=e.message, errorcode=STATUS.NOT_AUTHENTICATED);
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
		if(NOT structKeyExists(arguments.rc, 'password') && (NOT arguments.rc.password EQ getSetting('secretWord'))) {
			throw(message="Parameters password incorrect/empty", errorcode=STATUS.BAD_REQUEST);
		} 
		
		if(NOT structkeyExists(arguments.rc, 'id')) {
			throw(message="Parameters ID incorrect/empty", errorcode=STATUS.BAD_REQUEST);
			return;
		}
		
		var isevent = false;
		var id = arguments.rc.id;

		if(structkeyExists(rc, 'isevent')) isevent = arguments.rc.isevent;

		try {
			rsp = authservice.generatePassword(id, isevent);
			arguments.prc.response.setData({ "id" = id, "password" = rsp });
		} catch(any e) {
			arguments.prc.response.setData({ "id" = id, "password" = 'No existe contraseña, por favor generar.' })
				.setError(true)
				.setStatusCode(STATUS.BAD_REQUEST)
				.setStatusText(MESSAGES.BAD_REQUEST)
				.addMessage("Error when was trying to generate password");
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
		if(NOT structkeyExists(arguments.rc, 'password') && (NOT arguments.rc.password EQ getSetting('secretWord'))) {
			throw(message="Parameters password incorrect/empty", errorcode=STATUS.BAD_REQUEST)
		} 
		
		if(NOT structkeyExists(arguments.rc, 'id')) {
			throw(message="Parameters ID incorrect/empty", errorcode=STATUS.BAD_REQUEST)
		}
		
		var isevent = false;
		var id      = arguments.rc.id;

		if (structkeyExists(rc, 'isevent'))	isevent  = arguments.rc.isevent;

		try {
			rsp = authservice.obtainPassword(id, isevent);

			if(isEmpty(rsp.password)) throw(message="Client does not have an assigned password");

			var data = { 
				"id"         = id, 
				"password"   = rsp.password,
			};
			var fb =  (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja;
			if(!isEmpty(fb)) structInsert(data, "fecha_baja", fb);
			arguments.prc.response.setData(data);				
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
		var rsp = authservice.activateDesactivate(arguments.rc.id, arguments.rc.isevent);

		try {
			var data = { "id" =  arguments.rc.id, "actived" = true };
			var fb =  (!isnull(rsp.fecha_baja) && rsp.fecha_baja != '' )? getIsoTimeString(rsp.fecha_baja) : rsp.fecha_baja;
			if(!isEmpty(fb)) {
				structInsert(data, "fecha_baja", fb);
				structInsert(data, "actived", false, true);
			}
			arguments.prc.response.setData(data)
			.addMessage('The date has been updated');
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
		var usr =  (!arguments.rc.isevent) ? cliService.get(arguments.rc.id) : eService.get(arguments.rc.id);

		if(isnull(usr.getId_permisosToken())) {
			throw(message="Empty object, please generate password first.", errorcode=STATUS.INTERNAL_ERROR);
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
		if(!arguments.rc.isevent){
			var usr = cliService.get(arguments.rc.id);
		} else {
			var usr = eService.get(arguments.rc.id);
		}

		if(arrayLen(arguments.rc.permissions) < 3) {
			throw(message = "Permissions count incorrect.", errorcode = 500);
		}

		if(isnull(usr.getId_permisosToken())) {
			throw(message = "Empty object, please generate password first.", errorcode = 500);
		}
			
		var permisos = usr.permisos();

		for (i = 1; i <= arrayLen(arguments.rc.permissions); i++) {
			var value = arguments.rc.permissions[i];

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
			arguments.prc.response.addMessage("User permissions changed");
		} catch(Any e) {
			throw(message="Error when were saving user permissions", errorcode=e.errorcode, detail=e);
		}
	}

	/**
	 * Give token information to
	 *
	 * @event 
	 * @rc 
	 * @prc 
	 */
	any function tokenInformation(event, rc, prc) {		
		try {
			if(isdefined('url.tfe') && url.tfe == getSetting('secretWord')) {
				arguments.prc.response.setData(authservice.decodeToken(arguments.rc.token));
			}
		} catch(Any e) {
			throw(message="Error getting token information", errorcode=e.errorcode, detail=e);
		}
	}
}	