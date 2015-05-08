json.id(entry[:_id])
json.call(entry[:_source],
          :event_name,
          :start_date,
          :end_date,
          :registration_link,
          :description,
          :url,
          :industries,
          :source,
         )
json.call(entry[:_source][:venues][0].deep_symbolize_keys,
          :venue,
          :city,
          :state,
          :country,
         )
