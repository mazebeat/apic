/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	property name="dao"			inject="PermisosTokenDAO";
	property name="wirebox"		inject="wirebox";
	property name="populator"	inject="wirebox:populator";
	

	/**
	 * Constructor
	 */
	PermisosTokenService function init(){
		return this;
	}
	
	any function findByApiToken(required any model, boolean asQuery = false) {
		return this.get(model.id_permisosToken, asQuery);
	}

	any function get(required numeric id, boolean asQuery = false) {
		var q = dao.get(id);

		if (asQuery) { return q; } 

		return populator.populateFromQuery(wirebox.getInstance("PermisosToken"), q, 1);
	}
}