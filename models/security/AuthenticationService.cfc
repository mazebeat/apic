/**
 * AuthenticationService
	*/
	component accessors="true" extends="models.BaseModel" {
	
	// Dependency Injection
	property name="jwt" 				type="any" 			inject="jwt";
	property name="tokenExpiration" 	type="numeric" 		inject="coldbox:setting:accessTokenExpiration";
	property name="secretKey" 			type="string" 		inject="coldbox:setting:secretKey";
	property name="secretWord" 			type="string"		inject="coldbox:setting:secretWord";
    property name="clienteTokenService" type="any" 			inject="model:security.ClientesTokenService";
	property name="eventosTokenService" type="any" 			inject="model:security.EventosTokenService";
	
	
	/**
	 * Constructor
	 */
	AuthenticationService function init() {
		return this;
	}
	
	/**
	 * Validate user by username and password
	 * @password 
	 */
	any function validate(required string password) {

		var data   = this.passwordToStruct(arguments.password);
		var result = {};

		if(data.id != 0 && data.type IS 'C') {
			result = clienteTokenService.validate(data.id, arguments.password);
		} else if(data.id != 0 && data.type EQ 'E'){
			result = eventosTokenService.validate(data.id, arguments.password);
		} else {
			throw(message="Password Error");
		}

		return result;
	}

	/**
	 * Generate APIc access token
	 * @userId 
	 */
	string function grantToken(required string id, string type = "C", required string idsEventos) {
		var token   = "";
		var payload = {
			"iss"       = application.urlbase,
			"exp"       = dateAdd("n", variables.getTokenExpiration(), now()),
			"sub"       = arguments.id,
			"id_evento" = arguments.idsEventos,
			"type"      = arguments.type
		};

		try {
			/* Encode the data structure as a json web token */
			token = jwt.encode(payload, "HS512");

		} catch(any e) {}
		
		if(arguments.type EQ "C") {
			clienteTokenService.updateToken(arguments.id, token);
		} else if(type EQ "E"){
			eventosTokenService.updateToken(arguments.id, token);
		} 

		return token;
	}

	/**
	 * Check if user token is valid and still available (ontime)
	 * @accessToken user token
	 */	
	boolean function validateToken(required string accessToken) {
		var validToken = false;
		var data       = {};
	
		try {
			data = jwt.decode(arguments.accessToken);		
			validToken = true;
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		if (structCount(data) GT 0) {
			if (now() > data.exp) {
				validToken = false;
			}
		}	
		
		return validToken;
	}

	/**
	 * Decode token 
	 * @accessToken user token
	 */
	struct function decodeToken(required string accessToken) {		
		return jwt.decode(arguments.accessToken);
	}

	/** 
	 * Desencriptar contraseña
	 * @password
	 */	
	string function decryptPassword(required string password) {
		return decrypt(arguments.password, variables.getSecretKey(), 'AES', 'Base64');
	}

	/** 
	 * Encriptar contraseña 
	 * @password
	 */		
	string function encryptPassword(required string password) {
		return encrypt(arguments.password, variables.getSecretKey(), 'AES', 'Base64'); 
	}	

	/**
	 * Crear contraseña para entregar cliente o evento y puedan solictar un API token
	 * @id 
	 * @isEvento 
	 */
	private string function createPassword(required number id, boolean isEvento = false) {
		var password = (arguments.isEvento) ? "E_" : "C_";

		password &= arguments.id & "_" & variables.getSecretWord() & "_" & randRange(1, 256, "SHA1PRNG");
		finalPassword =  this.encryptPassword(password);

		return finalPassword;
	}

	/**
	 * generatePassword
	 *
	 * @id 
	 * @isEvento 
	 */
	string function generatePassword(required number id, boolean isEvento = false) {
		var password = this.createPassword(arguments.id, arguments.isEvento);
		(!arguments.isEvento) ? clienteTokenService.updatePassword(arguments.id, password) : eventosTokenService.updatePassword(arguments.id, password);
		
		return password;
	}

	/**
	 * obtainPassword
	 *
	 * @password 
	 */
	any function obtainPassword(required number id, boolean isEvento = false) {
		var password = {};

		try {
			password = (arguments.isEvento) ? eventosTokenService.getPassword(arguments.id) : clienteTokenService.getPassword(arguments.id);
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		return password;
	}

	private struct function passwordToStruct(required string password) {
		var temp = [];
		var result = {
			type   = "C",
			id     = 0,
			secret = ""
		};

		try {
			temp = ListToArray(decryptPassword(arguments.password), "_");

			//!! Add validation of number of elements that "temp" array contains
			result.type   = temp[1];
			result.id     = temp[2];
			result.secret = temp[3];
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);
			}
		}

		if(NOT result.secret EQ variables.getSecretWord()) {
			throw(message="Password doesn't match");
		}

		return result;
	}

	private any function authByToken(required string token, required numeric id, required string type) {
		var auth = new Query();

		switch(arguments.type) {
			case "C":
				auth = clienteTokenService.byToken(arguments.id, arguments.token);
				break; 
			case "E":
				auth= eventosTokenService.byToken(arguments.id, arguments.token);
				break; 
		}
		
		return auth;
	}

	any function activateDesactivate(required number id, required boolean isevent) {
		var rsp = {};

		try {
			if(arguments.isevent) {
				rsp = eventosTokenService.activateDesactivate(arguments.id);
			} else {
				rsp = clienteTokenService.activateDesactivate(arguments.id);
			}
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		return rsp;
	}

	any function obtainIdEventoByToken(required string token) {
		var validToken = false;
		var data       = {};
	
		try {
			data = jwt.decode(arguments.token);	
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		return data.id_evento;
	}
} 