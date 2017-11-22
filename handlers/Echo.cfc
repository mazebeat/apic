/**
 * My RESTFul Event Handler
 */
component extends="Base"{
	// Properties	
	// property name="dsn" inject="coldbox:datasource:sigo_dsn";
	
	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only      = "";
	this.prehandler_except    = "";
	this.posthandler_only     = "";
	this.posthandler_except   = "";
	this.aroundHandler_only   = "";
	this.aroundHandler_except = "";		

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {
		"index" = METHODS.GET
	};
	
	/**
	 * Index
	 * Vista principal retorna mensaje de bienvenida
	 */
	any function index(event, rc, prc) {
		prc.response.addMessage("Bienvenido a tufabricadeventos.com API RESTFul");						
	}
}