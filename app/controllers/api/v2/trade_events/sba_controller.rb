class Api::V2::TradeEvents::SbaController < Api::V2Controller
  include Searchable
  search_by :countries, :industry, :q
end
