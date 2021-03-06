#!/usr/bin/env ruby

require 'uri'
require 'optparse'
require 'open-uri'
require 'json'
require 'date'

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

SCHEDULE_URL = "http://osoc.berkeley.edu"
SEPERATOR = "****"
MAX_COL_SIZE = 50

def schedule_url(params={})
  # adds "p_ to beginning of each key in params
  renamed_params = Array.new(params.map {|k, v| ["p_#{k.to_s}", v]})

  "#{SCHEDULE_URL}/OSOC/osoc?#{URI.encode_www_form(renamed_params)}"
end

def truncate(str, max_length=MAX_COL_SIZE)
  if str.length > MAX_COL_SIZE
    str[0..max_length].gsub(/\s\w+$/, '...')
  else
    str
  end
end

DATETIME_YEAR = 2015
DATETIME_MONTH = 1
DATETIME_MON = 5
DATETIME_TUE = 6
DATETIME_WED = 7
DATETIME_THU = 8
DATETIME_FRI = 9
DATETIME_SAT = 10
DATETIME_SUN = 11

SCHEDULE_DAY_TIME_LOCATION_RE = "((M|Tu|W|Th|F|Sa|Su|SA|SU|T)+) (.+), (.*)"
SCHEDULE_DAY_TIME_LOCATION_UNKNOWN_RE = "(CANCELLED|UNSCHED NOFACILITY|TBA)"
SCHEDULE_MAX_CLASS_LENGTH_MINUTES = 5 * 60  # 8 hours

class Query < Array
  @@row_title =  {
      :department => "Department",
      :department_abrev => "Dept. Abrev.",
      :course_num => "Course Num",
      :course_control_numer => "CCN",
      :section_type => "Type",
      :ps => "P/S",
      :section_num => "Section Num",
      :title => "Title",
      :location => "Location",
      :instructor => "Instructor",
      :note => "Note",
      :units => "Units",
      :final_exam_group => "Final Exam Group",
      :restrictions => "Restrictions",
      :limit => "Limit",
      :enrolled => "Enrolled",
      :waitlist => "Waitlist",
      :available_seats => "Avail. Seats",
      :enrollment_message => "Enrollment Msg.",
      :enrollment_updated => "Enrollment Updated",
      :status_last_changed => "Last Changed",
      :session_start => "Session Start",
      :session_end => "Session End",
      :course_website => "Course Website",
  }

  def self.row_title
    @@row_title
  end

  def initialize(parameters={}, options={:attributes => Section.attributes}, show_progress=false)
    @num_matches = 0
    @attributes = options[:attributes]
    @show_progress = show_progress
    @parameters = parameters

    if parameters.has_key? :url
      parse_page(parameters[:url])
    else
      p schedule_url(parameters)
      parse_page(schedule_url(parameters))
    end

    raise "Number of courses parsed doesnt match total number of courses" unless self.length == @num_matches

    print_progress
  end

  def parse_page(url)
    file = open(url)
    content = file.read

    tables = content.scan(/<\s*TABLE[^>]*>.*?<\/TABLE>/m)
    header_table = tables.shift
    tables.pop # pop footer table

    header = Header.new
    header.parse_table(header_table)

    @num_matches = header.num_matches

    print_progress

    tables.each do |table|
      section = Section.new
      section.parse_table(table)
      section.term = header.term
      section.term_year = header.term_year
      self << section
    end

    if header.start_row + 100 < header.num_matches
      @parameters[:start_row] = header.start_row + 100
      parse_page(schedule_url(@parameters))
    end

  end

  def print_progress(fp=$stderr)
    if @show_progress
      fp.puts "#{self.size} out of #{@num_matches} courses processed"
    end
  end

  def print_tabular(fp=$stdout)
    # find max size of each column
    max_size = {}
    @attributes.each do |attr|
      max_size[attr] = (self.map{ |section|
        truncate(section.send(attr).to_s).size
        } + [truncate(@@row_title[attr]).size])
      .max
    end

    # print header
    fp.puts @attributes.map { |attr|
        "%#{max_size[attr]}s" % truncate(@@row_title[attr]) }
        .join(" | ")

    # print rows
    self.each do |section|
      fp.puts @attributes.map { |attr|
          "%#{max_size[attr]}s" % truncate(section.send(attr).to_s) }
          .join(" | ")
    end
  end

  def csv

  end

  def to_json
    self.map{ |section| JSON.load(section.to_json) }.to_json
  end
end

