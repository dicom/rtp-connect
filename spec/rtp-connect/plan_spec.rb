# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Plan do

    before :each do
      @rtp = Plan.new
    end

    describe "::load" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Plan.load(42)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when a string with too few values is passed as the 'string' argument" do
        str = '"PLAN_DEF","091111 12345","ALDERSON","TANGMAM ÅLESUND","51870"'
        expect {Plan.load(str)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should create a Plan object when given a valid string" do
        str = '"PLAN_DEF","091111 12345","ALDERSON","TANGMAM ÅLESUND","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","51870"'
        Plan.load(str).class.should eql Plan
      end

      it "should set attributes from the given string" do
        str = '"PLAN_DEF","091111 12345","ALDERSON","TANGMAM ÅLESUND","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","51870"'
        p = Plan.load(str)
        p.patient_id.should eql '091111 12345'
        p.rtp_if_version.should eql '2.20.08D7'
      end

    end


    describe "::parse" do

      it "should raise an ArgumentError when a non-String is passed as the 'string' argument" do
        expect {Plan.parse(42)}.to raise_error(ArgumentError, /'string'/)
      end

      it "should raise an ArgumentError when an invalid RTP string is passed as the 'string' argument" do
        str = '"Not a valid RTP", "file", "42"' + "\r\n"
        expect {Plan.parse(str)}.to raise_error(ArgumentError)
      end

      it "should create a Plan object when given a valid RTP file string" do
        str = File.open(RTP_COLUMNA, "rb") { |f| f.read }
        Plan.parse(str).class.should eql Plan
      end

      it "should set attributes from the given file" do
        str = File.open(RTP_COLUMNA, "rb") { |f| f.read }
        p = Plan.parse(str)
        p.plan_id.should eql 'STE:0-20:4'
        p.rtp_version.should eql 'OTP V4.1.0'
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
        Plan.read(RTP_COLUMNA).class.should eql Plan
      end

      it "should set attributes from the given file" do
        p = Plan.read(RTP_COLUMNA)
        p.patient_last_name.should eql 'ALDERSON'
        p.rtp_if_protocol.should eql 'IMPAC_DCM_SCP'
      end

    end


    describe "::new" do

      it "should create a Plan object" do
        @rtp.class.should eql Plan
      end

      it "should set the parent attribute as nil" do
        @rtp.parent.should be_nil
      end

      it "should by default set the prescriptions attribute as an empty array" do
        @rtp.prescriptions.should eql Array.new
      end

      it "should set the default keyword attribute" do
        @rtp.keyword.should eql "PLAN_DEF"
      end

    end


    describe "#add_prescription" do

      it "should raise an ArgumentError when a non-Prescription is passed as the 'child' argument" do
        expect {@rtp.add_prescription(42)}.to raise_error(ArgumentError, /'child'/)
      end

      it "should add the prescription" do
        r = Plan.new
        p = Prescription.new(r)
        @rtp.add_prescription(p)
        @rtp.prescriptions.should eql [p]
      end

    end


    describe "#children" do

      it "should return an empty array when called on a child-less instance" do
        @rtp.children.should eql Array.new
      end

      it "should return a one-element array containing the Plan's prescription" do
        p = Prescription.new(@rtp)
        @rtp.children.should eql [p]
      end

      it "should return a two-element array containing the Plan's prescriptions" do
        p1 = Prescription.new(@rtp)
        p2 = Prescription.new(@rtp)
        @rtp.children.should eql [p1, p2]
      end

    end


    describe "#values" do

      it "should return an array containing the keyword, but otherwise nil values when called on an empty instance" do
        arr = ["PLAN_DEF", [nil]*26].flatten
        @rtp.values.should eql arr
      end

    end


    describe "to_str" do

      it "should return a string which matches the original string" do
        str = '"PLAN_DEF","091111 12345","ALDERSON","TANGMAM ÅLESUND","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","51870"' + "\r\n"
        p = Plan.load(str)
        p.to_str.should eql str
      end

    end


    describe "#write" do

      it "should write the Plan object to file" do
        str = '"PLAN_DEF","091111 12345","ALDERSON","TANGMAM ÅLESUND","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","51870"' + "\r\n"
        plan = Plan.load(str)
        file = TMPDIR + 'plan.rtp'
        plan.write(file)
        p = Plan.read(file)
        p.to_str.should eql str
      end

    end


    describe "#keyword=()" do

      it "should raise an error unless 'PLAN_DEF' is given as an argument" do
        expect {@rtp.keyword=('SITE_DEF')}.to raise_error(ArgumentError, /keyword/)
        @rtp.keyword = 'PLAN_DEF'
        @rtp.keyword.should eql 'PLAN_DEF'
      end

    end


    describe "#patient_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '1'
        @rtp.patient_id = value
        @rtp.patient_id.should eql value
      end

    end


    describe "#patient_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Andy'
        @rtp.patient_last_name = value
        @rtp.patient_last_name.should eql value
      end

    end


    describe "#patient_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Back'
        @rtp.patient_first_name = value
        @rtp.patient_first_name.should eql value
      end

    end


    describe "#patient_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'C'
        @rtp.patient_middle_initial = value
        @rtp.patient_middle_initial.should eql value
      end

    end


    describe "#plan_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '2'
        @rtp.plan_id = value
        @rtp.plan_id.should eql value
      end

    end


    describe "#plan_date=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '20111123'
        @rtp.plan_date = value
        @rtp.plan_date.should eql value
      end

    end


    describe "#plan_time=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '150457'
        @rtp.plan_time = value
        @rtp.plan_time.should eql value
      end

    end


    describe "#course_id=()" do

      it "should pass the argument to the corresponding attribute" do
        value = '3'
        @rtp.course_id = value
        @rtp.course_id.should eql value
      end

    end


    describe "#diagnosis=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'D'
        @rtp.diagnosis = value
        @rtp.diagnosis.should eql value
      end

    end


    describe "#md_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Doc'
        @rtp.md_last_name = value
        @rtp.md_last_name.should eql value
      end

    end


    describe "#md_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Dr'
        @rtp.md_first_name = value
        @rtp.md_first_name.should eql value
      end

    end


    describe "#md_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'E'
        @rtp.md_middle_initial = value
        @rtp.md_middle_initial.should eql value
      end

    end


    describe "#md_approve_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Approver'
        @rtp.md_approve_last_name = value
        @rtp.md_approve_last_name.should eql value
      end

    end


    describe "#md_approve_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Mr'
        @rtp.md_approve_first_name = value
        @rtp.md_approve_first_name.should eql value
      end

    end


    describe "#md_approve_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'F'
        @rtp.md_approve_middle_initial = value
        @rtp.md_approve_middle_initial.should eql value
      end

    end


    describe "#phy_approve_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Phys'
        @rtp.phy_approve_last_name = value
        @rtp.phy_approve_last_name.should eql value
      end

    end


    describe "#phy_approve_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Ph'
        @rtp.phy_approve_first_name = value
        @rtp.phy_approve_first_name.should eql value
      end

    end


    describe "#phy_approve_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'G'
        @rtp.phy_approve_middle_initial = value
        @rtp.phy_approve_middle_initial.should eql value
      end

    end


    describe "#author_last_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Author'
        @rtp.author_last_name = value
        @rtp.author_last_name.should eql value
      end

    end


    describe "#author_first_name=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Aut'
        @rtp.author_first_name = value
        @rtp.author_first_name.should eql value
      end

    end


    describe "#author_middle_initial=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'H'
        @rtp.author_middle_initial = value
        @rtp.author_middle_initial.should eql value
      end

    end


    describe "#rtp_mfg=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'Manu'
        @rtp.rtp_mfg = value
        @rtp.rtp_mfg.should eql value
      end

    end


    describe "#rtp_model=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'model'
        @rtp.rtp_model = value
        @rtp.rtp_model.should eql value
      end

    end


    describe "#rtp_version=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'version'
        @rtp.rtp_version = value
        @rtp.rtp_version.should eql value
      end

    end


    describe "#rtp_if_protocol=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'prot'
        @rtp.rtp_if_protocol = value
        @rtp.rtp_if_protocol.should eql value
      end

    end


    describe "#rtp_if_version=()" do

      it "should pass the argument to the corresponding attribute" do
        value = 'ifver'
        @rtp.rtp_if_version = value
        @rtp.rtp_if_version.should eql value
      end

    end

  end

end
