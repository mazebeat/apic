/**
* Intercepts with HTTP Basic Authentication
*/
component extend {
	
    property name="queryLimit" type="any" inject="coldbox:setting:queryLimit";

    void function preProcess( event, rc, prc, interceptData, buffer ) {
        if(getSetting("environment") NEQ "development"){
            if(structkeyexists(rc, "rows") AND rc.rows GT queryLimit) {
                rc.rows = queryLimit;
            }
        }   
    }

    function postProcess(event, rc, prc, interceptData, buffer ) {
    }
}