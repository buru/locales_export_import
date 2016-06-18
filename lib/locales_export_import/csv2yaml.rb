require 'yaml'
require 'csv'

module LocalesExportImport
  module Csv2Yaml
    extend self

    def convert(input_file, output_path = nil, file_prefix = nil)
      @yaml = ::Hash.new
      ::CSV.foreach(::File.join(input_file), :headers => true) do |row|
        puts "inspect: #{row.inspect}"
        key = row['key'].strip
        row.headers.each do |header|
          if header && header.end_with?('_value')
            locale = header.partition('_').first
            unless @yaml.has_key?(locale)
              locale_file = ::File.join("#{locale}.yml")
              @yaml[locale] = ::File.exists?(locale_file) ? ::YAML.load_file(locale_file) : ::Hash.new
            end
            value = row[header]
            key_for_locale = [locale, key.partition('.').last].join('.')
            puts "adding key: #{key_for_locale}"
            add_value_to_tree(@yaml[locale], key_for_locale, value) unless value.nil? || value.empty?
          end
        end
      end
      puts "Resulting structure: #{@yaml.inspect}"
      output_files = ::Array.new
      @yaml.keys.each do |locale|
        output_file = ::File.join(*[output_path, "#{file_prefix}#{locale}.yml"].compact)
        ::File.write(output_file, @yaml[locale].to_yaml)
        output_files << output_file
      end
      return output_files, @yaml
    end

    def add_value_to_tree(hash, key, value)
      if !key.include?('.')
        hash[key] = value if hash.is_a?(::Hash)
      else
        head, _, tail = key.partition('.')
        hash[head] = ::Hash.new unless hash.has_key?(head)
        add_value_to_tree(hash[head], tail, value)
      end
    end

  end
end
