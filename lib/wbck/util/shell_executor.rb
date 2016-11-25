require 'paint'

module Wbck::Util
  class ShellExecutor

    def execute(command)
      puts Paint['Executing: ', :blue] + Paint[command.join(' '), :magenta]
      system(*command)
    end

  end
end
