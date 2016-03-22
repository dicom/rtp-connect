module RTP

  # The Record class contains attributes and methods that are common
  # for the various record types defined in the RTPConnect standard.
  #
  class Record

    # For most record types, there are no surplus (grouped) attributes.
    NR_SURPLUS_ATTRIBUTES = 0

    # An array of the record's attributes.
    attr_reader :attributes
    # The keyword defines the record type of a particular RTP string line.
    attr_reader :keyword
    # The CRC is used to validate the integrity of the content of the RTP string line.
    attr_reader :crc

    # Creates a new Record.
    #
    # @param [String] keyword the keyword which identifies this record
    # @param [Integer] min_elements the minimum number of data elements required for this record
    # @param [Integer] max_elements the maximum supported number of data elements for this record
    #
    def initialize(keyword, min_elements, max_elements)
      @keyword = keyword
      @min_elements = min_elements
      @max_elements = max_elements
    end

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
    # @param [Hash] options an optional hash parameter
    # @option options [Float] :version the Mosaiq compatibility version number (e.g. 2.4) used for the output
    # @return [String] a proper RTPConnect type CSV string
    #
    def encode(options={})
      encoded_values = values.collect {|v| v && v.encode('ISO8859-1')}
      encoded_values = discard_unsupported_attributes(encoded_values, options) if options[:version]
      content = CSV.generate_line(encoded_values, force_quotes: true, row_sep: '') + ","
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

    # Verifies a proposed keyword attribute.
    #
    # @note Since only a specific string is accepted, this is more of an argument check than a traditional setter method.
    # @param [#to_s] value the proposed keyword attribute
    # @raise [ArgumentError] if given an unexpected keyword
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected '#{@keyword}', got #{value}." unless value == @keyword
    end

    # Sets up a record by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the extended treatment field definition record string line
    # @return [Record] the updated Record instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def load(string, options={})
      # Extract processed values:
      values = string.to_s.values(options[:repair])
      raise ArgumentError, "Invalid argument 'string': Expected at least #{@min_elements} elements for #{@keyword}, got #{values.length}." if values.length < @min_elements
      RTP.logger.warn "The number of given elements (#{values.length}) exceeds the known number of data elements for this record (#{@max_elements}). This may indicate an invalid string record or that the RTP format has recently been expanded with new elements." if values.length > @max_elements
      self.send(:set_attributes, values)
      self
    end

    # Returns self.
    #
    # @return [Record] self
    #
    def to_record
      self
    end

    # Encodes the record + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
    #
    # @param [Hash] options an optional hash parameter
    # @option options [Float] :version the Mosaiq compatibility version number (e.g. 2.4) used for the output
    # @return [String] an RTP string with a single or multiple lines/records
    #
    def to_s(options={})
      str = encode(options)
      children.each do |child|
        # Note that the extended plan record was introduced in Mosaiq 2.5.
        str += child.to_s(options) unless child.class == ExtendedPlan && options[:version].to_f < 2.5
      end
      str
    end

    alias :to_str :to_s

    # Collects the values (attributes) of this instance.
    #
    # @note The CRC is not considered part of the actual values and is excluded.
    # @return [Array<String>] an array of attributes (in the same order as they appear in the RTP string)
    #
    def values
      @attributes.collect {|attribute| self.send(attribute)}
    end


    private


    # Removes the reference of the given instance from the attribute of this record.
    #
    # @param [Symbol] attribute the name of the child attribute from which to remove a child
    # @param [Record] instance a child record to be removed from this instance
    #
    def delete_child(attribute, instance=nil)
      if self.send(attribute).is_a?(Array)
        deleted = self.send(attribute).delete(instance)
        deleted.parent = nil if deleted
      else
        self.send(attribute).parent = nil if self.send(attribute)
        self.instance_variable_set("@#{attribute}", nil)
      end
    end

    # Removes all child references of the given type from this instance.
    #
    # @param [Symbol] attribute the name of the child attribute to be cleared
    #
    def delete_children(attribute)
      self.send(attribute).each { |c| c.parent = nil }
      self.send(attribute).clear
    end

    # Sets the attributes of the record instance.
    #
    # @param [Array<String>] values the record attributes (as parsed from a record string)
    #
    def set_attributes(values)
      import_indices([values.length - 1, @max_elements - 1].min).each_with_index do |indices, i|
        param = values.values_at(*indices)
        param = param[0] if param.length == 1
        self.send("#{@attributes[i]}=", param)
      end
      @crc = values[-1]
    end

    # Gives an array of indices indicating where the attributes of this record gets its
    # values from in the comma separated string which the instance is created from.
    #
    # @param [Integer] length the number of elements to create in the indices array
    #
    def import_indices(length)
      Array.new(length - NR_SURPLUS_ATTRIBUTES) { |i| [i] }
    end

    # Removes any attributes that are newer than the given compatibility target version.
    # E.g. if a compatibility version of Mosaiq 2.4 is specified, attributes that were
    # introduced in Mosaiq 2.5 or later is removed before the RTP string is created.
    #
    # @param [Array<String>] values the complete set of values of this record
    # @param [Hash] options an optional hash parameter
    # @option options [Float] :version the Mosaiq compatibility version number (e.g. 2.4) used for the output
    # @return [Array<String>] an array of attributes where some of the recent attributes may have been removed
    #
    def discard_unsupported_attributes(values, options={})
      case self
      when SiteSetup
        options[:version].to_f >= 2.6 ? values : values[0..-4]
      when ExtendedField
        options[:version].to_f >= 2.4 ? values : values[0..-5]
      else
        values
      end
    end

  end

end