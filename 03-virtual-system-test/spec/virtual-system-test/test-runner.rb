# NOTICE:  Code tangled from 'TEST-RUNNER.org' - and changes
# in this file will be overridden.

require 'hashformer'

require_relative "../spec_helper"
describe "virtual-system-tests" do


  # Define test cases
  fixtureDir = VIRTUAL_SYSTEM_TEST_INPUT_DIRECTORY
  interface = "TimeoffRegisterCompany"
   

  # Define mapping from formal model state to implementation state
  
  # Map 'formalEmail' to 'implementationEmail'
  formalEmail2implementationEmail = ->(formalEmail) do
    # add domain '@test.com' to make formal model 
    # email to valid email in implementation
    "#{formalEmail || "noemail"}@test.com"
  end
  
  
  # Map 'formalLastName' to 'implementationLastName'
  formalLastName2implementationLastName = ->(formalLastName) do
     # just prefix 
    "lastt-#{formalLastName}"
  end
  
  
  # Schema transform formal model entity 'User' 
  schemaUser = {
    "name" => HF["user_name"],
    "lastname" => HF["user_name"].__as{ |x| formalLastName2implementationLastName[x] },        
    "email" =>  HF["user_email"].__as{ |x| formalEmail2implementationEmail[x] },
  }
  
  # Schema transform formal model entity 'Company'
  schemaCompany = {
    "name" => HF["company_name"],
  }
  
  # Schema transform formal model 'beforeState' & 'afterState'
  schemaModelState =  {
    Users: HF[:Timeoff_Users].to_a.map{ |u| HF.transform( u, schemaUser) },
    Companies: HF[:Timeoff_Companies].to_a.map{ |u| HF.transform( u, schemaCompany) },
  } # schemaModelState
  
  
  # Schema transform formal model 'apiInput'
  schemaApiInput = {
    "name" => HF["user_name"],
    "lastname" => HF["user_name"].__as{ |x| formalLastName2implementationLastName[x] },    
    "email" => HF["user_email"].__as{ |x| formalEmail2implementationEmail[x] },
  }
  
  
  # Schema transform formal 'apiResponse'
  schemaStatus = {
    "success" => HF["status"].__as{ |stat| stat == "status_200" },
  }
  
  
  
   

    def readDatabase
      {
        Users: select_from_table( "Users", getTableSchema( "Users")),
        Companies: select_from_table( "Companies", getTableSchema( "Companies")),
      }
    end
  

  # Expect 'asIs' to include 'toBe'
  def checkDatabase( asIs:, toBe: )
    
    chk_db_table_included(
      comment: "db-Users>",
      toBe: toBe[:Users], asIs: asIs[:Users],
      keyLambda:  ->(r1,r2) { r1["email"] == r2["email"] }
    )
    
    chk_db_table_included(
      comment: "db-Companies>",
      toBe: toBe[:Companies], asIs: asIs[:Companies],
      keyLambda:  ->(r1,r2) { r1["name"] == r2["name"] }
    )
  
  end
    
  

  # Iterate step for 'interface' in APItrace files in 'fixtureDir'
  Sbuilder::TlaTraceArch::ReadArchiveFile.iterateApiTraceSteps( fixtureDir, interface  ) do |sha1, apiTraceStep|
      
     # String identifying test case step
     testDescription = "Step #{apiTraceStep["00-step"]["step"]} - interface #{apiTraceStep["00-step"]["interface"]} SHA1=#{apiTraceStep["00-step"]["sha1"]}"
  

    
    describe testDescription, :type => :feature do
      
      describe "Init database and start server" do
        
        before :context, "Db init" do

	  support_test_progress "------------------------------------------------------------------"
	  support_test_progress "#{testDescription}"
	  
	  # Db 
	  open_database( dbFile )
	  
	  # Init system 
	  delete_table( "Users")
	  delete_table( "Sessions")
	  delete_table( "Companies")
	  
	  # check systems
	  support_test_progress "    Check beforeState"          
	  checkDatabase( 
	   asIs: readDatabase, 
	   toBe: map_transform( comment: "beforeState>",  
	   data: apiTraceStep["01-inp"], xSchema: schemaModelState ) )
	  
	  # app
	  support_test_progress "    Start application"
	  appStart
	  
	  
          
        end
        
        # Shutdown background process 'APP_START'
        after :context  do
	   
	   # Shutdown server
	   support_test_progress "   Stop application"
	   appStop
	   
	   # run checks before closing database
	   support_test_progress "    Check afterState"
	   checkDatabase( 
	      asIs: readDatabase, 
	      toBe: map_transform( 
	                comment: "afterStateToBe>",  
	                data: apiTraceStep["04-out"], 
	                xSchema: schemaModelState ))
	   
	   #
	   close_database
	   
        end # after

        # expect server to be running
        it "expect - app #{APP_START} running" do
          expect( isAppRunning ).to eql true
        end
        
        describe "API-call" do
          before :context do
            support_test_progress "   Make API call"
            
            # navigate to regitration form
            ui_navigate_main_page
            ui_choose_register
            
            # fill registration
            ui_register_form_fill( 
               map_transform( 
                    comment: "api_input", 
                    data: apiTraceStep["02-api"], 
                    xSchema: schemaApiInput))
            
            # submit registation = API call
            ui_register_form_submig
	    
	    # Check return status from API
	    support_test_progress "    Check API response"
	    if ( map_transform( 
	            comment: "api_return", 
	            data: apiTraceStep["03-ret"], 
	            xSchema: schemaStatus )["success"] ) then
	      support_test_progress "        Check API response - expect success"
	      expect( page ).to have_content( "Registration is complete.")
	    else
	      support_test_progress "        Check API response - expect failure"
	    end
	    
	    
          end

          it { expect( true ).to eql true } 
        end

      end # describe "Db" do
      
    end
  end # iterateTestCases
  
end # virtual system tests
