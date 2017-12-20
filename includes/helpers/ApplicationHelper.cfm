<cffunction name="paginationToString">
    <cfargument name="rc" required="true">

    <cfset var pages = "">

    <cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
        <cfset pages =  arguments.rc.page & " of " & arguments.rc.total/arguments.rc.rows>
    </cfif>
    
    <cfreturn pages>
</cffunction>


<cffunction name="limiterByTime">
    <cfargument name="maxRequest"       type="numeric">
    <cfargument name="waitTimeRequest"  type="numeric">
    <cfargument name="prc">
    <cfargument name="event">

    <cfset var userRequest = checkIPUser()>

    <cfset cleanIPUser()>

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

<cffunction name="cleanIPUser">

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

<cffunction name="checkIPUser">
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

<cffunction name="addIPUser">
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
<cffunction name="getIsoTimeString" returntype="string">
    <cfargument name="datetime" required="true" type="date">
    <cfargument name="convertToUTC" default="true">
  
    <cfscript>
        if (convertToUTC) {
            datetime = dateConvert( "local2utc", datetime );
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
