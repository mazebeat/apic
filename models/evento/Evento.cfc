/**
* I am a new Model Object
*/
component accessors="true" table="vEventos" persistent="true" {
	
	// Primary Key
	property name="id_evento"	fieldtype="id"	column="id_evento"	generator="native"	setter="true";

	// Properties
	property name="nombre" 		ormType="string";
	property name="clientes_id_cliente" persistent="true" fieldtype="one-to-many" cfc="Cliente" fkcolumn="clientes_id_cliente" fetch="join" notnull="true" cascade="all";
<!--- 	property name="fecha_alta" 					type="date"		ormType="timestamp"		fieldtype="timestamp";
	property name="fecha_caducidad" 			type="date"		ormType="timestamp"		fieldtype="timestamp";
	property name="fecha_modif" 				type="date"		ormType="timestamp"		fieldtype="timestamp"; --->
	property name="activo"			ormType="boolean";
	property name="id_tipo_evento" 	ormType="int";
	property name="texto_ES" 		ormType="string";
	property name="texto_EN" 		ormType="string";
	property name="id_gestor" 		ormType="int";
	

	/**
	 * Constructor
	 */
	Evento function init(){
		
		return this;
	}
}