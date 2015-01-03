require 'testing_env'

class HeaderTests < Test::Unit::TestCase
  def setup
    @header = Header.new
  end

  def test_parse_table
    @header.parse_table(open("#{SCHEDULE_CASES}/header_table.html").read)
    assert_equal(307, @header.num_matches)
    assert_equal(1, @header.start_row)
    assert_equal(100, @header.end_row)
    assert_equal("Fall", @header.term)
    assert_equal(2012, @header.term_year)
  end
end
