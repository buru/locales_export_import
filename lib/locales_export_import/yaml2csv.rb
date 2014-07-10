require 'yaml'
require 'csv'

module LocalesExportImport
  module Yaml2Csv
    extend self

    def convert(input_files, output_file, pattern = nil)
      @arr = ::Array.new
      @locales = ::Array.new
      input_files.each do |input_file|
        input_data = ::YAML.load_file(::File.join(input_file))
        input_data.keys.each do |key|
          # 1st level should contain only one key -- locale code
          @locales << key
          construct_csv_row(key, input_data[key], pattern)
        end
      end
      ::CSV.open(::File.join(output_file), 'wb') do |csv|
        # headers
        csv << ['key', *@locales.map {|l| "#{l}_value"}]
        @arr.each { |row| csv << row }
      end
    end

    def construct_csv_row(key, value, pattern)
      case value
      when ::String
        if !pattern || value =~ pattern
          if @locales.length > 1 && (existing_key_index = @arr.find_index {|el| el.first.partition('.').last == key.partition('.').last})
            @arr[existing_key_index] << value
          else
            @arr << [key, value]
          end
        end
      when ::Array
        # ignoring arrays to avoid having duplicate keys in CSV
        # value.each { |v| construct_csv_row(key, v) }
      when ::Hash
        value.keys.each { |k| construct_csv_row("#{key}.#{k}", value[k], pattern) }
      end
    end

  end
end
