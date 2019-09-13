# frozen_string_literal: true

require "minitest/autorun"

require_relative "../lib/feedstock.rb"

class FeedstockTest < Minitest::Test
  def test_initialization
    url = "http://example.com/"
    rules = Hash.new
    fs = Feedstock.new(url, rules)

    assert_equal fs.instance_variables.size, 2
    assert_equal fs.instance_variable_get(:@url), url
    assert_equal fs.instance_variable_get(:@rules), rules
  end
end
