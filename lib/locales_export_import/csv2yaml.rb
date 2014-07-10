module LocalesExportImport
  module Csv2Yaml
    extend self
  
    def convert(input_file)
      @yaml = ::Hash.new
      ::CSV.foreach(::Rails.root.join(input_file), :headers => true) do |row|
        puts "inspect: #{row.inspect}"
        key = row['key'].strip
        row.headers.each do |header|
          if header && header.end_with?('_value')
            locale = header.partition('_').first
            unless @yaml.has_key?(locale)
              locale_file = ::Rails.root.join("#{locale}.yml")
              @yaml[locale] = ::File.exists?(locale_file) ? ::YAML.load_file(locale_file) : ::Hash.new
            end
            value = row[header]
            key_for_locale = [locale, key.partition('.').last].join('.')
            puts "adding key: #{key_for_locale}"
            add_value_to_tree(@yaml[locale], key_for_locale, value) unless value.blank?
          end
        end
      end
      puts "Resulting structure: #{@yaml.inspect}"
      @yaml.keys.each do |locale|
        output_file = ::Rails.root.join("#{locale}.yml")
        ::File.write(output_file, @yaml[locale].to_yaml)
      end
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
