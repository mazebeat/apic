/**
* Intercepts Client Session
*/
component extend {
    
    property name="authService" inject="model:security.AuthenticationService";

    void function configure() {}

    void function preProcess(event, rc, prc, interceptData, buffer) {
        if (reFindNoCase("(authenticate|Echo|apic-v1:home|Dashboard)", event.getCurrentEvent()) > 0) {
            continue;
        }

        if(!StructKeyExists(arguments.rc, 'token') OR !authservice.validateToken(arguments.rc.token)) {
            prc.response = getModel("Response");
            prc.response.setError(true)
                        .addMessage(getResource(resource="validation.invalidToken"))                        
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
        }       
    }

    function postProcess(event, rc, prc, interceptData, buffer) {  }
}