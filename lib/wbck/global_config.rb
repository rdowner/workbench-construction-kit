require 'wbck/util/amitool'
require 'wbck/util/geometry'

module Wbck
  class GlobalConfig

    attr_reader :filename, :geometry

    def initialize(global_config)
      @filename = global_config['filename']
      @geometry = Wbck::Util::Geometry.new(global_config['geometry'])
    end

  end
end
