def support_debug( msg )

  puts msg if @debug

end

def support_ui_debug( msg )
  support_debug( msg )
end

def support_info( msg )

  puts msg if @debug || @info
  
end

def support_test_progress msg
  puts  msg
end
