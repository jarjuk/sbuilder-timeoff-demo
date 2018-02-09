require 'tla_trace_arch'


# load supports
Dir[File.join( File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}
RSpec.configure do |c|
  c.include NodeManager
  c.include Sqlite3Manager
end



# Fixed data
FIXTURE_ROOT =  File.join(File.dirname(__FILE__), "fixtures")
VIRTUAL_SYSTEM_TEST_INPUT_DIRECTORY = File.join(File.dirname(__FILE__), "../virtual-system-test-input")


# App installation directory
APP_DIR = "timeoff"

# Command to launch application
APP_START = "npm start"

# name app.data base
DB_NAME   = "db.development.sqlite"

APP_SCHEMA = {
  "Users" => {
    :columns => [ "id", "name", "lastname", "email", "admin", "auto_approve", "start_date", "end_date", "companyId"],
  },
  "Companies" => {
    :columns => [ "id", "name", "country", "timezone"],
  },
}

def getTableSchema( tableName )
  raise "Missing schema #{tableName} - known schemas #{APP_SCHEMA.keys.join(",")} " if APP_SCHEMA[tableName].nil?
  APP_SCHEMA[tableName][:columns].map{ |k| [k,nil]}.to_h
end


require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.default_driver = :selenium_chrome # and :selenium_chrome_headless are also registere
Capybara.save_path = File.join  File.dirname(__FILE__), "../tmp"
Capybara::Screenshot.autosave_on_failure = true
Capybara.asset_host = 'http://localhost:3000'
Capybara.default_max_wait_time = 5
# Capybara.default_wait_time = 5 



