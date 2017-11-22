/**
* I am a new Model Object
*/
component accessors="true"{
	
	// Properties
	property name="dao" 		inject="model:cliente.Cliente";
    property name="log" 		inject="logbox:logger:{this}";
    property name="populator"	inject="wirebox:populator";
    property name="wirebox"		inject="wirebox";

	/**
	 * Constructor
	 */
	ClienteService function init(){
		
		return this;
	}
}