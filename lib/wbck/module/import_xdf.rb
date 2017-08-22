require 'wbck/util/xdf_pack'

module Wbck::Module
  class ImportXdf
    def run(context)
      source_xdf = context.module_config['source_xdf']
      target_volume = context.module_config['target_volume']

      source_pack = Wbck::Util::XdfPack.unpack(context, 'import', source_xdf)
      begin
        target_pack = Wbck::Util::XdfPack.new(File.join(context.workspace, target_volume))
        puts Paint['Importing files from ', :blue] + Paint[source_xdf, :magenta] + Paint[' into partition ', :blue] + Paint[target_volume, :magenta]
        target_pack.copy_in(source_pack)
      ensure
        puts Paint['Removing temporary files at ', :blue] + Paint[source_pack.unpacked_location, :magenta]
        source_pack.cleanup
      end
    end
  end
end
