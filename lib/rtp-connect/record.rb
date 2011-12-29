module RTP

  class Record

    attr_reader :keyword
    attr_reader :crc

    # Encodes a string from the contents of this instance.
    # This produces the full line, including a computed CRC checksum.
    #
    def encode
      content = values.encode + ","
      checksum = content.checksum
      # Complete string is content + checksum (in double quotes) + carriage return + line feed
      return content + checksum.to_s.wrap + "\r\n"
    end

    # Follows the tree of parents until the appropriate parent of the requesting record is found.
    #
    def get_parent(last_parent, klass)
      if last_parent.is_a?(klass)
        return last_parent
      else
        return last_parent.get_parent(last_parent.parent, klass)
      end
    end

    # Setting the keyword attribute.
    #
    def crc=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @crc = value
    end

  end

end