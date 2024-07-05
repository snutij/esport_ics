# frozen_string_literal: true

module EsportIcs
  class Team
    attr_reader :slug

    def initialize(api_team)
      @id = api_team.fetch("id")
      @name = api_team.fetch("name")
      @slug = api_team.fetch("name").parameterize
      @acronym = api_team.fetch("acronym")
    end

    def to_ical
      calendar = Icalendar::Calendar.new
      calendar.append_custom_property("slug", @slug)
      calendar.publish
      calendar
    end
  end
end
