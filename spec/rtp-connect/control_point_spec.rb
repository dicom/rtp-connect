# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe ControlPoint do

    before :example do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @f = Field.new(@p)
      @cp = ControlPoint.new(@f)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {ControlPoint.load(42, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Field is passed as the 'parent' argument" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        expect {ControlPoint.load(str, 'not-a-field')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","7923"'
        expect {ControlPoint.load(str, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","extra","16366"'
        cp = ControlPoint.load(str, @f)
      end

      it "should create a ControlPoint object when given a valid string" do
        # Since (currently) the last element of this record is a required one, there is no (valid) short version.
        complete = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        expect(ControlPoint.load(complete, @f).class).to eql ControlPoint
      end

      it "should set attributes from the given string" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        cp = ControlPoint.load(str, @f)
        expect(cp.field_id).to eql 'BAKFR'
        expect(cp.gantry_angle).to eql '180.0'
      end

    end


    describe "::new" do

      it "should create a ControlPoint object" do
        expect(@cp.class).to eql ControlPoint
      end

      it "should set the parent attribute" do
        expect(@cp.parent).to eql @f
      end

      it "should set the default keyword attribute" do
        expect(@cp.keyword).to eql "CONTROL_PT_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        ef = ExtendedField.new(@f)
        cp = ControlPoint.new(ef)
        expect(cp.parent).to eql @f
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        cp_other = ControlPoint.new(@f)
        cp_other.field_id = '123'
        @cp.field_id = '123'
        expect(@cp == cp_other).to be_truthy
      end

      it "should be false when comparing two instances having the different attribute values" do
        cp_other = ControlPoint.new(@f)
        cp_other.field_id = '123'
        @cp.field_id = '456'
        expect(@cp == cp_other).to be_falsey
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@cp == 42).to be_falsey
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@cp.children).to eql Array.new
      end

    end


    describe "#dcm_collimator_x1" do

      it "should return the processed collimator_x1 attribute of the control point" do
        value = -11.5
        @cp.collimator_x1 = value
        @cp.field_x_mode = 'SYM'
        expect(@cp.dcm_collimator_x1).to eql value * 10
      end

      it "should get the collimator_x1 attribute from the parent field when field parameters for the control point is not defined" do
        value = -11.5
        @cp.collimator_x1 = ''
        @cp.field_x_mode = ''
        @cp.parent.collimator_x1 = value
        @cp.parent.field_x_mode = 'SYM'
        expect(@cp.dcm_collimator_x1).to eql value * 10
      end

      context "with scale=:elekta" do

        it "should return an inverted, negative value (with field_x_mode being defined)" do
          # FIXME: Scale conversion really needs to be investigated closer.
          @cp.collimator_x1 = 5.0
          @cp.collimator_y1 = 5.0
          @cp.field_x_mode = 'SYM'
          @cp.field_y_mode = 'SYM'
          expect(@cp.dcm_collimator_x1(scale=:elekta)).to eql -50.0
        end

        it "should return an inverted, negative value pulled from the parent field (with field_x_mode being undefined)" do
          @cp.collimator_x1 = 0.0
          @cp.collimator_y1 = 0.0
          @cp.field_x_mode = ''
          @cp.field_y_mode = ''
          @cp.parent.collimator_x1 = 5.0
          @cp.parent.collimator_y1 = 5.0
          @cp.parent.field_x_mode = 'SYM'
          @cp.parent.field_y_mode = 'SYM'
          expect(@cp.dcm_collimator_x1(scale=:elekta)).to eql -50.0
        end

      end

      context "with scale=:varian" do

        it "should return an inverted value" do
          # FIXME: Scale conversion really needs to be investigated closer.
          @cp.collimator_x1 = 5.0
          @cp.collimator_y1 = 5.0
          @cp.field_x_mode = 'Asy'
          @cp.field_y_mode = 'Asy'
          expect(@cp.dcm_collimator_x1(scale=:varian)).to eql -50.0
        end

      end

    end


    describe "#dcm_collimator_y1" do

      it "should return the processed collimator_y1 attribute of the control point" do
        value = -11.5
        @cp.collimator_y1 = value
        @cp.field_y_mode = 'SYM'
        expect(@cp.dcm_collimator_y1).to eql value * 10
      end

      it "should get the collimator_y1 attribute from the parent field when field parameters for the control point is not defined" do
        value = -11.5
        @cp.collimator_y1 = ''
        @cp.field_y_mode = ''
        @cp.parent.collimator_y1 = value
        @cp.parent.field_y_mode = 'SYM'
        expect(@cp.dcm_collimator_y1).to eql value * 10
      end

      context "with scale=:elekta" do

        it "should return an inverted, negative value (with field_y_mode being defined)" do
          # FIXME: Scale conversion really needs to be investigated closer.
          @cp.collimator_x1 = 5.0
          @cp.collimator_y1 = 5.0
          @cp.field_x_mode = 'SYM'
          @cp.field_y_mode = 'SYM'
          expect(@cp.dcm_collimator_y1(scale=:elekta)).to eql -50.0
        end

        it "should return an inverted, negative value pulled from the parent field (with field_y_mode being undefined)" do
          @cp.collimator_x1 = 0.0
          @cp.collimator_y1 = 0.0
          @cp.field_x_mode = ''
          @cp.field_y_mode = ''
          @cp.parent.collimator_x1 = 5.0
          @cp.parent.collimator_y1 = 5.0
          @cp.parent.field_x_mode = 'SYM'
          @cp.parent.field_y_mode = 'SYM'
          expect(@cp.dcm_collimator_y1(scale=:elekta)).to eql -50.0
        end

      end

      context "with scale=:varian " do

        it "should return an inverted value" do
          # FIXME: Scale conversion really needs to be investigated closer.
          @cp.collimator_x1 = 5.0
          @cp.collimator_y1 = 5.0
          @cp.field_x_mode = 'Asy'
          @cp.field_y_mode = 'Asy'
          expect(@cp.dcm_collimator_y1(scale=:varian)).to eql -50.0
        end

      end

    end


    describe "#dcm_collimator_x2" do

      it "should return the processed collimator_x2 attribute of the control point" do
        value = 11.5
        @cp.collimator_x2 = value
        @cp.field_x_mode = 'SYM'
        expect(@cp.dcm_collimator_x2).to eql value * 10
      end

      it "should get the collimator_x2 attribute from the parent field when field parameters for the control point is not defined" do
        value = 11.5
        @cp.collimator_x2 = ''
        @cp.field_x_mode = ''
        @cp.parent.collimator_x2 = value
        @cp.parent.field_x_mode = 'SYM'
        expect(@cp.dcm_collimator_x2).to eql value * 10
      end

    end


    describe "#dcm_collimator_y2" do

      it "should return the processed collimator_y2 attribute of the control point" do
        value = 11.5
        @cp.collimator_y2 = value
        @cp.field_y_mode = 'SYM'
        expect(@cp.dcm_collimator_y2).to eql value * 10
      end

      it "should get the collimator_y2 attribute from the parent field when field parameters for the control point is not defined" do
        value = 11.5
        @cp.collimator_y2 = ''
        @cp.field_y_mode = ''
        @cp.parent.collimator_y2 = value
        @cp.parent.field_y_mode = 'SYM'
        expect(@cp.dcm_collimator_y2).to eql value * 10
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        cp_other = ControlPoint.new(@f)
        cp_other.field_id = '1'
        @cp.field_id = '1'
        expect(@cp == cp_other).to be_truthy
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"CONTROL_PT_DEF",' + Array.new(231){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        cp1 = ControlPoint.load(str, @f)
        cp2 = ControlPoint.load(str, @f)
        expect(cp1.hash == cp2.hash).to be_truthy
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["CONTROL_PT_DEF", [nil]*231].flatten
        expect(@cp.values).to eql arr
      end

    end


    describe "#to_control_point" do

      it "should return itself" do
        expect(@cp.to_control_point.equal?(@cp)).to be_truthy
      end

    end


    describe "#to_s" do

      it "should return a string which matches the original string" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"' + "\r\n"
        cp = ControlPoint.load(str, @f)
        expect(cp.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"CONTROL_PT_DEF",' + Array.new(231){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        cp = ControlPoint.load(str, @f)
        expect(cp.to_s).to eql str
      end

    end


    describe "#mlc_lp_a=()" do

      it "should raise an error if the specified array has less than 100 elements" do
        expect {@cp.mlc_lp_a=(Array.new(99, ''))}.to raise_error(ArgumentError, /array/)
      end

      it "should raise an error if the specified array has more than 100 elements" do
        expect {@cp.mlc_lp_a=(Array.new(101, ''))}.to raise_error(ArgumentError, /array/)
      end

      it "should transfer the array (containing string and nil values) to the mlc_lp_a attribute" do
        arr = Array.new(100)
        arr[10] = '5.00'
        arr[90] = '-5.00'
        @cp.mlc_lp_a = arr
        expect(@cp.mlc_lp_a).to eql arr
      end

      it "should transfer the array (containing only string values) to the mlc_lp_a attribute" do
        arr =Array.new(100) {|i| (i-50).to_f.to_s}
        @cp.mlc_lp_a = arr
        expect(@cp.mlc_lp_a).to eql arr
      end

    end


    describe "#mlc_lp_b=()" do

      it "should raise an error if the specified array has less than 100 elements" do
        expect {@cp.mlc_lp_b=(Array.new(99, ''))}.to raise_error(ArgumentError, /array/)
      end

      it "should raise an error if the specified array has more than 100 elements" do
        expect {@cp.mlc_lp_b=(Array.new(101, ''))}.to raise_error(ArgumentError, /array/)
      end

      it "should transfer the array (containing string and nil values) to the mlc_lp_b attribute" do
        arr = Array.new(100)
        arr[10] = '15.00'
        arr[90] = '-15.00'
        @cp.mlc_lp_b = arr
        expect(@cp.mlc_lp_b).to eql arr
      end

      it "should transfer the array (containing only string values) to the mlc_lp_b attribute" do
        arr =Array.new(100) {|i| (i-50).to_f.to_s}
        @cp.mlc_lp_b = arr
        expect(@cp.mlc_lp_b).to eql arr
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'CONTROL_PT_DEF' is given as an argument" do
        expect {@cp.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @cp.keyword = 'CONTROL_PT_DEF'
        expect(@cp.keyword).to eql 'CONTROL_PT_DEF'
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @cp.field_id = value
        expect(@cp.field_id).to eql value
      end

    end


    describe "#mlc_type=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '11'
        @cp.mlc_type = value
        expect(@cp.mlc_type).to eql value
      end

    end


    describe "#mlc_leaves=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '40'
        @cp.mlc_leaves = value
        expect(@cp.mlc_leaves).to eql value
      end

    end


    describe "#total_control_points=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '12'
        @cp.total_control_points = value
        expect(@cp.total_control_points).to eql value
      end

    end


    describe "#control_pt_number=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0'
        @cp.control_pt_number = value
        expect(@cp.control_pt_number).to eql value
      end

    end


    describe "#mu_convention=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @cp.mu_convention = value
        expect(@cp.mu_convention).to eql value
      end

    end


    describe "#monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9'
        @cp.monitor_units = value
        expect(@cp.monitor_units).to eql value
      end

    end


    describe "#wedge_position=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Out'
        @cp.wedge_position = value
        expect(@cp.wedge_position).to eql value
      end

    end


    describe "#energy=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @cp.energy = value
        expect(@cp.energy).to eql value
      end

    end


    describe "#doserate=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '300'
        @cp.doserate = value
        expect(@cp.doserate).to eql value
      end

    end


    describe "#ssd=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '93.8'
        @cp.ssd = value
        expect(@cp.ssd).to eql value
      end

    end


    describe "#scale_convention=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @cp.scale_convention = value
        expect(@cp.scale_convention).to eql value
      end

    end


    describe "#gantry_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '45'
        @cp.gantry_angle = value
        expect(@cp.gantry_angle).to eql value
      end

    end


    describe "#gantry_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @cp.gantry_dir = value
        expect(@cp.gantry_dir).to eql value
      end

    end


    describe "#collimator_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '65'
        @cp.collimator_angle = value
        expect(@cp.collimator_angle).to eql value
      end

    end


    describe "#collimator_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @cp.collimator_dir = value
        expect(@cp.collimator_dir).to eql value
      end

    end


    describe "#field_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Sym'
        @cp.field_x_mode = value
        expect(@cp.field_x_mode).to eql value
      end

    end


    describe "#field_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.0'
        @cp.field_x = value
        expect(@cp.field_x).to eql value
      end

    end


    describe "#collimator_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2.0'
        @cp.collimator_x1 = value
        expect(@cp.collimator_x1).to eql value
      end

    end


    describe "#collimator_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.0'
        @cp.collimator_x2 = value
        expect(@cp.collimator_x2).to eql value
      end

    end


    describe "#field_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Asy'
        @cp.field_y_mode = value
        expect(@cp.field_y_mode).to eql value
      end

    end


    describe "#field_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '5.0'
        @cp.field_y = value
        expect(@cp.field_y).to eql value
      end

    end


    describe "#collimator_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3.5'
        @cp.collimator_y1 = value
        expect(@cp.collimator_y1).to eql value
      end

    end


    describe "#collimator_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.5'
        @cp.collimator_y2 = value
        expect(@cp.collimator_y2).to eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.5'
        @cp.couch_vertical = value
        expect(@cp.couch_vertical).to eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.3'
        @cp.couch_lateral = value
        expect(@cp.couch_lateral).to eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '55.3'
        @cp.couch_longitudinal = value
        expect(@cp.couch_longitudinal).to eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4'
        @cp.couch_angle = value
        expect(@cp.couch_angle).to eql value
      end

    end


    describe "#couch_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CCW'
        @cp.couch_dir = value
        expect(@cp.couch_dir).to eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @cp.couch_pedestal = value
        expect(@cp.couch_pedestal).to eql value
      end

    end


    describe "#couch_ped_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CCW'
        @cp.couch_ped_dir = value
        expect(@cp.couch_ped_dir).to eql value
      end

    end

  end

end
