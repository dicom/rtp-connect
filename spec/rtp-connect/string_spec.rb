# encoding: UTF-8

require 'spec_helper'


module RTP

  describe String do

    describe "#checksum" do

      it "should return the exact CRC which is expected for the given string" do
        str = '"RX_DEF","70","?les/Gull_70-78","","Xrays","","","","","","","5",'
        expect(str.checksum).to eql 10063
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"PLAN_DEF","101111 12345","ALDERSON","PROSTATA ÅLESUND","","Åles/Gull_70-78","20111110","142139","70","","","","","skonil","","","","","","skonil","","","Nucletron","Oncentra","OTP V4.1.0","IMPAC_DCM_SCP","2.20.08D7",'
        expect(str.checksum).to eql 31179
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"SITE_SETUP_DEF","?les/Gull_70-78","HFS","ALX","","1.38","9.10","-8.15","1.3.6.1.4.1.2452.6.92054107.1255887185.1822381187.1310744101","1.2.840.113704.1.111.4068.1320928237.3","","","","","",'
        expect(str.checksum).to eql 58306
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"FIELD_DEF","?les/Gull_70-78","7 Forfra 70-78","FORFR","","","20.725211","","ALX","Static","Xrays","15","","","100.0","88.3","0.0","0.0","ASY","0.0","-4.6","1.7","ASY","0.0","-3.2","1.3","","","","0.0","0.0","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 59762
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","FORFR","1.3.6.1.4.1.2452.6.2996584657.1311141139.589715851.4019009474","7","FORFRA 70-78",'
        expect(str.checksum).to eql 25024
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"CONTROL_PT_DEF","FORFR","11","40","1","0","1","0.000000","","15","0","88.3","2","0.0","","0.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-2.00","-4.50","-4.50","-4.60","-4.60","-4.60","-4.40","-4.30","-4.30","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","-1.80","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","1.40","1.40","1.60","1.70","1.70","1.70","1.60","1.60","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","-0.80","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 57063
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"FIELD_DEF","?les/Gull_70-78","8 LAO 70-78 ","LAO 7","","","124.351267","124.35","ALX","Static","Xrays","15","","","100.0","86.4","50.0","270.0","ASY","0.0","-1.3","3.2","ASY","0.0","-5.4","2.1","","","","0.0","0.0","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 7109
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","LAO 7","1.3.6.1.4.1.2452.6.2996584657.1311141139.589715851.4019009474","8","LAO 70-78",'
        expect(str.checksum).to eql 18445
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"CONTROL_PT_DEF","LAO 7","11","40","1","0","1","0.000000","IN","15","0","86.4","2","50.0","","270.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","1.50","0.90","0.90","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-0.80","-0.80","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","-0.70","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","2.50","3.10","3.10","3.20","3.20","3.20","3.20","3.20","3.10","2.90","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","0.30","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 22763
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"FIELD_DEF","?les/Gull_70-78","9 Venstre 70-78 ","VENST","","","82.900845","","ALX","Static","Xrays","15","","","100.0","86.2","90.0","350.0","ASY","0.0","-4.5","2.9","ASY","0.0","-3.8","1.7","","","","0.0","0.0","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 41988
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","VENST","1.3.6.1.4.1.2452.6.2996584657.1311141139.589715851.4019009474","9","VENSTRE 70-78",'
        expect(str.checksum).to eql 33346
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"CONTROL_PT_DEF","VENST","11","40","1","0","1","0.000000","","15","0","86.2","2","90.0","","350.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-2.30","-4.50","-4.50","-4.50","-4.30","-4.10","-3.90","-1.90","-1.90","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","0.90","0.90","2.60","2.80","2.90","2.90","2.90","2.90","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","1.00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 21529
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"FIELD_DEF","?les/Gull_70-78","10 H?yre 70-78","H?YRE","","","82.900845","","ALX","Static","Xrays","15","","","100.0","82.7","270.0","10.0","ASY","0.0","-3.0","4.6","ASY","0.0","-3.9","1.7","","","","0.0","0.0","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 32860
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","H?YRE","1.3.6.1.4.1.2452.6.2996584657.1311141139.589715851.4019009474","10","H?YRE 70-78",'
        expect(str.checksum).to eql 24749
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"CONTROL_PT_DEF","H?YRE","11","40","1","0","1","0.000000","","15","0","82.7","2","270.0","","10.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","1.20","-1.30","-1.30","-2.70","-2.90","-2.90","-3.00","-3.00","-3.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","-1.00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","2.20","4.60","4.60","4.60","4.40","4.20","4.00","2.00","2.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","0.00","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 63409
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"FIELD_DEF","?les/Gull_70-78","11 RAO 70-78","RAO 7","","","124.351267","124.35","ALX","Static","Xrays","15","","","100.0","84.1","310.0","90.0","ASY","0.0","-3.2","1.3","ASY","0.0","-3.6","3.9","","","","0.0","0.0","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 33266
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","RAO 7","1.3.6.1.4.1.2452.6.2996584657.1311141139.589715851.4019009474","11","RAO 70-78",'
        expect(str.checksum).to eql 35277
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"CONTROL_PT_DEF","RAO 7","11","40","1","0","1","0.000000","IN","15","0","84.1","2","310.0","","90.0","","","","","","","","","","0.0","0.0","0.0","0.0","","0.0","","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-2.10","-3.20","-3.20","-3.20","-3.20","-3.20","-3.20","-3.20","-3.20","-2.90","-2.90","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","-1.30","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-1.10","-0.10","-0.10","1.30","1.30","1.30","1.30","1.30","1.30","1.30","1.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","-0.30","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",'
        expect(str.checksum).to eql 4676
      end

      it "should return the exact CRC which is expected for the given string" do
        str = '"EXTENDED_FIELD_DEF","","","","Anterior, Left",'
        expect(str.checksum).to eql 35786
      end

    end


    describe "#elements" do

      it "should return the elements of a RTP string line (an array of string elements)" do
        str = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"'
        arr = ['"RX_DEF"', '"20"', '"STE:0-20:4"', '""', '"Xrays"', '""', '""' ,'""', '""', '""', '""', '"1"', '"17677"']
        expect(str.elements).to eql arr
      end

    end


    describe "#value" do

      it "should return the string with it's double quotes removed" do
        str = '"RX_DEF"'
        expect(str.value).to eql 'RX_DEF'
      end

      it "should return an empty string" do
        str = '""'
        expect(str.value).to eql ''
      end

      it "should not remove the double quote characters inside the string" do
        str = '"Jack "KO" Doe"'
        expect(str.value).to eql 'Jack "KO" Doe'
      end

    end


    describe "#values" do

      it "should return the double-quote-less elements of a RTP string line (an array of string elements)" do
        str = '"RX_DEF","20","STE:0-20:4","","Xrays","","","","","","","1","17677"'
        arr = ['RX_DEF', '20', 'STE:0-20:4', '', 'Xrays', '', '' ,'', '', '', '', '1', '17677']
        expect(str.values).to eql arr
      end

      it "should successfully parse a record containing an attribute with a comma character" do
        str = '"EXTENDED_FIELD_DEF","","","","Anterior, Left","35786"'
        arr = ['EXTENDED_FIELD_DEF', '', '', '', 'Anterior, Left', '35786']
        expect(str.values).to eql arr
      end

      it "should successfully parse a record containing an attribute with pairs of double-quote characters (yielding values with single double-quote characters)" do
        str = '"EXTENDED_FIELD_DEF","","","","Anterior ""Left"" Field","59395"'
        arr = ['EXTENDED_FIELD_DEF', '', '', '', 'Anterior "Left" Field', '59395']
        expect(str.values).to eql arr
      end

      it "should successfully parse a record containing an attribute with a comma enclosed by pairs of double-quote characters" do
        str = '"EXTENDED_FIELD_DEF","","","","Anterior "","" Field","20339"'
        arr = ['EXTENDED_FIELD_DEF', '', '', '', 'Anterior "," Field', '20339']
        expect(str.values).to eql arr
      end

      it "should fail when given an invalid csv string (containing one double quote character), and give an error message containing the invalid string record" do
        str = '"PLAN_DEF","123","Doe","John"Joe","","","",""," 3","","","","","","","","","","","","","","","","","RTP","1.0","31446"'
        RTP.logger.expects(:error).once
        expect {str.values}.to raise_error
      end

    end


    describe "#wrap" do

      it "should return the string wrapped with double-quotes" do
        str = 'RX_DEF'
        expect(str.wrap).to eql '"RX_DEF"'
      end

      it "should return a string containing two double-quotes" do
        str = ''
        expect(str.wrap).to eql '""'
      end

    end

  end

end