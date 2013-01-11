#!/usr/bin/env ruby

require 'uri'
require 'optparse'
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

def schedule_url(params)
  "http://osoc.berkeley.edu/OSOC/osoc?#{URI.encode_www_form(params)}"
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options]"

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      options[:verbose] = v
    end
  end.parse!
  p options
  p ARGV
  p schedule_url(:p_term => :FL, :p_dept => :CHEM)
end

