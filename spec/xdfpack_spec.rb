require 'spec_helper'
require 'wbck/context'
require 'wbck/util/shell_executor'
require 'wbck/util/xdf_pack'

TEST_DATA_LOCATION = File.join(Dir.getwd, 'spec', 'test_data')
UNPACKED_LOCATION = File.join(TEST_DATA_LOCATION, 'unpacked', 'XdfPackTest')
PACKED_FILE = File.join(TEST_DATA_LOCATION, 'XdfPackTest.adf')
ANOTHER_PACKED_FILE = File.join(TEST_DATA_LOCATION, 'Another.adf')

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
    Dir.mktmpdir() do |workspace|
      global_config = {'filename' => '/dev/null', 'geometry' => '7751/16/63'}
      context = Wbck::Context.new(global_config, nil, Wbck::Util::ShellExecutor.new(), workspace)
      pack = Wbck::Util::XdfPack.unpack(context, 'test', PACKED_FILE)
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
    Dir.mktmpdir() do |workspace|
      global_config = {'filename' => '/dev/null', 'geometry' => '7751/16/63'}
      context = Wbck::Context.new(global_config, nil, Wbck::Util::ShellExecutor.new(), workspace)
      pack = Wbck::Util::XdfPack.unpack(context, 'test', PACKED_FILE)
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

end
