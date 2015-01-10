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
      "building" => "102 BARROWS",
      "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_WED, 15).iso8601,
      "duration" => 180,
    }], @section.locations)

    assert_equal(nil, @location_status)

    # Instructor
    assert_equal(["TAYLOR, U Y"], @section.instructors)

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
    assert_equal(7, @section.limit)
    assert_equal(5, @section.enrolled)
    assert_equal(0, @section.waitlist)
    assert_equal(2, @section.available_seats)
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
    assert_equal("CANCELLED", @section.locations_status)
    assert_equal([], @section.locations)

    @section.send(:parse_location, "UNSCHED NOFACILITY")
    assert_equal("UNSCHED NOFACILITY", @section.locations_status)
    assert_equal([], @section.locations)

    @section.send(:parse_location, "TBA")
    assert_equal("TBA", @section.locations_status)
    assert_equal([], @section.locations)
  end

  def test_parse_enrollment
    @section.send(:parse_enrollment, "SEE DEPT")
    assert_equal(nil, @section.limit)
    assert_equal(nil, @section.enrolled)
    assert_equal(nil, @section.waitlist)
    assert_equal(nil, @section.available_seats)

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
    assert_equal(["SCAIEF, A L", "SEINO, J", "FONG, D T"], @section.instructors)
    assert_equal([
      {
        "building" => "300 MINOR ADDITN",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, 9).iso8601,
        "duration" => 120,
      },
      {
        "building" => "300 MINOR ADDITN",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, 10).iso8601,
        "duration" => 60,
      },
      {
        "building" => "300 MINOR ADDITN",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, 8).iso8601,
        "duration" => 120,
      },
    ], @section.locations)

    @section = Section.new
    @section.send(:parse_location, "Th 10-11A, 500 MINOR")
    @section.send(:parse_note, "Also: HARVEY, P L; Tu 8-9A, 489 MINOR")
    assert_equal([
      {
        "building" => "500 MINOR",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, 10).iso8601,
        "duration" => 60,
      },
      {
        "building" => "489 MINOR",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_TUE, 8).iso8601,
        "duration" => 60,
      },
    ], @section.locations)

    @section = Section.new
    @section.send(:parse_instructor, "DENERO, J")
    @section.send(:parse_note, "Also: MASON, L B")
    assert_equal(["DENERO, J", "MASON, L B"], @section.instructors)

    @section = Section.new
    @section.send(:parse_note, "Also: KASKUTAS, L A; CHERPITEL, C J")
    assert_equal(["KASKUTAS, L A", "CHERPITEL, C J"], @section.instructors)

    @section = Section.new
    @section.send(:parse_note, "Also: W 7-8P, 18 BARROWS")
    assert_equal([
      {
        "building" => "18 BARROWS",
        "start_time" => DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_WED, 19).iso8601,
        "duration" => 60,
      },
    ], @section.locations)

    @section = Section.new
    @section.send(:parse_note, "Also: HERNANDEZ-RODRIGUE")
    assert_equal(["HERNANDEZ-RODRIGUE"], @section.instructors)

    @section = Section.new
    @section.send(:parse_note, "Also: STUDENTTEACHER, A")
    assert_equal(["STUDENTTEACHER, A"], @section.instructors)

    @section = Section.new
    @section.send(:parse_note, "Also: BIOLSI, T J; UNSCHED NOFACILITY")
    assert_equal(["BIOLSI, T J"], @section.instructors)
    assert_equal("UNSCHED NOFACILITY", @section.locations_status)

    @section = Section.new
    @section.send(:parse_note, "Also: ESQUER, D; Basketball MARTIN, C L; Crew TETI, M F; Football DYKES, D; Golf DESIMONE, S R; Gymnastics MCCLURE, B D; Soccer GRIMES, K; Swimming DURANTE, D L; Tennis WRIGHT, P T; Track and Field SANDOVAL, A M; Water Polo EVERIST, K F; Weight Training. For Intercollegiate Athletes only. CCNs can be obtained through your Athletic Study Center academic advisor. BLASQUEZ, M S")
    assert_equal([
      "ESQUER, D", "MARTIN, C L", "TETI, M F", "DYKES, D", "DESIMONE, S R", "MCCLURE, B D", "GRIMES, K", "DURANTE, D L", "WRIGHT, P T", "SANDOVAL, A M", "EVERIST, K F", "BLASQUEZ, M S"
    ], @section.instructors)
  end


  def test_time
    # we're assuming theres never going to be a class that starts at 5am because
    # thats fucking insane.
    for start_hour in 5..23
      for end_hour in 0..23
        for start_minute in [0, 30]
          for end_minute in [0, 30]
            # skip invalid times
            if start_hour == 24 and start_minute == 30
              next
            end

            if end_hour == 24 and end_minute == 30
              next
            end

            start_time = DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, start_hour, start_minute)
            end_time = DateTime.new(DATETIME_YEAR, DATETIME_MONTH, DATETIME_THU, end_hour, end_minute)

            # skip more invalid times
            if start_time >= end_time
              next
            end

            if (end_time.hour * 60 + end_time.minute) - (start_time.hour * 60 + start_time.minute) > SCHEDULE_MAX_CLASS_LENGTH_MINUTES
              next
            end

            if start_minute == 0
              start_time_format = "%l"
            else
              start_time_format = "%l%M"
            end

            if end_minute == 0
              end_time_format = "%l"
            else
              end_time_format = "%l%M"
            end

            # Add am and pm to end time
            if end_hour >= 12
              end_time_format += "P"
            else
              end_time_format += "A"
            end

            duration = (end_hour * 60 + end_minute) - (start_hour * 60 + start_minute)

            @section = Section.new
            @section.send(:parse_location, "Th #{start_time.strftime(start_time_format).strip}-#{end_time.strftime(end_time_format).strip}, 500 MINOR")
            assert_equal([{
              "building" => "500 MINOR",
              "start_time" => start_time.iso8601,
              "duration" => duration,
            }], @section.locations)
          end
        end
      end
    end
    @section.send(:parse_location, "Th 10-11A, 500 MINOR")
    @section.send(:parse_note, "Also: HARVEY, P L; Tu 8-9A, 489 MINOR")
  end
end
