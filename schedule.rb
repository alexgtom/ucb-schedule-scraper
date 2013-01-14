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

  def parse_page(urL)

  end
end

class Section 
  attr_reader :department           
  attr_reader :department_abrev     
  attr_reader :course_num           
  attr_reader :course_control_numer 
  attr_reader :section_type         
  attr_reader :ps
  attr_reader :section_num          
  attr_reader :class_type           
  attr_reader :title                
  attr_reader :location             
  attr_reader :instructor           
  attr_reader :note                 
  attr_reader :units                
  attr_reader :final_exam_group     
  attr_reader :restrictions         
  attr_reader :limit                
  attr_reader :enrolled             
  attr_reader :waitlist             
  attr_reader :available_seats      
  attr_reader :enrollment_message   
  attr_reader :enrollment_updated
  attr_reader :status_last_changed  
  attr_reader :session_start        
  attr_reader :session_end          
  attr_reader :course_website       
  attr_reader :days                 
  attr_reader :time                 

  def initialize
    @department           = nil
    @department_abrev     = nil
    @course_num           = nil
    @course_control_numer = nil
    @section_type         = nil
    @ps                   = nil
    @section_num          = nil
    @class_type           = nil
    @title                = nil
    @location             = nil
    @instructor           = nil
    @note                 = nil
    @units                = nil
    @final_exam_group     = nil
    @restrictions         = nil
    @limit                = nil
    @enrolled             = nil
    @waitlist             = nil
    @available_seats      = nil
    @enrollment_message   = nil
    @enrollment_updated   = nil
    @status_last_changed  = nil
    @session_start        = nil
    @session_end          = nil
    @course_website       = nil
    @days                 = nil
    @time                 = nil
  end

  def parse_table(str)
    str.gsub!(/<\/?TD>/, SEPERATOR)
    str.gsub!(/(<\/?[^>]+>|\n|&#[0-9]+;|&nbsp;?)/, '')
    str.gsub!(/\s+/, ' ')

    text_tokens = str.split(SEPERATOR).map{|token| token.strip}


    while text_tokens.size > 0
      label = text_tokens.shift
      if label =~ /^Course:/
        parse_course(text_tokens.shift)                 
      elsif label =~ /^Course Title:/
        parse_course_title(text_tokens.shift)           
      elsif label =~ /^Location:/
        parse_location(text_tokens.shift)               
      elsif label =~ /^Instructor:/
        parse_instructor(text_tokens.shift)             
      elsif label =~ /^Status\/Last Changed:/
        parse_status_last_changed(text_tokens.shift)    
      elsif label =~ /^Course Control Number:/
        parse_course_control_number(text_tokens.shift)  
      elsif label =~ /^Units\/Credit:/
        parse_units_credit(text_tokens.shift)           
      elsif label =~ /^Final Exam Group:/
        parse_final_exam_group(text_tokens.shift)       
      elsif label =~ /^Restrictions:/
        parse_restrictions(text_tokens.shift)           
      elsif label =~ /^Note:/
        parse_note(text_tokens.shift)                   
      elsif label =~ /^Enrollment on /
        parse_enrollment_on_date(label)
        parse_enrollment(text_tokens.shift)          
      end
    end
  end

  private

  def parse_course(str)
    match = str.match("(.+) (.+) (.) (...) (...)")
    @department = match[1]
    @course_num = match[2]
    @ps = match[3]
    @section_num = match[4]
    @section_type = match[5]
  end

  def parse_course_title(str)
    @title = str
  end

  def parse_location(str)
    if match = str.match("(CANCELLED|UNSCHED NOFACILITY|TBA)")
      @days = @location = @time = match[1]
    elsif match = str.match("((M|Tu|W|Th|F|Sa|Su|SA|SU|T)+) (.+), (.*)")
      @location = match[4]
      @days = match[2]
      @time = match[3]
    end
  end

  def parse_instructor(str)
    @instructor = str
  end

  def parse_status_last_changed(str)
    @status_last_changed = str
  end

  def parse_course_control_number(str)
    @course_control_numer = str
  end

  def parse_units_credit(str)
    @units = str
  end

  def parse_final_exam_group(str)
    @final_exam_group = str
  end

  def parse_restrictions(str)
    @restrictions = str
  end

  def parse_note(str)
    @note = str
  end

  def parse_enrollment_on_date(str)
    @enrollment_updated = str.match("([0-9]+\/[0-9]+\/[0-9]+):$")[1]
  end

  def parse_enrollment(str)
    if str == "SEE DEPT"
      @limit = @enrolled = @waitlist = @available_seats = "SEE DEPT"   
    elsif match = str.match("Limit:([0-9]+) Enrolled:([0-9]+) Waitlist:([0-9]+) Avail Seats:([0-9]+)")
      @limit = match[1]
      @enrolled = match[2]
      @waitlist = match[3]
      @available_seats = match[4]
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
  #Query.new('test/schedule_cases/section.html')
  Query.new('test/schedule_cases/single_page.html')

end

