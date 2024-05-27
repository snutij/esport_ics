# frozen_string_literal: true

module EsportIcs
  module LeagueOfLegends
    class Mapper
      def initialize(events)
        @events = events
        @matches = []
      end

      def to_matches!
        @events.map do |event|
          @matches << Dto::Match.new(
            id: event.fetch("id"),
            name: event.fetch("name"),
            **schedule(event),
            **teams(event),
            **league(event),
          )
        end

        @matches
      end

      private

      def schedule(event)
        {
          startTime: Time.strptime(Time.parse(event.fetch("scheduledAt")).to_s, "%Y-%m-%d %H:%M:%S"),
          endTime: Time.strptime((Time.parse(event.fetch("scheduledAt")) + (60 * 60)).to_s, "%Y-%m-%d %H:%M:%S"),
        }
      end

      def teams(event)
        {
          teams: event.fetch("teams", []).map do |team|
            Dto::Team.new(
              id: team.fetch("id"),
              name: team.fetch("name"),
              code: team.fetch("code"),
            )
          end,
        }
      end

      def league(event)
        {
          league: Dto::League.new(
            id: event.fetch("league").fetch("id"),
            name: event.fetch("league").fetch("name"),
            code: event.fetch("league").fetch("code"),
          ),
        }
      end
    end
  end
end
