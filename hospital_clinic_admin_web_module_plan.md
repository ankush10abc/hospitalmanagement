# Hospital & Clinic Estimation Platform --- Web Admin Planning

**Document type:** Module-wise product and implementation plan\
**Source workbook:** `Final CMA Report calculation sheet.xlsx`\
**Target:** Admin web application for managing users, hospital projects,
master data, assumptions, estimation rules, calculations, and reports\
**Recommended stack:** Flutter Web (admin UI), FastAPI (backend),
PostgreSQL/Supabase (database and authentication), object storage
(reports and source files)

------------------------------------------------------------------------

## 1. Purpose and scope

Build a secure web-based Admin Portal that controls the Hospital &
Clinic Estimation Platform. Admin users should manage the data and rules
that the customer-facing Flutter app uses to create hospital/clinic
estimates.

The Admin Portal is not merely a dashboard. It is the control centre
for:

-   User and organization administration.
-   Hospital/clinic project oversight.
-   State, city, hospital type, department, and bed-category masters.
-   Equipment, furniture, vehicle, construction, staffing, revenue, and
    expense catalogs.
-   Default assumptions and project templates.
-   Versioned calculation rules.
-   Calculation validation against the source Excel workbook.
-   CMA report templates, generation, and history.
-   Audit logs, access control, and system settings.

**Key architecture rule:** The admin web UI manages configuration and
data. Financial calculations are executed by the backend calculation
service. Do not implement financial formulas directly in Flutter widgets
or treat the browser as the financial source of truth.

## 2. Source workbook inventory

The uploaded workbook contains these 15 worksheets. Use these names as
the source mapping; do not silently rename or omit workbook sections.

  -----------------------------------------------------------------------
  Excel worksheet                     Admin-managed area / platform
                                      module
  ----------------------------------- -----------------------------------
  Assumptions                         Default assumptions, project
                                      assumptions, financial parameters

  COP                                 Cost of Project and Means of
                                      Finance configuration

  final revenue model                 Revenue categories and revenue
                                      calculation inputs

  FINAL expenses                      Staff designations, salary inputs,
                                      and expense assumptions

  P&L                                 Profit & Loss statement mapping and
                                      projection rules

  Ratios                              Financial ratio definitions and
                                      calculation rules

  BS                                  Balance Sheet mapping and
                                      projection rules

  TL & WC                             Term-loan repayment and
                                      working-capital rules

  Cash Flow                           Cash-flow statement mapping and
                                      projection rules

  Depreciation                        Depreciation asset classes and
                                      IT/Companies Act methods

  Furniture                           Furniture catalog and category
                                      totals

  Amulance and Vehicle                Vehicle catalog and quantity/rate
                                      data

  non medical equipment               Non-medical equipment catalog

  final equipment list                Detailed equipment list, makes,
                                      models, rates, and quantities

  MEDICAL EQUI.                       Department-wise medical equipment
                                      and cost data
  -----------------------------------------------------------------------

### 2.1 Source workbook observations to preserve as validation items

The workbook contains differing project descriptions and capacity labels
across worksheets. Examples visible in the source include a 100-bed
title in Assumptions, an 80-bed label in COP, a 100-bed label in the
revenue model, and 96 beds in the expenses sheet. The workbook also
contains different location names in different sheet titles. These are
source-data discrepancies, not values the application should
automatically reconcile.

Admin requirements:

1.  Import the workbook values into a staging area.
2.  Preserve source worksheet, cell address, original value, and formula
    wherever available.
3.  Flag conflicting capacities, locations, units, and rates for review.
4.  Do not assume one sheet's value is universally correct.
5.  Allow an authorized admin to approve a canonical template or mark an
    item unresolved.
6.  Keep the original uploaded workbook as an immutable reference
    artifact.

Some sheets contain formulas linked to other sheets. The application
must map these relationships into explicit calculation rules and test
cases rather than attempting to run arbitrary Excel formulas in
production.

## 3. Admin roles and permissions

