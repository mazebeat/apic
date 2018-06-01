<cfoutput>
    <h2 class="section-title">Agenda</h2>
   
    <div class="section-block" id="agenda-all">
        <h3 class="block-title"><span class="get">GET</span> Obtener todas las agendas</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/agendas</code></p>
        <p class="text-justify">
            Retorna información de él o los eventos asociados al perfil.
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
            <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/agendas</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"actividad": "Taller 1",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"sala": "Sala para T2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "10:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "10:30",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante2": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comentariosytptma": "",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante1": 39622,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"dia": "05/02/2018"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"actividad": "Taller 1",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"sala": "Sala para T2",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "10:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "10:30",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante2": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comentariosytptma": "",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante1": 39626,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"dia": "05/02/2018"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"actividad": "Reunión con (Białkowski2 Apellidos No Email2)",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"sala": "111",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "10:00",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "10:30",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante2": 40912,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comentariosytptma": "",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"participante1": 40135,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"dia": "05/02/2018"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#...
            #chr(9)#],
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>

    <div class="section-block" id="agenda-byParticipante">
        <h3 class="block-title"><span class="get">GET</span> Obtener la agenda de un participante</h3>
        <p class=""><code class="url">/apic/v#apiversion#/{{lang}}/{{token}}/agendas/{{id}}</code></p>
        <p class="text-justify">
            Este método retorna toda la información de las agendas geeradas en el evento de un participante en particular
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
                <code>#application.urlbase#/apic/v#apiversion#/{{lang}}/{{token}}/agendas/25</code>
            </p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": [
            #chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)#"actividad": "Reunión con Tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)#"sala": "Tufabricadeventos.com",
            #chr(9)##chr(9)##chr(9)##chr(9)#"hora_inicio": "00:01",
            #chr(9)##chr(9)##chr(9)##chr(9)#"hora_fin": "00:02",
            #chr(9)##chr(9)##chr(9)##chr(9)#"participante2": 39
            #chr(9)##chr(9)##chr(9)##chr(9)#"comentariosytptma": "",
            #chr(9)##chr(9)##chr(9)##chr(9)#"participante1": 25,
            #chr(9)##chr(9)##chr(9)##chr(9)#"dia": "19/08/2018"
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#}
            #chr(9)#],
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>
</cfoutput>