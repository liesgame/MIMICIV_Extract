with t1 as (
  SELECT n.subject_id, n.hadm_id ,to_char(n.charttime, 'yyyy-mm-dd')::timestamp without time zone as chartdate, n.charttime, n.note_type as category, n.text
  FROM mimiciv_note.discharge n
)

SELECT n.subject_id, n.hadm_id, i.stay_id as icustay_id,n.chartdate, n.charttime, n.category, n.text
FROM t1 n INNER JOIN mimiciv_icu.icustays i on i.hadm_id = n.hadm_id
WHERE (n.chartdate <= i.outtime OR n.chartdate <= i.outtime)
  AND n.hadm_id IN ('{hadm_id}')
  AND n.subject_id IN ('{subject_id}')
