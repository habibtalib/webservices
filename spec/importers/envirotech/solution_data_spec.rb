require 'spec_helper'

describe Envirotech::SolutionData do
  include_context 'empty Envirotech indices'
  let(:fixtures_file) { "#{Rails.root}/spec/fixtures/envirotech/solution_articles/solution_articles.json" }
  let(:expected) { YAML.load_file("#{File.dirname(__FILE__)}/solution/solution_articles.yaml") }

  let(:relational_fixtures_file) { "#{Rails.root}/spec/fixtures/envirotech/relations_data/issue_solution_regulation.json" }
  let(:relational_data) { JSON.parse(open(relational_fixtures_file).read) }

  let(:importer) { described_class.new(fixtures_file) }

  before do
    Envirotech::Relationships.relational_data = relational_data
    Envirotech::Relationships.solution_ids_names = []
  end

  it_behaves_like 'an importer which can purge old documents'
  it_behaves_like 'an importer which versions resources'
  it_behaves_like 'an importer which indexes the correct documents'
end
