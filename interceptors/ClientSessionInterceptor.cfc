/**
* Intercepts Client Session
*/
component extend {
    
    property name="authService" inject="model:security.AuthenticationService";

    void function preProcess( event, rc, prc, interceptData, buffer ) {
        if (findNoCase("authenticate", event.getCurrentEvent()) == 1 ||
            findNoCase("Echo", event.getCurrentEvent()) == 1 || 
            findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 1) {
            continue;
        }

        if(!StructKeyExists(session, 'id_evento')) {
            prc.response = getModel("Response");
            prc.response.setError(true)
                        .addMessage("No authenticated client found")
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

        // if (findNoCase("authenticate", event.getCurrentEvent()) == 0 &&
        //     findNoCase("Echo", event.getCurrentEvent()) == 0 && 
        //     findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 0) {
           
		// 	if(NOT StructKeyExists(session, 'id_evento') AND structkeyexists(session, 'token')) {
        //         if(structkeyexists(session.token, 'isvalid')) {
        //             if (StructKeyExists(session, 'usersession') AND
        //                 StructKeyExists(session.usersession, 'auth')) {
        //                 session["id_evento"] = session.usersession.auth.id_evento;  
        //             } else {
        //                 prc.response = getModel("Response").setError(true)
        //                                                 .addMessage("Has not been found a client authenticated")
        //                                                 .setStatusCode(500)
        //                                                 .setStatusText("General application error");
                            
        //                 event.renderData(
        //                     type		= prc.response.getFormat(),
        //                     data 		= prc.response.getDataPacket(reset=true),
        //                     contentType = prc.response.getContentType(),
        //                     statusCode 	= prc.response.getStatusCode(),
        //                     statusText 	= prc.response.getStatusText(),
        //                     location 	= prc.response.getLocation(),
        //                     isBinary 	= prc.response.getBinary()
        //                 );
        //             }         
        //         }
        //     }
        // }
    }

    // function postProcess(event, rc, prc, interceptData, buffer ) {  }
}