/**
 * EventosTokenDAO
 */
component output="false" accessors="true" extends="models.BaseModel" table="apic_eventosToken" {
	
	// Properties
	property name="id" 							ormtype="int"			column="id"	fieldtype="id" generator="increment";						;
	property name="id_evento" 					ormtype="int"		 	column="id_evento";
	property name="password" 					ormtype="string"	 	column="password";
	property name="token" 						ormtype="text"		 	column="token";
	property name="token_expiration" 			ormtype="int"			column="token_expiration";
	property name="fecha_modificacion_token"	ormtype="timestamp"		column="fecha_modificacion_token";
	property name="fecha_alta" 					ormtype="timestamp"		column="fecha_alta";
	property name="fecha_baja" 					ormtype="timestamp"		column="fecha_baja";
	property name="id_permisosToken" 			ormtype="int"			column="id_permisosToken";

	property name="wirebox"	inject="wirebox";
	
	/**
	 * Validation
	 */
	this.constraints = {
		id_cliente = {required = true},
		password   = {required = true},
    };

	/**
	 * Constructor
	 */
	EventosToken function init(){
		return this;
	}

	/**
	 * Obtener Permisos
	 */
	public function permisosById(required number id, boolean asQuery = false) {
		// this.setId_permisosToken(wirebox.getInstance('PermisosTokenService').findByApiTokenById(id, asQuery));
		return wirebox.getInstance('PermisosTokenService').findByApiTokenById(id, asQuery);
	}

	public function permisos(boolean asQuery = false) {
		if(!isnull(this.getId()) && isNumeric(this.getId_permisosToken())) {
			// this.setId_permisosToken(wirebox.getInstance('PermisosTokenService').findByApiToken(this, asQuery));
			return wirebox.getInstance('PermisosTokenService').findByApiToken(this, asQuery);
		} 

		// return this.getId_permisosToken();
	}
}