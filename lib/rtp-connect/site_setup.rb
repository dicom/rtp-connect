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
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Prescription, got #{parent.class}." unless parent.is_a?(RTP::Prescription)
      # Get the quote-less values:
      values = string.values
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
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Prescription, got #{parent.class}." unless parent.is_a?(RTP::Prescription)
      # Parent relation:
      @parent = get_parent(parent, Prescription)
      @parent.add_site_setup(self)
      @keyword = 'SITE_SETUP_DEF'
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
    def to_str
      str = encode
      if children
        children.each do |child|
          str += child.to_str
        end
      end
      return str
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      raise ArgumentError, "Invalid keyword. Expected 'SITE_SETUP_DEF', got #{value}." unless value.upcase == "SITE_SETUP_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @rx_site_name = value
    end

    # Sets the patient_orientation attribute.
    #
    def patient_orientation=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @patient_orientation = value
    end

    # Sets the treatment_machine attribute.
    #
    def treatment_machine=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @treatment_machine = value
    end

    # Sets the tolerance_table attribute.
    #
    def tolerance_table=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @tolerance_table = value
    end

    # Sets the iso_pos_x attribute.
    #
    def iso_pos_x=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @iso_pos_x = value
    end

    # Sets the iso_pos_y attribute.
    #
    def iso_pos_y=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @iso_pos_y = value
    end

    # Sets the iso_pos_z attribute.
    #
    def iso_pos_z=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @iso_pos_z = value
    end

    # Sets the structure_set_uid attribute.
    #
    def structure_set_uid=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @structure_set_uid = value
    end

    # Sets the frame_of_ref_uid attribute.
    #
    def frame_of_ref_uid=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @frame_of_ref_uid = value
    end

    # Sets the couch_vertical attribute.
    #
    def couch_vertical=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_vertical = value
    end

    # Sets the couch_lateral attribute.
    #
    def couch_lateral=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_lateral = value
    end

    # Sets the couch_longitudinal attribute.
    #
    def couch_longitudinal=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_longitudinal = value
    end

    # Sets the couch_angle attribute.
    #
    def couch_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_angle = value
    end

    # Sets the couch_pedestal attribute.
    #
    def couch_pedestal=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_pedestal = value
    end

  end

end