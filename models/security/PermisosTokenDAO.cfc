/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	

	/**
	 * Constructor
	 */
	PermisosTokenDAO function init(){
		
		return this;
	}
	
	query function get(required numeric id) {
		var s = "SELECT * FROM apic_permisosToken WHERE id = :id";
		
		var query = new Query(datasource="#application.datasource#", sql="#s#")
							.addParam(name="id", value=arguments.id, cfsqltype="CF_SQL_INTEGER");
        
		return query.execute().getResult();
	}

	query function permisosById(required numeric id, boolean isevent = false) {
		var s = "SELECT * FROM apic_permisosToken WHERE id = :id";
		
		var query = new Query(datasource="#application.datasource#", sql="#s#")
							.addParam(name="id", value=arguments.id, cfsqltype="CF_SQL_INTEGER");
        
		return query.execute().getResult();
	}

	any function updateModel(required PermisosToken pt) {
		try {
			var s = "UPDATE apic_permisosToken SET lectura= :lectura, escritura = :escritura, borrado = :borrado WHERE id = :id";
			var query = new Query(datasource="#application.datasource#", sql="#s#")
							.addParam(name="lectura", value=arguments.pt.lectura, cfsqltype="CF_SQL_TINYINT")
							.addParam(name="escritura", value=arguments.pt.escritura, cfsqltype="CF_SQL_TINYINT")
							.addParam(name="borrado", value=arguments.pt.borrado, cfsqltype="CF_SQL_TINYINT")
							.addParam(name="id", value=arguments.pt.id, cfsqltype="CF_SQL_INTEGER");
			query.execute();				
		} catch(Any e){
			throw(e);
		}
	}
}