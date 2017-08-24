require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class CloantoSetpatchFix
    SEARCH = /^C:Version >NIL: exec.library 45 20\nIf WARN\n  C:SetPatch QUIET\nEndIf$/im
    REPLACE = 'C:SetPatch QUIET'

    def run(context)

      unless context.module_config['system_volume']
        raise StandardError, 'Missing property system_volume in configuration for module cloanto_setpatch_fix'
      end

      system_volume = context.module_config['system_volume']
      system_pack = Wbck::Util::XdfPack.new(File.join(context.workspace, system_volume))

      # Find the startup-sequence reference, so we know how it's capitalized
      startup_sequence = system_pack.find_file "s/startup-sequence"
      unless startup_sequence
        raise StandardError, 'System volume does not contain s/startup-sequence'
      end

      content = File.open(system_pack.to_real_file(startup_sequence.name), 'rb') { |f| f.read }
      content = content.sub(SEARCH, REPLACE)
      File.open(system_pack.to_real_file(startup_sequence.name), 'wb') { |f| f.write content }
    end
  end
end