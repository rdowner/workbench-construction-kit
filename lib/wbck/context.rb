require 'wbck/util/amitool'
require 'wbck/global_config'

module Wbck
  class Context

    attr_reader :global_config, :module_config, :shell_executor, :amitool

    def initialize(global_config, module_config, shell_executor)
      @global_config = Wbck::GlobalConfig.new(global_config)
      @module_config = module_config
      @shell_executor = shell_executor
      @amitool = Wbck::Util::Amitool.new(@global_config.filename, @global_config.geometry, @shell_executor)
    end

  end
end
