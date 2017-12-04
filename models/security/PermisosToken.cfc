/**
* I am a new Model Object
*/
component output="false" peristent="true" accessors="true" table="apic_permisosToken" joincolumn="id_apitoken" {
	
	// Properties
	property name="id"			ormtype="int"		column="id"	fieldtype="id"	generator="increment";
	property name="lectura"		ormtype="boolean"	type="boolean" column="lectura";
	property name="escritura"	ormtype="boolean"	type="boolean" column="escritura";
	property name="borrado"		ormtype="boolean"	type="boolean" column="borrado";
	property name="fecha_alta"	ormtype="timestamp"	column="fecha_alta";
	property name="fecha_baja"	ormtype="timestamp"	column="fecha_baja";

	property name="wirebox"	inject="wirebox" setter="false" getter="false";
	

	/**
	 * Constructor
	 */
	PermisosToken function init(){
		return this;
	}

	any function updateModel() {
		return wirebox.getInstance('PermisosTokenService').updateModel(this);
	}
}