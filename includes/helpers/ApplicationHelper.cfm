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

    
    <cfif NOT IsDefined("application.rate_limiter")>
        <cfset application.rate_limiter = StructNew()>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR]              = StructNew()>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = 1>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = NOW()>

        <cfset addIPUser(prc, event)>
    <cfelse>
        <cfif NOT CGI.HTTP_COOKIE IS "">
            <cfset addIPUser(prc, event)>

            <cfif StructKeyExists(application.rate_limiter, CGI.REMOTE_ADDR) 
                && DateDiff("s", application.rate_limiter[CGI.REMOTE_ADDR].last_attempt, NOW()) LT arguments.waitTimeRequest>
                
                 <cfif application.rate_limiter[CGI.REMOTE_ADDR].attempts GT arguments.maxRequest>
                    <cfset logBox.getLogger("fileLogger").info("limiter invoked for: '#cgi.remote_addr#', #application.rate_limiter[CGI.REMOTE_ADDR].attempts#, #cgi.request_method#, '#cgi.SCRIPT_NAME#', '#cgi.QUERY_STRING#', '#cgi.http_user_agent#', '#application.rate_limiter[CGI.REMOTE_ADDR].last_attempt#', #listlen(cgi.http_cookie,";")#")>
                    
                    <cfset prc.response.addHeader("Retry-After", arguments.waitTimeRequest)
                                        .setError(true)
                                        .addMessage("You are making too many requests too fast, please slow down and wait #arguments.waitTimeRequest# seconds (#cgi.remote_addr#)")
                                        .setStatusText("Service Unavailable")
                                        .setStatusCode(503)>

                    <cfset event.renderData(
                        type		= prc.response.getFormat(),
                        data 		= prc.response.getDataPacket(),
                        contentType = prc.response.getContentType(),
                        statusCode 	= prc.response.getStatusCode(),
                        statusText 	= prc.response.getStatusText(),
                        location 	= prc.response.getLocation(),
                        isBinary 	= prc.response.getBinary()
                    )>
                </cfif>

                <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = application.rate_limiter[CGI.REMOTE_ADDR].attempts + 1>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = NOW()>
            <cfelse>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR]              = StructNew()>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = 1>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = NOW()>            
            </cfif>        
        </cfif>
    </cfif>

    <cfset checkIPUser()>
</cffunction>

<cffunction name="checkIPUser">

    <cfif (RandRange( 1, 10 ) EQ 5)>
        <cfquery name="local.qIPCheck" datasource="#application.datasource#">
            <!---
                Occassionally thin out the database table. We are using
                a random number here to make sure this doesn't happen on
                every page request.
            --->
            DELETE FROM apic_currentUser
            WHERE last_attempt < <cfqueryparam value="#DateAdd( 'n', -1, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />;
            

            <!--- 
            UPDATE apic_currentUser
            SET active = 0
            WHERE last_attempt < <cfqueryparam value="#DateAdd( 'n', -1, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />; 
            --->
        </cfquery>
    </cfif>

    <!--- <cfquery name="local.qIPCheck" datasource="#application.datasource#">
        <!---
            Get the number of unique IP users have used this site in
            the last two minutes (FOR THIS IP ADDRESS).
        --->
        SELECT
            COUNT(*) AS user_request_count
        FROM apic_currentUser
        WHERE last_attempt >= <cfqueryparam value="#DateAdd( 'n', -2, NOW() )#" cfsqltype="CF_SQL_TIMESTAMP" />
        <!--- Limit to this IP address. --->
        AND ip_address = <cfqueryparam value="#CGI.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />
        <!---
            We want to exclude the current user from this count as
            he shouldn't weight in against his *own* page requests.
        --->
        AND user_token != <cfqueryparam value="#SESSION.CFID#-#SESSION.CFTOKEN#" cfsqltype="CF_SQL_VARCHAR" />
        GROUP BY user_token;
    </cfquery> --->

    <!--- <cfreturn local.qIPCheck> --->
</cffunction>

<cffunction name="addIPUser">
    <cfargument name="prc">
    <cfargument name="event">

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
            <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR" />,
            <cfqueryparam value="#application.rate_limiter[CGI.REMOTE_ADDR].attempts#" cfsqltype="CF_SQL_INTEGER" />,
            <cfqueryparam value="#SESSION.CFID#-#SESSION.CFTOKEN#" cfsqltype="CF_SQL_VARCHAR" />,
            <cfqueryparam value="#application.rate_limiter[CGI.REMOTE_ADDR].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />,
            <cfqueryparam value="#event.getCurrentEvent()#" cfsqltype="CF_SQL_VARCHAR" />,
            <cfqueryparam value="#CGI.HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR" />,
            <cfqueryparam value="#NOW()#" cfsqltype="CF_SQL_TIMESTAMP" />
        )
        <!--- 
        ON DUPLICATE KEY 
        UPDATE 
        user_request_count = <cfqueryparam value="#application.rate_limiter[CGI.REMOTE_ADDR].attempts#" cfsqltype="CF_SQL_INTEGER" />,
        last_attempt = <cfqueryparam value="#application.rate_limiter[CGI.REMOTE_ADDR].last_attempt#" cfsqltype="CF_SQL_TIMESTAMP" />
         --->
        ;
    </cfquery>    
</cffunction>