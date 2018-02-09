require 'open3'
require 'pty'

module NodeManager
  # Spawn service 'svc' using PTY and a thread. Return hash for 1)
  # checking :status 2) Waiting for start up message 3) Finishin up
  #
  # @param svc [String] cmd to spawn in background
  #      
  #
  # @return [Hash] serviceContext hash with public properties :status,
  #          :read, :waitFor and :finish, and private properties :mutex,
  #          :buffer, :thread, :pid
  def startService( svc )

    # context to manage background process and thread
    svcState = {}
    PTY.spawn( svc ) do |stdout,stdin, pid|

      svcState[:pid] = pid

      # public lambda to access stderr & stdout
      svcState[:read] = ->() do
        buf = ""
        svcState[:mutex].synchronize do
          buf = svcState[:buffer];
          svcState[:buffer]='';
        end
        buf
      end

      # public lambda waitFor to wait until 'str' present in
      # 'svcState[:read]', quit if svcState[:status] in error
      svcState[:waitFor] = ->(str) do
        buf = svcState[:read].call
        while true
          return "ERROR" unless svcState[:status]
          return buf if buf.include?(str)
          # wait 
          sleep 1
          buf << svcState[:read].call
        end
      end

      # public lambda to finish background process
      svcState[:finish] = ->() do
        msg="Finish: "
        begin
          if svcState[:pid]
            Process.kill( "QUIT", svcState[:pid] ) 
            msg += " killed process #{svcState[:pid]}"
          end
          svcState[:pid] = nil
        ensure
          if svcState[:thread]
            Thread.kill( svcState[:thread] ) 
            msg += " killed thread #{svcState[:thread]}"
          end
          svcState[:thread] = nil
        end
        msg
      end

      # Create mutex to guard critical section
      svcState[:mutex] = Mutex.new
      svcState[:buffer] = ''
      svcState[:status] = true

      # Launch thread to read svc output and get notification if
      # service has died
      svcState[:thread] = Thread.new do
        begin
          # Do stuff with the output here. Just printing to show it works
          # stdout.each { |line| print line }
          stdout.each do |line|
            svcState[:mutex].synchronize do 
              svcState[:buffer] << line
            end
          end
        rescue Errno::EIO
          svcState[:status] = false
          warn "Server closed"
          # warn "Errno:EIO error, but this probably just means " +
          #      "that the process has finished giving output"
        end
      end # Thread.new
    end # PTY.spawn
    svcState
  end # startService
  
end # module NodeManager
