-- OPTIONAL local test data. Flyway does NOT run this file (it is outside db/migration).
-- Run it by hand in MySQL only on your own machine, after V1 has been applied, and only once.
-- Every value below is an example you can change. Nothing in the program depends on these rows.
-- In real use, enter the same data through the admin APIs or the Excel import.

INSERT INTO technologies (code, name) VALUES
    ('XML', 'XML'), ('JOURNAL', 'Journal'), ('EPUB', 'EPUB'), ('FIXED_LAYOUT', 'Fixed Layout');

INSERT INTO employee_levels (code, name, rank_order) VALUES
    ('JUNIOR', 'Junior', 1), ('SENIOR', 'Senior', 2);

-- XML difficulty categories. min_level_rank 2 means Heavy Complex needs level rank 2 (senior) or higher.
INSERT INTO complexity_categories (technology_id, code, name, sort_order, min_level_rank)
SELECT t.id, c.code, c.name, c.sort_order, c.min_rank
FROM technologies t
JOIN (SELECT 'SIMPLE' AS code, 'Simple' AS name, 1 AS sort_order, NULL AS min_rank
      UNION ALL SELECT 'MEDIUM', 'Medium', 2, NULL
      UNION ALL SELECT 'COMPLEX', 'Complex', 3, NULL
      UNION ALL SELECT 'HEAVY', 'Heavy Complex', 4, 2) c
WHERE t.code = 'XML';

-- XML pages per day. Senior numbers are from the team. Junior numbers are an ASSUMPTION (60% of senior): replace with real speeds.
INSERT INTO capacity_rules (technology_id, complexity_id, level_id, pages_per_day, effective_from, note)
SELECT t.id, cc.id, l.id, v.pages, CURRENT_DATE, v.note
FROM (SELECT 'SIMPLE' AS ccode, 'SENIOR' AS lcode, 300 AS pages, 'team figure' AS note
      UNION ALL SELECT 'MEDIUM',  'SENIOR', 150, 'team figure'
      UNION ALL SELECT 'COMPLEX', 'SENIOR',  75, 'team figure'
      UNION ALL SELECT 'HEAVY',   'SENIOR',  25, 'team figure'
      UNION ALL SELECT 'SIMPLE',  'JUNIOR', 180, 'ASSUMPTION: 60% of senior'
      UNION ALL SELECT 'MEDIUM',  'JUNIOR',  90, 'ASSUMPTION: 60% of senior'
      UNION ALL SELECT 'COMPLEX', 'JUNIOR',  45, 'ASSUMPTION: 60% of senior'
      UNION ALL SELECT 'HEAVY',   'JUNIOR',  15, 'ASSUMPTION: 60% of senior') v
JOIN technologies t ON t.code = 'XML'
JOIN complexity_categories cc ON cc.technology_id = t.id AND cc.code = v.ccode
JOIN employee_levels l ON l.code = v.lcode;