Use role-based access control (RBAC), with permissions enforced by the
API and database---not only by hiding UI controls.

  -----------------------------------------------------------------------
  Role                                Main permissions
  ----------------------------------- -----------------------------------
  Super Admin                         All settings, roles, templates,
                                      rules, data imports, and audit
                                      records

  Admin                               Manage catalogs, templates,
                                      projects, and users within assigned
                                      scope

  Finance Reviewer                    Review assumptions, formulas,
                                      financial outputs, and reports

  Data Manager                        Import and maintain master catalogs
                                      and rates

  Support Operator                    View user/project status and
                                      provide limited support

  Read-only Auditor                   View approved configurations,
                                      reports, and audit logs
  -----------------------------------------------------------------------

Permission examples:

-   `users.read`, `users.manage`
-   `projects.read`, `projects.manage`, `projects.approve`
-   `catalogs.read`, `catalogs.manage`
-   `assumptions.manage`
-   `calculation_rules.read`, `calculation_rules.edit`,
    `calculation_rules.publish`
-   `reports.read`, `reports.generate`
-   `audit_logs.read`
-   `system_settings.manage`

Sensitive actions such as publishing a calculation-rule version,
changing financial defaults, or deleting a master record should require
elevated permission and an audit entry. Prefer archive/deactivate over
hard delete when records are already referenced by projects.

## 4. Admin information architecture and navigation

Recommended desktop sidebar:

1.  Overview
2.  Users & Organizations
3.  Hospital Projects
4.  Master Data
    -   Locations
    -   Hospital Types
    -   Departments & Services
    -   Bed Categories
    -   Units of Measurement
5.  Estimation Catalogs
    -   Medical Equipment
    -   Non-Medical Equipment
    -   Furniture & Fixtures
    -   Ambulance & Vehicles
    -   Construction Items & Rates
    -   Staff Designations & Salary Templates
    -   Revenue Categories
    -   Expense Categories
6.  Assumption Templates
7.  Calculation Rules
8.  Financial Models
    -   Cost of Project / Means of Finance
    -   Revenue Model
    -   Expenses
    -   P&L
    -   Balance Sheet
    -   Cash Flow
    -   Term Loan & Working Capital
    -   Depreciation
    -   Ratios / DSCR / IRR / Break-even
9.  Workbook Import & Reconciliation
10. Reports & Templates
11. Validation & Test Runs
12. Audit Logs
13. Notifications
14. System Settings

Use breadcrumbs, global search, filters, pagination, status labels, and
contextual help. Every list page should support loading, empty, error,
and permission-denied states.

## 5. Module-wise admin plan

### Module 1 --- Admin authentication and access control

**Screens** - Admin login - Forgot/reset password - Optional MFA setup -
Profile and session management - Role and permission management

**Functions** - Secure sign-in and sign-out. - Enforce role-based routes
and API permissions. - Session expiry and refresh handling. - Disable or
suspend an admin account. - Record login and privileged-action events.

**Acceptance criteria** - A user without admin permission cannot access
admin APIs by manually calling endpoints. - Role changes take effect on
the server. - Sensitive actions record actor, timestamp, action, and
affected record.

### Module 2 --- Admin overview dashboard

**Dashboard cards** - Total users and organizations. - Total projects. -
Draft, submitted, reviewed, and completed projects. - Projects awaiting
review. - Published catalog/rule versions. - Recent imports and import
errors. - Recent report generations. - Recent admin activity.

**Charts and tables** - Projects by hospital type. - Projects by
state/city. - Project status trend. - Most recently updated projects. -
Data-quality warnings and failed calculation runs.

Dashboard metrics must come from backend queries and must respect the
admin's access scope.

### Module 3 --- Users and organizations

**Screens** - User list and detail. - Organization list and detail. -
Role assignment. - Account status and access history.

**Fields** - Name, email, mobile. - Organization name and type. -
Assigned role. - Account status. - Created date and last login. -
Assigned consultant/admin.

