/**
 * Base
 */
component extends="BaseHandler"{
	
	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";
	
    // REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};
    /*
	function postHandler(event, rc, prc, action, eventarguments ){
	}
	function aroundHandler( event, rc, prc, targetAction, eventarguments ){
		// executed targeted action
		arguments.targetAction( event );
	}
	function onMissingAction( event, rc, prc, missingAction, eventarguments ){
	}
	function onError( event, rc, prc, faultAction, exception, eventarguments ){
	}
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventarguments ){
	}
	*/

    function init() {
        super.init();
        return this;
    }
	
    /**
     * Función para quitar toda barra baja de una palabra y reemplazarla por un espacio, además de transformarla en minuscula.
     * @str paralbra requerida
     */
    string function clearArgumentWhiteSpace(required string str) {
        return trim(lCase(replaceNoCase(arguments.str, "-", " ")));
    }    

    /**
     * Convierte string bajo CamelCase en una palabra con espacios en blanco
     * @str
     */
    string function camelCaseToSpace(required string str) {
        var rtnStr = reReplace(arguments.str,"([A-Z])([a-z])"," \1\2","ALL");
        
        if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
            rtnStr = reReplace(arguments.str,"([a-z])([A-Z])","\1 \2","ALL");
            rtnStr = uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
        }

        return trim(rtnStr);
    }

    /**
     * Convierte un string con formato snake_case en camelCase
     * @str 
     */
    string function snakeCaseToCamelCase(required string str) {
        if (len(arguments.str)) {
            var camel_case = reReplace(arguments.str, "_([a-zA-Z])", "\u\1", "all");
            var upper_camel_case = reReplace(camel_case, "\b([a-zA-Z]+)", "\u\1", "all");

            return upper_camel_case;
        }
        return null;       
    }

    /**
     * Convierte una palabra en Spinal Case.
     */
    string function toSpinalCase(required string str) {
    }

    /**
     * Obtiene la dirección IP del cliente.
     */
    public string function getClientIp() {
        local.response = "";

        try {
            try {
                local.headers = getHttpRequestData().headers;
                if (structKeyExists(local.headers, "X-Forwarded-For") && len(local.headers["X-Forwarded-For"]) > 0) {
                    local.response = trim(listFirst(local.headers["X-Forwarded-For"]));
                }
            } catch (any e) {}

            if (len(local.response) == 0) {
                if (structKeyExists(cgi, "remote_addr") && len(cgi.remote_addr) > 0) {
                    local.response = cgi.remote_addr;
                } else if (structKeyExists(cgi, "remote_host") && len(cgi.remote_host) > 0) {
                    local.response = cgi.remote_host;
                }
            }
        } catch (any e) {
            cfthrow(message = e.Message);
        }

        return local.response;
    }

    public any function QueryToStruct(required query Query, numeric Row = 0) {
        include template="/includes/helpers/QuerysHelper.cfm";
        return QueryToStruct(arguments.Query, arguments.Row);
    }

     public any function QueryToStruct2(required query Query, string index = '', numeric Row = 0) {
         include template="/includes/helpers/QuerysHelper.cfm";
         return QueryToStruct2(arguments.Query, arguments.index, arguments.Row);
    }
}
