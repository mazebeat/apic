<cfoutput>
    <h2 class="section-title">Participantes</h2>

    <div class="section-block" id="participantes-all">
        <h3 class="block-title"><span class="get">GET</span> Obtener todos los participantes</h3>
        <p><code class="url">/apic/v#apiversion#/{lang}/{token}/participantes/</code></p>
        <p class="text-justify">
            Retorna todos los participantes asociados.</br>
            Los datos entregados por esta consulta son campos de formulario por defecto, por lo que si se requiere un campo diferente a los básicos (nombre, apellido, email) se debe consultar el apartado de <a class="scrollto" href="##form-meta">Metadata Formulario</a></p>
        
        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Page</span>
                <span class="col-md-9 col-xs-12 value">Número de página [Default: 1]</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Rows</span>
                <span class="col-md-9 col-xs-12 value">Cantidad de registros por página [Opcional | Default: 20, Max: 20]</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>
        
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                Por defecto, viene el parametro <code class="optional-param">page</code> con valor 1, por lo que si se requiere paginar se debe agregar dentro de la consulta, como se muestra en el ejemplo de abajo.
            </p>
            <p class="text-justify">            
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/page/1</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 20,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.a@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../1"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 2,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre B",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos B",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.b@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../2"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 3,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre C",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos C",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.c@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../3"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)#},
            #chr(9)##chr(9)#"total": 100
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre> 
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/page/1/rows/2</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 2,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.a@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../1"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 2,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre B",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos B",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.b@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../2"
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#},
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
        <h3 class="block-title"><span class="get">GET</span> Obtener un participante por ID</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/participantes/{id}</code></p>
        <p class="text-justify">
            Obtener un participante en concreto buscando por su ID
        </p>
        
        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Id Participante</span>
                <span class="col-md-9 col-xs-12 value">ID Participante a buscar</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>
        <div class="code-block">
            <h6>Ejemplo: </h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/3</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 3,
            #chr(9)##chr(9)##chr(9)##chr(9)#"4381": "Nombre C",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4356": "Apellidos C",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4383": "demo.c@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../3"
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#}
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>

    <div class="section-block" id="participantes-type">
        <h3 class="block-title"><span class="get">GET</span> Obtener todos los participante por tipo de participante</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/participantes/{tipo}</code></p>
        <p class="text-justify">
            Obtener todos los participante filtrando por su tipo de participante. Si el tipo de participante contiene algún espacio en blanco, este debe reemplazarce por un "-".
        </p>

        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Tipo Participante</span>
                <span class="col-md-9 col-xs-12 value">Tipo Participante a buscar</span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Page</span>
                <span class="col-md-9 col-xs-12 value">Número de página [Default: 1]</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Rows</span>
                <span class="col-md-9 col-xs-12 value">Cantidad de registros por página [Opcional | Default: 20, Max: 20]</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>

        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes/ponente</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 2,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"12": "Nombre A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"13": "Apellidos A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"14": "demo.a@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../1"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 8,
            #chr(9)##chr(9)##chr(9)##chr(9)#"12": "Nombre D",
            #chr(9)##chr(9)##chr(9)##chr(9)#"13": "Apellidos D",
            #chr(9)##chr(9)##chr(9)##chr(9)#"14": "demo.b@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../8"
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#},
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>

    <div class="section-block" id="participantes-fields">
        <h3 class="block-title"><span class="get">GET</span> Datos Participantes por Campos de Formulario</h3>
        <p class="text-justify">
            Cuando se requieren campos que no son los definidos por defecto, se deben enviar los ID de dichos campos para que estos sean retornados.
        </p>

        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Ids</span>
                <span class="col-md-9 col-xs-12 value">IDs correspondientes al campo que se requiere obtener</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes?ids=12,13,14,134,252,4144</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 0,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"12": "Nombre A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"13": "Apellidos A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"14": "demo.a@tufabricadeventos.com"
            #chr(9)##chr(9)##chr(9)##chr(9)#"134": "Ocupación A",
            #chr(9)##chr(9)##chr(9)##chr(9)#"252": "Vacío {Respuesta 1}",
            #chr(9)##chr(9)##chr(9)##chr(9)#"4144": "Sí {Asistirá?}",
            #chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../1"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)#},
            #chr(9)##chr(9)#"total": 154
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>       
        </div>
    </div>

    <div class="section-block" id="participantes-save">
        <h3 class="block-title"><span class="post">POST</span> Guardar Participante</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/participantes/</code></p>
        <p class="text-justify">
            Cada campo que no es definidos por defecto, osea no es un nombre en particular como <em><strong>"id_tipo_participante"</strong>, <strong>"login"</strong>, <strong>"password"</strong>, <strong>"inscrito"</strong></em>, etc, se debe enviar como ID de dichos campos para que estos sean almacenados correctamente.
            <br>Estas referencias se pueden obtener desde el metadata del fomulario, <a class="nav-link scrollto p-0 m-0 d-inline" href="##form-meta">Metadata Formulario</a></p>
        
        <h4>Parámetros</h4>
        <hr>
        
        <h5>Campos Obligatorios:</h5>
        <p>Al igual que en nuestra aplicación web, existen ciertos campos que son obligatorios para identificar al participante. Estos campos <em>deben</em> ir incluidos a través del <strong>ID</strong> que corresponda a cada campo, exceptuando por el tipo de participante.</p>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">id_tipo_participante</span>
                <span class="col-md-9 col-xs-12 value">Id del tipo de participante al cual se quiere asociar al nuevo participante</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Nombres</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Apellidos</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Email</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
        </ul>

        <h5>Campos Optativos</h5>
        <p>Dentro de los campos que se pueden enviar para crear un participante tenemos algunos personalizados para dar una mejor gestion de ellos. Estos campos no deben ir por si ID de campo, sino que por el nombre identificador, tal como se muestra a continuación.</p>
        <ul class="list-unstyled params">
        <li class="row">
                <span class="col-md-2 col-xs-12 name">login</span>
                <span class="col-md-9 col-xs-12 value">Correo para realizar inicio de sesión en app área privada [<em>Default:</em> Correo participante]</span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">password</span>
                <span class="col-md-9 col-xs-12 value">Contraseña participante. | <em>Default:</em> "Generada por el sistema"</span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">inscrito</span>
                <span class="col-md-9 col-xs-12 value">Define si el participante se guardará como inscrito en el evento o no. Los valores que puede optar son
                    <ul>
                        <li><strong>1</strong>: Inscrito</li class="row">
                        <li><strong>0</strong>: No Inscrito</li class="row">
                        <li><em>Default:</em> 0</li class="row">
                    </ul>
                </span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
            <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
                #chr(9)#data: {
                #chr(9)##chr(9)#"records": [
                #chr(9)##chr(9)#{
                #chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 1,
                #chr(9)##chr(9)##chr(9)##chr(9)#"login": "demo.a@tufabricadeventos.com", 
                #chr(9)##chr(9)##chr(9)##chr(9)#"password": "newpassword"
                #chr(9)##chr(9)##chr(9)##chr(9)#"15" : "2007-11-03T16:18:05Z",
                #chr(9)##chr(9)##chr(9)##chr(9)#"17": "Nombre A", // campo nombre
                #chr(9)##chr(9)##chr(9)##chr(9)#"22": "Apellidos A", // campo apellidos
                #chr(9)##chr(9)##chr(9)##chr(9)#"19": "demo.a@tufabricadeventos.com", //campo email
                #chr(9)##chr(9)##chr(9)##chr(9)#"24": 1, 
                #chr(9)##chr(9)##chr(9)##chr(9)#"inscrito": 1 
                #chr(9)##chr(9)##chr(9)#},
                #chr(9)##chr(9)##chr(9)#...
                #chr(9)##chr(9)#],
                #chr(9)#},
                }')#
            </code></pre>       
        </div>
    </div>

    <div class="section-block" id="participantes-modify">
        <h3 class="block-title"><span class="put">PUT</span> Modificar Participante</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/participantes/</code></p>
        <p class="text-justify">
            Al igual que al guardar un participante, cada uno de los campos que no es definidos por defecto, se debe enviar como ID de dichos campos para que estos sean modificados correctamente.
            <br>Estas referencias se pueden obtener desde el metadata del fomulario, <strong><a class="nav-link scrollto p-0 m-0 d-inline" href="##form-meta" style="">Metadata Formulario</a></strong></p>

        <h4>Parámetros</h4>
        <hr>
        
        <h5>Campos Obligatorios:</h5>
        <p>Al igual que en nuestra aplicación web, existen ciertos campos que son obligatorios para identificar al participante. Estos campos <em>deben</em> ir incluidos a través del <strong>ID</strong> que corresponda a cada campo, exceptuando por el tipo de participante.</p>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">id_tipo_participante</span>
                <span class="col-md-9 col-xs-12 value">Id del tipo de participante al cual se quiere asociar al nuevo participante</span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Nombres</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Apellidos</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Email</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
        </ul>

        <h5>Campos Optativos</h5>
        <p>Dentro de los campos que se pueden enviar para crear un participante tenemos algunos personalizados para dar una mejor gestion de ellos. Estos campos no deben ir por si ID de campo, sino que por el nombre identificador, tal como se muestra a continuación.</p>
        <ul class="list-unstyled params">
        <li class="row">
                <span class="col-md-2 col-xs-12 name">login</span>
                <span class="col-md-9 col-xs-12 value">Correo para realizar inicio de sesión en app área privada [<em>Default:</em> Correo participante]</span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">password</span>
                <span class="col-md-9 col-xs-12 value">Contraseña participante. | <em>Default:</em> "Generada por el sistema"</span>   
                <span class="col-md-1 col-xs-12 float-right type">String</span>   
            </li>
            <li class="row">
                <span class="col-md-2 col-xs-12 name">inscrito</span>
                <span class="col-md-9 col-xs-12 value">Define si el participante se guardará como inscrito en el evento o no. Los valores que puede optar son
                    <ul>
                        <li><strong>1</strong>: Inscrito</li class="row">
                        <li><strong>0</strong>: No Inscrito</li class="row">
                        <li><em>Default:</em> 0</li class="row">
                    </ul>
                </span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>

        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
            <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/participantes</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
                #chr(9)#data: {
                #chr(9)##chr(9)#"records": [
                #chr(9)##chr(9)#{
                #chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 1,
                #chr(9)##chr(9)##chr(9)##chr(9)#"login": "demo.a@tufabricadeventos.com",
                #chr(9)##chr(9)##chr(9)##chr(9)#"password": "newpassword"
                #chr(9)##chr(9)##chr(9)##chr(9)#"15" : "2007-11-03T16:18:05Z",
                #chr(9)##chr(9)##chr(9)##chr(9)#"17": "Nombre A",
                #chr(9)##chr(9)##chr(9)##chr(9)#"19": "demo.a@tufabricadeventos.com",
                #chr(9)##chr(9)##chr(9)##chr(9)#"22": "Apellidos A",
                #chr(9)##chr(9)##chr(9)##chr(9)#"24": 1,
                #chr(9)##chr(9)##chr(9)#},
                #chr(9)##chr(9)##chr(9)#...
                #chr(9)##chr(9)#],
                #chr(9)#},
                }')#
            </code></pre>       
        </div>
    </div>
</cfoutput>