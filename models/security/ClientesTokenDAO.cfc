/**
 * ClientesTokenDAO
 */
component accessors="true" {

	// Dependency Injection
	property name="eventDao" inject="model:evento.EventoDAO";

	
	/**
	 * Constructor
	 */
	ClientesTokenDAO function init() {
		return this;
	}

	/**
	 * Obtiene todos los registros de la tabla apic_clientesToken
	 */
	query function getAll() {
        var query = new Query(datasource="#application.datasource#", sql="SELECT * FROM apic_clientesToken");
		
		return query.execute().getResult();
    }

	/**
	 * Obtiene y valida si el cliente está registrado en la tabla apic_clientesToken por id_cliente y 
	 * la contraseña que se le ha otorgado.
	 * @idcliente ID correspondiente al cliente 
	 */
    query function get(required numeric idcliente) {
		var queryS = "SELECT * 
					  FROM apic_clientesToken 
					  WHERE id_cliente = :idcliente";
        var query = new Query(datasource = "#application.datasource#", sql = "#queryS#").addParam(name = "idcliente", value = arguments.idcliente, cfsqltype = "CF_SQL_NUMERIC");
		var records = query.execute().getResult();
		var evento = eventDao.getByIdCliente(records.id_cliente);

		queryAddColumn(records, "id_evento", [evento.id_evento]);

		return records;
    }

	/**
	 * Registra un nuevo evento en la tabla apic_eventosToken
	 * @idevento 
	 * @password 
	 * @tokenexpiration 
	 */
	private query function register(required numeric idcliente, required string password) {
		var queryS = "INSERT INTO apic_clientesToken (id_cliente, password) 
					  VALUES ('1', PASSWORD(:password))";
		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="password", value=arguments.password, cfsqltype="CF_SQL_VARCHAR");
        
		return query.execute().getResult();
	}

	/**
	 * Actualiza el registro token para un cliente en concreto
	 * @idcliente 
	 * @token 
	 */
	void function updateToken(required numeric idcliente, required string token) {
		var queryS = "UPDATE apic_clientesToken 
					  SET token = :token, fecha_modificacion_token = CURRENT_TIMESTAMP 
					  WHERE id_cliente = :idcliente";
		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");
        
		query.execute().getResult();
	}

	/**
	 * Busca un ClienteToken por su id y token, para corroborar su vigencia.
	 * @idcliente 
	 * @token
	 */
	query function byToken(required numeric idcliente, required string token) {
		var queryS = "SELECT * 
					FROM apic_clientesToken 
					WHERE id_cliente = :idcliente
					AND token = :token
					LIMIT 1	";
		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_NUMERIC")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");

		return query.execute().getResult();
	}

}