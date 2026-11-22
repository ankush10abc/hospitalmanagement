// Exact port of the D, HD, SP, CN data from Platform.html
class PD {
  // OPD: [specialty, patients/day @100beds, fee ₹]
  static const opd = [
    ['General Medicine', 52.0, 300.0],
    ['Cardiology', 5.0, 500.0],
    ['Obs & Gynaecology', 29.0, 500.0],
    ['General Surgery', 19.0, 500.0],
    ['Orthopaedic', 26.0, 500.0],
    ['Neurology', 5.0, 500.0],
    ['Oncology', 8.0, 500.0],
    ['Urology / Nephrology', 5.0, 500.0],
    ['ENT', 13.0, 500.0],
    ['Gastroenterology', 10.0, 500.0],
    ['Repeat visits (extra)', 25.0, 200.0],
  ];

  // Room: [category, bed share, rate ₹/day]
  static const room = [
    ['ICU', 0.14, 4500.0],
    ['SICU', 0.06, 4500.0],
    ['NICU', 0.04, 4500.0],
    ['Deluxe Room', 0.03, 3800.0],
    ['Single Room', 0.10, 2500.0],
    ['Twin Sharing', 0.12, 1800.0],
    ['General Ward', 0.20, 800.0],
    ['Ayushman / Scheme', 0.20, 400.0],
    ['Emergency', 0.03, 2000.0],
    ['Day Care', 0.06, 700.0],
    ['Dialysis', 0.02, 1200.0],
  ];

  // Diag: [test, opd share, ipd share, rate ipd ₹, rate opd ₹]
  static const diag = [
    ['Pathology', 0.20, 0.32, 1000.0, 650.0],
    ['X-ray', 0.12, 0.22, 400.0, 350.0],
    ['Sonography', 0.07, 0.15, 1000.0, 900.0],
    ['CT Scan', 0.02, 0.06, 3000.0, 2500.0],
    ['MRI', 0.015, 0.03, 6000.0, 5500.0],
    ['ECG', 0.10, 0.20, 200.0, 200.0],
    ['2D Echo', 0.04, 0.02, 1300.0, 1200.0],
    ['TMT', 0.05, 0.03, 1000.0, 800.0],
  ];

  // OTC: [case type, cases/day @100beds, avg ₹/case]
  static const otc = [
    ['Ortho major', 1.0, 45000.0],
    ['Ortho minor', 1.0, 16000.0],
    ['Onco major', 1.0, 55000.0],
    ['Onco minor', 1.0, 25000.0],
    ['Uro major', 1.0, 24000.0],
    ['Uro minor', 1.0, 15000.0],
    ['Labour OT / C-section', 1.0, 18000.0],
    ['Normal delivery', 2.0, 12000.0],
    ['ENT', 1.0, 12000.0],
    ['Gen surgery major', 1.5, 20000.0],
    ['Gen surgery minor', 2.0, 8000.0],
    ['Laparoscopy', 2.0, 32000.0],
    ['Emergency / trauma minor', 1.0, 5000.0],
  ];

  // Staff: [designation, qty @100beds, salary ₹/mo, scales(1=yes)]
  static const staff = [
    ['Pathologist', 0.0, 200000.0, 0],
    ['Radiologist / Sonologist', 0.0, 250000.0, 0],
    ['Senior Surgeon', 1.0, 180000.0, 0],
    ['Sr. Resident', 1.0, 120000.0, 0],
    ['RMO (Non-MBBS)', 6.0, 40000.0, 1],
    ['Casualty medical officer', 0.0, 25000.0, 1],
    ['Dietician', 0.0, 20000.0, 0],
    ['Nursing Superintendent', 1.0, 30000.0, 0],
    ['Nurses (OT + ward + ICU)', 62.0, 12000.0, 1],
    ['Lab & Blood bank technician', 2.0, 15000.0, 1],
    ['X-ray technician', 2.0, 15000.0, 1],
    ['Dialysis technician', 1.0, 20000.0, 0],
    ['OT technicians', 4.0, 18000.0, 1],
    ['Operations manager', 1.0, 40000.0, 0],
    ['Executive operations', 2.0, 18000.0, 1],
    ['Front office executive', 2.0, 15000.0, 1],
    ['Admission & billing executive', 5.0, 15000.0, 1],
    ['Pharmacists', 2.0, 18000.0, 1],
    ['Supervisor / facility manager', 1.0, 18000.0, 0],
    ['Drivers', 2.0, 15000.0, 0],
    ['Security guards', 2.0, 12000.0, 1],
    ['Housekeeping (ward boys, cleaners)', 14.0, 12000.0, 1],
    ['Lift man', 1.0, 12000.0, 0],
    ['Laundry man', 1.0, 15000.0, 0],
    ['Sr. Accountant', 1.0, 25000.0, 0],
    ['Jr. Accountant', 1.0, 12000.0, 0],
    ['HR manager', 1.0, 30000.0, 0],
    ['Asst. HR manager', 1.0, 15000.0, 0],
    ['Marketing manager', 1.0, 35000.0, 0],
    ['Asst. marketing manager', 1.0, 22000.0, 0],
    ['Sr. marketing executive', 1.0, 15000.0, 0],
    ['TPA / scheme executive', 1.0, 15000.0, 1],
    ['Biomedical engineer', 1.0, 25000.0, 0],
    ['IT executive', 1.0, 10000.0, 0],
  ];

