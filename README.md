ucb-schedule-scraper
====================
This is a work-in-progress program that provides a CLI and an API interface 
for the horribly formatted http://schedule.berkeley.edu. This works by submitting
requests to schedule.berkeley.edu, parsing the response from the request, and 
outputing the results in a nice format. So far only a tabular format (like the 
one shown below) is the only one supported now, but CSV formats will be added
later. 

Example
=======
Here is an example of how we would use the API:

     require 'schedule'
     
     Query.new(
        {:term => "FL", :dept => "POL SCI"}, 
        {:attributes => [
            :department, 
            :section_type, 
            :units, :title, 
            :instructor, 
            :location
          ]
        }).print_tabular
     
When we run the program, it will output the following:

           Department | Type | Units |                             Title |        Instructor |     Location
    POLITICAL SCIENCE |  LEC |     4 | Introduction to American Politics |         CITRIN, J | 155 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics | BIN ABDUL AZIZ, J | 229 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |     ASHCROFT, R T | 229 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |     ASHCROFT, R T | 229 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |    CHATFIELD, S N | 242 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |        ELINSON, G | 243 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |        ELINSON, G | 243 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |        ROCCO, P B |   24 WHEELER
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |        AHLER, D J | 243 DWINELLE
    POLITICAL SCIENCE |  DIS |       | Introduction to American Politics |        AHLER, D J |  155 BARROWS
                  ... |  ... |   ... |                               ... |               ... |          ...

TODO
====
* CLI version of schedule.rb
* CSV output

Test Suite
==========
The test suite can be ran by doing

     rake test
