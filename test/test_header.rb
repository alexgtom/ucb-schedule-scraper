require 'testing_env'

class HeaderTests < Test::Unit::TestCase
  def setup
    @header = Header.new
  end

  def test_parse_table
    @header.parse_table(open("#{SCHEDULE_CASES}/header_table.html").read)
    assert_equal("#{SCHEDULE_CASES}/multi_page_2.html", @header.next_url)
    assert_equal("307", @header.num_matches)
  end

  def test_parse_url
    @header.send(:parse_next_url, "<A HREF=\"#{SCHEDULE_CASES}/multi_page_2.html\">see next results")
    assert_equal("#{SCHEDULE_CASES}/multi_page_2.html", @header.next_url)

    @header.send(:parse_next_url, "<A HREF=\"/multi_page_2.html\">see next results")
    assert_equal("#{SCHEDULE_URL}/multi_page_2.html", @header.next_url)
  end
end
