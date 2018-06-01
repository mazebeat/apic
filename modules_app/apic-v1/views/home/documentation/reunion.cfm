<cfoutput>
    <h2 class="section-title">Reuniones</h2>
    
    <div class="section-block" id="reunion-all">
        <h3 class="block-title"><span class="get">GET</span> Todas las reuniones</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/reuniones</code></p>
        <p class="text-justify">
            Obtener todas las reuniones previamente agendada
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/reuniones</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"participantes": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"987": "Nombre Demo",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"989": "demo@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"22": "Apellidos No Email",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 55,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MjM6MTcgKzAxMDAiLCJ0eXBlIjoiYyJ9.joOx6eV2OmcLVxXuJ4zjgvJjOhlJ5kVo13IpAibkdpyeoiD-VTefTfIH3eAoJQZyiNsIyB_toxPfDSdkFua9tA/participantes/39621?ids=987,22,989"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"987": "Nombre Demo 2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"989": "demo2@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 54,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MjM6MTcgKzAxMDAiLCJ0eXBlIjoiYyJ9.joOx6eV2OmcLVxXuJ4zjgvJjOhlJ5kVo13IpAibkdpyeoiD-VTefTfIH3eAoJQZyiNsIyB_toxPfDSdkFua9tA/participantes/54?ids=987,22,989"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)#"sala": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_sala": 10,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Sala Demo"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#"horario": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"fecha": "01/01/2018",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "00:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "01:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_hora": 1
            #chr(9)##chr(9)##chr(9)##chr(9)#}
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

    <div class="section-block" id="reunion-byParticipante">
        <h3 class="block-title"><span class="get">GET</span> Reuniones de un participante.</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/reuniones/{{id}}</code></p>
        <p class="text-justify">
            EObtener las reuniones de un participante basandonos en su ID.
        </p>

        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">nodetail</span>
                <span class="col-md-9 col-xs-12 value">Oculta el detalle de la consulta y retorna solo los ids de los objetos [&nodetail=]</span>
                <span class="col-md-1 col-xs-12 float-right type">String</span>
            </li>
        </ul>
        
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/eventos/74</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"participantes": [
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"987": "Nombre Demo",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"989": "demo@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"22": "Apellidos No Email",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 55,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MjM6MTcgKzAxMDAiLCJ0eXBlIjoiYyJ9.joOx6eV2OmcLVxXuJ4zjgvJjOhlJ5kVo13IpAibkdpyeoiD-VTefTfIH3eAoJQZyiNsIyB_toxPfDSdkFua9tA/participantes/39621?ids=987,22,989"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"987": "Nombre Demo 2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"989": "demo2@tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_participante": 74,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "http://apic.oficina.tufabricadeventos.com/index.cfm/apic/v1/es/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJpc3MiOiJodHRwOi8vYXBpYy5vZmljaW5hLnR1ZmFicmljYWRldmVudG9zLmNvbSIsInN1YiI6MSwiZXhwIjoiTWFyY2gsIDA2IDIwMTggMTE6MjM6MTcgKzAxMDAiLCJ0eXBlIjoiYyJ9.joOx6eV2OmcLVxXuJ4zjgvJjOhlJ5kVo13IpAibkdpyeoiD-VTefTfIH3eAoJQZyiNsIyB_toxPfDSdkFua9tA/participantes/54?ids=987,22,989"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)#],
            #chr(9)##chr(9)##chr(9)##chr(9)#"sala": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_sala": 10,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Sala Demo"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#"horario": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"fecha": "01/01/2018",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "00:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "01:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_hora": 1
            #chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#]
            #chr(9)#],
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>
</cfoutput>