<cffunction name="paginationToString">
    <cfargument name="rc" required="true">

    <cfset var pages = "">

    <cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
        <cfset pages =  arguments.rc.page & " of " & arguments.rc.total/arguments.rc.rows>
    </cfif>
    
    <cfreturn pages>
</cffunction>


<cffunction name="limiterByTime" access="public">
    <cfargument name="maxRequest"       type="numeric">
    <cfargument name="waitTimeRequest"  type="numeric">
    <cfargument name="prc">
    <cfargument name="event">

    <!--- <cfset var userRequest = checkIPUser()> --->

    <!--- <cfset cleanIPUser()> --->

    <cfif structKeyExists( url, "killsession" )>
        <cfset  application.rate_limiter = {}>
        <cfset StructDelete(application, 'rate_limiter')>
    </cfif>

    <cfscript>
        // var ip = ["1.1.1","2.2.2","3.3.3"];
        // for (i in ip) {
        //     writeDump(var="#i#", label="var");
        // }
        // writeDump(var="#(NOT IsDefined("application.rate_limiter") OR structIsEmpty(application.rate_limiter)) OR NOT structKeyExists(application.rate_limiter, i)#", label="var");

        // abort;
        // var ip = ListToArray(cgi.REMOTE_ADDR, '.');
        // var ip2 = "";
     
        // for (i = 1; i < arrayLen(ip); i++) {
        //     ip2 &= ip[i] & ".";
        // }
        // ip2 &= (ip[i] + randRange(1, 127, "SHA1PRNG" )) & "";
    </cfscript>

    
    <cfif (NOT IsDefined("application.rate_limiter") OR structIsEmpty(application.rate_limiter)) 
        OR (NOT structKeyExists(application.rate_limiter, cgi.remote_addr))>
        <cfif NOT IsDefined("application.rate_limiter")>
            <cfset application.rate_limiter = StructNew()>
        </cfif>
        <cfset application.rate_limiter[cgi.remote_addr]              = StructNew()>
        <cfset application.rate_limiter[cgi.remote_addr].attempts     = 1>
        <cfset application.rate_limiter[cgi.remote_addr].last_attempt = NOW()>
    <cfelse>        
        <cfif NOT cgi.HTTP_COOKIE IS "">
            <cfif StructKeyExists(application.rate_limiter, cgi.remote_addr)>
               
                <cfif DateDiff("s", application.rate_limiter[cgi.remote_addr].last_attempt, NOW()) LT arguments.waitTimeRequest>
                    <cfif application.rate_limiter[cgi.remote_addr].attempts GTE arguments.maxRequest>                    
                        <cfset logBox.getLogger("fileLogger").info("limiter invoked for: '#cgi.remote_addr#', #application.rate_limiter[cgi.remote_addr].attempts#, #cgi.request_method#, '#cgi.SCRIPT_NAME#', '#cgi.QUERY_STRING#', '#cgi.http_user_agent#', '#application.rate_limiter[cgi.remote_addr].last_attempt#', #listlen(cgi.http_cookie,";")#")>
                        <cfset prc.response.addHeader("Retry-After", arguments.waitTimeRequest)
                                            .setError(true)
                                            .addMessage("You are making too many requests too fast, please slow down and wait #arguments.waitTimeRequest# seconds (#cgi.remote_addr#)")
                                            .setStatusText("Service Unavailable")
                                            .setStatusCode(503)>
                    </cfif>
                    
                    <cfset application.rate_limiter[cgi.remote_addr].attempts     = application.rate_limiter[cgi.remote_addr].attempts + 1>
                    <cfset application.rate_limiter[cgi.remote_addr].last_attempt = NOW()>
                <cfelse>
                    <cfset application.rate_limiter[cgi.remote_addr]              = StructNew()>
                    <cfset application.rate_limiter[cgi.remote_addr].attempts     = 1>
                    <cfset application.rate_limiter[cgi.remote_addr].last_attempt = NOW()>     
                </cfif>       
            </cfif>        
        </cfif>
    </cfif>

    <cfset addIPUser(prc, event)>
</cffunction>

<cffunction name="cleanIPUser" access="public">

    <cfif (RandRange( 1, 10 ) EQ 5)>
        <cfquery name="local.qIPCheck" datasource="#application.datasource#">
            DELETE FROM apic_currentUser
            WHERE last_attempt < <cfqueryparam value="#DateAdd( 'n', -2, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />;
            <!--- 
            UPDATE apic_currentUser
            SET active = 0
            WHERE last_attempt < <cfqueryparam value="#DateAdd( 'n', -1, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />; 
            --->
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
            SELECT 
            user_request_count
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
    <cfargument name="prc">
    <cfargument name="event">

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
                created_at
            )
            VALUES  
            (
                <cfqueryparam value="#cgi.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].attempts#" cfsqltype="CF_SQL_INTEGER" />,
                <cfqueryparam value="#session.cfid#-#session.cftoken#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />,
                <cfqueryparam value="#event.getCurrentEvent()#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#cgi.HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR" />,
                <cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_TIMESTAMP" />
            )
            <!--- 
            ON DUPLICATE KEY 
            UPDATE 
            user_request_count = <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].attempts#" cfsqltype="CF_SQL_INTEGER" />,
            last_attempt = <cfqueryparam value="#application.rate_limiter[cgi.remote_addr].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />
            --->
        </cfquery>    
    </cfif>
