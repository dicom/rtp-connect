module RTP

  # The Record class contains attributes and methods that are common
  # for the various record types defined in the RTPConnect standard.
  #
  class Record

    # The keyword defines the record type of a particular RTP string line.
    attr_reader :keyword
    # The CRC is used to validate the integrity of the content of the RTP string line.
    attr_reader :crc

    # Sets the crc (checksum) attribute.
    #
    # @note This value is not used when creating an RTP string from a record (a new crc is calculated)
    # @param [#to_s] value the new attribute value
    #
    def crc=(value)
      @crc = value.to_s
    end

    # Encodes a string from the contents of this instance.
    #
    # This produces the full record string line, including a computed CRC checksum.
    #
    # @return [String] a proper RTPConnect type CSV string
    #
    def encode
      content = values.encode + ","
      checksum = content.checksum
      # Complete string is content + checksum (in double quotes) + carriage return + line feed
      return content + checksum.to_s.wrap + "\r\n"
    end

    # Follows the tree of parents until the appropriate parent of the requesting record is found.
    #
    # @param [Record] last_parent the previous parent (the record from the previous line in the RTP file)
    # @param [Record] klass the expected parent record class of this record (e.g. Plan, Field)
    #
    def get_parent(last_parent, klass)
      if last_parent.is_a?(klass)
        return last_parent
      else
        return last_parent.get_parent(last_parent.parent, klass)
      end
    end

    # Returns self.
    #
    # @return [Record] self
    #
    def to_record
      self
    end

  end

end