/**
 * EventosTokenService
 */
component accessors="true"{
	
	// Dependency Injection
    property name="dao" 		inject="model:security.EventosTokenDAO";
    property name="log" 		inject="logbox:logger:{this}";
    property name="populator"	inject="wirebox:populator";
    property name="wirebox"		inject="wirebox";

	/**
	 * Constructor
	 */
	EventosTokenService function init(){
		return this;
	}

	/**
	 * Obtiene y valida si el evento está registrado en la tabla apic_eventosToken por id_evento y 
	 * la contraseña que se le ha otorgado.
	 * 
	 * @idevento 
	 */
	any function get(required numeric idevento = 0){
		var query = dao.get(arguments.idevento);

        if(idevento EQ 0 OR query.recordcount EQ 0){
            return wirebox.getInstance("EventosToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("EventosToken"), query, 1);
	}
	
	/**
	 * Registra un nuevo evento en la tabla apic_eventosToken
	 * 
	 * @idevento 
	 * @password 
	 * @tokenexpiration 
	 */
	any function register(required numeric idevento, required string password, date tokenexpiration) {
		// TODO: mejorar registros
		dao.register();
	}

	/**
	 * Actualiza el registro token para un evento en concreto
	 * 
	 * @idevento 
	 * @token 
	 */
	any function updateToken(required numeric idevento, required string token){
		dao.updateToken(arguments.idevento, arguments.token);
	}

	/**
	 * Actualiza el registro password para un evento en concreto
	 * 
	 * @idevento 
	 * @password 
	 */
	any function updatePassword(required numeric idevento, required string password){
		dao.updatePassword(arguments.idevento, arguments.password);
	}

	/**
	 * Busca un EventoToken por su id y token, para corroborar su vigencia.
	 * 
	 * @idevento 
	 * @token
	 */
	any function byToken(required numeric idevento, required string token){ 
		var query =  dao.byToken(arguments.idevento, arguments.token);

		if(idevento EQ 0 OR query.recordcount EQ 0) {
            return wirebox.getInstance("EventosToken");
        }

        return populator.populateFromQuery(wirebox.getInstance("EventosToken"), query, 1);
	}	

	/**
	 * Obtener Contraseña
	 *
	 * @idevento 
	 * @password 
	 */
	any function getPassword(required numeric idevento=0, required string password=""){
		var query = dao.getPassword(arguments.idevento, arguments.password);

        if(idevento EQ 0 OR query.recordcount EQ 0){
            return wirebox.getInstance("EventosToken");
        }

		return populator.populateFromQuery(wirebox.getInstance("EventosToken"), query, 1);
	}

	/**
	 * Activar o desactivar contraseña
	 *
	 * @id 
	 */
	any function activateDesactivate(required numeric id) {
		return dao.activateDesactivate(id);
	}
}