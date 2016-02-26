# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Plan do

    before :example do
      @rtp = Plan.new
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Plan.load(42)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","29106"'
        expect {Plan.load(str)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should give a warning when a string with too many values is passed as the 'string' argument" do
        RTP.logger.expects(:warn).once
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","extra","19010"'
        p = Plan.load(str)
      end

      it "should create a Plan object when given a valid string" do
        short = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","60364"'
        complete = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","61220"'
        expect(Plan.load(short).class).to eql Plan
        expect(Plan.load(complete).class).to eql Plan
      end

      it "should set attributes from the given string" do
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","61220"'
        p = Plan.load(str)
        expect(p.patient_id).to eql '12345'
        expect(p.rtp_if_version).to eql '2.20.08D7'
      end

    end


    describe "::parse" do

      it "should raise an error when a non-String is passed as the 'string' argument" do
        expect {Plan.parse(42)}.to raise_error(ArgumentError)
      end

      it "should raise an ArgumentError when an invalid RTP string is passed as the 'string' argument" do
        str = '"Not a valid RTP", "file", "42"' + "\r\n"
        expect {Plan.parse(str)}.to raise_error(ArgumentError)
      end

      it "should create a Plan object when given a valid RTP file string" do
        str = File.open(RTP_COLUMNA, "rb") { |f| f.read }
        expect(Plan.parse(str).class).to eql Plan
      end

      it "should set attributes from the given file" do
        str = File.open(RTP_COLUMNA, "rb") { |f| f.read }
        p = Plan.parse(str)
        expect(p.plan_id).to eql 'STE:0-20:4'
        expect(p.rtp_version).to eql 'OTP V4.1.0'
      end

      it "should successfully parse and load the RTP records in spite of an invalid CRC when the :ignore_crc option is used" do
        str = File.open(RTP_INVALID_CRC, "rb") { |f| f.read }
        p = Plan.parse(str, ignore_crc: true)
        expect(p.patient_last_name).to eql 'Doe'
        expect(p.prescriptions.first.rx_site_name).to eql 'Test'
      end

    end


    describe "::read" do

      it "should raise an ArgumentError when a non-String is passed as the 'file' argument" do
        expect {Plan.read(42)}.to raise_error(ArgumentError, /'file'/)
      end

      it "should raise an ArgumentError when a non-RTP file is passed as the 'file' argument" do
        str = '"Not a valid RTP", "file", "42"'
        file = TMPDIR + 'invalid.rtp'
        File.open(file, 'w') {|f| f.write(str) }
        expect {Plan.read(file)}.to raise_error(ArgumentError)
      end

      it "should create a Plan object when given a valid RTP file" do
        expect(Plan.read(RTP_COLUMNA).class).to eql Plan
      end

      it "should set attributes from the given file" do
        p = Plan.read(RTP_COLUMNA)
        expect(p.patient_last_name).to eql 'ALDERSON'
        expect(p.rtp_if_protocol).to eql 'IMPAC_DCM_SCP'
      end

      it "should successfully read and load the RTP records in spite of an invalid CRC when the :ignore_crc option is used" do
        p = Plan.read(RTP_INVALID_CRC, ignore_crc: true)
        expect(p.patient_last_name).to eql 'Doe'
        expect(p.prescriptions.first.rx_site_name).to eql 'Test'
      end

    end


    describe "::new" do

      it "should create a Plan object" do
        expect(@rtp.class).to eql Plan
      end

      it "should set the parent attribute as nil" do
        expect(@rtp.parent).to be_nil
      end

      it "should by default set the prescriptions attribute as an empty array" do
        expect(@rtp.prescriptions).to eql Array.new
      end

      it "should set the default keyword attribute" do
        expect(@rtp.keyword).to eql "PLAN_DEF"
      end

    end


    describe "#==()" do

      it "should be true when comparing two instances having the same attribute values" do
        rtp_other = Plan.new
        rtp_other.patient_id = '123'
        @rtp.patient_id = '123'
        expect(@rtp == rtp_other).to be_truthy
      end

      it "should be false when comparing two instances having the different attribute values" do
        rtp_other = Plan.new
        rtp_other.patient_id = '123'
        @rtp.patient_id = '456'
        expect(@rtp == rtp_other).to be_falsey
      end

      it "should be false when comparing against an instance of incompatible type" do
        expect(@rtp == 42).to be_falsey
      end

    end


    describe "#add_prescription" do

      it "should raise an error when a non-Prescription is passed as the 'child' argument" do
        expect {@rtp.add_prescription(42)}.to raise_error(/to_prescription/)
      end

      it "should add the prescription" do
        r = Plan.new
        p = Prescription.new(r)
        @rtp.add_prescription(p)
        expect(@rtp.prescriptions).to eql [p]
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        expect(@rtp.children).to eql Array.new
      end

      it "should return a one-element array containing the Plan's prescription" do
        p = Prescription.new(@rtp)
        expect(@rtp.children).to eql [p]
      end

      it "should return a two-element array containing the Plan's prescriptions" do
        p1 = Prescription.new(@rtp)
        p2 = Prescription.new(@rtp)
        expect(@rtp.children).to eql [p1, p2]
      end

    end


    describe "#eql?" do

      it "should be true when comparing two instances having the same attribute values" do
        rtp_other = Plan.new
        rtp_other.patient_last_name = 'John'
        @rtp.patient_last_name = 'John'
        expect(@rtp == rtp_other).to be_truthy
      end

    end


    describe "#hash" do

      it "should return the same Fixnum for two instances having the same attribute values" do
        values = '"PLAN_DEF",' + Array.new(26){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        rtp1 = Plan.load(str)
        rtp2 = Plan.load(str)
        expect(rtp1.hash == rtp2.hash).to be_truthy
      end

    end


    describe "#to_plan" do

      it "should return itself" do
        expect(@rtp.to_plan.equal?(@rtp)).to be_truthy
      end

    end


    describe "#to_rtp" do

      it "should return itself" do
        expect(@rtp.to_rtp.equal?(@rtp)).to be_truthy
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["PLAN_DEF", [nil]*26].flatten
        expect(@rtp.values).to eql arr
      end

    end


    describe "#to_s" do

      it "should return a string which matches the original string" do
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","61220"' + "\r\n"
        p = Plan.load(str)
        expect(p.to_s).to eql str
      end

      it "should return a string that matches the original string (which contains a unique value for each element)" do
        values = '"PLAN_DEF",' + Array.new(26){|i| i.to_s}.encode + ','
        crc = values.checksum.to_s.wrap
        str = values + crc + "\r\n"
        p = Plan.load(str)
        expect(p.to_s).to eql str
      end

      it "should properly handle attributes with double quote-characters to ensure that it doesn't output an invalid CSV string" do
        str = 'John "RTP" Oscar'
        p = Plan.new
        p.patient_first_name = str
        reloaded = Plan.parse(p.to_s)
        expect(p.patient_first_name).to eql str
      end

      it "returns a string including the EXTENDED_PLAN_DEF record when a version of 2.5 is specified" do
        p = Plan.new
        ep = ExtendedPlan.new(p)
        expect(p.to_s(version: 2.5).include?('EXTENDED_PLAN_DEF')).to be true
      end

      it "returns a string which does not include the EXTENDED_PLAN_DEF record when a version of 2.4 is specified" do
        p = Plan.new
        ep = ExtendedPlan.new(p)
        expect(p.to_s(version: 2.4).include?('EXTENDED_PLAN_DEF')).to be false
      end

    end


    describe "#write" do

      it "should write the Plan object to file" do
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","61220"' + "\r\n"
        plan = Plan.load(str)
        file = TMPDIR + 'plan.rtp'
        plan.write(file)
        p = Plan.read(file)
        expect(p.to_str).to eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'PLAN_DEF' is given as an argument" do
        expect {@rtp.keyword=('SITE_DEF')}.to raise_error(ArgumentError, /keyword/)
        @rtp.keyword = 'PLAN_DEF'
        expect(@rtp.keyword).to eql 'PLAN_DEF'
      end

    end


    describe "#patient_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @rtp.patient_id = value
        expect(@rtp.patient_id).to eql value
      end

    end


    describe "#patient_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Andy'
        @rtp.patient_last_name = value
        expect(@rtp.patient_last_name).to eql value
      end

    end


    describe "#patient_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Back'
        @rtp.patient_first_name = value
        expect(@rtp.patient_first_name).to eql value
      end

    end


    describe "#patient_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'C'
        @rtp.patient_middle_initial = value
        expect(@rtp.patient_middle_initial).to eql value
      end

    end


    describe "#plan_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @rtp.plan_id = value
        expect(@rtp.plan_id).to eql value
      end

    end


    describe "#plan_date=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '20111123'
        @rtp.plan_date = value
        expect(@rtp.plan_date).to eql value
      end

    end


    describe "#plan_time=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '150457'
        @rtp.plan_time = value
        expect(@rtp.plan_time).to eql value
      end

    end


    describe "#course_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @rtp.course_id = value
        expect(@rtp.course_id).to eql value
      end

    end


    describe "#diagnosis=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'D'
        @rtp.diagnosis = value
        expect(@rtp.diagnosis).to eql value
      end

    end


    describe "#md_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Doc'
        @rtp.md_last_name = value
        expect(@rtp.md_last_name).to eql value
      end

    end


    describe "#md_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Dr'
        @rtp.md_first_name = value
        expect(@rtp.md_first_name).to eql value
      end

    end


    describe "#md_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'E'
        @rtp.md_middle_initial = value
        expect(@rtp.md_middle_initial).to eql value
      end

    end


    describe "#md_approve_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Approver'
        @rtp.md_approve_last_name = value
        expect(@rtp.md_approve_last_name).to eql value
      end

    end


    describe "#md_approve_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Mr'
        @rtp.md_approve_first_name = value
        expect(@rtp.md_approve_first_name).to eql value
      end

    end


    describe "#md_approve_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'F'
        @rtp.md_approve_middle_initial = value
        expect(@rtp.md_approve_middle_initial).to eql value
      end

    end


    describe "#phy_approve_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Phys'
        @rtp.phy_approve_last_name = value
        expect(@rtp.phy_approve_last_name).to eql value
      end

    end


    describe "#phy_approve_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Ph'
        @rtp.phy_approve_first_name = value
        expect(@rtp.phy_approve_first_name).to eql value
      end

    end


    describe "#phy_approve_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'G'
        @rtp.phy_approve_middle_initial = value
        expect(@rtp.phy_approve_middle_initial).to eql value
      end

    end


    describe "#author_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Author'
        @rtp.author_last_name = value
        expect(@rtp.author_last_name).to eql value
      end

    end


    describe "#author_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Aut'
        @rtp.author_first_name = value
        expect(@rtp.author_first_name).to eql value
      end

    end


    describe "#author_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'H'
        @rtp.author_middle_initial = value
        expect(@rtp.author_middle_initial).to eql value
      end

    end


    describe "#rtp_mfg=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Manu'
        @rtp.rtp_mfg = value
        expect(@rtp.rtp_mfg).to eql value
      end

    end


    describe "#rtp_model=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'model'
        @rtp.rtp_model = value
        expect(@rtp.rtp_model).to eql value
      end

    end


    describe "#rtp_version=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'version'
        @rtp.rtp_version = value
        expect(@rtp.rtp_version).to eql value
      end

    end


    describe "#rtp_if_protocol=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'prot'
        @rtp.rtp_if_protocol = value
        expect(@rtp.rtp_if_protocol).to eql value
      end

    end


    describe "#rtp_if_version=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'ifver'
        @rtp.rtp_if_version = value
        expect(@rtp.rtp_if_version).to eql value
      end

    end

  end

end
