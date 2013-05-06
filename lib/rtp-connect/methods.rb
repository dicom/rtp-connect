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
        [-200, -135, -125, -115, -105, -95, -85, -75, -65, -55, -45, -35, -25,
          -15, -5, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95, 105, 115, 125, 135, 200
        ]
      when 40
        Array.new(nr_leaves) {|i| (i * 400 / nr_leaves.to_f - 200).to_i}
      when 41
        [-200, -195, -185, -175, -165, -155, -145, -135, -125, -115,
          -105, -95, -85, -75, -65, -55, -45, -35, -25, -15, -5, 5, 15, 25, 35, 45,
          55, 65, 75, 85, 95, 105, 115, 125, 135, 145, 155, 165, 175, 185, 195, 200
        ]
      when 60
        [-200, -190, -180, -170, -160, -150, -140, -130, -120, -110,
          -100, -95, -90, -85, -80, -75, -70, -65, -60, -55, -50, -45, -40, -35, -30,
          -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65,
          70, 75, 80, 85, 90, 95, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200
        ]
      when 80
        Array.new(nr_leaves) {|i| (i * 400 / nr_leaves.to_f - 200).to_i}
      else
        raise ArgumentError, "Unsupported number of leaves: #{nr_leaves}"
      end
    end

    # Computes the CRC checksum of the given line and verifies that
    # this value corresponds with the checksum given at the end of the line.
    #
    # @param [String] line a single line string from an RTPConnect ascii file
    # @return [Boolean] true
    # @raise [ArgumentError] if an invalid line/record is given or the string contains an invalid checksum
    #
    def verify(line)
      last_comma_pos = line.rindex(',')
      raise ArgumentError, "Invalid line encountered; No comma present in the string: #{line}" unless last_comma_pos
      string_to_check = line[0..last_comma_pos]
      string_remaining = line[(last_comma_pos+1)..-1]
      raise ArgumentError, "Invalid line encountered; Valid checksum missing at end of string: #{string_remaining}" unless string_remaining.length >= 3
      checksum_extracted = string_remaining.value.to_i
      checksum_computed = string_to_check.checksum
      raise ArgumentError, "Invalid line encountered: Specified checskum #{checksum_extracted} deviates from the computed checksum #{checksum_computed}." if checksum_extracted != checksum_computed
      return true
    end

  end

end