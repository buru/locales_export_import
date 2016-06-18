# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locales_export_import/version'

Gem::Specification.new do |spec|
  spec.name          = 'locales_export_import'
  spec.version       = LocalesExportImport::VERSION
  spec.authors       = ['buru', 'renatocn']
  spec.email         = ['pavlozahozhenko@gmail.com']
  spec.description   = %q{Used for exporting locale yaml files to CSV format. CSV files are then being imported into Excel, edited by translators, then imported back to yaml.}
  spec.summary       = 'Used for exporting and importing locale yaml files to CSV'
  spec.homepage      = 'https://github.com/buru/locales_export_import'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 0'
  spec.add_development_dependency 'rspec', '~> 0'
end
