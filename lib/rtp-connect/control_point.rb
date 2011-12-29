module RTP

  # The ControlPoint class.
  #
  # === Relations
  #
  # * Parent: Field
  # * Children: MLCShape
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
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a control point record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Get the quote-less values:
      values = string.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 233 elements, got #{values.length}." unless values.length == 233
      f = self.new(parent)
      # Assign the values to attributes:
      f.keyword = values[0]
      f.field_id = values[1]
      f.mlc_type = values[2]
      f.mlc_leaves = values[3]
      f.total_control_points = values[4]
      f.control_pt_number = values[5]
      f.mu_convention = values[6]
      f.monitor_units = values[7]
      f.wedge_position = values[8]
      f.energy = values[9]
      f.doserate = values[10]
      f.ssd = values[11]
      f.scale_convention = values[12]
      f.gantry_angle = values[13]
      f.gantry_dir = values[14]
      f.collimator_angle = values[15]
      f.collimator_dir = values[16]
      f.field_x_mode = values[17]
      f.field_x = values[18]
      f.collimator_x1 = values[19]
      f.collimator_x2 = values[20]
      f.field_y_mode = values[21]
      f.field_y = values[22]
      f.collimator_y1 = values[23]
      f.collimator_y2 = values[24]
      f.couch_vertical = values[25]
      f.couch_lateral = values[26]
      f.couch_longitudinal = values[27]
      f.couch_angle = values[28]
      f.couch_dir = values[29]
      f.couch_pedestal = values[30]
      f.couch_ped_dir = values[31]
      f.mlc_lp_a = [*values[32..131]]
      f.mlc_lp_b = [*values[132..231]]
      f.crc = values[232]
      return f
    end

    # Creates a new ControlPoint.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Child:
      @mlc_shape = nil
      # Parent relation:
      @parent = get_parent(parent, Field)
      @parent.add_control_point(self)
      @keyword = 'CONTROL_PT_DEF'
      @mlc_lp_a = Array.new(100)
      @mlc_lp_b = Array.new(100)
    end

    # As of now, returns an empty array.
    # However, by definition, this record may have an mlc shape record as child,
    # but this is not implemented yet.
    #
    def children
      #return [@mlc_shape]
      return Array.new
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
    #
    def values
      return [
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

    # Writes the ControlPoint object + any hiearchy of child objects,
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

    # Sets the mlc_a attribute.
    #
    # === Notes
    #
    # As opposed to the ordinary (string) attributes, this attribute
    # contains an array holding all 100 MLC leaf 'A' string values.
    #
    def mlc_lp_a=(array)
      raise ArgumentError, "Invalid argument 'array'. Expected Array, got #{array.class}." unless array.is_a?(Array)
      raise ArgumentError, "Invalid argument 'array'. Expected array with length 100, got #{array.length}." unless array.length == 100
      unexpected_types = array.collect{|i| i.class}.uniq - [String, NilClass]
      raise ArgumentError, "Invalid argument 'array'. Array must contain only string or nil values, got unexpected class #{unexpected_types}." if unexpected_types.length > 0
      @mlc_lp_a = array
    end

    # Sets the mlc_b attribute.
    #
    # === Notes
    #
    # As opposed to the ordinary (string) attributes, this attribute
    # contains an array holding all 100 MLC leaf 'A' string values.
    #
    def mlc_lp_b=(array)
      raise ArgumentError, "Invalid argument 'array'. Expected Array, got #{array.class}." unless array.is_a?(Array)
      raise ArgumentError, "Invalid argument 'array'. Expected array with length 100, got #{array.length}." unless array.length == 100
      unexpected_types = array.collect{|i| i.class}.uniq - [String, NilClass]
      raise ArgumentError, "Invalid argument 'array'. Array must contain only string or nil values, got unexpected class #{unexpected_types}." if unexpected_types.length > 0
      @mlc_lp_b = array
    end

    # Sets the keyword attribute.
    #
    def keyword=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      raise ArgumentError, "Invalid keyword. Expected 'CONTROL_PT_DEF', got #{value}." unless value.upcase == "CONTROL_PT_DEF"
      @keyword = value
    end

    # Sets the field_id attribute.
    #
    def field_id=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_id = value
    end

    # Sets the mlc_type attribute.
    #
    def mlc_type=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @mlc_type = value
    end

    # Sets the mlc_leaves attribute.
    #
    def mlc_leaves=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @mlc_leaves = value
    end

    # Sets the total_control_points attribute.
    #
    def total_control_points=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @total_control_points = value
    end

    # Sets the control_pt_number attribute.
    #
    def control_pt_number=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @control_pt_number = value
    end

    # Sets the mu_convention attribute.
    #
    def mu_convention=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @mu_convention = value
    end

    # Sets the monitor_units attribute.
    #
    def monitor_units=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @monitor_units = value
    end

    # Sets the wedge_position attribute.
    #
    def wedge_position=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @wedge_position = value
    end

    # Sets the energy attribute.
    #
    def energy=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @energy = value
    end

    # Sets the doserate attribute.
    #
    def doserate=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @doserate = value
    end

    # Sets the ssd attribute.
    #
    def ssd=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @ssd = value
    end

    # Sets the scale_convention attribute.
    #
    def scale_convention=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @scale_convention = value
    end

    # Sets the gantry_angle attribute.
    #
    def gantry_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @gantry_angle = value
    end

    # Sets the gantry_dir attribute.
    #
    def gantry_dir=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @gantry_dir = value
    end

    # Sets the collimator_angle attribute.
    #
    def collimator_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_angle = value
    end

    # Sets the collimator_dir attribute.
    #
    def collimator_dir=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_dir = value
    end

    # Sets the field_x_mode attribute.
    #
    def field_x_mode=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_x_mode = value
    end

    # Sets the field_x attribute.
    #
    def field_x=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_x = value
    end

    # Sets the collimator_x1 attribute.
    #
    def collimator_x1=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_x1 = value
    end

    # Sets the collimator_x2 attribute.
    #
    def collimator_x2=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_x2 = value
    end

    # Sets the field_y_mode attribute.
    #
    def field_y_mode=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_y_mode = value
    end

    # Sets the field_y attribute.
    #
    def field_y=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_y = value
    end

    # Sets the collimator_y1 attribute.
    #
    def collimator_y1=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_y1 = value
    end

    # Sets the collimator_y2 attribute.
    #
    def collimator_y2=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_y2 = value
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

    # Sets the couch_dir attribute.
    #
    def couch_dir=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_dir = value
    end

    # Sets the couch_pedestal attribute.
    #
    def couch_pedestal=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_pedestal = value
    end

    # Sets the couch_ped_dir attribute.
    #
    def couch_ped_dir=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_ped_dir = value
    end

  end

end