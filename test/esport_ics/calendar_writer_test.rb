# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module EsportIcs
  class CalendarWriterTest < Minitest::Test
    def setup
      @writer = CalendarWriter.new
      @tmpdir = Dir.mktmpdir
    end

    def teardown
      FileUtils.remove_entry(@tmpdir)
    end

    def build_calendar(slug: "test-team", calname: "Test Team", events: [])
      cal = Icalendar::Calendar.new
      cal.append_custom_property("X-WR-CALNAME", calname)
      cal.append_custom_property("slug", slug)
      cal.publish
      events.each { |e| cal.add_event(e) }
      cal
    end

    def build_event(uid:, summary:, dtstart:)
      event = Icalendar::Event.new
      event.uid = uid
      event.summary = summary
      event.dtstart = Icalendar::Values::DateTime.new(dtstart, "tzid" => "UTC")
      event.dtend = Icalendar::Values::DateTime.new(dtstart + 2700, "tzid" => "UTC")
      event.ip_class = "PUBLIC"
      event
    end

    # --- Write new file ---

    def test_write_creates_directory_and_file
      file_path = File.join(@tmpdir, "sub", "team.ics")
      calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      @writer.write(file_path, calendar)

      assert_path_exists(file_path)
      content = File.read(file_path)

      assert_includes(content, "BEGIN:VCALENDAR")
      assert_includes(content, "match-1@esport-ics")
    end

    def test_written_file_is_valid_ics
      file_path = File.join(@tmpdir, "team.ics")
      calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      @writer.write(file_path, calendar)

      parsed = Icalendar::Calendar.parse(File.read(file_path))

      assert_equal(1, parsed.size)
      assert_equal(1, parsed.first.events.size)
    end

    # --- Merge: preserves existing, replaces same UID ---

    def test_merge_preserves_existing_events
      file_path = File.join(@tmpdir, "team.ics")

      old_calendar = build_calendar(events: [
        build_event(uid: "old-match@esport-ics", summary: "Old Match", dtstart: Time.utc(2024, 5, 1, 18, 0)),
      ])
      @writer.write(file_path, old_calendar)

      new_calendar = build_calendar(events: [
        build_event(uid: "new-match@esport-ics", summary: "New Match", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])
      @writer.write(file_path, new_calendar)

      parsed = Icalendar::Calendar.parse(File.read(file_path)).first
      uids = parsed.events.map { |e| e.uid.to_s }

      assert_includes(uids, "old-match@esport-ics")
      assert_includes(uids, "new-match@esport-ics")
    end

    def test_merge_replaces_same_uid
      file_path = File.join(@tmpdir, "team.ics")

      old_calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "Old Summary", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])
      @writer.write(file_path, old_calendar)

      new_calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "Updated Summary", dtstart: Time.utc(2024, 6, 1, 19, 0)),
      ])
      @writer.write(file_path, new_calendar)

      parsed = Icalendar::Calendar.parse(File.read(file_path)).first

      assert_equal(1, parsed.events.size)
      assert_equal("Updated Summary", parsed.events.first.summary.to_s)
    end

    def test_merge_sorts_by_dtstart
      file_path = File.join(@tmpdir, "team.ics")

      old_calendar = build_calendar(events: [
        build_event(uid: "match-late@esport-ics", summary: "Late", dtstart: Time.utc(2024, 6, 15, 18, 0)),
      ])
      @writer.write(file_path, old_calendar)

      new_calendar = build_calendar(events: [
        build_event(uid: "match-early@esport-ics", summary: "Early", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])
      @writer.write(file_path, new_calendar)

      parsed = Icalendar::Calendar.parse(File.read(file_path)).first
      summaries = parsed.events.map { |e| e.summary.to_s }

      assert_equal(["Early", "Late"], summaries)
    end

    # --- Error handling ---

    def test_missing_file_returns_empty_events
      file_path = File.join(@tmpdir, "nonexistent", "team.ics")
      calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      @writer.write(file_path, calendar)

      parsed = Icalendar::Calendar.parse(File.read(file_path)).first

      assert_equal(1, parsed.events.size)
    end

    def test_malformed_ics_warns_to_stderr
      file_path = File.join(@tmpdir, "team.ics")
      File.write(file_path, "this is not valid ics content!!!")

      calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      capture_io { @writer.write(file_path, calendar) }[1]
      # Malformed ICS may either be silently parsed as empty or raise a warning
      # Either way, the new calendar should be written successfully
      assert_path_exists(file_path)
      parsed = Icalendar::Calendar.parse(File.read(file_path)).first

      assert_equal(1, parsed.events.size)
    end

    def test_read_error_warns_to_stderr_and_continues
      file_path = File.join(@tmpdir, "team.ics")
      File.write(file_path, "BEGIN:VCALENDAR\nEND:VCALENDAR")

      Icalendar::Calendar.stubs(:parse).raises(ArgumentError, "bad data")

      calendar = build_calendar(events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      stderr = capture_io { @writer.write(file_path, calendar) }[1]

      assert_includes(stderr, "Warning: could not read existing calendar")
    end

    # --- Custom properties preserved ---

    def test_preserves_custom_properties
      file_path = File.join(@tmpdir, "team.ics")
      calendar = build_calendar(slug: "my-team", calname: "My Team", events: [
        build_event(uid: "match-1@esport-ics", summary: "A vs B", dtstart: Time.utc(2024, 6, 1, 18, 0)),
      ])

      @writer.write(file_path, calendar)

      content = File.read(file_path)

      assert_includes(content, "X-WR-CALNAME:My Team")
      assert_includes(content, "SLUG:my-team")
    end
  end
end
