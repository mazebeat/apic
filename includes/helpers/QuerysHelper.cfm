<!--- 
    ESTE ES ARCHIVO CONTIENE HELPERS PARA QUERIES 
--->

<!-- 
    * Convierte un objeto Query en una estructura.
    * @Query 
    * @Row 
    -->
<cffunction name="queryToStruct" returnType="any" output="false">
    <cfargument name="Query" type="query" required="true" />
    <cfargument name="Row" type="numeric" required="false" default="0" />

    <cfscript>
        var local = StructNew();

        if (arguments.Row){
            local.FromIndex = arguments.Row;
            local.ToIndex   = arguments.Row;
        } else {
            local.FromIndex = 1;
            local.ToIndex = arguments.Query.RecordCount;
        }

        local.Columns     = ListToArray(arguments.Query.ColumnList);
        local.ColumnCount = ArrayLen(local.Columns);
        local.DataArray   = ArrayNew(1);

        for (local.RowIndex = local.FromIndex ; local.RowIndex LTE local.ToIndex ; local.RowIndex = (local.RowIndex + 1)){
            ArrayAppend(local.DataArray, StructNew());

            local.DataArrayIndex = ArrayLen(local.DataArray);

            for (local.ColumnIndex = 1 ; local.ColumnIndex LTE local.ColumnCount ; local.ColumnIndex = (local.ColumnIndex + 1)){
                local.ColumnName = local.Columns[local.ColumnIndex];
                
                if(isNumeric(local.ColumnName)) {
                    local.ColumnName = val(local.ColumnName);
                } else {
                    local.ColumnName = LCase(local.ColumnName);
                }
                local.ColumnValue = arguments.Query[local.ColumnName][local.RowIndex];

                if(IsQuery(local.ColumnValue)) {
                    local.ColumnValue = QueryToStruct(local.ColumnValue);
                } 

                local.DataArray[local.DataArrayIndex][local.ColumnName] =local.ColumnValue;
            }
        }

        if (arguments.Row){
            return(local.DataArray[1]);
        } else {
            return(local.DataArray);
        }

        struct
    </cfscript>
</cffunction>

<!--
    * Converts an entire query or the given record to a struct. This might return a structure (single record) or an array of structures.
    * @Query 
    * @index 
    * @Row
    -->
<cffunction name="queryToStruct2" returnType="any" output="false">
    <cfargument name="Query" type="query" required="true" />
    <cfargument name="index" type="string" required="false" default="" />
    <cfargument name="Row" type="numeric" required="false" default="0" />
    
    <cfscript>
        var local = StructNew();

        if (arguments.Row) 	{
            local.FromIndex = arguments.Row;
            local.ToIndex   = arguments.Row;
        } else {
            local.FromIndex = 1;
            local.ToIndex   = arguments.Query.RecordCount;
        }

        local.Columns     = ListToArray(arguments.Query.ColumnList);
        local.ColumnCount = ArrayLen(local.Columns);

        local.DataArray = ArrayNew(1);
        local.DataArray = createObject("java", "java.util.LinkedHashMap").init();

        for (local.RowIndex = local.FromIndex ; local.RowIndex LTE local.ToIndex ; local.RowIndex = (local.RowIndex + 1)) {

            local.DataArrayIndex = structCount(local.DataArray);
            if (arguments.index is '' || listfindnocase(arguments.Query.ColumnList, arguments.index) is 0) {
                arguments.index = local.Columns[1];
            }
            local.indice = arguments.Query[arguments.index][local.RowIndex];

            for (local.ColumnIndex = 1 ; local.ColumnIndex LTE local.ColumnCount ; local.ColumnIndex = (local.ColumnIndex + 1)) {
                local.ColumnName = LCase(local.Columns[local.ColumnIndex]);

                local.ColumnValue = arguments.Query[local.ColumnName][local.RowIndex];

                if(IsQuery(local.ColumnValue)) {
                    local.ColumnValue = QueryToStruct(local.ColumnValue);
                } 

                local.DataArray[local.indice][local.ColumnName] = local.ColumnValue;
            }
        }

        if (arguments.Row) {
            return(local.DataArray[1]);
        } else {
            return(local.DataArray);
        }
    </cfscript>
</cffunction>

<!--
    * This takes two queries and appends the second one with the first one. Returns the resultant third query.
    * @QueryOne required
    * @QueryTwo required
    * @UnionAll 
    * @return Query
    -->
