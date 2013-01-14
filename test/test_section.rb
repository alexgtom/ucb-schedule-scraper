require 'testing_env'

class SectionTests < Test::Unit::TestCase
  def test_course
    section = Section.new
    section.send(:course, "AFRICAN AMERICAN STUDIES 602 P 001 IND")
  end
end