class Header
  attr_reader :num_matches, :start_row, :end_row, :term, :term_year
  def initialize
    @num_matches = nil
    @start_row = nil
    @end_row = nil
    @term = nil
    @term_year = nil
  end

  def parse_table(str)
    parse_num_matches(str)
  end

  private

  def parse_num_matches(str)
    match = str.match("Displaying ([0-9]+)-([0-9]+) of ([0-9]+) matches to your request for <.*>([a-zA-Z]+)\s+([0-9]+)")
    @num_matches = match[3].to_i
    @start_row = match[1].to_i
    @end_row = match[2].to_i
    @term = match[4]
    @term_year = match[5].to_i
  end
end

class Section
  @@attributes = [
      :department,
      :department_abrev,
      :course_num,
      :course_control_numer,
      :section_type,
      :ps,
      :section_num,
      :title,
      :locations,
      :locations_status,
      :instructors,
      :note,
      :units,
      :final_exam_group,
      :restrictions,
      :limit,
      :enrolled,
      :waitlist,
      :available_seats,
      :enrollment_message,
      :enrollment_updated,
      :status_last_changed,
      :session_start,
      :session_end,
      :course_website,
      :term,
      :term_year,
  ]

  @@attributes.each { |attr| attr_accessor attr }

  def self.attributes
    @@attributes
  end

  def initialize
    @@attributes.each { |attr| self.instance_variable_set("@#{attr.to_s}", nil)}
  end

  def parse_table(str)
    parse_department_abrev(str)

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

  def to_json
    hash = {}
    @@attributes.map{
      |attr| hash[attr] = self.instance_variable_get("@#{attr.to_s}")
    }
    hash.to_json
  end

  private
  def parse_department_abrev(str)
    match = str.match("NAME=\"p_dept_cd\" VALUE=\"([^\"]*)\"")
    @department_abrev = match[1]
  end

  def parse_course(str)
    match = str.match("(.+) (.+) (.) (.+) (...)")
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
    if not @locations
      @locations = []
    end

    if match = str.match(SCHEDULE_DAY_TIME_LOCATION_UNKNOWN_RE)
      @locations_status = match[1]
    elsif match = str.match(SCHEDULE_DAY_TIME_LOCATION_RE)
      days = match[2]
      time = match[3]
      building = match[4]

      if days == "MTWTF"
        days = "MTuWThF"
      end

      # parse times
      start_time, end_time = time.split('-')
      #start_time = start_time.to_i

      if end_time.include? 'P'
        end_time.tr!("P", "")
        is_pm = true
      else
        end_time.tr!("A", "")
        is_pm = false
      end
      #end_time = end_time.to_i

      t = start_time.match(/(\d{1,2})(\d\d)?$/)
      start_hour = t[1].to_i
      start_minute = t[2].to_i

      t = end_time.match(/(\d{1,2})(\d\d)?$/)
      end_hour = t[1].to_i
      end_minute = t[2].to_i

      if end_hour >= start_hour
        if is_pm
          if start_hour < 12 and end_hour < 12
            start_hour += 12
            end_hour += 12
          end
        else
          # do nothing
        end
      else
        if is_pm
          if end_hour < 12
            end_hour += 12
          end
        end
      end

      duration = (end_hour * 60 + end_minute) - (start_hour * 60 + start_minute)

      ##over_max_class_length = end_time - start_time > SCHEDULE_MAX_CLASS_LENGTH_HOURS
      #if (end_hour * 60 + end_minute) - (start_hour * 60 + start_minute) > SCHEDULE_MAX_CLASS_LENGTH_MINUTES
      #  start_hour += 12
      #end

      # times are now in the form 800 or 2400
      day_map = {
        'M' => DATETIME_MON,
        'Tu' => DATETIME_TUE,
        'W' => DATETIME_WED,
        'Th' => DATETIME_THU,
        'F' => DATETIME_FRI,
        'Sa' => DATETIME_SAT,
        'SA' => DATETIME_SAT,
        'Su' => DATETIME_SUN,
        'SU' => DATETIME_SUN,
      }

      day_map.each do |day, day_date|
        DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_MON, start_hour).iso8601
        if days.include?(day)
          @locations.push({
            "building" => building,
            "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, day_date, start_hour, start_minute).iso8601,
            "duration" => duration,
          })
        end
      end
    end
  end

  def parse_instructor(str)
    if not @instructors
      @instructors = []
    end

    str.strip!

    match = str.match(/([A-Z\s\-,]+)$/)
    if match
      @instructors.push(match[1].strip)
    end
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
    if match = str.match(/Also:(.*)/)
      match[1].split(";").collect{|x| x.strip}.each do |e|
        if e.match(SCHEDULE_DAY_TIME_LOCATION_RE) or e.match(SCHEDULE_DAY_TIME_LOCATION_UNKNOWN_RE)
          # another location
          parse_location(e)
        else
          # another insturctor
          parse_instructor(e)
        end
      end
    end
    @note = str
  end

  def parse_enrollment_on_date(str)
    @enrollment_updated = str.match("([0-9]+\/[0-9]+\/[0-9]+):$")[1]
  end

  def parse_enrollment(str)
    if str == "SEE DEPT"
      @limit = @enrolled = @waitlist = @available_seats = nil
    elsif match = str.match("Limit:([0-9]+) Enrolled:([0-9]+) Waitlist:([0-9]+) Avail Seats:([0-9]+)")
      @limit = match[1].to_i
      @enrolled = match[2].to_i
      @waitlist = match[3].to_i
      @available_seats = match[4].to_i
    end
  end

  def to_s
    "[ #{@@attributes.map{
      |attr| "#{attr.to_s}: \"#{self.instance_variable_get("@#{attr.to_s}")}\""
    }.join(', ')} ]"
  end
