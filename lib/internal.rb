# frozen_string_literal: true

require "json"
require "net/http"
require "icalendar"
require "time"
require "dotenv"
require "fileutils"
require "active_support/core_ext/string/inflections"

Dotenv.load
