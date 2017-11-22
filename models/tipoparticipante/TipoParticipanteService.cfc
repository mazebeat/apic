<!--  
	Tipo de Participante Service
-->
<cfcomponent hint="Tipo de Participante Service" output="false" accessors="true">
	<cftimer label= "models/tipoparticipante/TipoParticipanteService"></cftimer>
	<!--- Properties --->
	<cfproperty name="dao" inject="model:tipoparticipante.TipoParticipanteDAO">
	<cfproperty name="log" inject="logbox:logger:{this}">
	<cfproperty name="populator"	inject="wirebox:populator">
    <cfproperty name="wirebox"		inject="wirebox">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="TipoParticipanteService" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	<!-- 
		Obtiene todos los tipos de participantes
		@event 
		@rc 
	-->
	<cffunction name="all" hint="Todos los tipos de participantes" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		
		<cfset s = { ok = true, mensaje= "", data = { "records"={},  "count"= 0, "total"= 0 } }>

		<cftry>
			<cfset var records = dao.all(arguments.event, arguments.rc)>

			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

	<!-- 
		Obtiene un tipo de participante en concreto por ID
		@event 
		@rc 
		@id_tipo_participante 
	-->
	<cffunction name="get" hint="Obtiene un tipo de participante en concreto por ID" output="false" returntype="struct">
		<cfargument name="event">
		<cfargument name="rc">
		<cfargument name="id_tipo_participante" type="numeric" required="true">
		
		<cfset s = { ok = true, mensaje= "", data = { "records"={},  "count"= 0 } }>

		<cftry>
			<cfset var records = dao.get(arguments.event, arguments.rc, arguments.id_tipo_participante)>

			<cfset s.data.records = records>
			<cfset s.data.count = records.recordCount>
		<cfcatch type = "any">
			<cfthrow type="any" message="#cfcatch.Message#">
		</cfcatch>
		</cftry> 
		
		<cfreturn s>
	</cffunction>

</cfcomponent>