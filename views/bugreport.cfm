<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
<style> .jumbotron { font-weight: 300; } table th { font-size: 14px } table td { font-size: 12px } table th.{ font-weight: normal; color: #ffffff; } #details { font-size: 18px; } 
samp.stacktrace{ font-family: Courier; font-size:14px; } 
samp.stacktrace .highlight{ font-weight: bold; background-color: #F0F7FE !important; padding:2px 0px; } 
samp.stacktrace .method{ font-weight: bold; color:red !important; } 
div.col-md-12 { word-wrap: break-word; }</style>
<div class="container-fluid">
    <cfoutput>
        <cfscript>
            // Detect Session Scope 
            local.sessionScopeExists = true; try { structKeyExists( session ,'x' ); } catch ( any e ) { local.sessionScopeExists = false; } try{ local.thisInetHost = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName();
            } catch( any e ){ local.thisInetHost = "localhost"; }
        </cfscript>

        <!--- Param Form Scope --->                
        <cfparam name="form" default="#structnew()#">
        
        <div class="jumbotron bg-danger"  style="color: ##ffffff">
            <h3>Oops! Houston we have a problem</h3>
            <h1 class="display-3">
                #HeadersValues.method# <cfif oException.geterrorCode() neq "" AND oException.getErrorCode() neq 0>#oException.getErrorCode()#: </cfif>#oException.getmessage()#
            </h1>
            <h2 >
                <cfif oException.getExtendedInfo() neq ""> #oException.getExtendedInfo()# <br></cfif>
                <cfif len( oException.getDetail() ) neq 0>#oException.getDetail()# </cfif>
                <cfif oException.getExtraMessage() neq "">
                    <!--- CUSTOM SET MESSAGE --->
                    <h3>#oException.getExtramessage()#</h3>
                </cfif>
            </h2>
        </div>

        <div class="row justify-content-md-center">
            <div class="col-xs-12 col-md-12" style="font-size: 16px; word-wrap: break-word;">
                <!--- Event --->
                <ul class="list-group">
                    <li class="list-group-item">
                        <strong>Event:</strong>
                        <div class="float-right"><cfif event.getCurrentEvent() neq "">#event.getCurrentEvent()# <cfelse>N/A</cfif></div>
                    </li>

                    <li class="list-group-item" >
                        <strong>Routed URL:</strong>
                        <div class="float-right; word-wrap: break-word;" ><cfif event.getCurrentRoutedURL() neq "">#event.getCurrentRoutedURL()# <cfelse>N/A</cfif></div>
                    </li>

                    <li class="list-group-item">
                        <strong>Layout:</strong>
                        <div class="float-right"><cfif Event.getCurrentLayout() neq "">#Event.getCurrentLayout()# <cfelse>N/A</cfif> (Module: #event.getCurrentLayoutModule()#)</div>
                    </li>

                    <li class="list-group-item">
                        <strong>View:</strong>
                        <div class="float-right"><cfif Event.getCurrentView() neq "">#Event.getCurrentView()# <cfelse>N/A</cfif></div>
                    </li>

                    <li class="list-group-item">
                        <strong>Timestamp:</strong>
                        <div class="float-right">#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</div>
                    </li>

                    <!--- ERROR TYPE --->
                    <cfif oException.getType() neq "">
                        <li class="list-group-item">
                            <strong>Type: </strong> <div class="float-right">#oException.gettype()#</div>
                        </li>
                    </cfif>
                </ul>
            </div>
        </div>

        <div class="row">
            <div class="col-xs-12 col-md-12">
                <h2>Tag Context:</h2>
                
                <table class="table table-hover table-sm">
                    <cfif ArrayLen( oException.getTagContext() )>
                        <cfset local.arrayTagContext= oException.getTagContext()>
                        
                        <cfloop from="1" to="#arrayLen( local.arrayTagContext )#" index="local.i">
                            <!--- Don't clutter the screen with this information unless it's actually useful --->
                            <cfif structKeyExists( local.arrayTagContext[ local.i ], "ID" ) and len( local.arrayTagContext[ local.i ].ID ) and local.arrayTagContext[ local.i ].ID neq "??">
                                <tr>
                                    <th scope="row">Tag:</th>
                                    <td>#local.arrayTagContext[ local.i ].ID#</td>
                                </tr>
                            </cfif>
                            <tr>
                                <th scope="row">Template:</th>
                                <td style="color:green;"><strong>#local.arrayTagContext[ local.i ].Template#</strong></td>
                            </tr>
                            <cfif structKeyExists( local.arrayTagContext[ local.i ], "codePrintHTML" )>
                                <tr class="tablebreak">
                                    <th scope="row">Line:</th>
                                    <td>#local.arrayTagContext[ local.i ].codePrintHTML#</td>
                                </tr>
                            <cfelse>
                                <tr class="tablebreak">
                                    <th scope="row">Line:</th>
                                    <td><strong>#local.arrayTagContext[ local.i ].LINE#</strong></td>
                                </tr>
                            </cfif>
                        </cfloop>
                    </cfif>
                </table>
            </div>

            <div class="col-xs-12 col-md-12">
                <h2>Stack Trace:</h2>
                
                <samp class="stacktrace">#oException.getstackTrace()#</samp>
            </div>
            
            <div class="col-xs-12 col-md-12">
                <!--- FRAMEWORK SNAPSHOT --->
                <h2>Framework Snapshot:</h2>
                
                <table class="table table-hover table-sm">                
                    <tr>
                        <th scope="row">Bug Date:</th>
                        <td>#dateformat(now(), "MM/DD/YYYY")# #timeformat(now(),"hh:MM:SS TT")#</td>
                    </tr>

                    <tr>
                        <th scope="row">Coldfusion ID: </th>
                        <td>
                            <cfif local.sessionScopeExists>
                                <cfif isDefined( "session") and structkeyExists(session, "cfid")> CFID=#session.CFID# ; <cfelseif isDefined( "client") and structkeyExists(client, "cfid")> CFID=#client.CFID# ; </cfif>
                                <cfif isDefined( "session") and structkeyExists(session, "CFToken")> CFToken=#session.CFToken# ; <cfelseif isDefined( "client") and structkeyExists(client, "CFToken")> CFToken=#client.CFToken# ; </cfif>
                                <cfif isDefined( "session") and structkeyExists(session, "sessionID")> JSessionID=#session.sessionID# </cfif>
                            <cfelse>
                                Session Scope Not Enabled
                            </cfif>
                        </td>
                    </tr>                                            
                                
                    <tr>
                        <th scope="row">Template Path : </th>
                        <td>#htmlEditFormat(CGI.CF_TEMPLATE_PATH)#</td>
                    </tr>
                    <tr>
                        <th scope="row">Path Info : </th>
                        <td>#htmlEditFormat(CGI.PATH_INFO)#</td>
                    </tr>
                    <tr>
                        <th scope="row"> Host &amp; Server: </th>
                        <td>#htmlEditFormat(cgi.http_host)# #local.thisInetHost#</td>
                    </tr>
                    <tr>
                        <th scope="row">Query String: </th>
                        <td>#htmlEditFormat(cgi.QUERY_STRING)#</td>
                    </tr>

                    <cfif len(cgi.HTTP_REFERER)>
                        <tr>
                            <th scope="row">Referrer:</th>
                            <td>#htmlEditFormat(cgi.HTTP_REFERER)#</td>
                        </tr>
                    </cfif>
                                                
                    <tr>
                        <th scope="row">Browser:</th>
                        <td>#htmlEditFormat(cgi.HTTP_USER_AGENT)#</td>
                    </tr>

                    <tr>
                        <th scope="row">Remote Address: </th>
                        <td>#htmlEditFormat(cgi.remote_addr)#</td>
                    </tr> 
                </table>
            </div>
            
            <div class="col-xs-12 col-md-12">
                <cfif isStruct(oException.getExceptionStruct())>
                    <cfif findnocase( "database", oException.getType() )>
                        <table class="table table-hover table-sm">
                            <thead class="thead-dark">
                                <th colspan="2" class="text-center">Database oException Information:</th>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="2" scope="row">NativeErrorCode & SQL State</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#oException.getNativeErrorCode()#: #oException.getSQLState()#</td>
                                </tr>
                                <tr>
                                    <td colspan="2" scope="row">SQL Sent</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#oException.getSQL()#</td>
                                </tr>
                                <tr>
                                    <td colspan="2" scope="row">Database Driver Error Message</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#oException.getqueryError()#</td>
                                </tr>
                                <tr>
                                    <td colspan="2" scope="row">Name-Value Pairs</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#oException.getWhere()#</td>
                                </tr>
                            </tbody>
                        </table>
                    </cfif>
                </cfif>
            </div>

            <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">
                    <thead class="thead-dark">
                        <tr>
                            <th colspan="2" class="text-center">Request Data</th>
                        </tr>
                    </thead>

                    <tbody>
                        <cfset myStruct = {}>
                        <cfif isdefined('EventValues') && isStruct(EventValues) && structKeyExists(EventValues, 'data') && structKeyExists(EventValues.data, 'records')>
                            <cfset consignmentDetailArray =  EventValues.data.records>
                            
                            <cfloop array="#consignmentDetailArray#" item="value">
                                <cfset myStruct = value>
                                
                                <cfif isStruct(myStruct)>
                                    <cfloop collection="#myStruct#" index="k">
                                        <tr>
                                            <th scope="row">#k#</th>
                                            <td>
                                                <cfif isSimpleValue( myStruct[ k ] )>
                                                    #htmlEditFormat( myStruct[ k ] )#									
                                                <cfelse>
                                                    <cfdump var="#SerializeJSON(myStruct[ k ])#" />
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                <cfelseif isArray(myStruct)>
                                    <cfloop array="#myStruct#" index="k">
                                        <tr>
                                            <th scope="row"> #k# </th>
                                            <td>
                                                <cfif isSimpleValue( myStruct[ k ] )>
                                                    #htmlEditFormat( myStruct[ k ] )#									
                                                <cfelse>
                                                    <cfdump var="#SerializeJSON(myStruct[ k ])#" />
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <th scope="row">#key#</th>
                                        <td>#myStruct#</td>                                            
                                    </tr>
                                </cfif>
                            </cfloop>
                        </cfif>
                    </tbody>
                </table>
            </div>

              <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">
                    <thead class="thead-dark">
                        <tr>
                            <th colspan="2" class="text-center">Headers</th>
                        </tr>
                    </thead>

                    <tbody>
                        <cfset myStruct = {}>
                        <cfif isdefined('HeadersValues') && isStruct(HeadersValues)>
                            <cfset consignmentDetailArray =  HeadersValues.headers>
                            
                            <cfloop collection="#consignmentDetailArray#" item="value" index="i">
                                <cfset myStruct = value>
                                
                                <!--- <cfif isdefined("url.debugg")>
                                    <cfdump var="#i#" label="myStruct">
                                    <cfdump var="#myStruct#" label="myStruct">
                                    <cfabort>
                                </cfif> --->

                                <cfif isStruct(myStruct)>
                                    <cfloop collection="#myStruct#" index="k">
                                        <tr>
                                            <th scope="row">#k#</th>
                                            <td>
                                                <cfif isSimpleValue( myStruct[ k ] )>
                                                    #htmlEditFormat( myStruct[ k ] )#									
                                                <cfelse>
                                                    <cfdump var="#SerializeJSON(myStruct[ k ])#" />
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                <cfelseif isArray(myStruct)>
                                    <cfloop array="#myStruct#" index="k">
                                        <tr>
                                            <th scope="row"> #k# </th>
                                            <td>
                                                <cfif isSimpleValue( myStruct[ k ] )>
                                                    #htmlEditFormat( myStruct[ k ] )#									
                                                <cfelse>
                                                    <cfdump var="#SerializeJSON(myStruct[ k ])#" />
                                                </cfif>
                                            </td>
                                        </tr>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <th scope="row">#i#</th>
                                        <td>#myStruct#</td>                                            
                                    </tr>
                                </cfif>
                            </cfloop>
                        </cfif>
                    </tbody>
                </table>
            </div>

            <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">
                    <thead class="thead-dark">
                        <tr>
                            <th colspan="2" class="text-center">Form variables</th>
                        </tr>
                    </thead>

                    <tbody>
                        <cfloop collection="#form#" item="key">
                            <cfif key neq "fieldnames">
                                <tr>
                                    <th scope="row">#htmlEditFormat( key )#</th>
                                    <td>
                                        <cfif isSimpleValue( form[ key ] )>
                                            #htmlEditFormat( form[ key ] )#
                                        <cfelse>
                                            <cfdump var="#form[ key ]#">
                                        </cfif>
                                    </td>
                                </tr>
                            </cfif>
                        </cfloop>	
                    </tbody>
                </table>
            </div>

            <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">									
                    <thead class="thead-dark">
                        <th colspan="2" class="text-center">Session Storage</th>
                    </thead>
                    
                    <tbody>
                        <cfif local.sessionScopeExists>
                            <cfloop collection="#session#" item="key">
                                <tr>
                                    <th scope="row">#key#</th>
                                    <td>
                                        <cfif isSimpleValue( session[ key ] )>
                                            #htmlEditFormat( session[ key ] )#									
                                        <cfelse>
                                            <cfdump var="#SerializeJSON(session[ key ])#" />
                                        </cfif>
                                    </td>
                                </tr>
                            </cfloop>
                        <cfelse>
                            <tr>
                                <th scope="row">N/A</th>
                                <td>Session Scope Not Enabled</td>
                            </tr>
                        </cfif>
                    </tbody>
                </table>
            </div>

            <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">									
                    <thead class="thead-dark">
                        <tr>
                            <th colspan="2" class="text-center">Cookies</th>
                        </tr>
                    </thead>

                    <tbody>
                        <cfloop collection="#cookie#" item="key">
                            <tr>
                                <th scope="row"> #key#: </th>
                                <td>#htmlEditFormat( cookie[ key ] )#</td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
            </div>

            <div class="col-xs-12 col-md-12">
                <table class="table table-hover table-sm">	
                    <thead class="thead-dark">
                        <tr>
                            <th colspan="2" class="text-center">Extra Information Dump</th>
                        </tr>
                    </thead>

                    <tbody>
                        <tr>
                            <td colspan="2">
                                <cfif isSimpleValue( oException.getExtraInfo() )>
                                    <cfif not len(oException.getExtraInfo())>[N/A]
                                        <cfelse>#oException.getExtraInfo()#</cfif>
                                    <cfelse>
                                        <cfdump var="#oException.getExtraInfo()#" expand="false">
                                </cfif>                                                    
                            </td>
                        </tr>
                    </tbody>
                </table> 
            </div>
    </cfoutput>
</div>