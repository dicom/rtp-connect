# encoding: UTF-8

require 'spec_helper'


module RTP

  describe Plan do

    describe " [encoding]" do

      before :each do
        @p = Plan.new
        @p.patient_id = '12345'.encode('ASCII')
        @p.patient_last_name = 'Værnes'.encode('ISO8859-1')
        @p.patient_first_name = 'John'.encode('ASCII')
        @rx = Prescription.new(@p)
        @rx.rx_site_name = 'Prostate'.encode('ASCII')
        @f = Field.new(@rx)
        @f.field_name = 'Høyre Å'.encode('ISO8859-1')
      end

      it "should preserve the extended ASCII (ISO8859-1) characters in a write-read cycle" do
        file = File.join(TMPDIR, 'encoding_01.rtp')
        @p.write(file)
        p = Plan.read(file)
        expect(p.patient_last_name.encoding).to eql Encoding::ISO8859_1
        expect(p.patient_last_name).to eql @p.patient_last_name
        expect(p.prescriptions.first.fields.first.field_name).to eql @f.field_name
      end

    end

  end

end