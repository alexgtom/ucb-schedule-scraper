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
    tokenizer.shift_until("table")
    header_tokenizer = tokenizer.shift_until("/table")
    
    # sections
    begin
      tokenizer.shift_until("table")
      section_tokenizer = tokenizer.shift_until("/table")
    end while section_tokenizer
  end
end

class Section 
  def initialize(tokenizer)
    begin
      course(tokenizer)                 if tokenizer.first =~ /^Course:/
      course_title(tokenizer)           if tokenizer.first =~ /^Course Title:/
      location(tokenizer)               if tokenizer.first =~ /^Location:/
      instructor(tokenizer)             if tokenizer.first =~ /^Instructor:/
      status_last_changed(tokenizer)    if tokenizer.first =~ /^Status\/Last Changed:/
      course_control_number(tokenizer)  if tokenizer.first =~ /^Course Control Number:/
      units_credit(tokenizer)           if tokenizer.first =~ /^Units\/Credit:/
      final_exam_group(tokenizer)       if tokenizer.first =~ /^Final Exam Group:/
      restrictions(tokenizer)           if tokenizer.first =~ /^Restrictions:/
      note(tokenizer)                   if tokenizer.first =~ /^Note:/
      enrollment_on(tokenizer)          if tokenizer.first =~ /^Enrollment on /
      enrollment_information(tokenizer) if tokenizer.first =~ /^Enrollment /
    end while tokenizer.first !=~ /^Course:/
  end

  private
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
    while self.first.tag.to_s != attr.to_s
      tokenizer << self.shift
    end
    
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

class HtmlToken < String
  def initialize(str)
    str.strip!
    super(str)
  
    if str[0] != '<'
      @tag = :text
    else
      match = self.match(/^<\s*(\/?)\s*(#{HTML_TAG_REGEX})/)
      if match
        @tag = match[1] + match[2]
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
  Query.new('test/schedule_cases/section.html')

end

