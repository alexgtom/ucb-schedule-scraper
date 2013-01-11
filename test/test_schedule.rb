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
                 HtmlTokenizer.new("<table></table>").to_a)
    assert_equal(["<table>", "hello", "</table>"], 
                 HtmlTokenizer.new("<table>hello</table>").to_a)
    assert_equal(["hello"], 
                 HtmlTokenizer.new("hello").to_a)
    assert_equal([], 
                 HtmlTokenizer.new("").to_a)
    assert_equal(["<table>"], 
                 HtmlTokenizer.new("<table>").to_a)
    assert_equal(["<>"], 
                 HtmlTokenizer.new("<>").to_a)
    assert_equal(["<"], 
                 HtmlTokenizer.new("<").to_a)
    assert_equal(["<<<<"],
                 HtmlTokenizer.new("<<<<").to_a)
    assert_equal([">"], 
                 HtmlTokenizer.new(">").to_a) 
    assert_equal([">>>>"], 
                 HtmlTokenizer.new(">>>>").to_a)
    assert_equal(["hello"], 
                 HtmlTokenizer.new("   hello   ").to_a)
    assert_equal(["hello world"], 
                 HtmlTokenizer.new("   hello world   ").to_a)
    assert_equal(["<a>", "<a>", "<a>"], 
                 HtmlTokenizer.new("   <a>   <a>   <a>   ").to_a)
  end
end
