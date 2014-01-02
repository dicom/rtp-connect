module RTP

  # The treatment Field class.
  #
  # @note Relations:
  #   * Parent: Prescription
  #   * Children: ExtendedField, ControlPoint
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
    # @param [#to_s] string the treatment field definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [Field] the created Field instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      f = self.new(parent)
      f.load(string)
    end

    # Creates a new (treatment) Field.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('FIELD_DEF', 27, 49)
      # Child records:
      @control_points = Array.new
      @extended_field = nil
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Prescription)
      @parent.add_field(self)
      @attributes = [
        # Required:
        :keyword,
        :rx_site_name,
        :field_name,
        :field_id,
        :field_note,
        :field_dose,
        :field_monitor_units,
        :wedge_monitor_units,
        :treatment_machine,
        :treatment_type,
        :modality,
        :energy,
        :time,
        :doserate,
        :sad,
        :ssd,
        :gantry_angle,
        :collimator_angle,
        :field_x_mode,
        :field_x,
        :collimator_x1,
        :collimator_x2,
        :field_y_mode,
        :field_y,
        :collimator_y1,
        :collimator_y2,
        # Optional:
        :couch_vertical,
        :couch_lateral,
        :couch_longitudinal,
        :couch_angle,
        :couch_pedestal,
        :tolerance_table,
        :arc_direction,
        :arc_start_angle,
        :arc_stop_angle,
        :arc_mu_degree,
        :wedge,
        :dynamic_wedge,
        :block,
        :compensator,
        :e_applicator,
        :e_field_def_aperture,
        :bolus,
        :portfilm_mu_open,
        :portfilm_coeff_open,
        :portfilm_delta_open,
        :portfilm_mu_treat,
        :portfilm_coeff_treat
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
      if other.respond_to?(:to_field)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a control point record to this instance.
    #
    # @param [ControlPoint] child a ControlPoint instance which is to be associated with self
    #
    def add_control_point(child)
      @control_points << child.to_control_point
    end

    # Adds an extended treatment field record to this instance.
    #
    # @param [ExtendedField] child an ExtendedField instance which is to be associated with self
    #
    def add_extended_field(child)
      @extended_field = child.to_extended_field
    end

    # Collects the child records of this instance in a properly sorted array.
    #
    # @return [Array<ExtendedField, ControlPoint>] a sorted array of self's child records
    #
    def children
      return [@extended_field, @control_points].flatten.compact
    end

    # Converts the collimator_x1 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_x1 attribute
    #
    def dcm_collimator_x1
      dcm_collimator1(:x)
    end

    # Converts the collimator_x2 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_x2 attribute
    #
    def dcm_collimator_x2
      value = @collimator_x2.to_f * 10
    end

    # Converts the collimator_y1 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_y1 attribute
    #
    def dcm_collimator_y1
      dcm_collimator1(:y)
    end

    # Converts the collimator_y2 attribute to proper DICOM format.
    #
    # @return [Float] the DICOM-formatted collimator_y2 attribute
    #
    def dcm_collimator_y2
      value = @collimator_y2.to_f * 10
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

    # Returns self.
    #
    # @return [Field] self
    #
    def to_field
      self
    end

    # Encodes the Field object + any hiearchy of child objects,
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

    # Sets the field_dose attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_dose=(value)
      @field_dose = value && value.to_s.strip
    end

    # Sets the field_monitor_units attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def field_monitor_units=(value)
      @field_monitor_units = value && value.to_s.strip
    end

    # Sets the wedge_monitor_units attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def wedge_monitor_units=(value)
      @wedge_monitor_units = value && value.to_s.strip
    end

    # Sets the treatment_machine attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def treatment_machine=(value)
      @treatment_machine = value && value.to_s
    end

    # Sets the treatment_type attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def treatment_type=(value)
      @treatment_type = value && value.to_s
    end

    # Sets the modality attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def modality=(value)
      @modality = value && value.to_s
    end

    # Sets the energy attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def energy=(value)
      @energy = value && value.to_s
    end

    # Sets the time attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def time=(value)
      @time = value && value.to_s.strip
    end

    # Sets the doserate attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def doserate=(value)
      @doserate = value && value.to_s.strip
    end

    # Sets the sad attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def sad=(value)
      @sad = value && value.to_s.strip
    end

    # Sets the ssd attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def ssd=(value)
      @ssd = value && value.to_s.strip
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

    # Sets the tolerance_table attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def tolerance_table=(value)
      @tolerance_table = value && value.to_s.strip
    end

    # Sets the arc_direction attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def arc_direction=(value)
      @arc_direction = value && value.to_s
    end

    # Sets the arc_start_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def arc_start_angle=(value)
      @arc_start_angle = value && value.to_s.strip
    end

    # Sets the arc_stop_angle attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def arc_stop_angle=(value)
      @arc_stop_angle = value && value.to_s.strip
    end

    # Sets the arc_mu_degree attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def arc_mu_degree=(value)
      @arc_mu_degree = value && value.to_s.strip
    end

    # Sets the wedge attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def wedge=(value)
      @wedge = value && value.to_s
    end

    # Sets the dynamic_wedge attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dynamic_wedge=(value)
      @dynamic_wedge = value && value.to_s
    end

    # Sets the block attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def block=(value)
      @block = value && value.to_s
    end

    # Sets the compensator attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def compensator=(value)
      @compensator = value && value.to_s
    end

    # Sets the e_applicator attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def e_applicator=(value)
      @e_applicator = value && value.to_s
    end

    # Sets the e_field_def_aperture attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def e_field_def_aperture=(value)
      @e_field_def_aperture = value && value.to_s
    end

    # Sets the bolus attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def bolus=(value)
      @bolus = value && value.to_s
    end

    # Sets the portfilm_mu_open attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def portfilm_mu_open=(value)
      @portfilm_mu_open = value && value.to_s
    end

    # Sets the portfilm_coeff_open attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def portfilm_coeff_open=(value)
      @portfilm_coeff_open = value && value.to_s
    end

    # Sets the portfilm_delta_open attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def portfilm_delta_open=(value)
      @portfilm_delta_open = value && value.to_s
    end

    # Sets the portfilm_mu_treat attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def portfilm_mu_treat=(value)
      @portfilm_mu_treat = value && value.to_s
    end

    # Sets the portfilm_coeff_treat attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def portfilm_coeff_treat=(value)
      @portfilm_coeff_treat = value && value.to_s
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
    # @param [Symbol] axis a representation for the axis of interes (:x or :y)
    # @return [Float] the DICOM-formatted collimator attribute
    #
    def dcm_collimator1(axis)
      value = self.send("collimator_#{axis}1").to_f * 10
      mode = self.send("field_#{axis}_mode")
      if mode.upcase == 'SYM' && value > 0
        -value
      else
        value
      end
    end

  end

end