/**
* Intercepts Client Session
*/
component extend {
    
    // Properties
    property name="authService" inject="model:security.AuthenticationService";

    void function preProcess( event, rc, prc, interceptData, buffer ) {
        // if(isdefined("url.debug")) {
        //     writeDump(var="#session#", label="session");
        //     abort;
        // }
        
        if (findNoCase("authenticate", event.getCurrentEvent()) == 0 &&
            findNoCase("Echo", event.getCurrentEvent()) == 0 && 
            findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {
           
            if(getSetting("environment") == "development" && isdefined('url.debug')) {
                if(!isdefined("usersession")){
                    var auth = authservice.validate(authservice.generatePassword(1, true));
                    auth = encrypt(serializeJSON(auth), "WTq8zYcZfaWVvMncigHqwQ==", "AES", "Base64");
                    session["usersession"] = { 
                        "type" = "evento",
                        "auth" = auth,
                        "defaults" = {
                            "form" = {
                                "fields" = ""
                            }
                        }
                    };
                }
                session["id_evento"] = 1;
            }

			if(NOT StructKeyExists(session, 'id_evento')) {
				if(structkeyexists(session, 'token')) {
					if(structkeyexists(session.token, 'isvalid')) {
						if (StructKeyExists(session, 'usersession') AND StructKeyExists(session.usersession, 'auth')) {
							session["id_evento"] = session.usersession.auth.id_evento;  
						} else {
                            prc.response = getModel("Response").setError(true)
                                                            .addMessage("Has not been found a client authenticated")
                                                            .setStatusCode(500)
                                                            .setStatusText("General application error");
                                
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
				}
            }
        }

        validateActions(event, rc, prc);
    }

    function postProcess(event, rc, prc, interceptData, buffer ) {}

    /**
     * Validate User Actions
     */
    function validateActions(event, rc, prc) {
        // if(structKeyExists(session, 'usersession')) {
        //     if(structKeyExists(session.usersession, 'auth')) {
        //         if(isdefined("url.debug")) {
        //             writeDump(var="#session#", label="session");
        //             abort;
        //         }
        //     }
        // }
    }
}