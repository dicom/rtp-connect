module RTP

  # The ExtendedField class.
  #
  # === Relations
  #
  # * Parent: Field
  # * Children: none
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
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing an extended treatment field record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Get the quote-less values:
      values = string.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 6 elements, got #{values.length}." unless values.length == 6
      f = self.new(parent)
      # Assign the values to attributes:
      f.keyword = values[0]
      f.field_id = values[1]
      f.original_plan_uid = values[2]
      f.original_beam_number = values[3]
      f.original_beam_name = values[4]
      f.crc = values[5]
      return f
    end

    # Creates a new (treatment) ExtendedField.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Parent relation:
      @parent = get_parent(parent, Field)
      @parent.add_extended_field(self)
      @keyword = 'EXTENDED_FIELD_DEF'
    end

    # Returns an empty array, as these instances are child-less by definition.
    #
    def children
      return Array.new
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
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

    # Writes the ExtendedField object + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
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
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'EXTENDED_FIELD_DEF', got #{value}." unless value == "EXTENDED_FIELD_DEF"
      @keyword = value
    end

    # Sets the field_id attribute.
    #
    def field_id=(value)
      @field_id = value && value.to_s
    end

    # Sets the original_plan_uid attribute.
    #
    def original_plan_uid=(value)
      @original_plan_uid = value && value.to_s
    end

    # Sets the original_beam_number attribute.
    #
    def original_beam_number=(value)
      @original_beam_number = value && value.to_s
    end

    # Sets the original_beam_name attribute.
    #
    def original_beam_name=(value)
      @original_beam_name = value && value.to_s
    end

  end

end