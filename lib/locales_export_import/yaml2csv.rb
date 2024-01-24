require 'yaml'
require 'csv'

module LocalesExportImport
  module Yaml2Csv
    extend self

    def convert(input_files, output_file, pattern = nil)
      @arr = ::Array.new
      @locales = ::Array.new
      @current_locale_index = 0
      @total_locales = input_files.length
      input_files.each_with_index do |input_file, index|
        input_data = ::YAML.load_file(::File.join(input_file))
        input_data.keys.each do |key|
          # 1st level should contain only one key -- locale code
          @locales << key
          @current_locale_index = index
          construct_csv_row('', input_data[key], pattern)
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
          if @current_locale_index != 0 && (existing_key_index = @arr.find_index {|el| el.first == key})
            current_val = @arr[existing_key_index][1..-1]
            current_val[@current_locale_index] = value
            @arr[existing_key_index] = current_val.insert(0, key)
          else
            current_val = ::Array.new(@total_locales, '')
            current_val[@current_locale_index] = value
            @arr << current_val.insert(0, key)
          end
        end
      when ::Array
        # ignoring arrays to avoid having duplicate keys in CSV
        # value.each { |v| construct_csv_row(key, v) }
      when ::Hash
        value.keys.each { |k|
          dot_key = key.present? ? "#{key}.#{k}" : k
          construct_csv_row(dot_key, value[k], pattern)
        }
      end
    end

  end
end
