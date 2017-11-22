<cffunction name="paginationToString">
    <cfargument name="rc" required="true">

    <cfset var pages = "">

    <cfif structKeyExists(arguments.rc, 'page') && structKeyExists(arguments.rc, 'rows') && arguments.rc.rows GT 0 && arguments.rc.page GT 0>
        <cfset pages =  arguments.rc.page & " of " & arguments.rc.total/arguments.rc.rows>
    </cfif>
    
    <cfreturn pages>
</cffunction>


<cffunction name="limiterByTime">
    <!---
        * Throttles requests made more than "request" times within "duration" seconds from single IP.
        * sends 503 status code for bots to consider as well as text for humans to read
        * also logs to a new "limiter.log" that is created automatically in cf logs directory (cfusion\logs, in CF10 ad above), tracking when limits are hit, to help fine tune
        * note that since it relies on the application scope, you need to place the call to it AFTER a cfapplication tag in application.cfm (if called in onrequeststart of application.cfc, that would be implicitly called after onapplicationstart so no worries there)
        * updated 10/16/12: now adds a test around the actual throttling code, so that it applies only to requests that present no cookie, so should only impact spiders, bots, and other automated requests. A "legit" user in a regular browser will be given a cookie by CF after their first visit and so would no longer be throttled.
        * I also tweaked the cflog output to be more like a csv-format output
    --->
    <cfargument name="countRequest" type="numeric" default="3">
    <cfargument name="duration" type="numeric" default="3">
    <cfargument name="prc">
    <cfargument name="event">
    <cfargument name="waitTime" type="numeric" default="10">

    <cfset var log = logBox.getLogger("fileLogger")>
    
    <cfif not IsDefined("application.rate_limiter")>
        <cfset application.rate_limiter = StructNew()>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR]              = StructNew()>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = 1>
        <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = Now()>
    <cfelse>
        <cfif NOT CGI.HTTP_COOKIE IS "">
            <cfif StructKeyExists(application.rate_limiter, CGI.REMOTE_ADDR) &&
                    DateDiff("s",application.rate_limiter[CGI.REMOTE_ADDR].last_attempt, Now()) LT arguments.duration>
                <cfif application.rate_limiter[CGI.REMOTE_ADDR].attempts GT arguments.countRequest>
                    <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = application.rate_limiter[CGI.REMOTE_ADDR].attempts + 1>
                    <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = Now()>
                    
                    <cfset log.info("'limiter invoked for:','#cgi.remote_addr#',#application.rate_limiter[CGI.REMOTE_ADDR].attempts#,#cgi.request_method#,'#cgi.SCRIPT_NAME#', '#cgi.QUERY_STRING#','#cgi.http_user_agent#','#application.rate_limiter[CGI.REMOTE_ADDR].last_attempt#',#listlen(cgi.http_cookie,";")#")>
                    <cfset log.info("You are making too many countRequest too fast, please slow down and wait #arguments.duration# seconds (#cgi.remote_addr#)")>
                    
                    <cfset prc.response.addHeader("Retry-After", arguments.duration)
                                        .setError(true)
                                        .addMessage("You are making too many requests too fast, please slow down and wait #arguments.duration# seconds (#cgi.remote_addr#)")
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
                <cfelse>
                    <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = application.rate_limiter[CGI.REMOTE_ADDR].attempts + 1>
                    <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = Now()>
                </cfif>
            <cfelse>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR]              = StructNew()>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR].attempts     = 1>
                <cfset application.rate_limiter[CGI.REMOTE_ADDR].last_attempt = Now()>
            </cfif>
        </cfif>
    </cfif>
</cffunction>

<cffunction name="checkIPUser">
    <cfquery name="qIPCheck">
        <!---
            Occassionally thin out the database table. We are using
            a random number here to make sure this doesn't happen on
            every page request.
        --->
        <cfif (RandRange( 1, 10 ) EQ 5)>
            <!--- Delete records more than 2 minutes old. --->
            DELETE FROM apic_currentUser
            WHERE date_created < <cfqueryparam value="#DateAdd( 'n', -2, Now() )#" cfsqltype="CF_SQL_TIMESTAMP" />
        </cfif>
        <!---
            Get the number of unique IP users have used this site in
            the last two minutes (FOR THIS IP ADDRESS).
        --->
        SELECT
            COUNT(*) AS user_count
        FROM apic_currentUser
        WHERE date_created >= <cfqueryparam value="#DateAdd( 'n', -2, Now() )#" cfsqltype="CF_SQL_TIMESTAMP" />
        <!--- Limit to this IP address. --->
        AND ip_address = <cfqueryparam value="#CGI.remote_addr#" cfsqltype="CF_SQL_VARCHAR" />
        <!---
            We want to exclude the current user from this count as
            he shouldn't weight in against his *own* page requests.
        --->
        AND user_token != <cfqueryparam value="#SESSION.CFID#-#SESSION.CFTOKEN#" cfsqltype="CF_SQL_VARCHAR" />
        GROUP BY user_token
    </cfquery>
    
    
</cffunction>