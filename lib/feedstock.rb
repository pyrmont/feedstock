# frozen_string_literal: true

require "erb"
require "nokogiri"
require "open-uri"
require "timeliness"

class Feedstock
  def initialize(url, rules, template_file = nil)
    @url = url
    @rules = rules
    @template_file = template_file || "default.xml"

    @page = nil
    @info = nil
    @entries = nil
    @feed = nil
  end

  def feed
    return @feed unless @feed.nil?

    download_page
    extract_info
    extract_entries
    create_feed

    @feed
  end

  def download_page(url = nil)
    url ||= @url
    @page = Nokogiri::HTML open(url)
  end

  def extract_info(page = nil, rules = nil)
    page ||= @page
    rules ||= @rules
    @info = Hash.new
    
    rules['info'].each do |name, rule|
      path, type = unpack rule
      page.css(path).each do |match|
        @info[name] = format match.content, type
      end
    end

    @info
  end

  def extract_entries(page = nil, rules = nil)
    page ||= @page
    rules ||= @rules
    @entries = Array.new

    rules['entries'].each do |name, rule|
      page.css(rule).each.with_index do |match, i|
        @entries[i] = Hash.new if @entries[i].nil?
        content = name.end_with?("!") ? match.inner_html
                                      : match.content
        @entries[i].merge!({ name => content })
      end
    end

    @entries
  end

  def create_feed(template_file = nil, info = nil, entries = nil)
    template_file ||= @template_file
    info ||= @info
    entries ||= @entries

    template = ERB.new File.read(template_file), trim_mode: ">"
    @feed = template.result_with_hash info: info, entries: entries
  end

  private def unpack(rule)
    if rule.is_a? Hash
      path = rule["path"]
      type = rule["type"]
    else
      path = rule
      type = "text"
    end

    [path, type]
  end

  private def format(content, type)
    return content if type == "text"

    case type
    when "datetime"
      Timeliness.parse content
    end
  end
end
