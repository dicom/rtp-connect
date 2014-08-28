# encoding: ASCII-8BIT

require 'spec_helper'


module RTP

  describe Plan do

    before :context do
      require 'dicom'
      DICOM.logger.level = Logger::ERROR
    end

    describe "#to_dcm" do

      it "should reset the DICOM logger to its original logging level" do
        original_level = DICOM.logger.level
        set_level = Logger::DEBUG
        DICOM.logger.level = set_level
        p = Plan.read(RTP_COLUMNA)
        p.to_dcm
        expect(DICOM.logger.level).to eql set_level
        DICOM.logger.level = original_level
      end

      it "should return a DICOM::DObject" do
        p = Plan.read(RTP_COLUMNA)
        expect(p.to_dcm.class).to eql DICOM::DObject
      end

      it "should create a valid RTPLAN DICOM file" do
        p = Plan.read(RTP_COLUMNA)
        p.to_dcm.write(TMPDIR + "rtplan.dcm")
        dcm = DICOM::DObject.read(TMPDIR + "rtplan.dcm")
        expect(dcm.class).to eql DICOM::DObject
        expect(dcm.read?).to be_truthy
      end

      it "should leave these undeterminable tags out of the Beam Sequence when no tag options are specified" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        beam_item = dcm['300A,00B0'][0]
        expect(beam_item.exists?('0008,0070')).to be_falsey
        expect(beam_item.exists?('0008,1090')).to be_falsey
        expect(beam_item.exists?('0018,1000')).to be_falsey
      end

      it "should fill in the Manufacturer tag in the Beam Sequence when specified by the :manufacturer option" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm(:manufacturer => 'ACME')
        beam_item = dcm['300A,00B0'][0]
        expect(beam_item.value('0008,0070')).to eql 'ACME'
      end

      it "should fill in the Manufacturer's Model Name tag in the Beam Sequence when specified by the :model option" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm(:model => 'ACME BEAM ON')
        beam_item = dcm['300A,00B0'][0]
        expect(beam_item.value('0008,1090')).to eql 'ACME BEAM ON'
      end

      it "should fill in the Device Serial Number tag in the Beam Sequence when specified by the :serial_number option" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm(:serial_number => '1234')
        beam_item = dcm['300A,00B0'][0]
        expect(beam_item.value('0018,1000')).to eql '1234'
      end

      it "should not create any ASYMX items for a plan using a model which is known not to have an X jaw" do
        p = Plan.read(RTP_SIEMENS_58)
        dcm = p.to_dcm
        beam_item = dcm['300A,00B0'][0]
        # Beam Limiting Device Sequence:
        expect(beam_item['300A,00B6'].items.length).to eql 2
        types = beam_item['300A,00B6'].items.collect {|item| item.value('300A,00B8')}
        expect(types.include?('ASYMX')).to be_falsey
        # Beam Limiting Device Position Sequence (First control point item):
        seq = beam_item['300A,0111'][0]['300A,011A']
        expect(seq.items.length).to eql 2
        types = seq.items.collect {|item| item.value('300A,00B8')}
        expect(types.include?('ASYMX')).to be_falsey
      end

      it "should create the ASYMX items for a plan using a model which is known to have an X jaw" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        beam_item = dcm['300A,00B0'][0]
        # Beam Limiting Device Sequence:
        expect(beam_item['300A,00B6'].items.length).to eql 3
        types = beam_item['300A,00B6'].items.collect {|item| item.value('300A,00B8')}
        expect(types.include?('ASYMX')).to be_truthy
        # Beam Limiting Device Position Sequence (First control point item):
        seq = beam_item['300A,0111'][0]['300A,011A']
        expect(seq.items.length).to eql 3
        types = seq.items.collect {|item| item.value('300A,00B8')}
        expect(types.include?('ASYMX')).to be_truthy
      end

      it "should give a warning (but still create a DICOM object) if the site setup record is missing" do
        p = Plan.read(RTP_COLUMNA)
        p.prescriptions.first.stubs(:site_setup)
        RTP.logger.expects(:warn)
        dcm = p.to_dcm
        expect(dcm.class).to eql DICOM::DObject
      end

      it "should skip the Referenced Structure Set Sequence and set RT Plan Geometry as 'TREATMENT_DEVICE' when structure set information is missing from the RTP file" do
        p = Plan.read(RTP_COLUMNA)
        p.prescriptions.first.stubs(:site_setup)
        dcm = p.to_dcm
        expect(dcm.value('300A,000C')).to eql 'TREATMENT_DEVICE'
        expect(dcm.exists?('300C,0060')).to be_falsey
      end

      it "should include the Referenced Structure Set Sequence and set RT Plan Geometry as 'PATIENT' when structure set information is present in the RTP file" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        expect(dcm.value('300A,000C')).to eql 'PATIENT'
        expect(dcm.exists?('300C,0060')).to be_truthy
        expect(dcm['300C,0060'][0].value('0008,1150')).to eql '1.2.840.10008.5.1.4.1.1.481.3'
        expect(dcm['300C,0060'][0].value('0008,1155')).to eql p.prescriptions.first.site_setup.structure_set_uid
      end

      it "should return an (incomplete) RTPLAN DObject when given a Plan object with no child records" do
        str = '"PLAN_DEF","12345","ALDERSON","TANGMAM","","STE:0-20:4","20111123","150457","20","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7","61220"'
        p = Plan.load(str)
        dcm = p.to_dcm
        expect(dcm.class).to eql DICOM::DObject
      end

      it "should include the Tolerance Table Sequence if the RTP contains a field with a tolerance table number" do
        p = Plan.read(RTP_VMAT)
        dcm = p.to_dcm
        expect(dcm.exists?('300A,0040')).to be_truthy
        expect(dcm['300A,0040'][0].value('300A,0042')).to eql p.prescriptions.first.fields.first.tolerance_table
      end

      it "should not include the Tolerance Table Sequence when the RTP record's (first) field doesn't have a tolerance table number" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        expect(dcm.exists?('300A,0040')).to be_falsey
      end

      it "should by default not include Dose Reference & Referenced Dose Reference sequences" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        expect(dcm.exists?('300A,0010')).to be_falsey
        dcm['300A,00B0'].items.each do |beam_item|
          ref_dose_in_beam_cpts = false
          beam_item['300A,0111'].items.each do |cp_item|
            ref_dose_in_beam_cpts = true if cp_item.exists?('300C,0050')
          end
          expect(ref_dose_in_beam_cpts).to be_falsey
        end
      end

      it "should include Dose Reference & Referenced Dose Reference sequences when the :dose_ref option is set as true" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm(dose_ref: true)
        expect(dcm.exists?('300A,0010')).to be_truthy
        dcm['300A,00B0'].items.each do |beam_item|
          ref_dose_in_beam_cpts = false
          beam_item['300A,0111'].items.each do |cp_item|
            ref_dose_in_beam_cpts = true if cp_item.exists?('300C,0050')
          end
          expect(ref_dose_in_beam_cpts).to be_truthy
        end
      end

      it "should encode the beam limiting device items in the following order: ASYMX, ASYMY, MLCX" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        bld_types = dcm['300A,00B0'][0]['300A,00B6'].items.collect {|item| item.value('300A,00B8')}
        expect(bld_types).to eql ['ASYMX', 'ASYMY', 'MLCX']
        bldp_types = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'].items.collect {|item| item.value('300A,00B8')}
        expect(bldp_types).to eql ['ASYMX', 'ASYMY', 'MLCX']
      end

      it "should encode the number of leaf/jaw pairs" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        bld_numbers = dcm['300A,00B0'][0]['300A,00B6'].items.collect {|item| item.value('300A,00BC')}
        expect(bld_numbers).to eql ['1', '1', '40']
      end

      it "should encode proper jaw positions for an RTP file where the jaws are not defined in the control point (only the field)" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        asymx = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][0].value('300A,011C').split("\\").collect {|v| v.to_f}
        asymy = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][1].value('300A,011C').split("\\").collect {|v| v.to_f}
        # If picked from the control point, these would be [0, 0] & [0, 0].
        expect(asymx).to eql [-50.0, 50.0]
        expect(asymy).to eql [-71.0, 58.0]
      end

      it "should encode the expected MLC positions for this case with a simple, single control point RTP file" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        mlcx = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][2].value('300A,011C').split("\\").collect {|v| v.to_f}
        expect(mlcx).to eql [
          -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -50.0, -50.0, -50.0, -50.0,
          -50.0,-50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -50.0, -5.0, -5.0,
          -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, -5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
          5.0, 5.0, 5.0, 5.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0,
          50.0, 50.0, 50.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,5.0, 5.0
        ]
      end

      it "should properly encode fractional cumulative meterset weight (in the case of an RTP with only a single control point)" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        expect(dcm['300A,00B0'][0].value('300A,010E').to_f).to eql 1.0
        expect(dcm['300A,00B0'][0]['300A,0111'][0].value('300A,0134').to_f).to eql 0.0
        expect(dcm['300A,00B0'][0]['300A,0111'][1].value('300A,0134').to_f).to eql 1.0
      end

      it "should properly encode fractional cumulative meterset weight (in the case of an RTP with multiple control points)" do
        p = Plan.read(RTP_VMAT)
        dcm = p.to_dcm
        expect(dcm['300A,00B0'][0].value('300A,010E').to_f).to eql 1.0
        expect(dcm['300A,00B0'][0]['300A,0111'][0].value('300A,0134').to_f).to eql 0.0
        expect(dcm['300A,00B0'][0]['300A,0111'][1].value('300A,0134').to_f).to eql 0.04762
        expect(dcm['300A,00B0'][0]['300A,0111'][20].value('300A,0134').to_f).to eql 0.95238
        expect(dcm['300A,00B0'][0]['300A,0111'][21].value('300A,0134').to_f).to eql 1.0
      end

      it "should insert the SSD element when the RTP record contains an ssd value" do
        p = Plan.read(RTP_COLUMNA)
        dcm = p.to_dcm
        expect(dcm['300A,00B0'][0]['300A,0111'][0].value('300A,0130').to_f).to eql 963.0
      end

      it "should not create the SSD element when the RTP record contains an empty string SSD value" do
        p = Plan.read(RTP_COLUMNA)
        p.prescriptions.first.fields.first.ssd = ''
        p.prescriptions.first.fields.first.control_points.first.ssd = ''
        dcm = p.to_dcm
        expect(dcm['300A,00B0'][0]['300A,0111'][0].exists?('300A,0130')).to be_falsey
      end

      it "should not create the SSD element when the RTP record contains a nil SSD value" do
        p = Plan.read(RTP_COLUMNA)
        p.prescriptions.first.fields.first.ssd = nil
        p.prescriptions.first.fields.first.control_points.first.ssd = nil
        dcm = p.to_dcm
        expect(dcm['300A,00B0'][0]['300A,0111'][0].exists?('300A,0130')).to be_falsey
      end

      it "should set exactly the same value of the cumulative meterset weight attribute in the last control point as that of the final cumulative meterset weight in the beam item" do
        p = Plan.read(RTP_VMAT)
        dcm = p.to_dcm
        final_cumulative = dcm['300A,00B0'][0].value('300A,010E')
        last_cumulative = dcm['300A,00B0'][0]['300A,0111'].items.last.value('300A,0134')
        expect(last_cumulative).to eql final_cumulative
      end

      it "should successfully convert an RTP file with fields that doesn't have any control points, using field settings for jaw positions" do
        p = Plan.read(RTP_SIM)
        dcm = p.to_dcm
        xjaws = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][0].value('300A,011C')
        yjaws = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][1].value('300A,011C')
        expect(xjaws).to eql "0.0\\108.0"
        expect(yjaws).to eql "-45.0\\45.0"
      end

      context "with :scale => :elekta" do

        it "encodes proper (inverted) x1 and y1 jaw positions for this Elekta case with native readout format" do
          p = Plan.read(RTP_VMAT)
          dcm = p.to_dcm(:scale => :elekta)
          asymx = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][0].value('300A,011C').split("\\").collect {|v| v.to_f}
          asymy = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][1].value('300A,011C').split("\\").collect {|v| v.to_f}
          # Without scale conversion these results would be [80, 80] & [105, 105] (i.e. all positive).
          expect(asymx[0]).to be < 0
          expect(asymy[0]).to be < 0
        end

        it "encodes(switches) the x and y jaw positions for this Elekta case with native readout format" do
          p = Plan.read(RTP_VMAT)
          dcm = p.to_dcm(:scale => :elekta)
          asymx = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][0].value('300A,011C').split("\\").collect {|v| v.to_f}
          asymy = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][1].value('300A,011C').split("\\").collect {|v| v.to_f}
          # Without scale conversion asymx results would be asymy, and vice versa:
          expect(asymx).to eql [-105.0, 105.0]
          expect(asymy).to eql [-80.0, 80.0]
        end

        it "encodes as expected the MLC positions for this Elekta VMAT case with native readout format" do
          p = Plan.read(RTP_VMAT)
          dcm = p.to_dcm(:scale => :elekta)
          mlc_retain = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][2].value('300A,011C').split("\\").collect {|v| v.to_f}
          mlc_invert = dcm['300A,00B0'][0]['300A,0111'][21]['300A,011A'][2].value('300A,011C').split("\\").collect {|v| v.to_f}
          expect(mlc_retain).to eql [
            98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0,
            98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0,
            98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 98.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0,
            100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0,
            100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0,
            100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0
          ]
          expect(mlc_invert).to eql [
            -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0,
            -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0,
            -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0,
            -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -100.0, -98.0, -98.0, -98.0, -98.0, -98.0,
            -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0,
            -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0,
            -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0, -98.0
          ]
        end

      end

      context "with :scale => :varian" do

        it "encodes proper (inverted) x1 and y1 jaw positions for this Varian case with native readout format" do
          p = Plan.read(RTP_VARIAN_NATIVE)
          dcm = p.to_dcm(:scale => :varian)
          asymx = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][0].value('300A,011C').split("\\").collect {|v| v.to_f}
          asymy = dcm['300A,00B0'][0]['300A,0111'][0]['300A,011A'][1].value('300A,011C').split("\\").collect {|v| v.to_f}
          # Without scale conversion these results would be [63, 45] & [33, 45] (i.e. all positive).
          expect(asymx[0]).to be < 0
          expect(asymy[0]).to be < 0
        end

      end

    end

  end

end