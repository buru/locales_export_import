require 'locales_export_import'

describe ::LocalesExportImport::Yaml2Csv do

  let(:test_input_file_name)  { ::File.join('spec', 'support', 'files', 'sample_locale.yml') }
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

end
