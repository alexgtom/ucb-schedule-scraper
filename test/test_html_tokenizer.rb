require 'testing_env'

class HtmlTagTests < Test::Unit::TestCase
  def test_main
    assert_equal('abc', HtmlTag.new('abc'))
    assert_equal('abc', HtmlTag.new('ABC'))
    assert_equal('abc', HtmlTag.new('AbC'))
    assert_equal('abc', HtmlTag.new(:abc))
    assert_equal('abc', HtmlTag.new(:aBc))
  end
end

class HtmlTokenizerTests < Test::Unit::TestCase
  def test_output_tokens
    assert_equal(["<table>", "</table>"], 
                 HtmlTokenizer.new("<table></table>"))
    assert_equal(["<table>", "hello", "</table>"], 
                 HtmlTokenizer.new("<table>hello</table>"))
    assert_equal(["hello"], 
                 HtmlTokenizer.new("hello"))
    assert_equal([], 
                 HtmlTokenizer.new(""))
    assert_equal(["<table>"], 
                 HtmlTokenizer.new("<table>"))
    assert_equal(["<>"], 
                 HtmlTokenizer.new("<>"))
    assert_equal(["<"], 
                 HtmlTokenizer.new("<"))
    assert_equal(["<<<<"],
                 HtmlTokenizer.new("<<<<"))
    assert_equal([">"], 
                 HtmlTokenizer.new(">")) 
    assert_equal([">>>>"], 
                 HtmlTokenizer.new(">>>>"))
    assert_equal(["hello"], 
                 HtmlTokenizer.new("   hello   "))
    assert_equal(["hello world"], 
                 HtmlTokenizer.new("   hello world   "))
    assert_equal(["<a>", "<a>", "<a>"], 
                 HtmlTokenizer.new("   <a>   <a>   <a>   "))
  end
  
  def test_shift_until
    t = HtmlTokenizer.new("<a><b><table>hello</hello>")
    assert_equal(["<a>", "<b>", "<table>"], t.shift_until(:text))
    assert_equal("hello", t.first)

    t = HtmlTokenizer.new("")
    assert_equal([], t)
    assert_equal(nil, t.shift_until(:text))
    assert_equal([], t)
  end

  def test_pop_until
    t = HtmlTokenizer.new("<a><b><table>hello</hello>")
    assert_equal(["<b>", "<table>", "hello", "</hello>"], t.pop_until(:b))
    assert_equal("<a>", t.last)

    t = HtmlTokenizer.new("")
    assert_equal([], t)
    assert_equal(nil, t.pop_until(:text))
    assert_equal([], t)
  end

  def test_find_tag_index
    t = HtmlTokenizer.new("<a><b><table>hello</hello>")
    assert_equal(0, t.find_tag_index('a') )
    assert_equal(1, t.find_tag_index('b') )
    assert_equal(4, t.find_tag_index('/hello') )
  end
end


class HtmlTokenTests < Test::Unit::TestCase
  def test_attribute
    assert_equal("b", HtmlToken.new('<a href="b">')['href']) 
    assert_equal("b", HtmlToken.new('<a href="b">')[:HREF]) 
    assert_equal("b", HtmlToken.new('<a href="b">')['HREF']) 
    assert_equal("b", HtmlToken.new('  <  a href="b">  ')['href']) 
    assert_equal("b", HtmlToken.new('<a href=\'b\'>')['href']) 
    assert_equal("_blank", 
                 HtmlToken.new('<a href="b" target=\'_blank\'>')['target']) 
    assert_equal(nil, HtmlToken.new('<a>')['href']) 
  end

  def test_tag
    assert_equal('a', HtmlToken.new('<a>').tag)
    assert_equal('a', HtmlToken.new('<a href="">').tag)
    assert_equal('/a', HtmlToken.new('</a>').tag)
    assert_equal('/a', HtmlToken.new('</ a>').tag)
    assert_equal('/a', HtmlToken.new('< / a>').tag)
    assert_equal('/a', HtmlToken.new('< /a>').tag)
    assert_equal('text', HtmlToken.new('a').tag) 
  end
end

