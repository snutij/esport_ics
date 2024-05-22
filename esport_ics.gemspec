# frozen_string_literal: true

require_relative "lib/esport_ics/version"

Gem::Specification.new do |spec|
  spec.name = "esport_ics"
  spec.version = EsportIcs::VERSION
  spec.authors = [ "snutij" ]

  spec.summary = "Generate ics file for esport events."
  spec.homepage = "https://github.com/snutij/esport_ics"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = "true"
  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]
end
