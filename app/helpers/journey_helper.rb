module JourneyHelper
  def duration_for(journey)
    journey_in_hours = journey.duration / 60
    journey_in_days = journey_in_hours / 24

    minutes = "minutes"
    minutes = "minute" if (journey.duration % 60) < 2

    hours = "hours"
    hours = "hour" if journey_in_hours < 2

    modulo_hours = "hours"
    modulo_hours = "hour" if (journey_in_hours % 24) < 2

    days = "days"
    days = "day" if journey_in_days < 2

    if journey_in_hours < 24
      "<strong>#{journey_in_hours}</strong> #{hours} and <strong>#{journey.duration % 60}</strong> #{minutes}"
    else
      "<strong>#{journey_in_days}</strong> #{days} and <strong>#{journey_in_hours % 24}</strong> #{modulo_hours}"
    end
  end
end
