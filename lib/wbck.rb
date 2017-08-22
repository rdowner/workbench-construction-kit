require 'wbck/version'
require 'wbck/module'
require 'wbck/context'
require 'wbck/util/shell_executor'
require 'thor'
require 'yaml'
require 'paint'

module Wbck
  class CLI < Thor

    desc 'build CONFIG', 'Builds a Amiga hard drive image file as described in file CONFIG'

    def build(config_filename)
      puts Paint["Workbench Construction Kit #{VERSION}", :green, :bright, :underline]

      config = load_and_validate_config(config_filename)
      unless config
        puts Paint["Aborted.", :red, :bright, :underline]
        exit 1
      end

      workspace = Dir.mktmpdir('wbck-')
      begin
        puts Paint["Use #{workspace} for workspace", :green]

        config['modules'].each do |m|
          puts Paint["Processing: #{m['module']}", :green]
          context = Wbck::Context.new(config['global'], m, Wbck::Util::ShellExecutor.new(), workspace)
          m['ref'].run(context)
        end

      ensure
        puts Paint["Cleaning workspace", :green]
        FileUtils.remove_entry(workspace)
      end

      puts Paint['Done!', :green, :bright]
    end

    no_commands {

      def load_and_validate_config(config_filename)
        config = YAML.load_file(config_filename)
        errors = false

        # Validate modules and insert instance reference
        config['modules'].each do |m|
          mod_name = m['module']
          begin
            require "wbck/module/#{mod_name}"
            mod_class_name = Wbck::Module::const_get(mod_name.split('_').collect(&:capitalize).join)
            instance = mod_class_name.new
          rescue
            puts Paint["Could not find module: #{mod_name}", :red]
            errors = true
          else
            m['ref'] = instance;
          end
        end

        errors ? nil : config
      end

    }
  end
end
