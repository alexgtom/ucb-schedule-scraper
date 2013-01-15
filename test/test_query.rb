require 'testing_env'

class QueryTests < Test::Unit::TestCase
  def test_single_page
    assert_equal(85, Query.new({:url => "#{SCHEDULE_CASES}/single_page.html"}).size)
  end

  def test_multi_page
    assert_equal(307, Query.new({:url => "#{SCHEDULE_CASES}/multi_page_1.html"}).size)
  end
end
