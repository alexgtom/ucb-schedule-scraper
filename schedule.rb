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
SEPERATOR = "****"

def schedule_url(params={})
  # adds "p_ to beginning of each key in params
  renamed_params = Hash[params.map {|k, v| ["p_#{k.to_s}", v]}]

  "#{SCHEDULE_URL}#{URI.encode_www_form(renamed_params)}"
end

class Query < Array
  def initialize(url)
    file = open(url)
    content = file.read
    
    tables = content.scan(/<\s*TABLE[^>]*>.*?<\/TABLE>/m)
    header_table = tables.shift
    footer_table = tables.pop

    tables.each do |table|
      section = Section.new
      section.parse_table(table)
      self << section
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

  def parse_table(str)
    str.gsub!(/<\/?TD>/, SEPERATOR)
    str.gsub!(/(<\/?[^>]+>|\n|&#[0-9]+;|&nbsp;?)/, '')
    str.gsub!(/\s+/, ' ')

    text_tokens = str.split(SEPERATOR)

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

