# frozen_string_literal: true

require "erb"
require "nokogiri"
require "open-uri"
require "timeliness"

module Feedstock
  def self.feed(url, rules, template_file = "#{__dir__}/../default.xml")
    rules   = normalise_rules rules
    page    = download_page url
    info    = extract_info page, rules
    entries = extract_entries page, rules
    feed    = create_feed info, entries, template_file

    feed
  end

  def self.create_feed(info, entries, template_file)
    template = ERB.new File.read(template_file), trim_mode: "-"
    template.result_with_hash info: info, entries: entries
  end

  def self.download_page(url)
    Nokogiri::HTML open(url)
  end

  def self.extract_entries(page, rules)
    static  = Hash.new
    entries = Array.new

    rules['entries'].each do |name, rule|
      if rule["literal"]
        static[name] = rule["literal"]
      elsif rule["repeat"]
        static[name] = format_content page.at_css(rule["path"]), rule
      else
        page.css(rule["path"]).each.with_index do |match, i|
          entries[i] = Hash.new if entries[i].nil?
          entries[i].merge!({ name => format_content(match, rule) })
        end
      end
    end

    unless static.empty?
      entries.each{ |entry| entry.merge!(static) }
    end

    entries
  end

  def self.extract_info(page, rules)
    info = Hash.new

    rules["info"].each do |name, rule|
      if rule["literal"]
        info[name] = rule["literal"]
      else
        info[name] = format_content page.at_css(rule["path"]), rule
      end
    end

    info
  end

  def self.format_content(match, rule)
    return "" if match.nil?

    text = if rule["attribute"]
             match[rule["attribute"]]
           else
             match.content.strip
           end

    case rule["type"]
    when "cdata"
      "<![CDATA[#{wrap_content(match.inner_html, rule)}]]>"
    when "datetime"
      "#{Timeliness.parse(wrap_content(text, rule))&.iso8601}"
    else
      wrap_content text, rule
    end
  end

  def self.normalise_rules(rules)
    rules.keys.each do |category|
      rules[category].each do |name, rule|
        rules[category][name] = { "path" => rule } unless rule.is_a? Hash
      end
    end

    rules
  end

  def self.wrap_content(content, rule)
    return content unless rule["prepend"] || rule["append"]

    "#{rule["prepend"]}#{content}#{rule["append"]}"
  end
end
