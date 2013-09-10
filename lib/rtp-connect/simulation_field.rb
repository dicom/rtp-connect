module RTP

  # The simulation field class.
  #
  # @note Relations:
  #   * Parent: Prescription
  #   * Children: none
  #
  class SimulationField < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    attr_reader :rx_site_name
    attr_reader :field_name
    attr_reader :field_id
    attr_reader :field_note
    attr_reader :treatment_machine
    attr_reader :gantry_angle
    attr_reader :collimator_angle
    attr_reader :field_x_mode
    attr_reader :field_x
    attr_reader :collimator_x1
    attr_reader :collimator_x2
    attr_reader :field_y_mode
    attr_reader :field_y
    attr_reader :collimator_y1
    attr_reader :collimator_y2
    attr_reader :couch_vertical
    attr_reader :couch_lateral
    attr_reader :couch_longitudinal
    attr_reader :couch_angle
    attr_reader :couch_pedestal
    attr_reader :sad
    attr_reader :ap_separation
    attr_reader :pa_separation
    attr_reader :lateral_separation
    attr_reader :tangential_separation
    attr_reader :other_label_1
    attr_reader :ssd_1
    attr_reader :sfd_1
    attr_reader :other_label_2
    attr_reader :other_measurement_1
    attr_reader :other_measurement_2
    attr_reader :other_label_3
    attr_reader :other_measurement_3
    attr_reader :other_measurement_4
    attr_reader :other_label_4
    attr_reader :other_measurement_5
    attr_reader :other_measurement_6
    attr_reader :blade_x_mode
    attr_reader :blade_x
    attr_reader :blade_x1
    attr_reader :blade_x2
    attr_reader :blade_y_mode
    attr_reader :blade_y
    attr_reader :blade_y1
    attr_reader :blade_y2
    attr_reader :ii_lateral
    attr_reader :ii_longitudinal
    attr_reader :ii_vertical
    attr_reader :kvp
    attr_reader :ma
    attr_reader :seconds

    # Creates a new SimulationField by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the simulation field definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [Field] the created SimulationField instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      low_limit = 17
      high_limit = 53
      raise ArgumentError, "Invalid argument 'string': Expected at least #{low_limit} elements, got #{values.length}." if values.length < low_limit
      RTP.logger.warn "The number of elements (#{values.length}) for this Simulation Field record exceeds the known number of data items for this record (#{high_limit}). This may indicate an invalid record or that the RTP format has recently been expanded with new items." if values.length > high_limit
      sf = self.new(parent)
      # Assign the values to attributes:
      sf.keyword = values[0]
      sf.rx_site_name = values[1]
      sf.field_name = values[2]
      sf.field_id = values[3]
      sf.field_note = values[4]
      sf.treatment_machine = values[5]
      sf.gantry_angle = values[6]
      sf.collimator_angle = values[7]
      sf.field_x_mode = values[8]
      sf.field_x = values[9]
      sf.collimator_x1 = values[10]
      sf.collimator_x2 = values[11]
      sf.field_y_mode = values[12]
      sf.field_y = values[13]
      sf.collimator_y1 = values[14]
      sf.collimator_y2 = values[15]
      sf.couch_vertical = values[16]
      sf.couch_lateral = values[17]
      sf.couch_longitudinal = values[18]
      sf.couch_angle = values[19]
      sf.couch_pedestal = values[20]
      sf.sad = values[21]
      sf.ap_separation = values[22]
      sf.pa_separation = values[23]
      sf.lateral_separation = values[24]
      sf.tangential_separation = values[25]
      sf.other_label_1 = values[26]
      sf.ssd_1 = values[27]
      sf.sfd_1 = values[28]
      sf.other_label_2 = values[29]
      sf.other_measurement_1 = values[30]
      sf.other_measurement_2 = values[31]
      sf.other_label_3 = values[32]
      sf.other_measurement_3 = values[33]
      sf.other_measurement_4 = values[34]
      sf.other_label_4 = values[35]
      sf.other_measurement_5 = values[36]
      sf.other_measurement_6 = values[37]
      sf.blade_x_mode = values[38]
      sf.blade_x = values[39]
      sf.blade_x1 = values[40]
      sf.blade_x2 = values[41]
      sf.blade_y_mode = values[42]
      sf.blade_y = values[43]
      sf.blade_y1 = values[44]
      sf.blade_y2 = values[45]
      sf.ii_lateral = values[46]
      sf.ii_longitudinal = values[47]
      sf.ii_vertical = values[48]
      sf.kvp = values[49]
      sf.ma = values[50]
      sf.seconds = values[51]
      sf.crc = values[-1]
      return sf
    end

    # Creates a new SimulationField.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Prescription)
      @parent.add_simulation_field(self)
      @keyword = 'SIM_DEF'
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
      if other.respond_to?(:to_simulation_field)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Collects the child records of this instance in a properly sorted array.
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
        @field_name,
        @field_id,
        @field_note,
        @treatment_machine,
        @gantry_angle,
        @collimator_angle,
        @field_x_mode,
        @field_x,
        @collimator_x1,
        @collimator_x2,
        @field_y_mode,
        @field_y,
        @collimator_y1,
        @collimator_y2,
        @couch_vertical,
        @couch_lateral,
        @couch_longitudinal,
        @couch_angle,
        @couch_pedestal,
        @sad,
        @ap_separation,
        @pa_separation,
        @lateral_separation,
        @tangential_separation,
        @other_label_1,
        @ssd_1,
        @sfd_1,
        @other_label_2,
        @other_measurement_1,
        @other_measurement_2,
        @other_label_3,
        @other_measurement_3,
        @other_measurement_4,
        @other_label_4,
        @other_measurement_5,
        @other_measurement_6,
        @blade_x_mode,
        @blade_x,
        @blade_x1,
        @blade_x2,
        @blade_y_mode,
        @blade_y,
        @blade_y1,
        @blade_y2,
        @ii_lateral,
        @ii_longitudinal,
        @ii_vertical,
        @kvp,
        @ma,
        @seconds
      ]
    end

    # Returns self.
    #
    # @return [SimulationField] self
    #
    def to_simulation_field
      self
    end

    # Encodes the SimulationField object + any hiearchy of child objects,
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
      raise ArgumentError, "Invalid keyword. Expected 'SIM_DEF', got #{value}." unless value == "SIM_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the field_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_name=(value)
      @field_name = value && value.to_s
    end

    # Sets the field_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_id=(value)
      @field_id = value && value.to_s
    end

    # Sets the field_note attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_note=(value)
      @field_note = value && value.to_s
    end

    # Sets the treatment_machine attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def treatment_machine=(value)
      @treatment_machine = value && value.to_s
    end

    # Sets the gantry_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def gantry_angle=(value)
      @gantry_angle = value && value.to_s.strip
    end

    # Sets the collimator_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_angle=(value)
      @collimator_angle = value && value.to_s.strip
    end

    # Sets the field_x_mode attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_x_mode=(value)
      @field_x_mode = value && value.to_s
    end

    # Sets the field_x attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_x=(value)
      @field_x = value && value.to_s.strip
    end

    # Sets the collimator_x1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_x1=(value)
      @collimator_x1 = value && value.to_s.strip
    end

    # Sets the collimator_x2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_x2=(value)
      @collimator_x2 = value && value.to_s.strip
    end

    # Sets the field_y_mode attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_y_mode=(value)
      @field_y_mode = value && value.to_s
    end

    # Sets the field_y attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_y=(value)
      @field_y = value && value.to_s.strip
    end

    # Sets the collimator_y1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_y1=(value)
      @collimator_y1 = value && value.to_s.strip
    end

    # Sets the collimator_y2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_y2=(value)
      @collimator_y2 = value && value.to_s.strip
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
      @couch_angle = value && value.to_s.strip.strip
    end

    # Sets the couch_pedestal attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_pedestal=(value)
      @couch_pedestal = value && value.to_s.strip
    end

    # Sets the sad attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def sad=(value)
      @sad = value && value.to_s.strip
    end

    # Sets the ap_separation attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ap_separation=(value)
      @ap_separation = value && value.to_s
    end

    # Sets the pa_separation attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def pa_separation=(value)
      @pa_separation = value && value.to_s.strip
    end

    # Sets the lateral_separation attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def lateral_separation=(value)
      @lateral_separation = value && value.to_s.strip
    end

    # Sets the tangential_separation attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def tangential_separation=(value)
      @tangential_separation = value && value.to_s.strip
    end

    # Sets the other_label_1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_label_1=(value)
      @other_label_1 = value && value.to_s
    end

    # Sets the ssd_1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ssd_1=(value)
      @ssd_1 = value && value.to_s
    end

    # Sets the sfd_1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def sfd_1=(value)
      @sfd_1 = value && value.to_s
    end

    # Sets the other_label_2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_label_2=(value)
      @other_label_2 = value && value.to_s
    end

    # Sets the other_measurement_1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_1=(value)
      @other_measurement_1 = value && value.to_s
    end

    # Sets the other_measurement_2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_2=(value)
      @other_measurement_2 = value && value.to_s
    end

    # Sets the other_label_3 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_label_3=(value)
      @other_label_3 = value && value.to_s
    end

    # Sets the other_measurement_3 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_3=(value)
      @other_measurement_3 = value && value.to_s
    end

    # Sets the other_measurement_4 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_4=(value)
      @other_measurement_4 = value && value.to_s
    end

    # Sets the other_label_4 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_label_4=(value)
      @other_label_4 = value && value.to_s
    end

    # Sets the other_measurement_5 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_5=(value)
      @other_measurement_5 = value && value.to_s
    end

    # Sets the other_measurement_6 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def other_measurement_6=(value)
      @other_measurement_6 = value && value.to_s
    end

    # Sets the blade_x_mode attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_x_mode=(value)
      @blade_x_mode = value && value.to_s
    end

    # Sets the blade_x attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_x=(value)
      @blade_x = value && value.to_s
    end

    # Sets the blade_x1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_x1=(value)
      @blade_x1 = value && value.to_s
    end

    # Sets the blade_x2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_x2=(value)
      @blade_x2 = value && value.to_s
    end

    # Sets the blade_y_mode attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_y_mode=(value)
      @blade_y_mode = value && value.to_s
    end

    # Sets the blade_y attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_y=(value)
      @blade_y = value && value.to_s
    end

    # Sets the blade_y1 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_y1=(value)
      @blade_y1 = value && value.to_s
    end

    # Sets the blade_y2 attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def blade_y2=(value)
      @blade_y2 = value && value.to_s
    end

    # Sets the ii_lateral attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ii_lateral=(value)
      @ii_lateral = value && value.to_s
    end

    # Sets the ii_longitudinal attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ii_longitudinal=(value)
      @ii_longitudinal = value && value.to_s
    end

    # Sets the ii_vertical attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ii_vertical=(value)
      @ii_vertical = value && value.to_s
    end

    # Sets the kvp attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def kvp=(value)
      @kvp = value && value.to_s
    end

    # Sets the ma attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ma=(value)
      @ma = value && value.to_s
    end

    # Sets the seconds attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def seconds=(value)
      @seconds = value && value.to_s
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