**Actions** - Search, filter, view, activate, suspend. - Assign or
change role. - Link users to organizations. - View projects owned by an
organization. - Do not expose passwords or authentication secrets.

### Module 4 --- Hospital projects administration

**Project list fields** - Project name and hospital name. -
Owner/organization. - Hospital type. - State and city. - Bed capacity. -
Project status. - Last updated date. - Current assumption-template
version. - Current calculation-rule version.

**Project detail tabs** 1. Overview 2. Project profile 3. Assumptions 4.
Bed distribution 5. Building estimation 6. Medical equipment 7.
Non-medical equipment 8. Furniture and vehicles 9. Staff and expenses
10. Revenue 11. Cost of Project / Finance 12. Financial statements 13.
Reports 14. Change history

**Admin actions** - View project data. - Return a project for correction
with comments. - Mark review status. - Compare saved versions. - Re-run
calculations using the project's pinned rule version. - Never silently
edit a customer's approved financial inputs.

### Module 5 --- General master data

Maintain shared lookup tables used by all modules.

**Masters** - Countries, states, districts, and cities. -
Hospital/clinic types. - Departments and services. - Bed categories. -
Units of measurement. - Asset categories. - Tax categories, where
applicable. - Project statuses.

**Requirements** - Add/edit/archive records. - Search and filter. -
Import/export CSV or Excel. - Prevent duplicate codes. - Support
active/inactive status. - Use stable IDs rather than names as database
references.

### Module 6 --- Medical equipment catalog

Map this module primarily to `MEDICAL EQUI.` and `final equipment list`.

**Catalog fields** - Item code / SKU. - Equipment name. -
Department/category. - Description. - Make/brand. - Model. - Unit of
measurement. - Default unit rate. - Currency. - GST/tax treatment if
configured. - Installation/commissioning cost rule. - Suggested quantity
rule (optional). - Mandatory/optional flag. - Source worksheet and
source cell/range. - Effective-from date. - Version and active status.

**Admin functions** - Create/edit/archive catalog items. - Add equipment
departments and subcategories. - Bulk import from Excel/CSV. - Preview
import before commit. - Detect duplicates and missing prices. - Maintain
price history. - Mark an item as needing review.

Do not assume all equipment quantities scale directly with beds.
Quantity rules should be explicit, configurable, and independently
testable.

### Module 7 --- Non-medical equipment catalog

Map to `non medical equipment`.

Manage items such as nurse-call systems, medical-gas infrastructure,
computers, HIMS/PACS, EPBX/biometric systems, laundry, kitchen, and
other non-medical assets where present in the source.

Use the same catalog lifecycle as medical equipment. Preserve category,
unit, source value, source location, and price history.

### Module 8 --- Furniture and fixtures catalog

Map to `Furniture`.

Manage categories represented in the workbook, including office
furniture, pharmacy, central stores, medical records/library,
engineering/maintenance, and patient-related areas.

Fields: - Item code and name. - Category and subcategory. - Unit. -
Default quantity rule (if defined). - Unit rate. - Tax/installation
fields if applicable. - Source reference. - Active status and version.

### Module 9 --- Ambulance and vehicle catalog

Map to `Amulance and Vehicle`.

Fields: - Vehicle category. - Vehicle name/type. - Specification. -
Default quantity. - Unit rate. - Tax/registration/fit-out assumptions if
supported by approved rules. - Source reference. - Effective date and
active status.

The source workbook includes cardiac ambulance, two-wheeler, and normal
ambulance rows. Preserve these source categories during import; admins
may add more categories later.

### Module 10 --- Construction items and rates

Create configurable items for land and building estimates, but only
import values that exist in the workbook or are subsequently approved by
an admin.

Potential configurable item structure: - Work category. - Item
description. - Unit. - Quantity basis. - Unit rate. - Location/region
applicability. - Building type applicability. - Effective date. - Source
and approval status.

If a rate varies by state/city, use a rate-region table with explicit
precedence. Do not silently infer a local rate.

### Module 11 --- Staff designations and salary templates

