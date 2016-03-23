# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Field do

    before :example do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @f = Field.new(@p)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Field.load(42, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Prescription is passed as the 'parent' argument" do
        expect {Field.load('"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"', 'not-an-rx')}.to raise_error(/to_record/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","6830"'
        expect {Field.load(str, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","extra","8612"'
        f = Field.load(str, @p)
      end

      it "should create a Field object when given a valid string" do
        short = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","21083"'
        complete = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"'
        expect(Field.load(short, @p).class).to eql Field
        expect(Field.load(complete, @p).class).to eql Field
      end

      it "should set attributes from the given string" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"'
        f = Field.load(str, @p)
        expect(f.field_name).to eql '8 Bakfra'
        expect(f.collimator_y2).to eql '5.8'
      end

    end


    describe "::new" do

      it "should create a Field object" do
        expect(@f.class).to eql Field
      end

      it "should set the parent attribute" do
        expect(@f.parent).to eql @p
      end

      it "should set the default keyword attribute" do
        expect(@f.keyword).to eql "FIELD_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        ss = SiteSetup.new(@p)
        f = Field.new(ss)
        expect(f.parent).to eql @p
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        f_other = Field.new(@p)
        f_other.field_id = '33'
        @f.field_id = '33'
        expect(@f == f_other).to be_truthy
      end

      it "should be false when comparing two instances having the different attribute values" do
        f_other = Field.new(@p)
        f_other.field_id = '11'
        @f.field_id = '1'
        expect(@f == f_other).to be_falsey
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@f == 42).to be_falsey
      end

    end


    describe "#add_control_point" do

      it "should raise an error when a non-ControlPoint is passed as the 'child' argument" do
        expect {@f.add_control_point(42)}.to raise_error(/to_control_point/)
      end

      it "should add the control point" do
        f_other = Field.new(@p)
        cp = ControlPoint.new(f_other)
        @f.add_control_point(cp)
        expect(@f.control_points).to eql [cp]
      end

      it "should set self as the parent of an added control point" do
        f_other = Field.new(@p)
        cp = ControlPoint.new(f_other)
        @f.add_control_point(cp)
        expect(cp.parent).to equal @f
      end

    end


    describe "#add_extended_field" do

      it "should raise an error when a non-ExtendedField is passed as the 'child' argument" do
        expect {@f.add_extended_field(42)}.to raise_error(/to_extended_field/)
      end

      it "should add the extended field" do
        f_other = Field.new(@p)
        ef = ExtendedField.new(f_other)
        @f.add_extended_field(ef)
        expect(@f.extended_field).to eql ef
      end

      it "should set self as the parent of an added extended field" do
        f_other = Field.new(@p)
        ef = ExtendedField.new(f_other)
        @f.add_extended_field(ef)
        expect(ef.parent).to equal @f
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@f.children).to eql Array.new
      end

      it "should return a one-element array containing the Field's control point" do
        cp = ControlPoint.new(@f)
        expect(@f.children).to eql [cp]
      end

      it "should return a one-element array containing the Field's extended field" do
        ef = ExtendedField.new(@f)
        expect(@f.children).to eql [ef]
      end

      it "should return a three-element array containing the Field's extended field and two control points" do
        cp1 = ControlPoint.new(@f)
        cp2 = ControlPoint.new(@f)
        ef = ExtendedField.new(@f)
        expect(@f.children).to eql [ef, cp1, cp2]
      end

    end


    describe "#dcm_collimator_x1" do

      it "should return the processed collimator_x1 attribute of the control point" do
        value = -11.5
        @f.collimator_x1 = value
        @f.field_x_mode = 'SYM'
        expect(@f.dcm_collimator_x1).to eql value * 10
      end

      it "should return an inverted, negative value in the case of 'sym' field_x_mode and an original positive x1 value" do
        @f.collimator_x1 = 5.0
        @f.field_x_mode = 'SYM'
        expect(@f.dcm_collimator_x1).to eql -50.0
      end

      it "should return the original negative value in the case of 'sym' field_x_mode with an original negative x1 value" do
        @f.collimator_x1 = -5.0
        @f.field_x_mode = 'SYM'
        expect(@f.dcm_collimator_x1).to eql -50.0
      end

    end


    describe "#dcm_collimator_y1" do

      it "should return the processed collimator_y1 attribute of the control point" do
        value = -11.5
        @f.collimator_y1 = value
        @f.field_y_mode = 'SYM'
        expect(@f.dcm_collimator_y1).to eql value * 10
      end

      it "should return an inverted, negative value in the case of 'sym' field_y_mode and an original positive y1 value" do
        @f.collimator_y1 = 5.0
        @f.field_y_mode = 'SYM'
        expect(@f.dcm_collimator_y1).to eql -50.0
      end

      it "should return the original negative value in the case of 'sym' field_y_mode with an original negative y1 value" do
        @f.collimator_y1 = -5.0
        @f.field_y_mode = 'SYM'
        expect(@f.dcm_collimator_y1).to eql -50.0
      end

    end


    describe "#dcm_collimator_x2" do

      it "should return the processed collimator_x2 attribute of the control point" do
        value = 11.5
        @f.collimator_x2 = value
        @f.field_x_mode = 'SYM'
        expect(@f.dcm_collimator_x2).to eql value * 10
      end

    end


    describe "#dcm_collimator_y2" do

      it "should return the processed collimator_y2 attribute of the control point" do
        value = 11.5
        @f.collimator_y2 = value
        @f.field_y_mode = 'SYM'
        expect(@f.dcm_collimator_y2).to eql value * 10
      end

    end


    describe "#delete" do

      it "properly deletes a given control point instance" do
        cp = ControlPoint.new(@f)
        @f.add_control_point(cp)
        @f.delete(cp)
        expect(@f.control_points.include?(cp)).to be false
        expect(cp.parent).to be_nil
      end

      it "properly deletes a given extended field instance" do
        ef = ExtendedField.new(@f)
        @f.add_extended_field(ef)
        @f.delete_extended_field
        expect(@f.extended_field).to be_nil
        expect(ef.parent).to be_nil
      end

    end


    describe "#delete_control_points" do

      before :each do
        @cp1 = ControlPoint.new(@f)
        @cp2 = ControlPoint.new(@f)
        @f.add_control_point(@cp1)
        @f.add_control_point(@cp2)
        @f.delete_control_points
      end

      it "resets the control_points attribute" do
        expect(@f.control_points).to eql Array.new
      end

      it "resets the parent attribute of the previously referenced control_points" do
        [@cp1, @cp2].each do |cp|
          expect(cp.parent).to be_nil
        end
      end

    end


    describe "#delete_extended_field" do

      it "resets the extended_field attribute" do
        ef = ExtendedField.new(@f)
        @f.add_extended_field(ef)
        @f.delete_extended_field
        expect(@f.extended_field).to be_nil
      end

      it "resets the parent attribute of the previously referenced extended field" do
        ef = ExtendedField.new(@f)
        @f.add_extended_field(ef)
        @f.delete_extended_field
        expect(ef.parent).to be_nil
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        f_other = Field.new(@p)
        f_other.field_id = '1'
        @f.field_id = '1'
        expect(@f == f_other).to be_truthy
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"FIELD_DEF",' + Array.new(47){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        f1 = Field.load(str, @p)
        f2 = Field.load(str, @p)
        expect(f1.hash == f2.hash).to be_truthy
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["FIELD_DEF", [nil]*47].flatten
        expect(@f.values).to eql arr
      end

    end


    describe "#to_field" do

      it "should return itself" do
        expect(@f.to_field.equal?(@f)).to be_truthy
      end

    end


    describe "#to_s" do

      it "should return a string which matches the original string" do
        str = '"FIELD_DEF","STE:0-20:4","8 Bakfra","BAKFR","","400.00","348.248310","","ALX","Static","Xrays","15","","","100.0","96.3","180.0","0.0","ASY","0.0","-5.0","5.0","ASY","0.0","-7.1","5.8","","","","0.0","0.0","","","","","","","","","","","","","","","","","","24065"' + "\r\n"
        f = Field.load(str, @p)
        expect(f.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"FIELD_DEF",' + Array.new(47){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        f = Field.load(str, @p)
        expect(f.to_s).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'FIELD_DEF' is given as an argument" do
        expect {@f.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @f.keyword = 'FIELD_DEF'
        expect(@f.keyword).to eql 'FIELD_DEF'
      end

    end


    describe "#field_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Anterior'
        @f.field_name = value
        expect(@f.field_name).to eql value
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @f.field_id = value
        expect(@f.field_id).to eql value
      end

    end


    describe "#field_note=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'asymmetric'
        @f.field_note = value
        expect(@f.field_note).to eql value
      end

    end


    describe "#field_dose=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '50'
        @f.field_dose = value
        expect(@f.field_dose).to eql value
      end

    end


    describe "#field_monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '57'
        @f.field_monitor_units = value
        expect(@f.field_monitor_units).to eql value
      end

    end


    describe "#wedge_monitor_units=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '41'
        @f.wedge_monitor_units = value
        expect(@f.wedge_monitor_units).to eql value
      end

    end


    describe "#treatment_machine=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'AL01'
        @f.treatment_machine = value
        expect(@f.treatment_machine).to eql value
      end

    end


    describe "#treatment_type=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Static'
        @f.treatment_type = value
        expect(@f.treatment_type).to eql value
      end

    end


    describe "#modality=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Xrays'
        @f.modality = value
        expect(@f.modality).to eql value
      end

    end


    describe "#energy=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @f.energy = value
        expect(@f.energy).to eql value
      end

    end


    describe "#time=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @f.time = value
        expect(@f.time).to eql value
      end

    end


    describe "#doserate=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '300'
        @f.doserate = value
        expect(@f.doserate).to eql value
      end

    end


    describe "#sad=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '100.0'
        @f.sad = value
        expect(@f.sad).to eql value
      end

    end


    describe "#ssd=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '94.7'
        @f.ssd = value
        expect(@f.ssd).to eql value
      end

    end


    describe "#gantry_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '21'
        @f.gantry_angle = value
        expect(@f.gantry_angle).to eql value
      end

    end


    describe "#collimator_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '110'
        @f.collimator_angle = value
        expect(@f.collimator_angle).to eql value
      end

    end


    describe "#field_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Asym'
        @f.field_x_mode = value
        expect(@f.field_x_mode).to eql value
      end

    end


    describe "#field_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.7'
        @f.field_x = value
        expect(@f.field_x).to eql value
      end

    end


    describe "#collimator_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2.7'
        @f.collimator_x1 = value
        expect(@f.collimator_x1).to eql value
      end

    end


    describe "#collimator_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.0'
        @f.collimator_x2 = value
        expect(@f.collimator_x2).to eql value
      end

    end


    describe "#field_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Sym'
        @f.field_y_mode = value
        expect(@f.field_y_mode).to eql value
      end

    end


    describe "#field_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6.0'
        @f.field_y = value
        expect(@f.field_y).to eql value
      end

    end


    describe "#collimator_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3.0'
        @f.collimator_y1 = value
        expect(@f.collimator_y1).to eql value
      end

    end


    describe "#collimator_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3.0'
        @f.collimator_y2 = value
        expect(@f.collimator_y2).to eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '13.7'
        @f.couch_vertical = value
        expect(@f.couch_vertical).to eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-4.7'
        @f.couch_lateral = value
        expect(@f.couch_lateral).to eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '61.7'
        @f.couch_longitudinal = value
        expect(@f.couch_longitudinal).to eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @f.couch_angle = value
        expect(@f.couch_angle).to eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6'
        @f.couch_pedestal = value
        expect(@f.couch_pedestal).to eql value
      end

    end


    describe "#tolerance_table=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @f.tolerance_table = value
        expect(@f.tolerance_table).to eql value
      end

    end


    describe "#arc_direction=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'CW'
        @f.arc_direction = value
        expect(@f.arc_direction).to eql value
      end

    end


    describe "#arc_start_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.0'
        @f.arc_start_angle = value
        expect(@f.arc_start_angle).to eql value
      end

    end


    describe "#arc_stop_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '180.0'
        @f.arc_stop_angle = value
        expect(@f.arc_stop_angle).to eql value
      end

    end


    describe "#arc_mu_degree=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9.1'
        @f.arc_mu_degree = value
        expect(@f.arc_mu_degree).to eql value
      end

    end


    describe "#wedge=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '60'
        @f.wedge = value
        expect(@f.wedge).to eql value
      end

    end


    describe "#dynamic_wedge=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Motorized'
        @f.dynamic_wedge = value
        expect(@f.dynamic_wedge).to eql value
      end

    end


    describe "#block=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'A'
        @f.block = value
        expect(@f.block).to eql value
      end

    end


    describe "#compensator=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'B'
        @f.compensator = value
        expect(@f.compensator).to eql value
      end

    end


    describe "#e_applicator=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'C'
        @f.e_applicator = value
        expect(@f.e_applicator).to eql value
      end

    end


    describe "#e_field_def_aperture=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'D'
        @f.e_field_def_aperture = value
        expect(@f.e_field_def_aperture).to eql value
      end

    end


    describe "#bolus=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Custom'
        @f.bolus = value
        expect(@f.bolus).to eql value
      end

    end


    describe "#portfilm_mu_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4'
        @f.portfilm_mu_open = value
        expect(@f.portfilm_mu_open).to eql value
      end

    end


    describe "#portfilm_coeff_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.0'
        @f.portfilm_coeff_open = value
        expect(@f.portfilm_coeff_open).to eql value
      end

    end


    describe "#portfilm_delta_open=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @f.portfilm_delta_open = value
        expect(@f.portfilm_delta_open).to eql value
      end

    end


    describe "#portfilm_mu_treat=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '8'
        @f.portfilm_mu_treat = value
        expect(@f.portfilm_mu_treat).to eql value
      end

    end


    describe "#portfilm_coeff_treat=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0.9'
        @f.portfilm_coeff_treat = value
        expect(@f.portfilm_coeff_treat).to eql value
      end

    end

  end

end
