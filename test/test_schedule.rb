require 'testing_env'

class ScheduleTests < Test::Unit::TestCase
  def test_schedule_url
    assert_equal("#{SCHEDULE_URL}", schedule_url())
    assert_equal("#{SCHEDULE_URL}p_term=FL", schedule_url(:term => "FL"))
    assert_equal("#{SCHEDULE_URL}p_term=FL&p_dept=CHEM", 
                 schedule_url(:term => "FL", :dept => "CHEM"))
  end

end

class HtmlTokenizerTests < Test::Unit::TestCase
  def test_output_tokens
    assert_equal(["<table>", "</table>"], 
                 HtmlTokenizer.new("<table></table>").each{|v| v})
    assert_equal(["<table>", "hello", "</table>"], 
                 HtmlTokenizer.new("<table>hello</table>").each{|v| v})
    assert_equal(["hello"], 
                 HtmlTokenizer.new("hello").each{|v| v})
    assert_equal([], 
                 HtmlTokenizer.new("").each{|v| v})
    assert_equal(["<table>"], 
                 HtmlTokenizer.new("<table>").each{|v| v})
    assert_equal(["<>"], 
                 HtmlTokenizer.new("<>").each{|v| v})
    assert_equal(["<"], 
                 HtmlTokenizer.new("<").each{|v| v})
    assert_equal(["<<<<"],
                 HtmlTokenizer.new("<<<<").each{|v| v})
    assert_equal([">"], 
                 HtmlTokenizer.new(">").each{|v| v}) 
    assert_equal([">>>>"], 
                 HtmlTokenizer.new(">>>>").each{|v| v})
    assert_equal(["hello"], 
                 HtmlTokenizer.new("   hello   ").each{|v| v})
    assert_equal(["hello world"], 
                 HtmlTokenizer.new("   hello world   ").each{|v| v})
    assert_equal(["<a>", "<a>", "<a>"], 
                 HtmlTokenizer.new("   <a>   <a>   <a>   ").each{|v| v})
  end
end
