module RTP

  # The treatment Field class.
  #
  # === Relations
  #
  # * Parent: Prescription
  # * Children: ExtendedField, ControlPoint
  #
  class Field < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The ExtendedField record (if any) that belongs to this Field.
    attr_reader :extended_field
    # An array of ControlPoint records (if any) that belongs to this Field.
    attr_reader :control_points
    attr_reader :rx_site_name
    attr_reader :field_name
    attr_reader :field_id
    attr_reader :field_note
    attr_reader :field_dose
    attr_reader :field_monitor_units
    attr_reader :wedge_monitor_units
    attr_reader :treatment_machine
    attr_reader :treatment_type
    attr_reader :modality
    attr_reader :energy
    attr_reader :time
    attr_reader :doserate
    attr_reader :sad
    attr_reader :ssd
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
    attr_reader :tolerance_table
    attr_reader :arc_direction
    attr_reader :arc_start_angle
    attr_reader :arc_stop_angle
    attr_reader :arc_mu_degree
    attr_reader :wedge
    attr_reader :dynamic_wedge
    attr_reader :block
    attr_reader :compensator
    attr_reader :e_applicator
    attr_reader :e_field_def_aperture
    attr_reader :bolus
    attr_reader :portfilm_mu_open
    attr_reader :portfilm_coeff_open
    attr_reader :portfilm_delta_open
    attr_reader :portfilm_mu_treat
    attr_reader :portfilm_coeff_treat

    # Creates a new (treatment) Field by parsing a RTPConnect string line.
    #
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a treatment field record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      raise ArgumentError, "Invalid argument 'string'. Expected String, got #{string.class}." unless string.is_a?(String)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Get the quote-less values:
      values = string.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 49 elements, got #{values.length}." unless values.length == 49
      f = self.new(parent)
      # Assign the values to attributes:
      f.keyword = values[0]
      f.rx_site_name = values[1]
      f.field_name = values[2]
      f.field_id = values[3]
      f.field_note = values[4]
      f.field_dose = values[5]
      f.field_monitor_units = values[6]
      f.wedge_monitor_units = values[7]
      f.treatment_machine = values[8]
      f.treatment_type = values[9]
      f.modality = values[10]
      f.energy = values[11]
      f.time = values[12]
      f.doserate = values[13]
      f.sad = values[14]
      f.ssd = values[15]
      f.gantry_angle = values[16]
      f.collimator_angle = values[17]
      f.field_x_mode = values[18]
      f.field_x = values[19]
      f.collimator_x1 = values[20]
      f.collimator_x2 = values[21]
      f.field_y_mode = values[22]
      f.field_y = values[23]
      f.collimator_y1 = values[24]
      f.collimator_y2 = values[25]
      f.couch_vertical = values[26]
      f.couch_lateral = values[27]
      f.couch_longitudinal = values[28]
      f.couch_angle = values[29]
      f.couch_pedestal = values[30]
      f.tolerance_table = values[31]
      f.arc_direction = values[32]
      f.arc_start_angle = values[33]
      f.arc_stop_angle = values[34]
      f.arc_mu_degree = values[35]
      f.wedge = values[36]
      f.dynamic_wedge = values[37]
      f.block = values[38]
      f.compensator = values[39]
      f.e_applicator = values[40]
      f.e_field_def_aperture = values[41]
      f.bolus = values[42]
      f.portfilm_mu_open = values[43]
      f.portfilm_coeff_open = values[44]
      f.portfilm_delta_open = values[45]
      f.portfilm_mu_treat = values[46]
      f.portfilm_coeff_treat = values[47]
      f.crc = values[48]
      return f
    end

    # Creates a new (treatment) Field.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      raise ArgumentError, "Invalid argument 'parent'. Expected RTP::Record, got #{parent.class}." unless parent.is_a?(RTP::Record)
      # Child records:
      @control_points = Array.new
      @extended_field = nil
      # Parent relation:
      @parent = get_parent(parent, Prescription)
      @parent.add_field(self)
      @keyword = 'FIELD_DEF'
    end

    # Adds a control point record to this instance.
    #
    def add_control_point(child)
      raise ArgumentError, "Invalid argument 'child'. Expected RTP::ControlPoint, got #{child.class}." unless child.is_a?(RTP::ControlPoint)
      @control_points << child
    end

    # Connects an extended treatment field record to this instance.
    #
    def add_extended_field(child)
      raise ArgumentError, "Invalid argument 'child'. Expected RTP::ExtendedField, got #{child.class}." unless child.is_a?(RTP::ExtendedField)
      @extended_field = child
    end

    # Returns nil, as these instances are child-less by definition.
    #
    def children
      return [@extended_field, @control_points].flatten.compact
    end

    # Returns the values of this instance in an array.
    # The values does not include the CRC.
    #
    def values
      return [
        @keyword,
        @rx_site_name,
        @field_name,
        @field_id,
        @field_note,
        @field_dose,
        @field_monitor_units,
        @wedge_monitor_units,
        @treatment_machine,
        @treatment_type,
        @modality,
        @energy,
        @time,
        @doserate,
        @sad,
        @ssd,
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
        @tolerance_table,
        @arc_direction,
        @arc_start_angle,
        @arc_stop_angle,
        @arc_mu_degree,
        @wedge,
        @dynamic_wedge,
        @block,
        @compensator,
        @e_applicator,
        @e_field_def_aperture,
        @bolus,
        @portfilm_mu_open,
        @portfilm_coeff_open,
        @portfilm_delta_open,
        @portfilm_mu_treat,
        @portfilm_coeff_treat
      ]
    end

    # Writes the Field object + any hiearchy of child objects,
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
      raise ArgumentError, "Invalid keyword. Expected 'FIELD_DEF', got #{value}." unless value.upcase == "FIELD_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @rx_site_name = value
    end

    # Sets the field_name attribute.
    #
    def field_name=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_name = value
    end

    # Sets the field_id attribute.
    #
    def field_id=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_id = value
    end

    # Sets the field_note attribute.
    #
    def field_note=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_note = value
    end

    # Sets the field_dose attribute.
    #
    def field_dose=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_dose = value
    end

    # Sets the field_monitor_units attribute.
    #
    def field_monitor_units=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @field_monitor_units = value
    end

    # Sets the wedge_monitor_units attribute.
    #
    def wedge_monitor_units=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @wedge_monitor_units = value
    end

    # Sets the treatment_machine attribute.
    #
    def treatment_machine=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @treatment_machine = value
    end

    # Sets the treatment_type attribute.
    #
    def treatment_type=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @treatment_type = value
    end

    # Sets the modality attribute.
    #
    def modality=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @modality = value
    end

    # Sets the energy attribute.
    #
    def energy=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @energy = value
    end

    # Sets the time attribute.
    #
    def time=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @time = value
    end

    # Sets the doserate attribute.
    #
    def doserate=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @doserate = value
    end

    # Sets the sad attribute.
    #
    def sad=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @sad = value
    end

    # Sets the ssd attribute.
    #
    def ssd=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @ssd = value
    end

    # Sets the gantry_angle attribute.
    #
    def gantry_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @gantry_angle = value
    end

    # Sets the collimator_angle attribute.
    #
    def collimator_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @collimator_angle = value
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

    # Sets the couch_pedestal attribute.
    #
    def couch_pedestal=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @couch_pedestal = value
    end

    # Sets the tolerance_table attribute.
    #
    def tolerance_table=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @tolerance_table = value
    end

    # Sets the arc_direction attribute.
    #
    def arc_direction=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @arc_direction = value
    end

    # Sets the arc_start_angle attribute.
    #
    def arc_start_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @arc_start_angle = value
    end

    # Sets the arc_stop_angle attribute.
    #
    def arc_stop_angle=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @arc_stop_angle = value
    end

    # Sets the arc_mu_degree attribute.
    #
    def arc_mu_degree=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @arc_mu_degree = value
    end

    # Sets the wedge attribute.
    #
    def wedge=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @wedge = value
    end

    # Sets the dynamic_wedge attribute.
    #
    def dynamic_wedge=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @dynamic_wedge = value
    end

    # Sets the block attribute.
    #
    def block=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @block = value
    end

    # Sets the compensator attribute.
    #
    def compensator=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @compensator = value
    end

    # Sets the e_applicator attribute.
    #
    def e_applicator=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @e_applicator = value
    end

    # Sets the e_field_def_aperture attribute.
    #
    def e_field_def_aperture=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @e_field_def_aperture = value
    end

    # Sets the bolus attribute.
    #
    def bolus=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @bolus = value
    end

    # Sets the portfilm_mu_open attribute.
    #
    def portfilm_mu_open=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @portfilm_mu_open = value
    end

    # Sets the portfilm_coeff_open attribute.
    #
    def portfilm_coeff_open=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @portfilm_coeff_open = value
    end

    # Sets the portfilm_delta_open attribute.
    #
    def portfilm_delta_open=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @portfilm_delta_open = value
    end

    # Sets the portfilm_mu_treat attribute.
    #
    def portfilm_mu_treat=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @portfilm_mu_treat = value
    end

    # Sets the portfilm_coeff_treat attribute.
    #
    def portfilm_coeff_treat=(value)
      raise ArgumentError, "Invalid argument 'value'. Expected String, got #{value.class}." unless value.is_a?(String)
      @portfilm_coeff_treat = value
    end

  end

end