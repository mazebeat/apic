<cfcomponent output="false" extends="models.campo.CampoFormulario">
	
	<cffunction name="init" returntype="campoFormulario">
		<cfreturn this>
	</cffunction>

	<cffunction name="setListaValores" access="public" returntype="void" output="false">
		<cfargument name="qListaValores">
		<cfset variables.instancia.listaValores = {}>
		<cfset variables.instancia.listaOrdenes = {}>
		
		<cfquery name="local.qDistintosValores" dbtype="query">
			SELECT DISTINCT(id_valor)
			FROM qListaValores
		</cfquery>
		<cfif local.qDistintosValores.recordCount gt 0>
			<cfloop query="local.qDistintosValores">
				<cfquery name="local.qUnValor" dbtype="query">
					SELECT *
					FROM arguments.qListaValores
					WHERE id_valor = '#id_valor#'
				</cfquery>
				<cfset variables.instancia.listaValores[id_valor] = {}>
				<cfset variables.instancia.listaOrdenes[id_valor] = {}>
				
				<cfloop query="local.qUnValor">
					<cfset variables.instancia.listaValores[id_valor][id_idioma] = titulo>
					<cfset variables.instancia.listaOrdenes[id_valor][id_idioma] = orden>
				</cfloop>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="getConfiguracion" access="public" returntype="Query" output="false">
		<cfargument name="campo" type="query"> 
		<cfquery name="local.qConfig" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,1,0)#">
			SELECT solo_lectura
			FROM vCampos
			WHERE id_campo = <cfqueryparam value="#variables.instancia.id_campo#" cfsqltype="CF_SQL_INTEGER">
			AND id_idioma = <cfqueryparam value="#session.language#" cfsqltype="CF_SQL_CHAR">
		</cfquery>
	
		<cfif local.qConfig.recordCount gt 0>
			<cfset campo.solo_lectura= local.qConfig.solo_lectura>
		<cfelse>
			<cfset campo.solo_lectura = 0>
		</cfif>
	
		<cfreturn campo>
	</cffunction>

</cfcomponent>