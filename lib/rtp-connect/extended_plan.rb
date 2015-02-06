module RTP

  # The Extended plan class.
  #
  # @note Relations:
  #   * Parent: Plan
  #   * Children: none
  #
  class ExtendedPlan < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    attr_reader :encoding
    attr_reader :fullname

    # Creates a new ExtendedPlan by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the extended plan definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [ExtendedPlan] the created ExtendedPlan instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      ep = self.new(parent)
      ep.load(string)
    end

    # Creates a new ExtendedPlan.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('EXTENDED_PLAN_DEF', 4, 4)
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_extended_plan(self)
      @attributes = [
        # Required:
        :keyword,
        :encoding,
        :fullname
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
      if other.respond_to?(:to_extended_plan)
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
    # @return [ExtendedPlan] self
    #
    def to_extended_plan
      self
    end

    # Encodes the ExtendedPlan object + any hiearchy of child objects,
    # to a properly formatted RTPConnect ascii string.
    #
    # @param [Hash] options an optional hash parameter
    # @option options [Float] :version the Mosaiq compatibility version number (e.g. 2.4) used for the output
    # @return [String] an RTP string with a single or multiple lines/records
    #
    def to_s(options={})
      str = encode(options)
      if children
        children.each do |child|
          str += child.to_s(options)
        end
      end
      return str
    end

    alias :to_str :to_s

    # Sets the encoding attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def encoding=(value)
      @encoding = value && value.to_s
    end

    # Sets the fullname attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def fullname=(value)
      @fullname = value && value.to_s
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