</cffunction>

<!--- 
    Convert any Coldfusion date/time to ISO 8601 format
--->
<cffunction name="getIsoTimeString" returntype="string" access="public">
    <cfargument name="datetime" required="true" type="date">
    <cfargument name="convertToUTC" default="true">
  
    <cfscript>
        if (convertToUTC) {
            datetime = dateConvert("local2utc", datetime );
        }
        return(dateFormat( datetime, "yyyy-mm-dd" ) & "T" & timeFormat( datetime, "HH:mm:ss" ) & "Z");
    </cfscript>
</cffunction>

<!--- 
    Convert any date/time in ISO 8601 format to Coldfusion date/time
 --->
<cffunction name="ISOToDateTime" access="public" returntype="string" output="false" hint="Converts an ISO 8601 date/time stamp with optional dashes to a ColdFusion date/time stamp.">
    <cfargument name="Date" type="string" required="true" hint="ISO 8601 date/time stamp."/>
    
    <cfreturn arguments.Date.ReplaceFirst("^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$", "$1-$2-$3 $4") />
</cffunction>

<cffunction name="sendErrorMail" output="false" returntype="void">
	<cfargument name="donde" required="true" default="DESCONOCIDO">
	<cfargument name="contenido" required="true">
    <cfargument name="argumentos" required="false">
    <cfargument name="event" required="false">
    <cfargument name="rc" required="false">
    <cfargument name="prc" required="false">

    <cfoutput>
    <cfinclude template="/default/maquina.cfm">
        <cfoutput>
            <cfsavecontent variable="contenidoEmail">
                    #queMaquina#
                    <br>
                    <table>
                    ID_EVENTO: #session.id_evento#<br>
                    <cfquery name="qNombreEvento" datasource="#application.datasource#" cachedwithin="#createtimespan(1,0,0,0)#">
                        select nombre
                        from vEventos
                        where id_evento = #session.ID_EVENTO#
                    </cfquery>
                    NOMBRE: #qNombreEvento.nombre#<br>

                    <cfdump var="IP REMOTA: #CGI.REMOTE_ADDR#">
                    <cfdump var="ES LOCALHOST: #isLocalHost(CGI.REMOTE_ADDR)#">
                    <cfdump var="LOCALHOST IP: #getLocalHostIP()#">
                    <cfdump var="FECHA Y HORA: #now()#">
                
                    MESSAGE: <cfdump var="#arguments.contenido#"><br>

                    <cfif isdefined("arguments.contenido.StackTrace")>
                        <cfdump var="#arguments.contenido.StackTrace#">
                    </cfif>

                    <cfif isdefined('arguments.argumentos')>
                        ARGUMENTS:<br>
                        <cfdump var="#arguments.argumentos#">
                    </cfif>

                    <cfif isdefined("cgi")>
                    HTTP_HOST: #CGI.HTTP_HOST#<br>
                    HTTP_USER_AGENT: #CGI.HTTP_USER_AGENT#<br>
                    </cfif>

                    <cfif isdefined("url")>
                    URL: <cfdump var="#URL#"><br>
                    </cfif>

                    <cfif isdefined("FORM")>
                    FORM: <cfdump var="#FORM#"><br>
                    </cfif>
                    
                    <cfif isdefined("SESSION")>
                    SESSION: <cfdump var="#SESSION#"><br>
                    </cfif>

                    <cfif isdefined("prc.response")>
                    DATA: <cfdump var="#prc.response.getDataPacket()#"><br>
                    </cfif>

                    <cfset var sURL = {}>

                    <cfif isdefined("form")>
                    <cfloop collection="#form#" item="id">
                        <cfset structInsert(sURL, id, form[id], true)>
                    </cfloop>
                </cfif>

                <cftry>
                    <cfif isdefined("url")>
                        <cfloop collection="#url#" item="id">
                            <cfset structInsert(sURL, id, url[id], true)>
                        </cfloop>
                    </cfif>
                <cfcatch type="any">
                </cfcatch>
                </cftry>
            </cfsavecontent>
        </cfoutput>

        <cftry>
            <cfset contenidoEmail = limitarLongitudLinea(contenidoEmail)>

            <cfset enviarElError(
                argumentCollection: {
                    subject       : "API ERROR SIGE #queMaquina# #arguments.donde#",
                    contenidoEmail: contenidoEmail
                }
            )>

        <cfcatch type="any">

        </cfcatch>
        </cftry>

        </cfoutput>
</cffunction>

<!--- 
    Envia un contenido hacia las direcciones de correo indicadas
 --->
<cffunction name="enviarElError" access="public">
	<cfargument name="to" required="false" default="diego@tufabricadeventos.com">
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
    
	<cfmail
		server      = "#local.qServidorEnviarError.server#"
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

            var requestBody = toString( getHttpRequestData().content );
            requestBody = deserializeJSON(requestBody, false);

            var EventValues = isJson(event.getHTTPContent()) ? deserializeJson(event.getHTTPContent(), true) : event.getHTTPContent();	
            var HeadersValues = GetHttpRequestData();			
           
            include template="/views/bugreport.cfm";
        }

        enviarElError("subject" = "API Error #rc.event#", "contenidoEmail" = errortext);
    </cfscript>
</cffunction>

<cfscript>
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
</cfscript>