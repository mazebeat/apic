/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
*/
component{
	// Application properties
	this.name              = hash( getCurrentTemplatePath() );
	this.sessionManagement = true;
	this.sessionTimeout    = createTimeSpan(0,0,20,0);
	this.setClientCookies  = true;

	// COLDBOX STATIC PROPERTY, DO NOT CHANGE UNLESS THIS IS NOT THE ROOT OF YOUR COLDBOX APP
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath( getCurrentTemplatePath() );
	// The web server mapping to this application. Used for remote purposes or static purposes
	COLDBOX_APP_MAPPING   = "";
	// COLDBOX PROPERTIES
	COLDBOX_CONFIG_FILE   = "";
	// COLDBOX APPLICATION KEY OVERRIDE
	COLDBOX_APP_KEY       = "";

	this.mappings = {
		'/adminmodels' = getDirectoryFromPath(getCurrentTemplatePath()) & '../default/admin/model',
		'/adminutils'  = getDirectoryFromPath(getCurrentTemplatePath()) & '../default/admin/helpers'
	};
	this.datasource  = "sige";

	// this.ormsettings.search.indexDir = getDirectoryFromPath(getCurrentTemplatePath()) & "/ormindex";

	// application start
	public boolean function onApplicationStart(){
		application.cbBootstrap = new coldbox.system.Bootstrap( COLDBOX_CONFIG_FILE, COLDBOX_APP_ROOT_PATH, COLDBOX_APP_KEY, COLDBOX_APP_MAPPING );
		application.cbBootstrap.loadColdbox();

		application.urlbase    = "http" & (cgi.HTTPS EQ 'Yes' ? 's' : '') & "://" & cgi.server_name;
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

		// Process ColdBox Request
		application.cbBootstrap.onRequestStart( arguments.targetPage );

		var pageCtx = getpagecontext().getresponse();
		pageCtx.setHeader('Access-Control-Allow-Origin', "*");
		pageCtx.setHeader('Access-Control-Allow-Headers', "Origin, X-Requested-With, Content-Type, Accept");
		pageCtx.setHeader('Access-Control-Allow-Methods', "GET, POST, PUT, DELETE, OPTIONS");
		pageCtx.setHeader('Access-Control-Allow-Credentials', "true");
		
		return true;
	}

	public void function onSessionStart(){
		if(isdefined("url.debug")) {
			writeDump(var="#session#", label="session");
			abort;
		}
		application.cbBootStrap.onSessionStart();
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ){
		arguments.appScope.cbBootStrap.onSessionEnd( argumentCollection=arguments );
	}

	public boolean function onMissingTemplate( template ){
		return application.cbBootstrap.onMissingTemplate( argumentCollection=arguments );
	}
}