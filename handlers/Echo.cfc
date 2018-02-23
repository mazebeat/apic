/**
 * My RESTFul Event Handler
 */
component extends="Base"{
	// Properties	
	// property name="dsn" inject="coldbox:datasource:sigo_dsn";
	property name="srv" inject="model:security.EventosTokenService";
	property name="dao" inject="model:security.ClientesTokenDAO";
	 
	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only      = "";
	this.prehandler_except    = "";
	this.posthandler_only     = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";		

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {
		"index"   = METHODS.GET
		// "savelog" = METHODS.POST
	};
	
	/**
	 * Index
	 * Vista principal retorna mensaje de bienvenida
	 */
	any function index(event, rc, prc) {
		prc.response.addMessage("Bienvenido a tufabricadeventos.com API RESTFul");						
	}

	// any function savelog(event, rc, prc) {
	// 	// myfile = FileRead("/logs/android.log");
	// 	// try {
	// 	if(structKeyExist(rc, 'data')) {
	// 		logBox.getLogger("myLog").info(rc.data);
	// 	} else {
	// 		log.info(rc)
	// 	}

	// 	// } catch (any err) {}
	// }

	any function test(event, rc, prc) {
		
	}
}