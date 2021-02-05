# frozen_string_literal: true

require "erb"
require "nokogiri"
require "open-uri"
require "timeliness"

module Feedstock
  def self.feed(url, rules, format = :html, template_file = "#{__dir__}/../default.xml")
    rules   = normalise_rules rules
    page    = download_page url, format
    info    = extract_info page, rules
    entries = extract_entries page, rules
    feed    = create_feed info, entries, template_file

    feed
  end

  def self.create_feed(info, entries, template_file)
    template = ERB.new File.read(template_file), trim_mode: "-"
    template.result_with_hash info: info, entries: entries
  end

  def self.download_page(url, format)
    case format
    when :html
      Nokogiri::HTML URI.open(url)
    when :xml
      Nokogiri::XML URI.open(url)
    else
      raise "Format not recognised"
    end
  end

  def self.extract_entries(page, rules)
    if rules[:entries]
      extract_entries_wrapped page, rules
    else
      extract_entries_unwrapped page, rules
    end
  end

  def self.extract_entries_unwrapped(page, rules)
    static  = Hash.new
    entries = Array.new

    rules[:entry].each do |name, rule|
      if rule[:literal]
        static[name.to_s] = rule[:literal]
      elsif rule[:repeat]
        static[name.to_s] = format_content page.at_css(rule[:path]), rule
      else
        page.css(rule[:path]).each.with_index do |match, i|
          entries[i] = Hash.new if entries[i].nil?
          entries[i].merge!({ name.to_s => format_content(match, rule) })
        end
      end
    end

    unless static.empty?
      entries.each{ |entry| entry.merge!(static) }
    end

    entries
  end

  def self.extract_entries_wrapped(page, rules)
    entries = Array.new

    page.css(rules[:entries][:path]).each.with_index do |node, i|
      rules[:entry].each do |name, rule|
        entries[i] = Hash.new if entries[i].nil?

        content = if rule[:literal]
                    rule[:literal]
                  elsif rule[:repeat]
                    format_content page.at_css(rule[:path]), rule
                  else
                    format_content node.at_css(rule[:path]), rule
                  end

        entries[i].merge!({ name.to_s => content })
      end
    end


    return entries unless rules[:entries][:filter].is_a? Proc

    entries.filter(&rules[:entries][:filter])
  end

  def self.extract_info(page, rules)
    info = Hash.new

    rules[:info].each do |name, rule|
      if rule[:literal]
        info[name.to_s] = rule[:literal]
      else
        info[name.to_s] = format_content page.at_css(rule[:path]), rule
      end
    end

    info
  end

  def self.format_content(match, rule)
    return "" if match.nil?

    text      = extract_content match, rule
    processed = process_content text, rule
    wrapped   = wrap_content processed, rule

    case rule[:type]
    when "cdata"
      "<![CDATA[#{wrapped}]]>"
    when "datetime"
      "#{Timeliness.parse(wrapped)&.iso8601}"
    else
      wrapped
    end
  end

  def self.normalise_rules(rules)
    rules.keys.each do |category|
      case category
      when :info, :entry
        rules[category].each do |name, rule|
          rules[category][name] = { :path => rule } unless rule.is_a? Hash
        end
      when :entries
        rule = rules[category]
        rules[category] = { :path => rule } unless rule.is_a? Hash
      end
    end

    rules
  end

  def self.extract_content(node, rule)
    case rule[:content]
    in { attribute: attribute }
      node[attribute]
    in "inner_html"
      node.inner_html
    in "html" | "xml"
      node.to_s
    else
      node.content.strip
    end
  end

  def self.process_content(content, rule)
    if rule[:processor]
      rule[:processor].call content, rule
    else
      content
    end
  end

  def self.wrap_content(content, rule)
    return content unless rule[:prepend] || rule[:append]

    "#{rule[:prepend]}#{content}#{rule[:append]}"
  end
end
