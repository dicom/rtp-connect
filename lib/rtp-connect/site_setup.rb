module RTP

  # The SiteSetup class.
  #
  # === Relations
  #
  # * Parent: Prescription
  # * Children: none
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

    # Creates a new SiteSetup setup by parsing a RTPConnect string line.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a site setup record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
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
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      # Parent relation (always expecting a Prescription here):
      @parent = get_parent(parent.to_prescription, Prescription)
      @parent.add_site_setup(self)
      @keyword = 'SITE_SETUP_DEF'
    end

    # Returns true if the argument is an instance with attributes equal to self.
    #
    def ==(other)
      if other.respond_to?(:to_site_setup)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Returns an empty array, as these instances are child-less by definition.
    #
    def children
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

    # Writes the SiteSetup object + any hiearchy of child objects,
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

    # Returns self.
    #
    def to_site_setup
      self
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'SITE_SETUP_DEF', got #{value}." unless value == "SITE_SETUP_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the patient_orientation attribute.
    #
    def patient_orientation=(value)
      @patient_orientation = value && value.to_s
    end

    # Sets the treatment_machine attribute.
    #
    def treatment_machine=(value)
      @treatment_machine = value && value.to_s
    end

    # Sets the tolerance_table attribute.
    #
    def tolerance_table=(value)
      @tolerance_table = value && value.to_s
    end

    # Sets the iso_pos_x attribute.
    #
    def iso_pos_x=(value)
      @iso_pos_x = value && value.to_s
    end

    # Sets the iso_pos_y attribute.
    #
    def iso_pos_y=(value)
      @iso_pos_y = value && value.to_s
    end

    # Sets the iso_pos_z attribute.
    #
    def iso_pos_z=(value)
      @iso_pos_z = value && value.to_s
    end

    # Sets the structure_set_uid attribute.
    #
    def structure_set_uid=(value)
      @structure_set_uid = value && value.to_s
    end

    # Sets the frame_of_ref_uid attribute.
    #
    def frame_of_ref_uid=(value)
      @frame_of_ref_uid = value && value.to_s
    end

    # Sets the couch_vertical attribute.
    #
    def couch_vertical=(value)
      @couch_vertical = value && value.to_s
    end

    # Sets the couch_lateral attribute.
    #
    def couch_lateral=(value)
      @couch_lateral = value && value.to_s
    end

    # Sets the couch_longitudinal attribute.
    #
    def couch_longitudinal=(value)
      @couch_longitudinal = value && value.to_s
    end

    # Sets the couch_angle attribute.
    #
    def couch_angle=(value)
      @couch_angle = value && value.to_s
    end

    # Sets the couch_pedestal attribute.
    #
    def couch_pedestal=(value)
      @couch_pedestal = value && value.to_s
    end


    private


    # Returns the attributes of this instance in an array (for comparison purposes).
    #
    alias_method :state, :values

  end

end