module RTP

  # The SiteSetup class.
  #
  # @note Relations:
  #   * Parent: Prescription
  #   * Children: none
  #
  class SiteSetup < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    attr_reader :rx_site_name
    attr_reader :patient_orientation
    attr_reader :treatment_machine
    attr_reader :tolerance_table
    attr_reader :iso_pos_x
    attr_reader :iso_pos_y
    attr_reader :iso_pos_z
    attr_reader :structure_set_uid
    attr_reader :frame_of_ref_uid
    attr_reader :couch_vertical
    attr_reader :couch_lateral
    attr_reader :couch_longitudinal
    attr_reader :couch_angle
    attr_reader :couch_pedestal

    # Creates a new SiteSetup by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the site setup definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [SiteSetup] the created SiteSetup instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 16 elements, got #{values.length}." unless values.length == 16
      s = self.new(parent)
      # Assign the values to attributes:
      s.keyword = values[0]
      s.rx_site_name = values[1]
      s.patient_orientation = values[2]
      s.treatment_machine = values[3]
      s.tolerance_table = values[4]
      s.iso_pos_x = values[5]
      s.iso_pos_y = values[6]
      s.iso_pos_z = values[7]
      s.structure_set_uid = values[8]
      s.frame_of_ref_uid = values[9]
      s.couch_vertical = values[10]
      s.couch_lateral = values[11]
      s.couch_longitudinal = values[12]
      s.couch_angle = values[13]
      s.couch_pedestal = values[14]
      s.crc = values[15]
      return s
    end

    # Creates a new SiteSetup.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      # Parent relation (always expecting a Prescription here):
      @parent = get_parent(parent.to_prescription, Prescription)
      @parent.add_site_setup(self)
      @keyword = 'SITE_SETUP_DEF'
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
      if other.respond_to?(:to_site_setup)
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
        @rx_site_name,
        @patient_orientation,
        @treatment_machine,
        @tolerance_table,
        @iso_pos_x,
        @iso_pos_y,
        @iso_pos_z,
        @structure_set_uid,
        @frame_of_ref_uid,
        @couch_vertical,
        @couch_lateral,
        @couch_longitudinal,
        @couch_angle,
        @couch_pedestal
      ]
    end

    # Encodes the SiteSetup object + any hiearchy of child objects,
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

    # Returns self.
    #
    # @return [SiteSetup] self
    #
    def to_site_setup
      self
    end

    # Sets the keyword attribute.
    #
    # @note Since only a specific string is accepted, this is more of an argument check than a traditional setter method
    # @param [#to_s] value the new attribute value
    # @raise [ArgumentError] if given an unexpected keyword
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'SITE_SETUP_DEF', got #{value}." unless value == "SITE_SETUP_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the patient_orientation attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def patient_orientation=(value)
      @patient_orientation = value && value.to_s
    end

    # Sets the treatment_machine attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def treatment_machine=(value)
      @treatment_machine = value && value.to_s
    end

    # Sets the tolerance_table attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def tolerance_table=(value)
      @tolerance_table = value && value.to_s.strip
    end

    # Sets the iso_pos_x attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def iso_pos_x=(value)
      @iso_pos_x = value && value.to_s.strip
    end

    # Sets the iso_pos_y attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def iso_pos_y=(value)
      @iso_pos_y = value && value.to_s.strip
    end

    # Sets the iso_pos_z attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def iso_pos_z=(value)
      @iso_pos_z = value && value.to_s.strip
    end

    # Sets the structure_set_uid attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def structure_set_uid=(value)
      @structure_set_uid = value && value.to_s
    end

    # Sets the frame_of_ref_uid attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def frame_of_ref_uid=(value)
      @frame_of_ref_uid = value && value.to_s
    end

    # Sets the couch_vertical attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_vertical=(value)
      @couch_vertical = value && value.to_s.strip
    end

    # Sets the couch_lateral attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_lateral=(value)
      @couch_lateral = value && value.to_s.strip
    end

    # Sets the couch_longitudinal attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_longitudinal=(value)
      @couch_longitudinal = value && value.to_s.strip
    end

    # Sets the couch_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_angle=(value)
      @couch_angle = value && value.to_s.strip
    end

    # Sets the couch_pedestal attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_pedestal=(value)
      @couch_pedestal = value && value.to_s.strip
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