Map to `FINAL expenses`.

**Fields** - Department. - Designation. - Employee category. - Default
headcount rule (optional). - Monthly salary. - Salary unit/currency. -
Annual increment assumption. - Applicable hospital type/capacity band
(if configured). - Source reference. - Effective date and active status.

Allow admins to maintain salary templates, while each project retains
its own selected headcount and salary overrides.

### Module 12 --- Revenue category and assumption templates

Map to `final revenue model`.

Maintain configurable revenue lines and their calculation inputs.
Preserve the source workbook's categories, including OPD, room,
diagnostics, OT, pharmacy, other revenue, blood bank, and
optical/pharmacy-related revenue rows where applicable.

Each revenue template should define: - Revenue category. -
Department/service. - Input fields. - Units. - Calculation method
identifier. - Default values only where supported by the source or
approved by an admin. - Utilization/occupancy dependency. - Inflation
dependency. - Projection treatment. - Source mapping.

Do not hardcode a single universal rate or patient volume for every
hospital. Project-specific inputs and admin-approved defaults must
remain separate.

### Module 13 --- Expense categories and operating-cost templates

Map to `FINAL expenses` and relevant operating-cost sections.

Manage: - Staff cost categories. - Other operating expense categories. -
Consumables and recurring expense categories where present in the
workbook. - Pre-operative expenses where mapped in COP. -
Inflation/escalation assumptions.

Each template needs a formula/method reference, unit, default (if
sourced), effective date, and source mapping.

### Module 14 --- Assumption templates

Map to `Assumptions`.

Create templates by project type and optionally hospital capacity band.
Do not force a single global assumption set.

Template fields should cover the actual workbook assumptions,
including: - OPD days. - Surgery days. - Bed days. - CAPEX interest
rate. - Working-capital interest rate. - Depreciation method
selection. - Depreciation rates by asset class. - Other financial
assumptions present in the sheet.

The admin can: - Create a template. - Duplicate a template. - Edit draft
values. - Compare versions. - Submit for review. - Publish a new
version. - Retire an old version.

A project must retain the exact template version it used. Updating a
template must not silently change existing projects.

### Module 15 --- Calculation rules management

This is a critical module. It controls how catalog and assumption data
become estimates.

**Rule categories** - Quantity rules. - Unit conversion rules. -
Construction cost rules. - Equipment quantity rules. - Furniture
quantity rules. - Staff headcount rules. - Revenue formulas. - Expense
formulas. - Project cost aggregation. - Funding allocation. - Loan
repayment. - Depreciation. - Financial statement formulas. - Financial
ratios.

**Rule record** - Rule code and name. - Description/business meaning. -
Rule category. - Input variables and types. - Formula/method
identifier. - Output variable and unit. - Dependencies. - Effective
date. - Version. - Draft/published/retired status. - Test cases and
expected outputs. - Approval metadata.

**Safety** - Do not allow arbitrary user-entered Python or executable
code in the admin UI. - Prefer a controlled formula DSL or an
allowlisted calculation-method registry. - Validate types, units,
dependencies, division-by-zero, and circular references. - Require test
cases and reviewer approval before publishing. - Never change a
published rule version in place; create a new version.

### Module 16 --- Financial model configuration

Map the workbook's financial worksheets:

-   `COP`
-   `P&L`
-   `Ratios`
-   `BS`
-   `TL & WC`
-   `Cash Flow`
-   `Depreciation`

Admin screens should expose configuration and mapping---not free-form
editing of production formulas without controls.

**Configuration areas** - Cost of Project line-item mapping. - Means of
Finance mapping. - Projection period and year labels. -
Capacity-utilization assumptions. - Revenue inflation/escalation. -
Expense escalation. - Term-loan interest, tenure, moratorium, and
repayment interval. - Working-capital calculation mapping. -
Depreciation asset classes and methods. - P&L line-item mapping. -
Balance Sheet line-item mapping. - Cash Flow line-item mapping. - Ratio
definitions and formula references.

