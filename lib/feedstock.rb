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
      literal, path, type = unpack rule
      @info[name] = if literal.nil?
                      match = page.at_css path
                      format match, type
                    else
                      literal
                    end
    end

    @info
  end

  def extract_entries(page = nil, rules = nil)
    page ||= @page
    rules ||= @rules
    literals = Hash.new
    @entries = Array.new

    rules['entries'].each do |name, rule|
      literal, path, type = unpack rule
      next literals.merge!({ name => literal }) unless literal.nil?
      page.css(path).each.with_index do |match, i|
        @entries[i] = Hash.new if @entries[i].nil?
        @entries[i].merge!({ name => format(match, type) })
      end
    end

    unless literals.empty?
      @entries.each{ |entry| entry.merge!(literals) }
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
      literal = rule["literal"]
      path = rule["path"]
      type = rule["type"]
    else
      literal = nil
      path = rule
      type = "text"
    end

    [literal, path, type]
  end

  private def format(match, type)
    return "" if match.nil?

    case type
    when "cdata"
      match.inner_html
    when "datetime"
      Timeliness.parse match.content
    else
      match.content
    end
  end
end
