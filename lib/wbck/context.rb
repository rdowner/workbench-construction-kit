require 'wbck/util/amitool'

module Wbck
  class Context

    attr_reader :global_config, :module_config, :shell_executor, :amitool

    def initialize(global_config, module_config, shell_executor)
      @global_config = global_config
      @module_config = module_config
      @shell_executor = shell_executor

      geom = Wbck::Util::Geometry.new(@global_config['geometry'])
      filename = @global_config['filename']
      @amitool = Wbck::Util::Amitool.new(filename, geom, @shell_executor)
    end

  end
end
