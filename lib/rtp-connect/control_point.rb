module RTP

  # The ControlPoint class.
  #
  # @note Relations:
  #   * Parent: Field
  #   * Children: none
  #
  class ControlPoint < Record

    # The number of attributes not having their own variable for this record (200 - 2).
    NR_SURPLUS_ATTRIBUTES = 198

    # The Record which this instance belongs to.
    attr_accessor :parent
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
    attr_reader :iso_pos_x
    attr_reader :iso_pos_y
    attr_reader :iso_pos_z
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
      super('CONTROL_PT_DEF', 233, 236)
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
        :iso_pos_x,
        :iso_pos_y,
        :iso_pos_z,
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
    # @param [Symbol] scale if set, relevant device parameters are converted from a native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [Float] the DICOM-formatted collimator_x1 attribute
    #
    def dcm_collimator_x1(scale=nil)
      dcm_collimator_1(scale, default_axis=:x)
    end

    # Converts the collimator_x2 attribute to proper DICOM format.
    #
    # @param [Symbol] scale if set, relevant device parameters are converted from native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [Float] the DICOM-formatted collimator_x2 attribute
    #
    def dcm_collimator_x2(scale=nil)
      axis = (scale == :elekta ? :y : :x)
      dcm_collimator(axis, coeff=1, side=2)
    end

    # Converts the collimator_y1 attribute to proper DICOM format.
    #
    # @param [Symbol] scale if set, relevant device parameters are converted from native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [Float] the DICOM-formatted collimator_y1 attribute
    #
    def dcm_collimator_y1(scale=nil)
      dcm_collimator_1(scale, default_axis=:y)
    end

    # Converts the collimator_y2 attribute to proper DICOM format.
    #
    # @param [Symbol] scale if set, relevant device parameters are converted from native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [Float] the DICOM-formatted collimator_y2 attribute
    #
    def dcm_collimator_y2(scale=nil)
      axis = (scale == :elekta ? :x : :y)
      dcm_collimator(axis, coeff=1, side=2)
    end

    # Converts the mlc_lp_a & mlc_lp_b attributes to a proper DICOM formatted string.
    #
    # @param [Symbol] scale if set, relevant device parameters are converted from native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [String] the DICOM-formatted leaf pair positions
    #
    def dcm_mlc_positions(scale=nil)
      coeff = (scale == :elekta ? -1 : 1)
      # As with the collimators, the first side (1/a) may need scale invertion:
      pos_a = @mlc_lp_a.collect{|p| (p.to_f * 10 * coeff).round(1) unless p.empty?}.compact
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
        @iso_pos_x,
        @iso_pos_y,
        @iso_pos_z,
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

    # Sets the mlc_lp_a attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 100 MLC leaf 'A' string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def mlc_lp_a=(array)
      @mlc_lp_a = array.to_a.validate_and_process(100)
    end

    # Sets the mlc_lp_b attribute.
    #
    # @note As opposed to the ordinary (string) attributes, this attribute
    #   contains an array holding all 100 MLC leaf 'B' string values.
    # @param [Array<nil, #to_s>] array the new attribute values
    #
    def mlc_lp_b=(array)
      @mlc_lp_b = array.to_a.validate_and_process(100)
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
    # @param [Integer] coeff a coeffecient (of -1 or 1) which the attribute is multiplied with
    # @param [Integer] nr collimator side/index (1 or 2)
    # @return [Float] the DICOM-formatted collimator attribute
    #
    def dcm_collimator(axis, coeff, nr)
      mode = self.send("field_#{axis}_mode")
      if mode && !mode.empty?
        target = self
      else
        target = @parent
      end
      target.send("collimator_#{axis}#{nr}").to_f * 10 * coeff
    end

    # Converts the collimator1 attribute to proper DICOM format.
    #
    # @param [Symbol] scale if set, relevant device parameters are converted from a native readout format to IEC1217 (supported values are :elekta & :varian)
    # @return [Float] the DICOM-formatted collimator_x1 attribute
    #
    def dcm_collimator_1(scale=nil, axis)
      coeff = 1
      if scale == :elekta
        axis = (axis == :x ? :y : :x)
        coeff = -1
      elsif scale == :varian
        coeff = -1
      end
      dcm_collimator(axis, coeff, side=1)
    end

    # Gives an array of indices indicating where the attributes of this record gets its
    # values from in the comma separated string which the instance is created from.
    #
    # @param [Integer] length the number of elements to create in the indices array
    #
    def import_indices(length)
      # Note that this method is defined in the parent Record class, where it is
      # used for most record types. However, because this record has two attributes
      # which contain an array of values, we use a custom import_indices method.
      #
      # Furthermore, as of Mosaiq version 2.64, the RTP ControlPoint record includes
      # 3 new attributes: iso_pos_x/y/z. Since these (unfortunately) are not placed
      # at the end of the record (which is the norm), but rather inserted before the
      # MLC leaf positions, we have to take special care here to make sure that this
      # gets right for records where these are included or excluded.
      #
      # Override length:
      applied_length = 235
      ind = Array.new(applied_length - NR_SURPLUS_ATTRIBUTES) { |i| [i] }
      # Override indices for mlc_pl_a and mlc_lp_b:
      # Allocation here is dependent on the RTP file version:
      # For 2.62 and earlier, where length is 232, we dont have the 3 iso_pos_x/y/z values preceeding the mlc arrays leaf position arrays.
      # For 2.64 (and later), where length is 235, we have the 3 iso_pos_x/y/z values preceeding the mlc leaf position arrays.
      if length == 232
        ind[32] = nil
        ind[33] = nil
        ind[34] = nil
        ind[35] = (32..131).to_a
        ind[36] = (132..231).to_a
      else # (length = 235)
        ind[35] = (35..134).to_a
        ind[36] = (135..234).to_a
      end
      ind
    end

  end

end