/**
 * EventosTokenDAO
 */
component accessors="true" {

	// Dependency Injection
	
	/**
	 * Constructor
	 */
	EventosTokenDAO function init() {
		return this;
	}

	/**
	 * Obtiene todos los registros de la tabla apic_eventosToken
	 */
	query function getAll() {
        var query = new Query(datasource="#application.datasource#", sql="SELECT * FROM apic_eventosToken");
        
		return query.execute().getResult();
    }

	/**
	 * Obtiene y valida si el evento está registrado en la tabla apic_eventosToken por id_evento y 
	 * la contraseña que se le ha otorgado.
	 * @idevento ID correspondiente al evento 
	 */
    query function get(required numeric idevento) {
		var s = "SELECT * 
				FROM apic_eventosToken 
				WHERE id_evento = :idevento";
        var query = new Query(datasource="#application.datasource#", sql="#s#")
        			.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_NUMERIC");
        
		return query.execute().getResult();
    }

	/**
	 * Registra un nuevo evento en la tabla apic_eventosToken
	 * @idevento 
	 * @password 
	 * @tokenexpiration 
	 */
	void function register(required numeric idevento, required string password) {
		var s = "INSERT INTO apic_eventosToken (id_evento, password) 
				VALUES ('1', PASSWORD(:password))";
		var query = new Query(datasource="#application.datasource#", sql="#s#")
					.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="password", value=arguments.password, cfsqltype="CF_SQL_VARCHAR");
        
		query.execute().getResult();
	}

	/**
	 * Actualiza el registro token para un evento en concreto
	 * @idevento 
	 * @token 
	 */
	void function updateToken(required numeric idevento, required string token) {
		var s = "UPDATE apic_eventosToken 
				SET token = :token, 
				fecha_modificacion_token = CURRENT_TIMESTAMP 
				WHERE id_evento = :idevento";
		var query = new Query(datasource="#application.datasource#", sql="#s#")
					.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");
        
		query.execute().getResult();
	}

	/**
	 * Busca un EventoToken por su id y token, para corroborar su vigencia.
	 * @idevento 
	 * @token
	 */
	query function byToken(required numeric idevento, required string token){ 
		var s = "SELECT * 
				FROM apic_eventosToken 
				WHERE id_evento = :idevento
				AND token = :token
				LIMIT 1";
        var query = new Query(datasource="#application.datasource#", sql="#s#")
        			.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");

		return query.execute().getResult();
	}	
}