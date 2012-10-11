module RTP

  # The Prescription site class.
  #
  # @note Relations:
  #   * Parent: Plan
  #   * Children: SiteSetup, Field
  #
  class Prescription < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The SiteSetup record (if any) that belongs to this Prescription.
    attr_reader :site_setup
    # An array of Field records (if any) that belongs to this Prescription.
    attr_reader :fields
    attr_reader :course_id
    attr_reader :rx_site_name
    attr_reader :technique
    attr_reader :modality
    attr_reader :dose_spec
    attr_reader :rx_depth
    attr_reader :dose_ttl
    attr_reader :dose_tx
    attr_reader :pattern
    attr_reader :rx_note
    attr_reader :number_of_fields

    # Creates a new Prescription site by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the prescription site definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [Prescription] the created Precription instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      low_limit = 4
      high_limit = 13
      raise ArgumentError, "Invalid argument 'string': Expected at least #{low_limit} elements, got #{values.length}." if values.length < low_limit
      RTP.logger.warn "The number of elements (#{values.length}) for this Prescription record exceeds the known number of data items for this record (#{high_limit}). This may indicate an invalid record or that the RTP format has recently been expanded with new items." if values.length > high_limit
      p = self.new(parent)
      # Assign the values to attributes:
      p.keyword = values[0]
      p.course_id = values[1]
      p.rx_site_name = values[2]
      p.technique = values[3]
      p.modality = values[4]
      p.dose_spec = values[5]
      p.rx_depth = values[6]
      p.dose_ttl = values[7]
      p.dose_tx = values[8]
      p.pattern = values[9]
      p.rx_note = values[10]
      p.number_of_fields = values[11]
      p.crc = values[-1]
      return p
    end

    # Creates a new Prescription site.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      # Child objects:
      @site_setup = nil
      @fields = Array.new
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_prescription(self)
      @keyword = 'RX_DEF'
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
      if other.respond_to?(:to_prescription)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a treatment field record to this instance.
    #
    # @param [Field] child a Field instance which is to be associated with self
    #
    def add_field(child)
      @fields << child.to_field
    end

    # Adds a site setup record to this instance.
    #
    # @param [SiteSetup] child a SiteSetup instance which is to be associated with self
    #
    def add_site_setup(child)
      @site_setup = child.to_site_setup
    end

    # Collects the child records of this instance in a properly sorted array.
    #
    # @return [Array<SiteSetup, Field>] a sorted array of self's child records
    #
    def children
      return [@site_setup, @fields].flatten.compact
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
        @course_id,
        @rx_site_name,
        @technique,
        @modality,
        @dose_spec,
        @rx_depth,
        @dose_ttl,
        @dose_tx,
        @pattern,
        @rx_note,
        @number_of_fields
      ]
    end

    # Returns self.
    #
    # @return [Prescription] self
    #
    def to_prescription
      self
    end

    # Encodes the Prescription object + any hiearchy of child objects,
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
      raise ArgumentError, "Invalid keyword. Expected 'RX_DEF', got #{value}." unless value == "RX_DEF"
      @keyword = value
    end

    # Sets the course_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def course_id=(value)
      @course_id = value && value.to_s
    end

    # Sets the rx_site_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the technique attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def technique=(value)
      @technique = value && value.to_s
    end

    # Sets the modality attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def modality=(value)
      @modality = value && value.to_s
    end

    # Sets the dose_spec attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_spec=(value)
      @dose_spec = value && value.to_s
    end

    # Sets the rx_depth attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_depth=(value)
      @rx_depth = value && value.to_s
    end

    # Sets the dose_ttl attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_ttl=(value)
      @dose_ttl = value && value.to_s.strip
    end

    # Sets the dose_tx attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_tx=(value)
      @dose_tx = value && value.to_s.strip
    end

    # Sets the pattern attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def pattern=(value)
      @pattern = value && value.to_s
    end

    # Sets the rx_note attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_note=(value)
      @rx_note = value && value.to_s
    end

    # Sets the number_of_fields attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def number_of_fields=(value)
      @number_of_fields = value && value.to_s.strip
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