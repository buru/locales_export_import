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
        fill_subarrays(@arr)
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
          existing_key_index = @arr.find_index { |el| el.first.partition('.').last == key.partition('.').last }

          if key_exists?(existing_key_index)
            @arr[existing_key_index] << value
          else
            max = @arr.map(&:length).max || 0
            create_subarray_with_new_key(@arr, max, key, value)
          end
        end
      when ::Array
        # ignoring arrays to avoid having duplicate keys in CSV
        # value.each { |v| construct_csv_row(key, v) }
      when ::Hash
        value.keys.each { |k| construct_csv_row("#{key}.#{k}", value[k], pattern) }
      end
    end

    private

    def fill_subarrays(arr)
      max = arr.map(&:length).max
      arr.each do |sub_a|
        while sub_a.length < max
          sub_a << ""
        end
      end
    end

    def key_exists?(existing_key_index)
      @locales.length > 1 && existing_key_index
    end

    def create_subarray_with_new_key(arr, max, key, value)
      new_sub_length = max != 0 ? max - 1 : 0
      new_sub = Array.new(new_sub_length, "")
      new_sub[0] = key
      new_sub << value
      @arr << new_sub
    end

  end
end
