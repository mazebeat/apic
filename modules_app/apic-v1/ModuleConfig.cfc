<cfcomponent output="false" hint="My Module Configuration">
	<cfscript>
		// Module Properties
		this.title 				= "apic-v1";
		this.author 			= "IBEVENTS";
		this.webURL 			= "https://www.tufabricadeventos.com/";
		this.description 		= "APIc para consumo de clientes";
		this.version			= "1.0.2";
		// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
		this.viewParentLookup 	= false;
		// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
		this.layoutParentLookup = false;
		// Module Entry Point
		this.entryPoint			= "apic/v1";
		// Model Namespace
		this.modelNamespace		= "apic-v1";
		// CF Mapping
		this.cfmapping			= "apic-v1";
		// Auto-map models
		this.autoMapModels		= false;
		// Module Dependencies
		this.dependencies 		= [];

		function configure(){

			// parent settings
			parentSettings = {};

			// module settings - stored in modules.name.settings
			settings = {};

			// Layout Settings
			layoutSettings = {
				defaultLayout = ""
			};

			// datasources
			datasources = {};

			// SES Routes
			routes = [	
				// Documentation
				{ 
					pattern="/:lang-alpha/doc", 
					handler="home", 
					action="doc", 
					noLayout=true 
				},

				// Agenda
				{ 
					pattern="/:lang-alpha/:token/agenda/:id_participante-numeric", 
					handler="Agenda", 
					action={ GET="get" } 
				},
				{ 
					pattern="/:lang-alpha/:token/agenda", 
					handler="Agenda", 
					action={ GET="index" } 
				},

				// Products
				{ 
					pattern="/:lang-alpha/:token/productos/seleccionados/:id_participante-numeric", 
					handler="Productos", 
					action={ GET="byParticipante" } 
				},
				{ 
					pattern="/:lang-alpha/:token/productos/seleccionados", 
					handler="Productos", 
					action={ GET="allSelected" } 
				},
				{ 
					pattern="/:lang-alpha/:token/productos/:id_producto-numeric", 
					handler="Productos", 
					action={ GET="get" } 
				},
				{ 
					pattern="/:lang-alpha/:token/productos", 
					handler="Productos", 
					action={ GET="index" } 
				},

				// Activities
				{ 
					pattern="/:lang-alpha/:token/actividades/:id_participante-numeric", 
					handler="Actividades", 
					action={ GET="byParticipante" } 
				},
				{ 
					pattern="/:lang-alpha/:token/actividades", 
					handler="Actividades", 
					action={ GET="index" } 
				},

				// Meetings
				{ 
					pattern="/:lang-alpha/:token/reuniones/:id_participante-numeric", 
					handler="Reuniones", 
					action={ GET="get" } 
				},
				{ 
					pattern="/:lang-alpha/:token/reuniones", 
					handler="Reuniones", 
					action={ GET="all" } 
				},

				// Statics
				{ 
					pattern="/:lang-alpha/:token/estadisticas", 
					handler="Estadisticas", 
					action={ GET="index" } 
				},

				// Participantes
			

				// -> By ID
				{ 
					pattern="/:lang-alpha/:token/participantes/:id_participante-numeric/page/:page-numeric/rows/:rows-numeric", 
					handler="Participantes", 
					action={ GET="get", HEAD="info" } 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:id_participante-numeric/page/:page-numeric/", 
					handler="Participantes", 
					action={ GET="get", HEAD="info" } 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:id_participante-numeric", 
					handler="Participantes", 
					action={ GET="get", HEAD="info" } 
				},


				// -> By Tipo
				{ 
					pattern="/:lang-alpha/:token/participantes/:tipo_participante-regex:([-_a-zA-Z]+)/page/:page-numeric/rows/:rows-numeric", 
					handler="Participantes", 
					action="byType",
					contraints= { 
						tipo_participante= { 
							required: true,
							regex: "(^([a-zA-Z]+\-?)*$)"
						} 
					} 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:tipo_participante-regex:([-_a-zA-Z]+)/page/:page-numeric/", 
					handler="Participantes", 
					action="byType", 
					contraints= { 
						tipo_participante= { 
							required: true,
							regex: "(^([a-zA-Z]+\-?)*$)"
						} 
					} 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:tipo_participante-regex:([-_a-zA-Z]+)", 
					handler="Participantes", 
					action="byType", 
					contraints= { 
						tipo_participante= { 
							required: true,
							regex: "(^([a-zA-Z]+\-?)*$)"
						} 
					} 
				},

				// -> By Email
				{ 
					pattern="/:lang-alpha/:token/participantes/:email-regex:([a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3})/page/:page-numeric/rows/:rows-numeric", 
					handler="Participantes", 
					action="byEmail", 
					contraints= { 
						email= { 
							required: true, 
							type: "email", 
							regex:"(^[\w!##$%&'*+/=?`{|}~^-]+(?:\.[\w!##$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$)"
						} 
					} 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:email-regex:([a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3})/page/:page-numeric/", 
					handler="Participantes", 
					action="byEmail", 
					contraints= { 
						email= { 
							required: true, 
							type: "email", 
							regex:"(^[\w!##$%&'*+/=?`{|}~^-]+(?:\.[\w!##$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$)"
						} 
					} 
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/:email-regex:([a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3})", 
					handler="Participantes", 
					action="byEmail", 
					contraints= { 
						email= { 
							required: true, 
							type: "email", 
							regex:"(^[\w!##$%&'*+/=?`{|}~^-]+(?:\.[\w!##$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}$)"
						} 
					} 
				},

				// -> All		
				{ 
					pattern="/:lang-alpha/:token/participantes/page/:page-numeric/rows/:rows-numeric", 
					handler="Participantes", 
					action="index"
				},
				{ 
					pattern="/:lang-alpha/:token/participantes/page/:page-numeric?", 
					handler="Participantes", 
					action="index" 
				},
				{ 
					
					pattern="/:lang-alpha/:token/participantes", 
					handler="Participantes", 
					action={ GET="index", POST="create", PUT="modify" } 
				},

				// Tipo de Participantes
				{ 
					pattern="/:lang-alpha/:token/tiposparticipantes/:id_tipo_participante-numeric", 
					handler="TiposParticipantes", 
					action="get" 
				},
				{ 
					pattern="/:lang-alpha/:token/tiposparticipantes", 
					handler="TiposParticipantes", 
					action="index" 
				},
						
				// Eventos
				{ 
					pattern="/:lang-alpha/:token/eventos", 
					handler="Eventos", 
					action="index" 
				},

				// Formularios
				{ 
					pattern="/:lang-alpha/:token/formularios/meta/:by_evento-numeric?", 
					handler="Formularios", 
					action="meta",
					constraints= {
						by_evento= {
							required: false,
							type: 'numeric'
						}
					}
				},
				{ 
					pattern="/:lang-alpha/:token/formularios/tipoparticipante/:id_tipo_participante-numeric", 
					handler="Formularios", 
					action="getByTipoParticipante" 
				},
				{ 
					pattern="/:lang-alpha/:token/formularios/:id_formulario-numeric", 
					handler="Formularios", 
					action="get" 
				},
				{ 
					pattern="/:lang-alpha/:token/formularios", 
					handler="Formularios", 
					action="index" 
				},

				// Module Entry Point
				{ 
					pattern="/:lang-alpha/:token?", 
					handler="home", 
					action="index" 
				},

				// Convention Route
				{ pattern="/:lang-alpha/:token?/:handler/:action?" }
			];

			// Custom Declared Points
			interceptorSettings = {
				customInterceptionPoints = ""
			};

			// Custom Declared Interceptors
			interceptors = [];

			// Binder Mappings
			// binder.map("Alias").to("#moduleMapping#.model.MyService");
		}

		/**
		* Fired when the module is registered and activated.
		*/
		function onLoad(){}

		/**
		* Fired when the module is unregistered and unloaded
		*/
		function onUnload(){}

	</cfscript>
</cfcomponent>