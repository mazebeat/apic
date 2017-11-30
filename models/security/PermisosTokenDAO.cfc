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
}