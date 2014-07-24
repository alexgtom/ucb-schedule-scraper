require 'testing_env'

class HeaderTests < Test::Unit::TestCase
  def setup
    @header = Header.new
  end

  def test_parse_table
    @header.parse_table(open("#{SCHEDULE_CASES}/header_table.html").read)
    assert_equal(307, @header.num_matches)
  end
end
