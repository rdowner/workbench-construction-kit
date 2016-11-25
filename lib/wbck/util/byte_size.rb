require 'bigdecimal'

module Wbck::Util
  # Parses a numeric value of bytes with optional metric unit prefix and/or 'b' unit. Examples: 56, 2kb, 4k, 6GiB.
  #
  # Metric unit prefixes that are understood are k, M, G, T, P, E, Z and Y for 1,000, 1,000,000, etc. Also understood
  # are the 1,024 based system ki, Mi, Gi, etc.
  #
  # An option unit of 'b' can be given. 1kb and 1k are both parsed the same.
  #
  # Finally, if the input is numeric, it is parsed as a simple integer number of bytes.
  #
  # The #to_s method is overridden to show the number of bytes in a convenient manner; for example, 1048576 would be
  # shown as '1.0MiB'.
  class ByteSize

    PATTERN = /^(?<qty>\d+)((?<factor>([kMGTPEZY]i?)?)[Bb]?)?$/i
    FACTORS = {
      '' => 1,
      'k' => 1000, 'ki' => 1024,
      'M' => 1000 ** 2, 'Mi' => 1024 ** 2,
      'G' => 1000 ** 3, 'Gi' => 1024 ** 3,
      'T' => 1000 ** 4, 'Ti' => 1024 ** 4,
      'P' => 1000 ** 5, 'Pi' => 1024 ** 5,
      'E' => 1000 ** 6, 'Ei' => 1024 ** 6,
      'Z' => 1000 ** 7, 'Zi' => 1024 ** 7,
      'Y' => 1000 ** 8, 'Yi' => 1024 ** 8,
    }
    FACTORS_UPPER_CASE = FACTORS.inject({}) { |h, (k, v)| h[k.upcase] = v; h }

    # The integer number of bytes.
    attr_reader :bytes

    # Parses a numeric value of bytes with optional metric unit prefix and/or 'b' unit. Examples: 56, 2kb, 4k, 6GiB.
    #
    # Metric unit prefixes that are understood are k, M, G, T, P, E, Z and Y for 1,000, 1,000,000, etc. Also understood
    # are the 1,024 based system ki, Mi, Gi, etc.
    #
    # An option unit of 'b' can be given. 1kb and 1k are both parsed the same.
    #
    # Finally, if the input is numeric, it is parsed as a simple integer number of bytes.
    def initialize(in_string)
      if in_string.is_a? Numeric
        @bytes = in_string.to_i
      else
        match = PATTERN.match(in_string)
        raise(ArgumentError.new("input string #{in_string} malformed")) unless match

        qty = match['qty'].to_i
        factor = match['factor']
        f = FACTORS_UPPER_CASE[factor.upcase]
        @bytes = qty * f
      end
    end

    def to_s
      return '0' if @bytes == 0
      suitable_factors = FACTORS.clone.keep_if do |unit, factor|
        var = (@bytes / factor)
        var > 0 && var < 1024
      end
      suitable_factors = { 'Y' => FACTORS['Y'] } if suitable_factors.empty?
      inverted_factors = suitable_factors.invert
      highest = inverted_factors.keys.max
      unit = inverted_factors[highest]
      divided = @bytes.to_f/highest
      formatted = BigDecimal.new(divided, 3).to_f
      "#{formatted}#{unit}B"
    end

  end
end