The source depreciation sheet includes IT-tax and Companies Act
sections. Preserve both methods as separate calculation paths and make
the selected method explicit for each project/report.

### Module 17 --- Workbook import and reconciliation

Build a controlled Excel import workflow.

**Steps** 1. Upload source workbook. 2. Store original file unchanged.
3. Read workbook sheet names, cells, formulas, values, and named ranges
where available. 4. Preview extracted rows. 5. Map each source range to
a target catalog/template. 6. Detect missing values, duplicates, formula
cells, inconsistent units, and conflicting project assumptions. 7.
Display validation warnings. 8. Allow authorized data manager to correct
mapping or mark unresolved. 9. Approve and import into staging. 10.
Publish selected records to master data. 11. Generate an import report.

**Reconciliation view** - Source sheet and cell. - Source
label/value/formula. - Imported record. - Proposed target field. -
Conflict/warning. - Reviewer decision. - Import status.

Do not execute arbitrary Excel formulas from uploaded workbooks on the
server. Translate approved formulas into tested backend calculation
methods.

### Module 18 --- Calculation run and validation centre

Provide an admin-only test console.

**Functions** - Select a test project or scenario. - Select
assumption-template version. - Select calculation-rule version. - Run
calculation. - View inputs and outputs. - View calculation trace and
dependency tree. - Compare against approved Excel reference outputs. -
Export discrepancy report.

**Test scenarios** - Small clinic. - Medium hospital. - Large
hospital. - Different department selections. - Different occupancy and
utilization values. - Different loan terms. - Different depreciation
methods.

These are test scenarios, not assumed source-workbook defaults. Test
input values must be explicitly defined and approved.

**Validation checks** - Bed-category sum versus declared total beds. -
Quantity × unit rate versus line total. - Department totals versus
project totals. - Cost of Project versus Means of Finance. - Loan
opening balance, principal repayment, interest, and closing balance. -
Balance Sheet balance check. - Cash flow reconciliation. - No invalid
division by zero. - No missing required input. - No circular calculation
dependency.

### Module 19 --- Reports and templates

Admin can manage: - CMA report template. - Organization branding/logo. -
Report header/footer. - Project profile section. - Assumptions
section. - Equipment and cost tables. - Financial statement layouts. -
Charts and summary sections. - Disclaimer and report notes.

Report generation must record: - Project ID. - Input snapshot/version. -
Calculation-rule version. - Template version. - Generated by. -
Generated date/time. - File location. - Report status.

A regenerated report should create a new version rather than overwrite
the prior approved report.

### Module 20 --- Audit logs and notifications

**Audit log fields** - Actor/admin ID. - Action. - Entity type and
entity ID. - Previous value. - New value. - Timestamp. -
Request/correlation ID. - Reason/comment, where required.

Track changes to: - Catalog prices. - Assumption templates. -
Calculation rules. - User roles. - Project review status. - Report
templates. - System settings.

Notifications may alert admins about pending reviews, failed imports,
calculation errors, expiring templates, and report-generation failures.

### Module 21 --- System settings and operational controls

Manage: - Application name and branding. - Currency and display
formats. - Default locale/time zone. - File upload limits. - Report
storage policy. - Email/notification configuration. - Maintenance
mode. - Feature flags. - Backup and retention policy. - API
health/status visibility.

Never display secret API keys in the browser. Keep secrets in
server-side environment configuration or a managed secret store.

------------------------------------------------------------------------

## 6. Recommended database model

