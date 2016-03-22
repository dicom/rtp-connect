module RTP

  # The Prescription site class.
  #
  # @note Relations:
  #   * Parent: Plan
  #   * Children: SiteSetup, SimulationField, Field
  #
  class Prescription < Record

    # The Record which this instance belongs to.
    attr_accessor :parent
    # The SiteSetup record (if any) that belongs to this Prescription.
    attr_reader :site_setup
    # An array of SimulationField records (if any) that belongs to this Prescription.
    attr_reader :simulation_fields
    # An array of Field records (if any) that belongs to this Prescription.
    attr_reader :fields
    attr_reader :course_id
    attr_reader :rx_site_name
    attr_reader :technique
    attr_reader :modality
    attr_reader :dose_spec
    attr_reader :rx_depth
    attr_reader :dose_ttl
    attr_reader :dose_tx
    attr_reader :pattern
    attr_reader :rx_note
    attr_reader :number_of_fields

    # Creates a new Prescription site by parsing a RTPConnect string line.
    #
    # @param [#to_s] string the prescription site definition record string line
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    # @return [Prescription] the created Precription instance
    # @raise [ArgumentError] if given a string containing an invalid number of elements
    #
    def self.load(string, parent)
      p = self.new(parent)
      p.load(string)
    end

    # Creates a new Prescription site.
    #
    # @param [Record] parent a record which is used to determine the proper parent of this instance
    #
    def initialize(parent)
      super('RX_DEF', 4, 13)
      # Child objects:
      @site_setup = nil
      @fields = Array.new
      @simulation_fields = Array.new
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_prescription(self)
      @attributes = [
        # Required:
        :keyword,
        :course_id,
        :rx_site_name,
        # Optional:
        :technique,
        :modality,
        :dose_spec,
        :rx_depth,
        :dose_ttl,
        :dose_tx,
        :pattern,
        :rx_note,
        :number_of_fields
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
      if other.respond_to?(:to_prescription)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a treatment field record to this instance.
    #
    # @param [Field] child a Field instance which is to be associated with self
    #
    def add_field(child)
      @fields << child.to_field
      child.parent = self
    end

    # Adds a simulation field record to this instance.
    #
    # @param [Field] child a SimulationField instance which is to be associated with self
    #
    def add_simulation_field(child)
      @simulation_fields << child.to_simulation_field
      child.parent = self
    end

    # Adds a site setup record to this instance.
    #
    # @param [SiteSetup] child a SiteSetup instance which is to be associated with self
    #
    def add_site_setup(child)
      @site_setup = child.to_site_setup
      child.parent = self
    end

    # Collects the child records of this instance in a properly sorted array.
    #
    # @return [Array<SiteSetup, SimulationField, Field>] a sorted array of self's child records
    #
    def children
      return [@site_setup, @simulation_fields, @fields].flatten.compact
    end

    # Removes the reference of the given instance from this instance.
    #
    # @param [Field, SimulationField, SiteSetup] record a child record to be removed from this instance
    #
    def delete(record)
      case record
      when Field
        delete_child(:fields, record)
      when SimulationField
        delete_child(:simulation_fields, record)
      when SiteSetup
        delete_site_setup
      else
        logger.warn("Unknown class (record) given to Prescription#delete: #{record.class}")
      end
    end

    # Removes all field references from this instance.
    #
    def delete_fields
      delete_children(:fields)
    end

    # Removes all simulation_field references from this instance.
    #
    def delete_simulation_fields
      delete_children(:simulation_fields)
    end

    # Removes the site setup reference from this instance.
    #
    def delete_site_setup
      delete_child(:site_setup)
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
    # @return [Prescription] self
    #
    def to_prescription
      self
    end

    # Sets the course_id attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def course_id=(value)
      @course_id = value && value.to_s
    end

    # Sets the rx_site_name attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the technique attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def technique=(value)
      @technique = value && value.to_s
    end

    # Sets the modality attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def modality=(value)
      @modality = value && value.to_s
    end

    # Sets the dose_spec attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_spec=(value)
      @dose_spec = value && value.to_s
    end

    # Sets the rx_depth attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_depth=(value)
      @rx_depth = value && value.to_s
    end

    # Sets the dose_ttl attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_ttl=(value)
      @dose_ttl = value && value.to_s.strip
    end

    # Sets the dose_tx attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def dose_tx=(value)
      @dose_tx = value && value.to_s.strip
    end

    # Sets the pattern attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def pattern=(value)
      @pattern = value && value.to_s
    end

    # Sets the rx_note attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def rx_note=(value)
      @rx_note = value && value.to_s
    end

    # Sets the number_of_fields attribute.
    #
    # @param [nil, #to_s] value the new attribute value
    #
    def number_of_fields=(value)
      @number_of_fields = value && value.to_s.strip
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