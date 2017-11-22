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
        <link href='http://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800'
            rel='stylesheet' type='text/css'>
        <!-- Global CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css" integrity="sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb"
            crossorigin="anonymous">
        <!-- <link rel="stylesheet" href="plugins/bootstrap/css/bootstrap.min.css"> -->
        <!-- Plugins CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="#application.urlbase#/includes/plugins/prism/prism.css">

    
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
            <header id="header" class="header mb-5">
                <div class="container">
                    <div class="row">
                        <div class="col float-left">
                            <img src="http://estatico.tufabricadeventos.com/common/images/logoTFE.gif" class="img-responsive">
                        </div>
                        <div class="col float-right">
                            <div class="branding text-right">
                                <h1 class="logo">
                                    <a href="##">
                                        <span aria-hidden="true" class="">
                                            <i class="fa fa-file-code-o" aria-hidden="true"></i>
                                        </span>
                                        <span class="text-highlight">Tufabricadeventos.com</span>
                                        <span class="" style="color: black;">Docs</span>
                                    </a>
                                </h1>
                            </div>
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

            <section class="jumbotron jumbotron-fluid text-center">
                <div class="container">
                    <h1 class="display-3 text-highlight mb-0"><i class="icon fa fa-code "></i> Documentación APIc V#apiversion# <i class="icon fa fa-code "></i></h1>
                    <p class="meta">
                        <i class="fa fa-clock-o"></i> Última actualización:
                        <span id="last_updated">Thu Oct 26 2017 16:22pm</span>
                    </p>
                </div>
            </section>

             <div class="container">
                <div class="row hidden-xs">
                    <div class="col-3 doc-sidebar">
                        <nav id="doc-nav" class="sticky-top doc-section" role="tablist">
                            <ul id="doc-menu" class="nav flex-column doc-menu">
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##datosprincipales-section">Datos Principales</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##autenticacion-section">Autenticación</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##participantes-section">Participantes</a>
                                    <ul class="nav flex-column doc-sub-menu">
                                        <li>
                                            <a class="nav-link scrollto" href="##participantes-all">Todos</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##participantes-id">Por ID Participante</a>
                                        </li>
                                        <li>
                                            <a class="nav-link scrollto" href="##participantes-type">Por Tipo Participante</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##tiposparticipantes-section">Tipo de Participantes</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##eventos-section">Evento</a>
                                    <ul class="nav flex-column doc-sub-menu">
                                        <li>
                                            <a class="nav-link scrollto" href="##evento-datos">Datos del evento</a>
                                        </li>
                                    </ul>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link scrollto" href="##evento-section">Evento</a>
                                </li>
                            </ul>
                        </nav>
                    </div>

                    <div class="col-9">
                        <div class="">
                            <section class="doc-section" id="datosprincipales-section">
                                <blockquote class="blockquote">
                                    <h2 class="section-title">Datos Principales</h2>
                                    <div class="section-block">
                                        <ul class="">
                                            <li>
                                                URL Base:
                                                <code>#application.urlbase#</code>
                                            </li>
                                            <li>
                                                Métodos utilizados:
                                                <strong>GET, POST</strong>
                                            </li>
                                        </ul>
                                    </div>
                                </blockquote>
                            </section>
                            <section class="doc-section" id="autenticacion-section">
                                <h2 class="section-title">Autenticación</h2>
                                <div class="section-block">
                                    <h3 class="block-title">Obtener token de conexión</h3>
                                    <p class="text-justify">
                                        Este método nos retorna un APIc Token para poder gestionar diferentes consultas de datos que se verán en este documento.</p>
                                    <p class="text-justify"> Para solicitar un Token se debe solicitar vía
                                        <code>POST</code> y adjuntando el parametro contraseña en formato
                                        <code>JSON</code>. Dicha contraseña será única y exclusivamente entregada al cliente por el equipo de
                                        <strong>TUFABRICADEVENTOS.COM</strong>. Junto a esto es requisito que el HEADER de la solicitud
                                        refleje el tipo de contenido, en este caso,
                                        <code class="language-json">Content-Type: "application/json"</code>
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/authenticate</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>POST</strong>
                                        </li>
                                        <li>
                                            Parametors:
                                            <strong>Password
                                                <code>String</code> </strong>
                                        </li>
                                    </ul>
                                    <div class="code-block">
                                        <h6>Ejemplo:</h6>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#"password": "0TZN5Ns6edxagsohMNB2tgQ=="
    }')#</code></pre>
                                        <p class="text-justify">Luego de autenticarte se retornará el token de conneción en una respuesta como se muestra
                                            a continuación</p>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"token": "eyJ0eXAiOiJKV#apiversion#QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwczovL2FwaWMub2ZpY2luYS50dWZhYnJpY2FkZXZlbnRvcy5jb20iLCJzdWIiOjEsImV4cCI6Ik9jdG9iZXIsIDI0IDIwMTcgMTc6MTE6MDMgKzAyMDAifQ.TF6QP9N_XdRPHrzqSPOKOwJPJCECh_BkgGvD2oC_wIlS1jOpqhuErd25gqlFOG97YQXk72BIdfUmkEG-J4gkgA"
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                                <div class="callout-block callout-info">
                                    <div class="icon-holder">
                                        <i class="fa fa-info-circle"></i>
                                    </div>
                                    <div class="content">
                                        <h4 class="callout-title">Información Importante</h4>
                                        <p class="text-justify">En todas las solicitudes que se realicen através de la APIc, debe contener un
                                            <code>TOKEN</code> válido y vigente, de lo contrario se denegará dicha solicitud.
                                            <a href="##errorToken" class="scrollto">Ver Ejemplo</a>
                                        </p>
                                    </div>
                                </div>
                                <div class="code-block" id="errorToken">
                                    <h6>Error APIc Token</h6>
                                    <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {},
    #chr(9)#error: true,
    #chr(9)#messages: [
    #chr(9)##chr(9)#"The access token is not valid!"
    #chr(9)#],
    #chr(9)#statusText: "Unauthorized Resource",
    #chr(9)#statusCode: 403
    }')#</code></pre>
                                </div>
                            </section>
                            <section class="doc-section" id="participantes-section">
                                <h2 class="section-title">Participantes</h2>
                                <div class="section-block" id="participantes-all">
                                    <h3 class="block-title">Obtener todos los participantes</h3>
                                    <p>
                                        Retorna todos los participantes asociados al evento del cliente.
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/apic/v#apiversion#/{lang}/{token}/participantes/</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>GET</strong>
                                        </li>
                                        <li>
                                            Parámetros:
                                            <strong>
                                                Lang <code>String</code> <em>[Default: es]</em>, Token
                                                <code>String</code>
                                            </strong>
                                            <br>
                                            <em>Paginación de datos</em>:
                                            <ul>
                                                <li>
                                                    <strong>Page
                                                        <code class="optional-param">Integer</code>
                                                    </strong>
                                                    [Default: 1]
                                                </li>
                                                <li>
                                                    <strong>Rows
                                                        <em>(Opcional)</em>
                                                        <code class="optional-param">Integer</code>
                                                    </strong>
                                                    [Default: 20, Max: 20]
                                                </li>
                                                <li>Formas de Uso:
                                                    <ul>
                                                        <li>
                                                            <code class="language-json">page/1/rows/20</code> /
                                                            <code class="language-json">?page=1&rows=20</code>
                                                        </li>
                                                    </ul>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>
                                    <div class="code-block">
                                        <h6>Ejemplo:</h6>
                                        <p class="text-justify">URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes</code></p>
                                        <p class="text-justify">Por defecto, viene el parametro <code class="optional-param">page</code> con valor 1, por lo que si se requiere paginar se debe agregar dentro de la consulta, como se muestra en el ejemplo más abajo.</p>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 20,
    #chr(9)##chr(9)#"records": [
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.a@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#},
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 2,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.b@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#},
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 3,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.c@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#},
    #chr(9)##chr(9)##chr(9)#...
    #chr(9)##chr(9)#],
    #chr(9)##chr(9)#"total": 100
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre> URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/page/1/rows/2</code>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 2,
    #chr(9)##chr(9)#"records": [
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.a@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#},
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 2,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre B",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.b@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#}
    #chr(9)##chr(9)#],
    #chr(9)##chr(9)#"total" : 30
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                                <div class="section-block" id="participantes-id">
                                    <h3 class="block-title">Obtener un participante por ID</h3>
                                    <p>
                                        Obtener un participante en concreto buscando por su ID
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/apic/v#apiversion#/{lang}/{token}/participantes/{id}</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>GET</strong>
                                        </li>
                                        <li>
                                            Parametros:
                                            <strong>
                                                Lang <code>String</code> <em>[Default: es]</em>, Token  <code>String</code>, Id Participante
                                                <code>Integer</code>
                                            </strong>
                                        </li>
                                    </ul>
                                    <div class="code-block">
                                        <h6>Ejemplo: </h6>
                                        URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/1</code>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 1,
    #chr(9)##chr(9)#"records": [
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.a@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#}
    #chr(9)##chr(9)#]
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                                <div class="section-block" id="participantes-type">
                                    <h3 class="block-title">Obtener todos los participante por tipo de participante</h3>
                                    <p>
                                        Obtener todos los participante filtrando por su tipo de participante. Si el tipo de participante contiene algún espacio en blanco, este debe reemplazarce por un "-".
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/apic/v#apiversion#/{lang}/{token}/participantes/{tipo}</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>GET</strong>
                                        </li>
                                        <li>
                                            Parametros:
                                            <strong>
                                                Lang <code>String</code> <em>[Default: es]</em>, Token
                                                <code>String</code>, Tipo Participante
                                                <code>String</code>
                                            </strong>
                                            <br>
                                            <em>Paginación de datos</em>:
                                            <ul>
                                                <li>
                                                    <strong>Page
                                                        <code class="optional-param">Integer</code>
                                                    </strong>
                                                    [Default: 1]
                                                </li>
                                                <li>
                                                    <strong>Rows
                                                        <em>(Opcional)</em>
                                                        <code class="optional-param">Integer</code>
                                                    </strong>
                                                    [Default: 20, Max: 20]
                                                </li>
                                                <li>Formas de Uso:
                                                    <ul>
                                                        <li>
                                                            <code class="language-json">page/1/rows/20</code> /
                                                            <code class="language-json">?page=1&rows=20</code>
                                                        </li>
                                                    </ul>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>
                                    <div class="code-block">
                                        <h6>Ejemplo:</h6>
                                        URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/ponente</code>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 2,
    #chr(9)##chr(9)#"records": [
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre A",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.a@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#},
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre_empresa": "Empresa C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 3,
    #chr(9)##chr(9)##chr(9)##chr(9)#"apellidos": "Apellidos C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Nombre C",
    #chr(9)##chr(9)##chr(9)##chr(9)#"email_participante": "demo.c@tufabricadeventos.com"
    #chr(9)##chr(9)##chr(9)#}
    #chr(9)##chr(9)#],
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                            </section>

                            <section class="doc-section" id="tiposparticipantes-section">
                                <h2 class="section-title">Tipo de Participantes</h2>
                                <div class="section-block" id="tiposparticipantes-all">
                                    <h3 class="block-title">Obtner todos los tipos de participantes.</h3>
                                    <p>
                                        Retorna información de él o los eventos asociados al perfil.
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/apic/v#apiversion#/{lang}/{token}/tiposparticipantes</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>GET</strong>
                                        </li>
                                        <li>
                                            Parametros:
                                            <strong>
                                                Lang <code>String</code> <em>[Default: es]</em>, Token
                                                <code>String</code>
                                            </strong>
                                        </li>
                                    </ul> 
                                    <div class="code-block">
                                        <h6>Ejemplo:</h6>
                                        URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/tiposparticipantes</code>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 0,
    #chr(9)##chr(9)#"records": []
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                            </section>

                            <section class="doc-section" id="eventos-section">
                                <h2 class="section-title">Eventos</h2>
                                <div class="section-block" id="eventos-all">
                                    <h3 class="block-title">Obtener metadata de el o los evento asociado</h3>
                                    <p>
                                        Retorna información de él o los eventos asociados al perfil.
                                    </p>
                                    <ul class="">
                                        <li>
                                            URL:
                                            <code>/apic/v#apiversion#/{lang}/{token}/eventos/</code>
                                        </li>
                                        <li>
                                            Método:
                                            <strong>GET</strong>
                                        </li>
                                        <li>
                                            Parametros:
                                            <strong>
                                                Lang <code>String</code> <em>[Default: es]</em>, Token
                                                <code>String</code>
                                            </strong>
                                        </li>
                                    </ul>
                                    <div class="code-block">
                                        <h6>Ejemplo:</h6>
                                        URL:
                                        <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/eventos</code>
                                        <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
    #chr(9)#data: {
    #chr(9)##chr(9)#"count": 1,
    #chr(9)##chr(9)#"records": [
    #chr(9)##chr(9)##chr(9)#{
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Evento Demo",
    #chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": "Descripción Demo"
    #chr(9)##chr(9)##chr(9)##chr(9)#"organizador": "Demo",
    #chr(9)##chr(9)##chr(9)##chr(9)#"emailorganizador": "demo@tufabricadeventos.com",
    #chr(9)##chr(9)##chr(9)##chr(9)#"lugar": "Demo",
    #chr(9)##chr(9)##chr(9)##chr(9)#"fecha_inicio": "01/01/1991 09:00",
    #chr(9)##chr(9)##chr(9)##chr(9)#"fecha_fin": "02/01/1990 09:00",
    #chr(9)##chr(9)##chr(9)##chr(9)#"moneda": "euro",
    #chr(9)##chr(9)##chr(9)##chr(9)#"identificacion": "",
    #chr(9)##chr(9)##chr(9)##chr(9)#"max_inscritos": 100,
    #chr(9)##chr(9)##chr(9)##chr(9)#"nombresalasreuniones": "Sala Demo",
    #chr(9)##chr(9)##chr(9)##chr(9)#"mensajes_sin_leer_para_avisar": 0,
    #chr(9)##chr(9)##chr(9)##chr(9)#"max_inscritos_activo": 0,
    #chr(9)##chr(9)##chr(9)#}
    #chr(9)##chr(9)#]
    #chr(9)#},
    #chr(9)#error: false,
    #chr(9)#messages: [],
    #chr(9)#statusText: "OK",
    #chr(9)#statusCode: 200
    }')#</code></pre>
                                    </div>
                                </div>
                            </section>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <footer id="footer" class="footer text-center">
            <div class="container">
                <small class="copyright">Desarrollado
                    <i class="fa fa-engine"></i> por
                    <a href="http://www.tufabricadeventos.com/" targe="_blank">Tufabricadeventos.com</a>
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