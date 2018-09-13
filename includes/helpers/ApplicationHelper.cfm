<cffunction name="paginationToString">
    <cfargument name="rc" required="true">

    <cfset var pages = "">

    <cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
        <cfset pages =  arguments.rc.page & " of " & arguments.rc.total/arguments.rc.rows>
    </cfif>
    
    <cfreturn pages>
</cffunction>

<cffunction name="cleanIPUser" access="public">
    <cfif (RandRange(1, 10) EQ 5)>
        <!--- 
        -- DELETE FROM apic_currentUser
        -- WHERE last_attempt < (<cfqueryparam value="#DateAdd( 'n', -2, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />) 
        --->
        <cfquery name="local.qIPCheck" datasource="#application.datasource#">
            UPDATE apic_currentUser
            SET active = 0
            WHERE last_attempt < (<cfqueryparam value="#DateAdd('n', -1, NOW())#" cfsqltype="CF_SQL_TIMESTAMP">)
        </cfquery>
    </cfif>
</cffunction>

<cffunction name="checkIPUser" access="public">
    <!--- <cfquery name="local.qIPCheck" datasource="#application.datasource#">
        SELECT
            COUNT(*) AS user_request_count
        FROM apic_currentUser
        WHERE last_attempt >= <cfqueryparam value="#DateAdd( 'n', -5, NOW())#" cfsqltype="CF_SQL_TIMESTAMP" />
        AND ip_address = <cfqueryparam value="#cgi.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />
        AND user_token = <cfqueryparam value="#session.cfid#-#session.cftoken#" cfsqltype="CF_SQL_VARCHAR" />
        GROUP BY user_token
        ORDER BY last_attempt DESC
        LIMIT 1;
    </cfquery> --->

    <cfif structKeyExists(session, 'cfid')>
        <cfquery name="local.qIPCheck" datasource="#application.datasource#">
            SELECT user_request_count
            FROM apic_currentUser
            WHERE last_attempt >= <cfqueryparam value="#DateAdd( 'n', -5, NOW())#" cfsqltype="CF_SQL_TIMESTAMP" />
            AND ip_address = <cfqueryparam value="#cgi.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />
            AND user_token = <cfqueryparam value="#session.cfid#-#session.cftoken#" cfsqltype="CF_SQL_VARCHAR" />
            ORDER BY user_request_count DESC
            LIMIT 1;
        </cfquery>

        <cfreturn local.qIPCheck>
    </cfif>

</cffunction>

<cffunction name="addIPUser" access="public">
    <cfargument name="event">
    <cfargument name="rc">
    <cfargument name="prc">

    <cfparam name="arguments.rc.token" default="">

    <cfif structKeyExists(session, 'cfid')>
        <cfquery name="local.qIPCheck" datasource="#application.datasource#">
            INSERT INTO apic_currentUser
            (
                ip_address,
                user_request_count,
                user_token,
                last_attempt,
                last_event,
                http_user_agent,
                token,
                created_at
            )
            VALUES  
            (
                <cfqueryparam value="#cgi.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].attempts#" cfsqltype="CF_SQL_INTEGER" />,
                <cfqueryparam value="#session.cfid#-#session.cftoken#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />,
                <cfqueryparam value="#arguments.event.getCurrentEvent()#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#cgi.HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#arguments.rc.token#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_TIMESTAMP" />
            )
            ON DUPLICATE KEY 
            UPDATE 
            user_request_count = <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].attempts#" cfsqltype="CF_SQL_INTEGER" />,
            last_attempt = <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />
        </cfquery>    
    </cfif>
</cffunction>



<!--- 
    Convert any date/time in ISO 8601 format to Coldfusion date/time
 --->
<cffunction name="ISOToDateTime" access="public" returntype="string" output="false" hint="Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.">
    <cfargument name="Date" type="string" required="true" hint="ISO 8601 date/time stamp."/>
    
    <cfreturn arguments.Date.ReplaceFirst("^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$", "$1-$2-$3 $4") />
</cffunction>

<!--- 
    Envia un contenido hacia las direcciones de correo indicadas
 --->
