require 'testing_env'

class SectionTests < Test::Unit::TestCase
  def setup
    @section = Section.new
  end

  def test_parse_table
    @section.parse_table(open('test/schedule_cases/single_table.html').read)
    
    # Course
    assert_equal("AFRICAN AMERICAN STUDIES", @section.department)
    assert_equal("C301", @section.course_num)
    assert_equal("P", @section.ps)
    assert_equal("001", @section.section_num)
    assert_equal("SEM", @section.section_type)

    # Course Title
    assert_equal("Critical Pedagogy: Instructor Training", @section.title)

    # Location
    assert_equal("102 BARROWS", @section.location)  
    assert_equal("W", @section.days)  
    assert_equal("3-6P", @section.time)  
    
    # Instructor
    assert_equal("TAYLOR, U Y", @section.instructor)  

    # Status/Last Changed
    assert_equal("", @section.status_last_changed)  

    # Course Control Number
    assert_equal("00746", @section.course_control_numer)  

    # Units/Credit
    assert_equal("4", @section.units)  

    # Final Exam Group
    assert_equal("NONE", @section.final_exam_group)  

    # Restrictions
    assert_equal("", @section.restrictions)  

    # Note
    assert_equal("Cross-listed with Ethnic Studies Graduate Group C301 section 1.", @section.note)  

    # Enrollment On
    assert_equal("7", @section.limit)  
    assert_equal("5", @section.enrolled)  
    assert_equal("0", @section.waitlist)  
    assert_equal("2", @section.available_seats)  
    assert_equal("01/09/13", @section.enrollment_updated)  

    # assert_equal("", @section.)  
  end

  def test_parse_location
    @section.send(:parse_location, "CANCELLED")
    assert_equal("CANCELLED", @section.days) 
    assert_equal("CANCELLED", @section.location) 
    assert_equal("CANCELLED", @section.time) 

    @section.send(:parse_location, "UNSCHED NOFACILITY")
    assert_equal("UNSCHED NOFACILITY", @section.days) 
    assert_equal("UNSCHED NOFACILITY", @section.location) 
    assert_equal("UNSCHED NOFACILITY", @section.time) 

    @section.send(:parse_location, "TBA")
    assert_equal("TBA", @section.days) 
    assert_equal("TBA", @section.location) 
    assert_equal("TBA", @section.time) 
  end

  def test_parse_enrollment
    @section.send(:parse_enrollment, "SEE DEPT")
    assert_equal("SEE DEPT", @section.limit)
    assert_equal("SEE DEPT", @section.enrolled)
    assert_equal("SEE DEPT", @section.waitlist)
    assert_equal("SEE DEPT", @section.available_seats)
    
  end
end
