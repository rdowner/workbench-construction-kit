require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class Remapollo
    SEARCH = /^(\s*)(C:)?SetPatch(.*)$/i
    REPLACE = "PLACEHOLDER\n\\1\\2SetPatch\\3"

    def run(context)

      (system_volume = context.module_config['system_volume']) or raise StandardError, 'Missing property system_volume in configuration for module remapollo'
      (remapollo_lha = context.module_config['remapollo_lha']) or raise StandardError, 'Missing property remapollo_lha in configuration for module remapollo'
      remapollo_options = context.module_config['remapollo_options'] || ''
      drap_options = context.module_config['drap_options'] || ''
      amiga_install_dir = context.module_config['install_dir'] || 'System/RemAPollo'

      system_pack = Wbck::Util::XdfPack.new(File.join(context.workspace, system_volume))

      # Install the files
      extract_dir = File.join(context.workspace, 'remapollo_extract')
      Dir.mkdir(extract_dir)
      context.shell_executor.execute(['lha', 'x', '-q', "-w=#{extract_dir}", remapollo_lha])
      puts Paint['Installing RemAPollo files into ', :blue] + Paint[amiga_install_dir, :magenta]
      system_pack.mkdir(amiga_install_dir)
      system_pack.import_files(extract_dir, amiga_install_dir)

      # Find the startup-sequence reference, so we know how it's capitalized
      startup_sequence = system_pack.find_file "s/startup-sequence"
      unless startup_sequence
        raise StandardError, 'System volume does not contain s/startup-sequence'
      end

      puts Paint['Installing RemAPollo into ', :blue] + Paint[startup_sequence.name, :magenta]
      content = File.open(system_pack.to_real_file(startup_sequence.name), 'rb') { |f| f.read }
      r = REPLACE.sub('PLACEHOLDER', "SYS:#{amiga_install_dir}/DRAP #{drap_options}
If WARN
   SYS:#{amiga_install_dir}/RemApollo #{remapollo_options}
EndIf")
      content = content.sub(SEARCH, r)
      File.open(system_pack.to_real_file(startup_sequence.name), 'wb') { |f| f.write content }
    end
  end
end