<cfoutput>
    <h2 class="section-title">Eventos</h2>
   
    <div class="section-block" id="eventos-all">
        <h3 class="block-title"><span class="get">GET</span> Obtener data de el o los evento asociado</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/eventos</code></p>
        <p class="text-justify">
            Retorna información de él o los eventos asociados al perfil.
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/eventos</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": {
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
            #chr(9)##chr(9)#}
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>
</cfoutput>