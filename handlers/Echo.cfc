/**
 * My RESTFul Event Handler
 */
component extends="Base"{
	// Properties	
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
		"index" = METHODS.GET,
		"test" = METHODS.GET
	};
	
	/**
	 * Index
	 * Vista principal retorna mensaje de bienvenida
	 */
	any function index(event, rc, prc) {
		prc.response.addMessage("Bienvenido a tufabricadeventos.com API RESTFul");						
	}
}