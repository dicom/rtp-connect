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
    attr_reader :table_top_vert_displacement
    attr_reader :table_top_long_displacement
    attr_reader :table_top_lat_displacement

    # Creates a new SiteSetup by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the site setup definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [SiteSetup] the created SiteSetup instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      s = self.new(parent)
      s.load(string)
    end

    # Creates a new SiteSetup.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('SITE_SETUP_DEF', 5, 16)
      # Parent relation (always expecting a Prescription here):
      @parent = get_parent(parent.to_prescription, Prescription)
      @parent.add_site_setup(self)
      @attributes = [
        # Required:
        :keyword,
        :rx_site_name,
        :patient_orientation,
        :treatment_machine,
        # Optional:
        :tolerance_table,
        :iso_pos_x,
        :iso_pos_y,
        :iso_pos_z,
        :structure_set_uid,
        :frame_of_ref_uid,
        :couch_vertical,
        :couch_lateral,
        :couch_longitudinal,
        :couch_angle,
        :couch_pedestal,
        :table_top_vert_displacement,
        :table_top_long_displacement,
        :table_top_lat_displacement
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

    # Sets the table_top_vert_displacement attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def table_top_vert_displacement=(value)
      @table_top_vert_displacement = value && value.to_s.strip
    end

    # Sets the table_top_long_displacement attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def table_top_long_displacement=(value)
      @table_top_long_displacement = value && value.to_s.strip
    end

    # Sets the table_top_lat_displacement attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def table_top_lat_displacement=(value)
      @table_top_lat_displacement = value && value.to_s.strip
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