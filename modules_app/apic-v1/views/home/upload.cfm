<!--- Param form variables. --->
<cfparam name="form.upload" type="string" default="" />

<!--- Check to see if the form was uploaded. --->
<cfif len( form.upload )>

    <!--- Upload the photo to a temp directory. --->
    <cffile
        result="upload"
        action="upload"
        filefield="upload"
        destination="#expandPath( './' )#"
        nameconflict="makeunique"
        />

    <!---
        Read the image from the temp directory so that we
        can resize it to fit in the given area.
    --->
    <cfimage
        name="photo"
        action="read"
        source="./#upload.serverFile#"
        />

    <!--- Resize the image to fit in the specified box. --->
    <cfset imageScaleToFit(
        photo,
        500,
        500
        ) />


    <!---
        Now that we have our resized image, we need to write it
        to disk. Because we want to impose a file size limit,
        we are going to keep trying to save the image until we
        have a decent file size.
    --->

    <!---
        Start out with 95% quality. The reason that we are not
        starting out with full quality is that 100% usually
        creates a file that is *surprisingly large*.
    --->
    <cfset imageQuality = 0.95 />

    <!--- Set the max file size. --->
    <cfset maxFileSize = (60 * 1024) />

    <!--- Set the name of the resized image file. --->
    <cfset photoFile = (
        upload.serverFileName &
        "-resized." &
        upload.serverFileExt
        ) />


    <!--- Keep track of the number of iterations. --->
    <cfset saveCount = 0 />

    <!--- Start image save loop. --->
    <cfloop condition="true">

        <!---
            Write the image to the disk with the current level
            of compression.
        --->
        <cfimage
            action="write"
            source="#photo#"
            destination="./#photoFile#"
            quality="#imageQuality#"
            overwrite="true"
            />

        <!--- Increment the save count. --->
        <cfset saveCount++ />

        <!--- Get the file size of the new image file. --->
        <cfset fileSize = getFileInfo(
            ExpandPath( "./#photoFile#" )
            ).size
            />


        <!---
            Check to see if the file size is greater than the
            target file size. If it is not, then we need to
            decrease the photo quality and try again.
        --->
        <cfif (fileSize gt maxFileSize)>

            <!--- Reduce the quality by 5%. --->
            <cfset imageQuality -= .05 />

        <cfelse>

            <!---
                The file size is fine, so just break out of
                the loop.
            --->
            <cfbreak />

        </cfif>

    </cfloop>

</cfif>


<cfoutput>

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
    <head>
        <title>CFImage Dynamic Compression Demo</title>
    </head>
    <body>

        <h1>
            CFImage Dynamic Compression Demo
        </h1>

        <form
            action="#cgi.script_name#"
            method="post"
            enctype="multipart/form-data">

            <p>
                <input type="file" name="upload" size="40" />
            </p>

            <p>
                <input type="submit" value="Upload Photo" />
            </p>

        </form>


        <!--- Check to see if we have an upload photo. --->
        <cfif structKeyExists( variables, "photo" )>

            <h2>
                Resized Image<br />

                <!--- Image properties. --->
                Size: #numberFormat( fileSize, "," )#
                (Max: #numberFormat( maxFileSize, "," )#)<br />

                Quality: #imageQuality#<br />
                Iterations: #saveCount#
            </h2>

            <p>
                <img src="./#photoFile#" />
            </p>

        </cfif>

    </body>
    </html>

</cfoutput>