  // Eq: [dept, item, unit ₹ lakh, basis(f/bed/icu/ot), factor]
  static const eq = [
    ['ICU', 'Ventilators', 12.0, 'icu', 0.5],
    ['ICU', 'Multipara monitors', 0.65, 'icu', 1.5],
    ['ICU', 'Syringe / infusion pumps', 0.2, 'icu', 3.0],
    ['ICU', 'Defibrillators', 2.25, 'f', 2.0],
    ['ICU', 'ABG analyser', 6.0, 'f', 1.0],
    ['OT / CSSD', 'C-Arm', 10.5, 'f', 1.0],
    ['OT / CSSD', 'Autoclave (CSSD)', 25.0, 'f', 1.0],
    ['OT / CSSD', 'ETO / plasma steriliser', 18.0, 'f', 1.0],
    ['OT / CSSD', 'Washer disinfector', 12.0, 'f', 1.0],
    ['OT / CSSD', 'Shared OT utilities per OT', 3.0, 'ot', 1.0],
    ['Radiology', 'Digital X-Ray', 18.0, 'f', 1.0],
    ['Radiology', 'Mobile X-Ray', 6.0, 'f', 1.0],
    ['Radiology', 'USG colour doppler', 12.0, 'f', 2.0],
    ['Laboratory', 'Haematology analyser', 9.0, 'f', 1.0],
    ['Laboratory', 'Biochemistry analyser', 15.0, 'f', 1.0],
    ['Laboratory', 'Immunoassay analyser', 18.0, 'f', 1.0],
    ['Laboratory', 'Blood bank equipment', 4.0, 'f', 1.0],
    ['Cardiology', 'ECG machines', 0.8, 'f', 2.0],
    ['Cardiology', 'TMT', 6.0, 'f', 1.0],
    ['Cardiology', '2D Echo colour doppler', 14.0, 'f', 1.0],
    ['Dialysis', 'Dialysis machines', 6.0, 'f', 2.0],
    ['Wards', 'Suction & O2 flowmeters / bed', 0.15, 'bed', 1.0],
    ['Wards', 'Vitals monitors, BP, glucometers / bed', 0.2, 'bed', 1.0],
    ['Emergency', 'Transport ventilator & crash carts', 8.0, 'f', 2.0],
    ['Physio', 'Physiotherapy lot', 8.0, 'f', 1.0],
    ['OPD', 'OPD examination & procedure lot', 10.0, 'f', 1.0],
  ];

  // Ad: [item, ₹ lakh]
  static const ad = [
    ['MRI 1.5T', 600.0],
    ['MRI 3T', 1100.0],
    ['CT 32 slice', 200.0],
    ['CT 128 slice', 500.0],
    ['Cath Lab', 800.0],
    ['PET CT', 1200.0],
    ['LINAC', 2800.0],
  ];

  // NM: [item, fixed ₹ lakh, per bed ₹ lakh]
  static const nm = [
    ['Nurse call system', 2.0, 0.03],
    ['Medical gas pipeline & cylinders', 4.0, 0.35],
    ['Computers & hardware', 0.0, 0.048],
    ['HIMS with PACS', 2.0, 0.0],
    ['EPBX & biometric', 1.2, 0.0],
    ['CCTV', 1.75, 0.0],
    ['Laundry & kitchen equipment', 12.0, 0.0],
  ];

