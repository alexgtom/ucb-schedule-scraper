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
HTML_ATTRIBUTE_SINGLE_QUOTES = /[^"]+/
HTML_ATTRIBUTE_DOUBLE_QUOTES = /[^']+/
HTML_ATTRIBUTE_REGEX = /(#{HTML_ATTRIBUTE_NO_QUOTES}|#{HTML_ATTRIBUTE_DOUBLE_QUOTES}|#{HTML_ATTRIBUTE_SINGLE_QUOTES})/

def schedule_url(params={})
  # adds "p_ to beginning of each key in params
  renamed_params = Hash[params.map {|k, v| ["p_#{k.to_s}", v]}]

  "#{SCHEDULE_URL}#{URI.encode_www_form(renamed_params)}"
end

def read_page(url)
  file = open(url)
  content = file.read

  tokenizer = HtmlTokenizer.new(content)

  while not tokenizer.empty?
    token = tokenizer.shift
  end
end

def tag_name(html)
  html = html.strip.slice(1..-1).strip

  if html != '/'
    html.match(HTML_TAG_REGEX)[0].downcase
  else
    tag_name(html) 
  end
end

class HtmlTokenizer < Array
  def initialize(page)
    @char_pos = 0

    # strip leading and ending whitespace
    page.strip!
  
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

  private

  def tag_token(page)
    token = ""

    while @char_pos < page.length and page[@char_pos] != '>'
      token << page[@char_pos]
      @char_pos += 1
    end

    token << page[@char_pos] if @char_pos < page.length
    @char_pos += 1

    self << token
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
      self << token.strip
    end
  end
end

class HtmlTag < Hash
  def initialize(html)
    html.strip!
    html.sub!(/^<\s*\/?\s*/, '').sub!(/\s*>$/, '')

    html = tag_name(html)
    while not html.empty?
      html = pair(html)
      p html
    end
  end

  private
  
  def tag_name(html)
    if html =~ HTML_TAG_REGEX
      self[:tag_name] = html.match(HTML_TAG_REGEX)[0]
      html.sub!(HTML_TAG_REGEX, '') 
    end
    html.strip
  end

  def pair(html)
    key = attribute(html)
    html.sub!(HTML_TAG_REGEX, '')
    self[key] = value(html)
    html.sub!(HTML_ATTRIBUTE_REGEX, '')
    html.lstrip
  end

  def attribute(html)
    html.lstrip!
    html.match(HTML_TAG_REGEX)[0].downcase.to_sym
  end

  def value(html)
    html.lstrip!
    if html[0] == "="
      html.sub!(/=/, '')
      html.lstrip!
      if html =~ HTML_ATTRIBUTE_NO_QUOTES
        html.match(HTML_ATTRIBUTE_NO_QUOTES)[0]
      else
        html.match(/(#{HTML_ATTRIBUTE_SINGLE_QUOTES}|#{HTML_ATTRIBUTE_DOUBLE_QUOTES})/)[0][1..-2]
      end
    else
      nil
    end
  end
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
  read_page('test/schedule_cases/section.html')

end

