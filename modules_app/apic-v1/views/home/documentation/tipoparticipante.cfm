<cfoutput>
    <h2 class="section-title">Tipo de Participantes</h2>

    <div class="section-block" id="tiposparticipantes-all">
        <h3 class="block-title"><span class="get">GET</span> Obtener todos los tipos de participantes.</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/tiposparticipantes</code></p>
        <p class="text-justify">
            Retorna información de él o los eventos asociados al perfil.
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/tiposparticipantes</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 5,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Expositores",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 45,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../45",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"codigo": "EXP"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Invitado",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 67,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"_link": "#application.urlbase#/.../67",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"codigo": "INV"
            #chr(9)##chr(9)##chr(9)##chr(9)#},
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

    <div class="section-block" id="tiposparticipantes-id">
        <h3 class="block-title"><span class="get">GET</span> Por ID Tipo Particiipante.</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/tiposparticipantes/{{id}}</code></p>
        <p class="text-justify">
            Obtiene la información de un tipo de participante en concreto usando su ID
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/tiposparticipantes/45</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"nombre": "Expositores",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 45,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"max_comunicaciones": 10000,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"max_inscritos": 100000,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"cantidad_limite_reuniones": 10000,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_participante": 2962,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"codigo": "EXP"
            #chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#},
            #chr(9)##chr(9)#"total": 1
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>
</cfoutput>