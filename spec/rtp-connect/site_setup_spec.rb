# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe SiteSetup do

    before :example do
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
        str = '"SITE_SETUP_DEF","test","HFS","SB3","","2.78","7.66","-7.25","1.3.6.1","1.2.840","","","","","","-3.0","-3.0","-3.0","extra","6386"'
        ss = SiteSetup.load(str, @p)
      end

      it "should create a SiteSetup object when given a valid string" do
        short = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","26934"'
        complete = '"SITE_SETUP_DEF","test","HFS","SB3","","2.78","7.66","-7.25","1.3.6.1","1.2.840","","","","","","-3.0","-3.0","-3.0","47438"'
        expect(SiteSetup.load(short, @p).class).to eql SiteSetup
        expect(SiteSetup.load(complete, @p).class).to eql SiteSetup
      end

      it "should set attributes from the given string" do
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"'
        ss = SiteSetup.load(str, @p)
        expect(ss.patient_orientation).to eql 'HFS'
        expect(ss.frame_of_ref_uid).to eql '1.2.840.3'
      end

      it "properly sets the crc and missing attributes when given a string which doesn't contain all optional attributes" do
        str = '"SITE_SETUP_DEF","STE:0-20:4","HFS","ALX","","-0.38","14.10","-12.50","1.3.6.1","1.2.840.3","","","","","","24183"'
        ss = SiteSetup.load(str, @p)
        expect(ss.crc).to eql '24183' # note that when re-encoded, this crc will be different
        expect(ss.table_top_vert_displacement).to be_nil
        expect(ss.table_top_long_displacement).to be_nil
        expect(ss.table_top_lat_displacement).to be_nil
      end

    end


    describe "::new" do

      it "should create a SiteSetup object" do
        expect(@ss.class).to eql SiteSetup
      end

      it "should set the parent attribute" do
        expect(@ss.parent).to eql @p
      end

      it "should set the default keyword attribute" do
        expect(@ss.keyword).to eql "SITE_SETUP_DEF"
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'PROST'
        @ss.rx_site_name = 'PROST'
        expect(@ss == ss_other).to be_truthy
      end

      it "should be false when comparing two instances having the different attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'PROST'
        @ss.rx_site_name = 'MAM'
        expect(@ss == ss_other).to be_falsey
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@ss == 42).to be_falsey
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@ss.children).to eql Array.new
      end

    end


    describe "#encode" do

      it "returns 19 attributes (including CRC) when a version of 2.6 is specified" do
        expect(@ss.encode(version: 2.6).values.length).to eql 19
      end

      it "returns 16 attributes (including CRC) when a version of 2.5 is specified" do
        expect(@ss.encode(version: 2.5).values.length).to eql 16
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        ss_other = SiteSetup.new(@p)
        ss_other.rx_site_name = 'MAM'
        @ss.rx_site_name = 'MAM'
        expect(@ss == ss_other).to be_truthy
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"SITE_SETUP_DEF",' + Array.new(14){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ss1 = SiteSetup.load(str, @p)
        ss2 = SiteSetup.load(str, @p)
        expect(ss1.hash == ss2.hash).to be_truthy
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["SITE_SETUP_DEF", [nil]*17].flatten
        expect(@ss.values).to eql arr
      end

    end


    describe "#to_s" do

      it "should return a string which matches the original string" do
        str = '"SITE_SETUP_DEF","test","HFS","SB3","","2.78","7.66","-7.25","1.3.6.1","1.2.840","","","","","","-3.0","-3.0","-3.0","47438"' + "\r\n"
        ss = SiteSetup.load(str, @p)
        expect(ss.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"SITE_SETUP_DEF",' + Array.new(17){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        ss = SiteSetup.load(str, @p)
        expect(ss.to_s).to eql str
      end

    end


    describe "#to_site_setup" do

      it "should return itself" do
        expect(@ss.to_site_setup.equal?(@ss)).to be_truthy
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'SITE_SETUP_DEF' is given as an argument" do
        expect {@ss.keyword=('RX_DEF')}.to raise_error(ArgumentError, /keyword/)
        @ss.keyword = 'SITE_SETUP_DEF'
        expect(@ss.keyword).to eql 'SITE_SETUP_DEF'
      end

    end


    describe "#rx_site_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Prostate'
        @ss.rx_site_name = value
        expect(@ss.rx_site_name).to eql value
      end

    end


    describe "#patient_orientation=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'HFS'
        @ss.patient_orientation = value
        expect(@ss.patient_orientation).to eql value
      end

    end


    describe "#treatment_machine=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'AL01'
        @ss.treatment_machine = value
        expect(@ss.treatment_machine).to eql value
      end

    end


    describe "#tolerance_table=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @ss.tolerance_table = value
        expect(@ss.tolerance_table).to eql value
      end

    end


    describe "#iso_pos_x=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '5'
        @ss.iso_pos_x = value
        expect(@ss.iso_pos_x).to eql value
      end

    end


    describe "#iso_pos_y=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7'
        @ss.iso_pos_y = value
        expect(@ss.iso_pos_y).to eql value
      end

    end


    describe "#iso_pos_z=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '9'
        @ss.iso_pos_z = value
        expect(@ss.iso_pos_z).to eql value
      end

    end


    describe "#structure_set_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.234.5'
        @ss.structure_set_uid = value
        expect(@ss.structure_set_uid).to eql value
      end

    end


    describe "#frame_of_ref_uid=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1.567.8'
        @ss.frame_of_ref_uid = value
        expect(@ss.frame_of_ref_uid).to eql value
      end

    end


    describe "#couch_vertical=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-3'
        @ss.couch_vertical = value
        expect(@ss.couch_vertical).to eql value
      end

    end


    describe "#couch_lateral=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-1'
        @ss.couch_lateral = value
        expect(@ss.couch_lateral).to eql value
      end

    end


    describe "#couch_longitudinal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-6'
        @ss.couch_longitudinal = value
        expect(@ss.couch_longitudinal).to eql value
      end

    end


    describe "#couch_angle=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '10'
        @ss.couch_angle = value
        expect(@ss.couch_angle).to eql value
      end

    end


    describe "#couch_pedestal=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '15'
        @ss.couch_pedestal = value
        expect(@ss.couch_pedestal).to eql value
      end

    end


    describe "#table_top_vert_displacement=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-2'
        @ss.table_top_vert_displacement = value
        expect(@ss.table_top_vert_displacement).to eql value
      end

    end


    describe "#table_top_long_displacement=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '-0.6'
        @ss.table_top_long_displacement = value
        expect(@ss.table_top_long_displacement).to eql value
      end

    end


    describe "#table_top_lat_displacement=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '7.3'
        @ss.table_top_lat_displacement = value
        expect(@ss.table_top_lat_displacement).to eql value
      end

    end

  end

end
