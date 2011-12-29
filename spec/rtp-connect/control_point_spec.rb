# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe ControlPoint do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @f = Field.new(@p)
      @cp = ControlPoint.new(@f)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {ControlPoint.load(42, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when a non-Field is passed as the 'parent' argument" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        expect {ControlPoint.load(str, 'not-a-field')}.to raise_error(ArgumentError, /'parent'/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","7923"'
        expect {ControlPoint.load(str, @f)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should create a ControlPoint object when given a valid string" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        ControlPoint.load(str, @f).class.should eql ControlPoint
      end

      it "should set attributes from the given string" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"'
        cp = ControlPoint.load(str, @f)
        cp.field_id.should eql 'BAKFR'
        cp.gantry_angle.should eql '180.0'
      end

    end


    describe "::new" do

      it "should create a ControlPoint object" do
        @cp.class.should eql ControlPoint
      end

      it "should set the parent attribute" do
        @cp.parent.should eql @f
      end

      it "should set the default keyword attribute" do
        @cp.keyword.should eql "CONTROL_PT_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        ef = ExtendedField.new(@f)
        cp = ControlPoint.new(ef)
        cp.parent.should eql @f
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @cp.children.should eql Array.new
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["CONTROL_PT_DEF", [nil]*231].flatten
        @cp.values.should eql arr
      end

    end


    describe "to_str" do

      it "should return a string which matches the original string" do
        str = '"CONTROL_PT_DEF","BAKFR","11","40","1","0","1","0.000000","","15","0","96.3","2","180.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-5.00","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","-0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","5.00","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","0.50","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","7923"' + "\r\n"
        cp = ControlPoint.load(str, @f)
        cp.to_str.should eql str
      end

    end


    describe "#mlc_lp_a=()" do

      it "should raise an error if a non-array is given as an argument" do
        expect {@cp.mlc_lp_a=('not-an-array')}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has less than 100 elements" do
        expect {@cp.mlc_lp_a=(Array.new(99, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has more than 100 elements" do
        expect {@cp.mlc_lp_a=(Array.new(101, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array contains anything else than string or nil elements" do
        arr = Array.new(100)
        arr[10] = false
        expect {@cp.mlc_lp_a=(arr)}.to raise_error(ArgumentError, /'array'/)
      end

      it "should transfer the array (containing string and nil values) to the mlc_lp_a attribute" do
        arr = Array.new(100)
        arr[10] = '5.00'
        arr[90] = '-5.00'
        @cp.mlc_lp_a = arr
        @cp.mlc_lp_a.should eql arr
      end

      it "should transfer the array (containing only string values) to the mlc_lp_a attribute" do
        arr =Array.new(100) {|i| (i-50).to_f.to_s}
        @cp.mlc_lp_a = arr
        @cp.mlc_lp_a.should eql arr
      end

    end


    describe "#mlc_lp_b=()" do

      it "should raise an error if a non-array is given as an argument" do
        expect {@cp.mlc_lp_b=('not-an-array')}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has less than 100 elements" do
        expect {@cp.mlc_lp_b=(Array.new(99, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array has more than 100 elements" do
        expect {@cp.mlc_lp_b=(Array.new(101, ''))}.to raise_error(ArgumentError, /'array'/)
      end

      it "should raise an error if the specified array contains anything else than string or nil elements" do
        arr = Array.new(100)
        arr[10] = true
        arr[11] = '9.0'
        expect {@cp.mlc_lp_b=(arr)}.to raise_error(ArgumentError, /'array'/)
      end

      it "should transfer the array (containing string and nil values) to the mlc_lp_a attribute" do
        arr = Array.new(100)
        arr[10] = '15.00'
        arr[90] = '-15.00'
        @cp.mlc_lp_b = arr
        @cp.mlc_lp_b.should eql arr
      end

      it "should transfer the array (containing only string values) to the mlc_lp_a attribute" do
        arr =Array.new(100) {|i| (i-50).to_f.to_s}
        @cp.mlc_lp_b = arr
        @cp.mlc_lp_b.should eql arr
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'CONTROL_PT_DEF' is given as an argument" do
        expect {@cp.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @cp.keyword = 'CONTROL_PT_DEF'
        @cp.keyword.should eql 'CONTROL_PT_DEF'
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @cp.field_id = value
        @cp.field_id.should eql value
      end

    end


    describe "#mlc_type=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '11'
        @cp.mlc_type = value
        @cp.mlc_type.should eql value
      end

    end


    describe "#mlc_leaves=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '40'
        @cp.mlc_leaves = value
        @cp.mlc_leaves.should eql value
      end

    end


    describe "#total_control_points=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '12'
        @cp.total_control_points = value
        @cp.total_control_points.should eql value
      end

    end


    describe "#control_pt_number=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0'
        @cp.control_pt_number = value
        @cp.control_pt_number.should eql value
      end

    end


    describe "#mu_convention=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @cp.mu_convention = value
        @cp.mu_convention.should eql value
      end

    end


    describe "#monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9'
        @cp.monitor_units = value
        @cp.monitor_units.should eql value
      end

    end


    describe "#wedge_position=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Out'
        @cp.wedge_position = value
        @cp.wedge_position.should eql value
      end

    end


    describe "#energy=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @cp.energy = value
        @cp.energy.should eql value
      end

    end


    describe "#doserate=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '300'
        @cp.doserate = value
        @cp.doserate.should eql value
      end

    end


    describe "#ssd=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '93.8'
        @cp.ssd = value
        @cp.ssd.should eql value
      end

    end


    describe "#scale_convention=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @cp.scale_convention = value
        @cp.scale_convention.should eql value
      end

    end


    describe "#gantry_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '45'
        @cp.gantry_angle = value
        @cp.gantry_angle.should eql value
      end

    end


    describe "#gantry_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @cp.gantry_dir = value
        @cp.gantry_dir.should eql value
      end

    end


    describe "#collimator_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '65'
        @cp.collimator_angle = value
        @cp.collimator_angle.should eql value
      end

    end


    describe "#collimator_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @cp.collimator_dir = value
        @cp.collimator_dir.should eql value
      end

    end


    describe "#field_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Sym'
        @cp.field_x_mode = value
        @cp.field_x_mode.should eql value
      end

    end


    describe "#field_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.0'
        @cp.field_x = value
        @cp.field_x.should eql value
      end

    end


    describe "#collimator_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2.0'
        @cp.collimator_x1 = value
        @cp.collimator_x1.should eql value
      end

    end


    describe "#collimator_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.0'
        @cp.collimator_x2 = value
        @cp.collimator_x2.should eql value
      end

    end


    describe "#field_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Asy'
        @cp.field_y_mode = value
        @cp.field_y_mode.should eql value
      end

    end


    describe "#field_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '5.0'
        @cp.field_y = value
        @cp.field_y.should eql value
      end

    end


    describe "#collimator_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3.5'
        @cp.collimator_y1 = value
        @cp.collimator_y1.should eql value
      end

    end


    describe "#collimator_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.5'
        @cp.collimator_y2 = value
        @cp.collimator_y2.should eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.5'
        @cp.couch_vertical = value
        @cp.couch_vertical.should eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.3'
        @cp.couch_lateral = value
        @cp.couch_lateral.should eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '55.3'
        @cp.couch_longitudinal = value
        @cp.couch_longitudinal.should eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4'
        @cp.couch_angle = value
        @cp.couch_angle.should eql value
      end

    end


    describe "#couch_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CCW'
        @cp.couch_dir = value
        @cp.couch_dir.should eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @cp.couch_pedestal = value
        @cp.couch_pedestal.should eql value
      end

    end


    describe "#couch_ped_dir=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CCW'
        @cp.couch_ped_dir = value
        @cp.couch_ped_dir.should eql value
      end

    end

  end

end
