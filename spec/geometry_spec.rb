require 'spec_helper'
require 'wbck/util/geometry'

describe Wbck::Util::Geometry do

  it 'parses correctly' do
    geom = Wbck::Util::Geometry.new('1024/16/63')
    expect(geom.cylinders).to eq(1024)
    expect(geom.heads).to eq(16)
    expect(geom.sectors).to eq(63)
  end

  it 'calculates blocks-per-cylinder' do
    geom = Wbck::Util::Geometry.new('1024/16/63')
    expect(geom.blocks_per_cylinder).to eq(1008)
  end

  it 'calculates total blocks' do
    geom = Wbck::Util::Geometry.new('1024/16/63')
    expect(geom.total_blocks).to eq(1032192)
  end

  it 'calculates bytes-per-cylinder' do
    geom = Wbck::Util::Geometry.new('1024/16/63')
    expect(geom.bytes_per_cylinder).to eq(516096)
  end

  it 'calculates total bytes' do
    geom = Wbck::Util::Geometry.new('1024/16/63')
    expect(geom.total_bytes).to eq(528482304)
  end

  it 'rejects malformed input' do
    expect { Wbck::Util::Geometry.new('1024/16') }.to raise_error(ArgumentError)
  end

  it 'rejects zero values' do
    expect { Wbck::Util::Geometry.new('0/16/63') }.to raise_error(ArgumentError)
    expect { Wbck::Util::Geometry.new('1024/0/63') }.to raise_error(ArgumentError)
    expect { Wbck::Util::Geometry.new('1024/16/0') }.to raise_error(ArgumentError)
  end

  it 'rejects negative values' do
    expect { Wbck::Util::Geometry.new('-1024/16/63') }.to raise_error(ArgumentError)
    expect { Wbck::Util::Geometry.new('1024/-16/63') }.to raise_error(ArgumentError)
    expect { Wbck::Util::Geometry.new('1024/16/-63') }.to raise_error(ArgumentError)
  end

end
