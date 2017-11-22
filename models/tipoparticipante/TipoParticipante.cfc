<!--
	Tipo de Participante
 -->
<cfcomponent hint="Tipo de Participante Model" output="false" accessors="true" extends="models.BaseModel">
	<cftimer label= "models/tipoparticipante/TipoParticipante"></cftimer>
	<!--- Properties --->
	<cfproperty name="id_tipo_participante"	column="id_tipo_participante" 	ormType="int"		fieldtype="id"	generator="native"	required="true">
	<cfproperty name="nombre"				column="nombre" 				ormType="string"	required="true">
	<cfproperty name="codigo" 				column="codigo" 				ormType="string"	required="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" returntype="TipoParticipante" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

</cfcomponent>