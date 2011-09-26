<cfcomponent displayname="Locale Resource Bundle" output="false">
	
	<cffunction name="init">
        <cfset this.version = "1.1,1.1.1,1.1.2,1.1.3,1.1.4,1.1.5">
		<cfset $getJavaRB(true)/>
		<cfif structKeyExists(application,"resourceBundles")>
			<cflock timeout="5" scope="application">
				<cfset structDelete(application,"resourceBundles")/>
			</cflock>
		</cfif>
        <cfreturn this>
    </cffunction>
	
	<cffunction name="$" returntype="any" output="false">
		<cfargument name="key" type="string" required="true"/>
		<cfargument name="bundle" type="string" default="global"/>
		<cfargument name="locale" type="string" default="#getCurrentLocale()#"/>
		<cfscript>
			var rb = $getResourceBundleStruct();
			
			if(!structKeyExists(rb,arguments.bundle)){
				if(get('environment') eq 'production'){
					return "";
				}
				else{
					throw("Bundle does not exist in resource bundles");
				}
			}
			
			var bundle = rb[arguments.bundle];
			
			try{
				if(structKeyExists(bundle,arguments.locale)){
					if(structKeyExists(bundle[arguments.locale],arguments.key)){
						return bundle[arguments.locale][arguments.key];
					}
				}
				
				var split = reFind("_",arguments.locale);
				if(split){
					var langOnly = left(arguments.locale,split-1);
					if(structKeyExists(bundle,langOnly)){
						if(structKeyExists(bundle[langOnly],arguments.key)){
							return bundle[langOnly][arguments.key];
						}
					}
				}
				
				var defaultLocale = $getDefaultLocale();
				if(structKeyExists(bundle,defaultLocale)){
					if(structKeyExists(bundle[defaultLocale],arguments.key)){
						return bundle[defaultLocale][arguments.key];
					}
				}
			}
			catch(any e){
				if(get('environment') eq 'production'){
					return "";
				}
				throw("An error occurred when retrieving the key from the resource bundle");
			}
			
			if(get('environment') eq 'production'){
				return "";
			}
			throw("Key or bundle does not exist in resource bundles");
		</cfscript>
	</cffunction>
	
	<cffunction name="localeMessageFormat" returntype="any" output="false">
		<cfargument name="pattern" type="string" required="true"/>
		<cfargument name="args" type="array" required="true"/>
		<cfargument name="locale" type="string" default="#getCurrentLocale()#"/>
		<cfscript>
			return $getJavaRB().messageFormat(arguments.pattern,arguments.args,arguments.locale);
		</cfscript>
	</cffunction>
	
	<cffunction name="setCurrentLocale">
		<cfargument name="locale" type="string" required="true"/>
		<cfset session.locale = arguments.locale/>
	</cffunction>
	
	<cffunction name="getCurrentLocale" returntype="any" output="false">
		<cfscript>
			
			if(structKeyExists(session,"locale"))
				return session.locale;
			
			return $getDefaultLocale();
		</cfscript>
	</cffunction>
	
	<cffunction name="$getDefaultLocale" returntype="any" output="false">
		<cfscript>
			returnLocale = "en";
			
			try{
				returnLocale = get('defaultLocale');
			}
			catch(any e){}
			
			return returnLocale;
		</cfscript>
	</cffunction>	
	
	<cffunction name="reinitializeLocaleRB">
		<cfset $getJavaRB(true)/>
		<cfset $getResourceBundleStruct(true)/>
	</cffunction>
	
	<cffunction name="$getResourceBundleStruct" returntype="any">
		<cfargument name="reinitialize" type="boolean" default="false"/>
		
		<cfif !isDefined("application.resourceBundles") OR arguments.reinitialize>
			<cflock timeout="20" scope="application">
				<cfscript>
					//Create the application variable that will hold all of the bundles
					application.resourceBundles = structNew();
			
					localeFiles = directoryList(getDirectoryFromPath(getBaseTemplatePath()) & "locale",true,'path','*.properties');
			
					//Loop through all files, and set the appropriate application variables
					for (i=1;i lte ArrayLen(localeFiles);i=i+1) {
						//First check if it starts with a '.' - we should disregard this. This could be from resource forks, etc
						if(!reFind("(\\\.)|(/\.)",localeFiles[i])){
							localeFile = reMatch("[^\\/]*$",localeFiles[i])[1];
							fileNoExt = reReplace(localeFile,"\.[^.]*$","");
					
							split = reFind("_",fileNoExt);
					
							//If no underscore was found, we assume default language
							bundleName = fileNoExt;
							locale = $getDefaultLocale();
					
							//Otherwise, get what it really should be
							if(split gt 0){
								bundleName = left(fileNoExt,split - 1);
								locale = right(fileNoExt,Len(fileNoExt) - split);
							}
					
					
							//If the bundle doesn't exist, create it
							if(!structKeyExists(application.resourceBundles,bundleName)){
								application.resourceBundles[bundleName] = structNew();
							}
					
							//If the locale doesn't exist create it (We allow for mixing of files - not sure when you would want to do this)
							if(!structKeyExists(application.resourceBundles[bundleName],locale)){
								application.resourceBundles[bundleName][locale] = structNew();
							}
					
							resourceBundle = $getJavaRB().getResourceBundle(getDirectoryFromPath(localeFiles[i]) & bundleName & ".properties",locale);
					
							//Merge the resource bundle into the struct
							structAppend(application.resourceBundles[bundleName][locale],resourceBundle);
						}	
					}
				</cfscript>
			</cflock>
		</cfif>
		
		<cfreturn application.resourceBundles/>
		
	</cffunction>
	
	<cffunction name="$getJavaRB" returntype="any">
		<cfargument name="reinitialize" type="boolean" default="false"/>
		<cfif !isDefined("application.javaRB") OR arguments.reinitialize>
			<cflock timeout="5" scope="application">
				<cfset application.javaRB = createObject("component","javaRB")/>
			</cflock>
		</cfif>
		<cfreturn application.javaRB/>
	</cffunction>
	
</cfcomponent>