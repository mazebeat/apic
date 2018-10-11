<!--- 
    ESTE ES ARCHIVO CONTIENE HELPERS PARA STRINGS 
--->
<cfscript>
    numeric function onlyNumbers(required string string) {
        return javacast('int', string.replaceAll('[^0-9\.]+',''));
    }

    string function onlyAlpha(required string string) {
        return javacast('string', string.replaceAll('[^a-zA-Z\.]+',''));
    }

    string function onlyAlphaAndSpaces(required string string) {
        return javacast('string', string.replaceAll('[^a-zA-Z\. ]+',''));
    }
</cfscript>