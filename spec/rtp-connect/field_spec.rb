# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Field do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @f = Field.new(@p)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Field.load(42, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when a non-Prescription is passed as the 'parent' argument" do
        expect {Field.load('"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"', 'not-an-rx')}.to raise_error(ArgumentError, /'parent'/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","24065"'
        expect {Field.load(str, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should create a Field object when given a valid string" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"'
        Field.load(str, @p).class.should eql Field
      end

      it "should set attributes from the given string" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"'
        f = Field.load(str, @p)
        f.field_name.should eql '8 Bakfra'
        f.collimator_y2.should eql '5.8'
      end

    end


    describe "::new" do

      it "should create a Field object" do
        @f.class.should eql Field
      end

      it "should set the parent attribute" do
        @f.parent.should eql @p
      end

      it "should set the default keyword attribute" do
        @f.keyword.should eql "FIELD_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        ss = SiteSetup.new(@p)
        f = Field.new(ss)
        f.parent.should eql @p
      end

    end


    describe "#add_control_point" do

      it "should raise an ArgumentError when a non-ControlPoint is passed as the 'child' argument" do
        expect {@f.add_control_point(42)}.to raise_error(ArgumentError, /'child'/)
      end

      it "should add the control point" do
        f_other = Field.new(@p)
        cp = ControlPoint.new(f_other)
        @f.add_control_point(cp)
        @f.control_points.should eql [cp]
      end

    end


    describe "#add_extended_field" do

      it "should raise an ArgumentError when a non-ExtendedField is passed as the 'child' argument" do
        expect {@f.add_extended_field(42)}.to raise_error(ArgumentError, /'child'/)
      end

      it "should add the extended field" do
        f_other = Field.new(@p)
        ef = ExtendedField.new(f_other)
        @f.add_extended_field(ef)
        @f.extended_field.should eql ef
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @f.children.should eql Array.new
      end

      it "should return a one-element array containing the Field's control point" do
        cp = ControlPoint.new(@f)
        @f.children.should eql [cp]
      end

      it "should return a one-element array containing the Field's extended field" do
        ef = ExtendedField.new(@f)
        @f.children.should eql [ef]
      end

      it "should return a three-element array containing the Field's extended field and two control points" do
        cp1 = ControlPoint.new(@f)
        cp2 = ControlPoint.new(@f)
        ef = ExtendedField.new(@f)
        @f.children.should eql [ef, cp1, cp2]
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["FIELD_DEF", [nil]*47].flatten
        @f.values.should eql arr
      end

    end


    describe "to_str" do

      it "should return a string which matches the original string" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"' + "\r\n"
        f = Field.load(str, @p)
        f.to_str.should eql str
      end
      
      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"FIELD_DEF",' + Array.new(47){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        f = Field.load(str, @p)
        f.to_str.should eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'FIELD_DEF' is given as an argument" do
        expect {@f.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @f.keyword = 'FIELD_DEF'
        @f.keyword.should eql 'FIELD_DEF'
      end

    end


    describe "#field_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Anterior'
        @f.field_name = value
        @f.field_name.should eql value
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @f.field_id = value
        @f.field_id.should eql value
      end

    end


    describe "#field_note=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'asymmetric'
        @f.field_note = value
        @f.field_note.should eql value
      end

    end


    describe "#field_dose=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '50'
        @f.field_dose = value
        @f.field_dose.should eql value
      end

    end


    describe "#field_monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '57'
        @f.field_monitor_units = value
        @f.field_monitor_units.should eql value
      end

    end


    describe "#wedge_monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '41'
        @f.wedge_monitor_units = value
        @f.wedge_monitor_units.should eql value
      end

    end


    describe "#treatment_machine=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'AL01'
        @f.treatment_machine = value
        @f.treatment_machine.should eql value
      end

    end


    describe "#treatment_type=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Static'
        @f.treatment_type = value
        @f.treatment_type.should eql value
      end

    end


    describe "#modality=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Xrays'
        @f.modality = value
        @f.modality.should eql value
      end

    end


    describe "#energy=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @f.energy = value
        @f.energy.should eql value
      end

    end


    describe "#time=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @f.time = value
        @f.time.should eql value
      end

    end


    describe "#doserate=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '300'
        @f.doserate = value
        @f.doserate.should eql value
      end

    end


    describe "#sad=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '100.0'
        @f.sad = value
        @f.sad.should eql value
      end

    end


    describe "#ssd=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '94.7'
        @f.ssd = value
        @f.ssd.should eql value
      end

    end


    describe "#gantry_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '21'
        @f.gantry_angle = value
        @f.gantry_angle.should eql value
      end

    end


    describe "#collimator_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '110'
        @f.collimator_angle = value
        @f.collimator_angle.should eql value
      end

    end


    describe "#field_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Asym'
        @f.field_x_mode = value
        @f.field_x_mode.should eql value
      end

    end


    describe "#field_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.7'
        @f.field_x = value
        @f.field_x.should eql value
      end

    end


    describe "#collimator_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2.7'
        @f.collimator_x1 = value
        @f.collimator_x1.should eql value
      end

    end


    describe "#collimator_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.0'
        @f.collimator_x2 = value
        @f.collimator_x2.should eql value
      end

    end


    describe "#field_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Sym'
        @f.field_y_mode = value
        @f.field_y_mode.should eql value
      end

    end


    describe "#field_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6.0'
        @f.field_y = value
        @f.field_y.should eql value
      end

    end


    describe "#collimator_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3.0'
        @f.collimator_y1 = value
        @f.collimator_y1.should eql value
      end

    end


    describe "#collimator_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3.0'
        @f.collimator_y2 = value
        @f.collimator_y2.should eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '13.7'
        @f.couch_vertical = value
        @f.couch_vertical.should eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-4.7'
        @f.couch_lateral = value
        @f.couch_lateral.should eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '61.7'
        @f.couch_longitudinal = value
        @f.couch_longitudinal.should eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @f.couch_angle = value
        @f.couch_angle.should eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6'
        @f.couch_pedestal = value
        @f.couch_pedestal.should eql value
      end

    end


    describe "#tolerance_table=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @f.tolerance_table = value
        @f.tolerance_table.should eql value
      end

    end


    describe "#arc_direction=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @f.arc_direction = value
        @f.arc_direction.should eql value
      end

    end


    describe "#arc_start_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.0'
        @f.arc_start_angle = value
        @f.arc_start_angle.should eql value
      end

    end


    describe "#arc_stop_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '180.0'
        @f.arc_stop_angle = value
        @f.arc_stop_angle.should eql value
      end

    end


    describe "#arc_mu_degree=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9.1'
        @f.arc_mu_degree = value
        @f.arc_mu_degree.should eql value
      end

    end


    describe "#wedge=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '60'
        @f.wedge = value
        @f.wedge.should eql value
      end

    end


    describe "#dynamic_wedge=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Motorized'
        @f.dynamic_wedge = value
        @f.dynamic_wedge.should eql value
      end

    end


    describe "#block=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'A'
        @f.block = value
        @f.block.should eql value
      end

    end


    describe "#compensator=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'B'
        @f.compensator = value
        @f.compensator.should eql value
      end

    end


    describe "#e_applicator=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'C'
        @f.e_applicator = value
        @f.e_applicator.should eql value
      end

    end


    describe "#e_field_def_aperture=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'D'
        @f.e_field_def_aperture = value
        @f.e_field_def_aperture.should eql value
      end

    end


    describe "#bolus=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Custom'
        @f.bolus = value
        @f.bolus.should eql value
      end

    end


    describe "#portfilm_mu_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4'
        @f.portfilm_mu_open = value
        @f.portfilm_mu_open.should eql value
      end

    end


    describe "#portfilm_coeff_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.0'
        @f.portfilm_coeff_open = value
        @f.portfilm_coeff_open.should eql value
      end

    end


    describe "#portfilm_delta_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @f.portfilm_delta_open = value
        @f.portfilm_delta_open.should eql value
      end

    end


    describe "#portfilm_mu_treat=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '8'
        @f.portfilm_mu_treat = value
        @f.portfilm_mu_treat.should eql value
      end

    end


    describe "#portfilm_coeff_treat=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0.9'
        @f.portfilm_coeff_treat = value
        @f.portfilm_coeff_treat.should eql value
      end

    end

  end

end
