require 'spec_helper'

describe Envirotech::BackgroundLinkData do
  let(:fixtures_file) { "#{Rails.root}/spec/fixtures/envirotech/background_link_articles/background_link_articles.json" }
  let(:importer) { described_class.new(fixtures_file) }
  let(:articles_hash) { YAML.load_file("#{File.dirname(__FILE__)}/background_link/background_link_articles.yaml") }

  it_behaves_like 'an importer which can purge old documents'

  describe '#import' do
    it 'loads background link articles from specified resource' do
      expect(Envirotech::BackgroundLink).to receive(:index) do |articles|
        expect(articles.size).to eq(2)
        2.times { |x| expect(articles[x]).to eq(articles_hash[x]) }
      end
      importer.import
    end
  end
end