<cffunction name="enviarElError" access="public">
	<cfargument name="to" required="false" default="diego@tufabricadeventos.com;jramon.paz@tufabricadeventos.com">
    <!--- <cfargument name="to" required="false" default="errores@tufabricadeventos.com; diego@tufabricadeventos.com"> --->
    <cfargument name="from" required="false" default="errores@tufabricadeventos.com">
	<cfargument name="subject" required="true">
    <cfargument name="contenidoEmail" required="true">
    
	<cfquery name="local.qServidorEnviarError" datasource="sige">
		SELECT server, username, password
		FROM servidoresCorreo
		WHERE id_servidor = 4
		<!--- 
		id_servidor = 1 = EEUU
		id_servidor = 4 = EUROPA
		--->
    </cfquery>
    
	<cfmail server      = "#local.qServidorEnviarError.server#"
            username    = "#local.qServidorEnviarError.username#"
            password    = "#local.qServidorEnviarError.password#"
            to          = "#arguments.to#"
            from        = "#arguments.from#"
            subject     = "#arguments.subject#"
            spoolenable = "false"
            type        = "html">
        #arguments.contenidoEmail#
	</cfmail>
</cffunction>

<cffunction name="sendError" access="public">
    <cfargument name="exception" type="any" required="true">
    <cfargument name="rc" required="true">
    <cfargument name="event" required="true">

    <cfscript>        
        savecontent variable="errortext" {
            var oException = new coldbox.system.web.context.ExceptionBean( arguments.exception );

            var requestBody = isJSON(request._body) ? deserializeJSON(request._body, false) : {};
            var EventValues = isJson(event.getHTTPContent()) ? deserializeJson(event.getHTTPContent(), true) : event.getHTTPContent();
            var HeadersValues = GetHttpRequestData();	
                    
            include template="/views/bugreport.cfm";
        }

        enviarElError("subject" = "API ERROR #getSetting("environment")# #arguments.rc.event#", "contenidoEmail" = errortext);
    </cfscript>
</cffunction>

