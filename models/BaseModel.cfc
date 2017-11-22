<!--
  Base Model
 -->
<cfcomponent output="false" accessors="true" hint="Base Model">

	<!--- Properties --->
	<cfproperty name="dsn" 				type="any" inject="coldbox:datasource:sige">
	<cfproperty name="queryLimit" 		type="any" inject="coldbox:setting:queryLimit">
	<cfproperty name="queryExpiration" 	type="any" inject="coldbox:setting:queryExpiration">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="BaseModel" output="false" hint="constructor">
		<cfscript>	
			return this;
		</cfscript>
	</cffunction>
	

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getURLLink">
		<cfargument name="token" 	type="string"	required="true">
		<cfargument name="id" 		type="numeric"	required="false">
		<cfargument name="version" 	type="numeric"	required="true" default="1">

		<cfscript>
			var link = "http" & (cgi.HTTPS EQ 'YES' ? 's' : '') & "://" & cgi.server_name & cgi.script_name & "/apic/v" & version & "/" & lcase(session.language) & "/"& arguments.token;					
			return Trim(link);
		</cfscript>		
	</cffunction>
	
</cfcomponent>