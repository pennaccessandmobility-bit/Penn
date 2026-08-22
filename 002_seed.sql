-- Penn Access and Mobility
-- 002_seed.sql
-- Run AFTER 001_schema.sql. Safe to re-run, nothing duplicates.

-- ============================================================
-- COMPANY DEFAULTS
-- ============================================================
insert into company_settings (key, value) select 'company_name','Penn Access & Mobility' where not exists (select 1 from company_settings where key='company_name');
insert into company_settings (key, value) select 'legal_name','P.A. Losch and Sons LLC' where not exists (select 1 from company_settings where key='legal_name');
insert into company_settings (key, value) select 'address','3366 Evendale Hill Road, Richfield, PA 17086' where not exists (select 1 from company_settings where key='address');
insert into company_settings (key, value) select 'phone','717-320-2829' where not exists (select 1 from company_settings where key='phone');
insert into company_settings (key, value) select 'license_no','PA054398' where not exists (select 1 from company_settings where key='license_no');
insert into company_settings (key, value) select 'default_target_margin','35' where not exists (select 1 from company_settings where key='default_target_margin');
insert into company_settings (key, value) select 'default_labor_rate','65' where not exists (select 1 from company_settings where key='default_labor_rate');
insert into company_settings (key, value) select 'payment_terms','Net 30' where not exists (select 1 from company_settings where key='payment_terms');

insert into tax_settings (id) select 1 where not exists (select 1 from tax_settings where id=1);

-- ============================================================
-- WORK TYPES
-- ============================================================
insert into work_types (name, sort_order) select 'Accessibility',1 where not exists (select 1 from work_types where name='Accessibility');
insert into work_types (name, sort_order) select 'Fire Safety',2 where not exists (select 1 from work_types where name='Fire Safety');
insert into work_types (name, sort_order) select 'Flooring',3 where not exists (select 1 from work_types where name='Flooring');
insert into work_types (name, sort_order) select 'Painting',4 where not exists (select 1 from work_types where name='Painting');
insert into work_types (name, sort_order) select 'Carpentry',5 where not exists (select 1 from work_types where name='Carpentry');
insert into work_types (name, sort_order) select 'Electrical',6 where not exists (select 1 from work_types where name='Electrical');
insert into work_types (name, sort_order) select 'Plumbing',7 where not exists (select 1 from work_types where name='Plumbing');
insert into work_types (name, sort_order) select 'Roofing',8 where not exists (select 1 from work_types where name='Roofing');
insert into work_types (name, sort_order) select 'HVAC',9 where not exists (select 1 from work_types where name='HVAC');
insert into work_types (name, sort_order) select 'Demolition',10 where not exists (select 1 from work_types where name='Demolition');
insert into work_types (name, sort_order) select 'Travel',11 where not exists (select 1 from work_types where name='Travel');
insert into work_types (name, sort_order) select 'Shop / Yard',12 where not exists (select 1 from work_types where name='Shop / Yard');

-- ============================================================
-- OVERHEAD DEFAULTS
-- ============================================================
insert into overhead_settings (name, description, overhead_type, amount, applies_to, sort_order)
select 'General overhead','Shop, admin, insurance spread across jobs','percent',12,'total',1
where not exists (select 1 from overhead_settings where name='General overhead');

insert into overhead_settings (name, description, overhead_type, amount, applies_to, sort_order)
select 'Mileage','Per mile round trip','per_mile',0.67,'total',2
where not exists (select 1 from overhead_settings where name='Mileage');

insert into overhead_settings (name, description, overhead_type, amount, applies_to, sort_order)
select 'Material handling','Pickup, staging, waste','percent',8,'materials',3
where not exists (select 1 from overhead_settings where name='Material handling');

-- ============================================================
-- SYSTEM LISTS
-- ============================================================
insert into system_lists (list_name, value, sort_order) select 'bid_category','Accessibility',1 where not exists (select 1 from system_lists where list_name='bid_category' and value='Accessibility');
insert into system_lists (list_name, value, sort_order) select 'bid_category','Bathroom remodel',2 where not exists (select 1 from system_lists where list_name='bid_category' and value='Bathroom remodel');
insert into system_lists (list_name, value, sort_order) select 'bid_category','Ramp',3 where not exists (select 1 from system_lists where list_name='bid_category' and value='Ramp');
insert into system_lists (list_name, value, sort_order) select 'bid_category','Stairlift',4 where not exists (select 1 from system_lists where list_name='bid_category' and value='Stairlift');
insert into system_lists (list_name, value, sort_order) select 'bid_category','Door widening',5 where not exists (select 1 from system_lists where list_name='bid_category' and value='Door widening');
insert into system_lists (list_name, value, sort_order) select 'bid_category','General repair',6 where not exists (select 1 from system_lists where list_name='bid_category' and value='General repair');

-- ============================================================
-- COMPLIANCE AND RENEWALS
-- Dates are intentionally NULL. Fill in your real dates in the app.
-- Tax rows are common deadlines, NOT advice. Confirm every one
-- of them with your accountant.
-- ============================================================
insert into compliance_items (name, kind, issuer, identifier, renewal_period)
select 'PA Home Improvement Contractor registration','registration','PA Attorney General','PA054398','biennial'
where not exists (select 1 from compliance_items where name='PA Home Improvement Contractor registration');

