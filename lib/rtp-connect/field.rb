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
      # Get the quote-less values:
      values = string.to_s.values
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
      # Child records:
      @control_points = Array.new
      @extended_field = nil
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Prescription)
      @parent.add_field(self)
      @keyword = 'FIELD_DEF'
    end

    # Returns true if the argument is an instance with attributes equal to self.
    #
    def ==(other)
      if other.respond_to?(:to_field)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a control point record to this instance.
    #
    def add_control_point(child)
      @control_points << child.to_control_point
    end

    # Connects an extended treatment field record to this instance.
    #
    def add_extended_field(child)
      @extended_field = child.to_extended_field
    end

    # Returns nil, as these instances are child-less by definition.
    #
    def children
      return [@extended_field, @control_points].flatten.compact
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

    # Returns self.
    #
    def to_field
      self
    end

    # Writes the Field object + any hiearchy of child objects,
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

    # Sets the keyword attribute.
    #
    def keyword=(value)
      value = value.to_s.upcase
      raise ArgumentError, "Invalid keyword. Expected 'FIELD_DEF', got #{value}." unless value == "FIELD_DEF"
      @keyword = value
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the field_name attribute.
    #
    def field_name=(value)
      @field_name = value && value.to_s
    end

    # Sets the field_id attribute.
    #
    def field_id=(value)
      @field_id = value && value.to_s
    end

    # Sets the field_note attribute.
    #
    def field_note=(value)
      @field_note = value && value.to_s
    end

    # Sets the field_dose attribute.
    #
    def field_dose=(value)
      @field_dose = value && value.to_s
    end

    # Sets the field_monitor_units attribute.
    #
    def field_monitor_units=(value)
      @field_monitor_units = value && value.to_s
    end

    # Sets the wedge_monitor_units attribute.
    #
    def wedge_monitor_units=(value)
      @wedge_monitor_units = value && value.to_s
    end

    # Sets the treatment_machine attribute.
    #
    def treatment_machine=(value)
      @treatment_machine = value && value.to_s
    end

    # Sets the treatment_type attribute.
    #
    def treatment_type=(value)
      @treatment_type = value && value.to_s
    end

    # Sets the modality attribute.
    #
    def modality=(value)
      @modality = value && value.to_s
    end

    # Sets the energy attribute.
    #
    def energy=(value)
      @energy = value && value.to_s
    end

    # Sets the time attribute.
    #
    def time=(value)
      @time = value && value.to_s
    end

    # Sets the doserate attribute.
    #
    def doserate=(value)
      @doserate = value && value.to_s
    end

    # Sets the sad attribute.
    #
    def sad=(value)
      @sad = value && value.to_s
    end

    # Sets the ssd attribute.
    #
    def ssd=(value)
      @ssd = value && value.to_s
    end

    # Sets the gantry_angle attribute.
    #
    def gantry_angle=(value)
      @gantry_angle = value && value.to_s
    end

    # Sets the collimator_angle attribute.
    #
    def collimator_angle=(value)
      @collimator_angle = value && value.to_s
    end

    # Sets the field_x_mode attribute.
    #
    def field_x_mode=(value)
      @field_x_mode = value && value.to_s
    end

    # Sets the field_x attribute.
    #
    def field_x=(value)
      @field_x = value && value.to_s
    end

    # Sets the collimator_x1 attribute.
    #
    def collimator_x1=(value)
      @collimator_x1 = value && value.to_s
    end

    # Sets the collimator_x2 attribute.
    #
    def collimator_x2=(value)
      @collimator_x2 = value && value.to_s
    end

    # Sets the field_y_mode attribute.
    #
    def field_y_mode=(value)
      @field_y_mode = value && value.to_s
    end

    # Sets the field_y attribute.
    #
    def field_y=(value)
      @field_y = value && value.to_s
    end

    # Sets the collimator_y1 attribute.
    #
    def collimator_y1=(value)
      @collimator_y1 = value && value.to_s
    end

    # Sets the collimator_y2 attribute.
    #
    def collimator_y2=(value)
      @collimator_y2 = value && value.to_s
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

    # Sets the tolerance_table attribute.
    #
    def tolerance_table=(value)
      @tolerance_table = value && value.to_s
    end

    # Sets the arc_direction attribute.
    #
    def arc_direction=(value)
      @arc_direction = value && value.to_s
    end

    # Sets the arc_start_angle attribute.
    #
    def arc_start_angle=(value)
      @arc_start_angle = value && value.to_s
    end

    # Sets the arc_stop_angle attribute.
    #
    def arc_stop_angle=(value)
      @arc_stop_angle = value && value.to_s
    end

    # Sets the arc_mu_degree attribute.
    #
    def arc_mu_degree=(value)
      @arc_mu_degree = value && value.to_s
    end

    # Sets the wedge attribute.
    #
    def wedge=(value)
      @wedge = value && value.to_s
    end

    # Sets the dynamic_wedge attribute.
    #
    def dynamic_wedge=(value)
      @dynamic_wedge = value && value.to_s
    end

    # Sets the block attribute.
    #
    def block=(value)
      @block = value && value.to_s
    end

    # Sets the compensator attribute.
    #
    def compensator=(value)
      @compensator = value && value.to_s
    end

    # Sets the e_applicator attribute.
    #
    def e_applicator=(value)
      @e_applicator = value && value.to_s
    end

    # Sets the e_field_def_aperture attribute.
    #
    def e_field_def_aperture=(value)
      @e_field_def_aperture = value && value.to_s
    end

    # Sets the bolus attribute.
    #
    def bolus=(value)
      @bolus = value && value.to_s
    end

    # Sets the portfilm_mu_open attribute.
    #
    def portfilm_mu_open=(value)
      @portfilm_mu_open = value && value.to_s
    end

    # Sets the portfilm_coeff_open attribute.
    #
    def portfilm_coeff_open=(value)
      @portfilm_coeff_open = value && value.to_s
    end

    # Sets the portfilm_delta_open attribute.
    #
    def portfilm_delta_open=(value)
      @portfilm_delta_open = value && value.to_s
    end

    # Sets the portfilm_mu_treat attribute.
    #
    def portfilm_mu_treat=(value)
      @portfilm_mu_treat = value && value.to_s
    end

    # Sets the portfilm_coeff_treat attribute.
    #
    def portfilm_coeff_treat=(value)
      @portfilm_coeff_treat = value && value.to_s
    end


    private


    # Returns the attributes of this instance in an array (for comparison purposes).
    #
    alias_method :state, :values

  end

end