<cffunction name="queryAppend" access="public" returntype="query" output="false" hint="This takes two queries and appends the second one to the first one. Returns the resultant third query.">

    <!--- Define arguments. --->
    <cfargument name="QueryOne" type="query" required="true">
    <cfargument name="QueryTwo" type="query" required="true">
    <cfargument name="UnionAll" type="boolean" required="false" default="true">

    <!--- Define the local scope. --->
    <cfset var local = StructNew() />

    

    <!--- Append the second to the first. Do this by unioning the two queries. --->
    <cfquery name="local.NewQuery" dbtype="query">
        <!--- Select all from the first query. --->
        (
            SELECT
            *
            FROM
            #arguments.QueryOne#
       )
        <!--- Union the two queries together. --->
        UNION <cfif arguments.UnionAll>ALL</cfif>
        <!--- Select all from the second query. --->
        (
            SELECT
            *
            FROM
            #arguments.QueryTwo#
       )
    </cfquery>

    <cfdump var="#local.NewQuery#"><cfabort>
    

    <!--- Return the new query. --->
    <cfreturn local.NewQuery>
</cffunction>

<!--
    * This takes two queries and appends the second one to the first one. This actually updates the first query and does not return anything.
    * @QueryOne required
    * @QueryTwo requires
    * @return Query
    -->
<cffunction name="queryAppend2" access="public" returntype="Query" output="false" hint="This takes two queries and appends the second one to the first one. This actually updates the first query and does not return anything.">
    <cfargument name="QueryOne" type="query" required="true" />
    <cfargument name="QueryTwo" type="query" required="true" />

    <!--- Define the local scope. --->
    <cfset var local = StructNew() />

    <!--- Get the column list (as an array for faster access. --->
    <cfset local.Columns = ListToArray(arguments.QueryTwo.ColumnList) />

    
    <!--- Loop over the second query. --->
    <cfloop query="arguments.QueryTwo">
            

        <!--- Add a row to the first query. --->
        <!--- <cfset QueryAddRow(arguments.QueryOne) /> --->

        <!--- Loop over the columns. --->
        <cfloop index="local.Column" from="1" to="#ArrayLen(local.Columns)#" step="1">
            
            <!--- Get the column name for easy access. --->
            <cfset local.ColumnName = local.Columns[local.Column] />
            
            <cfif NOT queryColumnExists(arguments.QueryOne, local.ColumnName)>
                <cfset queryAddColumn(arguments.QueryOne, local.ColumnName)>
            </cfif>
            <!--- Set the column value in the newly created row. --->
            <cfset arguments.QueryOne[local.ColumnName][arguments.QueryOne.RecordCount] = arguments.QueryTwo[local.ColumnName][arguments.QueryTwo.CurrentRow] />           
        </cfloop>

    </cfloop>

    <!--- Return out. --->
    <cfreturn arguments.QueryOne>
</cffunction>

<!--
    * Obtiene una row especifica por su posición de una Query
    * @query 
    * @rowNumber  
    -->
<cffunction name="getQueryRow" access="public" returntype="any" output="false">
    <cfargument name="query" type="query" required="true">
    <cfargument name="rowNumber" type="numeric" required="true">
    
    <cfquery name="local.myQueryRow" dbtype="query" datasource="#application.datasource#">
        SELECT * FROM query WHERE id=id_of_row
    </cfquery>

    <cfreturn local.myQueryRow>
</cffunction>

<!--
    * Renombra una columna de una Query
    * queryObj Query
    * oldColName Nombre de la columna que se requiere reemplazar
    * newColName Nombre que reemplazará el actual.
    -->
<cffunction name="renameColumn" access="public" output="false" returntype="query" hint="Uses java to rename a given query object column">
    <cfargument name="queryObj" required="true" type="query">
    <cfargument name="oldColName" required="true" type="string">
    <cfargument name="newColName" required="true" type="string">

    
    <!--- Get an array of the current column names --->
    <cfset var colNameArray = queryObj.getColumnNames()>
    <cfset colNameArray = ArrayMerge([], queryObj.getColumnNames())>
    <cfset var i = 0>
    
    <!--- Loop through the name array and try match the current column name with the target col name--->
    <cfif arrayLen(colNameArray)>
        <cfloop from="1" to="#arrayLen(colNameArray)#" index="i">
            <!--- If we find the target col name change to the new name --->
            <cfif compareNoCase(colNameArray[i],arguments.oldColName) EQ 0>
                <cfset colNameArray[i] = arguments.newColName>                
            </cfif>
        </cfloop>
    </cfif>
  
    <!--- Update the column names with the updated name array --->
    <cfset queryObj.setColumnNames(colNameArray)>
    
    <cfreturn queryObj />
</cffunction>