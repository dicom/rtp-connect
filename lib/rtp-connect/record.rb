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
      content = CSV.generate_line(values, force_quotes: true, row_sep: '') + ","
      checksum = content.checksum
      # Complete string is content + checksum (in double quotes) + carriage return + line feed
      return (content + checksum.to_s.wrap + "\r\n").encode('ISO8859-1')
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

    # Vverifies a proposed keyword attribute.
    #
    # @note Since only a specific string is accepted, this is more of an argument check than a traditional setter method.
    # @param [#to_s] value the proposed keyword attribute
    # @raise [ArgumentError] if given an unexpected keyword
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected '#{@keyword}', got #{value}." unless value == @keyword
    end

    # Returns self.
    #
    # @return [Record] self
    #
    def to_record
      self
    end


    private


    # Sets the attributes of the record instance.
    #
    # @param [Array<String>] values the record attributes (as parsed from a record string)
    #
    def set_attributes(values)
      @attributes.each_index {|i| self.send("#{@attributes[i]}=", values[i])}
      @crc = values[-1]
    end

  end

end