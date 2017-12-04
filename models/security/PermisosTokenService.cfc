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

	any function findByApiTokenById(required number id_permisosToken, boolean asQuery = false) {
		return this.get(id_permisosToken, asQuery);
	}

	any function get(required numeric id, boolean asQuery = false) {
		var q = dao.get(id);

		if (asQuery) { return q; } 

		return populator.populateFromQuery(wirebox.getInstance("PermisosToken"), q, 1);
	}

	void function update(required numeric id, ) {
		dao.update
	} 

	any function updateModel(required PermisosToken pt) {
		return dao.updateModel(pt);
	}
}