Use PostgreSQL with UUID primary keys, foreign keys, timestamps,
indexes, and audit metadata.

  Table                            Purpose
  -------------------------------- ----------------------------------------------
  `users`                          User identity/profile reference
  `organizations`                  Hospital owners and consultant organizations
  `organization_members`           User-to-organization membership
  `roles`                          Role definitions
  `permissions`                    Permission definitions
  `role_permissions`               Role-permission mapping
  `projects`                       Hospital/clinic project profile
  `project_members`                Project-level access
  `project_assumption_sets`        Project-specific assumption snapshots
  `assumption_templates`           Reusable default templates
  `assumption_template_versions`   Immutable template versions
  `locations`                      State, district, city hierarchy
  `hospital_types`                 Hospital/clinic types
  `departments`                    Department master
  `bed_categories`                 Bed category master
  `project_bed_allocations`        Project bed counts
  `units`                          Units of measurement
  `equipment_categories`           Equipment categories
  `equipment_catalog`              Medical equipment master
  `equipment_price_versions`       Equipment price history
  `project_equipment`              Project-selected equipment
  `nonmedical_catalog`             Non-medical equipment master
  `furniture_catalog`              Furniture master
  `vehicle_catalog`                Vehicle master
  `construction_rate_versions`     Construction rates and history
  `staff_designations`             Staff designation master
  `salary_template_versions`       Salary defaults and history
  `revenue_templates`              Revenue categories and inputs
  `expense_templates`              Expense categories and inputs
  `calculation_rules`              Rule identity and metadata
  `calculation_rule_versions`      Immutable rule versions
  `calculation_runs`               Calculation execution records
  `calculation_results`            Calculation outputs
  `calculation_dependencies`       Rule dependency graph
  `financial_projection_rows`      P&L, BS, cash flow, ratios, etc.
  `workbook_imports`               Import job metadata
  `workbook_source_cells`          Source sheet/cell/value/formula mapping
  `report_templates`               Report template metadata
  `report_versions`                Generated report history
  `audit_logs`                     Administrative change history
  `notifications`                  Admin/user notifications

Use project-scoped tables for customer-specific inputs. Keep shared
catalog data separate from project selections and overrides.

### 6.1 Versioning and snapshot policy

Every project calculation should be reproducible. Save: - Project input
snapshot. - Selected assumption-template version. - Catalog/rate
versions used. - Calculation-rule version. - Calculation engine
version. - Output snapshot. - Calculation timestamp.

Do not silently recalculate an old approved report with newly published
prices or formulas. Offer an explicit "recalculate using latest
configuration" action that creates a new project/report version.

------------------------------------------------------------------------

## 7. Backend API groups

Suggested FastAPI route groups:

  API prefix                          Purpose
  ----------------------------------- ----------------------------------------------
  `/api/admin/auth`                   Admin session and profile
  `/api/admin/users`                  User administration
  `/api/admin/organizations`          Organization administration
  `/api/admin/projects`               Project oversight
  `/api/admin/masters`                Locations, types, departments, units
  `/api/admin/catalogs`               Equipment, furniture, vehicles, construction
  `/api/admin/staff-templates`        Designations and salaries
  `/api/admin/revenue-templates`      Revenue defaults
  `/api/admin/expense-templates`      Expense defaults
  `/api/admin/assumption-templates`   Assumption versions
  `/api/admin/calculation-rules`      Rule lifecycle
  `/api/admin/financial-models`       Statement and ratio configuration
  `/api/admin/workbook-imports`       Workbook staging and reconciliation
  `/api/admin/calculation-runs`       Test and production calculation runs
  `/api/admin/reports`                Report templates and report history
  `/api/admin/audit-logs`             Audit records
  `/api/admin/settings`               System configuration

Use request/response schemas, pagination, filtering, sorting, consistent
error responses, and server-side permission checks.

------------------------------------------------------------------------

## 8. Flutter Web admin project structure

Use feature-first Clean Architecture.

``` text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    config/
    constants/
    errors/
    network/
    permissions/
    utils/
    widgets/
  features/
    admin_auth/
      data/
      domain/
      presentation/
    dashboard/
      data/
      domain/
      presentation/
    users/
    organizations/
    projects/
    master_data/
    medical_equipment/
    non_medical_equipment/
    furniture/
    vehicles/
    construction_rates/
    staff_templates/
    revenue_templates/
    expense_templates/
    assumption_templates/
    calculation_rules/
    financial_models/
    workbook_import/
    validation_centre/
    reports/
    audit_logs/
    notifications/
    system_settings/
  main.dart
```

