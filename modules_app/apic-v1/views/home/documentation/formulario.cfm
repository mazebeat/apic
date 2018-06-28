<cfoutput>
    <h2 class="section-title">Formulario</h2>
    
    <div class="section-block" id="form-meta">
        <h3 class="block-title"><span class="get">GET</span> Metadata</h3>
        <p class="text-justify"><code class="url">/apic/v#apiversion#/{lang}/{token}/formularios/meta</code></p>
        <p class="text-justify">
            Obtiene toda la metadata de los formulario y grupos asociados al evento. De esta manera se puede consultar por campos específicos de formulario.</p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/formularios/meta</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)#"groups": {
            #chr(9)##chr(9)##chr(9)##chr(9)#"1178": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"title": "Titulo Grupo",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"fields": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"12": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"inputType": "input",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"name": "Nombre",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"type": "text",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"configuration": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"required": true,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"maxlength": 50,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"onlyAlpha": true,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"readonly": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"minlength": 0
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"13": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"inputType": "input",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"name": "Apellidos",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"type": "text",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"configuration": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"required": true,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"maxlength": 50,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"onlyAlpha": true,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"readonly": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"minlength": 0
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"4144": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"inputType": "input",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"values": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"0": "NO",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"1": "SÍ"
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"name": "Asistirá?",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"type": "radio",
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"configuration": {
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"required": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"maxlength": 0,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"comprobacion": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"onlyAlpha": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"readonly": false,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"minlength": 0
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#},
            #chr(9)##chr(9)#"total": 25
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
        <p class="text-justify">
            Si algunos de los campos que retornen la consulta contienen la llave <strong>"values"</strong>, como es el caso de <strong>"Asistirá?"</strong>, estos corresponden a los valores que se pueden optar.
        Además, cada campo entregado en los metas del formulario contiene su propia <strong>configuración</strong>, que al momento de almacenar o modificar un registro se deben cumplir, de lo contrario el sistema retornará el error correspondiente.</p>
    </div>

    <div class="section-block" id="form-basics">
        <h3 class="block-title"><span class="get">GET</span> Datos básicos formulario</h3>
        <p class="text-justify">
            <code class="url">/apic/v#apiversion#/{lang}/{token}/formularios</code>
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/formularios</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 5,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)# {
            #chr(9)##chr(9)##chr(9)#"id_formulario": 4321,
            #chr(9)##chr(9)##chr(9)#"id_campo": [
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 44,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 112,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 3
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 67,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 112,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 4
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 788,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 112,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 5
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 54,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 112,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 6
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#},
            #chr(9)##chr(9)#"total": 25
            #chr(9)#},
            #chr(9)#error: false,
            #chr(9)#messages: [],
            #chr(9)#statusText: "OK",
            #chr(9)#statusCode: 200
            }')#</code></pre>
        </div>
    </div>       
                            
    <div class="section-block" id="form-id">
        <h3 class="block-title"><span class="get">GET</span> Obtener por ID</h3>
        <p class="text-justify">
            <code class="url">/apic/v#apiversion#/{lang}/{token}/formularios/{id}</code>
        </p>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <p class="text-justify">
                <code>#application.urlbase#/apic/v#apiversion#/{lang}/{token}/formularios/1234</code></p>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#data: {
            #chr(9)##chr(9)#"count": 1,
            #chr(9)##chr(9)#"records": {
            #chr(9)##chr(9)##chr(9)# {
            #chr(9)##chr(9)##chr(9)#"id_formulario": 1234,
            #chr(9)##chr(9)##chr(9)#"id_campo": [
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 32,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 1179,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 3
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 12,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 1179,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 4
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 45,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 1179,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 5
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#{
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo": 1,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_campo": 576,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_agrupacion": 1179,
            #chr(9)##chr(9)##chr(9)##chr(9)##chr(9)#"id_tipo_campo_fijo": 6
            #chr(9)##chr(9)##chr(9)##chr(9)#},
            #chr(9)##chr(9)##chr(9)##chr(9)#...
            #chr(9)##chr(9)##chr(9)#}
            #chr(9)##chr(9)#}
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