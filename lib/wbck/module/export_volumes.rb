require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class ExportVolumes
    def run(context)

      partitions = context.module_config['partitions']

      partitions.each do |p|
        puts Paint['Exporting partition ', :blue] +
               Paint[p, :magenta]
        context.amitool.xdftool(p, [
                                  Wbck::Util::Amitool::Command.new('unpack', [ File.join(context.workspace, p) ], {})
                                ])
      end
    end
  end
end