  // Fr: [item, unit rate ₹]
  static const fr = [
    ['ICU hi-lo bed', 79200.0],
    ['Fowler bed (deluxe/single/twin)', 45000.0],
    ['Ward bed', 21600.0],
    ['Casualty bed', 65000.0],
    ['Dialysis chair', 35000.0],
    ['Overbed table', 4500.0],
    ['Relatives couch', 5500.0],
    ['Examination table', 7200.0],
  ];

  // Lump: [section, ₹ lakh @100 beds]
  static const lump = [
    ['Office furniture', 5.2],
    ['Pharmacy', 1.57],
    ['Central stores', 2.0],
    ['Medical records & library', 1.33],
    ['Engineering & maintenance', 0.15],
  ];

  // Pre: [item, ₹ lakh]
  static const pre = [
    ['Deposits & approvals', 2.0],
    ['Insurance', 2.25],
    ['Pre-marketing', 4.0],
    ['Site office (₹ lakh per month of gestation)', 0.38],
  ];

  // OTT: [type, count, equip ₹L/OT, furn ₹L/OT, fitout ₹L/OT]
  static const ott = [
    ['Modular OT', 2.0, 150.0, 5.0, 50.0],
    ['General OT', 1.0, 80.0, 3.0, 20.0],
    ['Labour OT', 1.0, 60.0, 3.0, 15.0],
    ['Minor OT', 1.0, 25.0, 1.5, 5.0],
    ['Emergency OT', 1.0, 70.0, 3.0, 15.0],
  ];

  // Cities: [name, cost index]
  static const cities = [
    ['Ahmedabad', 1.0],
    ['Surat', 0.95],
    ['Rajkot', 0.9],
    ['Pune', 1.1],
    ['Bengaluru', 1.2],
    ['Delhi NCR', 1.25],
    ['Mumbai', 1.35],
    ['Tier-3 city', 0.8],
  ];

  // City norms: [fsi, gc%, maxH, landRate]
  static const cityNorms = [
    [1.8, 50.0, 45.0, 8000.0],
    [1.8, 50.0, 45.0, 7000.0],
    [1.8, 50.0, 45.0, 5000.0],
    [1.5, 40.0, 40.0, 9000.0],
    [2.0, 50.0, 50.0, 10000.0],
    [2.0, 40.0, 60.0, 15000.0],
    [2.5, 50.0, 70.0, 25000.0],
    [1.5, 50.0, 24.0, 2500.0],
  ];

  static const hospitalTypes = [
    ['multi', 'Multi Specialty'],
    ['single', 'Single Specialty'],
    ['super', 'Super Specialty'],
    ['onco', 'Oncology'],
    ['cardiac', 'Cardiac'],
    ['ortho', 'Orthopedic'],
    ['wc', 'Women & Child'],
    ['ivf', 'IVF'],
    ['diag', 'Diagnostic Center'],
    ['day', 'Day Care Center'],
  ];

  static const utilDefaults = [
    24.0,
    34.0,
    45.0,
    50.0,
    55.0,
    58.0,
    60.0,
    62.0,
    64.0,
    65.0,
  ];

  /// Returns the reason a service is unavailable, or null when it is allowed.
  /// These are the same capacity and hospital type rules used by Platform.html.
  static String? serviceRestriction(
    String key, {
    required String hospitalType,
    required double beds,
  }) {
    switch (key) {
      case 'mri':
        return beds >= 50 && !['ivf', 'day'].contains(hospitalType)
            ? null
            : 'Needs 50+ beds and a diagnostic-capable type';
      case 'ct':
        return beds >= 30 && hospitalType != 'ivf' ? null : 'Needs 30+ beds';
      case 'cath':
        return ['cardiac', 'multi', 'super'].contains(hospitalType) &&
                beds >= 50
            ? null
            : 'Only cardiac/multi/super with 50+ beds';
      case 'pet':
        return beds >= 200 &&
                ['multi', 'super', 'onco', 'diag'].contains(hospitalType)
            ? null
            : 'Only 200+ bed multi/super/oncology';
      case 'linac':
        return ['onco', 'super'].contains(hospitalType) ||
                (hospitalType == 'multi' && beds >= 200)
            ? null
            : 'Only oncology/super (or 200+ bed multi)';
      default:
        return null;
    }
  }
}
