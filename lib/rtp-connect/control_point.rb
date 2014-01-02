module RTP

  # The ControlPoint class.
  #
  # @note Relations:
  #   * Parent: Field
  #   * Children: none
  #
  class ControlPoint < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The MLC shape record (if any) that belongs to this ControlPoint.
    attr_reader :mlc_shape
    attr_reader :field_id
    attr_reader :mlc_type
    attr_reader :mlc_leaves
    attr_reader :total_control_points
    attr_reader :control_pt_number
    attr_reader :mu_convention
    attr_reader :monitor_units
    attr_reader :wedge_position
    attr_reader :energy
    attr_reader :doserate
    attr_reader :ssd
    attr_reader :scale_convention
    attr_reader :gantry_angle
    attr_reader :gantry_dir
    attr_reader :collimator_angle
    attr_reader :collimator_dir
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
    attr_reader :couch_dir
    attr_reader :couch_pedestal
    attr_reader :couch_ped_dir
    # Note: This attribute contains an array of all MLC LP A values (leaves 1..100).
    attr_reader :mlc_lp_a
    # Note: This attribute contains an array of all MLC LP B values (leaves 1..100).
    attr_reader :mlc_lp_b

    # Creates a new ControlPoint by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the control point definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [ControlPoint] the created ControlPoint instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      cp = self.new(parent)
      cp.load(string)
    end

    # Creates a new ControlPoint.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('CONTROL_PT_DEF', 233, 233)
      # Child:
      @mlc_shape = nil
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Field)
      @parent.add_control_point(self)
      @mlc_lp_a = Array.new(100)
      @mlc_lp_b = Array.new(100)
      @attributes = [
        # Required:
        :keyword,
        :field_id,
        :mlc_type,
        :mlc_leaves,
        :total_control_points,
        :control_pt_number,
        :mu_convention,
        :monitor_units,
        :wedge_position,
        :energy,
        :doserate,
        :ssd,
        :scale_convention,
        :gantry_angle,
        :gantry_dir,
        :collimator_angle,
        :collimator_dir,
        :field_x_mode,
        :field_x,
        :collimator_x1,
        :collimator_x2,
        :field_y_mode,
        :field_y,
        :collimator_y1,
        :collimator_y2,
        :couch_vertical,
        :couch_lateral,
        :couch_longitudinal,
        :couch_angle,
        :couch_dir,
        :couch_pedestal,
        :couch_ped_dir,
        :mlc_lp_a,
        :mlc_lp_b
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
      if other.respond_to?(:to_control_point)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # As of now, gives an empty array. However, by definition, this record may
    # have an mlc shape record as child, but this is not implemented yet.
    #
    # @return [Array] an emtpy array
    #
    def children
      #return [@mlc_shape]
      return Array.new
    end

    # Converts the collimator_x1 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_x1 attribute
    #
    def dcm_collimator_x1
      # Deal with scale convertion:
      axis = (scale_convertion? ? :y : :x)
      dcm_collimator1(axis)
    end

    # Converts the collimator_x2 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_x2 attribute
    #
    def dcm_collimator_x2
      axis = (scale_convertion? ? :y : :x)
      dcm_collimator2(axis)
    end

    # Converts the collimator_y1 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_y1 attribute
    #
    def dcm_collimator_y1
      # Deal with scale convertion:
      axis = (scale_convertion? ? :x : :y)
      dcm_collimator1(axis)
    end

    # Converts the collimator_y2 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_y2 attribute
    #
    def dcm_collimator_y2
      axis = (scale_convertion? ? :x : :y)
      dcm_collimator2(axis)
    end

    # Converts the mlc_lp_a & mlc_lp_b attributes to a proper DICOM formatted string.
    #
    # @return [String] the DICOM-formatted leaf pair positions
    #
    def dcm_mlc_positions
      # As with the collimators, the first side (1/a) may need scale invertion:
      pos_a = @mlc_lp_a.collect{|p| (p.to_f * 10 * scale_factor).round(1) unless p.empty?}.compact
      pos_b = @mlc_lp_b.collect{|p| (p.to_f * 10).round(1) unless p.empty?}.compact
      (pos_a + pos_b).join("\\")
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

    # Gives the index of this ControlPoint
    # (i.e. its index among the control points belonging to the parent Field).
    #
    # @return [Fixnum] the control point's index
    #
    def index
      @parent.control_points.index(self)
    end

    # Collects the values (attributes) of this instance.
    #
    # @note The CRC is not considered part of the actual values and is excluded.
    # @return [Array<String>] an array of attributes (in the same order as they appear in the RTP string)
    #
    def values
      [
        @keyword,
        @field_id,
        @mlc_type,
        @mlc_leaves,
        @total_control_points,
        @control_pt_number,
        @mu_convention,
        @monitor_units,
        @wedge_position,
        @energy,
        @doserate,
        @ssd,
        @scale_convention,
        @gantry_angle,
        @gantry_dir,
        @collimator_angle,
        @collimator_dir,
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
        @couch_dir,
        @couch_pedestal,
        @couch_ped_dir,
        *@mlc_lp_a,
        *@mlc_lp_b
      ]
    end

    # Returns self.
    #
    # @return [ControlPoint] self
    #
    def to_control_point
      self
    end

    # Encodes the ControlPoint object + any hiearchy of child objects,
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

    # Sets the mlc_lp_a attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 100 MLC leaf 'A' string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def mlc_lp_a=(array)
      array = array.to_a
      raise ArgumentError, "Invalid argument 'array'. Expected length 100, got #{array.length}." unless array.length == 100
      @mlc_lp_a = array.collect! {|e| e && e.to_s.strip}
    end

    # Sets the mlc_lp_b attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 100 MLC leaf 'B' string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def mlc_lp_b=(array)
      array = array.to_a
      raise ArgumentError, "Invalid argument 'array'. Expected length 100, got #{array.length}." unless array.length == 100
      @mlc_lp_b = array.collect! {|e| e && e.to_s.strip}
    end

    # Sets the field_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_id=(value)
      @field_id = value && value.to_s
    end

    # Sets the mlc_type attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def mlc_type=(value)
      @mlc_type = value && value.to_s
    end

    # Sets the mlc_leaves attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def mlc_leaves=(value)
      @mlc_leaves = value && value.to_s.strip
    end

    # Sets the total_control_points attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def total_control_points=(value)
      @total_control_points = value && value.to_s.strip
    end

    # Sets the control_pt_number attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def control_pt_number=(value)
      @control_pt_number = value && value.to_s.strip
    end

    # Sets the mu_convention attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def mu_convention=(value)
      @mu_convention = value && value.to_s
    end

    # Sets the monitor_units attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def monitor_units=(value)
      @monitor_units = value && value.to_s
    end

    # Sets the wedge_position attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def wedge_position=(value)
      @wedge_position = value && value.to_s
    end

    # Sets the energy attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def energy=(value)
      @energy = value && value.to_s
    end

    # Sets the doserate attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def doserate=(value)
      @doserate = value && value.to_s.strip
    end

    # Sets the ssd attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ssd=(value)
      @ssd = value && value.to_s
    end

    # Sets the scale_convention attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def scale_convention=(value)
      @scale_convention = value && value.to_s
    end

    # Sets the gantry_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def gantry_angle=(value)
      @gantry_angle = value && value.to_s.strip
    end

    # Sets the gantry_dir attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def gantry_dir=(value)
      @gantry_dir = value && value.to_s
    end

    # Sets the collimator_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_angle=(value)
      @collimator_angle = value && value.to_s.strip
    end

    # Sets the collimator_dir attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def collimator_dir=(value)
      @collimator_dir = value && value.to_s
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
      @couch_angle = value && value.to_s.strip
    end

    # Sets the couch_dir attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_dir=(value)
      @couch_dir = value && value.to_s
    end

    # Sets the couch_pedestal attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_pedestal=(value)
      @couch_pedestal = value && value.to_s.strip
    end

    # Sets the couch_ped_dir attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def couch_ped_dir=(value)
      @couch_ped_dir = value && value.to_s
    end


    private


    # Collects the attributes of this instance.
    #
    # @note The CRC is not considered part of the attributes of interest and is excluded
    # @return [Array<String>] an array of attributes
    #
    alias_method :state, :values

    # Converts the collimator attribute to proper DICOM format.
    #
    # @param [Symbol] axis a representation for the axis of interest (x or y)
    # @return [Float] the DICOM-formatted collimator attribute
    #
    def dcm_collimator1(axis)
      mode = self.send("field_#{axis}_mode")
      if mode && !mode.empty?
        value = self.send("collimator_#{axis}1").to_f * 10
        if mode.upcase == 'SYM' && value > 0
          -value
        else
          value
        end
      else
        value = @parent.send(:dcm_collimator1, axis)
      end
    end

    # Converts the collimator attribute to proper DICOM format.
    #
    # @param [Symbol] axis a representation for the axis of interest (x or y)
    # @return [Float] the DICOM-formatted collimator attribute
    #
    def dcm_collimator2(axis)
      mode = self.send("field_#{axis}_mode")
      if mode && !mode.empty?
        target = self
      else
        target = @parent
      end
      target.send("collimator_#{axis}2").to_f * 10
    end

    # Checks whether the contents of the this record indicates that scale
    # convertion is to be applied. This convertion entails converting a value
    # from IEC1217 format to the target machine's native readout format.
    # Note that the scope of this scale conversion is not precisely known (the
    # current implementation is based on a few observations made from a single
    # RTP file).
    #
    # @return [Boolean] true if the scale convention attribute indicates scale convertion
    #
    def scale_convertion?
      # A scale convention of 1 means that geometric parameters are represented
      # in the target machine's native readout format, as opposed to the IEC 1217
      # convention. The consequences of this is not totally clear, but at least for
      # an Elekta device, there are a number of convertions which seems to be indicated.
      @scale_convention.to_i == 1 ? true : false
    end

    # Gives a factor used for scale convertion, which depends on the
    # 'scale_convention' attribute.
    #
    # @param [Numerical] value the value to process
    # @return [Numerical] the scale converted value
    #
    def scale_factor
      # It should be noted that this scale factor is not satisfactory mapped.
      # Perhaps its support should even be removed until it is sufficiently specced?
      scale_convertion? ? -1 : 1
    end

    # Sets the attributes of the record instance.
    #
    # @param [Array<String>] values the record attributes (as parsed from a record string)
    #
    def set_attributes(values)
      self.keyword = values[0]
      @field_id = values[1]
      @mlc_type = values[2]
      @mlc_leaves = values[3]
      @total_control_points = values[4]
      @control_pt_number = values[5]
      @mu_convention = values[6]
      @monitor_units = values[7]
      @wedge_position = values[8]
      @energy = values[9]
      @doserate = values[10]
      @ssd = values[11]
      @scale_convention = values[12]
      @gantry_angle = values[13]
      @gantry_dir = values[14]
      @collimator_angle = values[15]
      @collimator_dir = values[16]
      @field_x_mode = values[17]
      @field_x = values[18]
      @collimator_x1 = values[19]
      @collimator_x2 = values[20]
      @field_y_mode = values[21]
      @field_y = values[22]
      @collimator_y1 = values[23]
      @collimator_y2 = values[24]
      @couch_vertical = values[25]
      @couch_lateral = values[26]
      @couch_longitudinal = values[27]
      @couch_angle = values[28]
      @couch_dir = values[29]
      @couch_pedestal = values[30]
      @couch_ped_dir = values[31]
      @mlc_lp_a = [*values[32..131]]
      @mlc_lp_b = [*values[132..231]]
      @crc = values[-1]
    end

  end

end