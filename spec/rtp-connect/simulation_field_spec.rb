# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe SimulationField do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @sf = SimulationField.new(@p)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {SimulationField.load(42, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Prescription is passed as the 'parent' argument" do
        expect {SimulationField.load(str = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","","1.1","1.2","","1.3","1.4","","1.5","1.6","","1.7","1.8","","1.9","2.1","2.2","","2.3","2.4","2.5","2.6","2.7","2.8","3","4","5.5","18120"', 'not-an-rx')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","9132"'
        expect {SimulationField.load(str, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","","1.1","1.2","","1.3","1.4","","1.5","1.6","","1.7","1.8","","1.9","2.1","2.2","","2.3","2.4","2.5","2.6","2.7","2.8","3","4","5.5","extra","23925"'
        sf = SimulationField.load(str, @p)
      end

      it "should create a SimulationField object when given a valid string" do
        short = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9132"'
        complete = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","","1.1","1.2","","1.3","1.4","","1.5","1.6","","1.7","1.8","","1.9","2.1","2.2","","2.3","2.4","2.5","2.6","2.7","2.8","3","4","5.5","18120"'
        expect(SimulationField.load(short, @p).class).to eql SimulationField
        expect(SimulationField.load(complete, @p).class).to eql SimulationField
      end

      it "should set attributes from the given string" do
        str = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","","1.1","1.2","","1.3","1.4","","1.5","1.6","","1.7","1.8","","1.9","2.1","2.2","","2.3","2.4","2.5","2.6","2.7","2.8","3","4","5.5","18120"'
        sf = SimulationField.load(str, @p)
        expect(sf.field_name).to eql 'L2-L4'
        expect(sf.treatment_machine).to eql 'CT Sim'
      end

    end


    describe "::new" do

      it "should create a SimulationField object" do
        expect(@sf.class).to eql SimulationField
      end

      it "should set the parent attribute" do
        expect(@sf.parent).to eql @p
      end

      it "should set the default keyword attribute" do
        expect(@sf.keyword).to eql "SIM_DEF"
      end

      it "should determine the proper parent when given a lower level record in the hiearchy of records" do
        ss = SiteSetup.new(@p)
        sf = SimulationField.new(ss)
        expect(sf.parent).to eql @p
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        sf_other = SimulationField.new(@p)
        sf_other.field_id = '33'
        @sf.field_id = '33'
        expect(@sf == sf_other).to be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        sf_other = SimulationField.new(@p)
        sf_other.field_id = '11'
        @sf.field_id = '1'
        expect(@sf == sf_other).to be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@f == 42).to be_false
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@sf.children).to eql Array.new
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        sf_other = SimulationField.new(@p)
        sf_other.field_id = '1'
        @sf.field_id = '1'
        expect(@sf == sf_other).to be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"SIM_DEF",' + Array.new(51){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        sf1 = SimulationField.load(str, @p)
        sf2 = SimulationField.load(str, @p)
        expect(sf1.hash == sf2.hash).to be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["SIM_DEF", [nil]*51].flatten
        expect(@sf.values).to eql arr
      end

    end


    context "#to_simulation_field" do

      it "should return itself" do
        expect(@sf.to_simulation_field.equal?(@sf)).to be_true
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"SIM_DEF","SPINE","L2-L4","B","PRONE","CT Sim","1.0","2.0","Sym","3.0","4.0","5.0","Sym","6.0","7.0","8.0","9.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","","1.1","1.2","","1.3","1.4","","1.5","1.6","","1.7","1.8","","1.9","2.1","2.2","","2.3","2.4","2.5","2.6","2.7","2.8","3","4","5.5","18120"' + "\r\n"
        sf = SimulationField.load(str, @p)
        expect(sf.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"SIM_DEF",' + Array.new(51){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        sf = SimulationField.load(str, @p)
        expect(sf.to_s).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'SIM_DEF' is given as an argument" do
        expect {@sf.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @sf.keyword = 'SIM_DEF'
        expect(@sf.keyword).to eql 'SIM_DEF'
      end

    end


    describe "#field_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Anterior'
        @sf.field_name = value
        expect(@sf.field_name).to eql value
      end

    end


    describe "#field_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @sf.field_id = value
        expect(@sf.field_id).to eql value
      end

    end


    describe "#treatment_machine=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'AL01'
        @sf.treatment_machine = value
        expect(@sf.treatment_machine).to eql value
      end

    end


    describe "#gantry_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '21'
        @sf.gantry_angle = value
        expect(@sf.gantry_angle).to eql value
      end

    end


    describe "#collimator_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '110'
        @sf.collimator_angle = value
        expect(@sf.collimator_angle).to eql value
      end

    end


    describe "#field_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Asym'
        @sf.field_x_mode = value
        expect(@sf.field_x_mode).to eql value
      end

    end


    describe "#field_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.7'
        @sf.field_x = value
        expect(@sf.field_x).to eql value
      end

    end


    describe "#collimator_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2.7'
        @sf.collimator_x1 = value
        expect(@sf.collimator_x1).to eql value
      end

    end


    describe "#collimator_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2.0'
        @sf.collimator_x2 = value
        expect(@sf.collimator_x2).to eql value
      end

    end


    describe "#field_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Sym'
        @sf.field_y_mode = value
        expect(@sf.field_y_mode).to eql value
      end

    end


    describe "#field_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6.0'
        @sf.field_y = value
        expect(@sf.field_y).to eql value
      end

    end


    describe "#collimator_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3.0'
        @sf.collimator_y1 = value
        expect(@sf.collimator_y1).to eql value
      end

    end


    describe "#collimator_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3.0'
        @sf.collimator_y2 = value
        expect(@sf.collimator_y2).to eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '13.7'
        @sf.couch_vertical = value
        expect(@sf.couch_vertical).to eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-4.7'
        @sf.couch_lateral = value
        expect(@sf.couch_lateral).to eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '61.7'
        @sf.couch_longitudinal = value
        expect(@sf.couch_longitudinal).to eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @sf.couch_angle = value
        expect(@sf.couch_angle).to eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6'
        @sf.couch_pedestal = value
        expect(@sf.couch_pedestal).to eql value
      end

    end


    describe "#sad=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '103'
        @sf.sad = value
        expect(@sf.sad).to eql value
      end

    end


    describe "#ap_separation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @sf.ap_separation = value
        expect(@sf.ap_separation).to eql value
      end

    end


    describe "#pa_separation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.0'
        @sf.pa_separation = value
        expect(@sf.pa_separation).to eql value
      end

    end


    describe "#lateral_separation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '18'
        @sf.lateral_separation = value
        expect(@sf.lateral_separation).to eql value
      end

    end


    describe "#tangential_separation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9.1'
        @sf.tangential_separation = value
        expect(@sf.tangential_separation).to eql value
      end

    end


    describe "#other_label_1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '60'
        @sf.other_label_1 = value
        expect(@sf.other_label_1).to eql value
      end

    end


    describe "#ssd_1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '97'
        @sf.ssd_1 = value
        expect(@sf.ssd_1).to eql value
      end

    end


    describe "#sfd_1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '99'
        @sf.sfd_1 = value
        expect(@sf.sfd_1).to eql value
      end

    end


    describe "#other_label_2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'B'
        @sf.other_label_2 = value
        expect(@sf.other_label_2).to eql value
      end

    end


    describe "#other_measurement_1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @sf.other_measurement_1 = value
        expect(@sf.other_measurement_1).to eql value
      end

    end


    describe "#other_measurement_2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.4'
        @sf.other_measurement_2 = value
        expect(@sf.other_measurement_2).to eql value
      end

    end


    describe "#other_label_3=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Custom'
        @sf.other_label_3 = value
        expect(@sf.other_label_3).to eql value
      end

    end


    describe "#other_measurement_3=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6'
        @sf.other_measurement_3 = value
        expect(@sf.other_measurement_3).to eql value
      end

    end


    describe "#other_measurement_4=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.0'
        @sf.other_measurement_4 = value
        expect(@sf.other_measurement_4).to eql value
      end

    end


    describe "#other_label_4=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'PC'
        @sf.other_label_4 = value
        expect(@sf.other_label_4).to eql value
      end

    end


    describe "#other_measurement_5=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '8'
        @sf.other_measurement_5 = value
        expect(@sf.other_measurement_5).to eql value
      end

    end


    describe "#other_measurement_6=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0.9'
        @sf.other_measurement_6 = value
        expect(@sf.other_measurement_6).to eql value
      end

    end


    describe "#blade_x_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Y'
        @sf.blade_x_mode = value
        expect(@sf.blade_x_mode).to eql value
      end

    end


    describe "#blade_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.9'
        @sf.blade_x = value
        expect(@sf.blade_x).to eql value
      end

    end


    describe "#blade_x1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.3'
        @sf.blade_x1 = value
        expect(@sf.blade_x1).to eql value
      end

    end


    describe "#blade_x2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6.6'
        @sf.blade_x2 = value
        expect(@sf.blade_x2).to eql value
      end

    end


    describe "#blade_y_mode=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'N'
        @sf.blade_y_mode = value
        expect(@sf.blade_y_mode).to eql value
      end

    end


    describe "#blade_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '8.8'
        @sf.blade_y = value
        expect(@sf.blade_y).to eql value
      end

    end


    describe "#blade_y1=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '5.5'
        @sf.blade_y1 = value
        expect(@sf.blade_y1).to eql value
      end

    end


    describe "#blade_y2=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '6.6'
        @sf.blade_y2 = value
        expect(@sf.blade_y2).to eql value
      end

    end


    describe "#ii_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '0.6'
        @sf.ii_lateral = value
        expect(@sf.ii_lateral).to eql value
      end

    end


    describe "#ii_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3.2'
        @sf.ii_longitudinal = value
        expect(@sf.ii_longitudinal).to eql value
      end

    end


    describe "#ii_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '4.7'
        @sf.ii_vertical = value
        expect(@sf.ii_vertical).to eql value
      end

    end


    describe "#kvp=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '120'
        @sf.kvp = value
        expect(@sf.kvp).to eql value
      end

    end


    describe "#ma=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @sf.ma = value
        expect(@sf.ma).to eql value
      end

    end


    describe "#seconds=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '12'
        @sf.seconds = value
        expect(@sf.seconds).to eql value
      end

    end

  end

end
