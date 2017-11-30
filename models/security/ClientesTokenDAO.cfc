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
        var query = new Query(datasource = "#application.datasource#", sql = "#queryS#").addParam(name = "idcliente", value = arguments.idcliente, cfsqltype = "CF_SQL_INTEGER");
		var records = query.execute().getResult();

		if(records.recordCount GT 0) {
			var evento = eventDao.getByIdCliente(records.id_cliente);
			if(evento.recordCount GT 0) {
				queryDeleteColumn(records, 'id_evento');
				queryAddColumn(records, "id_evento", [evento.id_evento]);
				querySetCell(records, 'id_evento', evento);
			}
		}

		return records;
    }

	/**
	 * Registra un nuevo evento en la tabla apic_eventosToken
	 * @idevento 
	 * @password 
	 * @tokenexpiration 
	 */
	void function register(required numeric idcliente) {
		transaction action="begin" {
			try {
				var queryS = "INSERT INTO apic_permisosToken (lectura, escritura, borrado) VALUES (1,1,1)";
				var query = new Query(datasource="#application.datasource#", sql="#queryS#");        

				var result = query.execute();

				queryS = "INSERT INTO apic_clientesToken (id_cliente, password, id_permisosToken) 
				VALUES (:idcliente, ' ', :idpermisos)";
				
				query = new Query(datasource="#application.datasource#", sql="#queryS#")
				.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
				.addParam(name="idpermisos", value=result.getPrefix().generatedKey, cfsqltype="CF_SQL_INTEGER");

				result = query.execute();
			
				transaction action="commit";
			} catch(any e) {
				transaction action="rollback";
			}
		}
	}

	/**
	 * Actualiza el registro token para un cliente en concreto
	 * @idcliente 
	 * @token 
	 */
	void function updateToken(required numeric idcliente, required string token) {
		var queryS = "UPDATE apic_clientesToken 
					  SET token = :token, 
					  fecha_modificacion_token = CURRENT_TIMESTAMP 
					  WHERE id_cliente = :idcliente";
		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");
        
		query.execute();
	}

	/**
	 * Actualiza el registro token para un evento en concreto
	 * @idcliente 
	 * @password 
	 */
	void function updatePassword(required numeric idcliente, required string password) {
		transaction action="begin" {
			try {
		
				var query = new Query(datasource="#application.datasource#", sql="SELECT id FROM apic_clientesToken WHERE id_cliente = :idcliente")
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER");

				var result = query.execute().getResult();

				if(result.recordCount EQ 0) {
					this.register(idcliente);
				}
				
				var queryS = " UPDATE apic_clientesToken SET password = :password, fecha_baja = NULL 
							   WHERE id_cliente = :idcliente";

				var query = new Query(datasource="#application.datasource#", sql="#queryS#")
							.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
							.addParam(name="password", value=arguments.password, cfsqltype="CF_SQL_VARCHAR");
				
				query.execute();
				transaction action="commit";
			} catch(any e) {
				transaction action="rollback";
			}
		}
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
					.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");

		return query.execute().getResult();
	} 

	query function getPassword(required numeric idcliente) {
		var queryS = "SELECT id_cliente, IFNULL(password, '') as password, fecha_baja
					  FROM apic_clientesToken 
					  WHERE id_cliente = :idcliente";
        var query = new Query(datasource = "#application.datasource#", sql = "#queryS#").addParam(name = "idcliente", value = arguments.idcliente, cfsqltype = "CF_SQL_INTEGER");
		var records = query.execute().getResult();

		return records;
	}
	
	query function activateDesactivate(required numeric idcliente) {
		var queryS = "UPDATE apic_clientesToken
					  SET fecha_baja = IF(fecha_baja IS NOT NULL, NULL, CURRENT_TIMESTAMP)
					  WHERE id_cliente = :idcliente";

		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
		.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
		
		query.execute().getResult();					

		var queryS = "SELECT id_cliente, fecha_baja 
					  FROM apic_clientesToken 
					  WHERE id_cliente = :idcliente";

		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
		.addParam(name="idcliente", value=arguments.idcliente, cfsqltype="CF_SQL_INTEGER")
		
		return query.execute().getResult();					
	}
}