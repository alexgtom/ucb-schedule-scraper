HTML_TAG_REGEX = /[a-zA-Z][a-zA-Z0-9]*/
HTML_ATTRIBUTE_NO_QUOTES = /[^\s"']+/
HTML_ATTRIBUTE_SINGLE_QUOTES = /'([^']+)'/
HTML_ATTRIBUTE_DOUBLE_QUOTES = /"([^"]+)"/

class HtmlTokenizer < Array
  def initialize(page)
    @char_pos = 0

    # tokenize
    while @char_pos < page.length
      curr_char = page[@char_pos]

      if curr_char == "<"
        tag_token(page)
      else
        text_token(page)
      end
    end
  end

  def shift_until(attr)
    # shifts the tokens over until the next attr
    return nil if self.size == 0

    tokenizer = HtmlTokenizer.new('')
    while self.size > 0 and self.first.tag != attr
      tokenizer << self.shift
    end
    
    if tokenizer.size > 0
      tokenizer 
    else
      nil
    end
  end

  def find_tag_index(attr)
    # finds the location of the first occurance of attr
    self.each_with_index do |elem, i|
      if elem.tag == attr
        return i
      end
    end

    nil
  end

  def pop_until(attr)
    return nil if self.size == 0

    tokenizer = HtmlTokenizer.new('')
    while self.size > 0 and self.last.tag != attr
      tokenizer.insert(0, self.pop)
    end
    tokenizer.insert(0, self.pop)
    
    if tokenizer.size > 0
      tokenizer 
    else
      nil
    end
  end

  private

  def tag_token(page)
    token = ""

    while @char_pos < page.length and page[@char_pos] != '>'
      token << page[@char_pos]
      @char_pos += 1
    end

    token << page[@char_pos] if @char_pos < page.length
    @char_pos += 1

    self << HtmlToken.new(token)
  end

  def text_token(page)
    token = ""

    while @char_pos < page.length and page[@char_pos+1] != '<'
      token << page[@char_pos]
      @char_pos += 1
    end

    token << page[@char_pos] if @char_pos < page.length
    @char_pos += 1
    
    # prevent blank tokens from being added to token list
    if token.strip.length > 0
      self << HtmlToken.new(token.strip)
    end
  end


end

class HtmlTag < String
  def initialize(str)
    super(normalize_tag(str))
  end

  def ==(str)
    self.to_s == normalize_tag(str)
  end


  private 
  def normalize_tag(str)
    str.to_s.downcase
  end
end

class HtmlToken < String
  def initialize(str)
    str.strip!
    super(str)
  
    if str[0] != '<'
      @tag = HtmlTag.new(:text)
    else
      match = self.match(/^<\s*(\/?)\s*(#{HTML_TAG_REGEX})/)
      if match
        @tag = HtmlTag.new(match[1] + match[2])
      else
        @tag = nil
      end
    end
  end

  def [](attr)
    attr = attr.to_s

    m = self.match(/^.*#{attr}\s*=\s*/im)
    return nil if m == nil
    
    token = self.slice(m[0].length..-1)

    if token.chr == '\''
      token.match(HTML_ATTRIBUTE_SINGLE_QUOTES)[1]
    elsif token.chr == '"'
      token.match(HTML_ATTRIBUTE_DOUBLE_QUOTES)[1]
    elsif token =~ /[^\s]/
      token.match(HTML_ATTRIBUTE_NO_QUOTES)[0]
    else
      nil
    end
  end


  attr_reader :tag
end
