<!---
The base model test case will use the 'model' annotation as the instantiation path
and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
responsibility to update the model annotation instantiation path and init your model.
--->
<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="models.campo.Campo" output="false" hint="">
	
	<!--- *********************************** LIFE CYCLE Methods *********************************** --->

	<cffunction name="beforeAll">
		<cfset super.beforeAll()>
	
		<!--- setup the model --->
		<cfset super.setup()>
		
		<!--- init the model object --->
		<cfset model.init()>
	</cffunction>

	<cffunction name="afterAll">
		<cfset super.afterAll()>
	</cffunction>

	<!--- *********************************** BDD SUITES *********************************** --->
	
	<cffunction name="run">
		<cfscript>
		describe( "campo.Campo Suite", function(){
			

		});
		</cfscript>
	</cffunction>

</cfcomponent>
