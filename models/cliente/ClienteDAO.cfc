/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	property name="flash" inject="coldbox:flash";

	/**
	 * Constructor
	 */
	ClienteDAO function init(){
		
		return this;
	}

	Cliente function obtainClient() {
		var clientSession = {};

		if(StructKeyExists(session, 'clientSession')) {
			clientSession = session.clientSession;
		}

	}
}