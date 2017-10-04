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
      @metafile = path + ".xdfmeta"
      raise ArgumentError, 'No such file: ' + @metafile unless File.exist?(path)
      metadata = File.readlines(@metafile)
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

    def find_file(filename)
      all_content.find { |x| filename.casecmp(x.name) == 0 }
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
      flush
    end

    def install_file(localname, amiganame)
      dirpart = amiganame.split('/')[0..-2].join('/')
      unless dirpart.nil? || dirpart.length == 0
        # Find the existing directory name - this causes the existing casing to be used
        # (remember Amiga fs is not case sensitive but does store case, whereas the UNIX fs will be case sensitive,
        # so while we're working on it we have to put files into exactly-correct cased directories)
        dirpart_meta = find_file dirpart
        if dirpart_meta.nil?
          raise RuntimeError, "request to install file as #{amiganame} but directory #{dirpart} does not exist"
        end
        amiganame = dirpart_meta.name + '/' + amiganame.split('/')[-1]
      end

      existing = find_file amiganame
      if existing
        FileUtils.remove to_real_file(existing.name)
        @metadata.remove_file(existing.name)
      end

      ts = File.mtime(localname)
      mode = ''
      mode += 'r' if File.readable?(localname)
      mode += 'w' if File.writable?(localname)
      mode += 'e' if File.executable?(localname)
      mode += 'd' if File.writable?(localname)
      metadata = XdfMeta::XdfItemMeta.new(sprintf('%s:%s,%s,%s', amiganame, mode, amitool_ts(ts), '')) # TODO better constructor
      FileUtils.cp(localname, to_real_file(amiganame))
      @metadata.add_file(metadata)
      flush
    end

    def mkdir(amiganame, timestamp: Time.now.getlocal, mode: 'rwed')
      existing = find_file amiganame
      if existing
        if File.directory?(to_real_file(existing.name))
          # directory already exists, no-op
          return
        else
          # already exists, but not as a directory (therefore most likely a file)
          raise RuntimeError, "Asked to create directory #{amiganame} but it already exists as a file"
        end
      else
        metadata = XdfMeta::XdfItemMeta.new(sprintf('%s:%s,%s,%s', amiganame, mode, amitool_ts(timestamp), '')) # TODO better constructor
        FileUtils.mkdir(to_real_file(amiganame))
        @metadata.add_file(metadata)
        flush
      end
    end

    def flush
      File.open(@metafile, 'w') do |f|
        f.puts @metadata.to_s
        all_content.each do |l|
          f.puts l.to_s
        end
      end
    end

    TS_FORMAT = '%d.%m.%Y %H:%M:%S'
    def amitool_ts(ts)
      ts.strftime(TS_FORMAT) + sprintf(' t%02d', ts.subsec)
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

      def remove_file(name)
        @all_content.delete_if do |x| name.casecmp(x.name) == 0 end
      end

      def to_s
        sprintf '%s:%s,%s,%s,%s', @disk_name, @dos_type, @format_timestamp, @changed_timestamp, @rootblock_changed_timestamp
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

        def to_s
          sprintf '%s:%s,%s,%s', @name, @flags, @timestamp, @comment
        end

      end

    end

  end

end