insert into compliance_items (name, kind, renewal_period) select 'General liability insurance','insurance','annual' where not exists (select 1 from compliance_items where name='General liability insurance');
insert into compliance_items (name, kind, renewal_period) select 'Workers compensation insurance','insurance','annual' where not exists (select 1 from compliance_items where name='Workers compensation insurance');
insert into compliance_items (name, kind, renewal_period) select 'Commercial auto insurance','insurance','annual' where not exists (select 1 from compliance_items where name='Commercial auto insurance');
insert into compliance_items (name, kind, renewal_period, notes) select 'Workers comp annual audit','insurance','annual','Carrier audits payroll after the policy year ends.' where not exists (select 1 from compliance_items where name='Workers comp annual audit');

insert into compliance_items (name, kind, issuer, renewal_period) select 'Work truck registration','registration','PennDOT','annual' where not exists (select 1 from compliance_items where name='Work truck registration');
insert into compliance_items (name, kind, issuer, renewal_period) select 'Work truck inspection','registration','PA State Inspection','annual' where not exists (select 1 from compliance_items where name='Work truck inspection');
insert into compliance_items (name, kind, issuer, renewal_period) select 'Trailer registration','registration','PennDOT','annual' where not exists (select 1 from compliance_items where name='Trailer registration');
insert into compliance_items (name, kind, issuer, renewal_period) select 'LLC annual registration','registration','PA Department of State','annual' where not exists (select 1 from compliance_items where name='LLC annual registration');

insert into compliance_items (name, kind, issuer, renewal_period) select 'Harrisburg contractor license','license','City of Harrisburg','annual' where not exists (select 1 from compliance_items where name='Harrisburg contractor license');
insert into compliance_items (name, kind, issuer, renewal_period) select 'PA sales tax license','license','PA Department of Revenue','annual' where not exists (select 1 from compliance_items where name='PA sales tax license');

insert into compliance_items (name, kind, issuer, renewal_period) select 'OSHA 10 certification','certification','OSHA','one-time' where not exists (select 1 from compliance_items where name='OSHA 10 certification');
insert into compliance_items (name, kind, issuer, renewal_period) select 'CPR / First aid certification','certification','American Red Cross','biennial' where not exists (select 1 from compliance_items where name='CPR / First aid certification');
insert into compliance_items (name, kind, issuer, renewal_period) select 'Lead-safe RRP certification','certification','EPA','annual' where not exists (select 1 from compliance_items where name='Lead-safe RRP certification');

insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Federal estimated tax Q1','tax','IRS','annual','Typically due April 15. Confirm with accountant.' where not exists (select 1 from compliance_items where name='Federal estimated tax Q1');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Federal estimated tax Q2','tax','IRS','annual','Typically due June 15. Confirm with accountant.' where not exists (select 1 from compliance_items where name='Federal estimated tax Q2');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Federal estimated tax Q3','tax','IRS','annual','Typically due September 15. Confirm with accountant.' where not exists (select 1 from compliance_items where name='Federal estimated tax Q3');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Federal estimated tax Q4','tax','IRS','annual','Typically due January 15 of the following year. Confirm with accountant.' where not exists (select 1 from compliance_items where name='Federal estimated tax Q4');

insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA estimated tax Q1','tax','PA Department of Revenue','annual','Confirm schedule with accountant.' where not exists (select 1 from compliance_items where name='PA estimated tax Q1');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA estimated tax Q2','tax','PA Department of Revenue','annual','Confirm schedule with accountant.' where not exists (select 1 from compliance_items where name='PA estimated tax Q2');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA estimated tax Q3','tax','PA Department of Revenue','annual','Confirm schedule with accountant.' where not exists (select 1 from compliance_items where name='PA estimated tax Q3');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA estimated tax Q4','tax','PA Department of Revenue','annual','Confirm schedule with accountant.' where not exists (select 1 from compliance_items where name='PA estimated tax Q4');

insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA sales tax filing','tax','PA Department of Revenue','quarterly','Frequency depends on your assigned filing schedule. Confirm with accountant.' where not exists (select 1 from compliance_items where name='PA sales tax filing');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'PA UC quarterly report','tax','PA Dept of Labor and Industry','quarterly','Unemployment compensation filing if you have employees.' where not exists (select 1 from compliance_items where name='PA UC quarterly report');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Local EIT quarterly filing','tax','Local tax collector','quarterly','Earned income tax. Confirm your collector.' where not exists (select 1 from compliance_items where name='Local EIT quarterly filing');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'W-2 and 1099-NEC filing','tax','IRS / SSA','annual','Typically due January 31.' where not exists (select 1 from compliance_items where name='W-2 and 1099-NEC filing');
insert into compliance_items (name, kind, issuer, renewal_period, notes) select 'Business tax return','tax','IRS','annual','Due date depends on entity election. Confirm with accountant.' where not exists (select 1 from compliance_items where name='Business tax return');
