module RTP

  # The DoseTracking class.
  #
  # === Relations
  #
  # * Parent: Plan
  # * Children: DoseAction
  #
  class DoseTracking < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The DoseAction records (if any) that belongs to this DoseTracking.
    attr_reader :dose_actions
    attr_reader :region_name
    attr_reader :region_prior_dose
    # Note: This attribute contains an array of all field_id values (1..10).
    attr_reader :field_ids
    # Note: This attribute contains an array of all reg_coeff values (1..10).
    attr_reader :region_coeffs
    attr_reader :actual_dose
    attr_reader :actual_fractions

    # Creates a new DoseTracking by parsing a RTPConnect string line.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a control point record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 26 elements, got #{values.length}." unless values.length == 26
      d = self.new(parent)
      # Assign the values to attributes:
      d.keyword = values[0]
      d.region_name = values[1]
      d.region_prior_dose = values[2]
      d.field_ids = values.values_at(3, 5, 7, 9, 11, 13, 15, 17, 19, 21)
      d.region_coeffs = values.values_at(4, 6, 8, 10, 12, 14, 16, 18, 20, 22)
      d.actual_dose = values[23]
      d.actual_fractions = values[24]
      d.crc = values[25]
      return d
    end

    # Creates a new DoseTracking.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      # Child records:
      @dose_actions = Array.new
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_dose_tracking(self)
      @keyword = 'DOSE_DEF'
      @field_ids = Array.new(10)
      @region_coeffs = Array.new(10)
    end

    # Returns true if the argument is an instance with attributes equal to self.
    #
    def ==(other)
      if other.respond_to?(:to_dose_tracking)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # As of now, returns an empty array.
    # However, by definition, this record may have dose action (points) as children,
    # but this is not implemented yet.
    #
    def children
      #return @dose_actions
      return Array.new
    end

    # Generates a Fixnum hash value for this instance.
    #
    def hash
      state.hash
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
    #
    def values
      return [
        @keyword,
        @region_name,
        @region_prior_dose,
        # Need to join every other two elements from these two arrays together:
        *@field_ids.zip(@region_coeffs).flatten,
        @actual_dose,
        @actual_fractions
      ]
    end

    # Returns self.
    #
    def to_dose_tracking
      self
    end

    # Writes the DoseTracking object + any hiearchy of child objects,
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

    # Sets the field_ids attribute.
    #
    # === Notes
    #
    # As opposed to the ordinary (string) attributes, this attribute
    # contains an array holding all 10 Field ID string values.
    #
    def field_ids=(array)
      array = array.to_a
      raise ArgumentError, "Invalid argument 'array'. Expected length 10, got #{array.length}." unless array.length == 10
      @field_ids = array.collect! {|e| e && e.to_s}
    end

    # Sets the region_coeffs attribute.
    #
    # === Notes
    #
    # As opposed to the ordinary (string) attributes, this attribute
    # contains an array holding all 10 Region Coeff string values.
    #
    def region_coeffs=(array)
      array = array.to_a
      raise ArgumentError, "Invalid argument 'array'. Expected length 10, got #{array.length}." unless array.length == 10
      @region_coeffs = array.collect! {|e| e && e.to_s}
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'DOSE_DEF', got #{value}." unless value == "DOSE_DEF"
      @keyword = value
    end

    # Sets the region_name attribute.
    #
    def region_name=(value)
      @region_name = value && value.to_s
    end

    # Sets the region_prior_dose attribute.
    #
    def region_prior_dose=(value)
      @region_prior_dose = value && value.to_s
    end

    # Sets the actual_dose attribute.
    #
    def actual_dose=(value)
      @actual_dose = value && value.to_s
    end

    # Sets the actual_fractions attribute.
    #
    def actual_fractions=(value)
      @actual_fractions = value && value.to_s
    end


    private


    # Returns the attributes of this instance in an array (for comparison purposes).
    #
    alias_method :state, :values

  end

end