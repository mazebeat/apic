/**
* Intercepts Client Session
*/
component extend {
    
    // Properties
    property name="authService" inject="model:security.AuthenticationService";

    void function preProcess( event, rc, prc, interceptData, buffer ) {
        if (findNoCase("authenticate", event.getCurrentEvent()) == 0 &&
            findNoCase("Echo", event.getCurrentEvent()) == 0 && 
            findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {
            if(getSetting("environment") == "development" && isdefined('url.debug')) {
                session.clientSession = { 
                    clientPassword= { type= "cliente", id=1, token= rc.token }
                };
                session.id_evento = 1;
            }

			if(NOT StructKeyExists(session, 'id_evento')) {
				if(structkeyexists(session, 'token')) {
					if(structkeyexists(session.token, 'isvalid')) {
						if (StructKeyExists(session, 'clientsession') AND StructKeyExists(session.clientsession, 'auth')) {
							session.id_evento = session.clientsession.auth.id_evento;  
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
    }

    function postProcess(event, rc, prc, interceptData, buffer ) {
    }
}