require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'paint'

module Wbck::Module
  class NewImage
    def run(context)
      geom = Wbck::Util::Geometry.new(context.global_config['geometry'])
      filename = context.global_config['filename']
      raise "no geometry given" if geom.nil?
      blocks = context.global_config['blocks']
      blocks = geom.total_blocks if blocks.nil?
      image_size = Wbck::Util::ByteSize.new("#{blocks * 512}")

      puts Paint['Creating image of size ', :blue] +
             Paint[image_size, :magenta] +
             Paint[' named "', :blue] +
             Paint[filename, :magenta] +
             Paint['"', :blue]

      command = [ 'dd', 'if=/dev/zero', 'count='+blocks.to_s, 'of='+filename ]
      context.shell_executor.execute(command)

    end
  end
end
