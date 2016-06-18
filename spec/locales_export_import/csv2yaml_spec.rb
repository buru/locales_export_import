require 'locales_export_import'

describe ::LocalesExportImport::Csv2Yaml do

  let(:test_input_file_name)    { ::File.join('spec', 'support', 'files', 'sample_locale.csv') }
  let(:test_output_file_name)   { 'de-DE.yml' }
  let(:custom_output_file_name) { ::File.join('spec', 'support', 'files', 'custom_de-DE.yml') }

  context '#convert' do

    after(:each) do
      ::File.delete(test_output_file_name) if ::File.exist?(test_output_file_name)
      ::File.delete(custom_output_file_name) if ::File.exist?(custom_output_file_name)
    end

    it 'should convert csv file to yaml named after appropriate locale' do
      output_file_names, _ = subject.convert(test_input_file_name)
      expect(output_file_names.first).to eq(test_output_file_name)
    end

    it 'should convert csv line into a hash' do
      _, yaml_hash = subject.convert(test_input_file_name)
      expect(yaml_hash['de-DE']['de-DE']['views']['generic']['cheer']).to eq('Gut')
    end

    it 'should output to custom directory with custom prefix if output options are given' do
      output_file_names, _ = subject.convert(test_input_file_name, 'spec/support/files/', 'custom_')
      expect(output_file_names.first).to eq(custom_output_file_name)
    end 

    it 'should output to custom directory with if output path lacks trailing space' do
      output_file_names, _ = subject.convert(test_input_file_name, 'spec/support/files', 'custom_')
      expect(output_file_names.first).to eq(custom_output_file_name)
    end

    context 'edit existing locale file' do

      before(:each) do
        ::FileUtils.cp(::File.join('spec', 'support', 'files', 'de-DE.yml'), custom_output_file_name)
      end

      it 'should merge already existing output file contents with new output file with the same name' do
        _, yaml_hash = subject.convert(test_input_file_name, 'spec/support/files', 'custom_')
        expect(yaml_hash['de-DE']['de-DE']['views']['generic']['but']).to eq('aber')
      end

      it 'should override value in existing locale file' do
        _, yaml_hash = subject.convert(test_input_file_name, 'spec/support/files', 'custom_')
        expect(yaml_hash['de-DE']['de-DE']['views']['generic']['yes_please']).to eq('Ja, bitte!')
      end

    end

  end

end
