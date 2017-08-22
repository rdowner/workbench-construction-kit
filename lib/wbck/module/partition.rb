require 'wbck/util/geometry'
require 'wbck/util/byte_size'
require 'wbck/util/amitool'

module Wbck::Module
  class Partition
    def run(context)

      geom = context.global_config.geometry
      filename = context.global_config.filename
      rdb_reserve = context.module_config['rdb_reserve'].to_i
      partitions = context.module_config['partitions']

      auto_part = nil
      partitions.each do |p|
        case p['size']
          when "auto"
            auto_part = p
          when /^(\d+)%$/
            p['cylinders'] = (geom.cylinders * ($1.to_i / 100.0)).to_i
          when /^(.*b)$/
            bytes = Wbck::Util::ByteSize.new($1)
            p['cylinders'] = bytes / geom.bytes_per_cylinder
        end
      end

      auto_part['cylinders'] = geom.cylinders - partitions.inject(rdb_reserve) do |r, e|
        r += e['cylinders'] unless e['cylinders'].nil?
        r
      end

      puts Paint['Initialising RDB with ', :blue] + Paint[rdb_reserve, :magenta] + Paint[' cylinders', :blue]
      context.amitool.rdbtool_create_or_open([
                                Wbck::Util::Amitool::Command.new('init', [], {'rdb_cyls' => rdb_reserve.to_s})
                              ])

      partitions.each do |p|
        puts Paint['Adding partition ', :blue] +
               Paint[p['name'], :magenta] +
               Paint[' with ', :blue] +
               Paint[p['cylinders'], :magenta] +
               Paint[' cylinders', :blue]
        context.amitool.rdbtool([
                                  Wbck::Util::Amitool::Command.new('add', [], {'size' => p['cylinders'].to_s, 'name' => p['name'], 'dostype' => 'DOS3'})
                                ])

        puts Paint['Formatting partition ', :blue] +
               Paint[p['name'], :magenta] +
               Paint[' with label "', :blue] +
               Paint[p['label'], :magenta] +
               Paint['"', :blue]
        context.amitool.xdftool(p['name'], [
                                  Wbck::Util::Amitool::Command.new('format', [p['label'], 'DOS3'], {})
                                ])
      end

      puts Paint['Final partition state:', :blue]
      context.amitool.rdbtool([
                                Wbck::Util::Amitool::Command.new('info', [], {})
                              ])
    end
  end
end
