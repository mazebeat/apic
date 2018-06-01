<cfoutput>
    <h2 class="section-title">Productos</h2>
    
    <div class="section-block" id="producto-all">
        <h3 class="block-title"><span class="get">GET</span> Todos los productos</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/productos</code></p>
        <p class="text-justify">
            Retorna todos los productos disponibles en el evento organizado por grupos.
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/productos</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"titulo": "Productos del país 2",
            #chr(9)##chr(9)##chr(9)##chr(9)#"productos": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"titulo": "Papayas 2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": ""
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"titulo": "Mango",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 2,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": ""
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"titulo": "Piña",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 3,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": ""
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"titulo": "Albaricoques",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 4,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": ""
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)#"activo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"descripcion": "Seleccione los productos del país que desee comprobar in situ para hacer la degustación"
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)#]
            #chr(9)#],
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>

    <div class="section-block" id="producto-selected">
        <h3 class="block-title"><span class="get">GET</span> Todos los productos seleccionados</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/eventos/seleccionados</code></p>
        <p class="text-justify">
           Obtiene todos los participantes por producto que hayan sido seleccionado,
        </p>

       <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/eventos/seleccionados</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"participantes": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"data": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"97": "Nombre Demo",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"99": "jramon.paz@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"102": "Mis Apellidos",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 220,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MDY6MjAgKzAxMDAiLCJ0eXBlIjoiYyJ9.IDdGdFpEy-l0_QJY1j6stIuCOoTX972GK8N-2pEushpmxEaFuIMtj2tUYWKwVWrNPqvnJZo3z9JFqk337uskyw/participantes/39620?ids=97,102,99"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"data": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"97": "Nombre Demo 2 ",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"99": "demo@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"102": "Apellidos Demo 2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 261,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MDY6MjAgKzAxMDAiLCJ0eXBlIjoiYyJ9.IDdGdFpEy-l0_QJY1j6stIuCOoTX972GK8N-2pEushpmxEaFuIMtj2tUYWKwVWrNPqvnJZo3z9JFqk337uskyw/participantes/39621?ids=97,102,99"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"vender": 0
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 1
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)#]
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>

    <div class="section-block" id="producto-selectedbyParticipante">
        <h3 class="block-title"><span class="get">GET</span> Todos los productos seleccionados por un participante</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/eventos/seleccionados/{{id}}</code></p>
        <p class="text-justify">
           Obtiene todos los producto que haya sido seleccionado por un participante en puntual
        </p>

        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">ID Participante</span>
                <span class="col-md-9 col-xs-12 value"></span>   
                <span class="col-md-1 col-xs-12 float-right type">Integer</span>   
            </li>
        </ul>

        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/eventos/seleccionados/25</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 1
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 2
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 3
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 4
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 5
            #chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"colaborar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"comprar": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)#"vender": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)#"id_producto": 6
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
</cfoutput>