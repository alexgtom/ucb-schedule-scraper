require 'testing_env'
require 'json'

class QueryTests < Test::Unit::TestCase
  def test_single_page
    assert_equal(85, Query.new({:url => "#{SCHEDULE_CASES}/single_page.html"}).size)
  end

  def test_single_page
    assert_equal(85, JSON.load(Query.new({:url => "#{SCHEDULE_CASES}/single_page.html"}).to_json).size)
  end
end
