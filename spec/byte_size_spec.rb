require 'spec_helper'
require 'wbck/util/byte_size'

describe Wbck::Util::ByteSize do

  it 'parses 0 correctly' do
    byte_size = Wbck::Util::ByteSize.new(0)
    expect(byte_size.bytes).to eq(0)
  end

  it 'parses "0b" correctly' do
    byte_size = Wbck::Util::ByteSize.new('0b')
    expect(byte_size.bytes).to eq(0)
  end

  it 'parses 1 correctly' do
    byte_size = Wbck::Util::ByteSize.new(1)
    expect(byte_size.bytes).to eq(1)
  end

  it 'parses "1" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1')
    expect(byte_size.bytes).to eq(1)
  end

  it 'parses "1b" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1b')
    expect(byte_size.bytes).to eq(1)
  end

  it 'parses "1B" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1B')
    expect(byte_size.bytes).to eq(1)
  end

  it 'parses "1kb" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1kb')
    expect(byte_size.bytes).to eq(1000)
  end

  it 'parses "1KB" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1KB')
    expect(byte_size.bytes).to eq(1000)
  end

  it 'parses "1kib" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1kib')
    expect(byte_size.bytes).to eq(1024)
  end

  it 'parses "1KiB" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1KiB')
    expect(byte_size.bytes).to eq(1024)
  end

  it 'parses "1KIB" correctly' do
    byte_size = Wbck::Util::ByteSize.new('1KIB')
    expect(byte_size.bytes).to eq(1024)
  end

  it 'rejects malformed input' do
    expect { Wbck::Util::ByteSize.new('foo') }.to raise_error(ArgumentError)
  end

  it 'rejects negative values' do
    expect { Wbck::Util::ByteSize.new('-1b') }.to raise_error(ArgumentError)
  end

  it 'renders 1000 as 1.0kB' do
    byte_size = Wbck::Util::ByteSize.new(1000)
    expect(byte_size.to_s).to eq('1.0kB')
  end

  it 'renders 1024 as 1.0kiB' do
    byte_size = Wbck::Util::ByteSize.new(1024)
    expect(byte_size.to_s).to eq('1.0kiB')
  end

  it 'renders 1000000 as 1.0MB' do
    byte_size = Wbck::Util::ByteSize.new(1000000)
    expect(byte_size.to_s).to eq('1.0MB')
  end

  it 'renders 1048576 as 1.0MiB' do
    byte_size = Wbck::Util::ByteSize.new(1048576)
    expect(byte_size.to_s).to eq('1.0MiB')
  end

end
