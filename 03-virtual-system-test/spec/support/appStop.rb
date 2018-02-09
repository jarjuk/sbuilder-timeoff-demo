  def appStop
    msg = @svcContext[:finish].call if @svcContext 
    support_info "Shutting down server '#{APP_START}' in directory '#{APP_DIR}'"
    support_debug msg
    @svcContext  = nil
  end
  