Each feature should contain: - `data`: API clients, DTOs, repository
implementations. - `domain`: entities, repository contracts, use
cases. - `presentation`: pages, widgets, Riverpod providers/controllers.

Recommended packages: - `flutter_riverpod` - `go_router` - `dio` -
`freezed` / `json_serializable` where appropriate - `data_table_2` or an
equivalent responsive data-grid package - `intl` - `file_picker` -
`fl_chart` or another maintained chart package

Confirm package compatibility with the selected Flutter stable version
before adding dependencies.

------------------------------------------------------------------------

## 9. Admin UI design standards

Use a professional healthcare-finance SaaS design.

**Desktop layout** - Fixed/collapsible left sidebar. - Top bar with page
title, breadcrumbs, global search, notifications, and profile. - Main
content area with responsive cards and tables. - Right-side detail
drawer for quick edits where useful.

**Common list-page pattern** - Page title and description. - Add New
action. - Search. - Filters. - Sort. - Paginated table. - Row actions. -
Bulk actions only where safe. - Export. - Empty/loading/error states.

**Common edit-page pattern** - Grouped form sections. - Required-field
validation. - Unit labels. - Source reference. - Draft/save/publish
actions. - Change summary. - Confirmation for destructive or high-impact
actions.

**Status labels** - Draft - Pending Review - Approved - Published -
Archived - Needs Attention - Failed

Do not rely on color alone to communicate status.

------------------------------------------------------------------------

## 10. Development phases and deliverables

### Phase 1 --- Foundation

Deliver: - Flutter Web project setup. - FastAPI project setup. -
PostgreSQL schema and migrations. - Authentication. - RBAC and route
protection. - Admin shell, sidebar, top bar, responsive layout. -
Audit-log foundation.

**Exit criteria:** Admin can securely log in and see only permitted
modules.

### Phase 2 --- Dashboard and administration

Deliver: - Dashboard. - User management. - Organization management. -
Project list and project detail. - Search, filters, pagination, status
workflows.

**Exit criteria:** Admin can manage users and inspect projects without
modifying financial calculations.

### Phase 3 --- Master data and catalogs

Deliver: - Location and hospital-type masters. - Department and
bed-category masters. - Medical equipment catalog. - Non-medical
equipment catalog. - Furniture and vehicle catalogs. - Construction
rates. - Staff and salary templates. - Revenue and expense templates.

**Exit criteria:** Admin can add, edit, archive, import, and version
master data.

### Phase 4 --- Assumptions and calculation rules

Deliver: - Assumption-template editor. - Version comparison and
publishing. - Calculation-rule registry. - Dependency validation. -
Approval workflow. - Calculation trace.

**Exit criteria:** Admin can publish a tested configuration version
without changing application code.

### Phase 5 --- Excel import and reconciliation

Deliver: - Workbook upload and immutable storage. - Sheet/cell/formula
extraction. - Mapping interface. - Conflict and missing-data
detection. - Staging and approval. - Import report.

**Exit criteria:** Workbook source data can be reviewed and imported
without losing source traceability.

### Phase 6 --- Financial model administration

Deliver: - COP and Means of Finance mapping. - Revenue and expense
mapping. - P&L, Balance Sheet, and Cash Flow mapping. - Loan and
working-capital configuration. - Depreciation configuration. - Ratios
and DSCR mapping.

**Exit criteria:** Financial configuration is versioned and calculation
runs are reproducible.

### Phase 7 --- Validation and reporting

Deliver: - Calculation test console. - Excel-reference comparison. -
Validation reports. - CMA report templates. - PDF/Excel report
history. - Audit and notifications.

**Exit criteria:** Approved test scenarios pass and generated reports
retain their input/rule/template versions.

### Phase 8 --- Production readiness

Deliver: - Security review. - Authorization tests. - Calculation
tests. - Performance tests. - Backup/restore verification. - Error
monitoring. - Deployment pipeline. - Admin operating guide.

