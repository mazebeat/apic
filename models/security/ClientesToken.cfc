/**
 * ClientesToken
 */
component accessors="true" extends="models.BaseModel" table="apic_clientesToken" {
	
	// Properties
	property name="id" 							ormtype="int"		column="id"	fieldtype="id"	generator="increment";
	property name="id_cliente" 					ormtype="int"		column="id_cliente";
	property name="id_evento";
	property name="password" 					ormtype="string"	column="password";
	property name="token" 						ormtype="text"		column="token";
	property name="token_expiration" 			ormtype="int"		column="token_expiration"			;
	property name="fecha_modificacion_token"	ormtype="timestamp"	column="fecha_modificacion_token" 	;
	property name="fecha_alta" 					ormtype="timestamp"	column="fecha_alta"					;
	property name="fecha_baja" 					ormtype="timestamp"	column="fecha_baja"					;
	property name="id_permisosToken" 			ormtype="int"		column="id_permisosToken";

	 property name="wirebox" inject="wirebox"  setter="false" getter="false";

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
	ClientesToken function init(){
		return this;
	}

	/**
	 * Obtener permisos por ID
	 *
	 * @id 
	 * @asQuery 
	 */
	public function permisosById(required number id, boolean asQuery = false) {
		// this.setId_permisosToken(wirebox.getInstance('PermisosTokenService').findByApiTokenById(id, asQuery));
		return wirebox.getInstance('PermisosTokenService').findByApiTokenById(id, asQuery);
	}

	/**
	 * Obtener permisos
	 *
	 * @asQuery 
	 */
	public function permisos(boolean asQuery = false) {
		if(!isnull(this.getId()) && isNumeric(this.getId_permisosToken())) {
			// this.setId_permisosToken(wirebox.getInstance('PermisosTokenService').findByApiToken(this, asQuery));
			return wirebox.getInstance('PermisosTokenService').findByApiToken(this, asQuery);
		}

		return this.getId_permisosToken();
	}

} 	