<cfcomponent hint="ProductoDAO" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="partServ"			inject="model:participante.ParticipanteDAO">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ProductoDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<cffunction name="all" access="public" returntype="any" output="false">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">
	
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

	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">
	
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


	<cffunction name="allSelected" access="public" returntype="any" output="false">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset local.allParticipantes = partServ.all(arguments.id_evento, arguments.event, arguments.rc)>
	
		<cfquery name="local.seleccionados" datasource="#application.datasource#">
			SELECT id_producto, id_participante AS 'data', comprar, vender, colaborar
			FROM vProductosSeleccionados
			WHERE id_participante IN (<cfqueryparam value="#valueList(allParticipantes.id_participante)#" list="true" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>

		<cfloop query="#local.seleccionados#">
			<cfquery name="local.findParticipantes" dbtype="query">
				SELECT *
				FROM [local].allParticipantes
				WHERE id_participante = #data#
			</cfquery>

			<cfset local.seleccionados.data[currentrow] = local.findParticipantes>
		</cfloop>

		<cfset local.seleccionados2 = QueryNew("id_producto,participantes", "integer,varchar")>

		<cfloop list="#listremoveduplicates(valueList(local.seleccionados.id_producto))#" index="i">
			<cfquery name="local.findProducts" dbtype="query">
				SELECT data, comprar, vender, colaborar
				FROM [local].seleccionados
				WHERE id_producto = #i#				
			</cfquery>

			<cfset queryAddRow(local.seleccionados2, [javaCast('integer', i), local.findProducts])>
		</cfloop>

		<cfreturn local.seleccionados2>
	</cffunction>

	<cffunction name="selectedByParticipante" access="public" returntype="any" output="false">
		<cfargument name="id_evento" required="true">
		<cfargument name="event">
		<cfargument name="rc">

		<cfset allParticipantes = partServ.get(arguments.event, arguments.rc, arguments.rc.id_evento, arguments.rc.id_participante)>

		<cfquery name="local.seleccionados" datasource="#application.datasource#">
			SELECT id_producto, comprar, vender, colaborar
			FROM vProductosSeleccionados
			WHERE id_participante = (<cfqueryparam value="#valueList(allParticipantes.id_participante)#" list="true" cfsqltype="CF_SQL_INTEGER">);
		</cfquery>

		<cfreturn local.seleccionados>
	</cffunction>

</cfcomponent>