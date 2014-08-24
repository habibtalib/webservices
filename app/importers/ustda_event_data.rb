require 'open-uri'
require 'csv'

class UstdaEventData
  include Importer

  ENDPOINT = 'http://www.ustda.gov/events/USTDATradeEvents.csv'

  COLUMN_HASH = {
    id:                 :id,
    event_name:         :event_name,
    description:        :description,
    start_date:         :start_date,
    end_date:           :end_date,
    cost:               :cost,
    registration_link:  :registration_link,
    registration_title: :registration_title,
    url:                :url,
    country1:           :country,
    state1:             :state,
    city1:              :city,
    venue1:             :venue,
    industry:           :industries,
  }.freeze

  EMPTY_RECORD = {
    id:                 '',
    event_name:         '',
    description:        '',
    start_date:         '',
    end_date:           '',
    cost:               '',
    registration_link:  '',
    registration_title: '',
    url:                '',
    country:            '',
    state:              '',
    city:               '',
    venue:              '',
    event_type:         'FIXME',
    industries:         [],
    contacts:           [],
  }.freeze

  def initialize(resource = ENDPOINT)
    @resource = resource
  end

  def import
    Rails.logger.info "Importing #{@resource}"
    UstdaEvent.index events
  end

  def events
    fh = open(@resource, 'r:UTF-8')
    fh.readline # Remove 'Last Updated: ...'
    content = fh.read.encode('UTF-16le', invalid: :replace).encode('UTF-8')
    doc = CSV.parse(content, headers: true, header_converters: :symbol, encoding: 'UTF-8')
    doc.map { |entry| process_entry entry.to_h }.compact
  end

  private

  def process_entry(entry)
    event = sanitize_string_hash remap_keys(COLUMN_HASH, entry)

    %i(start_date end_date).each do |field|
      event[field] = Date.strptime(event[field], '%m/%d/%Y').iso8601 rescue nil if event[field]
    end

    event[:country] &&= lookup_country(event[:country])
    event[:industries] = Array(event[:industries])
    event[:contacts] = [
      entry
        .slice(:first_name, :last_name, :post, :person_title, :phone, :email)
        .map { |k, v| { k => v.blank? ? '' : v.strip } }
        .reduce(:merge),
    ]
    EMPTY_RECORD.dup.merge(event)
  end
end