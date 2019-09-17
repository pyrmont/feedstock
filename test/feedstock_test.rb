# frozen_string_literal: true

require "minitest/autorun"
require "warning"

Gem.path.each do |path|
  Warning.ignore(//, path)
end

require_relative "../lib/feedstock.rb"

class FeedstockTest < Minitest::Test
  def setup
    @fs = Feedstock.new nil, nil, nil
  end

  def test_initialize
    url = "test/data/test.html"
    rules = { "info" => Hash.new, "entries" => Hash.new }
    fs = Feedstock.new url, rules
    assert_equal 7, fs.instance_variables.size
    assert_equal url, fs.instance_variable_get(:@url)
    assert_equal rules, fs.instance_variable_get(:@rules)
  end

  def test_feed
    # @fs.feed
  end

  def test_download_page
    url = "test/data/test.html"
    @fs.download_page url
   
    assert_equal Nokogiri::HTML::Document,
                 @fs.instance_variable_get(:@page).class
  end

  def test_extract_info
    page = Nokogiri::HTML("<html><body>
                          <h1>A title</h1>
                          <h2>A summary</h2>
                          </body></html>") 
    rules = { "info" => { "title" => "h1", "summary" => "h2" } }
    @fs.extract_info page, rules

    assert_equal({"title" => "A title",
                  "summary" => "A summary" },
                 @fs.instance_variable_get(:@info))
  end

  def test_extract_entries
    page = Nokogiri::HTML("<html><body>
                          <div><h1>Title 1</h1><h2>Summary 1</h2></div>
                          <div><h1>Title 2</h1><h2>Summary 2</h2></div>
                          </body></html>") 

    rules = { "entries" => { "title" => "h1", "summary" => "h2" } }
    @fs.extract_entries page, rules

    assert_equal [ { "title" => "Title 1",
                     "summary" => "Summary 1" },
                   { "title" => "Title 2",
                     "summary" => "Summary 2" } ],
                 @fs.instance_variable_get(:@entries)
    
    rules = { "entries" => { "content" => { "path" => "div",
                                            "type" => "cdata" } } }
    @fs.extract_entries page, rules

    assert_equal [ { "content" => "<h1>Title 1</h1>\n<h2>Summary 1</h2>" },
                   { "content" => "<h1>Title 2</h1>\n<h2>Summary 2</h2>" } ],
                 @fs.instance_variable_get(:@entries)
  end

  def test_create_feed
    template_file = "default.xml"
    info = { "id" => "https://example.org/", "title" => "A feed", "updated" => "1/1/1977" }
    
    entries = [ { "id" => "https://example.org/1", "title" => "A post", "updated" => "1/1/1977" },
                { "id" => "https://example.org/2", "title" => "A post", "updated" => "1/1/1977" } ]
    @fs.create_feed template_file, info, entries

    assert File.read("test/data/feed1.xml"), @fs.instance_variable_get(:@feed)
    
    entries = [ { "id" => "https://example.org/1",
                  "title" => "A post",
                  "updated" => "1/1/1977",
                  "content" => "Some <em>content</em>!" } ]
    @fs.create_feed template_file, info, entries

    assert File.read("test/data/feed2.xml"), @fs.instance_variable_get(:@feed)
  end
end
