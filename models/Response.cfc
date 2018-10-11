/**
* ********************************************************************************
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ********************************************************************************
* HTTP Response model, spice up as needed and stored in the request scope
*/
component accessors="true" {

	property name="format" 			type="string" 		default="json";
	property name="data" 			type="any"			default="";
	property name="error" 			type="boolean"		default="false";
	property name="binary" 			type="boolean"		default="false";
	property name="messages" 		type="array"		default="[]";
	property name="location" 		type="string"		default="";
	property name="jsonCallback" 	type="string"		default="";
	property name="jsonQueryFormat" type="string"		default="query";
	property name="contentType" 	type="string"		default="";
	property name="statusCode" 		type="numeric"		default="200";
	property name="statusText" 		type="string"		default="OK";
	property name="responsetime"	type="numeric"		default="0";
	property name="cachedResponse" 	type="boolean"		default="false";
	property name="headers" 		type="array"		default="[]";

	/**
	* Constructor
	*/
	Response function init(){

		// Init properties
		variables.format 			= "json";
		variables.data 				= {};
		variables.error 			= false;
		variables.binary 			= false;
		variables.messages 			= [];		
		variables.location 			= "";
		variables.jsonCallBack 		= "";
		variables.jsonQueryFormat 	= "query";
		variables.contentType 		= "";
		variables.statusCode 		= 200;
		variables.statusText 		= "OK";
		variables.responsetime		= 0;
		variables.cachedResponse 	= false;
		variables.headers 			= [];

		return this;
	}

	/**
	 * Add some messages
	 * @message Array or string of message to incorporate
	 */
	function addMessage(required any message){
		if(isSimpleValue(arguments.message)) { arguments.message = [ arguments.message ]; }
		variables.messages.addAll(arguments.message);
		return this;
		
	}

	/**
	 * Add a header
	 * @name The header name (e.g. "Content-Type")
	 * @value The header value (e.g. "application/json")
	 */
	function addHeader(required string name, required string value){
		arrayAppend(variables.headers, { name=arguments.name, value=arguments.value });
		return this;
	}

	/**
	 * @hint Returns a standard response formatted data packet
	 * @description Standard response
	 * @reset Reset the 'data' element of the original data packet
	 * @output false
	 */
	function getDataPacket(boolean reset=false) {
		try {
			variables.statusCode = javacast('int', variables.statusCode);
		} catch (any e) {}
		
		var packet = {
			"data"           = variables.data,
			"error"          = variables.error ? true : false,
			"messages"       = variables.messages,
			"statusCode"     = variables.statusCode,
			"statusText"     = variables.statusText			
		};

		if(isdefined("url.debug") && (cgi.REMOTE_ADDR is '89.7.89.193') || cgi.REMOTE_ADDR IS '192.168.1.199') {
			structAppend(packet, {
				"headers"        = variables.headers,
				"cachedResponse" = variables.cachedResponse,
				"responsetime"   = variables.responsetime,
			})
		}

		// Are we reseting the data packet
		if(arguments.reset){
			packet.data = {};
		}
		return packet;
	}
}