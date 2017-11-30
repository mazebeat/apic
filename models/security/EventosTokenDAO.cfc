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
        			.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER");
        
		return query.execute().getResult();
    }

	/**
	 * Registra un nuevo evento en la tabla apic_eventosToken
	 * @idevento 
	 * @password 
	 * @tokenexpiration 
	 */
	void function register(required numeric idevento) {
		transaction action="begin" {
			try {
				var queryS = "INSERT INTO apic_permisosToken (lectura, escritura, borrado) VALUES (1,1,1)";
				var query = new Query(datasource="#application.datasource#", sql="#queryS#");        

				var result = query.execute();

				queryS = "INSERT INTO apic_eventosToken (id_evento, password, id_permisosToken) 
				VALUES (:idevento, ' ', :idpermisos)";
				
				query = new Query(datasource="#application.datasource#", sql="#queryS#")
				.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER")
				.addParam(name="idpermisos", value=result.getPrefix().generatedKey, cfsqltype="CF_SQL_INTEGER");

				result = query.execute();
			
				transaction action="commit";
			} catch(any e) {
				transaction action="rollback";
			}
		}
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
					.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");
        
		query.execute();
	}

	/**
	 * Actualiza el password token para un evento en concreto
	 * @idevento 
	 * @password 
	 */
	void function updatePassword(required numeric idevento, required string password) {
		transaction action="begin" {
			try {
		
				var query = new Query(datasource="#application.datasource#", sql="SELECT id FROM apic_eventosToken WHERE id_evento = :idevento")
					.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER");

				var result = query.execute().getResult();

				if(result.recordCount EQ 0) {
					this.register(idevento);
				}
				
				var queryS = " UPDATE apic_eventosToken SET password = :password, fecha_baja = NULL 
							   WHERE id_evento = :idevento";

				var query = new Query(datasource="#application.datasource#", sql="#queryS#")
							.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER")
							.addParam(name="password", value=arguments.password, cfsqltype="CF_SQL_VARCHAR");
				
				query.execute();
				transaction action="commit";
			} catch(any e) {
				transaction action="rollback";
			}
		}
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
        			.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER")
					.addParam(name="token", value=arguments.token, cfsqltype="CF_SQL_LONGVARCHAR");

		return query.execute().getResult();
	}	

	query function getPassword(required numeric idevento) {
		var s = "SELECT id_evento, IFNULL(password, '') AS password, fecha_baja
				FROM apic_eventosToken 
				WHERE id_evento = :idevento";
		
		var query = new Query(datasource="#application.datasource#", sql="#s#")
        			.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER");
        
		return query.execute().getResult();
	}
	
	query function activateDesactivate(required numeric idevento) {
		var queryS = "UPDATE apic_eventosToken
					  SET fecha_baja = IF(fecha_baja IS NOT NULL, NULL, CURRENT_TIMESTAMP)
					  WHERE id_evento = :idevento";

		var query = new Query(datasource="#application.datasource#", sql="#queryS#")
		.addParam(name="idevento", value=arguments.idevento, cfsqltype="CF_SQL_INTEGER")
        
		query.execute().getResult();

		return this.get(idevento);					
	}
}