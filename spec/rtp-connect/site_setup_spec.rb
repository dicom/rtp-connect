# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe SiteSetup do

    before :each do
      @rtp = Plan.new
      @p = Prescription.new(@rtp)
      @ss = SiteSetup.new(@p)
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {SiteSetup.load(42, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an error when a non-Prescription is passed as the 'parent' argument" do
        expect {SiteSetup.load('"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"', 'not-an-rx')}.to raise_error
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","30017"'
        expect {SiteSetup.load(str, @p)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","extra","26790"'
        ss = SiteSetup.load(str, @p)
      end

      it "should create a SiteSetup object when given a valid string" do
        short = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","26934"'
        complete = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"'
        SiteSetup.load(short, @p).class.should eql SiteSetup
        SiteSetup.load(complete, @p).class.should eql SiteSetup
      end

      it "should set attributes from the given string" do
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"'
        ss = SiteSetup.load(str, @p)
        ss.patient_orientation.should eql 'HFS'
        ss.frame_of_ref_uid.should eql '1.2.840.3'
      end

    end


    describe "::new" do

      it "should create a SiteSetup object" do
        @ss.class.should eql SiteSetup
      end

      it "should set the parent attribute" do
        @ss.parent.should eql @p
      end

      it "should set the default keyword attribute" do
        @ss.keyword.should eql "SITE_SETUP_DEF"
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'PROST'
        @ss.rx_site_name = 'PROST'
        (@ss == ss_other).should be_true
      end

      it "should be false when comparing two instances having the different attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'PROST'
        @ss.rx_site_name = 'MAM'
        (@ss == ss_other).should be_false
      end

      it "should be false when comparing against an instance of incompatible type" do
        (@ss == 42).should be_false
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @ss.children.should eql Array.new
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'MAM'
        @ss.rx_site_name = 'MAM'
        (@ss == ss_other).should be_true
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"SITE_SETUP_DEF",' + Array.new(14){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ss1 = SiteSetup.load(str, @p)
        ss2 = SiteSetup.load(str, @p)
        (ss1.hash == ss2.hash).should be_true
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["SITE_SETUP_DEF", [nil]*14].flatten
        @ss.values.should eql arr
      end

    end


    describe "to_s" do

      it "should return a string which matches the original string" do
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"' + "\r\n"
        ss = SiteSetup.load(str, @p)
        ss.to_s.should eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"SITE_SETUP_DEF",' + Array.new(14){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ss = SiteSetup.load(str, @p)
        ss.to_s.should eql str
      end

    end


    context "#to_site_setup" do

      it "should return itself" do
        @ss.to_site_setup.equal?(@ss).should be_true
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'SITE_SETUP_DEF' is given as an argument" do
        expect {@ss.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @ss.keyword = 'SITE_SETUP_DEF'
        @ss.keyword.should eql 'SITE_SETUP_DEF'
      end

    end


    describe "#rx_site_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Prostate'
        @ss.rx_site_name = value
        @ss.rx_site_name.should eql value
      end

    end


    describe "#patient_orientation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'HFS'
        @ss.patient_orientation = value
        @ss.patient_orientation.should eql value
      end

    end


    describe "#treatment_machine=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'AL01'
        @ss.treatment_machine = value
        @ss.treatment_machine.should eql value
      end

    end


    describe "#tolerance_table=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @ss.tolerance_table = value
        @ss.tolerance_table.should eql value
      end

    end


    describe "#iso_pos_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '5'
        @ss.iso_pos_x = value
        @ss.iso_pos_x.should eql value
      end

    end


    describe "#iso_pos_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @ss.iso_pos_y = value
        @ss.iso_pos_y.should eql value
      end

    end


    describe "#iso_pos_z=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9'
        @ss.iso_pos_z = value
        @ss.iso_pos_z.should eql value
      end

    end


    describe "#structure_set_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.234.5'
        @ss.structure_set_uid = value
        @ss.structure_set_uid.should eql value
      end

    end


    describe "#frame_of_ref_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.567.8'
        @ss.frame_of_ref_uid = value
        @ss.frame_of_ref_uid.should eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3'
        @ss.couch_vertical = value
        @ss.couch_vertical.should eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-1'
        @ss.couch_lateral = value
        @ss.couch_lateral.should eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-6'
        @ss.couch_longitudinal = value
        @ss.couch_longitudinal.should eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '10'
        @ss.couch_angle = value
        @ss.couch_angle.should eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @ss.couch_pedestal = value
        @ss.couch_pedestal.should eql value
      end

    end

  end

end
