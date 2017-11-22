/**
 * EventosTokenDAO
 */
component accessors="true"  extends="models.BaseModel" {
	
	// Properties
	property name="id" 							ormtype="int"			column="id"							hint="ID Registro" fieldtype="id"  generator="native" ;
	property name="id_evento" 					ormtype="int"		 	column="id_evento"					hint="ID Cliente asociado";
	property name="password" 					ormtype="string"	 	column="password"					hint="Contraseña para corroborar existencia cliente y solicitud token";
	property name="token" 						ormtype="text"		 	column="token"						hint="Token del cliente para realizar acciones en la APIc";
	property name="token_expiration" 			ormtype="int"			column="token_expiration"			hint="Cantidad de minutos en los que expira el token";
	property name="fecha_modificacion_token"	ormtype="timestamp"		column="fecha_modificacion_token" 	hint="Fecha de la última actualización del token";
	property name="fecha_alta" 					ormtype="timestamp"		column="fecha_alta"					hint="";
	property name="fecha_baja" 					ormtype="timestamp"		column="fecha_baja"					hint="";
	
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
}