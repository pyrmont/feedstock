# frozen_string_literal: true

require "erb"
require "nokogiri"
require "open-uri"
require "timeliness"

module Feedstock
  class Extract < Struct.new("Extract", :selector, :absolute, :content, :processor, :prefix,
                             :suffix, :type, :filter, keyword_init: true); end

  class << self
    def data(url, rules, format = :html)
      page    = download_page url, format

      info    = extract_info page, rules
      entries = extract_entries page, rules

      { info: info, entries: entries }
    end

    def feed(url, rules, format = :html, template_file = "#{__dir__}/../default.xml")
      info, entries = data(url, rules, format).values_at(:info, :entries)

      create_feed info, entries, template_file
    end

    private def create_feed(info, entries, template_file)
      template = ERB.new File.read(template_file), trim_mode: "-"
      template.result_with_hash info: info, entries: entries
    end

    private def download_page(url, format)
      case format
      when :html
        Nokogiri::HTML URI.open(url)
      when :xml
        Nokogiri::XML URI.open(url)
      else
        raise "Format not recognised"
      end
    end

    private def extract_content(node, rule)
      case rule.content
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

    private def extract_entries(page, rules)
      if rules[:entries]
        extract_entries_wrapped page, rules
      else
        extract_entries_unwrapped page, rules
      end
    end

    private def extract_entries_unwrapped(page, rules)
      static  = Hash.new
      entries = Array.new

      rules[:entry].each do |name, rule|
        if rule.is_a? String
          static[name.to_s] = rule
        elsif rule.absolute
          static[name.to_s] = format_content page.at_css(rule.selector), rule
        else
          page.css(rule.selector).each.with_index do |match, i|
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

    private def extract_entries_wrapped(page, rules)
      entries = Array.new

      page.css(rules[:entries].selector).each.with_index do |parent, i|
        rules[:entry].each do |name, rule|
          entries[i] = Hash.new if entries[i].nil?

          content = if rule.is_a? String
                      rule
                    elsif rule.absolute
                      format_content page.at_css(rule.selector), rule
                    elsif rule.selector.empty?
                      format_content parent, rule
                    else
                      format_content parent.at_css(rule.selector), rule
                    end

          entries[i].merge!({ name.to_s => content })
        end
      end


      return entries unless rules[:entries].filter.is_a? Proc

      entries.filter(&rules[:entries].filter)
    end

    private def extract_info(page, rules)
      info = Hash.new

      rules[:info].each do |name, rule|
        if rule.is_a? String
          info[name.to_s] = rule
        else
          info[name.to_s] = format_content page.at_css(rule.selector), rule
        end
      end

      info
    end

    private def format_content(match, rule)
      return "" if match.nil?

      text      = extract_content match, rule
      processed = process_content text, rule
      wrapped   = wrap_content processed, rule

      case rule.type
      when "cdata"
        "<![CDATA[#{wrapped}]]>"
      when "datetime"
        "#{Timeliness.parse(wrapped)&.iso8601}"
      else
        wrapped
      end
    end

    private def process_content(content, rule)
      if rule.processor
        rule.processor.call content, rule
      else
        content
      end
    end

    private def wrap_content(content, rule)
      return content unless (rule.prefix || rule.suffix)

      "#{rule.prefix}#{content}#{rule.suffix}"
    end
  end
end
