require 'testing_env'

class QueryTests < Test::Unit::TestCase
  def test_single_page
    assert_equal(85, Query.new({:url => "#{SCHEDULE_CASES}/single_page.html"}).size)
  end
end
