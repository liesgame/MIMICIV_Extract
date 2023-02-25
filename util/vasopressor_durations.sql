SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS vasopressor_durations; CREATE TABLE vasopressor_durations AS 
-- This query extracts durations of vasopressor administration
-- It groups together any administration of the below list of drugs:
--  norepinephrine - 30047,30120,221906
--  epinephrine - 30044,30119,30309,221289
--  phenylephrine - 30127,30128,221749
--  vasopressin - 30051,222315 (42273, 42802 also for 2 patients)
--  dopamine - 30043,30307,221662
--  dobutamine - 30042,30306,221653
--  milrinone - 30125,221986

-- Consecutive administrations are numbered 1, 2, ...
-- Total time on the drug can be calculated from this table
-- by grouping using ICUSTAY_ID

-- select only the ITEMIDs from the inputevents_cv table related to vasopressors
with
-- select only the ITEMIDs from the inputevents(metavesion) table related to vasopressors
 io_mv as
(
  select
    stay_id as icustay_id, linkorderid, starttime, endtime
  FROM mimiciv_icu.inputevents io
  -- Subselect the vasopressor ITEMIDs
  where itemid in
  (
  221906,221289,221749,222315,221662,221653,221986
  )
  and statusdescription != 'Rewritten' -- only valid orders
)
, vasomv as
(
  select
    icustay_id, linkorderid
    , min(starttime) as starttime, max(endtime) as endtime
  from io_mv
  group by icustay_id, linkorderid
)
, vasomv_grp as
(
SELECT
  s1.icustay_id,
  s1.starttime,
  MIN(t1.endtime) AS endtime
FROM vasomv s1
INNER JOIN vasomv t1
  ON  s1.icustay_id = t1.icustay_id
  AND s1.starttime <= t1.endtime
  AND NOT EXISTS(SELECT * FROM vasomv t2
                 WHERE t1.icustay_id = t2.icustay_id
                 AND t1.endtime >= t2.starttime
                 AND t1.endtime < t2.endtime)
WHERE NOT EXISTS(SELECT * FROM vasomv s2
                 WHERE s1.icustay_id = s2.icustay_id
                 AND s1.starttime > s2.starttime
                 AND s1.starttime <= s2.endtime)
GROUP BY s1.icustay_id, s1.starttime
ORDER BY s1.icustay_id, s1.starttime
)
select
  icustay_id
  , ROW_NUMBER() over (partition by icustay_id order by starttime) as vasonum
  , starttime, endtime
  , mimiciv_derived.DATETIME_DIFF(endtime, starttime, 'HOUR') AS duration_hours
  -- add durations
from
  vasomv_grp
order by icustay_id, vasonum;