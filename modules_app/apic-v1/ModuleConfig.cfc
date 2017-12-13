<cfcomponent output="false" hint="My Module Configuration">
<cfscript>
/**
Module Directives as public properties
this.title 				= "Title of the module";
this.author 			= "Author of the module";
this.webURL 			= "Web URL for docs purposes";
this.description 		= "Module description";
this.version 			= "Module Version";
this.viewParentLookup   = (true) [boolean] (Optional) // If true, checks for views in the parent first, then it the module.If false, then modules first, then parent.
this.layoutParentLookup = (true) [boolean] (Optional) // If true, checks for layouts in the parent first, then it the module.If false, then modules first, then parent.
this.entryPoint  		= "" (Optional) // If set, this is the default event (ex:forgebox:manager.index) or default route (/forgebox) the framework
									       will use to create an entry link to the module. Similar to a default event.
this.cfmapping			= "The CF mapping to create";
this.modelNamespace		= "The namespace to use for registered models, if blank it uses the name of the module."
this.dependencies 		= "The array of dependencies for this module"

structures to create for configuration
- parentSettings : struct (will append and override parent)
- settings : struct
- datasources : struct (will append and override parent)
- interceptorSettings : struct of the following keys ATM
	- customInterceptionPoints : string list of custom interception points
- interceptors : array
- layoutSettings : struct (will allow to define a defaultLayout for the module)
- routes : array Allowed keys are same as the addRoute() method of the SES interceptor.
- wirebox : The wirebox DSL to load and use

Available objects in variable scope
- controller
- appMapping (application mapping)
- moduleMapping (include,cf path)
- modulePath (absolute path)
- log (A pre-configured logBox logger object for this object)
- binder (The wirebox configuration binder)
- wirebox (The wirebox injector)

Required Methods
- configure() : The method ColdBox calls to configure the module.

Optional Methods
- onLoad() 		: If found, it is fired once the module is fully loaded
- onUnload() 	: If found, it is fired once the module is unloaded

*/

	// Module Properties
	this.title 				= "apic-v1";
	this.author 			= "Tufabricadeventos.com";
	this.webURL 			= "http://www.tufabricadeventos.com/";
	this.description 		= "APIc para consumo de clientes";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "apic/v1";
	// Model Namespace
	this.modelNamespace		= "apic-v1";
	// CF Mapping
	this.cfmapping			= "apic-v1";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	function configure(){

		// parent settings
		parentSettings = {
		};

		// module settings - stored in modules.name.settings
		settings = {
		};

		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};

		// datasources
		datasources = {
		};

		// SES Routes
		routes = [			
			// Documentation
			{ pattern="/:lang-alpha/doc", handler="home", action="doc", noLayout=true },

			// Participantes
			{ pattern="/:lang-alpha/:token/participantes/page/:page-numeric/rows/:rows-numeric?", handler="Participantes", action="index" },
			{ pattern="/:lang-alpha/:token/participantes/page/:page-numeric?", handler="Participantes", action="index" },

			// -> By ID
			{ pattern="/:lang-alpha/:token/participantes/:id_participante-numeric/page/:page-numeric/rows/:rows-numeric?", handler="Participantes", action={ GET="get", HEAD="info" } },
			{ pattern="/:lang-alpha/:token/participantes/:id_participante-numeric/page/:page-numeric/", handler="Participantes", handler="Participantes", action={ GET="get", HEAD="info" } },
			{ pattern="/:lang-alpha/:token/participantes/:id_participante-numeric", handler="Participantes", action={ GET="get", HEAD="info" } },

			// -> By Tipo			<!---  --->
			{ pattern="/:lang-alpha/:token/participantes/:tipo_participante/page/:page-numeric/rows/:rows-numeric?", handler="Participantes", action="byType", contraints={ tipo_participante="(/([\w])\w+/+g)", token="(([(\w|\d)\.\-\\])\w+/g)" } },
			{ pattern="/:lang-alpha/:token/participantes/:tipo_participante/page/:page-numeric/", handler="Participantes", action="byType", contraints={ tipo_participante="(/([\w])\w+/+g)", token="(([(\w|\d)\.\-\\])\w+/g)" } },
			{ pattern="/:lang-alpha/:token/participantes/:tipo_participante", handler="Participantes", action="byType", contraints={ tipo_participante="(/([\w])\w+/+g)", token="(([(\w|\d)\.\-\\])\w+/g)" } },

			// -> All		
			{ pattern="/:lang-alpha/:token/participantes", handler="Participantes", action={ GET="index", POST="create" } },

			// Tipo de Participantes
			{ pattern="/:lang-alpha/:token/tiposparticipantes/:id_tipo_participante-numeric", handler="TiposParticipantes", action="get" },
			{ pattern="/:lang-alpha/:token/tiposparticipantes", handler="TiposParticipantes", action="index" },
					
			// Eventos
			{ pattern="/:lang-alpha/:token/eventos", handler="Eventos", action="index" },

			// Formularios
			{ pattern="/:lang-alpha/:token/formularios/meta", handler="Formularios", action="meta" },
			// { pattern="/:lang-alpha/:token/formularios/tipoparticipante/:id_tipo_participante-numeric", handler="Formularios", action="getByTipoParticipante" },
			{ pattern="/:lang-alpha/:token/formularios/:id_formulario-numeric", handler="Formularios", action="get" },
			{ pattern="/:lang-alpha/:token/formularios", handler="Formularios", action="index" },

			// Module Entry Point
			{ pattern="/:lang-alpha/:token?", handler="home", action="index" },
			
			// Convention Route
			{ pattern="/:lang-alpha/:token?/:handler/:action?" }
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
		];

		// Binder Mappings
		// binder.map("Alias").to("#moduleMapping#.model.MyService");
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

</cfscript>
</cfcomponent>