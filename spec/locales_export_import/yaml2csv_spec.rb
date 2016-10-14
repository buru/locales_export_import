require 'locales_export_import'

describe ::LocalesExportImport::Yaml2Csv do

  let(:test_input_file_name)  { ::File.join('spec', 'support', 'files', 'sample_locale.yml') }
  let(:test_en_input_file_name)  { ::File.join('spec', 'support', 'files', 'sample_locale_en.yml') }
  let(:test_es_input_file_name)  { ::File.join('spec', 'support', 'files', 'sample_locale_es.yml') }
  let(:test_output_file_name) { ::File.join('spec', 'support', 'files', 'test.csv') }

  after(:each) do
    ::File.delete(test_output_file_name) if ::File.exist?(test_output_file_name)
  end

  it 'should convert yaml file to csv' do
    subject.convert([test_input_file_name], test_output_file_name)
    ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
      if $. == 2
        expect(row['key']).to eq('de-DE.views.generic.back')
        expect(row['de-DE_value']).to eq('Zurück')
      end
      if $. == 61
        expect(row['key']).to eq('de-DE.emails.email_verification.from')
        expect(row['de-DE_value']).to eq('kundenservice@blacorp.com')
      end
    end
  end

  it 'should export only values matched by regex pattern' do
    pattern = /Passwor.{1}/
    subject.convert([test_input_file_name], test_output_file_name, pattern)
    ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
      expect(row['de-DE_value']).to match(pattern)
    end
  end

  context 'when multiple locale files are loaded' do
    it 'should convert multiple locale files to csv' do
      subject.convert([test_input_file_name, test_en_input_file_name, test_es_input_file_name], test_output_file_name)
      ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
        if $. == 2
          expect(row['key']).to eq('de-DE.views.generic.back')
          expect(row['de-DE_value']).to eq('Zurück')
          expect(row['en-US_value']).to eq('Back')
          expect(row['es-ES_value']).to eq('Atras')
        end
        if $. == 6
          expect(row['key']).to eq('de-DE.views.generic.send')
          expect(row['de-DE_value']).to eq('Senden')
          expect(row['en-US_value']).to eq('Send')
          expect(row['es-ES_value']).to eq('Enviar')
        end
      end
    end
  end

  context 'when a locale file does not have a key found in at least one other locale file' do

    it 'should insert an empty string, not nil, as the value for that locale into the exported csv' do
      subject.convert([test_input_file_name, test_es_input_file_name, test_en_input_file_name], test_output_file_name)
      ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
        if $. == 4
          expect(row['key']).to eq('de-DE.views.generic.cheer')
          expect(row['de-DE_value']).to eq('Gut')
          expect(row['es-ES_value']).not_to eq(nil)
          expect(row['es-ES_value']).to eq('')
          expect(row['en-US_value']).to eq('Cheer')
        end
      end
    end
  end

  context 'when a locale file has keys not found in any previously loaded locale file(s)' do
    it 'adds the key' do
      subject.convert([test_input_file_name, test_en_input_file_name], test_output_file_name)
      keys = []
      ::CSV.foreach(test_output_file_name) { |row| keys << row[0] }
      keys_from_en_locale = keys.select { |key| key.start_with? 'en-US.' }

      expect(keys).to include('en-US.views.users.key_not_in_any_other_locale_file')
      expect(keys_from_en_locale.count).to eq(1)
    end

    it 'should insert an empty cell for any locale without a value for that key regardless of input file order' do
      subject.convert([test_en_input_file_name, test_input_file_name, test_es_input_file_name], test_output_file_name)
      ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
        key_without_locale_prefix = row['key'].partition('.').last
        if key_without_locale_prefix == 'views.pagination.last'
          expect(row['de-DE_value']).to eq('Vorige &raquo;')
          expect(row['en-US_value']).to eq('')
          expect(row['es-ES_value']).to eq('')
        end
      end

      subject.convert([test_es_input_file_name, test_input_file_name, test_en_input_file_name], test_output_file_name)
      ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
        key_without_locale_prefix = row['key'].partition('.').last
        if key_without_locale_prefix == 'views.pagination.last'
          expect(row['de-DE_value']).to eq('Vorige &raquo;')
          expect(row['en-US_value']).to eq('')
          expect(row['es-ES_value']).to eq('')
        end
      end

      subject.convert([test_input_file_name, test_es_input_file_name, test_en_input_file_name], test_output_file_name)
      ::CSV.foreach(test_output_file_name, :headers => true, encoding: 'UTF-8') do |row|
        key_without_locale_prefix = row['key'].partition('.').last
        if key_without_locale_prefix == 'views.pagination.last'
          expect(row['de-DE_value']).to eq('Vorige &raquo;')
          expect(row['en-US_value']).to eq('')
          expect(row['es-ES_value']).to eq('')
        end
      end
    end
  end
end