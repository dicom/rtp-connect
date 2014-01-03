module RTP

  class << self

    #--
    # Module methods:
    #++

    # Gives an array of MLC leaf position boundaries for a given type of MLC,
    # specified by its number of leaves at one side.
    #
    # @param [Fixnum] nr_leaves the number of leaves (in one leaf bank)
    # @return [Array<Fixnum>] the leaf boundary positions
    # @raise [ArgumentError] if an unsupported MLC (nr of leaves) is given
    #
    def leaf_boundaries(nr_leaves)
      case nr_leaves
      when 29
        leaf_boundaries_odd(29)
      when 40
        leaf_boundaries_even(40)
      when 41
        leaf_boundaries_odd(41)
      when 60
        Array.new(10) {|i| (i * 10 - 200).to_i}
          .concat(Array.new(41) {|i| (i * 5 - 100).to_i})
          .concat(Array.new(10) {|i| (i * 10 + 110).to_i})
      when 80
        leaf_boundaries_even(80)
      else
        raise ArgumentError, "Unsupported number of leaves: #{nr_leaves}"
      end
    end

    # Gives an array of MLC leaf position boundaries for ordinary even numbered
    # multi leaf collimators.
    #
    # @param [Fixnum] nr_leaves the number of leaves (in one leaf bank)
    # @return [Array<Fixnum>] the leaf boundary positions
    #
    def leaf_boundaries_even(nr_leaves)
      Array.new(nr_leaves+1) {|i| (i * 400 / nr_leaves.to_f - 200).to_i}
    end

    # Gives an array of MLC leaf position boundaries for ordinary odd numbered
    # multi leaf collimators.
    #
    # @param [Fixnum] nr_leaves the number of leaves (in one leaf bank)
    # @return [Array<Fixnum>] the leaf boundary positions
    #
    def leaf_boundaries_odd(nr_leaves)
      Array.new(nr_leaves-1) {|i| (10 * (i - (0.5 * nr_leaves - 1))).to_i}.unshift(-200).push(200)
    end

    # Computes the CRC checksum of the given line and verifies that
    # this value corresponds with the checksum given at the end of the line.
    #
    # @param [String] line a single line string from an RTPConnect ascii file
    # @param [Hash] options the options to use for verifying the RTP record
    # @option options [Boolean] :ignore_crc if true, the verification method will return true even if the checksum is invalid
    # @return [Boolean] true
    # @raise [ArgumentError] if an invalid line/record is given or the string contains an invalid checksum
    #
    def verify(line, options={})
      last_comma_pos = line.rindex(',')
      raise ArgumentError, "Invalid line encountered; No comma present in the string: #{line}" unless last_comma_pos
      string_to_check = line[0..last_comma_pos]
      string_remaining = line[(last_comma_pos+1)..-1]
      raise ArgumentError, "Invalid line encountered; Valid checksum missing at end of string: #{string_remaining}" unless string_remaining.length >= 3
      checksum_extracted = string_remaining.value.to_i
      checksum_computed = string_to_check.checksum
      raise ArgumentError, "Invalid line encountered: Specified checksum #{checksum_extracted} deviates from the computed checksum #{checksum_computed}." if checksum_extracted != checksum_computed && !options[:ignore_crc]
      return true
    end

  end

end