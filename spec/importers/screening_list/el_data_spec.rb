require 'spec_helper'

describe ScreeningList::ElData do
  before { ScreeningList::El.recreate_index }
  let(:fixtures_dir) { "#{Rails.root}/spec/fixtures/screening_lists/el" }
  let(:fixtures_file) { "#{fixtures_dir}/el.csv" }
  let(:importer) { described_class.new(fixtures_file) }
  let(:expected) { YAML.load_file("#{fixtures_dir}/results.yaml") }

  it_behaves_like 'an importer which can purge old documents'

  describe '#import' do
    it 'loads BIS entities from specified resource' do
      expect(ScreeningList::El).to receive(:index) do |el|
        expect(el).to eq(expected)
      end
      importer.import
    end
  end
end