
<cfcomponent output="false" output="false" accessors="true" extends="models.BaseModel">
	

	<cffunction name="generarTipoParticipantes" access="public" returntype="struct" output="false">
		<cfset var s = {}>
		<cfquery name="local.qTipoParticipante" datasource="#application.datasource#">
			SELECT nombre, id_tipo_participante
			FROM 
				vTiposDeParticipantes 
			WHERE 
				eventos_id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			ORDER BY id_tipo_participante 
		</cfquery>
		<cfset s.ok=true>
		<cfset s.datos = local.qTipoParticipante>
		<cfreturn s>		
	</cffunction>

	<cffunction name="generarPreinscritos" access="public" returntype="struct" output="false">
		<cfset var s = {}>
		<cfquery name="local.qPreInscritos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">
			SELECT 
				COUNT(id_participante) AS PreInscritos, id_tipo_participante
			FROM 
				vParticipantes
			WHERE 
				importado = 1
				AND id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			GROUP BY id_tipo_participante
		</cfquery>
		<cfset s.ok=true>
		<cfset s.datos = local.qPreinscritos>
		
		<cfreturn s>
	</cffunction>
	
	<cffunction name="generarInscritos" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		<cfquery name="local.qInscritos" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">
			SELECT 
				COUNT(id_participante) AS Inscritos, id_tipo_participante
			FROM vParticipantes 
			WHERE inscrito=1
				AND id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			GROUP BY id_tipo_participante
		</cfquery>
		<cfset s.ok=true>
		<cfset s.datos = local.qInscritos>
		<cfreturn s>
	</cffunction>

	
	<cffunction name="generarAcreditados" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qAcreditados" datasource="#application.datasource#"  cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">
			SELECT 
				-- COUNT(id_reg_acceso) as total_acreditados,
				COUNT(distinct(rp.participantes_id_participante)) as total_acreditados, 
				p.id_tipo_participante
           	FROM acredRegistroParticipante rp INNER JOIN vParticipantes p
           		ON rp.participantes_id_participante = p.id_participante
           			AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
           			AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			WHERE ctrl_acceso = 0
				AND acceso = 1
            GROUP BY  p.id_tipo_participante
		</cfquery>
		<cfset s.ok=true>
		<cfset s.datos = local.qAcreditados>
		<cfreturn s>
		
	</cffunction>


	<cffunction name="generarAcredPorDiasYPart" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qAcredPorDiasYPart" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">     
        SELECT 
		    COUNT(distinct(p.id_participante)) AS acreditados_por_dia,
		    DATE_FORMAT(CONVERT_TZ(fecha,
		                            'Europe/Madrid',
		                            ZONAHORARIAEVENTO(#variables.instancia.id_evento#)),
		            '%d/%m/%Y') AS fecha,
		    id_tipo_participante
		FROM
		    acredRegistroParticipante rp
		        INNER JOIN
		    vParticipantes p ON rp.participantes_id_participante = p.id_participante
		        AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
		        AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
		WHERE ctrl_acceso = 0 
				AND acceso = 1
		        AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
		GROUP BY  id_tipo_participante, 2
		
		</cfquery>
		<cfset s.ok=true>
		<cfset s.datos = local.qAcredPorDiasYPart>
		<cfreturn s>
		
	</cffunction>	


	<cffunction name="generarAcredPorDias" access="public" returntype="struct" output="false">	
			<cfset var s = {}>
			
			<cfquery name="local.qAcredPorDias" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">     
	        SELECT 
			    COUNT(distinct(rp.participantes_id_participante)) AS acreditados_por_dia,
			    DATE_FORMAT(CONVERT_TZ(fecha,
			                            'Europe/Madrid',
			                            ZONAHORARIAEVENTO(#variables.instancia.id_evento#)),
			            '%d/%m/%Y') AS fecha
			FROM
			    acredRegistroParticipante rp
			WHERE ctrl_acceso = 0 
			    AND acceso = 1
			    AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			GROUP BY 2
			
			</cfquery>
			<cfset s.ok=true>
			<cfset s.datos = local.qAcredPorDias>
			<cfreturn s>
			
		</cffunction>	

	<cffunction name="generarNumInsitu" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qNumInsitu" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">	
			
			SELECT 
			            COUNT(distinct(id_participante)) AS NumInsitu, id_tipo_participante
			        FROM
			            vParticipantes p
			                INNER JOIN
			            acredRegistroParticipante rp ON rp.participantes_id_participante = id_participante
			        WHERE
			            ctrl_acceso = 0 AND acceso = 1
			                AND insitu = 1
			                AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			        group by id_tipo_participante
		</cfquery>
                           
		<cfset s.ok=true>
		<cfset s.datos = local.qNumInsitu>
		<cfreturn s>
	</cffunction>	
	
	
	
	
	<cffunction name="generarNumWeb" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qNumWeb" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">		
		 SELECT 
			            COUNT(distinct(id_participante)) AS NumWeb, id_tipo_participante
			        FROM
			            vParticipantes p
			                INNER JOIN
			            acredRegistroParticipante rp ON rp.participantes_id_participante = id_participante
			        WHERE
			            ctrl_acceso = 0 AND acceso = 1
			                AND p.insitu = 0
			                AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			        group by id_tipo_participante
		</cfquery>
	<cfset s.ok=true>
		<cfset s.datos = local.qNumWeb>
		<cfreturn s>
	</cffunction>	
		
	
	<cffunction name="generarTotalNumWeb" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qTotalNumWeb" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">		
			SELECT 
			            COUNT(distinct(p.id_participante)) AS TotalNumWeb
			        FROM
			            vParticipantes p
			                INNER JOIN
			            acredRegistroParticipante rp ON rp.participantes_id_participante = id_participante
			        WHERE
			            ctrl_acceso = 0 AND acceso = 1
			                AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND p.insitu = 0
					 
		</cfquery>
	<cfset s.ok=true>
		<cfset s.datos = local.qTotalNumWeb>
		<cfreturn s>
	</cffunction>	
		
		
		
	
	<cffunction name="generarTotalNumInsitu" access="public" returntype="struct" output="false">	
		<cfset var s = {}>
		
		<cfquery name="local.qTotalNumInsitu" datasource="#application.datasource#" cachedWithin="#createTimeSpan( 0, 0, 0, 30 )#">		
			SELECT 
			            COUNT(distinct(id_participante)) AS TotalNumInsitu
			        FROM
			            vParticipantes p
			                INNER JOIN
			            acredRegistroParticipante rp ON rp.participantes_id_participante = id_participante
			        WHERE
			            ctrl_acceso = 0 AND acceso = 1
			                AND p.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND rp.id_evento IN (<cfqueryparam value="#variables.instancia.id_evento#" cfsqltype="cf_sql_integer" list="true">)
			                AND p.insitu = 1
		</cfquery>
	<cfset s.ok=true>
		<cfset s.datos = local.qTotalNumInsitu>
		<cfreturn s>
	</cffunction>	
	
	
</cfcomponent>