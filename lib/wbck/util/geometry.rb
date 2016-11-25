module Wbck::Util
  # Parses a disk's geometry string, like '1024/16/63'.
  #
  # A disk's geometry is expressed as the number of cylinders, heads and sectors. The geometry string is these three
  # values in that order, separated by '/' characters. Each value must be at least one.
  #
  # Once parsed, some derived values such as #blocks_per_cylinder are available.
  #
  # Geometry objects are immutable; they contain properties that can be read, but no way to change the geometry after it
  # has been instantiated.
  class Geometry

    PATTERN = /^(?<c>\d+)\/(?<h>\d+)\/(?<s>\d+)$/
    BYTES_PER_BLOCK = 512

    # the number of cyclinders
    attr_reader :cylinders
    # the number of heads
    attr_reader :heads
    # the number of sectors
    attr_reader :sectors
    # the number of blocks in a cylinder, that is #heads multiplied by #sectors
    attr_reader :blocks_per_cylinder
    # the number of bytes in a cylinder, assuming 512-byte blocks/sectors
    attr_reader :bytes_per_cylinder
    # the total number of blocks on the disk, that is #cylinders multiplied by #blocks_per_cylinder
    attr_reader :total_blocks
    # the total number of bytes on the disk, assuming 512-byte blocks/sectors
    attr_reader :total_bytes

    # Parses a disk's geometry string, like '1024/16/63'.
    #
    # A disk's geometry is expressed as the number of cylinders, heads and sectors. The geometry string is these three
    # values in that order, separated by '/' characters. Each value must be at least one.
    def initialize(geom_string)
      match = PATTERN.match(geom_string)
      raise(ArgumentError.new("geometry string '#{geom_string}' malformed")) unless match
      @cylinders = match['c'].to_i
      raise(ArgumentError.new("cylinders value '#{geom_string}' must be at least 1")) unless @cylinders >= 1
      @heads = match['h'].to_i
      raise(ArgumentError.new("heads value '#{geom_string}' must be at least 1")) unless @heads >= 1
      @sectors = match['s'].to_i
      raise(ArgumentError.new("sectors value '#{geom_string}' must be at least 1")) unless @sectors >= 1
      @blocks_per_cylinder = @heads * @sectors
      @bytes_per_cylinder = @blocks_per_cylinder * BYTES_PER_BLOCK
      @total_blocks = @cylinders * @blocks_per_cylinder
      @total_bytes = @total_blocks * BYTES_PER_BLOCK
    end

  end
end
