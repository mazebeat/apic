/**
* Intercepts Client Session
*/
component extend {
    
    property name="authService" inject="model:security.AuthenticationService";

    void function configure() {}

    void function preProcess( event, rc, prc, interceptData, buffer ) {
        if (findNoCase("authenticate", event.getCurrentEvent()) == 1 ||
            findNoCase("Echo", event.getCurrentEvent()) == 1 || 
            findNoCase("apic-v1:home.doc", event.getCurrentEvent()) == 1  || 
            findNoCase("apic-v1:home.index", event.getCurrentEvent()) == 1) {
            continue;
        }
          
        if(!StructKeyExists(arguments.rc, 'token') OR !authservice.validateToken(arguments.rc.token)) {
            prc.response = getModel("Response");
            prc.response.setError(true)
                        .addMessage("No authenticated client found")
                        .setStatusCode(401)
                        .setStatusText("Invalid or Missing Credentials");
                
            event.renderData(
                type		= prc.response.getFormat(),
                data 		= prc.response.getDataPacket(reset=true),
                contentType = prc.response.getContentType(),
                statusCode 	= prc.response.getStatusCode(),
                statusText 	= prc.response.getStatusText(),
                location 	= prc.response.getLocation(),
                isBinary 	= prc.response.getBinary()
            );
        } else {
            arguments.id_evento = authService.obtainIdEventoByToke(arguments.rc.token);
        }
    }

    function postProcess(event, rc, prc, interceptData, buffer ) {  }
}