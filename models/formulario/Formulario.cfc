<cfcomponent hint="I am a new Model Object" output="false" accessors="true">

	<!--- Properties --->
	<cfproperty name="id_formulario" type="string">	<cfproperty name="id_evento" type="string">	<cfproperty name="id_tipo_participante" type="string">	<cfproperty name="titulo" type="string">	<cfproperty name="descripcion" type="string">	<cfproperty name="pie" type="string">	<cfproperty name="id_idioma" type="string">	<cfproperty name="necesitaValidacion" type="string">	<cfproperty name="multiples_inscripciones" type="string">	<cfproperty name="tipo_multiples_inscripciones" type="string">	<cfproperty name="linkedin" type="string">	<cfproperty name="id_app_linkedin" type="string">	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Formulario" output="false" hint="constructor">
		<cfscript>
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->


</cfcomponent>