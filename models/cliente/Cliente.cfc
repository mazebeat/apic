/**
* I am a new Model Object
*/
component accessors="true" table="vClientesActivos" persistent="true" {
	
	// Properties
	property name="id_cliente" 			ormType="integer"	column="id_cliente"	fieldtype="id"  generator="native"	setter="true";
	property name="nombre" 				ormType="string"	fieldtype="column";
	property name="fecha_alta" 			ormType="timestamp"	fieldtype="timestamp";
	property name="fecha_baja" 			ormType="timestamp"	fieldtype="timestamp";
	property name="fecha_modif" 		ormType="timestamp"	fieldtype="timestamp";
	property name="activo" 				ormType="boolean"	fieldtype="column";
	property name="agencias_id_agencia" ormType="string"	fieldtype="column";
	

	/**
	 * Constructor
	 */
	Cliente function init(){
		
		return this;
	}
	

} 	