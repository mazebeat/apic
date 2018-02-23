component extends="coldbox.system.Interceptor" {

    function onException(event, interceptData){
        // Get the exception
        // var exception = arguments.interceptData.exception;

        // var oException = new coldbox.system.web.context.ExceptionBean( exception );

        // var errortext = "";

        // savecontent variable="errortext" {
        //     writeOutput('An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />');
        
        //     writeOutput('Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />');
        //     writeDump(var="#form#", label="Form");
        //     writeDump(var="#session#", label="Session");
        //     writeDump(var="#cookie#", label="Cookies");
        //     writeDump(var="#url#", label="URL");

        //     include template="/views/bugreport.cfm";
        // }

        // enviarElError(exception.getMessage(), errortext);

        // throw(exception);
    }
}