module Wbck::Util
  class XdfPack

    attr_reader :unpacked_location

    def self.unpack(context, name, xdffile)
      unpacked_location = File.join(context.workspace, name)
      context.amitool.xdftool_raw(xdffile, [
        Wbck::Util::Amitool::Command.new('unpack', [unpacked_location], {})
      ])
      XdfPack.new(unpacked_location)
    end

    def initialize(path)
      raise ArgumentError, 'No such directory: ' + path unless Dir.exist?(path)
      metafile = path + ".xdfmeta"
      raise ArgumentError, 'No such file: ' + metafile unless File.exist?(path)
      metadata = File.readlines(metafile)
      @metadata = XdfMeta.new(metadata)
      @unpacked_location = path
    end

    def disk_name
      @metadata.disk_name
    end

    def dos_type
      @metadata.dos_type
    end

    def format_timestamp
      @metadata.format_timestamp
    end

    def changed_timestamp
      @metadata.changed_timestamp
    end

    def rootblock_changed_timestamp
      @metadata.rootblock_changed_timestamp
    end

    def all_content
      @metadata.all_content
    end

    def copy_in(other)
      other.all_content.each do |f|
        src = other.to_real_file(f.name)
        dest = to_real_file(f.name)
        if (FileTest.directory?(src))
          if (FileTest.exist?(dest))
            raise StandardError, "Trying to copy in directory #{f} but it's a file in the destination" unless FileTest.directory?(dest)
          else
            Dir.mkdir(dest)
          end
        else
          FileUtils.cp(src, dest)
        end
        @metadata.add_file(f)
      end
    end

    def to_real_file(filename)
      fn = [ @unpacked_location ] + filename.split('/')
      File.join(*fn)
    end

    def cleanup
      FileUtils.remove_entry(@unpacked_location)
    end


    class XdfMeta

      attr_reader :disk_name, :dos_type, :format_timestamp, :changed_timestamp, :rootblock_changed_timestamp

      def initialize(xdfmeta_content)
        @disk_metadata = xdfmeta_content[0].chomp
        match = /^([^:]*):([^,]*),([^,]*),([^,]*),([^,]*)$/.match(@disk_metadata)
        raise ArgumentError, "Header line did not match expectations: #{@disk_metadata}" unless match
        @disk_name = match[1]
        @dos_type = match[2]
        @format_timestamp = match[3]
        @changed_timestamp = match[4]
        @rootblock_changed_timestamp = match[5]

        @all_content = xdfmeta_content[1..-1].collect do |item|
          XdfItemMeta.new(item)
        end
      end

      def all_content
        Array.new(@all_content).freeze
      end

      def add_file(metadata)
        @all_content.push(metadata.clone)
      end

      class XdfItemMeta

        attr_reader :name, :flags, :timestamp, :comment

        def initialize(xdfitemmeta)
          match = /^([^:]*):([^,]*),([^,]*),(.*)$/.match(xdfitemmeta.chomp)
          raise ArgumentError, "Content line did not match expectations: #{xdfitemmeta}" unless match
          @name = match[1]
          @flags = match[2]
          @timestamp = match[3]
          @comment = match[4]
        end

      end

    end

  end

end
