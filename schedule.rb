#!/usr/bin/env ruby

require 'uri'
require 'optparse'
require 'open-uri'
# Sample URLs:
#   Term
#       p_term = {FL, SP, SU}
#   Course Classifications
#       p_classif = {L, U, G, P, M, D, O}
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_classif=L
#   Department Name
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_deptname=Aerospace+Studies
#   Course Prefixes/Suffixes
#       p_presuf = {C, H, N, R, W, AC}
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_presuf=C
#   Department Abbreviation
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_dept=CHEM
#   Course Number
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_course=1A
#   Course Title Keyword
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_title=DATABASE
#   Instructor Name
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_instr=SMITH
#   Final Exam Group
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_exam=7
#   Course Control Number
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_ccn=57303
#   Day(s) of the Week
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_day=M
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_day=TuTh
#   Hour(s)
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_hour=930-11
#   Building Name
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_bldg=DWINELLE
#   Units/Credit
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_units=2
#   Restrictions
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_restr=NONE
#   Additional Information
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_info=SWIMMING
#   Status/Last Changed
#       http://osoc.berkeley.edu/OSOC/osoc?p_term=FL&p_updt=UPDATED

SCHEDULE_URL = "http://osoc.berkeley.edu/OSOC/osoc?"

HTML_TAG_REGEX = /[a-zA-Z][a-zA-Z0-9]*/
HTML_ATTRIBUTE_NO_QUOTES = /[^\s"']+/
HTML_ATTRIBUTE_SINGLE_QUOTES = /'([^']+)'/
HTML_ATTRIBUTE_DOUBLE_QUOTES = /"([^"]+)"/

def schedule_url(params={})
  # adds "p_ to beginning of each key in params
  renamed_params = Hash[params.map {|k, v| ["p_#{k.to_s}", v]}]

  "#{SCHEDULE_URL}#{URI.encode_www_form(renamed_params)}"
end

class Query < Array
  def initialize(url)
    file = open(url)
    content = file.read

    tokenizer = HtmlTokenizer.new(content)

    # header
    header_tokenizer = tokenizer.shift_until("/table")
    header_tokenizer << tokenizer.shift # deletes "</table>"

    # footer
    footer_tokenizer = tokenizer.pop_until("table")
    # sections
    while tokenizer.shift_until("table") and tokenizer.size > 0
      section_tokenizer = tokenizer.shift_until("/table")
      section_tokenizer << tokenizer.shift

      section = Section.new
      section.parse(section_tokenizer)
    end
  end
end

class Section 
  def initialize
    @department = nil
    @department_abrev = nil
    @course_num = nil
    @course_control_numer = nil
    @section_type = nil
    @section_num = nil
    @class_type = nil
    @title = nil
    @location = nil
    @instructor = nil
    @note = nil
    @units = nil
    @final_exam_group = nil
    @restrictions = nil
    @limit = nil
    @enrolled = nil
    @waitlist = nil
    @available_seats = nil
    @enrollment_message = nil
    @status_last_changed = nil
    @session_start = nil
    @session_end = nil
    @course_website = nil
    @days = nil
    @room = nil
    @time = nil
  end
  def parse(tokenizer)
    text_tokens = HtmlTokenizer.new('')
    input_tokens = HtmlTokenizer.new('')
    
    # get text and input tokens
    while tokenizer.first.tag != '/table'
      token = tokenizer.shift
      if token.tag == :text
        text_tokens << token
      elsif token.tag == :input
        input_tokens << token 
      end
    end
    
    while text_tokens.size > 0
      label = text_tokens.shift

      if label =~ /^Course:/
        course(text_tokens.shift)                 
      elsif label =~ /^Course Title:/
        course_title(text_tokens.shift)           
      elsif label =~ /^Location:/
        location(text_tokens.shift)               
      elsif label =~ /^Instructor:/
        instructor(text_tokens.shift)             
      elsif label =~ /^Status\/Last Changed:/
        status_last_changed(text_tokens.shift)    
      elsif label =~ /^Course Control Number:/
        course_control_number(text_tokens.shift)  
      elsif label =~ /^Units\/Credit:/
        units_credit(text_tokens.shift)           
      elsif label =~ /^Final Exam Group:/
        final_exam_group(text_tokens.shift)       
      elsif label =~ /^Restrictions:/
        restrictions(text_tokens.shift)           
      elsif label =~ /^Note:/
        note(text_tokens.shift)                   
      elsif label =~ /^Enrollment on /
        enrollment_on_date(label)
        enrollment(text_tokens.shift)          
      else
        text_tokens.shift
      end
    end
  end

  private

  def course(str)
  end

  def course_title(str)

  end

  def location(str)

  end

  def instructor(str)

  end

  def status_last_changed(str)

  end

  def course_control_number(str)

  end

  def units_credit(str)

  end

  def final_exam_group(str)

  end

  def restrictions(str)

  end

  def note(str)

  end

  def enrollment_on_date(str)

  end

  def enrollment(str)

  end
end


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


if __FILE__ == $PROGRAM_NAME
  # command line arguments
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options]"

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      options[:verbose] = v
    end
  end.parse!
  p options
  p ARGV

  # main program
  #p schedule_page(:term => "FL", :dept => "CHEM")
  #Query.new('test/schedule_cases/section.html')
  Query.new('test/schedule_cases/single_page.html')

end

