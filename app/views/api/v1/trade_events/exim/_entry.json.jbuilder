json.id(entry[:_id])
json.call(entry[:_source],
          :event_name,
          :start_date,
          :end_date,
          :registration_link,
          :description,
          :url,
          :city,
          :state,
          :country,
          :industries,
          :source,
)