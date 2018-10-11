<!--
  Base Model
 -->
<cfcomponent output="false" accessors="true" hint="Base Model">

	<!--- Properties --->
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
			return trim(link);
		</cfscript>		
	</cffunction>

	<cffunction name="getPaginationQuery">
		<cfargument name="token" type="string" required="true">
	</cffunction>

	<cfscript>
		any function GetQueryRow(query, rowNumber) {
			var i = 0;
			var rowData = StructNew();
			var cols = ListToArray(query.columnList);
			for (i = 1; i lte ArrayLen(cols); i = i + 1) {
				rowData[lcase(cols[i])] = query[cols[i]][rowNumber];
			}
			return rowData;
		}

		any function sanatizeQuery(any value) {
			include ("/includes/helpers/ApplicationHelper.cfm");
			
			if(!isStruct(arguments.value)) {
				return sanatize(arguments.value)
				// return application.esapi.encoder().encodeForSQL(application.esapiMyslCodec, javacast("string", arguments.value));
			}

			return arguments.value;
		}

		any function sanatizeQueryColumn(any value) {
			// if(!isStruct(arguments.value)) {
			// 	return application.esapi.encoder().encodeForSQL(application.esapiMyslCodec, javacast("string", arguments.value));
			// }
			return sanatizeQuery(arguments.value)
		}
	</cfscript>
</cfcomponent>