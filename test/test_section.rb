require 'testing_env'
require 'json'
require 'date'

class SectionTests < Test::Unit::TestCase
  def setup
    @section = Section.new
  end

  def test_parse_table
    @section.parse_table(open('test/schedule_cases/single_table.html').read)

    # Department Abreviation
    assert_equal("AFRICAM", @section.department_abrev)

    # Course
    assert_equal("AFRICAN AMERICAN STUDIES", @section.department)
    assert_equal("C301", @section.course_num)
    assert_equal("P", @section.ps)
    assert_equal("001", @section.section_num)
    assert_equal("SEM", @section.section_type)

    # Course Title
    assert_equal("Critical Pedagogy: Instructor Training", @section.title)

    # Location
    assert_equal([{
      "status" => nil,
      "building" => "102 BARROWS",
      "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_WED, 3).iso8601,
      "end_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_WED, 6).iso8601,
    }], @section.location)

    # Instructor
    assert_equal(["TAYLOR, U Y"], @section.instructor)

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

  def test_json
    @section.parse_table(open('test/schedule_cases/single_table.html').read)
    hash = JSON.load(@section.to_json)
    Section.attributes.map { |attr| assert(hash.has_key?(attr.to_s), "#{attr} missing")}
  end

  def test_parse_location
    @section.send(:parse_location, "CANCELLED")
    assert_equal("CANCELLED", @section.location_status)
    assert_equal([], @section.location)

    @section.send(:parse_location, "UNSCHED NOFACILITY")
    assert_equal("UNSCHED NOFACILITY", @section.location_status)
    assert_equal([], @section.location)

    @section.send(:parse_location, "TBA")
    assert_equal("TBA", @section.location_status)
    assert_equal([], @section.location)
  end

  def test_parse_enrollment
    @section.send(:parse_enrollment, "SEE DEPT")
    assert_equal("SEE DEPT", @section.limit)
    assert_equal("SEE DEPT", @section.enrolled)
    assert_equal("SEE DEPT", @section.waitlist)
    assert_equal("SEE DEPT", @section.available_seats)

  end

  def test_parse_course
    @section.send(:parse_course, "COMPUTER SCIENCE 399 P 1-29 IND")
    assert_equal("COMPUTER SCIENCE", @section.department)
    assert_equal("399", @section.course_num)
    assert_equal("P", @section.ps)
    assert_equal("1-29", @section.section_num)
    assert_equal("IND", @section.section_type)
  end

  def test_parse_note
    @section = Section.new
    @section.send(:parse_note, "Also: SCAIEF, A L; SEINO, J; FONG, D T; Th 9-11A, 300 MINOR ADDITN; Th 10-11A, 300 MINOR ADDITN; Th 8-10A, 300 MINOR ADDITN")
    assert_equal(["SCAIEF, A L", "SEINO, J", "FONG, D T"], @section.instructor)

    @section = Section.new
    @section.send(:parse_location, "Th 10-11A, ")
    @section.send(:parse_note, "Also: HARVEY, P L; Tu 8-9A, 489 MINOR")
    assert_equal(["HARVEY, P L"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: MASON, L B")
    assert_equal(["MASON, L B"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: KASKUTAS, L A; CHERPITEL, C J")
    assert_equal(["KASKUTAS, L A", "CHERPITEL, C J"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: W 7-8P, 18 BARROWS")
    @section = Section.new
    @section.send(:parse_note, "Also: HERNANDEZ-RODRIGUE")
    assert_equal(["HERNANDEZ-RODRIGUE"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: STUDENTTEACHER, A")
    assert_equal(["STUDENTTEACHER, A"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: BIOLSI, T J; UNSCHED NOFACILITY")
    assert_equal(["BIOLSI, T J"], @section.instructor)

    @section = Section.new
    @section.send(:parse_note, "Also: ESQUER, D; Basketball MARTIN, C L; Crew TETI, M F; Football DYKES, D; Golf DESIMONE, S R; Gymnastics MCCLURE, B D; Soccer GRIMES, K; Swimming DURANTE, D L; Tennis WRIGHT, P T; Track and Field SANDOVAL, A M; Water Polo EVERIST, K F; Weight Training. For Intercollegiate Athletes only. CCNs can be obtained through your Athletic Study Center academic advisor. BLASQUEZ, M S")
    assert_equal([
      "ESQUER, D", "MARTIN, C L", "TETI, M F", "DYKES, D", "DESIMONE, S R", "MCCLURE, B D", "GRIMES, K", "DURANTE, D L", "WRIGHT, P T", "SANDOVAL, A M", "EVERIST, K F", "BLASQUEZ, M S"
    ], @section.instructor)
  end
end
