module RTP

  # The ExtendedField class.
  #
  # @note Relations:
  #   * Parent: Field
  #   * Children: none
  #
  class ExtendedField < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    attr_reader :field_id
    attr_reader :original_plan_uid
    attr_reader :original_beam_number
    attr_reader :original_beam_name

    # Creates a new (treatment) ExtendedField by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the extended treatment field definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [ExtendedField] the created ExtendedField instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 6 elements, got #{values.length}." unless values.length == 6
      ef = self.new(parent)
      # Assign the values to attributes:
      ef.keyword = values[0]
      ef.field_id = values[1]
      ef.original_plan_uid = values[2]
      ef.original_beam_number = values[3]
      ef.original_beam_name = values[4]
      ef.crc = values[5]
      return ef
    end

    # Creates a new (treatment) ExtendedField.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Field)
      @parent.add_extended_field(self)
      @keyword = 'EXTENDED_FIELD_DEF'
    end

    # Checks for equality.
    #
    # Other and self are considered equivalent if they are
    # of compatible types and their attributes are equivalent.
    #
    # @param other an object to be compared with self.
    # @return [Boolean] true if self and other are considered equivalent
    #
    def ==(other)
      if other.respond_to?(:to_extended_field)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Gives an empty array, as these instances are child-less by definition.
    #
    # @return [Array] an emtpy array
    #
    def children
      return Array.new
    end

    # Computes a hash code for this object.
    #
    # @note Two objects with the same attributes will have the same hash code.
    #
    # @return [Fixnum] the object's hash code
    #
    def hash
      state.hash
    end

    # Collects the values (attributes) of this instance.
    #
    # @note The CRC is not considered part of the actual values and is excluded.
    # @return [Array<String>] an array of attributes (in the same order as they appear in the RTP string)
    #
    def values
      return [
        @keyword,
        @field_id,
        @original_plan_uid,
        @original_beam_number,
        @original_beam_name
      ]
    end

    # Returns self.
    #
    # @return [ExtendedField] self
    #
    def to_extended_field
      self
    end

    # Encodes the ExtendedField object + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
    #
    # @return [String] an RTP string with a single or multiple lines/records
    #
    def to_s
      str = encode
      if children
        children.each do |child|
          str += child.to_s
        end
      end
      return str
    end

    alias :to_str :to_s

    # Sets the keyword attribute.
    #
    # @note Since only a specific string is accepted, this is more of an argument check than a traditional setter method
    # @param [#to_s] value the new attribute value
    # @raise [ArgumentError] if given an unexpected keyword
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'EXTENDED_FIELD_DEF', got #{value}." unless value == "EXTENDED_FIELD_DEF"
      @keyword = value
    end

    # Sets the field_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_id=(value)
      @field_id = value && value.to_s
    end

    # Sets the original_plan_uid attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def original_plan_uid=(value)
      @original_plan_uid = value && value.to_s
    end

    # Sets the original_beam_number attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def original_beam_number=(value)
      @original_beam_number = value && value.to_s
    end

    # Sets the original_beam_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def original_beam_name=(value)
      @original_beam_name = value && value.to_s
    end


    private


    # Collects the attributes of this instance.
    #
    # @note The CRC is not considered part of the attributes of interest and is excluded
    # @return [Array<String>] an array of attributes
    #
    alias_method :state, :values

  end

end