<cfscript>
    void function limiterByTime(required event, required rc, required prc, required numeric maxRequest, required numeric waitTimeRequest) {
        param name="arguments.rc.token" default="";
    
        <!--- var userRequest = checkIPUser(); --->
        cleanIPUser();
    
        if (structKeyExists(url, "killsession")) {
            application.rate_limiter = {};
            StructDelete(application, 'rate_limiter');
        }
    
        if ((NOT IsDefined("application.rate_limiter") OR structIsEmpty(application.rate_limiter)) OR (NOT structKeyExists(application.rate_limiter, cgi.remote_addr))) {
            if (NOT structKeyExists(application, "rate_limiter")) {
                application.rate_limiter = StructNew();
            }
            application.rate_limiter[cgi.remote_addr]              = StructNew();
            application.rate_limiter[cgi.remote_addr].attempts     = 1;
            application.rate_limiter[cgi.remote_addr].last_attempt = NOW();
        } else {
            if (NOT cgi.HTTP_COOKIE IS "") {
                if (StructKeyExists(application.rate_limiter, cgi.remote_addr)) {
                    if (DateDiff("s", application.rate_limiter[cgi.remote_addr].last_attempt, NOW()) LT arguments.waitTimeRequest) {
                        if (application.rate_limiter[cgi.remote_addr].attempts GTE arguments.maxRequest) {
                            logBox.getLogger("fileLogger").info("Limiter invoked for: '#cgi.remote_addr#', #application.rate_limiter[cgi.remote_addr].attempts#, #cgi.request_method#, '#cgi.SCRIPT_NAME#', '#cgi.QUERY_STRING#', '#cgi.http_user_agent#', '#application.rate_limiter[cgi.remote_addr].last_attempt#', #listlen(cgi.http_cookie,";")#, #arguments.rc.token#");
                            
                            arguments.prc.response.addHeader("Retry-After", arguments.waitTimeRequest)
                                                .setError(true)
                                                .addMessage("You are making too many requests too fast, please slow down and wait #arguments.waitTimeRequest# seconds (#cgi.remote_addr#)")
                                                .setStatusText("Service Unavailable")
                                                .setStatusCode(503);
                        }
                    
                        application.rate_limiter[cgi.remote_addr].attempts     = application.rate_limiter[cgi.remote_addr].attempts + 1;
                        application.rate_limiter[cgi.remote_addr].last_attempt = NOW();
                    } else {
                        application.rate_limiter[cgi.remote_addr]              = StructNew();
                        application.rate_limiter[cgi.remote_addr].attempts     = 1;
                        application.rate_limiter[cgi.remote_addr].last_attempt = NOW();
                    }
                }
            }
        }
    
        addIPUser(arguments.event, arguments.rc, arguments.prc);
    }
    
    /**
     * Convert any Coldfusion date/time to ISO 8601 format
     */
    string function getIsoTimeString(required date datetime, boolean convertToUTC=true){
  
        if (convertToUTC) datetime = dateConvert("local2utc", datetime );
        return(dateFormat( datetime, "yyyy-mm-dd" ) & "T" & timeFormat( datetime, "HH:mm:ss" ) & "Z");
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
    string function getClientIp() {
        var response = "";

        try {
            try {
                local.headers = getHttpRequestData().headers;
                if (structKeyExists(local.headers, "X-Forwarded-For") && len(local.headers["X-Forwarded-For"]) > 0) {
                    response = trim(listFirst(local.headers["X-Forwarded-For"]));
                }
            } catch (any e) {}

            if (len(response) == 0) {
                if (structKeyExists(cgi, "remote_addr") && len(cgi.remote_addr) > 0) {
                    response = cgi.remote_addr;
                } else if (structKeyExists(cgi, "remote_host") && len(cgi.remote_host) > 0) {
                    response = cgi.remote_host;
                }
            }
        } catch (any e) {
            cfthrow(message = e.Message);
        }

        return response;
    }

    /**
     * Convert query to struct
     *  
     * @Query 
     * @Row 
     */
    any function QueryToStruct(required query Query, numeric Row = 0) {
        include template="/includes/helpers/QuerysHelper.cfm";
        return QueryToStruct(arguments.Query, arguments.Row);
    }

    /**
     * Convert query to struct version 2
     *
     * @Query 
     * @index 
     * @Row 
     */
    any function QueryToStruct2(required query Query, string index = '', numeric Row = 0) {
         include template="/includes/helpers/QuerysHelper.cfm";
         return QueryToStruct2(arguments.Query, arguments.index, arguments.Row);
    }
    
    /**
     * Combines structFindKey() and structFindValue()
     * v1.0 by Adam Cameron
     * v1.01 by Adam Cameron (fixing logic error in scope-handling)
     * 
     * @param struct      Struct to check (Required)
     * @param key      Key to find (Required)
     * @param value      Value to find for key (Required)
     * @param scope      Whether to find ONE (default) or ALL matches (Optional)
     * @return Returns an array as per structFindValue() 
     * @author Adam Cameron (dac.cfml@gmail.com) 
     * @version 1.01, September 9, 2013 
     */
    public array function structFindKeyWithValue(required struct struct, required string key, required string value, string scope="ONE"){
        if (!isValid("regex", arguments.scope, "(?i)one|all")){
            throw(type="InvalidArgumentException", message="Search scope #arguments.scope# must be ""one"" or ""all"".");
        }
        var keyResult = structFindKey(struct, key, "all");
        var valueResult = [];
        for (var i=1; i <= arrayLen(keyResult); i++){
            if (keyResult[i].value == value){
                arrayAppend(valueResult, keyResult[i]);
                if (scope == "one"){
                    break;
                }
            }
        }
        return valueResult;
    }

    variables.reTags 					= '<[^>]*(>|$)';
	variables.reWhitelist 				= '(?x) <\/?(b(lockquote)?|code|d(d|t|l|el)|em|h(1|2|3)|i|kbd|ul|li|ol|p(re)?|s(ub|up|trong|trike|tyle)?|(t(able|r|d|body|footer|head) ?)\s?\/?)?\s?\/?>|<(b|h)r\s?\/?>';
	variables.reWhitelistLinks 			= '(?x) ^<a\s href="(\##\d+|(https?|ftp)://[-a-z0-9+&@##/%?=~_|!:,.;\(\)]+)" (\stitle="[^"<>]+")?\s?>$ | ^</a';
	variables.reWhitelistImages 		= '(?x) <\/?img.*(\ssrc="https?:\/\/[-a-z0-9+&@##/%?=~_|!:,.;\(\)]+\").*(\stitle=\"[^"<>]*\")?.*(\salt="[^"<>]*")?.*(\swidth="\d{1,4}")?.*(\sheight="\d{1,4}")?\/?>';	
	variables.reBlackJavascriptArray 	= [
		'(\/\*.*\*\/)',
		'(\t)',
		'(.*(script\b).*>.*<.*(script\b).*)',
		'(javascript\s*:)',
		'(\b)(on\S+)(\s*)=|javascript|vbscript|(<\s*)(\/*)script',
		'(@import)',
		'(style=[^<]*((expression\s*?\([^<]*?\))|(behavior\s*:)|(eval\s*:))[^<]*(?=\>))',
		'(ondblclick|onclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onload|onunload|onerror)=[^<]*(?=\>)',
		'<\/?(script|meta|link|frame|iframe)>',
		'src=[^<]*base64[^<]*(?=\>)',
	];
	
	/**
	 * Find all the cases by regex expression
	 * @regex (required|string)
	 * @text (required|string)
	 * @return string
	 */ 
	private array function findAll(required string regex, required string text) {
		var L = structNew();
		L.result = [];
		L.offset = 1;      
		while (true) {
			L.match = reFind(arguments.regex, arguments.text, L.offset, true);
			
			if (L.match.len[1] GT 0) {
				L.details = { text = Mid(arguments.text, L.match.pos[1], L.match.len[1]), index = L.match.pos[1], length = L.match.len[1] };
				arrayAppend(L.result, L.details);
				L.offset = L.details.index + L.details.length;
			} else {
				break;
			}
		}
		return L.result;
	}

	/**
	 * Remplaza valor según reglas regex
	 * @value (required|string)
	 * @regexp (required|array)
	 * @replaceBy (required|string)
	 * @return any
	 */
	private any function filterArrayRegex(required string value, required array regexp, required string replaceBy) {
		for(re in arguments.regexp) {
			arguments.value = reReplaceNoCase(trim(arguments.value), re, arguments.replaceBy, 'all');
		}
		return (arguments.value);
	}

	/**
	 * Sanatize
	 * Sanatize a text from XSS an others injections attack
	 * Importante: No utilizar para sanitizar elementos que vayan en la WEB, ya que valida si se utilizan IFRAMES como SCRIPT
	 * @text (required|string)
	 * @return
	 */ 
	private string function sanatizeHtml(required string html) {
		var L = structNew();

		try {
			L.result = arguments.html;
			
			// Canonalize
			L.result = isdefined('application.esapi') ? application.esapi.encoder().canonicalize(L.result, false, false) : canonicalize(L.result, false, false);
			
			// WhiteLists
			if(len(arguments.html) GT 0) {
				L.tags = findAll(variables.reTags, L.result);				
				variables.reWhitelist = '';
				cfloop(from='#ArrayLen(L.tags)#' to='1', index='L.i', step='-1') {
					L.tagname  = lcase(L.tags[L.i].text);
					L.allowTag = reFind(variables.reWhitelist, L.tagname) GT 0 OR reFind(variables.reWhitelistLinks, L.tagname) GT 0 OR reFind(variables.reWhitelistImages, L.tagname) GT 0;
					if(!L.allowTag) {
						L.result = removeChars(L.result, L.tags[L.i].index, L.tags[L.i].length); 
					}
				}
			} 

			// XSS Javavascript
			L.result = filterArrayRegex(L.result, variables.reBlackJavascriptArray, "<invalidTag>");
		} catch (any ex) {
			if(isDebugMode()) {
				writeDump(var="#L#", label="Object");
				writeDump(var="#ex#", label="Exception");
				abort;
			}
		}

		return L.result;
	}

	/**
	 * Sanatize Scope
	 * @scope (required|struct)
	 * @return void
	 */
	private void function sanitizeScope(required struct scope ) {
		try {
			for( var key in scope ) {			
				if(isStruct(scope[key])) sanitizeScope(scope[key]);			
				if(isSimpleValue(scope[key])) scope[key] = sanatize(scope[key]);
			}
		} catch (any ex) { 
			if(isDebugMode()) {
				writeDump(var="#ex#", label="Exception");
				abort;
			}
		}	
	}

	/**
	 * Sanatize
	 * Sanatize a text from XSS an others injections attack
	 * Importante: No utilizar para sanitizar elementos que vayan en la WEB, ya que valida si se utilizan IFRAMES como SCRIPT
	 * @text (required|string)
	 * @return
	 */ 
	public string function sanatize(required string html) {
		try{
			return sanatizeHtml(arguments.html);
		} catch (any ex) { 
			if(isDebugMode()) {
				writeDump(var="#ex#", label="Exception");
				abort;
			}
		}	
	}

	/**
	 * Sanatize Dump
	 * Performs a sanitized dump, where JavaScript has been removed to minimize XSS risks
	 * @data (required|any)
	 * @return any 
	 */
	public struct function sanatizeDump(required struct data) {
		try{
			sanitizeScope(arguments.data);
		} catch (any ex) { 
			if(isDebugMode()) {
				writeDump(var="#ex#", label="Exception");
				abort;
			}
		}	

		return arguments.data;	
	}	


</cfscript>