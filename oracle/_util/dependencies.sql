
-- DROPS

DROP TABLE deps$;
DROP TABLE deps$_;

-- CREATES

CREATE TABLE deps$_(a VARCHAR2(30), b VARCHAR2(30));
CREATE TABLE deps$(a VARCHAR2(30), b VARCHAR2(30));

-- Initialization

INSERT INTO deps$_ (a, b)
SELECT table_name, NULL
FROM user_tables
WHERE 
	table_name NOT LIKE 'MIG_%'
	AND table_name NOT LIKE '%$%'
;

INSERT INTO deps$_ (a, b)
SELECT
	b.table_name as a,
	a.table_name as b
FROM
	user_constraints a,
	user_constraints b
WHERE
	b.constraint_type = 'R'
	AND a.constraint_name = b.r_constraint_name
;

-- Execute this block as much as needed
-- to include dependencies recursively

-- STOP TO RUN WHEN THE NUMBER OF ROWS INSERTED 
-- AT THE LAST COMMENT DOES NOT INCREASES ANY MORE

---------------------------------------------------
-- BLOCK START

INSERT INTO deps$_ (a, b)
SELECT
	d1.a, d2.b
FROM 
	deps$_ d1,
	deps$_ d2
WHERE
	d1.b = d2.a
;

TRUNCATE TABLE deps$;

-- insert distincts, but avoid circular deps
INSERT INTO deps$ (a, b)
SELECT DISTINCT * FROM deps$_ 
WHERE a != b;

TRUNCATE TABLE deps$_;

INSERT INTO deps$_ SELECT * FROM deps$;

-- BLOCK END
---------------------------------------------------


-- Report 

SET pagesize 1000
SET linesize 70
BREAK ON A

SELECT *
FROM deps$
ORDER by 1, 2
;



-- DROPS AGAIN

DROP TABLE deps$;
DROP TABLE deps$_;