**Exit criteria:** Production release is approved after financial and
security validation.

------------------------------------------------------------------------

## 11. Testing strategy

### UI tests

-   Admin login and logout.
-   Role-specific navigation.
-   Form validation.
-   Search/filter/pagination.
-   Import preview and approval.
-   Version publish confirmation.

### API tests

-   Authentication and authorization.
-   Tenant/project isolation.
-   Catalog CRUD.
-   Version immutability.
-   Import validation.
-   Audit-log creation.

### Calculation tests

-   Unit test each formula/method.
-   Test units and rounding.
-   Test boundary values.
-   Test missing/zero values.
-   Test circular dependency detection.
-   Test loan schedules.
-   Test depreciation methods separately.
-   Test financial statement reconciliations.

### Workbook reconciliation

For each approved reference scenario: 1. Record the exact input cells
and values. 2. Record expected output cells and values. 3. Run the
application with the same inputs and configuration. 4. Compare each
mapped output. 5. Explain any variance. 6. Obtain finance reviewer
approval for accepted differences.

Do not claim the app matches the workbook until the mapped outputs have
been tested.

------------------------------------------------------------------------

## 12. Non-functional requirements

-   Secure authentication and server-side authorization.
-   Organization and project data isolation.
-   Immutable published configuration versions.
-   Audit trail for important changes.
-   Decimal-safe financial arithmetic.
-   Idempotent import and calculation operations where appropriate.
-   Database transactions for related updates.
-   Pagination for large catalogs.
-   Background jobs for large imports and report generation.
-   File type and size validation.
-   Backups and restore testing.
-   Error monitoring and structured logs.
-   Accessibility and responsive web layouts.
-   No secrets embedded in Flutter web assets.
-   No arbitrary executable formulas supplied by admins.

------------------------------------------------------------------------

## 13. Initial build prompt for the coding agent

> Act as a senior Flutter Web architect and Python FastAPI/PostgreSQL
> engineer. Build the Admin Portal described in this document for the
> Hospital & Clinic Estimation Platform.
>
> First inspect the existing repository and report its current structure
> before changing files. If no project exists, create the Flutter Web
> and FastAPI foundations.
>
> Implement the work phase by phase. Begin with Phase 1 only: project
> setup, authentication, RBAC, database migrations, admin shell,
> responsive sidebar, top bar, routing, and audit-log foundation.
>
> Use Riverpod, GoRouter, Dio, Clean Architecture, FastAPI, Pydantic,
> and PostgreSQL. Enforce authorization in the backend. Keep all
> financial calculations out of Flutter UI.
>
> Do not hardcode workbook rates, quantities, assumptions, or formulas.
> Do not invent missing values. Preserve the original workbook as the
> source reference and build import/reconciliation workflows in later
> phases.
>
> Before coding, present the implementation plan and proposed database
> schema. After Phase 1, run tests, list files created/modified, report
> known limitations, and wait for approval before moving to Phase 2.
>
> Do not create unrelated documentation files or change existing
> application behavior without explaining the reason and obtaining
> approval.

------------------------------------------------------------------------

## 14. Definition of done

The Admin Portal is ready for its first production pilot when:

-   Admin login and server-enforced roles work.
-   Admin can manage users, organizations, and projects.
-   Admin can maintain all required master catalogs.
-   Admin can create and publish versioned assumption templates.
-   Admin can maintain versioned calculation rules with test cases.
-   Workbook imports preserve source traceability.
-   Financial outputs can be reproduced from saved input and rule
    versions.
-   Reports preserve their template and calculation versions.
-   All important admin changes are audited.
-   Tenant/project isolation and backup/restore have been tested.
-   Financial calculations have been reviewed and approved by a
    qualified finance professional.

**Guiding principle:** Build the Admin Portal as a configuration and
governance platform. The customer-facing Flutter application consumes
approved catalogs, templates, and calculation services. This separation
allows the estimation platform to grow without hardcoding each hospital
type or changing Flutter code whenever an admin updates a rate or
approved business rule.
