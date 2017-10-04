require 'spec_helper'
require 'wbck/context'
require 'wbck/util/shell_executor'
require 'wbck/util/xdf_pack'
require 'pathname'
require 'time'

TEST_DATA_LOCATION = File.join(Dir.getwd, 'spec', 'test_data')
UNPACKED_LOCATION = File.join(TEST_DATA_LOCATION, 'unpacked', 'XdfPackTest')
PACKED_FILE = File.join(TEST_DATA_LOCATION, 'XdfPackTest.adf')
ANOTHER_PACKED_FILE = File.join(TEST_DATA_LOCATION, 'Another.adf')

def standard_context()
  Dir.mktmpdir() do |workspace|
    global_config = {'filename' => '/dev/null', 'geometry' => '7751/16/63'}
    context = Wbck::Context.new(global_config, nil, Wbck::Util::ShellExecutor.new(), workspace)
    pack = Wbck::Util::XdfPack.unpack(context, 'test', PACKED_FILE)
    yield workspace, global_config, context, pack
  end
end

def standard_install_file_context()
  standard_context do |workspace, global_config, context, pack|
    source_file = Pathname.new(workspace).join('install_file')
    File.open(source_file, 'w') {|f| f.write("example file being imported")}
    yield workspace, global_config, context, pack, source_file
  end
end

def install_file_permission_test(unixmode, amigamode)
  standard_install_file_context do |workspace, global_config, context, pack, source_file|
    File.chmod(unixmode, source_file)
    pack.install_file source_file, 'install_file'
    imported_file_meta = pack.find_file('install_file')
    expect(imported_file_meta).to_not(be_nil)
    expect(imported_file_meta.flags).to eq(amigamode)
  end
end

describe Wbck::Util::XdfPack do

  it 'parses disk metadata' do
    pack = Wbck::Util::XdfPack.new(UNPACKED_LOCATION)
    expect(pack.disk_name).to eq('XdfPackTest')
    expect(pack.dos_type).to eq('DOS0')
    expect(pack.format_timestamp).to eq('22.08.2009 11:14:40 t28')
    expect(pack.changed_timestamp).to eq('22.08.2009 12:16:43 t21')
    expect(pack.rootblock_changed_timestamp).to eq('22.08.2009 12:14:15 t32')
  end

  it 'parses disk content metadata' do
    pack = Wbck::Util::XdfPack.new(UNPACKED_LOCATION)
    content = pack.all_content
    expect(content.size).to eq(5)
    content.each do |item|
      case item.name
        when 'Disk.info'
          expect(item.flags).to eq('rwd')
          expect(item.timestamp).to eq('22.08.2009 12:14:15 t32')
          expect(item.comment).to eq('')
        when 'Subdirectory'
          expect(item.flags).to eq('rwed')
          expect(item.timestamp).to eq('22.08.2009 12:16:42 t22')
          expect(item.comment).to eq('')
        when 'Subdirectory.info'
          expect(item.flags).to eq('rwd')
          expect(item.timestamp).to eq('22.08.2009 12:14:00 t22')
          expect(item.comment).to eq('')
        when 'Subdirectory/File'
          expect(item.flags).to eq('rwd')
          expect(item.timestamp).to eq('22.08.2009 12:16:21 t15')
          expect(item.comment).to eq('')
        when 'Subdirectory/File.info'
          expect(item.flags).to eq('rwd')
          expect(item.timestamp).to eq('22.08.2009 12:16:42 t44')
          expect(item.comment).to eq('')
        else
          raise('unexpected content item: ' + item.name)
      end
    end
  end

  it "can unpack an xdf file" do
    standard_context do |workspace, global_config, context, pack|
      expect(pack.disk_name).to eq('XdfPackTest')
      expect(pack.dos_type).to eq('DOS0')
      expect(pack.all_content.size).to eq(5)
      pathprefix = [workspace, 'test']
      pack.all_content.each do |f|
        fn = pathprefix + f.name.split('/')
        expect(File.exist?(File.join(*fn)))
      end
    end
  end

  it "can copy in an xdf_pack" do
    standard_context do |workspace, global_config, context, pack|
      other = Wbck::Util::XdfPack.unpack(context, 'other', ANOTHER_PACKED_FILE)
      pack.copy_in(other)
      expect(pack.all_content.size).to eq(6)
      pathprefix = [workspace, 'test']
      another_file_seen = false
      pack.all_content.each do |f|
        another_file_seen = true if f.name == 'AnotherFile'
        fn = pathprefix + f.name.split('/')
        expect(File.exist?(File.join(*fn)))
      end
      expect(another_file_seen).to eq(true)
    end
  end


  it "can import a file into the root" do
    standard_install_file_context do |workspace, global_config, context, pack, source_file|
      pack.install_file source_file, 'install_file'
      imported_file_meta = pack.find_file('install_file')
      expect(imported_file_meta).to_not(be_nil)
      fn = [workspace, 'test'] + imported_file_meta.name.split('/')
      expect(File.exist?(File.join(*fn)))
      File.open(File.join(*fn), 'r') {|f| expect(f.read).to eq("example file being imported") }
    end
  end

  it "can import a file and preserve timestamp" do
    standard_install_file_context do |workspace, global_config, context, pack, source_file|
      ts = Time.parse('2017-06-01 12:34:56')
      File.utime(ts, ts, source_file)
      pack.install_file source_file, 'install_file'
      imported_file_meta = pack.find_file('install_file')
      expect(imported_file_meta).to_not(be_nil)
      expect(imported_file_meta.timestamp).to eq('01.06.2017 12:34:56 t00')
    end
  end

  it "can import a file and preserve write/delete set" do install_file_permission_test(0600, 'rwd') end
  it "can import a file and preserve write/delete unset" do install_file_permission_test(0400, 'r') end
  it "can import a file and preserve execute set" do install_file_permission_test(0700, 'rwed') end
  it "can import a file and preserve execute unset" do install_file_permission_test(0600, 'rwd') end

  it "can import a file into a subdirectory when case matches exactly" do
    standard_install_file_context do |workspace, global_config, context, pack, source_file|
      pack.install_file source_file, 'Subdirectory/install_file'
      imported_file_meta = pack.find_file('Subdirectory/install_file')
      expect(imported_file_meta).to_not(be_nil)
      fn = [workspace, 'test'] + imported_file_meta.name.split('/')
      expect(File.exist?(File.join(*fn)))
      File.open(File.join(*fn), 'r') {|f| expect(f.read).to eq("example file being imported") }
    end
  end

  it "can import a file into a subdirectory when case does not match exactly" do
    standard_install_file_context do |workspace, global_config, context, pack, source_file|
      pack.install_file source_file, 'SUBDIRECTORY/install_file'
      imported_file_meta = pack.find_file('Subdirectory/install_file')
      expect(imported_file_meta).to_not(be_nil)
      expect(imported_file_meta.name).to eq('Subdirectory/install_file')
      fn = [workspace, 'test'] + imported_file_meta.name.split('/')
      expect(File.exist?(File.join(*fn)))
    end
  end

  it "can replace an existing file" do
    standard_install_file_context do |workspace, global_config, context, pack, source_file|
      pack.install_file source_file, 'Subdirectory/File'
      imported_file_meta = pack.find_file('Subdirectory/File')
      expect(imported_file_meta).to_not(be_nil)
      fn = [workspace, 'test'] + imported_file_meta.name.split('/')
      expect(File.exist?(File.join(*fn)))
      File.open(File.join(*fn), 'r') {|f| expect(f.read).to eq("example file being imported") }
    end
  end
end
