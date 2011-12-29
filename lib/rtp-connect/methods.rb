module RTP

  class << self

    #--
    # Module methods:
    #++

    # Computes the CRC checksum of the given line and verifies that
    # this value corresponds with the checksum given at the end of the line.
    # Raises an error if the two values does not match.
    #
    # === Parameters
    #
    # * <tt>line</tt> -- An single line string from an RTPConnect ascii file.
    #
    def verify(line)
      last_comma_pos = line.rindex(',')
      raise ArgumentError, "Invalid line encountered; No comma present in the string: #{line}" unless last_comma_pos
      string_to_check = line[0..last_comma_pos]
      string_remaining = line[(last_comma_pos+1)..-1]
      raise ArgumentError, "Invalid line encountered; Valid checksum missing at end of string: #{string_remaining}" unless string_remaining.length > 3
      checksum_extracted = string_remaining.value.to_i
      checksum_computed = string_to_check.checksum
      raise ArgumentError, "Invalid line encountered: Specified checskum #{checksum_extracted} deviates from the computed checksum #{checksum_computed}." if checksum_extracted != checksum_computed
      return true
    end

  end

end