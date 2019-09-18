# frozen_string_literal: true

require "minitest/autorun"
require "warning"

Gem.path.each do |path|
  Warning.ignore(//, path)
end

require "feedstock"

class FeedstockTest < Minitest::Test
  def setup
  end

  def test_feed
    # @fs.feed
  end

  def test_create_feed
    template_file = "default.xml"
    info = { "id" => "https://example.org/", "title" => "A feed", "updated" => "1970-01-01T00:00:00+09:00" }

    entries = [ { "id" => "https://example.org/1", "title" => "A post", "updated" => "1970-01-01T00:00:00+09:00" },
                { "id" => "https://example.org/2", "title" => "A post", "updated" => "1970-01-01T00:00:00+09:00" } ]
    feed = Feedstock.create_feed info, entries, template_file

    assert_equal File.read("test/data/feed1.xml"), feed

    entries = [ { "id" => "https://example.org/1",
                  "title" => "A post",
                  "updated" => "1970-01-01T00:00:00+09:00",
                  "content" => "<![CDATA[Some <em>content</em>!]]>" } ]
    feed = Feedstock.create_feed info, entries, template_file

    assert_equal File.read("test/data/feed2.xml"), feed
  end

  def test_download_page
    url  = "test/data/test.html"
    page = Feedstock.download_page url
   
    assert_equal Nokogiri::HTML::Document, page.class
  end

  def test_extract_entries
    page = Nokogiri::HTML("<html><body>
                           <h2>January 1970</h2>
                           <div><h1>Title 1</h1>\n<date>1/1/1970</date>\n<p>Summary 1</p></div>
                           <div><h1>Title 2</h1>\n<date>1/1/1970</date>\n<p>Summary 2</p></div>
                           </body></html>")

    rules = { "entries" => { "title" => { "path" => "h1" },
                             "updated" => { "path" => "date",
                                            "type" => "datetime" },
                             "summary" => { "path" => "p" } } }
    entries = Feedstock.extract_entries page, rules

    expected = [ { "title" => "Title 1",
                   "updated" => "1970-01-01T00:00:00+09:00",
                   "summary" => "Summary 1" },
                 { "title" => "Title 2",
                   "updated" => "1970-01-01T00:00:00+09:00",
                   "summary" => "Summary 2" } ]
    assert_equal expected, entries
    
    rules = { "entries" => { "content" => { "path" => "div",
                                            "type" => "cdata" } } }
    entries = Feedstock.extract_entries page, rules

    expected = [ { "content" => "<![CDATA[<h1>Title 1</h1>\n<date>1/1/1970</date>\n<p>Summary 1</p>]]>" },
                 { "content" => "<![CDATA[<h1>Title 2</h1>\n<date>1/1/1970</date>\n<p>Summary 2</p>]]>" } ]
    assert_equal expected, entries
    
    rules = { "entries" => { "title" => { "path" => "h1" },
                             "updated" => { "path" => "h2",
                                            "type" => "datetime",
                                            "repeat" => true,
                                            "prepend" => "1 " } } }
    entries = Feedstock.extract_entries page, rules

    expected = [ { "title" => "Title 1",
                   "updated" => "1970-01-01T00:00:00+09:00" },
                 { "title" => "Title 2",
                   "updated" => "1970-01-01T00:00:00+09:00" } ]
    assert_equal expected, entries
  end

  def test_extract_info
    page = Nokogiri::HTML("<html><body>
                           <h1>A title</h1>
                           <h2>A summary</h2>
                           </body></html>")
    rules = { "info" => { "title" => { "path" => "h1" },
                          "summary" => { "path" => "h2" } } }
    info = Feedstock.extract_info page, rules

    assert_equal({"title" => "A title", "summary" => "A summary" }, info)
  end

  def test_format_content
    page = Nokogiri::HTML("<html><body>
                          <h1>A title</h1>
                          <h2>1 January 1970</h2>
                          </body></html>")
    match1 = page.at_css("h1")
    match2 = page.at_css("h2")

    rule = Hash.new
    content = Feedstock.format_content nil, rule
    assert_equal "", content

    rule = { "type" => "cdata" }
    content = Feedstock.format_content match1, rule
    assert_equal "<![CDATA[A title]]>", content

    rule = { "type" => "datetime" }
    content = Feedstock.format_content match1, rule
    assert_equal "", content
    content = Feedstock.format_content match2, rule
    assert_equal "1970-01-01T00:00:00+09:00", content

    rule = { "type" => false }
    content = Feedstock.format_content match1, rule
    assert_equal "A title", content
  end

  def test_normalise_rules
    rules = { "info" => { "title" => { "path" => "h1" } } }
    normalised = Feedstock.normalise_rules rules
    assert_equal rules, normalised

    rules = { "info" => { "title" => "h1", "summary" => "h2" }  }
    normalised = Feedstock.normalise_rules rules
    assert_equal({ "info" => { "title" => { "path" => "h1" },
                               "summary" => {"path" => "h2" } } }, normalised)
  end

  def test_wrap_content
    rule = Hash.new
    content = Feedstock.wrap_content "Content", rule
    assert_equal "Content", content

    rule = { "prepend" => "Some " }
    content = Feedstock.wrap_content "content", rule
    assert_equal "Some content", content

    rule = { "append" => "!" }
    content = Feedstock.wrap_content "Content", rule
    assert_equal "Content!", content

    rule = { "prepend" => "'", "append" => "'?" }
    content = Feedstock.wrap_content "Content", rule
    assert_equal "'Content'?", content
  end
end
