module RTP

  class Plan < Record

    # Converts the Plan (and child) records to a
    # DICOM::DObject of modality RTPLAN.
    #
    def to_dcm
      #
      # FIXME: This method is rather big, with a few sections of somewhat similar, repeating code.
      # Refactoring and simplifying it at some stage might be a good idea.
      #
      require 'dicom'
      DICOM.logger.level = Logger::FATAL
      p = @prescriptions.first
      # If no prescription is present, we are not going to be able to make a valid DICOM object:
      logger.error("No Prescription Record present. Unable to build a valid RTPLAN DICOM object.") unless p
      dcm = DICOM::DObject.new
      #
      # TOP LEVEL TAGS:
      #
      # Specific Character Set:
      DICOM::Element.new('0008,0005', 'ISO_IR 100', :parent => dcm)
      # Instance Creation Date
      DICOM::Element.new('0008,0012', Time.now.strftime("%Y%m%d"), :parent => dcm)
      # Instance Creation Time:
      DICOM::Element.new('0008,0013', Time.now.strftime("%H%M%S"), :parent => dcm)
      # SOP Class UID:
      DICOM::Element.new('0008,0016', '1.2.840.10008.5.1.4.1.1.481.5', :parent => dcm)
      # SOP Instance UID (if an original UID is not present, we make up a UID):
      begin
        sop_uid = p.fields.first.extended_field.original_plan_uid.empty? ? DICOM.generate_uid : p.fields.first.extended_field.original_plan_uid
      rescue
        sop_uid = DICOM.generate_uid
      end
      DICOM::Element.new('0008,0018', sop_uid, :parent => dcm)
      # Study Date
      DICOM::Element.new('0008,0020', Time.now.strftime("%Y%m%d"), :parent => dcm)
      # Study Time:
      DICOM::Element.new('0008,0030', Time.now.strftime("%H%M%S"), :parent => dcm)
      # Accession Number:
      DICOM::Element.new('0008,0050', '', :parent => dcm)
      # Modality:
      DICOM::Element.new('0008,0060', 'RTPLAN', :parent => dcm)
      # Manufacturer:
      DICOM::Element.new('0008,0070', 'rtp-connect', :parent => dcm)
      # Referring Physician's Name:
      DICOM::Element.new('0008,0070', 'rtp-connect', :parent => dcm)
      # Referring Physician's Name:
      DICOM::Element.new('0008,0090', "#{@md_last_name}^#{@md_first_name}^#{@md_middle_name}^^", :parent => dcm)
      # Operator's Name:
      DICOM::Element.new('0008,1070', "#{@phy_approve_last_name}^#{@phy_approve_first_name}^#{@phy_approve_middle_name}^^", :parent => dcm)
      # Patient's Name:
      DICOM::Element.new('0010,0010', "#{@patient_last_name}^#{@patient_first_name}^#{@patient_middle_name}^^", :parent => dcm)
      # Patient ID:
      DICOM::Element.new('0010,0020', @patient_id, :parent => dcm)
      # Patient's Birth Date:
      DICOM::Element.new('0010,0030', '', :parent => dcm)
      # Patient's Sex:
      DICOM::Element.new('0010,0040', '', :parent => dcm)
      # Manufacturer's Model Name:
      DICOM::Element.new('0008,1090', 'RTP auto-conversion', :parent => dcm)
      # Software Version(s):
      DICOM::Element.new('0018,1020', "rtp-connect #{VERSION}", :parent => dcm)
      # Study Instance UID:
      DICOM::Element.new('0020,000D', DICOM.generate_uid, :parent => dcm)
      # Series Instance UID:
      DICOM::Element.new('0020,000E', DICOM.generate_uid, :parent => dcm)
      # Study ID:
      DICOM::Element.new('0020,0010', '1', :parent => dcm)
      # Series Number:
      DICOM::Element.new('0020,0011', '1', :parent => dcm)
      # Frame of Reference UID (if an original UID is not present, we make up a UID):
      begin
        for_uid = p.site_setup.frame_of_ref_uid.empty? ? DICOM.generate_uid : p.site_setup.frame_of_ref_uid
      rescue
        for_uid = DICOM.generate_uid
      end
      DICOM::Element.new('0020,0052', for_uid, :parent => dcm)
      # Position Reference Indicator:
      DICOM::Element.new('0020,1040', '', :parent => dcm)
      # RT Plan Label (max 16 characters):
      plan_label = p ? p.rx_site_name[0..15] : @course_id
      DICOM::Element.new('300A,0002', plan_label, :parent => dcm)
      # RT Plan Name:
      plan_name = p ? p.rx_site_name : @course_id
      DICOM::Element.new('300A,0003', plan_name, :parent => dcm)
      # RT Plan Description:
      plan_desc = p ? p.technique : @diagnosis
      DICOM::Element.new('300A,0004', plan_desc, :parent => dcm)
      # RT Plan Date:
      plan_date = @plan_date.empty? ? Time.now.strftime("%Y%m%d") : @plan_date
      DICOM::Element.new('300A,0006', plan_date, :parent => dcm)
      # RT Plan Time:
      plan_time = @plan_time.empty? ? Time.now.strftime("%H%M%S") : @plan_time
      DICOM::Element.new('300A,0007', plan_time, :parent => dcm)
      # RT Plan Geometry:
      DICOM::Element.new('300A,000C', 'PATIENT', :parent => dcm)
      # Approval Status:
      DICOM::Element.new('300E,0002', 'UNAPPROVED', :parent => dcm)
      #
      # SEQUENCES:
      #
      #
      # Referenced Structure Set Sequence:
      #
      ss_seq = DICOM::Sequence.new('300C,0060', :parent => dcm)
      ss_item = DICOM::Item.new(:parent => ss_seq)
      # Referenced SOP Class UID:
      DICOM::Element.new('0008,1150', '1.2.840.10008.5.1.4.1.1.481.3', :parent => ss_item)
      # Referenced SOP Instance UID (if an original UID is not present, we make up a UID):
      begin
        ref_ss_uid = p.site_setup.structure_set_uid.empty? ? DICOM.generate_uid : p.site_setup.structure_set_uid
      rescue
        ref_ss_uid = DICOM.generate_uid
      end
      DICOM::Element.new('0008,1155', ref_ss_uid, :parent => ss_item)
      #
      # Patient Setup Sequence:
      #
      ps_seq = DICOM::Sequence.new('300A,0180', :parent => dcm)
      ps_item = DICOM::Item.new(:parent => ps_seq)
      # Patient Position:
      begin
        pat_pos = p.site_setup.patient_orientation.empty? ? 'HFS' : p.site_setup.patient_orientation
      rescue
        pat_pos = 'HFS'
      end
      DICOM::Element.new('0018,5100', pat_pos, :parent => ps_item)
      # Patient Setup Number:
      DICOM::Element.new('300A,0182', '1', :parent => ps_item)
      # Setup Technique (assume Isocentric):
      DICOM::Element.new('300A,01B0', 'ISOCENTRIC', :parent => ps_item)
      #
      # Fraction Group Sequence:
      #
      fg_seq = DICOM::Sequence.new('300A,0070', :parent => dcm)
      fg_item = DICOM::Item.new(:parent => fg_seq)
      # Fraction Group Number:
      DICOM::Element.new('300A,0071', '1', :parent => fg_item)
      # Number of Fractions Planned (try to derive from total dose/fraction dose, or use 1 as default):
      begin
        num_frac = p.dose_ttl.empty? || p.dose_tx.empty? ? '1' : (p.dose_ttl.to_i / p.dose_tx.to_f).round.to_s
      rescue
        num_frac = '0'
      end
      DICOM::Element.new('300A,0078', num_frac, :parent => fg_item)
      # Number of Beams:
      num_beams = p ? p.fields.length : 0
      DICOM::Element.new('300A,0080', "#{num_beams}", :parent => fg_item)
      # Number of Brachy Application Setups:
      DICOM::Element.new('300A,00A0', "0", :parent => fg_item)
      # Referenced Beam Sequence (items created for each beam below):
      rb_seq = DICOM::Sequence.new('300C,0004', :parent => fg_item)
      #
      # Beam Sequence:
      #
      b_seq = DICOM::Sequence.new('300A,00B0', :parent => dcm)
      if p
        # If no fields are present, we are not going to be able to make a valid DICOM object:
        logger.error("No Field Record present. Unable to build a valid RTPLAN DICOM object.") unless p.fields.length > 0
        p.fields.each_with_index do |field, i|
          # If this is an electron beam, a warning should be printed, as these are less reliably converted:
          logger.warn("This is not a photon beam (#{field.modality}). Beware that DICOM conversion of Electron beams are experimental, and other modalities are unsupported.") if field.modality != 'Xrays'
          # Beam number and name:
          beam_number = field.extended_field ? field.extended_field.original_beam_number : (i + 1).to_s
          beam_name = field.extended_field ? field.extended_field.original_beam_name : field.field_name
          # Ref Beam Item:
          rb_item = DICOM::Item.new(:parent => rb_seq)
          # Beam Meterset:
          DICOM::Element.new('300A,0086', field.field_monitor_units, :parent => rb_item)
          # Referenced Beam Number:
          DICOM::Element.new('300C,0006', beam_number, :parent => rb_item)
          # Beam Item:
          b_item = DICOM::Item.new(:parent => b_seq)
          # Treatment Machine Name (max 16 characters):
          DICOM::Element.new('300A,00B2', field.treatment_machine[0..15], :parent => b_item)
          # Primary Dosimeter Unit:
          DICOM::Element.new('300A,00B3', 'MU', :parent => b_item)
          # Source-Axis Distance (convert to mm):
          DICOM::Element.new('300A,00B4', "#{field.sad.to_f * 10}", :parent => b_item)
          # Beam Number:
          DICOM::Element.new('300A,00C0', beam_number, :parent => b_item)
          # Beam Name:
          DICOM::Element.new('300A,00C2', beam_name, :parent => b_item)
          # Beam Description:
          DICOM::Element.new('300A,00C3', field.field_note, :parent => b_item)
          # Beam Type:
          beam_type = case field.treatment_type
            when 'Static' then 'STATIC'
            when 'StepNShoot' then 'STATIC'
            else logger.error("The beam type (treatment type) #{field.treatment_type} is not yet supported.")
          end
          DICOM::Element.new('300A,00C4', beam_type, :parent => b_item)
          # Radiation Type:
          rad_type = case field.modality
            when 'Elect' then 'ELECTRON'
            when 'Xrays' then 'PHOTON'
            else logger.error("The radiation type (modality) #{field.modality} is not yet supported.")
          end
          DICOM::Element.new('300A,00C6', rad_type, :parent => b_item)
          # Treatment Delivery Type:
          DICOM::Element.new('300A,00CE', 'TREATMENT', :parent => b_item)
          # Number of Wedges:
          DICOM::Element.new('300A,00D0', (field.wedge.empty? ? '0' : '1'), :parent => b_item)
          # Number of Compensators:
          DICOM::Element.new('300A,00E0', (field.compensator.empty? ? '0' : '1'), :parent => b_item)
          # Number of Boli:
          DICOM::Element.new('300A,00ED', (field.bolus.empty? ? '0' : '1'), :parent => b_item)
          # Number of Blocks:
          DICOM::Element.new('300A,00F0', (field.block.empty? ? '0' : '1'), :parent => b_item)
          # Final Cumulative Meterset Weight:
          DICOM::Element.new('300A,010E', field.field_monitor_units, :parent => b_item)
          # Number of Control Points:
          DICOM::Element.new('300A,0110', "#{field.control_points.length}", :parent => b_item)
          # Referenced Patient Setup Number:
          DICOM::Element.new('300C,006A', '1', :parent => b_item)
          #
          # Beam Limiting Device Sequence:
          #
          bl_seq = DICOM::Sequence.new('300A,00B6', :parent => b_item)
          # Always create one ASYMX and one ASYMY item:
          bl_item_x = DICOM::Item.new(:parent => bl_seq)
          bl_item_y = DICOM::Item.new(:parent => bl_seq)
          # RT Beam Limiting Device Type:
          DICOM::Element.new('300A,00B8', "ASYMX", :parent => bl_item_x)
          DICOM::Element.new('300A,00B8', "ASYMY", :parent => bl_item_y)
          # Number of Leaf/Jaw Pairs:
          DICOM::Element.new('300A,00BC', "1", :parent => bl_item_x)
          DICOM::Element.new('300A,00BC', "1", :parent => bl_item_y)
          # MLCX item is only created if leaves are defined:
          # (NB: The RTP file doesn't specify leaf position boundaries, so for now we estimate these positions
          # based on the (even) number of leaves and the assumptions of a 200 mm position of the outer leaf)
          # FIXME: In the future, the MLCX leaf position boundary should be configurable - i.e. an option argument of to_dcm().
          if field.control_points.length > 0
            bl_item_mlcx = DICOM::Item.new(:parent => bl_seq)
            DICOM::Element.new('300A,00B8', "MLCX", :parent => bl_item_mlcx)
            num_leaves = field.control_points.first.mlc_leaves.to_i
            logger.warn("Support for odd number of leaves (#{num_leaves}) is not implemented yet. Leaf Position Boundaries tag will be incorrect.") if num_leaves.odd?
            logger.warn("Untested number of leaves encountered: #{num_leaves} Leaf Position Boundaries tag may be incorrect.") if num_leaves.even? && ![40, 80].include?(num_leaves)
            DICOM::Element.new('300A,00BC', num_leaves.to_s, :parent => bl_item_mlcx)
            pos_boundaries = Array.new(num_leaves) {|i| i * 400 / num_leaves.to_f - 200}
            DICOM::Element.new('300A,00BE', "#{pos_boundaries.join("\\")}", :parent => bl_item_mlcx)
          end
          #
          # Block Sequence (if any):
          # FIXME: It seems that the Block Sequence (300A,00F4) may be
          # difficult (impossible?) to reconstruct based on the RTP file's
          # information, and thus it is skipped altogether.
          #
          #
          # Applicator Sequence (if any):
          #
          unless field.e_applicator.empty?
            app_seq = DICOM::Sequence.new('300A,0107', :parent => b_item)
            app_item = DICOM::Item.new(:parent => app_seq)
            # Applicator ID:
            DICOM::Element.new('300A,0108', field.e_field_def_aperture, :parent => app_item)
            # Applicator Type:
            DICOM::Element.new('300A,0109', "ELECTRON_#{field.e_applicator.upcase}", :parent => app_item)
            # Applicator Description:
            DICOM::Element.new('300A,010A', "Appl. #{field.e_field_def_aperture}", :parent => app_item)
          end
          #
          # Control Point Sequence:
          #
          # A field may have 0 (no MLC), 1 (conventional beam with MLC) or 2n (IMRT) control points.
          # The DICOM file shall always contain 2n control points (minimum 2).
          #
          cp_seq = DICOM::Sequence.new('300A,0111', :parent => b_item)
          if field.control_points.length < 2
            # When we have 0 or 1 control point, use settings from field, and insert MLC settings if present:
            # First CP:
            cp_item = DICOM::Item.new(:parent => cp_seq)
            # Control Point Index:
            DICOM::Element.new('300A,0112', "0", :parent => cp_item)
            # Nominal Beam Energy:
            DICOM::Element.new('300A,0114', "#{field.energy.to_f}", :parent => cp_item)
            # Gantry Angle:
            DICOM::Element.new('300A,011E', field.gantry_angle, :parent => cp_item)
            # Gantry Rotation Direction:
            DICOM::Element.new('300A,011F', (field.arc_direction.empty? ? 'NONE' : field.arc_direction), :parent => cp_item)
            # Beam Limiting Device Angle:
            DICOM::Element.new('300A,0120', field.collimator_angle, :parent => cp_item)
            # Beam Limiting Device Rotation Direction:
            DICOM::Element.new('300A,0121', 'NONE', :parent => cp_item)
            # Patient Support Angle:
            DICOM::Element.new('300A,0122', field.couch_pedestal, :parent => cp_item)
            # Patient Support Rotation Direction:
            DICOM::Element.new('300A,0123', 'NONE', :parent => cp_item)
            # Table Top Eccentric Angle:
            DICOM::Element.new('300A,0125', field.couch_angle, :parent => cp_item)
            # Table Top Eccentric Rotation Direction:
            DICOM::Element.new('300A,0126', 'NONE', :parent => cp_item)
            # Table Top Vertical Position:
            DICOM::Element.new('300A,0128', "#{field.couch_vertical.to_f * 10}", :parent => cp_item)
            # Table Top Longitudinal Position:
            DICOM::Element.new('300A,0129', "#{field.couch_longitudinal.to_f * 10}", :parent => cp_item)
            # Table Top Lateral Position:
            DICOM::Element.new('300A,012A', "#{field.couch_lateral.to_f * 10}", :parent => cp_item)
            # Isocenter Position (x\y\z):
            DICOM::Element.new('300A,012C', "#{(p.site_setup.iso_pos_x.to_f * 10).round(2)}\\#{(p.site_setup.iso_pos_y.to_f * 10).round(2)}\\#{(p.site_setup.iso_pos_z.to_f * 10).round(2)}", :parent => cp_item)
            # Source to Surface Distance:
            DICOM::Element.new('300A,0130', "#{field.ssd.to_f * 10}", :parent => cp_item)
            # Cumulative Meterset Weight:
            DICOM::Element.new('300A,0134', "0.0", :parent => cp_item)
            # Beam Limiting Device Position Sequence:
            dp_seq = DICOM::Sequence.new('300A,011A', :parent => cp_item)
            # Always create one ASYMX and one ASYMY item:
            dp_item_x = DICOM::Item.new(:parent => dp_seq)
            dp_item_y = DICOM::Item.new(:parent => dp_seq)
            # RT Beam Limiting Device Type:
            DICOM::Element.new('300A,00B8', "ASYMX", :parent => dp_item_x)
            DICOM::Element.new('300A,00B8', "ASYMY", :parent => dp_item_y)
            # Leaf/Jaw Positions:
            DICOM::Element.new('300A,011C', "#{field.collimator_x1.to_f * 10}\\#{field.collimator_x2.to_f * 10}", :parent => dp_item_x)
            DICOM::Element.new('300A,011C', "#{field.collimator_y1.to_f * 10}\\#{field.collimator_y2.to_f * 10}", :parent => dp_item_y)
            # MLCX:
            if field.control_points.length > 0
              dp_item_mlcx = DICOM::Item.new(:parent => dp_seq)
              # RT Beam Limiting Device Type:
              DICOM::Element.new('300A,00B8', "MLCX", :parent => dp_item_mlcx)
              # Leaf/Jaw Positions:
              pos_a = field.control_points.first.mlc_lp_a.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
              pos_b = field.control_points.first.mlc_lp_b.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
              leaf_pos = "#{pos_a.join("\\")}\\#{pos_b.join("\\")}"
              DICOM::Element.new('300A,011C', leaf_pos, :parent => dp_item_mlcx)
            end
            # Second CP:
            cp_item = DICOM::Item.new(:parent => cp_seq)
            # Control Point Index:
            DICOM::Element.new('300A,0112', "1", :parent => cp_item)
            # Cumulative Meterset Weight:
            DICOM::Element.new('300A,0134', field.field_monitor_units, :parent => cp_item)
          else
            # When we have multiple (2n) control points, iterate and pick settings from the CPs:
            field.control_points.each_slice(2) do |cp1, cp2|
              cp_item1 = DICOM::Item.new(:parent => cp_seq)
              cp_item2 = DICOM::Item.new(:parent => cp_seq)
              # First control point:
              # Control Point Index:
              DICOM::Element.new('300A,0112', "#{cp1.index}", :parent => cp_item1)
              # Nominal Beam Energy:
              DICOM::Element.new('300A,0114', "#{cp1.energy.to_f}", :parent => cp_item1)
              # Gantry Angle:
              DICOM::Element.new('300A,011E', cp1.gantry_angle, :parent => cp_item1)
              # Gantry Rotation Direction:
              DICOM::Element.new('300A,011F', (cp1.gantry_dir.empty? ? 'NONE' : cp1.gantry_dir), :parent => cp_item1)
              # Beam Limiting Device Angle:
              DICOM::Element.new('300A,0120', cp1.collimator_angle, :parent => cp_item1)
              # Beam Limiting Device Rotation Direction:
              DICOM::Element.new('300A,0121', (cp1.collimator_dir.empty? ? 'NONE' : cp1.collimator_dir), :parent => cp_item1)
              # Patient Support Angle:
              DICOM::Element.new('300A,0122', cp1.couch_pedestal, :parent => cp_item1)
              # Patient Support Rotation Direction:
              DICOM::Element.new('300A,0123', (cp1.couch_ped_dir.empty? ? 'NONE' : cp1.couch_ped_dir), :parent => cp_item1)
              # Table Top Eccentric Angle:
              DICOM::Element.new('300A,0125', cp1.couch_angle, :parent => cp_item1)
              # Table Top Eccentric Rotation Direction:
              DICOM::Element.new('300A,0126', (cp1.couch_dir.empty? ? 'NONE' : cp1.couch_dir), :parent => cp_item1)
              # Table Top Vertical Position:
              DICOM::Element.new('300A,0128', "#{cp1.couch_vertical.to_f * 10}", :parent => cp_item1)
              # Table Top Longitudinal Position:
              DICOM::Element.new('300A,0129', "#{cp1.couch_longitudinal.to_f * 10}", :parent => cp_item1)
              # Table Top Lateral Position:
              DICOM::Element.new('300A,012A', "#{cp1.couch_lateral.to_f * 10}", :parent => cp_item1)
              # Isocenter Position (x\y\z):
              DICOM::Element.new('300A,012C', "#{(p.site_setup.iso_pos_x.to_f * 10).round(2)}\\#{(p.site_setup.iso_pos_y.to_f * 10).round(2)}\\#{(p.site_setup.iso_pos_z.to_f * 10).round(2)}", :parent => cp_item1)
              # Source to Surface Distance:
              DICOM::Element.new('300A,0130', "#{cp1.ssd.to_f * 10}", :parent => cp_item1)
              # Cumulative Meterset Weight:
              mu_weight = (cp1.monitor_units.to_f * field.field_monitor_units.to_f).round(4)
              DICOM::Element.new('300A,0134', "#{mu_weight}", :parent => cp_item1)
              # Beam Limiting Device Position Sequence:
              dp_seq = DICOM::Sequence.new('300A,011A', :parent => cp_item1)
              # Always create one ASYMX and one ASYMY item:
              dp_item_x = DICOM::Item.new(:parent => dp_seq)
              dp_item_y = DICOM::Item.new(:parent => dp_seq)
              # RT Beam Limiting Device Type:
              DICOM::Element.new('300A,00B8', "ASYMX", :parent => dp_item_x)
              DICOM::Element.new('300A,00B8', "ASYMY", :parent => dp_item_y)
              # Leaf/Jaw Positions:
              DICOM::Element.new('300A,011C', "#{field.collimator_x1.to_f * 10}\\#{field.collimator_x2.to_f * 10}", :parent => dp_item_x)
              DICOM::Element.new('300A,011C', "#{field.collimator_y1.to_f * 10}\\#{field.collimator_y2.to_f * 10}", :parent => dp_item_y)
              # MLCX:
              dp_item_mlcx = DICOM::Item.new(:parent => dp_seq)
              # RT Beam Limiting Device Type:
              DICOM::Element.new('300A,00B8', "MLCX", :parent => dp_item_mlcx)
              # Leaf/Jaw Positions:
              pos_a = cp1.mlc_lp_a.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
              pos_b = cp1.mlc_lp_b.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
              leaf_pos = "#{pos_a.join("\\")}\\#{pos_b.join("\\")}"
              DICOM::Element.new('300A,011C', leaf_pos, :parent => dp_item_mlcx)
              # Second control point:
              # Always include index and cumulative weight:
              DICOM::Element.new('300A,0112', "#{cp2.index}", :parent => cp_item2)
              mu_weight = (cp2.monitor_units.to_f * field.field_monitor_units.to_f).round(4)
              DICOM::Element.new('300A,0134', "#{mu_weight}", :parent => cp_item2)
              # The other parameters are only included if they have changed from the previous control point:
              # Nominal Beam Energy:
              DICOM::Element.new('300A,0114', "#{cp2.energy.to_f}", :parent => cp_item2) if cp2.energy != cp1.energy
              # Gantry Angle:
              DICOM::Element.new('300A,011E', cp2.gantry_angle, :parent => cp_item2) if cp2.gantry_angle != cp1.gantry_angle
              # Gantry Rotation Direction:
              DICOM::Element.new('300A,011F', (cp2.gantry_dir.empty? ? 'NONE' : cp2.gantry_dir), :parent => cp_item2) if cp2.gantry_dir != cp1.gantry_dir
              # Beam Limiting Device Angle:
              DICOM::Element.new('300A,0120', cp2.collimator_angle, :parent => cp_item2) if cp2.collimator_angle != cp1.collimator_angle
              # Beam Limiting Device Rotation Direction:
              DICOM::Element.new('300A,0121', (cp2.collimator_dir.empty? ? 'NONE' : cp2.collimator_dir), :parent => cp_item2) if cp2.collimator_dir != cp1.collimator_dir
              # Patient Support Angle:
              DICOM::Element.new('300A,0122', cp2.couch_pedestal, :parent => cp_item2) if cp2.couch_pedestal != cp1.couch_pedestal
              # Patient Support Rotation Direction:
              DICOM::Element.new('300A,0123', (cp2.couch_ped_dir.empty? ? 'NONE' : cp2.couch_ped_dir), :parent => cp_item2) if cp2.couch_ped_dir != cp1.couch_ped_dir
              # Table Top Eccentric Angle:
              DICOM::Element.new('300A,0125', cp2.couch_angle, :parent => cp_item2) if cp2.couch_angle != cp1.couch_angle
              # Table Top Eccentric Rotation Direction:
              DICOM::Element.new('300A,0126', (cp2.couch_dir.empty? ? 'NONE' : cp2.couch_dir), :parent => cp_item2) if cp2.couch_dir != cp1.couch_dir
              # Table Top Vertical Position:
              DICOM::Element.new('300A,0128', "#{cp2.couch_vertical.to_f * 10}", :parent => cp_item2) if cp2.couch_vertical != cp1.couch_vertical
              # Table Top Longitudinal Position:
              DICOM::Element.new('300A,0129', "#{cp2.couch_longitudinal.to_f * 10}", :parent => cp_item2) if cp2.couch_longitudinal != cp1.couch_longitudinal
              # Table Top Lateral Position:
              DICOM::Element.new('300A,012A', "#{cp2.couch_lateral.to_f * 10}", :parent => cp_item2) if cp2.couch_lateral != cp1.couch_lateral
              # Source to Surface Distance:
              DICOM::Element.new('300A,0130', "#{cp2.ssd.to_f * 10}", :parent => cp_item2) if cp2.ssd != cp1.ssd
              # Beam Limiting Device Position Sequence:
              dp_seq = DICOM::Sequence.new('300A,011A', :parent => cp_item2)
              # ASYMX:
              if cp2.collimator_x1 != cp1.collimator_x1
                dp_item_x = DICOM::Item.new(:parent => dp_seq)
                DICOM::Element.new('300A,00B8', "ASYMX", :parent => dp_item_x)
                DICOM::Element.new('300A,011C', "#{field.collimator_x1.to_f * 10}\\#{field.collimator_x2.to_f * 10}", :parent => dp_item_x)
              end
              # ASYMY:
              if cp2.collimator_y1 != cp1.collimator_y1
                dp_item_y = DICOM::Item.new(:parent => dp_seq)
                DICOM::Element.new('300A,00B8', "ASYMY", :parent => dp_item_y)
                DICOM::Element.new('300A,011C', "#{field.collimator_y1.to_f * 10}\\#{field.collimator_y2.to_f * 10}", :parent => dp_item_y)
              end
              # MLCX:
              if cp2.mlc_lp_a != cp1.mlc_lp_a or cp2.mlc_lp_b != cp1.mlc_lp_b
                dp_item_mlcx = DICOM::Item.new(:parent => dp_seq)
                # RT Beam Limiting Device Type:
                DICOM::Element.new('300A,00B8', "MLCX", :parent => dp_item_mlcx)
                # Leaf/Jaw Positions:
                pos_a = cp2.mlc_lp_a.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
                pos_b = cp2.mlc_lp_b.collect{|p| (p.to_f * 10).round(2) unless p.empty?}.compact
                leaf_pos = "#{pos_a.join("\\")}\\#{pos_b.join("\\")}"
                DICOM::Element.new('300A,011C', leaf_pos, :parent => dp_item_mlcx)
              end
            end
          end
        end
      end
      return dcm
    end

  end

end