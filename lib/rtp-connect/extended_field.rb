module RTP

  # The ExtendedField class.
  #
  # @note Relations:
  #   * Parent: Field
  #   * Children: none
  #
  class ExtendedField < Record

    # The Record which this instance belongs to.
    attr_accessor :parent
    attr_reader :field_id
    attr_reader :original_plan_uid
    attr_reader :original_beam_number
    attr_reader :original_beam_name
    attr_reader :is_fff
    attr_reader :accessory_code
    attr_reader :accessory_type
    attr_reader :high_dose_authorization
    attr_reader :referenced_rt_plan_uid
    attr_reader :referenced_rt_plan_relationship

    # Creates a new (treatment) ExtendedField by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the extended treatment field definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [ExtendedField] the created ExtendedField instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      ef = self.new(parent)
      ef.load(string)
    end

    # Creates a new (treatment) ExtendedField.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('EXTENDED_FIELD_DEF', 4, 12)
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Field)
      @parent.add_extended_field(self)
      @attributes = [
        # Required:
        :keyword,
        :field_id,
        :original_plan_uid,
        # Optional:
        :original_beam_number,
        :original_beam_name,
        :is_fff,
        :accessory_code,
        :accessory_type,
        :high_dose_authorization,
        :referenced_rt_plan_uid,
        :referenced_rt_plan_relationship
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

    # Returns self.
    #
    # @return [ExtendedField] self
    #
    def to_extended_field
      self
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

    # Sets the is_fff attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def is_fff=(value)
      @is_fff = value && value.to_s
    end

    # Sets the accessory_code attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def accessory_code=(value)
      @accessory_code = value && value.to_s
    end

    # Sets the accessory_type attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def accessory_type=(value)
      @accessory_type = value && value.to_s
    end

    # Sets the high_dose_authorization attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def high_dose_authorization=(value)
      @high_dose_authorization = value && value.to_s
    end

    # Sets the referenced_rt_plan_uid attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def referenced_rt_plan_uid=(value)
      @referenced_rt_plan_uid = value && value.to_s
    end

    # Sets the referenced_rt_plan_relationship attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def referenced_rt_plan_relationship=(value)
      @referenced_rt_plan_relationship = value && value.to_s
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