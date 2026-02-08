# frozen_string_literal: true

module EsportIcs
  class CalendarWriter
    def write(file_path, calendar)
      dir_path = File.dirname(file_path)
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

      existing_events = read_existing_events(file_path)
      merged_events = merge_events(existing_events, calendar)

      merged_calendar = Icalendar::Calendar.new
      calendar.custom_properties.each { |key, value| merged_calendar.append_custom_property(key, value.first) }
      merged_calendar.publish

      merged_events.values
        .sort_by { |e| e.dtstart.to_time }
        .each { |event| merged_calendar.add_event(event) }

      File.open(file_path, "w+") do |file|
        file.write(merged_calendar.to_ical)
      end
    end

    private

    def read_existing_events(file_path)
      return {} unless File.exist?(file_path)

      calendars = Icalendar::Calendar.parse(File.read(file_path))
      return {} if calendars.nil? || calendars.empty?

      calendars.first.events.each_with_object({}) do |event, hash|
        hash[event.uid.to_s] = event
      end
    rescue Errno::ENOENT, Errno::EACCES, ArgumentError => e
      $stderr.puts "Warning: could not read existing calendar #{file_path}: #{e.message}"
      {}
    end

    def merge_events(existing_events, new_calendar)
      new_events_by_uid = new_calendar.events.each_with_object({}) do |event, hash|
        hash[event.uid.to_s] = event
      end

      existing_events
        .reject { |uid, _| new_events_by_uid.key?(uid) }
        .merge(new_events_by_uid)
    end
  end
end
