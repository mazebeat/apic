<cfcomponent hint="I am a new Model Object" output="false" accessors="true" extends="models.BaseModel">

	<!--- Properties --->
	<cfproperty name="daoParticipante" inject="model:participante.ParticipanteDAO">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="generalDAO" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="all" returntype="struct" outoput="false">
	<cfargument name="id_evento" required="true">

	<cfset all ={}>

	<cfscript>
		var tipoParticipante = daoParticipante.getTipoParticipante(arguments.id_evento);
		
		var qNombreTiposParticipante = objEstadClientes.generarTipoParticipantes();
		var eNombreTiposParticipante = QueryToStruct(qNombreTiposParticipante.datos, 'id_tipo_participante');
		1
		
		<!---PREINSCRITOS--->
		var Preinscritos = objEstadClientes.generarPreinscritos();
		var listaTiposPreinscritos = valuelist(Preinscritos.datos.id_tipo_participante, ",");
		var listaTiposPreinscritosNulos = listNotInList(TipoParticipantes,listaTiposPreinscritos);
		
		<!---INSCRITOS--->
		var Inscritos = objEstadClientes.generarInscritos();
		var listaTiposInscritos = valuelist(Inscritos.datos.id_tipo_participante, ",");
		var listaTiposInscritosNulos = listNotInList(TipoParticipantes,listaTiposInscritos);
		
		<!---ACREDITADOS--->
		var Acreditados=objEstadClientes.generarAcreditados();
		var listaTiposAcreditados = valuelist(Acreditados.datos.id_tipo_participante, ",");
		var listaTiposAcreditadosNulos = listNotInList(TipoParticipantes,listaTiposAcreditados);

		
		<!---POR DIAS--->
		var AcredPorDias=objEstadClientes.generarAcredPorDias(); 
		
		var AcredPorDiasYPart=objEstadClientes.generarAcredPorDiasYPart(); 
		var listaTiposAcredPorDiasYPart = valuelist(AcredPorDiasYPart.datos.id_tipo_participante, ","); 
		var listaTiposAcredPorDiasYPartNulos = listNotInList(TipoParticipantes,listaTiposAcredPorDiasYPart); 
		var listaTiposAcredSinDuplicados= ListDeleteDuplicatesNoCase(listaTiposAcredPorDiasYPart); 
	</cfscript>
	
	<cfloop list="#listaTiposAcredSinDuplicados#" index= "id_tipo_participante">   
	
		<cfquery dbtype="query" name="FechasPorParticipante"  cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">  
			SELECT count(acred.id_tipo_participante) as numero_max_fechas, id_tipo_participante 
			FROM  AcredPorDiasYPart.datos acred
			WHERE acred.id_tipo_participante = <cfqueryparam value="#id_tipo_participante#" cfsqltype="cf_sql_integer">
			group by id_tipo_participante
		</cfquery> 
	</cfloop>

	<cfquery dbtype="query" name="FechasTotalesAcreditados" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">  
		SELECT fecha
		FROM  AcredPorDias.datos
		order by fecha
	
	</cfquery> 

	<!---MODOS--->
	
	<cfset NumInsitu = objEstadClientes.generarNumInsitu()>
	<cfset NumWeb = objEstadClientes.generarNumWeb()>
	<cfset TotalNumWeb = objEstadClientes.generarTotalNumWeb()>
	<cfset TotalNumInsitu = objEstadClientes.generarTotalNumInsitu()>
	
	<cfreturn all>
</cffunction>

</cfcomponent>