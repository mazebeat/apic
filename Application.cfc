/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{
	// Application properties
	this.name                   = hash( getCurrentTemplatePath() );
	
	this.locale                 = 'es_ES';	
	this.timezone               = 'America/Madrid';
	
	this.invokeImplicitAccessor = true;
	
	this.sessionManagement      = true;
	this.sessionTimeout         = createTimeSpan(0,0,20,0);
	this.clientManagement       = true;
	this.clientStorage          = 'cookie';
	this.setClientCookies       = true;

	this.datasource             = "sige_up"; // sige_up | sige 
	
	this.secureJSON             = true;
	this.compression            = true;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = "";
	// MAPPING PATH
	this.mappings = {
		'/adminmodels' = getDirectoryFromPath(getCurrentTemplatePath()) & '../default/admin/model',
		'/adminutils'  = getDirectoryFromPath(getCurrentTemplatePath()) & '../default/admin/helpers'
	};

	// this.ormsettings.search.indexDir = getDirectoryFromPath(getCurrentTemplatePath()) & "/ormindex";

	if (structKeyExists(url, "killsession")) { this.sessionTimeout = createTimeSpan( 0, 0, 0, 1 ); }

	// application start
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();

		application.urlbase    = "http" & (cgi.server_port_secure EQ 1 ? 's' : '') & "://" & cgi.server_name;
		application.languages  = ["ES", "EN", "IT", "RS"];
		application.language   = 'ES';
		application.datasource = this.datasource;

		return true;
	}

	// application end
	public boolean function onApplicationEnd( struct appScope ){
		arguments.appScope.cbBootstrap.onApplicationEnd( arguments.appScope );
	}

	// request start
	public boolean function onRequestStart( string targetPage ){
		setting showdebugoutput = structkeyexists(url, "debug");

		if (structKeyExists( url, "killsession" )) {  this.sessioncookie.disableupdate = false; structClear(session); }
		if (structKeyExists(url, "reset")) { this.onApplicationStart();	}
		
		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );
		
		// CORS
		var pageCtx = getpagecontext().getresponse();
		pageCtx.setHeader('Access-Control-Allow-Origin', "*");
		pageCtx.setHeader('Access-Control-Allow-Headers', "Origin, X-Requested-With, Content-Type, Accept");
		pageCtx.setHeader('Access-Control-Allow-Methods', "GET, POST, PUT, DELETE, OPTIONS");
		pageCtx.setHeader('Access-Control-Allow-Credentials', "true");

		return true;
	}

	public void function onSessionStart() {  
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}
}