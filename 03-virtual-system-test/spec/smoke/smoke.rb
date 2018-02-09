require_relative "../spec_helper"


describe "smoke" do

  before :context  do
    @debug = true
    appStart
  end


  
  after :context do
    appStop
  end

  it { expect( true ).to eql true }

  # expec server to be ok
  it { expect( isAppRunning  ).to eql true }


  
end 
