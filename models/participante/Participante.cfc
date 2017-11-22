<!--
  Participante
 -->
<cfcomponent output="false" accessors="true" extends="models.BaseModel" hint="Participante Model">
	<cftimer label= "models/Participante"></cftimer>

	<!--- Proper=ties --->
	<cfproperty name="id_participante"				column="id_participante"				ormType="int"		fieldtype="id">
	<cfproperty name="login"						column="login"							ormType="string">
	<cfproperty name="password"						column="password"						ormType="string">
	<cfproperty name="fecha_alta"					column="fecha_alta"						ormType="timestamp">
	<cfproperty name="fecha_alta_sort"				column="fecha_alta_sort"				ormType="timestamp">
	<cfproperty name="fecha_modif"					column="fecha_modif"					ormType="timestamp">
	<cfproperty name="fecha_modif_sort"				column="fecha_modif_sort"				ormType="timestamp">
	<cfproperty name="observaciones"				column="observaciones"					ormType="text">
	<cfproperty name="id_formulario"				column="id_formulario"					ormType="int">
	<cfproperty name="id_tipo_participante"			column="id_tipo_participante"			ormType="int">
	<cfproperty name="id_evento"					column="id_evento"						ormType="int">
	<cfproperty name="nombre"						column="nombre"							ormType="string">
	<cfproperty name="apellidos"					column="apellidos"						ormType="string">
	<cfproperty name="email_participante"			column="email_participante"				ormType="string">
	<cfproperty name="nombre_empresa"				column="nombre_empresa"					ormType="string">
	<cfproperty name="activo"						column="activo"							ormType="boolean">
	<cfproperty name="id_sala"						column="id_sala"						ormType="int">
	<cfproperty name="importado"					column="importado" 						ormType="boolean">
	<cfproperty name="inscrito"						column="inscrito" 						ormType="boolean">
	<cfproperty name="total_a_pagar"				column="total_a_pagar"					ormType="double">
	<cfproperty name="id_idioma"					column="id_idioma"						ormType="string">
	<cfproperty name="insitu"						column="insitu"							ormType="boolean">
	<cfproperty name="activo_en_reuniones"			column="activo_en_reuniones"			ormType="boolean">
	<cfproperty name="activo_en_actividades"		column="activo_en_actividades"			ormType="boolean">
	<cfproperty name="reservado_tfda"				column="reservado_tfda"					ormType="boolean">
	<cfproperty name="id_usuario_alta"				column="id_usuario_alta"				ormType="int">
	<cfproperty name="id_usuario_baja"				column="id_usuario_baja"				ormType="int">
	<cfproperty name="id_usuario_modif"				column="id_usuario_modif"				ormType="int">
	<cfproperty name="fecha_alta_orig"				column="fecha_alta_orig"				ormType="timestamp">
	<cfproperty name="fecha_modif_orig"				column="fecha_modif_orig"				ormType="timestamp">
	<cfproperty name="func_nombre_participante"		column="func_nombre_participante"		ormType="string">
	<cfproperty name="func_apellidos_participante"	column="func_apellidos_participante"	ormType="string">
	<cfproperty name="func_email_participante"		column="func_email_participante"		ormType="string">
	<cfproperty name="baja_newsletter"				column="baja_newsletter"				ormType="boolean">
	<cfproperty name="participantePadre"			column="participantePadre"				ormType="int">
	<cfproperty name="doble_opt_in"					column="doble_opt_in"					ormType="int">
	<cfproperty name="last_login"					column="last_login"						ormType="timestamp">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cffunction name="init" access="public" returntype="Participante" output="false" hint="constructor">
		<cfscript>	
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->


</cfcomponent>