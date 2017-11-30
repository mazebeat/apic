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
	
	// Properties
	
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

		var data   = passwordToStruct(password);
		var result = {};

		if(data.id != 0 && data.type EQ "c") {
			result = clienteTokenService.get(data.id);
		} else if(data.id != 0 && data.type EQ "e"){
			result = eventosTokenService.get(data.id);
		} else {
			throw(message="Password Error");
		}

		return result;
	}

	/**
	 * Generate APIc access token
	 * @userId 
	 */
	string function grantToken(required string id, string type = 'c') {

		var token   = "";
		var payload = {
			"iss"  = application.urlbase,
			"exp"  = dateAdd("n", tokenExpiration, now()),
			"sub"  = id,
			"type" = type
		};

		try {
			/* Encode the data structure as a json web token */
			token = jwt.encode(payload, "HS512");
			
			if(type EQ "c") {
				clienteTokenService.updateToken(id, token);
			} else if(type EQ "e"){
				eventosTokenService.updateToken(id, token);
			} 
		} catch(any e) {}

		return token;
	}

	/**
	 * Check if user token is valid and still available (ontime)
	 * @accessToken user token
	 */	
	boolean function validateToken(required string accessToken) {
		
		var validToken = false;
	
		try {
			var data   = jwt.decode(accessToken);		
			validToken = true;

			session.token.data = data;
		} catch(any e) {
			sessionInvalidate();
			
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		if (structKeyExists(local, "data")) {
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
		return jwt.decode(accessToken);
	}

	/** 
	 * Desencriptar contraseña
	 * @password
	 */	
	string function decryptPassword(required string password) {
		return decrypt(password, secretKey, 'AES', 'Base64');
	}

	/** 
	 * Encriptar contraseña 
	 * @password
	 */		
	string function encryptPassword(required string password) {
		return encrypt(password, secretKey, 'AES','Base64'); 
	}	

	/**
	 * Crear contraseña para entregar cliente o evento y puedan solictar un API token
	 * @id 
	 * @isEvento 
	 */
	private string function createPassword(required number id, boolean isEvento = false) {
		var password = "c_";
		
		if(isEvento) {
			password = "e_";
		}

		password &= id & "_" & secretWord & "_" & randRange(1, 256, "SHA1PRNG");

		return encryptPassword(password);
	}

	/**
	 * generatePassword
	 *
	 * @id 
	 * @isEvento 
	 */
	string function generatePassword(required number id, boolean isEvento = false) {
		password = createPassword(id, isEvento);

		if(!isEvento) {
			clienteTokenService.updatePassword(id, password);
		} else {
			eventosTokenService.updatePassword(id, password);
		}

		return password;
	}

	/**
	 * obtainPassword
	 *
	 * @password 
	 */
	any function obtainPassword(required number id, boolean isEvento = false) {
		password = {};

		try {
			if(isEvento) {
				password = eventosTokenService.getPassword(id);
			} else {
				password = clienteTokenService.getPassword(id);
			}
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
			type   = "c",
			id     = 0,
			secret = ""
		};

		try {
			temp = ListToArray(decryptPassword(password), "_");
			
			if(NOT temp.len() GTE 3) {
				throw(message="Wrong password");
			}

			result.type   = temp[1];
			result.id     = temp[2];
			result.secret = temp[3];
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		if(NOT result.secret EQ secretWord) {
			throw(message="Password doesn't match");
		}

		return result;
	}

	private any function authByToken(required string token, required numeric id, required string type) {
		var auth = new Query();

		switch(type) {
			case "c":
				auth = clienteTokenService.byToken(id, token);
				break; 
			case "e":
				auth= eventosTokenService.byToken(id, token);
				break; 
		}
		
		return auth;
	}

	any function activateDesactivate(required number id, required boolean isevent) {
		var rsp = {};

		try {
			if(isevent) {
				rsp = eventosTokenService.activateDesactivate(id);
			} else {
				rsp = clienteTokenService.activateDesactivate(id);
			}
		} catch(any e) {
			if(isdefined('url.debug')) {
				throw(e);	
			}
		}

		return rsp;
	}
} 