require 'open-uri'
require 'csv'
require 'digest/md5'

module ScreeningList
  class UvlData
    include ::Importer
    include ScreeningList::CanGroupRows

    self.group_by = [:name]

    ENDPOINT = 'http://www.bis.doc.gov/index.php/forms-documents/doc_download/1053-unverified-list'

    def initialize(resource = ENDPOINT)
      @resource = resource
    end

    def import
      Rails.logger.info "Importing #{@resource}"
      rows = CSV.parse(open(@resource).read, encoding: 'UTF-8').map do |row|
        { country: row[0],
          name:    row[1],
          address: row[2] }
      end

      docs = group_rows(rows).map do |id, grouped|
        process_grouped_rows(id, grouped)
      end

      model_class.index(docs)
    end

    private

    def process_grouped_rows(id, rows)
      doc = {
        name:                   rows.first[:name],
        id:                     id,
        source:                 model_class.source,
        source_list_url:        'http://www.bis.doc.gov/enforcement/unverifiedlist/unverified_parties.html',
        source_information_url: 'http://www.bis.doc.gov/index.php/policy-guidance/lists-of-parties-of-concern/unverified-list',
      }

      doc[:addresses] = rows.map do |row|
        { address:     row[:address],
          city:        nil,
          state:       nil,
          postal_code: nil,
          country:     lookup_country(row[:country]) }
      end.uniq

      doc[:alt_names] =
        rows.map { |row| row[:name].split(', a.k.a. ') }
          .flatten
          .uniq
          .delete_if { |alt_name| alt_name == doc[:name] }

      doc
    end
  end
end