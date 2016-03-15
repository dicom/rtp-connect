module RTP

  # The DoseTracking class.
  #
  # @note Relations:
  #   * Parent: Plan
  #   * Children: none
  #
  class DoseTracking < Record

    # The number of attributes not having their own variable for this record (20 - 2).
    NR_SURPLUS_ATTRIBUTES = 18

    # The Record which this instance belongs to.
    attr_accessor :parent
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
    # @param [#to_s] string the dose tracking definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [DoseTracking] the created DoseTracking instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      d = self.new(parent)
      d.load(string)
    end

    # Creates a new DoseTracking.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('DOSE_DEF', 24, 26)
      # Child records:
      @dose_actions = Array.new
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_dose_tracking(self)
      @field_ids = Array.new(10)
      @region_coeffs = Array.new(10)
      @attributes = [
        # Required:
        :keyword,
        :region_name,
        :region_prior_dose,
        :field_ids,
        :region_coeffs,
        # Optional:
        :actual_dose,
        :actual_fractions
      ]
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
      if other.respond_to?(:to_dose_tracking)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # As of now, gives an empty array. However, by definition, this record may
    # have dose action (point) records as children, but this is not implemented yet.
    #
    # @return [Array] an emtpy array
    #
    def children
      #return @dose_actions
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
      [
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
    # @return [DoseTracking] self
    #
    def to_dose_tracking
      self
    end

    # Sets the field_ids attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 10 Field ID string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def field_ids=(array)
      @field_ids = array.to_a.validate_and_process(10)
    end

    # Sets the region_coeffs attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 10 Region Coeff string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def region_coeffs=(array)
      @region_coeffs = array.to_a.validate_and_process(10)
    end

    # Sets the region_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def region_name=(value)
      @region_name = value && value.to_s
    end

    # Sets the region_prior_dose attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def region_prior_dose=(value)
      @region_prior_dose = value && value.to_s
    end

    # Sets the actual_dose attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def actual_dose=(value)
      @actual_dose = value && value.to_s
    end

    # Sets the actual_fractions attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def actual_fractions=(value)
      @actual_fractions = value && value.to_s
    end


    private


    # Collects the attributes of this instance.
    #
    # @note The CRC is not considered part of the attributes of interest and is excluded
    # @return [Array<String>] an array of attributes
    #
    alias_method :state, :values

    # Gives an array of indices indicating where the attributes of this record gets its
    # values from in the comma separated string which the instance is created from.
    #
    # @param [Integer] length the number of elements to create in the indices array
    #
    def import_indices(length)
      # Note that this method is defined in the parent Record class, where it is
      # used for most record types. However, because this record has two attributes
      # which contain an array of values, we use a custom import_indices method.
      ind = Array.new(length - NR_SURPLUS_ATTRIBUTES) { |i| i }
      # Override indices for field_ids and region_coeffs:
      ind[3] = [3, 5, 7, 9, 11, 13, 15, 17, 19, 21]
      ind[4] = [4, 6, 8, 10, 12, 14, 16, 18, 20, 22]
      ind[5, 6] = [23, 24]
      ind
    end

  end

end