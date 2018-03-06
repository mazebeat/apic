<cfoutput>
    <cfscript>
        var apiversion = 1;
        var apilanguage = session.language
        var docUrl = listFirst(cgi.REQUEST_URL, "?");
    </cfscript>
    <!DOCTYPE html>
    <!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->
    <!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->
    <!--[if !IE]><!-->
    <html lang="#lcase(apilanguage)#">
    <!--<![endif]-->

    <head>
        <title>APIc V#apiversion# Documentación</title>
        <base href="#getSetting('htmlBaseURL')#">
        <!-- Meta -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="APIc V#apiversion# Tufabricadeventos.com">
        <meta name="author" content="TFE">
        
        <link rel="alternate" hreflang="#apilanguage#" href="#docUrl#">
        <link rel="canonical" href="#docUrl#">

        <link rel="shortcut icon" href="http://www.tufabricadeventos.com/files/2213/6015/1524/bigIcon-online.png">
        <link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800' rel='stylesheet' type='text/css'>
        <!-- Global CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb" crossorigin="anonymous">
        <!-- <link rel="stylesheet" href="plugins/bootstrap/css/bootstrap.min.css"> -->
        <!-- Plugins CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
        
        <link rel="stylesheet" href="#application.urlbase#/includes/plugins/prism/prism.css">
        <!--- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.8.4/themes/prism.min.css"> --->
    
        <!-- Theme CSS -->
        <link id="theme-style" rel="stylesheet" href="#application.urlbase#/includes/css/styles.css">
        <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->

    </head>

    <body class="body-blue" data-spy="scroll" data-target="##doc-nav" data-offset="0">
        <div class="page-wrapper">
            
            <header id="header" class="header">
                <div class="container">
                    <div class="row">
                        <div class="col-md-3 float-left">
                            <img src="http://estatico.tufabricadeventos.com/common/images/logoTFE.gif" class="img-fluid" alt="logotipo">
                        </div>
                        <div class="col-md-9 float-right">
                            <h2 class="text-uppercase text-right">
                                <!--- <a href="##"> --->
                                    <span aria-hidden="true" class="">
                                        <i class="fa fa-file-code-o" aria-hidden="true"></i>
                                    </span>
                                    <span class="text-highlight">TFE</span>
                                    <span class="" style="color: black;">Docs</span>
                                <!--- </a> --->
                            </h2>
                            <nav aria-label="breadcrumb" role="navigation" class="float-right">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item">
                                        <a href="##">Inicio</a>
                                    </li>
                                    <li class="breadcrumb-item">
                                        <a href="##">Documentación</a>
                                    </li>
                                    <li class="breadcrumb-item active" aria-current="page">APIc V#apiversion#</li>
                                </ol>
                            </nav>
                        </div>
                    </div>
                </div>
            </header>
            
            <div class="container">
                <nav class="navbar navbar-toggleable-sm navbar-expand-sm navbar-light bg-light">
                    <!-- Links -->
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link scrollto" href="##top">Documentación</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link scrollto" href="##top">Ejemplos</a>
                        </li>
                    </ul>
                </nav>
            </div>

            <section class="jumbotron jumbotron-fluid text-center">
                <div class="container">
                    <h1 class="display-3 text-highlight mb-0"><i class="icon fa fa-code "></i> Documentación APIc V#apiversion# <i class="icon fa fa-code "></i></h1>
                    <p class="meta">
                        <i class="fa fa-clock-o"></i> Última actualización:
                        <span id="last_updated">Mar Marzo 6 2018 13:12pm</span>
                    </p>
                </div>
            </section>

            <div class="container">
                
                <div class="row hidden-xs">
                   
                    <div class="col-md-3 doc-sidebar " id="sidebar">
                        <nav id="doc-nav" class="sticky-top doc-section" role="tablist">
                            <ul id="doc-menu" class="nav flex-column doc-menu">
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##datosprincipales-section">Datos Principales</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##autenticacion-section">Autenticación</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-participante">Participantes</a>
                                    <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-participante">
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-all"><span class="get">GET</span> Todos</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-id"><span class="get">GET</span> Por ID</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-type"><span class="get">GET</span> Por Tipo Participante</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-fields"><span class="get">GET</span> Por Campos de Formulario</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-save"><span class="post">POST</span> Guardar</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" data-parent="menu-participante" href="##participantes-modify"><span class="put">PUT</span> Modificar</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-tiposparticipantes">Tipo de Participantes</a>
                                    <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-tiposparticipantes">
                                        <li>
                                            <a class="nav-link scrollto" href="##tiposparticipantes-all"><span class="get">GET</span> Todos</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##tiposparticipantes-id"><span class="get">GET</span> Por por ID</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##eventos-section">Evento</a>
                                    <!--- <ul class="nav flex-column doc-sub-menu">
                                        <li>
                                            <a class="nav-link scrollto" href="##evento-datos">Datos del evento</a>
                                        </li>
                                    </ul> --->
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-formulario">Formulario</a>
                                    <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-formulario">
                                        <li>
                                            <a class="nav-link scrollto" href="##form-meta"><span class="get">GET</span> Metadata</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##form-basics"><span class="get">GET</span> Datos Básicos</a>
                                        </li>
                                        <!--- <li>
                                            <a class="nav-link scrollto" href="##form-fields">Datos por Campos</a>
                                        </li> --->
                                        <li>
                                            <a class="nav-link scrollto" href="##form-id"><span class="get">GET</span> Datos por ID</a>
                                        </li>
                                    </ul>
                                </li>

                                 <li class="nav-item">
                                    <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-agenda">Agenda</a>
                                    <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-agenda">
                                        <li>
                                            <a class="nav-link scrollto" href="##agenda-all"><span class="get">GET</span> Todas las agendas</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##agenda-byParticipante"><span class="get">GET</span> Por Participante</a>
                                        </li>
                                    </ul>
                                </li>

                                
                                <li class="nav-item">
                                    <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-reunion">Reuniones</a>
                                    <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-reunion">
                                        <li>
                                            <a class="nav-link scrollto" href="##reunion-all"><span class="get">GET</span> Todas las reuniones</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##reunion-byParticipante"><span class="get">GET</span> Por Participante</a>
                                        </li>
                                    </ul>
                                </li>
                                
                                <li class="nav-item">
                                   <a class="nav-link scrollto collapsed" data-toggle="collapse" data-parent="##sidebar" aria-expanded="false" data-toggle="collapse" data-target="##menu-producto">Productos</a>
                                   <ul class="nav-s flex-column doc-sub-menu collapse" id="menu-producto">
                                       <li>
                                           <a class="nav-link scrollto" href="##producto-all"><span class="get">GET</span> Todas las productos</a>
                                       </li>
                                       <li>
                                           <a class="nav-link scrollto" href="##producto-selected"><span class="get">GET</span> Productos Seleccionados</a>
                                       </li>
                                        <li>
                                           <a class="nav-link scrollto" href="##producto-selectedbyParticipante"><span class="get">GET</span> Seleccionados por Participante</a>
                                       </li>                                       
                                   </ul>
                               </li>
                            </ul>
                        </nav>
                    </div>

                    <div class="col-md-9">
                        <div id="doc-content-section">
                            
                            <section class="doc-section" id="datosprincipales-section">
                                <h2 class="section-title">Datos Principales</h2>
                                <div class="section-block">
                                    <p class="text-justify">URL Base: <code class="url">#application.urlbase#</code></p>
                                    <p class="text-justify">
                                        Métodos utilizados
                                        <strong><span class="get">GET</span>, <span class="post">POST</span>, <span class="put">PUT</span></strong>
                                    </p>
                                    
                                    <h4>Parámetros</h4>
                                    <hr>
                                    <ul class="list-unstyled params">
                                        <li class="row">
                                            <span class="col-md-2 col-xs-12 name">Lang</span>
                                            <span class="col-md-9 col-xs-12 value"><em>[Default: es]</em></span>   
                                            <span class="col-md-1 col-xs-12 float-right type">String</span>   
                                        </li>
                                        <li class="row">
                                            <span class="col-md-2 col-xs-12 name">Token</span>
                                            <span class="col-md-9 col-xs-12 value"></span>   
                                            <span class="col-md-1 col-xs-12 float-right type">String</span>   
                                        </li>
                                    </ul>
                                </div>
                            </section>
                           
                            <section class="doc-section" id="autenticacion-section">
                               <cfinclude template ="documentation/authentication.cfm">
                            </section>                           

                            <section class="doc-section" id="participantes-section">
                                <cfinclude template ="documentation/participante.cfm">
                            </section>

                            <section class="doc-section" id="tiposparticipantes-section">
                                <cfinclude template ="documentation/tipoparticipante.cfm">
                            </section>

                            <section class="doc-section" id="eventos-section">
                                <cfinclude template ="documentation/evento.cfm">
                            </section>
                            
                            <section class="doc-section" id="form-section">
                                <cfinclude template ="documentation/formulario.cfm">
                            </section>

                            <section class="doc-section" id="agenda-section">
                                <cfinclude template ="documentation/agenda.cfm">
                            </section>

                             <section class="doc-section" id="reunion-section">
                                <cfinclude template ="documentation/reunion.cfm">
                            </section>

                            <section class="doc-section" id="producto-section">
                                <cfinclude template ="documentation/producto.cfm">
                            </section>
                        </div>
                    </div>
                </div>
            </div>
        </div>
                
        <a href="##top" id="smoothup" title="Back to top">
            <span class="fa-stack fa-lg">
                <i class="fa fa-circle fa-2x fa-stack-2x"></i>
                <i class="fa fa-arrow-up fa-lg fa-stack-1x fa-inverse"></i>
            </span>
        </a>

        <footer id="footer" class="footer text-center">
            <div class="container">
                <small class="copyright">Desarrollado
                    <i class="fa fa-engine"></i> por 
                    <a href="http://www.tufabricadeventos.com/" targe="_blank">Tufabricadeventos.com </a> <i class="fa fa-copyright" aria-hidden="true"></i> 2018
                    - Documentación APIc V#apiversion#
                </small>
            </div>
        </footer>

        <script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-scrollTo/2.1.2/jquery.scrollTo.min.js"></script>
        <script src="#application.urlbase#/includes/plugins/prism/prism.js"></script>
        <script src="#application.urlbase#/includes/js/main.js"></script>
    </body>
    </html>
</cfoutput>