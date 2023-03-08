\echo ''
\echo '==='
\echo 'Beginning to create materialized views for MIMIC database.'
\echo 'Any notices of the form  "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'
\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
\echo '==='
\echo ''

-- Set the search_path, i.e. the location at which we generate tables.
-- postgres looks at schemas sequentially, so this will generate tables on the mimiciv_derived schema

-- NOTE: many scripts *require* you to use mimic_derived as the schema for outputting concepts
-- change the search path at your peril!
SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;

-- dependencies
\i niv-durations.sql
\i colloid_bolus.sql
\i crystalloid_bolus.sql
\i code_status.sql
\i ccs_dx.sql
\i ventilation_classification.sql
\i ventilation_durations.sql
\i vasopressor_durations.sql
\i adenosine_durations.sql
\i dobutamine_durations.sql
\i dopamine_durations.sql
\i epinephrine_durations.sql
\i isuprel_durations.sql
\i milrinone_durations.sql
\i norepinephrine_durations.sql
\i phenylephrine_durations.sql
\i vasopressin_durations.sql