# Locales Export & Import

This gem is designed to work with Rails I18n locale files, but it's not dependent on Rails, so can be also used elsewhere. Translation agencies prefer working with the tools they know, typically Excel, while ruby developers usually store localized strings in yaml files. locale_export_import helps with easy conversion between the two formats to make developer-translator interaction less painful.
  
The typical workflow of adding new locale(s) with this gem is as follows:

1. Developer exports his base locale file to CSV (currently only CSV is supported, XLSX support is planned).
2. Translator opens the file in Excel, adds one or several columns with translated texts (one column per locale).
3. Developer converts the resulting file to YML file(s) and commits the changes.

## Installation

Add this line to your application's Gemfile:

    gem 'locales_export_import'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install locales_export_import

## Usage

#### Converting locale YML file to CSV:
```
  ::LocalesExportImport::Yaml2Csv.convert(locale_file_names_array, output_file_name, pattern = nil)
```

For example:
```
  ::LocalesExportImport::Yaml2Csv.convert(['config/locales/en.yml'], 'en_keys_10_07_2014.csv')
```
Resulting CSV is in the following format:
```
key,en_value
en.views.login.remember_me,Remember me
...
```

For multiple locales at once:
```
  ::LocalesExportImport::Yaml2Csv.convert(%w[config/locales/en-UK.yml config/locales/de-DE.yml], 'en_de_keys_10_07_2014.csv')
```
And the result will be something like this:
```
key,en-UK_value,de-DE_value
en.views.login.remember_me,Remember me,Mich eingeloggt lassen
en.views.login.log_in,Log in,Einloggen
...
```
Not that each column header for translation texts should be in the format #{locale}_value

Exporting only the texts that match a certain pattern:
```
  ::LocalesExportImport::Yaml2Csv.convert(['config/locales/en.yml'], 'en_login_keys_10_07_2014.csv', /login/i)
```

#### Converting CSV back to YML:
```
  ::LocalesExportImport::Csv2Yaml.convert(csv_file_name)
````

The result will be the locale file(s) in the current working directory, one file for each locale column found in headers. E.g. if CSV file header row was "key,en-UK,de-DE,fi-FI", then the resulting files will be en-UK.yml, de-DE.yml and fi-FI.yml populated with corresponding translated strings.

Note that if you already have one or several locale files in the same folder (e.g. en-UK.yml and de-DE.yml), these files will be loaded and updated with new values. That way you can import new portion of translations to already exsisting locale file, adding only the new ones while keeping the old keys/values inatact.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
