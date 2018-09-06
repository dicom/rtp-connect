# encoding: ASCII-8BIT

# Compatibility specification. The RTPConnect library should be able to read
# and write all these sample files successfully.
# Only reading files checked yet.

require 'spec_helper'


module RTP

  describe Plan do

    describe "::read" do

      it "should raise an exception when given a file with invalid CSV format" do
        expect {Plan.read(RTP_INVALID_QUOTE)}.to raise_error(/Unclosed/)
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_COMMA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_PAIRS_QUOTES)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect Plan record" do
        rtp = Plan.read(RTP_ATTRIBUTE_QUOTED_COMMA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_COLUMNA)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_PROSTATE)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_IMRT)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_TANGMAM)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_ELECTRON)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_24)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_SIM)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_VMAT)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_VARIAN_NATIVE)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_25)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_26)
        expect(rtp.class).to eql Plan
      end

      it "should parse this RTPConnect file and build a valid record object hierarchy" do
        rtp = Plan.read(RTP_MOSAIQ_264)
        expect(rtp.class).to eql Plan
      end

      context "with ignore_crc: true" do

        it "should successfully read this file with invalid CRCs" do
          rtp = Plan.read(RTP_INVALID_CRC, ignore_crc: true)
          expect(rtp.patient_id).to eql "123"
          expect(rtp.prescriptions.first.course_id).to eql "7"
        end

      end

      context "with skip_unknown: true" do

        it "should successfully read this file containing an unknown record definition (the unknown record being discarded)" do
          rtp = Plan.read(RTP_UNKNOWN_RECORD, skip_unknown: true)
          expect(rtp.patient_id).to eql "99999"
          expect(rtp.prescriptions.length).to eql 1
          expect(rtp.prescriptions.first.course_id).to eql "2"
        end

      end

      context "with repair: true" do

        it "should successfully read this file containing invalid CSV attributes (by repairing the invalid CSV attributes)" do
          rtp = Plan.read(RTP_INVALID_QUOTE, repair: true)
          expect(rtp.patient_id).to eql "123"
        end

      end

    end

    describe "::write" do

      before :all do
        @p = Plan.new
        @ep = ExtendedPlan.new(@p)
        @pr = Prescription.new(@p)
        @ss = SiteSetup.new(@pr)
        @f = Field.new(@pr)
        @ef = ExtendedField.new(@f)
        @cp = ControlPoint.new(@f)
        @ss.table_top_vert_displacement = '44.4'
        @ss.table_top_long_displacement = '22.2'
        @ss.table_top_lat_displacement = '33.3'
        @f.iso_pos_x = '2.2'
        @f.iso_pos_y = '3.3'
        @f.iso_pos_z = '4.4'
        @ef.is_fff = '1'
        @ef.accessory_code = 'CC'
        @ef.accessory_type = 'TT'
        @ef.high_dose_authorization = 'YY'
        @cp.iso_pos_x = '-1.3'
        @cp.iso_pos_y = '-5.7'
        @cp.iso_pos_z = '-9.1'
      end

      it "discards the SiteSetup table top displacement elements when a version less than 2.6 is used" do
        file = File.join(TMPDIR, 'site_setup_pre_2.6.rtp')
        @p.write(file, version: 2.5)
        res = Plan.read(file)
        expect(res.prescriptions.first.site_setup.table_top_vert_displacement).to be_nil
        expect(res.prescriptions.first.site_setup.table_top_long_displacement).to be_nil
        expect(res.prescriptions.first.site_setup.table_top_lat_displacement).to be_nil
      end

      it "includes the SiteSetup table top displacement elements when a version greater or equal than 2.6 is used" do
        file = File.join(TMPDIR, 'site_setup_2.6.rtp')
        @p.write(file, version: 2.6)
        res = Plan.read(file)
        expect(res.prescriptions.first.site_setup.table_top_vert_displacement).to eql @ss.table_top_vert_displacement
        expect(res.prescriptions.first.site_setup.table_top_long_displacement).to eql @ss.table_top_long_displacement
        expect(res.prescriptions.first.site_setup.table_top_lat_displacement).to eql @ss.table_top_lat_displacement
      end

      it "discards the ExtendedField elements 6-9 when a version less than 2.4 is used" do
        file = File.join(TMPDIR, 'extended_field_pre_2.4.rtp')
        @p.write(file, version: 2.3)
        res = Plan.read(file)
        expect(res.prescriptions.first.fields.first.extended_field.is_fff).to be_nil
        expect(res.prescriptions.first.fields.first.extended_field.accessory_code).to be_nil
        expect(res.prescriptions.first.fields.first.extended_field.accessory_type).to be_nil
        expect(res.prescriptions.first.fields.first.extended_field.high_dose_authorization).to be_nil
      end

      it "includes the ExtendedField elements 6-9 when a version greater or equal than 2.4 is used" do
        file = File.join(TMPDIR, 'extended_field_2.4.rtp')
        @p.write(file, version: 2.4)
        res = Plan.read(file)
        expect(res.prescriptions.first.fields.first.extended_field.is_fff).to eql @ef.is_fff
        expect(res.prescriptions.first.fields.first.extended_field.accessory_code).to eql @ef.accessory_code
        expect(res.prescriptions.first.fields.first.extended_field.accessory_type).to eql @ef.accessory_type
        expect(res.prescriptions.first.fields.first.extended_field.high_dose_authorization).to eql @ef.high_dose_authorization
      end

      it "discards the ExtendedPlan record when a version less than 2.5 is used" do
        file = File.join(TMPDIR, 'extended_plan_pre_2.5.rtp')
        @p.write(file, version: 2.4)
        res = Plan.read(file)
        expect(res.extended_plan).to be_nil
      end

      it "includes the ExtendedPlan record when a version greater or equal than 2.5 is used" do
        file = File.join(TMPDIR, 'extended_plan_2.5.rtp')
        @p.write(file, version: 2.5)
        res = Plan.read(file)
        expect(res.extended_plan).to be_a ExtendedPlan
      end

      it "discards the Field and ControlPoint iso_pos_x/y/z elements when a version less than 2.64 is used" do
        file = File.join(TMPDIR, 'field_and_control_point_pre_2.6.rtp')
        @p.write(file, version: 2.6)
        res = Plan.read(file)
        expect(res.prescriptions.first.fields.first.iso_pos_x).to be_nil
        expect(res.prescriptions.first.fields.first.iso_pos_y).to be_nil
        expect(res.prescriptions.first.fields.first.iso_pos_z).to be_nil
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_x).to be_nil
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_y).to be_nil
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_z).to be_nil
      end

      it "includes the Field and ControlPoint iso_pos_x/y/z elements when a version greater or equal than 2.64 is used" do
        file = File.join(TMPDIR, 'field_and_control_point_2.6.rtp')
        @p.write(file, version: 2.64)
        res = Plan.read(file)
        expect(res.prescriptions.first.fields.first.iso_pos_x).to eql @f.iso_pos_x
        expect(res.prescriptions.first.fields.first.iso_pos_y).to eql @f.iso_pos_y
        expect(res.prescriptions.first.fields.first.iso_pos_z).to eql @f.iso_pos_z
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_x).to eql @cp.iso_pos_x
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_y).to eql @cp.iso_pos_y
        expect(res.prescriptions.first.fields.first.control_points.first.iso_pos_z).to eql @cp.iso_pos_z
      end

    end

  end

end