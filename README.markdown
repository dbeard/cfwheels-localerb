LocaleRB - CFWheels
========================

[localerb]: http://cfg11n.blogspot.com/2006/03/javarbrbjava-cfcs-updated.html "LocaleRB"
[resourceb]: http://java.sun.com/developer/technicalArticles/Intl/ResourceBundles/ "Resource Bundles"

LocaleRB provides the easiest to use locale class for CFWheels. Using the locale cfcs created by [Paul Hastings][localerb] and [Java's built in ResourceBundles][resourceb], you can easily make your site translate across different locales. 

Installation
------------

After installing the plugin, there is one configuration option available, which can be set in your `settings.cfm` inside the `config` folder:

	set(defaultLocale="es_ES");
	
This sets the default locale that will be used in the application when no other locale is set for the user's session.

LocaleRB uses java's resource bundle format for creating the different translations. These bundles are stored in a `locale` folder off of the root of the CFWheels application. You will need to create this.

###.properties files

LocaleRB uses .properties files for storing the translations. The naming of these files is important. For example `email_en_US.properties` would create an `email` bundle that contains the `en_US` translations. Likewise, you could make one for the spanish version by creating `email_es_ES.properties`. There is a default bundle that can be made called `global` which can simplify your code (see Usage) if you don't want to make several different bundles (i.e. `global_en_US.properties`).

For information on how to enter the translations in the file see [Wikipedia](http://en.wikipedia.org/wiki/.properties). The `.properties` files contain simple key value pairs:

	Day=Day
	Month=Month
	Year=Year
	
	Day=Dia
	Month=Mes
	Year=Ano

Inside the `locale` folder, simply create as many `.properties` files as needed for you application with the translations. LocaleRB will recursively scan this folder for all `.properties` files, so you can store bundles together in a folder if wanted, etc. With that, you should be ready to start using the methods.

Usage
----------

LocaleRB comes with several handy methods for retrieving translations and localizing strings.

### `$(key,[locale])`

This is the main function. Returns the value associated with the key passed. Optionally pass the locale wanted. Defaults to either the set locale for the user, or the default locale for the site.

####Examples

Retrieve the key 'hello' in the `email` bundle:

	$('email.hello') = "Hello"
	$('email.hello','es_ES') = "Hola"
	
Retrieve the key 'goodbye' in the `global` bundle:

	$('goodbye') = "Goodbye"
	$('global.goodbye','es_ES') = "Adios"
	
If you remember, the `global` bundle is the default, so you don't need to pass the bundle necessarily in these cases - it defaults to `global`.

### `localeMessageFormat(pattern,args,[locale])`

Returns string with dynamic values substituted. See [http://download.oracle.com/javase/1.4.2/docs/api/java/text/MessageFormat.html](http://download.oracle.com/javase/1.4.2/docs/api/java/text/MessageFormat.html) for more information. Locale is optional.

### `setCurrentLocale(locale)`

Sets the current locale for the user. Stored in the session scope. Example:

	setCurrentLocale('fr_FR')

### `getCurrentLocale()`

Returns the current locale being used for the user. Pulled from either the default locale or session scope.

### `reinitializeLocaleRB()`

Re-initializes the locale struct stored in the application scope. Use this to re-read the `.properties` files.

Building From Source
--------------------

	rake build

History
------------

Version 0.1 - Initial Release