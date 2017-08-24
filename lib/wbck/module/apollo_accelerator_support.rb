require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class ApolloAcceleratorSupport
    SEARCH = /^(\s*)(C:)?SetPatch(.*)$/i
    REPLACE = "\\1\\2SetPatch\\3\nPLACEHOLDER b"

    def run(context)

      (system_volume = context.module_config['system_volume']) or raise StandardError, 'Missing property system_volume in configuration for module apollo_accelerator_support'
      (library_68040 = context.module_config['library_68040']) or raise StandardError, 'Missing property library_68040 in configuration for module apollo_accelerator_support'
      library_68o4o = context.module_config['library_68o4o']
      library_68060 = context.module_config['library_68060']
      (cpu_command = context.module_config['cpu_command']) or raise StandardError, 'Missing property cpu_command in configuration for module apollo_accelerator_support'

      system_pack = Wbck::Util::XdfPack.new(File.join(context.workspace, system_volume))

      # Install the files
      system_pack.install_file(library_68040, 'libs/68040.library')
      system_pack.install_file(library_68o4o, 'libs/68o4o.library')
      system_pack.install_file(library_68060, 'libs/68060.library')
      system_pack.install_file(cpu_command, "c/#{ File.basename(cpu_command) }")

      # Find the startup-sequence reference, so we know how it's capitalized
      startup_sequence = system_pack.find_file "s/startup-sequence"
      unless startup_sequence
        raise StandardError, 'System volume does not contain s/startup-sequence'
      end

      content = File.open(system_pack.to_real_file(startup_sequence.name), 'rb') { |f| f.read }
      r = REPLACE.sub('PLACEHOLDER', File.basename(cpu_command))
      content = content.sub(SEARCH, r)
      File.open(system_pack.to_real_file(startup_sequence.name), 'wb') { |f| f.write content }
    end
  end
end