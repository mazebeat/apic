/**
 * Base
 */
component extends="BaseHandler" {

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";
	this.allowedMethods = {};


    function init() {
        super.init();
        return this;
	}    
	

}
