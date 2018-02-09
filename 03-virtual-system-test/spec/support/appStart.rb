  def appStart
    Dir.chdir( APP_DIR ) do
      @svcContext = startService( APP_START )
      # lambda call to read startup message
      msg = @svcContext[:waitFor]["www"]
      support_info "Starting server '#{APP_START}' in directory '#{APP_DIR}' in pid: #{@svcContext[:pid]}"
      support_debug msg
      # let it settle
      sleep( 1 )
    end
  end

def isAppRunning
  support_debug "#{__method__}: @svcContext[:status]=#{@svcContext[:status] }"
  @svcContext[:status] 
end
