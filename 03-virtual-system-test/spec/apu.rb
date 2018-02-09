require_relative "../spec_helper"

require 'hashformer'

 describe "system-tests" do

  # Define test cases
  fixtureDir = VIRTUAL_SYSTEM_TEST_INPUT_DIRECTORY
  interface = "TimeoffRegisterCompany"
   

  # Define mapping from formal model state to implementation state
  
  modelData2email = ->(modelData) do
    "#{modelData || "noemail"}@test.com"
  end
  
  modelData2lastname = ->(modelData) do
    "lastt-#{modelData}"
  end
  
  
  # Map formal model api_input to hash to populate registry form
  xformApiInput = {
    "name" => HF["user_name"],
    "lastname" => HF["user_name"].__as{ |x| modelData2lastname[x] },    
    "email" => HF["user_email"].__as{ |x| modelData2email[x] },
  }
  
  
  
  xformUser = {
    "name" => HF["user_name"],
    "lastname" => HF["user_name"].__as{ |x| modelData2lastname[x] },        
    "email" =>  HF["user_email"].__as{ |x| modelData2email[x] },
  }
  
  xformStatus = {
    "success" => HF["status"].__as{ |stat| stat == "status_200" },
  }
  
  
  xformCompany = {
    "name" => HF["company_name"],
  }
  
  
  xformModelState =  {
    Users: HF[:Timeoff_Users].to_a.map{ |u| HF.transform( u, xformUser) },
    Companies: HF[:Timeoff_Companies].to_a.map{ |u| HF.transform( u, xformCompany) },
  } # xformModelState
  
   

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

    testDescription = "Step #{apiTraceStep["00-step"]["step"]} - interface #{apiTraceStep["00-step"]["interface"]} SHA1=#{apiTraceStep["00-step"]["sha1"]}"
    
    describe testDescription, :type => :feature do
      
      describe "Init database and start server" do
        
        before :context, "Db init" do
          support_test_progress "------------------------------------------------------------------"
          support_test_progress "Initialize system state - #{testDescription}"

          
          # @debug = true
          # @info = true
          # Db 
          open_database( dbFile )
          delete_table( "Users")
          delete_table( "Sessions")
          delete_table( "Companies")

          support_test_progress "Check beforeState - #{testDescription}"          
          beforeStateToBe = map_transform( comment: "beforeState>",  data: apiTraceStep["01-inp"], xSchema: xformModelState )
          beforeStateAsIs = readDatabase
          checkDatabase( asIs: beforeStateAsIs, toBe: beforeStateToBe )
          
          # app
          support_test_progress "Start application - #{testDescription}"
          appStart
        end
        
        # Shutdown background process 'APP_START'
        after :context  do
          
          # Shutdown server
          support_test_progress "Stop application - #{testDescription}"
          appStop

          # run checks before closing database
          support_test_progress "Check afterState - #{testDescription}"
          afterStateToBe = map_transform( comment: "afterStateToBe>",  data: apiTraceStep["04-out"], xSchema: xformModelState )          
          afterStateAsIs = readDatabase
          checkDatabase( asIs: afterStateAsIs, toBe: afterStateToBe )

          #
          close_database
          
        end # after

        # expect server to be running
        it "expect - app #{APP_START} running" do
          expect( isAppRunning ).to eql true
        end
        
        describe "API-call" do
          before :context do
            support_test_progress "Make API call - #{testDescription}"
            ui_navigate_main_page
            ui_choose_register
            apiInput = map_transform( comment: "api_input", data: apiTraceStep["02-api"], xSchema: xformApiInput)
            apiReturn = map_transform( comment: "api_return", data: apiTraceStep["03-ret"], xSchema: xformStatus )
            support_info "API-call: formal parameters: #{apiTraceStep["02-api"]} --> actual parameters #{apiInput}"
            ui_register_form_fill( apiInput )
            # Capybara::Screenshot.screenshot_and_save_page
            if ( apiReturn["success"] ) then
                 support_test_progress "Check API return - expect success"
                 expect( page ).to have_content( "Registration is complete.")
            else
              support_test_progress "Check API return - expect failure"
            end
          end

          it { expect( true ).to eql true } 
        end

      end # describe "Db" do
      
    end
  end # iterateTestCases
  

 end
