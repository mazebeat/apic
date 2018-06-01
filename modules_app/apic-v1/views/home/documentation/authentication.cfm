<cfoutput>
    <h2 class="section-title">Autenticación</h2>

    <div class="section-block">
        <h3 class="block-title"><span class="post">POST</span> Obtener token de conexión</h3>
        <p class="text-justify">
            <code class="url">/authenticate/apitoken</code>
        </p>
        <p class="text-justify">
            Este método nos retorna un APIc Token para poder gestionar diferentes consultas de datos que se verán en este documento.
        </p>
        <p class="text-justify"> Para solicitar un Token se debe solicitar vía
            POST y adjuntando el parametro contraseña en formato
            JSON. Dicha contraseña será única y exclusivamente entregada al cliente por el equipo de
            <a href="http://www.tufabricadeventos.com/" target="_blank">Tu Fabrica de Eventos</a>. Junto a esto es requisito que el HEADER de la solicitud
            refleje el tipo de contenido, en este caso,
            <code class="language-json">Content-Type: "application/json"</code>
        </p>

        <h4>Parámetros</h4>
        <hr>
        <ul class="list-unstyled params">
            <li class="row">
                <span class="col-md-2 col-xs-12 name">Password</span>
                <span class="col-md-9 col-xs-12 value">{{api_password}}</span>
                <span class="col-md-1 col-xs-12 float-right type">String</span>
            </li>
        </ul>
        <div class="code-block">
            <h6>Ejemplo:</h6>
            <pre class="line-numbers"><code class="language-json">#encodeForHTML('{
            #chr(9)#"password:#chr(9)#"0TZN5Ns6edxagsohMNB2tgQ=="
            }')#</code></pre>

            <p class="text-justify">Luego de autenticarte se retornará el token de conneción en una respuesta como se muestra a continuación</p>

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
    
    <div class="section-block" id="errorToken">
        <h6>Error APIc Token</h6>
        <pre class="line-numbers" style="border: 1px solid red;"><code class="language-json">#encodeForHTML('{
        #chr(9)#data: {},
        #chr(9)#error: true,
        #chr(9)#messages: [
        #chr(9)##chr(9)#"The access token is not valid!"
        #chr(9)#],
        #chr(9)#statusText: "Unauthorized Resource",
        #chr(9)#statusCode: 403
        }')#</code></pre>
    </div>
</cfoutput>