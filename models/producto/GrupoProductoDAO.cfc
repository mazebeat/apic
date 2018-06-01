<cfcomponent hint="ProductoDAO" output="false" accessors="true">

	<!--- Properties --->
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="GrupoProductoDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="all" access="public" returntype="any" output="false">
		<cfargument name="id_evento">
	
		<cfquery name="local.grupos" datasource="#application.datasource#">
			SELECT
			DISTINCT(id_grupo) AS id_grupo,
			titulo,
			descripcion,
			activo,
			'' AS productos
			FROM vGruposProductos
			WHERE id_evento IN (<cfqueryparam value="#arguments.id_evento#" cfsqltype="CF_SQL_INTEGER" list="true">)
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_VARCHAR">;
		</cfquery>

		<cfquery name="local.productosByGrupo" datasource="#application.datasource#">
			SELECT 
			DISTINCT(id_grupo) AS id_grupo,
			id_producto,
			titulo,
			descripcion			
			FROM vProductos
			WHERE id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_VARCHAR">
			AND id_grupo IN (<cfqueryparam value="#valueList(local.grupos.id_grupo)#" list="true" cfsqltype="CF_SQL_INTEGER">);
		</cfquery>

		<cfloop query="#local.grupos#">
			<cfquery name="local.findProductos" dbtype="query">
				SELECT *
				FROM [local].productosByGrupo
				WHERE id_grupo = #id_grupo#
			</cfquery>

			<cfset queryDeleteColumn(local.findProductos, 'id_grupo')>
			<!--- <cfset queryDeleteColumn(local.findProductos, 'id_producto')> --->

			<cfset local.grupos.productos[currentrow] = local.findProductos>
		</cfloop>

		<cfset queryDeleteColumn(local.grupos, 'id_grupo')>

		<cfreturn local.grupos>
	</cffunction>

</cfcomponent>