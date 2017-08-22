require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class ImportVolumes
    def run(context)

      partitions = context.module_config['partitions']

      partitions.each do |p|
        puts Paint['Exporting partition ', :blue] +
               Paint[p, :magenta]
        context.amitool.xdftool(p, [
                                  Wbck::Util::Amitool::Command.new('pack', [ File.join(context.workspace, p) ], {})
                                ])

        puts Paint['Partition information:', :blue]
        context.amitool.xdftool(p, [
                                  Wbck::Util::Amitool::Command.new('info', [], {})
                                ])
      end
    end
  end
end
