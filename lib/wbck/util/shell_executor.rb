require 'paint'

module Wbck::Util
  class ShellExecutor

    def execute(command)
      puts Paint['Executing: ', :blue] + Paint[command.join(' '), :magenta]
      success = system(*command)
      unless success
        raise StandardError, "Shell command failed; #{$?}. Command: #{command}. Directory: #{Dir.getwd}"
      end
    end

  end
end
