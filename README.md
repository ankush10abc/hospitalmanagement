# hospitalmanagement

A new Flutter project.

## Admin authentication setup

The admin sign-in uses Supabase Auth. Create a Supabase project, enable
email/password sign-in, and run the web app with your project URL and the
publishable (or legacy anon) key:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY
```

Create or invite the administrator account in Supabase Auth. The account must
have a server-managed `app_metadata.role` set to one of `admin`,
`super_admin`, `finance_reviewer`, `data_manager`, `support_operator`, or
`read_only_auditor`. Never put a Supabase service-role key in the Flutter app;
assign roles from a trusted server. Protect database data with server-side
authorization and Row Level Security policies as well—the Flutter role check
only controls the client UI.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# MASTER PROJECT PROMPT – Hospital & Clinic Estimation Platform

Act as a Senior Flutter Architect, Python Backend Engineer, Financial Software Architect, Database Designer and UI/UX Designer.

I want to develop a complete, production-ready Hospital & Clinic Project Estimation Platform using Flutter Web, Android and iOS.

## 1. Reference Excel Workbook

First, inspect the complete uploaded Excel workbook:

`Final CMA Report calculation sheet.xlsx`

It contains 15 interconnected worksheets:

1. Assumptions
2. COP
3. final revenue model
4. FINAL expenses
5. P&L
6. Ratios
7. BS
8. TL & WC
9. Cash Flow
10. Depreciation
11. Furniture
12. Amulance and Vehicle
13. non medical equipment
14. final equipment list
15. MEDICAL EQUI.

IMPORTANT:
- Inspect every worksheet, including formulas, linked cells, quantities, rates and calculation dependencies.
- Do not ignore any worksheet.
- Preserve the workbook's calculation methodology and business logic.
- Identify conflicting assumptions and broken or questionable formulas.
- Do not silently correct the original workbook.
- Create a validation list of all discrepancies.
- Use the original workbook as the initial data and calculation reference.
- Do not replace missing source values with invented figures.

## 2. Project Objective

Build an application where hospital owners, clinic owners and healthcare consultants can register, create projects and enter their hospital information.

The application should dynamically estimate:

- Hospital construction cost.
- Land and building cost.
- Medical equipment.
- Non-medical equipment.
- Furniture and fixtures.
- Ambulances and vehicles.
- Staff requirements and salaries.
- Hospital revenue.
- Operating expenses.
- Total cost of project.
- Means of finance.
- Working capital.
- Term loan repayment.
- Profit and Loss.
- Balance Sheet.
- Cash Flow.
- Depreciation.
- DSCR.
- IRR.
- ROI.
- Break-even point.
- Payback period.
- Complete 10-year CMA financial projections.

All calculations must be dynamic.

A user should be able to create a 20-bed clinic, 30-bed hospital, 60-bed hospital, 100-bed hospital or 200-bed hospital without requiring changes to application code.

## 3. Technology Stack

Frontend:
- Flutter latest stable version.
- Flutter Web, Android and iOS.
- Riverpod for state management.
- GoRouter for navigation.
- Dio for API integration.
- Clean Architecture.
- Feature-first folder structure.
- Responsive UI for mobile, tablet and desktop.

Backend:
- Python FastAPI.
- REST APIs.
- Pydantic validation.
- Calculation engine.
- Financial calculation services.
- PDF and Excel report generation.

Database:
- Supabase Authentication.
- PostgreSQL.
- Supabase Storage.
- Role-based authorization.

Keep calculations in the backend. Flutter must not independently calculate financial statements.

## 4. User Roles

Create the following roles:

1. Super Admin
2. Admin
3. Healthcare Consultant
4. Hospital Owner
5. Viewer

Implement role-based access control.

Hospital owners must only access their authorized projects. Consultants should be able to manage multiple client projects.

## 5. Application Modules

### Module A: Authentication
- Signup.
- Login.
- Email verification.
- Forgot password.
- Profile management.
- Organization management.

### Module B: Dashboard
Show:
- Total projects.
- Draft projects.
- Completed projects.
- Total estimated project investment.
- Recent projects.
- Project status.
- Create New Project button.

### Module C: Project Creation

Collect:
- Project name.
- Hospital name.
- Hospital type.
- New / Existing / Expansion.
- Owner details.
- State.
- City.
- Address.
- Project start year.
- Financial projection period.

Support different project types:
- Multispeciality Hospital.
- General Hospital.
- Specialty Hospital.
- Eye Hospital.
- Dental Clinic.
- General Clinic.
- Diagnostic Centre.
- Nursing Home.
- Day Care Centre.

### Module D: Dynamic Assumptions Wizard

Create a multi-step form.

Step 1: Basic project details.

Step 2: Location details:
- State.
- City.
- District.
- Address.

Step 3: Hospital capacity:
- Total beds.
- ICU.
- SICU.
- NICU.
- General Ward.
- Deluxe.
- Single Room.
- Twin Sharing.
- Emergency.
- Day Care.
- Dialysis.

Step 4: Land and building:
- Plot area.
- Carpet area.
- Built-up area.
- Area per bed.
- Number of floors.
- Land cost.
- Construction rate.

Step 5: Hospital services:
- OPD.
- IPD.
- OT.
- ICU.
- Radiology.
- Pathology.
- Cardiology.
- Dialysis.
- Emergency.
- Pharmacy.
- Blood Bank.
- Physiotherapy.
- CSSD.

Step 6: Operating assumptions:
- OPD operating days.
- Surgery operating days.
- Bed operating days.
- Patients per day.
- Capacity utilization.
- Project gestation period.

Step 7: Financial assumptions:
- Interest rates.
- Promoter contribution.
- Bank debt.
- Loan tenure.
- Moratorium.
- Repayment frequency.
- Inflation.
- Tax.
- Depreciation.
- Contingency.

All fields must be editable and configurable.

Save wizard progress automatically.

### Module E: Land and Building Estimation

Create dynamic calculation tables for:
- Land cost.
- RCC.
- Masonry.
- Waterproofing.
- Interior.
- Electrical.
- HVAC.
- Plumbing.
- Firefighting.
- Elevators.
- Landscaping.
- Consultant fees.
- Contingency.

Formula:

Total Amount = Quantity × Unit Rate.

Allow adding custom construction items.

### Module F: Medical Equipment

Create a dynamic equipment catalog based on the workbook.

Organize by department:

- Operating Theatre.
- ICU.
- SICU.
- NICU.
- Radiology.
- Cardiology.
- Dialysis.
- Emergency.
- Laboratory.
- Blood Bank.
- CSSD.
- Physiotherapy.
- Other specialty departments.

Every equipment record must contain:
- Equipment name.
- Department.
- Brand.
- Model.
- Description.
- Unit.
- Default quantity.
- Unit price.
- Total price.
- Optional / Mandatory status.

Allow users to add, edit, remove and select equipment.

### Module G: Furniture and Non-Medical Equipment

Create separate dynamic catalogs for:
- Patient furniture.
- Office furniture.
- Pharmacy.
- Central stores.
- Medical records.
- Engineering and maintenance.
- Laundry.
- Kitchen.
- Dining.
- Computers.
- HIMS and PACS.
- Nurse call systems.
- Medical gases.

### Module H: Vehicles

Include:
- Normal ambulance.
- Mobile clinic.
- Other vehicles.

Allow dynamic quantity and unit pricing.

### Module I: Staff and Salary Estimation

Create categories:
- Consultants.
- Doctors.
- Nurses.
- Paramedical.
- Technicians.
- Operations.
- Front office.
- Pharmacy.
- Housekeeping.
- Security.
- Finance.
- HR.
- IT.
- Maintenance.

Fields:
- Designation.
- Department.
- Employee count.
- Monthly salary.
- Monthly total.
- Annual total.
- Salary inflation.

Allow users to add custom designations.

### Module J: Revenue Estimation

Create separate calculators for:

1. OPD Revenue.
2. Room/IPD Revenue.
3. Diagnostics Revenue.
4. OT Revenue.
5. Pharmacy Revenue.
6. Blood Bank Revenue.
7. Ambulance Revenue.
8. Canteen Revenue.
9. Other Revenue.

OPD formula:

Annual Revenue = Patients per Day × Consultation Fee × Operating Days.

IPD formula:

Annual Revenue = Number of Beds × Daily Rate × Occupancy × Operating Days.

Diagnostics:
Calculate inpatient and outpatient productivity separately.

OT:
Calculate surgeries per day, average charges and operating days.

Pharmacy:
Calculate inpatient and outpatient revenue separately.

Allow custom revenue categories.

### Module K: Cost of Project

Automatically combine:

- Land and building.
- Medical equipment.
- Non-medical equipment.
- Vehicles.
- Furniture.
- Pre-operative expenses.
- Working capital margin.

Generate Cost of Project and Means of Finance.

Calculate:
- Total project cost.
- Promoter contribution.
- Bank debt.
- Other funding.

### Module L: Financial Calculation Engine

Implement the workbook's financial methodology in separate backend services.

Required calculations:

1. 10-year P&L.
2. Projected Balance Sheet.
3. 10-year Cash Flow.
4. Depreciation under both methods in the workbook.
5. Term Loan Repayment Schedule.
6. Working Capital.
7. DSCR.
8. Average DSCR.
9. Project IRR.
10. Equity IRR.
11. ROI.
12. Break-even.
13. Cash Break-even.
14. Payback Period.

Create independent, testable calculation functions.

Use precise decimal arithmetic for monetary values.

Implement dependency tracking so changing an assumption automatically recalculates all dependent results.

Prevent circular dependencies.

Every calculation should have an explanation showing its inputs, formula and output.

### Module M: Admin Panel

The admin must be able to manage:

- Hospital categories.
- Departments.
- Bed categories.
- Equipment catalogs.
- Equipment prices.
- Furniture catalogs.
- Vehicles.
- Salary templates.
- Construction rates.
- Revenue templates.
- Financial assumptions.
- Tax rates.
- Interest rates.
- Depreciation rates.
- Calculation rules.
- Report templates.

All master data must be stored in PostgreSQL.

Never hardcode catalog prices, quantities or assumption defaults in Flutter screens.

Implement configuration versioning.

Existing projects must preserve their saved assumptions and prices when an administrator updates a template.

### Module N: CMA Report Generation

Generate professional PDF and Excel reports.

Include all major sections from the original workbook:

- Project overview.
- Assumptions.
- Building estimation.
- Medical equipment.
- Non-medical equipment.
- Furniture.
- Vehicles.
- Staff estimation.
- Revenue projections.
- Cost of Project.
- Means of Finance.
- P&L.
- Balance Sheet.
- Cash Flow.
- Depreciation.
- Loan repayment.
- Working Capital.
- Financial Ratios.
- DSCR.
- IRR.
- ROI.
- Break-even.
- Payback Period.

Provide:
- PDF download.
- Excel download.
- Print.
- Report version history.
- Project-wise report storage.

## 6. Dynamic Calculation Requirements

The application must not use fixed assumptions such as 60, 80 or 100 beds.

All quantities should come from project data or configurable rules.

For example:

When a user changes total beds from 60 to 100:
1. Update bed distribution.
2. Recalculate building area where configured.
3. Recalculate equipment quantities where configured.
4. Recalculate furniture requirements.
5. Recalculate staffing.
6. Recalculate revenue.
7. Recalculate operating expenses.
8. Recalculate project cost.
9. Recalculate funding.
10. Recalculate all financial statements.

Some values must use configurable scaling rules rather than simple proportional multiplication.

Support manual overrides.

Clearly distinguish:
- Workbook default.
- Admin default.
- System-calculated value.
- User override.

## 7. Database Design

Create normalized PostgreSQL tables.

At minimum:

- users
- organizations
- projects
- project_assumptions
- departments
- bed_categories
- project_beds
- equipment_catalog
- project_equipment
- furniture_catalog
- project_furniture
- vehicles
- project_vehicles
- staff_designations
- project_staff
- construction_rates
- project_construction
- revenue_templates
- project_revenue
- expense_templates
- calculation_rules
- calculation_results
- financial_projections
- report_versions
- audit_logs

Create proper relationships, foreign keys, indexes and row-level security policies.

## 8. UI/UX Requirements

Design a modern professional healthcare SaaS application.

Use:
- Clean dashboard.
- Sidebar navigation on desktop.
- Bottom navigation where appropriate on mobile.
- Step progress indicators.
- Responsive tables.
- Dynamic forms.
- Searchable dropdowns.
- Add/remove rows.
- Inline editing.
- Calculation summary cards.
- Charts and graphs.
- Save Draft.
- Next and Previous buttons.
- Review Before Submit.

Every module should show its calculated subtotal and grand total.

Use INR formatting:
- ₹
- Lakhs.
- Crores.

## 9. Project Folder Structure

Create a feature-first Flutter architecture.

lib/
- core/
  - config/
  - constants/
  - network/
  - router/
  - theme/
  - utils/
  - widgets/
- features/
  - authentication/
  - dashboard/
  - projects/
  - assumptions/
  - building/
  - beds/
  - medical_equipment/
  - non_medical_equipment/
  - furniture/
  - vehicles/
  - staff/
  - revenue/
  - cost_of_project/
  - finance/
  - reports/
  - admin/
- main.dart

Backend:

backend/
- app/
  - api/
  - core/
  - models/
  - schemas/
  - repositories/
  - services/
  - calculations/
  - reports/
  - tests/
- migrations/
- main.py

## 10. Development Instructions

Do not generate the entire application in one step.

Work in phases.

PHASE 1:
- Inspect the complete Excel workbook.
- Document all sheets and formula dependencies.
- Identify inconsistencies.
- Prepare the database schema.
- Prepare the Flutter and FastAPI architecture.
- Set up the development environment.

PHASE 2:
- Implement authentication.
- Implement user roles.
- Implement project creation.
- Implement dynamic assumptions wizard.
- Implement saving and editing projects.

PHASE 3:
- Implement building estimation.
- Implement bed distribution.
- Implement medical equipment.
- Implement non-medical equipment.
- Implement furniture and vehicles.

PHASE 4:
- Implement staff and expenses.
- Implement revenue estimation.
- Implement COP.
- Implement Means of Finance.

PHASE 5:
- Implement all financial calculations.
- Compare outputs against the original Excel workbook.

PHASE 6:
- Implement PDF and Excel reports.
- Implement Admin Configuration.
- Implement testing.
- Prepare production deployment.

At the end of each phase:
1. Explain what has been implemented.
2. Show the created or modified files.
3. Run relevant tests.
4. Report any errors.
5. Confirm which features are working.
6. Wait for approval before starting the next phase.

## 11. Critical Development Rules

- Do not hardcode financial calculations in UI widgets.
- Do not hardcode equipment catalogs in Flutter.
- Do not hardcode hospital capacity.
- Do not duplicate calculation logic.
- Do not silently change Excel formulas.
- Do not invent missing financial data.
- Do not overwrite existing user project data.
- Implement proper validation and error handling.
- Maintain audit logs for important financial changes.
- Use transactions for financial calculations and saving results.
- Test calculations against the original Excel reference.
- Protect sensitive hospital and financial project information.
- Keep the application responsive for mobile and web.

## 12. First Task

Start ONLY with PHASE 1.

First inspect the complete Excel workbook, map all 15 sheets and their formulas, identify inconsistent values and create a detailed implementation plan.

Then provide:
1. Workbook analysis.
2. Formula dependency mapping.
3. Database ER diagram.
4. Flutter architecture.
5. FastAPI architecture.
6. Development roadmap.
7. Testing strategy.

Do not start building all screens until the architecture and calculation mapping have been reviewed.

The final objective is a configurable, multi-user Hospital & Clinic Estimation SaaS Platform that can generate complete, dynamically calculated project feasibility and CMA reports for hospitals and clinics of different sizes.
