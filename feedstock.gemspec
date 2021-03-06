# frozen_string_literal: true

require "./lib/feedstock/version"

Gem::Specification.new do |s|
  s.name = "feedstock"
  s.version = Feedstock::VERSION
  s.authors = ["Michael Camilleri"]
  s.email = ["mike@inqk.net"]
  s.summary = "A library for creating RSS feeds from webpages"
  s.description = <<-desc.strip.gsub(/\s+/, " ")
    Feedstock is a Ruby library for extracting information from an HTML/XML
    document and inserting it into an ERB template.
  desc
  s.homepage = "https://github.com/pyrmont/feedstock/"
  s.licenses = "Unlicense"
  s.required_ruby_version = ">= 2.7"
  s.metadata = {
    "documentation_uri" => "https://github.com/pyrmont/feedstock/blob/v0.3.0/api.md"
  }

  s.files = Dir["Gemfile", "default.xml", "LICENSE", "README.md",
                "feedstock.gemspec", "lib/feedstock.rb", "lib/**/*.rb"]
  s.require_paths = ["lib"]

  s.metadata["allowed_push_host"] = "https://rubygems.org"

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "timeliness"

  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "warning"
end
