task create_lines: [:environment] do
  Station.all.each do |station|
    FetchStationTripsJob.perform_later(station)
  end
end
