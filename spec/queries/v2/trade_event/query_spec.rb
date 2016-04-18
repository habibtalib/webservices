require 'spec_helper'

describe V2::TradeEvent::Query do
  let(:fixtures_dir) { "#{File.dirname(__FILE__)}/query" }

  describe '#new' do
    it_behaves_like 'a paginated query'

    context 'when options include countries' do
      let(:query) { described_class.new(countries: 'us,ca') }

      describe '#countries' do
        subject { query.countries }
        it { is_expected.to eq(%w(US CA)) }
      end
    end
  end

  describe '#generate_search_body' do
    context 'when options include industries' do
      let(:query) { described_class.new(industries: 'fishing,hunting') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_match_industries.json").read }

      it 'generates search body with queries' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include industry' do
      let(:query) { described_class.new(industry: 'fishing,hunting') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_default_options.json").read }

      it 'should not be considered on the search' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options is an empty hash' do
      let(:query) { described_class.new }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_default_options.json").read }

      it 'generates search body with default options' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include q' do
      let(:query) { described_class.new(q: 'workboat') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_multi_match.json").read }

      it 'generates search body with queries' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include countries' do
      let(:query) { described_class.new(countries: 'IL, US') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_filters.json").read }

      it 'generates search body with filters' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include start_date' do
      let(:query) { described_class.new(start_date: '2015-08-27 TO 2015-08-28') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_start_date.json").read }

      it 'generates search body with start_date filter' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include end_date_start or end_date_end' do
      let(:query) { described_class.new(end_date: '2015-08-27 TO 2015-08-28') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_end_date.json").read }

      it 'generates search body with end_date filter' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when options include trade_regions or world_regions' do
      let(:query) { described_class.new(trade_regions: 'European Union - 28', world_regions: 'Asia') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_geo_terms.json").read }

      it 'generates search body trade_regions and world_regions filter' do
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when q includes only a country term that must be parsed' do
      let(:query) { described_class.new(q: 'china') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_parsed_country.json").read }
      let(:taxonomy_results) { YAML.load_file("#{Rails.root}/spec/models/ita_taxonomy/related_term_results.yaml") }

      it 'generates search body with parsed query' do
        allow(ItaTaxonomy).to receive(:search_related_terms).and_return([taxonomy_results.first])
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end

    context 'when q includes a world region term that must be parsed' do
      let(:query) { described_class.new(q: 'healthcare north america') }
      let(:search_body) { JSON.parse open("#{fixtures_dir}/search_body_with_parsed_world_region.json").read }
      let(:taxonomy_results) { YAML.load_file("#{Rails.root}/spec/models/ita_taxonomy/related_term_results.yaml") }

      it 'generates search body with parsed query' do
        allow(ItaTaxonomy).to receive(:search_related_terms).and_return([taxonomy_results[1]])
        expect(JSON.parse(query.generate_search_body)).to eq(search_body)
      end
    end
  end
end
