require 'spec_helper'

describe ScreeningList::IsnData do
  before { ScreeningList::Isn.recreate_index }
  let(:fixtures_dir) { "#{Rails.root}/spec/fixtures/screening_lists/isn" }
  let(:fixtures_file) { "#{fixtures_dir}/isn.csv" }
  let(:importer) { described_class.new(fixtures_file) }
  let(:expected) { YAML.load_file("#{fixtures_dir}/results.yaml") }

  it_behaves_like 'an importer which can purge old documents'

  describe '#import' do
    it 'loads ISN entries from specified resource' do
      expect(ScreeningList::Isn).to receive(:index) do |isn|
        expect(isn).to eq(expected)
      end
      importer.import
    end
  end
end