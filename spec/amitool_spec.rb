require 'spec_helper'
require 'wbck/util/geometry'
require 'wbck/util/amitool'

describe Wbck::Util::Amitool do

  it 'generates a correct rdbtool command' do
    image_name = 'test.hdf'
    geom = Wbck::Util::Geometry.new('1024/16/63')
    executor = double('shell_executor')
    expect(executor).to receive(:execute).with(['rdbtool', image_name, 'open', 'c=1024', 'h=16', 's=63', '+', 'info'])

    amitool = Wbck::Util::Amitool.new(image_name, geom, executor)
    amitool.rdbtool([ Wbck::Util::Amitool::Command.new('info', [], {}) ])
  end

  it 'generates a correct xdftool command' do
    image_name = 'test.hdf'
    geom = Wbck::Util::Geometry.new('1024/16/63')
    executor = double('shell_executor')
    expect(executor).to receive(:execute).with(['xdftool', image_name, 'open', 'c=1024', 'h=16', 's=63', 'part=CF0', '+', 'format', 'MainHD', 'DOS3'])

    amitool = Wbck::Util::Amitool.new(image_name, geom, executor)
    amitool.xdftool('CF0', [ Wbck::Util::Amitool::Command.new('format', [ 'MainHD', 'DOS3' ], {}) ])
  end

end
