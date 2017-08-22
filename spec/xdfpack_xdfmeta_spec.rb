require 'spec_helper'
require 'wbck/util/xdf_pack'

TEST_DATA = [
  "XdfPackTest:DOS0,22.08.2009 11:14:40 t28,22.08.2009 12:16:43 t21,22.08.2009 12:14:15 t32\n",
  "Disk.info:rwd,22.08.2009 12:14:15 t32,\n",
  "Subdirectory:rwed,22.08.2009 12:16:42 t22,\n",
  "Subdirectory.info:rwd,22.08.2009 12:14:00 t22,\n",
  "Subdirectory/File:rwd,22.08.2009 12:16:21 t15,\n",
  "Subdirectory/File.info:rwd,22.08.2009 12:16:42 t44,\n"
]

describe Wbck::Util::XdfPack::XdfMeta do

  it 'parses disk metadata' do
    metadata = Wbck::Util::XdfPack::XdfMeta.new(TEST_DATA)
    expect(metadata.disk_name).to eq('XdfPackTest')
    expect(metadata.dos_type).to eq('DOS0')
    expect(metadata.format_timestamp).to eq('22.08.2009 11:14:40 t28')
    expect(metadata.changed_timestamp).to eq('22.08.2009 12:16:43 t21')
    expect(metadata.rootblock_changed_timestamp).to eq('22.08.2009 12:14:15 t32')
  end

  it 'parses disk content metadata' do
    metadata = Wbck::Util::XdfPack::XdfMeta.new(TEST_DATA)
    content = metadata.all_content
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

end
