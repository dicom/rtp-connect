module RTP

  # The Prescription site class.
  #
  # === Relations
  #
  # * Parent: Plan
  # * Children: SiteSetup, (SimulationField), Field
  #
  class Prescription < Record

    # The Record which this instance belongs to.
    attr_reader :parent
    # The SiteSetup record (if any) that belongs to this Prescription.
    attr_reader :site_setup
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
    # === Parameters
    #
    # * <tt>string</tt> -- A string containing a prescription site record.
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def self.load(string, parent)
      # Get the quote-less values:
      values = string.to_s.values
      raise ArgumentError, "Invalid argument 'string': Expected exactly 13 elements, got #{values.length}." unless values.length == 13
      p = self.new(parent)
      # Assign the values to attributes:
      p.keyword = values[0]
      p.course_id = values[1]
      p.rx_site_name = values[2]
      p.technique = values[3]
      p.modality = values[4]
      p.dose_spec = values[5]
      p.rx_depth = values[6]
      p.dose_ttl = values[7]
      p.dose_tx = values[8]
      p.pattern = values[9]
      p.rx_note = values[10]
      p.number_of_fields = values[11]
      p.crc = values[12]
      return p
    end

    # Creates a new Prescription site.
    #
    # === Parameters
    #
    # * <tt>parent</tt> -- A Record which is used to determine the proper parent of this instance.
    #
    def initialize(parent)
      # Child objects:
      @site_setup = nil
      @fields = Array.new
      # Parent relation (may get more than one type of record here):
      @parent = get_parent(parent.to_record, Plan)
      @parent.add_prescription(self)
      @keyword = 'RX_DEF'
    end

    # Returns true if the argument is an instance with attributes equal to self.
    #
    def ==(other)
      if other.respond_to?(:to_prescription)
        other.send(:state) == state
      end
    end

    alias_method :eql?, :==

    # Adds a treatment Field record to this instance.
    #
    def add_field(child)
      @fields << child.to_field
    end

    # Connects a Site setup record to this instance.
    #
    def add_site_setup(child)
      @site_setup = child.to_site_setup
    end

    # Returns the a properly sorted array of the child records of this instance.
    #
    def children
      return [@site_setup, @fields].flatten.compact
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
        @course_id,
        @rx_site_name,
        @technique,
        @modality,
        @dose_spec,
        @rx_depth,
        @dose_ttl,
        @dose_tx,
        @pattern,
        @rx_note,
        @number_of_fields
      ]
    end

    # Returns self.
    #
    def to_prescription
      self
    end

    # Writes the Prescription object + any hiearchy of child objects,
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
      raise ArgumentError, "Invalid keyword. Expected 'RX_DEF', got #{value}." unless value == "RX_DEF"
      @keyword = value
    end

    # Sets the course_id attribute.
    #
    def course_id=(value)
      @course_id = value && value.to_s
    end

    # Sets the rx_site_name attribute.
    #
    def rx_site_name=(value)
      @rx_site_name = value && value.to_s
    end

    # Sets the technique attribute.
    #
    def technique=(value)
      @technique = value && value.to_s
    end

    # Sets the modality attribute.
    #
    def modality=(value)
      @modality = value && value.to_s
    end

    # Sets the dose_spec attribute.
    #
    def dose_spec=(value)
      @dose_spec = value && value.to_s
    end

    # Sets the rx_depth attribute.
    #
    def rx_depth=(value)
      @rx_depth = value && value.to_s
    end

    # Sets the dose_ttl attribute.
    #
    def dose_ttl=(value)
      @dose_ttl = value && value.to_s.strip
    end

    # Sets the dose_tx attribute.
    #
    def dose_tx=(value)
      @dose_tx = value && value.to_s.strip
    end

    # Sets the pattern attribute.
    #
    def pattern=(value)
      @pattern = value && value.to_s
    end

    # Sets the rx_note attribute.
    #
    def rx_note=(value)
      @rx_note = value && value.to_s
    end

    # Sets the number_of_fields attribute.
    #
    def number_of_fields=(value)
      @number_of_fields = value && value.to_s.strip
    end


    private


    # Returns the attributes of this instance in an array (for comparison purposes).
    #
    alias_method :state, :values

  end

end