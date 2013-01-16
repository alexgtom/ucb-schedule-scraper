require 'testing_env'

class ScheduleTests < Test::Unit::TestCase
  def test_schedule_url
    assert_equal("#{SCHEDULE_URL}/OSOC/osoc?", schedule_url())
    assert_equal("#{SCHEDULE_URL}/OSOC/osoc?p_term=FL", schedule_url(:term => "FL"))
    assert_equal("#{SCHEDULE_URL}/OSOC/osoc?p_term=FL&p_dept=CHEM", 
                 schedule_url(:term => "FL", :dept => "CHEM"))
    assert_equal("#{SCHEDULE_URL}/OSOC/osoc?p_term=FL&p_dept=CHEM&p_dept=POL+SCI", 
                 schedule_url(:term => "FL", :dept => ["CHEM", "POL SCI"]))
    assert_equal("#{SCHEDULE_URL}/OSOC/osoc?p_term=FL&p_dept=CHEM", 
                 schedule_url(:term => ["FL"], :dept => ["CHEM"]))
  end
end

