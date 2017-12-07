/**
 * ClientesTokenService
 */
component accessors="true"{
	
	// Dependency Injection
    property name="dao" 		inject="model:security.ClientesTokenDAO";
    property name="log" 		inject="logbox:logger:{this}";
    property name="populator"	inject="wirebox:populator";
    property name="wirebox"		inject="wirebox";

	/**
	 * Constructor
	 */
	ClientesTokenService function init(){
		return this;
	}

	/**
	 * Get
	 */
	any function get(required numeric idcliente = 0) {
		var query = dao.get(arguments.idcliente);

        if(idcliente EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("ClientesToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("ClientesToken"), query, 1);
	}

	/**
	 * Validate
	 */
	any function validate(required numeric idcliente = 0, required string password) {
		var query = dao.validate(idcliente, password);

        if(idcliente EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("ClientesToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("ClientesToken"), query, 1);
	}

	/**
	 * Registra un nuevo evento en la tabla apic_clientesToken
	 * @idcliente 
	 * @password 
	 * @tokenexpiration 
	 */
	any function register(required numeric idcliente, required string password, date tokenexpiration) {
		// TODO: mejorar registros
		dao.register();
	}

	/**
	 * Actualiza el registro token para un cliente en concreto
	 * @idcliente 
	 * @token 
	 */
	any function updateToken(required numeric idcliente, required string token){
		dao.updateToken(arguments.idcliente, arguments.token);
	}

	/**
	 * Actualiza el registro password para un evento en concreto
	 * @idcliente 
	 * @password 
	 */
	any function updatePassword(required numeric idcliente, required string password){
		dao.updatePassword(arguments.idcliente, arguments.password);
	}

	/**
	 * Busca un ClienteToken por su id y token, para corroborar su vigencia.
	 * @idcliente 
	 * @token
	 */
	any function byToken(required numeric idcliente, required string token){ 
		var query =  dao.byToken(arguments.idcliente, arguments.token);

		if(idcliente EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("ClientesToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("ClientesToken"), query, 1);
	}	
	
	/**
	* getPassword
	*/
	any function getPassword(required numeric idcliente=0) {
		var query = dao.getPassword(arguments.idcliente);
		
        if(idcliente EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("ClientesToken");
		}
		
		return populator.populateFromQuery(wirebox.getInstance("ClientesToken"), query, 1);
	}

	any function activateDesactivate(required numeric idcliente) {
		var query = dao.activateDesactivate(arguments.idcliente);

        if(idcliente EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("ClientesToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("ClientesToken"), query, 1);
	}
}