end


if __FILE__ == $PROGRAM_NAME
  # command line arguments
  attributes = Section.attributes
  format = "table"
  parameters = Hash.new{|hash, key| hash[key] = Array.new}

  OptionParser.new do |opts|
    opts.banner = "Usage: schedule.rb [options]"

    opts.on("--term TERM") do |ext|
        parameters[:term].push ext
    end

    opts.on("--format [FORMAT]") do |ext|
        format = ext
    end

    opts.on("--deptname [DEPARTMENT NAME]") do |ext|
        parameters[:deptname].push ext
    end

    opts.on("--classif [COURSE CLASSIFICATIONS]") do |ext|
        parameters[:classif].push ext
    end

    opts.on("--presuf [COURSE PREFIXES/SUFFIXES]") do |ext|
        parameters[:presuf].push ext
    end

    opts.on("--dept [DEPARTMENT ABREVIATION]") do |ext|
        parameters[:dept].push ext
    end

    opts.on("--course [COURSE NUMBER]") do |ext|
        parameters[:course].push ext
    end

    opts.on("--title [COURSE TITLE KEYWORD]") do |ext|
        parameters[:title].push ext
    end

    opts.on("--instr [INSTRUCTOR NAME]") do |ext|
        parameters[:instr].push ext
    end

    opts.on("--exam [FINAL EXAM GROUP]") do |ext|
        parameters[:exam].push ext
    end

    opts.on("--ccn [COURSE CONTROL NUMBER]") do |ext|
        parameters[:ccn].push ext
    end

    opts.on("--day [DAYS]") do |ext|
        parameters[:day].push ext
    end

    opts.on("--hour [HOURS]") do |ext|
        parameters[:hour].push ext
    end

    opts.on("--bldg [BUILDING NAME]") do |ext|
        parameters[:bldg].push ext
    end

    opts.on("--units [UNITS]") do |ext|
        parameters[:units].push ext
    end

    opts.on("--restr [RESTRICTIONS]") do |ext|
        parameters[:restr].push ext
    end

    opts.on("--info [INFORMATION]") do |ext|
        parameters[:info].push ext
    end

    opts.on("--updt [STATUS/LAST CHANGED]") do |ext|
        parameters[:updt].push ext
    end

    opts.on("--attributes [list]",
              "The columns to show on the output format",
              "Ex. --attributes department,title will",
              "output only the department and the title") do | list |
      attributes = list.split(",")
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!


  #Query.new(parameters, {:attributes => attributes}, show_progress=true)

  # main program
  #p schedule_page(:term => "FL", :dept => "CHEM")
  #Query.new('test/schedule_cases/section.html')
  #Query.new('test/schedule_cases/single_page.html')
  #Query.new({:url => 'test/schedule_cases/multi_page_1.html'}, {:attributes => [:department, :units, :title]}).print_tabular
  #Query.new({:term => "FL", :dept => "COMPSCI"}, {:attributes => [:department, :section_type, :units, :title, :instructor, :location]}).print_tabular
  #Query.new({:term => "FL", :dept => "COMPSCI"}).print_tabular
  #Query.new({:term => "FL", :dept => "COMPSCI"}, {:attributes => [:department, :units, :title]}).print_tabular
  #puts JSON.parse(Query.new({:term => "FL", :dept => "COMPSCI"}, {:attributes => [:department, :units, :title]}).to_json)
  #JSON.parse(Query.new({:term => "FL", :dept => "COMPSCI"}, {:attributes => [:department, :units, :title]}).to_json)
  JSON.parse(Query.new({:term => "FL", :classif => "L"}, {:attributes => [:department, :units, :title]}).to_json)
  #puts JSON.pretty_generate(JSON.parse(Query.new({:term => "FL", :dept => "COMPSCI"}, {:attributes => [:department, :units, :title]}).to_json))
  #url = schedule_url(:term => "FL", :classif => "O")
  #p url
  #p "Total Courses: #{Query.new(url).size}"

end

