-- 0
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int);
	INSERT INTO t VALUES(11, 22, 33);
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3"
[11 22 33]

-- 1
BEGIN;
	CREATE TABLE t (c1 int);
	CREATE TABLE t (c1 int);
COMMIT;
||table.*exists

-- 2
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c1 int, c4 int);
COMMIT;
||duplicate column

-- 3
BEGIN;
	DROP TABLE none;
COMMIT;
||table .* not exist

-- 4
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int);
	DROP TABLE t;
COMMIT;
SELECT * FROM t;
||table .* not exist

-- 5
BEGIN;
	INSERT INTO none VALUES (1, 2);
COMMIT;
||table .* not exist

-- 6
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	INSERT INTO t VALUES (1);
COMMIT;
||expect

-- 7
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	INSERT INTO t VALUES (1, 2, 3);
COMMIT;
||expect

-- 8
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	INSERT INTO t VALUES (1, 2/(3*5-15));
COMMIT;
||integer divide by zero

-- 9
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	INSERT INTO t VALUES (2+3*4, 2*3+4);
COMMIT;
SELECT * FROM t;
|"c1", "c2"
[14 10]

-- 10
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	INSERT INTO t (c2, c4) VALUES (1);
COMMIT;
||expect

-- 11
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	INSERT INTO t (c2, c4) VALUES (1, 2, 3);
COMMIT;
||expect

-- 12
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	INSERT INTO t (c2, none) VALUES (1, 2);
COMMIT;
||unknown

-- 13
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	INSERT INTO t (c2, c3) VALUES (2+3*4, 2*3+4);
	INSERT INTO t VALUES (1, 2, 3, 4);
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3", "c4"
[<nil> 14 10 <nil>]
[1 2 3 4]

-- 14
BEGIN;
	TRUNCATE TABLE none;
COMMIT;
||table .* not exist

-- 15
SELECT * FROM none;
||table .* not exist

-- 16
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (1, "a");
COMMIT;
SELECT * FROM t;
|"c1", "c2"
[2 b]
[1 a]

-- 17
SELECT c1 FROM none;
||table .* not exist

-- 18
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT none FROM t;
||unknown

-- 19
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT c1, none, c2 FROM t;
||unknown

-- 20
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (1, "a");
COMMIT;
SELECT 3*c1 AS v FROM t;
|"v"
[6]
[3]

-- 21
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (1, "a");
COMMIT;
SELECT c2 FROM t;
|"c2"
[b]
[a]

-- 22
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (1, "a");
COMMIT;
SELECT c1 AS X, c2 FROM t;
|"X", "c2"
[2 b]
[1 a]

-- 23
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (1, "a");
COMMIT;
SELECT c2, c1 AS Y FROM t;
|"c2", "Y"
[b 2]
[a 1]

-- 24
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT * FROM t WHERE c3 = 1;
||unknown

-- 25
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT * FROM t WHERE c1 = 1;
|"c1", "c2"
[1 a]

-- 26
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT * FROM t ORDER BY c3;
||unknown

-- 27
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (22, "bc");
	INSERT INTO t VALUES (11, "ab");
	INSERT INTO t VALUES (33, "cd");
COMMIT;
SELECT * FROM t ORDER BY c1;
|"c1", "c2"
[11 ab]
[22 bc]
[33 cd]

-- 28
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT * FROM t ORDER BY c1 ASC;
|"c1", "c2"
[1 a]
[2 b]

-- 29
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
COMMIT;
SELECT * FROM t ORDER BY c1 DESC;
|"c1", "c2"
[2 b]
[1 a]

-- 30
BEGIN;
CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "b");
	INSERT INTO t VALUES (3, "c");
	INSERT INTO t VALUES (4, "d");
	INSERT INTO t VALUES (5, "e");
	INSERT INTO t VALUES (6, "f");
	INSERT INTO t VALUES (7, "g");
COMMIT;
SELECT * FROM t
WHERE c1 % 2 = 0
ORDER BY c2 DESC;
|"c1", "c2"
[6 f]
[4 d]
[2 b]

-- 31
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "a");
	INSERT INTO t VALUES (2, "a");
	INSERT INTO t VALUES (3, "b");
	INSERT INTO t VALUES (4, "b");
	INSERT INTO t VALUES (5, "c");
	INSERT INTO t VALUES (6, "c");
	INSERT INTO t VALUES (7, "d");
COMMIT;
SELECT * FROM t
ORDER BY c1, c2;
|"c1", "c2"
[1 a]
[2 a]
[3 b]
[4 b]
[5 c]
[6 c]
[7 d]

-- 32
BEGIN;
	CREATE TABLE t (c1 int, c2 TEXT);
	INSERT INTO t VALUES (1, "d");
	INSERT INTO t VALUES (2, "c");
	INSERT INTO t VALUES (3, "c");
	INSERT INTO t VALUES (4, "b");
	INSERT INTO t VALUES (5, "b");
	INSERT INTO t VALUES (6, "a");
	INSERT INTO t VALUES (7, "a");
COMMIT;
SELECT * FROM t
ORDER BY c2, c1
|"c1", "c2"
[6 a]
[7 a]
[4 b]
[5 b]
[2 c]
[3 c]
[1 d]

-- S 33
SELECT * FROM employee, none;
||table .* not exist

-- S 34
SELECT employee.LastName FROM employee, none;
||table .* not exist

-- S 35
SELECT none FROM employee, department;
||unknown

-- S 36
SELECT employee.LastName FROM employee, department;
|"LastName"
[Rafferty]
[Rafferty]
[Rafferty]
[Rafferty]
[Jones]
[Jones]
[Jones]
[Jones]
[Heisenberg]
[Heisenberg]
[Heisenberg]
[Heisenberg]
[Robinson]
[Robinson]
[Robinson]
[Robinson]
[Smith]
[Smith]
[Smith]
[Smith]
[Williams]
[Williams]
[Williams]
[Williams]

-- S 37
SELECT * FROM employee, department
ORDER by employee.LastName, department.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 38
SELECT *
FROM employee, department
WHERE employee.DepartmentID = department.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Rafferty 31 31 Sales]
[Jones 33 33 Engineering]
[Heisenberg 33 33 Engineering]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- S 39
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE employee.DepartmentID = department.DepartmentID
ORDER BY department.DepartmentName, employee.LastName;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Clerical 34 Robinson 34]
[Clerical 34 Smith 34]
[Engineering 33 Heisenberg 33]
[Engineering 33 Jones 33]
[Sales 31 Rafferty 31]

-- S 40
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE department.DepartmentName IN ("Sales", "Engineering", "HR", "Clerical")
ORDER BY employee.LastName, department.DepartmentID;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Sales 31 Heisenberg 33]
[Engineering 33 Heisenberg 33]
[Clerical 34 Heisenberg 33]
[Sales 31 Jones 33]
[Engineering 33 Jones 33]
[Clerical 34 Jones 33]
[Sales 31 Rafferty 31]
[Engineering 33 Rafferty 31]
[Clerical 34 Rafferty 31]
[Sales 31 Robinson 34]
[Engineering 33 Robinson 34]
[Clerical 34 Robinson 34]
[Sales 31 Smith 34]
[Engineering 33 Smith 34]
[Clerical 34 Smith 34]
[Sales 31 Williams <nil>]
[Engineering 33 Williams <nil>]
[Clerical 34 Williams <nil>]

-- S 41
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE (department.DepartmentID+1000) IN (1031, 1035, 1036)
ORDER BY employee.LastName;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Sales 31 Heisenberg 33]
[Marketing 35 Heisenberg 33]
[Sales 31 Jones 33]
[Marketing 35 Jones 33]
[Sales 31 Rafferty 31]
[Marketing 35 Rafferty 31]
[Sales 31 Robinson 34]
[Marketing 35 Robinson 34]
[Sales 31 Smith 34]
[Marketing 35 Smith 34]
[Sales 31 Williams <nil>]
[Marketing 35 Williams <nil>]

-- S 42
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE department.DepartmentName NOT IN ("Engineering", "HR", "Clerical");
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Sales 31 Rafferty 31]
[Marketing 35 Rafferty 31]
[Sales 31 Jones 33]
[Marketing 35 Jones 33]
[Sales 31 Heisenberg 33]
[Marketing 35 Heisenberg 33]
[Sales 31 Robinson 34]
[Marketing 35 Robinson 34]
[Sales 31 Smith 34]
[Marketing 35 Smith 34]
[Sales 31 Williams <nil>]
[Marketing 35 Williams <nil>]

-- S 43
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE department.DepartmentID BETWEEN 34 AND 36
ORDER BY employee.LastName;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Clerical 34 Heisenberg 33]
[Marketing 35 Heisenberg 33]
[Clerical 34 Jones 33]
[Marketing 35 Jones 33]
[Clerical 34 Rafferty 31]
[Marketing 35 Rafferty 31]
[Clerical 34 Robinson 34]
[Marketing 35 Robinson 34]
[Clerical 34 Smith 34]
[Marketing 35 Smith 34]
[Clerical 34 Williams <nil>]
[Marketing 35 Williams <nil>]

-- S 44
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE department.DepartmentID BETWEEN cast(34 as signed) AND cast(36 as signed)
ORDER BY employee.LastName;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Clerical 34 Heisenberg 33]
[Marketing 35 Heisenberg 33]
[Clerical 34 Jones 33]
[Marketing 35 Jones 33]
[Clerical 34 Rafferty 31]
[Marketing 35 Rafferty 31]
[Clerical 34 Robinson 34]
[Marketing 35 Robinson 34]
[Clerical 34 Smith 34]
[Marketing 35 Smith 34]
[Clerical 34 Williams <nil>]
[Marketing 35 Williams <nil>]

-- S 45
SELECT department.DepartmentName, department.DepartmentID, employee.LastName, employee.DepartmentID
FROM employee, department
WHERE department.DepartmentID NOT BETWEEN 33 AND 34 -- TODO plan for 'or' in this case is possible.
ORDER BY employee.LastName;
|"DepartmentName", "DepartmentID", "LastName", "DepartmentID"
[Sales 31 Heisenberg 33]
[Marketing 35 Heisenberg 33]
[Sales 31 Jones 33]
[Marketing 35 Jones 33]
[Sales 31 Rafferty 31]
[Marketing 35 Rafferty 31]
[Sales 31 Robinson 34]
[Marketing 35 Robinson 34]
[Sales 31 Smith 34]
[Marketing 35 Smith 34]
[Sales 31 Williams <nil>]
[Marketing 35 Williams <nil>]

-- S 46
SELECT LastName, LastName FROM employee;
|"LastName", "LastName"
[Rafferty Rafferty]
[Jones Jones]
[Heisenberg Heisenberg]
[Robinson Robinson]
[Smith Smith]
[Williams Williams]

-- S 47
SELECT concat(LastName,", ") AS a, LastName AS a FROM employee;
|"a", "a"
[Rafferty,  Rafferty]
[Jones,  Jones]
[Heisenberg,  Heisenberg]
[Robinson,  Robinson]
[Smith,  Smith]
[Williams,  Williams]

-- S 48
SELECT LastName AS a, LastName AS b FROM employee
ORDER by a, b;
|"a", "b"
[Heisenberg Heisenberg]
[Jones Jones]
[Rafferty Rafferty]
[Robinson Robinson]
[Smith Smith]
[Williams Williams]

-- S 49
SELECT employee.LastName AS name, employee.DepartmentID AS id, department.DepartmentName AS department, department.DepartmentID AS id2
FROM employee, department
WHERE employee.DepartmentID = department.DepartmentID
ORDER BY name, id, department, id2;
|"name", "id", "department", "id2"
[Heisenberg 33 Engineering 33]
[Jones 33 Engineering 33]
[Rafferty 31 Sales 31]
[Robinson 34 Clerical 34]
[Smith 34 Clerical 34]

-- S 50
SELECT * FROM;
||";"

-- S 51
SELECT * FROM employee
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 33]
[Jones 33]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- S 52
SELECT * FROM employee AS e
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 33]
[Jones 33]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- S 53
SELECT none FROM (
	SELECT * FROM employee
	SELECT * FROM department
);
||"SELECT"

-- S 54
SELECT none FROM (
	SELECT * FROM employee
) AS a;
||unknown

-- S 55
SELECT noneCol FROM (
	SELECT * FROM noneTab
) AS a;
||not exist

-- S 56
SELECT noneCol FROM (
	SELECT * FROM employee
) AS a;
||unknown

-- S 57
SELECT * FROM (
	SELECT * FROM employee
) AS a
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 33]
[Jones 33]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- S 58
SELECT * FROM (
	SELECT LastName AS Name FROM employee
) AS a
ORDER BY Name;
|"Name"
[Heisenberg]
[Jones]
[Rafferty]
[Robinson]
[Smith]
[Williams]

-- S 59
SELECT Name FROM (
	SELECT LastName AS name FROM employee
) AS a;
|"Name"
[Rafferty]
[Jones]
[Heisenberg]
[Robinson]
[Smith]
[Williams]

-- S 60
SELECT name AS Name FROM (
	SELECT LastName AS name
	FROM employee AS e
) AS a
ORDER BY Name;
|"Name"
[Heisenberg]
[Jones]
[Rafferty]
[Robinson]
[Smith]
[Williams]

-- S 61
SELECT name AS Name FROM (
	SELECT LastName AS name FROM employee
) AS a
ORDER BY Name;
|"Name"
[Heisenberg]
[Jones]
[Rafferty]
[Robinson]
[Smith]
[Williams]

-- S 62
SELECT LastName, DepartmentName, DepartmentID FROM (
	SELECT LastName, DepartmentName, employee.DepartmentID
	FROM employee, department
	WHERE employee.DepartmentID = department.DepartmentID
) AS a
ORDER BY DepartmentName, LastName
|"LastName", "DepartmentName", "DepartmentID"
[Robinson Clerical 34]
[Smith Clerical 34]
[Heisenberg Engineering 33]
[Jones Engineering 33]
[Rafferty Sales 31]

-- S 63
SELECT LastName, DepartmentName, DepartmentID FROM (
	SELECT LastName, DepartmentName, e.DepartmentID
	FROM employee AS e, department AS d
	WHERE e.DepartmentID = d.DepartmentID
) AS a 
ORDER by DepartmentName, LastName;
|"LastName", "DepartmentName", "DepartmentID"
[Robinson Clerical 34]
[Smith Clerical 34]
[Heisenberg Engineering 33]
[Jones Engineering 33]
[Rafferty Sales 31]

-- S 64
SELECT LastName AS name, DepartmentName AS department, DepartmentID AS id FROM (
	SELECT LastName, DepartmentName, e.DepartmentID
	FROM employee AS e, department AS d
	WHERE e.DepartmentID = d.DepartmentID
) AS a 
ORDER by department, name
|"name", "department", "id"
[Robinson Clerical 34]
[Smith Clerical 34]
[Heisenberg Engineering 33]
[Jones Engineering 33]
[Rafferty Sales 31]

-- S 65
SELECT name, department, id FROM (
	SELECT e.LastName AS name, e.DepartmentID AS id, d.DepartmentName AS department, d.DepartmentID AS fid
	FROM employee AS e, department AS d
	WHERE e.DepartmentID = d.DepartmentID
) AS a 
ORDER by department, name;
|"name", "department", "id"
[Robinson Clerical 34]
[Smith Clerical 34]
[Heisenberg Engineering 33]
[Jones Engineering 33]
[Rafferty Sales 31]

-- S 66
SELECT *
FROM
(
	SELECT *
	FROM employee
) AS a,
(
	SELECT *
	FROM department
) AS b;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 67
SELECT *
FROM
(
	SELECT *
	FROM employee
) AS e,
(
	SELECT *
	FROM department
) AS d
ORDER BY e.LastName, e.DepartmentID, d.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 68
SELECT *
FROM
(
	SELECT *
	FROM employee
) AS e,
(
	SELECT *
	FROM department
) AS d
ORDER BY d.DepartmentID DESC, e.DepartmentID DESC;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Robinson 34 35 Marketing]
[Smith 34 35 Marketing]
[Jones 33 35 Marketing]
[Heisenberg 33 35 Marketing]
[Rafferty 31 35 Marketing]
[Williams <nil> 35 Marketing]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Heisenberg 33 34 Clerical]
[Jones 33 34 Clerical]
[Rafferty 31 34 Clerical]
[Williams <nil> 34 Clerical]
[Smith 34 33 Engineering]
[Robinson 34 33 Engineering]
[Jones 33 33 Engineering]
[Heisenberg 33 33 Engineering]
[Rafferty 31 33 Engineering]
[Williams <nil> 33 Engineering]
[Robinson 34 31 Sales]
[Smith 34 31 Sales]
[Heisenberg 33 31 Sales]
[Jones 33 31 Sales]
[Rafferty 31 31 Sales]
[Williams <nil> 31 Sales]

-- S 69
SELECT *
FROM
	employee,
	(
		SELECT *
		FROM department
	) AS d
ORDER BY employee.LastName, d.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 70
SELECT *
FROM
(
	SELECT *
	FROM employee
) AS e,
(
	SELECT *
	FROM department
) AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, e.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]

-- S 71
SELECT *
FROM
	employee,
	(
		SELECT *
		FROM department
	) AS d
WHERE employee.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]

-- S 72
SELECT *
FROM
	employee AS e,
	(
		SELECT *
		FROM department
	) AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY d.DepartmentName, e.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]

-- S 73
SELECT *
FROM
	employee AS e,
	(
		SELECT *
		FROM department
	) AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.DepartmentID, e.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Rafferty 31 31 Sales]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- S 74
SELECT *
FROM
	employee AS e,
	(
		SELECT *
		FROM department
	) AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.DepartmentID, e.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Rafferty 31 31 Sales]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- 101
BEGIN;
	CREATE TABLE t (c1 bool);
	INSERT INTO t VALUES (true);
COMMIT;
SELECT * from t
WHERE c1 > 3;
|"c1"

-- 102
BEGIN;
	CREATE TABLE t (c1 bool);
	INSERT INTO t VALUES (true);
COMMIT;
SELECT * from t
WHERE c1;
|"c1"
[1]

-- 103
BEGIN;
	CREATE TABLE t (c1 TINYINT);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 104
BEGIN;
	CREATE TABLE t (c1 SMALLINT);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 105
BEGIN;
	CREATE TABLE t (c1 int);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 106
BEGIN;
	CREATE TABLE t (c1 int);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 107
BEGIN;
	CREATE TABLE t (c1 TINYINT UNSIGNED);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 108
BEGIN;
	CREATE TABLE t (c1 SMALLINT UNSIGNED);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 109
BEGIN;
	CREATE TABLE t (c1 INT UNSIGNED);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 110
BEGIN;
	CREATE TABLE t (c1 bigint unsigned);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 111
BEGIN;
	CREATE TABLE t (c1 bigint unsigned);
	INSERT INTO t VALUES (1);
COMMIT;
SELECT * from t
WHERE c1 = 1;
|"c1"
[1]

-- 112
BEGIN;
	CREATE TABLE t (c1 float);
	INSERT INTO t VALUES (8);
COMMIT;
SELECT * from t
WHERE c1 = 8;
|"c1"
[8]

-- 113
BEGIN;
	CREATE TABLE t (c1 double);
	INSERT INTO t VALUES (2);
COMMIT;
SELECT * from t
WHERE c1 = 2;
|"c1"
[2]

-- 114
BEGIN;
	CREATE TABLE t (c1 float);
	INSERT INTO t VALUES (2.);
COMMIT;
SELECT * from t
WHERE c1 = 2;
|"c1"
[2]

-- 115
BEGIN;
	CREATE TABLE t (c1 TEXT);
	INSERT INTO t VALUES ("foo");
COMMIT;
SELECT * from t
WHERE c1 = "2";
|"c1"

-- 116
BEGIN;
	CREATE TABLE t (c1 TEXT);
	INSERT INTO t VALUES ("foo");
COMMIT;
SELECT * from t
WHERE c1 = "foo";
|"c1"
[foo]

-- 117
SELECT 2/(3*5-15) AS foo FROM bar;
||table test.bar does not exist

-- 118
SELECT 2.0/(2.0-2.0) AS foo FROM bar;
||table test.bar does not exist

-- 120
SELECT 2/(3*5-x) AS foo FROM bar;
||table .* not exist

-- S 121
SELECT 314, 42 AS AUQLUE, DepartmentID, DepartmentID+1000, LastName AS Name
FROM employee
ORDER BY Name;
|"314", "AUQLUE", "DepartmentID", "DepartmentID + 1000", "Name"
[314 42 33 1033 Heisenberg]
[314 42 33 1033 Jones]
[314 42 31 1031 Rafferty]
[314 42 34 1034 Robinson]
[314 42 34 1034 Smith]
[314 42 <nil> <nil> Williams]

-- S 122
SELECT *
FROM
	employee AS e,
	( SELECT * FROM department) AS d
ORDER BY e.LastName, d.DepartmentID;
| "LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 123
SELECT * FROM employee AS e, ( SELECT * FROM department) AS d
ORDER BY e.LastName, d.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- 125
BEGIN;
	CREATE TABLE p (p bool);
	INSERT INTO p VALUES (NULL), (false), (true);
COMMIT;
SELECT * FROM p;
|"p"
[<nil>]
[0]
[1]

-- 126
BEGIN;
	CREATE TABLE p (p bool);
	INSERT INTO p VALUES (NULL), (false), (true);
COMMIT;
SELECT p.p AS p, q.p AS q, p.p OR q.p AS p_or_q, p.p && q.p aS p_and_q FROM p, p AS q;
|"p", "q", "p_or_q", "p_and_q"
[<nil> <nil> <nil> <nil>]
[<nil> 0 <nil> 0]
[<nil> 1 1 <nil>]
[0 <nil> <nil> 0]
[0 0 0 0]
[0 1 1 0]
[1 <nil> 1 <nil>]
[1 0 1 0]
[1 1 1 1]

-- 127
BEGIN;
	CREATE TABLE p (p bool);
	INSERT INTO p VALUES (NULL), (false), (true);
COMMIT;
SELECT p, !p AS not_p FROM p;
|"p", "not_p"
[<nil> <nil>]
[0 1]
[1 0]

-- S 128
SELECT * FROM department WHERE DepartmentID >= 33
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[33 Engineering]
[34 Clerical]
[35 Marketing]

-- S 129
SELECT * FROM department WHERE DepartmentID <= 34
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[31 Sales]
[33 Engineering]
[34 Clerical]

-- S 130
SELECT * FROM department WHERE DepartmentID < 34
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[31 Sales]
[33 Engineering]

-- S 131
SELECT +DepartmentID FROM employee;
|"+DepartmentID"
[31]
[33]
[33]
[34]
[34]
[<nil>]

-- S 132
SELECT * FROM employee
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 33]
[Jones 33]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- S 133
SELECT *
FROM employee
ORDER BY LastName DESC;
|"LastName", "DepartmentID"
[Williams <nil>]
[Smith 34]
[Robinson 34]
[Rafferty 31]
[Jones 33]
[Heisenberg 33]

-- S 134
SELECT 1023+DepartmentID AS y FROM employee
ORDER BY y DESC;
|"y"
[1057]
[1057]
[1056]
[1056]
[1054]
[<nil>]

-- S 135
SELECT +DepartmentID AS y FROM employee
ORDER BY y DESC;
|"y"
[34]
[34]
[33]
[33]
[31]
[<nil>]

-- S 136
SELECT * FROM employee ORDER BY DepartmentID DESC, LastName DESC;
|"LastName", "DepartmentID"
[Smith 34]
[Robinson 34]
[Jones 33]
[Heisenberg 33]
[Rafferty 31]
[Williams <nil>]

-- S 137
SELECT * FROM employee ORDER BY 0+DepartmentID DESC, LastName DESC;
|"LastName", "DepartmentID"
[Smith 34]
[Robinson 34]
[Jones 33]
[Heisenberg 33]
[Rafferty 31]
[Williams <nil>]

-- S 138
SELECT * FROM employee ORDER BY +DepartmentID DESC, LastName DESC;
|"LastName", "DepartmentID"
[Smith 34]
[Robinson 34]
[Jones 33]
[Heisenberg 33]
[Rafferty 31]
[Williams <nil>]

-- S 139
SELECT ~DepartmentID AS y FROM employee
ORDER BY y DESC;
|"y"
[18446744073709551584]
[18446744073709551582]
[18446744073709551582]
[18446744073709551581]
[18446744073709551581]
[<nil>]

-- S 140
SELECT ~(DepartmentID) AS y FROM employee ORDER BY y DESC;
|"y"
[18446744073709551584]
[18446744073709551582]
[18446744073709551582]
[18446744073709551581]
[18446744073709551581]
[<nil>]

-- 141
BEGIN;
	CREATE TABLE t (i int);
	INSERT INTO t VALUES (-2), (-1), (0), (1), (2);
COMMIT;
SELECT i^1 AS y FROM t
ORDER by y;
|"y"
[0]
[1]
[3]
[18446744073709551614]
[18446744073709551615]

-- 142
BEGIN;
	CREATE TABLE t (i int);
	INSERT INTO t VALUES (-2), (-1), (0), (1), (2);
COMMIT;
SELECT i&or;1 AS y FROM t
ORDER BY y;
|"y"
[1]
[1]
[3]
[18446744073709551615]
[18446744073709551615]

-- 143
BEGIN;
	CREATE TABLE t (i int);
	INSERT INTO t VALUES (-2), (-1), (0), (1), (2);
COMMIT;
SELECT i&1 FROM t;
|"i & 1"
[0]
[1]
[0]
[1]
[0]

-- S 145
SELECT * from employee WHERE LastName = "Jones" OR DepartmentID IS NULL
ORDER by LastName DESC;
|"LastName", "DepartmentID"
[Williams <nil>]
[Jones 33]

-- S 146
SELECT * from employee WHERE LastName != "Jones" && DepartmentID IS NOT NULL
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 33]
[Rafferty 31]
[Robinson 34]
[Smith 34]

-- S 157
SELECT LastName
FROM employee
WHERE department IS NULL;
||unknown field department

-- S 159
SELECT
	DepartmentID AS x,
	DepartmentID<<1 AS a,
	1<<cast(DepartmentID as unsigned) AS b
FROM
	employee
WHERE DepartmentID IS NOT NULL
ORDER BY x;
|"x", "a", "b"
[31 62 2147483648]
[33 66 8589934592]
[33 66 8589934592]
[34 68 17179869184]
[34 68 17179869184]

-- S 160
SELECT
	DepartmentID AS x,
	DepartmentID>>1 AS a,
	cast(1 as unsigned)<<63>>cast(DepartmentID as unsigned) AS b
FROM
	employee
WHERE DepartmentID IS NOT NULL
ORDER BY x;
|"x", "a", "b"
[31 15 4294967296]
[33 16 1073741824]
[33 16 1073741824]
[34 17 536870912]
[34 17 536870912]

-- S 161
SELECT DISTINCT DepartmentID
FROM employee
WHERE DepartmentID IS NOT NULL;
|"DepartmentID"
[31]
[33]
[34]

-- S 162
SELECT DISTINCT e.DepartmentID, d.DepartmentID, e.LastName
FROM employee AS e, department AS d
WHERE e.DepartmentID = d.DepartmentID;
|"DepartmentID", "DepartmentID", "LastName"
[31 31 Rafferty]
[33 33 Jones]
[33 33 Heisenberg]
[34 34 Robinson]
[34 34 Smith]

-- S 163
SELECT DISTINCT e.DepartmentID, d.DepartmentID, e.LastName
FROM employee AS e, department AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.LastName;
|"DepartmentID", "DepartmentID", "LastName"
[33 33 Heisenberg]
[33 33 Jones]
[31 31 Rafferty]
[34 34 Robinson]
[34 34 Smith]

-- S 164
SELECT *
FROM employee, department
ORDER BY employee.LastName, department.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 31 Sales]
[Heisenberg 33 33 Engineering]
[Heisenberg 33 34 Clerical]
[Heisenberg 33 35 Marketing]
[Jones 33 31 Sales]
[Jones 33 33 Engineering]
[Jones 33 34 Clerical]
[Jones 33 35 Marketing]
[Rafferty 31 31 Sales]
[Rafferty 31 33 Engineering]
[Rafferty 31 34 Clerical]
[Rafferty 31 35 Marketing]
[Robinson 34 31 Sales]
[Robinson 34 33 Engineering]
[Robinson 34 34 Clerical]
[Robinson 34 35 Marketing]
[Smith 34 31 Sales]
[Smith 34 33 Engineering]
[Smith 34 34 Clerical]
[Smith 34 35 Marketing]
[Williams <nil> 31 Sales]
[Williams <nil> 33 Engineering]
[Williams <nil> 34 Clerical]
[Williams <nil> 35 Marketing]

-- S 165
SELECT *
FROM employee, department
WHERE employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName, department.DepartmentID;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- S 166
BEGIN;
	INSERT INTO department (DepartmentID, DepartmentName)
	SELECT DepartmentID+1000, concat(DepartmentName,"/headquarters")
	FROM department;
COMMIT;
SELECT * FROM department
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[31 Sales]
[33 Engineering]
[34 Clerical]
[35 Marketing]
[1031 Sales/headquarters]
[1033 Engineering/headquarters]
[1034 Clerical/headquarters]
[1035 Marketing/headquarters]

-- S 167
BEGIN;
	INSERT INTO department (DepartmentName, DepartmentID)
	SELECT concat(DepartmentName,"/headquarters"), DepartmentID+1000
	FROM department;
COMMIT;
SELECT * FROM department
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[31 Sales]
[33 Engineering]
[34 Clerical]
[35 Marketing]
[1031 Sales/headquarters]
[1033 Engineering/headquarters]
[1034 Clerical/headquarters]
[1035 Marketing/headquarters]

-- S 168
BEGIN;
	DELETE FROM department;
COMMIT;
SELECT * FROM department
|"DepartmentID", "DepartmentName"

-- S 169
BEGIN;
	DELETE FROM department
	WHERE DepartmentID = 35 OR DepartmentName != "" && DepartmentName = 'C';
COMMIT;
SELECT * FROM department
ORDER BY DepartmentID;
|"DepartmentID", "DepartmentName"
[31 Sales]
[33 Engineering]
[34 Clerical]

-- S 170
SELECT LastName
FROM employee

|"LastName"
[Rafferty]
[Jones]
[Heisenberg]
[Robinson]
[Smith]
[Williams]

-- S 171
BEGIN;
	DELETE FROM employee
	WHERE LastName = "Jones";
COMMIT;
SELECT LastName
FROM employee;
|"LastName"
[Rafferty]
[Heisenberg]
[Robinson]
[Smith]
[Williams]

-- S 172
SELECT e.LastName, e.DepartmentID, d.DepartmentID
FROM
	employee AS e,
	department AS d
WHERE e.DepartmentID = d.DepartmentID
ORDER BY e.LastName;
|"LastName", "DepartmentID", "DepartmentID"
[Heisenberg 33 33]
[Jones 33 33]
[Rafferty 31 31]
[Robinson 34 34]
[Smith 34 34]

-- S 173
SELECT e.LastName, e.DepartmentID, d.DepartmentID
FROM
	(SELECT LastName, DepartmentID FROM employee) AS e,
	department AS d
WHERE e.DepartmentID = d.DepartmentID
|"LastName", "DepartmentID", "DepartmentID"
[Rafferty 31 31]
[Jones 33 33]
[Heisenberg 33 33]
[Robinson 34 34]
[Smith 34 34]

-- S 174
BEGIN;
	UPDATE none
		SET DepartmentID = DepartmentID+1000
	WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee;
||table.*not.*exist

-- S 175
BEGIN;
	UPDATE employee
		SET FirstName = "Williams"
	WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee;
||unknown.*FirstName

-- S 176
BEGIN;
	UPDATE employee
		SET DepartmentID = DepartmentID+1000
	WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 1033]
[Jones 1033]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- S 177
BEGIN;
	UPDATE employee
		SET DepartmentID = DepartmentID+1000;
COMMIT;
SELECT * FROM employee
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 1033]
[Jones 1033]
[Rafferty 1031]
[Robinson 1034]
[Smith 1034]
[Williams <nil>]

-- S 178
BEGIN;
	UPDATE employee
		SET DepartmentId = DepartmentID+1000;
COMMIT;
SELECT * FROM employee;
|"LastName", "DepartmentID"
[Rafferty 1031]
[Jones 1033]
[Heisenberg 1033]
[Robinson 1034]
[Smith 1034]
[Williams <nil>]

-- S 179
BEGIN;
	UPDATE employee
		SET DepartmentID = DepartmentId+1000;
COMMIT;
SELECT * FROM employee;
|"LastName", "DepartmentID"
[Rafferty 1031]
[Jones 1033]
[Heisenberg 1033]
[Robinson 1034]
[Smith 1034]
[Williams <nil>]

-- S 180
BEGIN;
	UPDATE employee
		SET DepartmentID = "foo";
COMMIT;
SELECT * FROM employee;
||type

-- 187
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE a;
COMMIT;
SELECT * FROM b;
|"b"

-- 188
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE a;
COMMIT;
SELECT * FROM c;
|"c"

-- 189
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE b;
COMMIT;
SELECT * FROM a;
|"a"

-- 190
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE b;
COMMIT;
SELECT * FROM b;
||table test.b does not exist

-- 191
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE b;
COMMIT;
SELECT * FROM c;
|"c"

-- 192
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE c;
COMMIT;
SELECT * FROM a;
|"a"

-- 193
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE c;
COMMIT;
SELECT * FROM b;
|"b"

-- 194
BEGIN;
	CREATE TABLE a (a int);
	CREATE TABLE b (b int);
	CREATE TABLE c (c int);
	DROP TABLE c;
COMMIT;
SELECT * FROM c;
||table test.c does not exist

-- 195
BEGIN;
	CREATE TABLE a (c int);
	INSERT INTO a VALUES (10), (11), (12);
	CREATE TABLE b (d int);
	INSERT INTO b VALUES (20), (21), (22), (23);
COMMIT;
SELECT * FROM a, b ORDER BY a.c DESC, b.d DESC;
|"c", "d"
[12 23]
[12 22]
[12 21]
[12 20]
[11 23]
[11 22]
[11 21]
[11 20]
[10 23]
[10 22]
[10 21]
[10 20]

-- 196
BEGIN;
	CREATE TABLE a (c int);
	INSERT INTO a VALUES (0), (1), (2);
COMMIT;
SELECT
	9*x2.c AS x2,
	3*x1.c AS x1,
	1*x0.c AS x0,
	9*x2.c + 3*x1.c + x0.c AS y
FROM
	a AS x2,
	a AS x1,
	a AS x0
ORDER BY y;
|"x2", "x1", "x0", "y"
[0 0 0 0]
[0 0 1 1]
[0 0 2 2]
[0 3 0 3]
[0 3 1 4]
[0 3 2 5]
[0 6 0 6]
[0 6 1 7]
[0 6 2 8]
[9 0 0 9]
[9 0 1 10]
[9 0 2 11]
[9 3 0 12]
[9 3 1 13]
[9 3 2 14]
[9 6 0 15]
[9 6 1 16]
[9 6 2 17]
[18 0 0 18]
[18 0 1 19]
[18 0 2 20]
[18 3 0 21]
[18 3 1 22]
[18 3 2 23]
[18 6 0 24]
[18 6 1 25]
[18 6 2 26]

-- 197
BEGIN;
	CREATE TABLE t (c int);
	INSERT INTO t VALUES (242);
	DELETE FROM t WHERE c != 0;
COMMIT;
SELECT * FROM t
|"c"

-- 200
BEGIN;
	CREATE TABLE t (i int);
COMMIT;
BEGIN;
	DROP TABLE T;
COMMIT;
SELECT * from t;
||does not exist

-- 201
BEGIN;
	CREATE TABLE t (i int);
	INSERT INTO t VALUES ("65.0");
COMMIT;
SELECT * FROM t;
|"i"
[65]

-- 202
BEGIN;
	CREATE TABLE t (s TEXT);
	INSERT INTO t VALUES (CAST(65 AS CHAR));
COMMIT;
SELECT * FROM t;
|"s"
[65]

-- 206
BEGIN;
	CREATE TABLE t (i TINYINT);
	INSERT INTO t VALUES (-129+2);
COMMIT;
SELECT * FROM t;
|"i"
[-127]

-- 207
BEGIN;
	CREATE TABLE t (i TINYINT);
	INSERT INTO t VALUES (-128+2);
COMMIT;
SELECT * FROM t;
|"i"
[-126]

-- 208
BEGIN;
	CREATE TABLE t (i TINYINT);
	INSERT INTO t VALUES (128+2);
COMMIT;
SELECT * FROM t;
||overflow

-- S 209
SELECT count(none) FROM employee;
||unknown

-- S 210
SELECT count(*) FROM employee;
|"count(*)"
[6]

-- S 211
SELECT count(*) AS y FROM employee;
|"y"
[6]

-- S 212
SELECT 3*count(*) AS y FROM employee;
|"y"
[18]

-- S 213
SELECT count(LastName) FROM employee;
|"count(LastName)"
[6]

-- S 214
SELECT count(DepartmentID) FROM employee;
|"count(DepartmentID)"
[5]

-- S 215
SELECT count(*) - count(DepartmentID) FROM employee;
|"count(*) - count(DepartmentID)"
[1]

-- S 216
SELECT min(LastName), min(DepartmentID) FROM employee;
|"min(LastName)", "min(DepartmentID)"
[Heisenberg 31]

-- S 217
SELECT max(LastName), max(DepartmentID) FROM employee;
|"max(LastName)", "max(DepartmentID)"
[Williams 34]

-- S 218
SELECT sum(LastName), sum(DepartmentID) FROM employee;
||eval SUM aggregate err

-- S 219
SELECT sum(DepartmentID) FROM employee;
|"sum(DepartmentID)"
[165]

-- S 220
SELECT avg(DepartmentID) FROM employee;
|"avg(DepartmentID)"
[33.0000]

-- S 221
SELECT DepartmentID FROM employee GROUP BY none;
||unknown field none

-- S 222
SELECT DepartmentID, sum(DepartmentID) AS s FROM employee GROUP BY DepartmentID ORDER BY s DESC;
|"DepartmentID", "s"
[34 68]
[33 66]
[31 31]
[<nil> <nil>]

-- S 223
SELECT DepartmentID, count(concat(LastName,CAST(DepartmentID AS CHAR))) AS y FROM employee GROUP BY DepartmentID ORDER BY y DESC, DepartmentID DESC;
|"DepartmentID", "y"
[34 2]
[33 2]
[31 1]
[<nil> 0]

-- S 224
SELECT DepartmentID, sum(2*DepartmentID) AS s FROM employee GROUP BY DepartmentID ORDER BY s DESC;
|"DepartmentID", "s"
[34 136]
[33 132]
[31 62]
[<nil> <nil>]

-- S 225
SELECT min(2*DepartmentID) FROM employee;
|"min(2 * DepartmentID)"
[62]

-- S 226
SELECT max(2*DepartmentID) FROM employee;
|"max(2 * DepartmentID)"
[68]

-- S 227
SELECT avg(2*DepartmentID) FROM employee;
|"avg(2 * DepartmentID)"
[66.0000]

-- S 228
SELECT * FROM employee GROUP BY DepartmentID ORDER BY DepartmentID;
|"LastName", "DepartmentID"
[Williams <nil>]
[Rafferty 31]
[Jones 33]
[Robinson 34]

-- S 229
SELECT * FROM employee GROUP BY DepartmentID ORDER BY LastName DESC;
|"LastName", "DepartmentID"
[Williams <nil>]
[Robinson 34]
[Rafferty 31]
[Jones 33]

-- S 230
SELECT * FROM employee GROUP BY DepartmentID, LastName ORDER BY LastName DESC;
|"LastName", "DepartmentID"
[Williams <nil>]
[Smith 34]
[Robinson 34]
[Rafferty 31]
[Jones 33]
[Heisenberg 33]

-- S 231
SELECT * FROM employee GROUP BY LastName, DepartmentID  ORDER BY LastName DESC;
|"LastName", "DepartmentID"
[Williams <nil>]
[Smith 34]
[Robinson 34]
[Rafferty 31]
[Jones 33]
[Heisenberg 33]

-- 232
BEGIN;
	CREATE TABLE s (i int);
	CREATE TABLE t (i int);
COMMIT;
BEGIN;
	DROP TABLE s;
COMMIT;
SELECT * FROM t;
|"i"

-- 233
BEGIN;
	CREATE TABLE t (n int);
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[0]

-- 234
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[2]

-- 235
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT count(*) FROM t WHERE n < 2;
|"count(*)"
[2]

-- 236
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT count(*) FROM t WHERE n < 1;
|"count(*)"
[1]

-- 237
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT count(*) FROM t WHERE n < 0;
|"count(*)"
[0]

-- 238
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT s+10 FROM (SELECT sum(n) AS s FROM t WHERE n < 2) AS a;
|"s + 10"
[11]

-- 239
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT s+10 FROM (SELECT sum(n) AS s FROM t WHERE n < 1) AS a;
|"s + 10"
[10]

-- 240
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT s+10 FROM (SELECT sum(n) AS s FROM t WHERE n < 0) AS a;
|"s + 10"
[<nil>]

-- 241
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT sum(n) AS s FROM t WHERE n < 2;
|"s"
[1]

-- 242
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT sum(n) AS s FROM t WHERE n < 1;
|"s"
[0]

-- 243
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1);
COMMIT;
SELECT sum(n) AS s FROM t WHERE n < 0;
|"s"
[<nil>]

-- 244
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t SELECT count(*) FROM t;
	INSERT INTO t SELECT count(*) FROM t;
	INSERT INTO t SELECT count(*) FROM t;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[3]

-- 245
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t SELECT count(*) FROM t;
	INSERT INTO t SELECT count(*) FROM t;
	INSERT INTO t SELECT count(*) FROM t;
	INSERT INTO t SELECT * FROM t;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[6]

-- 246
BEGIN;
	CREATE TABLE t (n int);
	INSERT INTO t VALUES (0), (1), (2);
	INSERT INTO t SELECT * FROM t;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[6]

-- 247
BEGIN;
	CREATE TABLE t(S TEXT);
	INSERT INTO t SELECT "perfect!" FROM (SELECT count(*) AS cnt FROM t WHERE S = "perfect!") AS a WHERE cnt = 0;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[1]

-- 248
BEGIN;
	CREATE TABLE t(S TEXT);
	INSERT INTO t SELECT "perfect!" FROM (SELECT count(*) AS cnt FROM t WHERE S = "perfect!") AS a WHERE cnt = 0;
	INSERT INTO t SELECT "perfect!" FROM (SELECT count(*) AS cnt FROM t WHERE S = "perfect!") AS a WHERE cnt = 0;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[1]

-- 249
BEGIN;
    CREATE TABLE t(c blob);
    INSERT INTO t VALUES (CAST("a" AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[97]]

-- 250
BEGIN;
    CREATE TABLE t(c blob);
    INSERT INTO t VALUES (CAST('
0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
' AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[10 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 10]]

-- 251
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST(
concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF") AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70]]

-- 252
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST(
concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF",
"!") AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70 33]]

-- 253
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST("hell\xc3\xb8" AS BINARY));
COMMIT;
SELECT CAST(c AS CHAR) FROM t;
|"CAST(c AS CHAR)"
[hellø]

-- 254
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST(
concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF",
"!") AS BINARY));
COMMIT;
SELECT CAST(c AS CHAR) FROM t;
|"CAST(c AS CHAR)"
[0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 255
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST("" AS BINARY));
COMMIT;
SELECT CAST(c AS CHAR) FROM t;
|"CAST(c AS CHAR)"
[]

-- 256
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST("hellø" AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[104 101 108 108 195 184]]

-- 257
BEGIN;
	CREATE TABLE t(c blob);
	INSERT INTO t VALUES (CAST("" AS BINARY));
COMMIT;
SELECT * FROM t;
|"c"
[[]]

-- 258
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY))
	;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]

-- 259
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY))
	;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]
[1 [49]]

-- 260
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY)),
		(2, CAST("2" AS BINARY))
	;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]
[1 [49]]
[2 [50]]

-- 261
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT * FROM t;
|"i", "b"

-- 262
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT * FROM t;
|"i", "b"
[1 [49]]

-- 263
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY))
	;
	DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]

-- 264
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY)),
		(2, CAST("2" AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT * FROM t;
|"i", "b"
[1 [49]]
[2 [50]]

-- 265
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY)),
		(2, CAST("2" AS BINARY))
	;
	DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]
[2 [50]]

-- 266
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST("0" AS BINARY)),
		(1, CAST("1" AS BINARY)),
		(2, CAST("2" AS BINARY))
	;
	DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]
[1 [49]]

-- 267
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"

-- 268
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(1, CAST(
			concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"
[1 1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 269
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(1, CAST(
			concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 1;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"
[0 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 270
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(1, CAST(
			concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(2, CAST(
			concat("2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 0;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"
[1 1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]
[2 2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 271
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(1, CAST(
			concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(2, CAST(
			concat("2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 1;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"
[0 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]
[2 2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 272
BEGIN;
	CREATE TABLE t(i int, b blob);
	INSERT INTO t VALUES
		(0, CAST(
			concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(1, CAST(
			concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY)),
		(2, CAST(
			concat("2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
			"2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY))
	;
	DELETE FROM t WHERE i = 2;
COMMIT;
SELECT i, CAST(b AS CHAR) FROM t;
|"i", "CAST(b AS CHAR)"
[0 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]
[1 1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!]

-- 273
BEGIN;
	CREATE TABLE t (c bool);
	INSERT INTO t VALUES (false), (true);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[0]
[1]

-- 274
BEGIN;
	CREATE TABLE t (c bool, i int);
	INSERT INTO t VALUES (false, 1), (true, 2), (false, 10), (true, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[0 11]
[1 22]

-- 275
BEGIN;
	CREATE TABLE t (c TINYINT);
	INSERT INTO t VALUES (1), (2);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[1]
[2]

-- 276
BEGIN;
	CREATE TABLE t (c TINYINT, i int);
	INSERT INTO t VALUES (99, 1), (100, 2), (99, 10), (100, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[99 11]
[100 22]

-- 277
BEGIN;
	CREATE TABLE t (c blob);
	INSERT INTO t VALUES (CAST("A" AS BINARY)), (CAST("B" AS BINARY));
COMMIT;
SELECT * FROM t ORDER BY c;
||cannot .* \[\]uint8

-- 278
BEGIN;
	CREATE TABLE t (c blob, i int);
	INSERT INTO t VALUES (CAST("A" AS BINARY), 1), (CAST("B" AS BINARY), 2);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[[65] 1]
[[66] 2]

-- 279
BEGIN;
	CREATE TABLE t (c blob, i int);
	INSERT INTO t VALUES (CAST("A" AS BINARY), 10), (CAST("B" AS BINARY), 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[[65] 10]
[[66] 20]

-- 280
BEGIN;
	CREATE TABLE t (c blob, i int);
	INSERT INTO t VALUES (CAST("A" AS BINARY), 1), (CAST("B" AS BINARY), 2), (CAST("A" AS BINARY), 10), (CAST("B" AS BINARY), 20);
COMMIT;
SELECT * FROM t;
|"c", "i"
[[65] 1]
[[66] 2]
[[65] 10]
[[66] 20]

-- 281
BEGIN;
	CREATE TABLE t (c TEXT, i int);
	INSERT INTO t VALUES ("A", 1), ("B", 2), ("A", 10), ("B", 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[A 11]
[B 22]

-- 282
BEGIN;
	CREATE TABLE t (c blob, i int);
	INSERT INTO t VALUES (CAST("A" AS BINARY), 1), (CAST("B" AS BINARY), 2), (CAST("A" AS BINARY), 10), (CAST("B" AS BINARY), 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[[65] 11]
[[66] 22]

-- 283
BEGIN;
	CREATE TABLE t (c TINYINT UNSIGNED);
	INSERT INTO t VALUES (42), (314);
COMMIT;
SELECT * FROM t ORDER BY c;
||overflow

-- 284
BEGIN;
	CREATE TABLE t (c TINYINT UNSIGNED);
	INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 285
BEGIN;
	CREATE TABLE t (c TINYINT UNSIGNED, i int);
	INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 286
BEGIN;
	CREATE TABLE t (c TINYINT UNSIGNED);
	INSERT INTO t VALUES (42), (3.14);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[3]
[42]

-- 287
BEGIN;
	CREATE TABLE t (c float);
	INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 288
BEGIN;
	CREATE TABLE t (c float, i int);
	INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 289
BEGIN;
    CREATE TABLE t (c double, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 290
BEGIN;
    CREATE TABLE t (c float);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 291
BEGIN;
    CREATE TABLE t (c float, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 292
BEGIN;
    CREATE TABLE t (c int);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 293
BEGIN;
    CREATE TABLE t (c int, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 294
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 295
BEGIN;
    CREATE TABLE t (c bigint, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 296
BEGIN;
    CREATE TABLE t (c TINYINT);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 297
BEGIN;
    CREATE TABLE t (c TINYINT, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 298
BEGIN;
    CREATE TABLE t (c SMALLINT);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 299
BEGIN;
    CREATE TABLE t (c SMALLINT, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 300
BEGIN;
    CREATE TABLE t (c int);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 301
BEGIN;
    CREATE TABLE t (c int, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 302
BEGIN;
    CREATE TABLE t (c bigint unsigned);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 303
BEGIN;
    CREATE TABLE t (c bigint unsigned, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 304
BEGIN;
    CREATE TABLE t (c bigint unsigned);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 305
BEGIN;
    CREATE TABLE t (c bigint unsigned, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 306
BEGIN;
    CREATE TABLE t (c TINYINT UNSIGNED);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 307
BEGIN;
    CREATE TABLE t (c TINYINT UNSIGNED, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 308
BEGIN;
    CREATE TABLE t (c SMALLINT UNSIGNED);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 309
BEGIN;
    CREATE TABLE t (c SMALLINT UNSIGNED, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 310
BEGIN;
    CREATE TABLE t (c INT UNSIGNED);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 311
BEGIN;
    CREATE TABLE t (c INT UNSIGNED, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 312
BEGIN;
    CREATE TABLE t (c blob, i int);
    INSERT INTO t VALUES (CAST("A" AS BINARY), 1), (CAST("B" AS BINARY), 2);
    UPDATE t SET c = CAST("C" AS BINARY) WHERE i = 2;
COMMIT;
SELECT * FROM t;
|"c", "i"
[[65] 1]
[[67] 2]

-- 313
BEGIN;
    CREATE TABLE t (c blob, i int);
    INSERT INTO t VALUES
        (CAST(
            concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY
        ), 1),
        (CAST(
            concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY
        ), 2);
    UPDATE t SET c = CAST(
            concat("2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "2123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "2123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY
    ) WHERE i = 2;
COMMIT;
SELECT * FROM t order by i desc;
|"c", "i"
[[50 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 50 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 50 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 50 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70 33] 2]
[[48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70 33] 1]

-- 314
BEGIN;
    CREATE TABLE t (c blob, i int);
    INSERT INTO t VALUES
        (CAST(
            concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY
        ), 1),
        (CAST(
            concat("1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
            "1123456789abcdef0123456789abcdef0123456789abcdef0123456789ABCDEF!") AS BINARY
        ), 2);
    UPDATE t SET i = 42 WHERE i = 2;
COMMIT;
SELECT * FROM t order by i desc;
|"c", "i"
[[49 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 49 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 49 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 49 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70 33] 42]
[[48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 97 98 99 100 101 102 48 49 50 51 52 53 54 55 56 57 65 66 67 68 69 70 33] 1]

-- 315
BEGIN;
    CREATE TABLE t (i bigint);
    INSERT INTO t VALUES (1);
COMMIT;
SELECT * FROM t;
|"i"
[1]

-- 316
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (42), (114);
COMMIT;
SELECT * FROM t ORDER BY c;
|"c"
[42]
[114]

-- 317
BEGIN;
    CREATE TABLE t (c bigint, i int);
    INSERT INTO t VALUES (100, 1), (101, 2), (100, 10), (101, 20);
COMMIT;
SELECT c, sum(i) FROM t GROUP BY c;
|"c", "sum(i)"
[100 11]
[101 22]

-- 318
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c > 100 ORDER BY c DESC;
|"c"
[111]
[110]
[101]

-- 319
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c < 110 ORDER BY c;
|"c"
[100]
[101]

-- 320
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c <= 110 ORDER BY c;
|"c"
[100]
[101]
[110]

-- 321
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c >= 110 ORDER BY c;
|"c"
[110]
[111]

-- 322
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c != 110 ORDER BY c;
|"c"
[100]
[101]
[111]

-- 323
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT * FROM t WHERE c = 110 ORDER BY c;
|"c"
[110]

-- 324
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT (c+1000) as s FROM t ORDER BY s;
|"s"
[1100]
[1101]
[1110]
[1111]

-- 325
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT (1000-c) as s FROM t ORDER BY s;
|"s"
[889]
[890]
[899]
[900]

-- 326
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT (c>>1) as s FROM t ORDER BY s;
|"s"
[50]
[50]
[55]
[55]

-- 327
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (100), (101), (110), (111);
COMMIT;
SELECT (c<<1) as s FROM t ORDER BY s;
|"s"
[200]
[202]
[220]
[222]

-- 328
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE c&0x55555 = 0x11550;
|"c"
[79856]

-- 329
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE c&or;0x55555 = 0x577f5;
|"c"
[79856]

-- 331
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE c^0x55555 = 0x462a5;
|"c"
[79856]

-- 332
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE c%256 = 0xf0;
|"c"
[79856]

-- 333
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE c*16 = 0x137f00;
|"c"
[79856]

-- 334
BEGIN;
    CREATE TABLE t (c bigint);
    INSERT INTO t VALUES (0x137f0);
COMMIT;
SELECT * FROM t WHERE +c = 0x137f0;
|"c"
[79856]

-- 348
BEGIN;
    DROP TABLE nonexistent;
COMMIT;
||does not exist

-- 349
BEGIN;
    CREATE TABLE t (i int);
    CREATE TABLE t (i int);
COMMIT;
||exist

-- 350
BEGIN;
    CREATE TABLE t (i int);
    CREATE TABLE IF NOT EXISTS t (s TEXT);
COMMIT;
SELECT * FROM t;
|"i"

-- 351
BEGIN;
    CREATE TABLE t (c int);
    CREATE INDEX y ON t (c);
COMMIT;
SELECT * FROM t;
|"c"

-- 354
BEGIN;
    CREATE TABLE t (i int);
    CREATE TABLE u (s TEXT);
    CREATE INDEX u ON t (i);
COMMIT;
||collision.*: u

-- 355
BEGIN;
    CREATE TABLE t (i int);
    CREATE TABLE u (s TEXT);
    CREATE INDEX z ON t (i);
    CREATE INDEX z ON u (s);
COMMIT;
||already

-- 356
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX u ON u (s);
COMMIT;
||.*

-- 357
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX v ON u (v);
COMMIT;
||.*

-- 358
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX s ON t (i);
COMMIT;
||.*

-- 359
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX id ON t (i);
COMMIT;
SELECT * FROM t;
|"i"

-- 360
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    CREATE TABLE x (s TEXT);
COMMIT;
||table t.*index x

-- 361
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    DELETE FROM t;
COMMIT;
SELECT * FROM t;
|"i"

-- 362
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    DELETE FROM t;
COMMIT;
SELECT * FROM t;
|"i"

-- 363
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    INSERT INTO t SELECT 10*i FROM t;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[42]
[420]

-- 364
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    INSERT INTO t SELECT 10*i FROM t;
    DROP INDEX none ON t;
COMMIT;
||index none does not exist

-- 365
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    INSERT INTO t SELECT 10*i FROM t;
    DROP INDEX x ON t;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[42]
[420]

-- 366
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (42);
    INSERT INTO t SELECT 10*i FROM t;
COMMIT;
BEGIN;
    DROP INDEX x ON t;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[42]
[420]

-- 367
BEGIN;
    CREATE TABLE t (b blob);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES (CAST(
        concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef") AS BINARY -- > shortBlob
    ));
    DROP TABLE t;
COMMIT;
SELECT * FROM t;
||does not exist

-- 368
BEGIN;
    CREATE TABLE t (b blob);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES (CAST(
        concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef") AS BINARY -- > shortBlob
    ));
    DROP TABLE t;
COMMIT;
BEGIN;
    DROP TABLE t;
COMMIT;
SELECT * FROM t;
||does not exist

-- 369
BEGIN;
    CREATE TABLE t (b blob);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES (CAST(
        concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef") AS BINARY -- > shortBlob
    ));
    DROP INDEX x ON t;
COMMIT;
SELECT length(CAST(b AS CHAR)) AS n FROM t;
|"n"
[320]

-- 370
BEGIN;
    CREATE TABLE t (b blob);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES (CAST(
        concat("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef") AS BINARY -- > shortBlob
    ));
COMMIT;
BEGIN;
    DROP INDEX x ON t;
COMMIT;
SELECT length(CAST(b AS CHAR)) AS n FROM t;
|"n"
[320]

-- 371
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM test.t;
|"i"

-- 372
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42);
COMMIT;
SELECT * FROM t AS u;
|"i"
[42]

-- 373
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42);
COMMIT;
SELECT u.x FROM t AS u;
||unknown field u.x

-- 374
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42);
COMMIT;
SELECT u.i FROM t AS u;
|"i"
[42]

-- 375
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42);
COMMIT;
SELECT i FROM t AS u;
|"i"
[42]

-- 376
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES(24, false);
    INSERT INTO t VALUES(333, NULL);
    INSERT INTO t VALUES(42, true);
    INSERT INTO t VALUES(240, false);
    INSERT INTO t VALUES(420, true);
COMMIT;
SELECT i FROM t WHERE b ORDER BY i;
|"i"
[42]
[420]

-- 377
BEGIN;
    CREATE TABLE t (i INT, s TEXT);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(10, "foo");
COMMIT;
SELECT * FROM t WHERE i < "30";
| "i", "s"
[10 foo]

-- 378
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE i < 30;
|"i"
[10]
[20]
[20]
[10]

-- 379
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE i < 30 order by i;
|"i"
[10]
[10]
[20]
[20]

-- 380
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i <= 30;
|"i"
[10]
[20]
[30]
[30]
[20]
[10]

-- 381
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i <= 30 order by i;
|"i"
[10]
[10]
[20]
[20]
[30]
[30]

-- 382
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE i = 30;
|"i"
[30]
[30]

-- 383
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE i = 30;
|"i"
[30]
[30]

-- 384
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i >= 30;
|"i"
[50]
[40]
[30]
[30]
[40]
[50]

-- 385
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i >= 30 ORDER by i;
|"i"
[30]
[30]
[40]
[40]
[50]
[50]

-- 386
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i > 30;
|"i"
[50]
[40]
[40]
[50]

-- 387
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i > 30 order by i;
|"i"
[40]
[40]
[50]
[50]

-- 388
BEGIN;
    CREATE TABLE t (i int, b bool);
    INSERT INTO t VALUES(24, false);
    INSERT INTO t VALUES(333, NULL);
    INSERT INTO t VALUES(42, true);
    INSERT INTO t VALUES(240, false);
    INSERT INTO t VALUES(420, true);
COMMIT;
SELECT i FROM t WHERE !b ORDER BY i;
|"i"
[24]
[240]

-- 389
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES(24, false);
    INSERT INTO t VALUES(333, NULL);
    INSERT INTO t VALUES(42, true);
    INSERT INTO t VALUES(240, false);
    INSERT INTO t VALUES(420, true);
COMMIT;
SELECT i FROM t WHERE !b ORDER BY i;
|"i"
[24]
[240]

-- 400
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE 30 > i;
|"i"
[10]
[10]
[20]
[20]

-- 401
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE 30 >= i;
|"i"
[10]
[10]
[20]
[20]
[30]
[30]

-- 402
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT i FROM t WHERE 30 = i;
|"i"
[30]
[30]

-- 403
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE 30 <= i;
|"i"
[30]
[30]
[40]
[40]
[50]
[50]

-- 404
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE 30 < i;
|"i"
[40]
[40]
[50]
[50]

-- 405
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i < 30 order by i desc;
|"i"
[20]
[10]

-- 406
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(20);
    INSERT INTO t VALUES(30);
    INSERT INTO t VALUES(40);
    INSERT INTO t VALUES(50);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i < 30 order by i;
|"i"
[10]
[20]

-- 407
BEGIN;
    CREATE TABLE t (i int);
    CREATE UNIQUE INDEX x ON t (i);
    INSERT INTO t VALUES(NULL);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(10);
    INSERT INTO t VALUES(NULL);
COMMIT;
SELECT * FROM t WHERE i < 30;
||Error: Condition not match

-- 409
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    INSERT INTO t VALUES (1, "test");
COMMIT;
SELECT * FROM t WHERE s = "test";
|"i", "s"
[1 test]

-- 410
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    INSERT INTO t VALUES (1, "test");
    CREATE INDEX idx_s ON t (s);
COMMIT;
SELECT * FROM t WHERE s = "test";
|"i", "s"
[1 test]

-- 411
BEGIN;
    CREATE TABLE t (i int, j int, k int);
    INSERT INTO t VALUES
        (1, 2, 3),
        (4, 5, 6);
    CREATE TABLE u (x int, y int, z int);
    INSERT INTO u VALUES
        (10, 20, 30),
        (40, 50, 60);
COMMIT;
SELECT * FROM t, u WHERE u.y < 60 && t.k < 7 order by t.i desc, t.j desc, t.k desc, u.x desc;
|"i", "j", "k", "x", "y", "z"
[4 5 6 40 50 60]
[4 5 6 10 20 30]
[1 2 3 40 50 60]
[1 2 3 10 20 30]

-- 412
BEGIN;
    CREATE TABLE t (i int, j int, k int);
    CREATE INDEX xk ON t (k);
    INSERT INTO t VALUES
        (1, 2, 3),
        (4, 5, 6);
    CREATE TABLE u (x int, y int, z int);
    INSERT INTO u VALUES
        (10, 20, 30),
        (40, 50, 60);
COMMIT;
SELECT * FROM t, u WHERE u.y < 60 && t.k < 7;
|"i", "j", "k", "x", "y", "z"
[1 2 3 10 20 30]
[1 2 3 40 50 60]
[4 5 6 10 20 30]
[4 5 6 40 50 60]

-- 413
BEGIN;
    CREATE TABLE t (i int, j int, k int);
    INSERT INTO t VALUES
        (1, 2, 3),
        (4, 5, 6);
    CREATE TABLE u (x int, y int, z int);
    CREATE INDEX xy ON u (y);
    INSERT INTO u VALUES
        (10, 20, 30),
        (40, 50, 60);
COMMIT;
SELECT * FROM t, u WHERE u.y < 60 && t.k < 7;
|"i", "j", "k", "x", "y", "z"
[1 2 3 10 20 30]
[1 2 3 40 50 60]
[4 5 6 10 20 30]
[4 5 6 40 50 60]

-- 414
BEGIN;
    CREATE TABLE t (i int, j int, k int);
    CREATE INDEX xk ON t (k);
    INSERT INTO t VALUES
        (1, 2, 3),
        (4, 5, 6);
    CREATE TABLE u (x int, y int, z int);
    CREATE INDEX xy ON u (y);
    INSERT INTO u VALUES
        (10, 20, 30),
        (40, 50, 60);
COMMIT;
SELECT * FROM t, u WHERE u.y < 60 && t.k < 7;
|"i", "j", "k", "x", "y", "z"
[1 2 3 10 20 30]
[1 2 3 40 50 60]
[4 5 6 10 20 30]
[4 5 6 40 50 60]

-- 415
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 1; -- no rows -> not evaluated
|"i"

-- 416
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 0; -- no rows -> not evaluated
|"i"

-- 417
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 1; -- no rows -> not evaluated
|"i"

-- 418
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET -1;
||"-"

-- 419
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 0;
|"i"
[42]
[24]

-- 420
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 1;
|"i"
[24]

-- 421
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 10 OFFSET 2;
|"i"

-- 422
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 0; -- no rows -> not evaluated
|"i"

-- 423
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 0; -- no rows -> not evaluated
|"i"

-- 424
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
SELECT * FROM t LIMIT 1; -- no rows -> not evaluated
|"i"

-- 425
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT -1;
||"-"

-- 426
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 0;
|"i"

-- 427
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 1;
|"i"
[42]

-- 428
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 2;
|"i"
[42]
[24]

-- 429
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 3;
|"i"
[42]
[24]

-- 430
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 0 OFFSET 0;
|"i"

-- 431
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 0 OFFSET 1;
|"i"

-- 432
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 0 OFFSET 2;
|"i"

-- 433
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 0 OFFSET 3;
|"i"

-- 434
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 1 OFFSET 0;
|"i"
[42]

-- 435
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 1 OFFSET 1;
|"i"
[24]

-- 436
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 1 OFFSET 2;
|"i"

-- 437
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 1 OFFSET 3;
|"i"

-- 438
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 2 OFFSET 0;
|"i"
[42]
[24]

-- 439
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 2 OFFSET 1;
|"i"
[24]

-- 440
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 2 OFFSET 2;
|"i"

-- 441
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 2 OFFSET 3;
|"i"

-- 442
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 3 OFFSET 0;
|"i"
[42]
[24]

-- 443
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 3 OFFSET 1;
|"i"
[24]

-- 444
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 3 OFFSET 2;
|"i"

-- 445
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(42), (24);
COMMIT;
SELECT * FROM t LIMIT 3 OFFSET 3;
|"i"

-- 446
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    CREATE TABLE u (i int);
    INSERT INTO u VALUES(10), (20), (30);
COMMIT;
SELECT * FROM
    (SELECT * FROM t ORDER BY i LIMIT 2 OFFSET 1) AS a,
    (SELECT * FROM u ORDER BY i) AS b
ORDER BY a.i, b.i;
|"i", "i"
[2 10]
[2 20]
[2 30]
[3 10]
[3 20]
[3 30]

-- 447
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    CREATE TABLE u (i int);
    INSERT INTO u VALUES(10), (20), (30);
COMMIT;
SELECT * FROM
    (SELECT * FROM t ORDER BY i LIMIT 2 OFFSET 1) AS a,
    (SELECT * FROM u ORDER BY i LIMIT 3 OFFSET 1) AS b
ORDER BY a.i, b.i;
|"i", "i"
[2 20]
[2 30]
[3 20]
[3 30]

-- 448
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    CREATE TABLE u (i int);
    INSERT INTO u VALUES(10), (20), (30);
COMMIT;
SELECT * FROM
    (SELECT * FROM t ORDER BY i LIMIT 2 OFFSET 1) AS a,
    (SELECT * FROM u ORDER BY i LIMIT 1) AS b
ORDER BY a.i, b.i;
|"i", "i"
[2 10]
[3 10]

-- 449
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    CREATE TABLE u (i int);
    INSERT INTO u VALUES(10), (20), (30);
COMMIT;
SELECT * FROM
    (SELECT * FROM t ORDER BY i LIMIT 2 OFFSET 1) AS a,
    (SELECT * FROM u ORDER BY i LIMIT 1 OFFSET 1) AS b
ORDER BY a.i, b.i;
|"i", "i"
[2 20]
[3 20]

-- 450
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    CREATE TABLE u (i int);
    INSERT INTO u VALUES(10), (20), (30);
COMMIT;
SELECT * FROM
    (SELECT * FROM t ORDER BY i LIMIT 2 OFFSET 1) AS a,
    (SELECT * FROM u ORDER BY i LIMIT 1 OFFSET 1) AS b
ORDER BY a.i, b.i
LIMIT 1;
|"i", "i"
[2 20]

-- 451
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
COMMIT;

SELECT count(1) AS total FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
|"total"
[4]

-- 452
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
COMMIT;

SELECT * FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3 ORDER BY input DESC LIMIT 2 OFFSET 1;
|"input", "output"
[6 8]
[5 5]

-- 453
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
  ## Let's delete 4 rows.
  ## Delete where input = 5, input = 6, input = 7 or input = 3
  DELETE FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
COMMIT;
SELECT * FROM fibonacci ORDER BY input;
|"input", "output"
[0 0]
[1 1]
[2 1]
[4 3]
[8 21]
[9 34]

-- 454
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
COMMIT;
## ' Let's delete 4 rows.
BEGIN;
  ## Delete where input = 5, input = 6, input = 7 or input = 3
  DELETE FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
COMMIT;
SELECT * FROM fibonacci ORDER BY input;
|"input", "output"
[0 0]
[1 1]
[2 1]
[4 3]
[8 21]
[9 34]

-- 455
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
  ## Let's delete 4 rows.
  ## Delete where input = 5, input = 6, input = 7 or input = 3
  DELETE FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
COMMIT;
## Try to count the rows we've just deleted, using the very same condition. Result is 1, should be 0.
SELECT count(*) AS total FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
|"total"
[0]

-- 456
BEGIN;
  DROP TABLE IF EXISTS fibonacci;
  CREATE TABLE fibonacci(
    input int,
    output int
  );
COMMIT;

BEGIN;
  INSERT INTO fibonacci (input, output) VALUES (0, 0);
  INSERT INTO fibonacci (input, output) VALUES (1, 1);
  INSERT INTO fibonacci (input, output) VALUES (2, 1);
  INSERT INTO fibonacci (input, output) VALUES (3, 2);
  INSERT INTO fibonacci (input, output) VALUES (4, 3);
  INSERT INTO fibonacci (input, output) VALUES (5, 5);
  INSERT INTO fibonacci (input, output) VALUES (6, 8);
  INSERT INTO fibonacci (input, output) VALUES (7, 13);
  INSERT INTO fibonacci (input, output) VALUES (8, 21);
  INSERT INTO fibonacci (input, output) VALUES (9, 34);
COMMIT;
BEGIN;
  ## Let's delete 4 rows.
  ## Delete where input = 5, input = 6, input = 7 or input = 3
  DELETE FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
COMMIT;
## Try to count the rows we've just deleted, using the very same condition. Result is 1, should be 0.
SELECT count(*) AS total FROM fibonacci WHERE input >= 5 && input <= 7 OR input = 3;
|"total"
[0]

-- 457
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1);
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"

-- 458
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2);
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]

-- 459
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2);
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]

-- 460
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[3]

-- 461
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[3]

-- 462
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3);
    DELETE FROM t WHERE i = 3;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[2]

-- 463
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[3]
[4]

-- 464
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[3]
[4]

-- 465
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 3;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[2]
[4]

-- 466
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 4;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[2]
[3]

-- 467
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 1;
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[3]
[4]

-- 468
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 2;
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[3]
[4]

-- 469
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 2;
    DELETE FROM t WHERE i = 3;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[4]

-- 470
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 3;
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[4]

-- 471
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 3;
    DELETE FROM t WHERE i = 4;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[2]

-- 472
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 4;
    DELETE FROM t WHERE i = 3;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[2]

-- 473
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 1;
    DELETE FROM t WHERE i = 3;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[4]

-- 474
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 3;
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[4]

-- 475
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 1;
    DELETE FROM t WHERE i = 4;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[3]

-- 476
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 4;
    DELETE FROM t WHERE i = 1;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[2]
[3]

-- 477
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 2;
    DELETE FROM t WHERE i = 4;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[3]

-- 478
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES(1), (2), (3), (4);
    DELETE FROM t WHERE i = 4;
    DELETE FROM t WHERE i = 2;
COMMIT;
SELECT * FROM t ORDER BY i;
|"i"
[1]
[3]

-- 479
SELECT Name, Unique FROM __Index;
||"Unique"

-- 480
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX x ON t (s);
    INSERT INTO t VALUES (1, "bar"), (2, "foo");
COMMIT;
SELECT s FROM t order by s desc;
|"s"
[foo]
[bar]

-- 481
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX x ON t (s);
    CREATE INDEX x ON t (s);
    INSERT INTO t VALUES (1, "bar"), (2, "foo");
COMMIT;
SELECT * FROM x;
||already

-- 482
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX x ON t (s);
    INSERT INTO t VALUES (1, "bar"), (2, "foo");
COMMIT;
SELECT s FROM t WHERE s != "z";
|"s"
[bar]
[foo]

-- 483
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX x ON t (s);
    INSERT INTO t VALUES (1, "bar"), (2, "foo");
COMMIT;
SELECT s FROM t WHERE s < "z"; -- ordered -> index is used
|"s"
[bar]
[foo]

-- 484
BEGIN;
    CREATE TABLE t (i int, s TEXT);
    CREATE INDEX x ON t (s);
    INSERT INTO t VALUES (1, "bar"), (2, "foo");
    DROP INDEX x ON t;
COMMIT;
SELECT s FROM t WHERE s < "z" order by s desc;
|"s"
[foo]
[bar]

-- 485
BEGIN;
    CREATE TABLE t (p TEXT, c blob);
    CREATE UNIQUE INDEX x ON t (p);
    INSERT INTO t VALUES
        ("empty", CAST("" AS BINARY))
    ;
COMMIT;
SELECT p, CAST(c AS CHAR) FROM t;
|"p", "CAST(c AS CHAR)"
[empty ]

-- 486
BEGIN;
    CREATE TABLE t (p TEXT, c blob);
    CREATE INDEX x ON t (p);
    INSERT INTO t VALUES
        ("empty", CAST("" AS BINARY))
    ;
COMMIT;
BEGIN;
    DELETE FROM t WHERE p = "empty";
COMMIT;
SELECT p, CAST(c AS CHAR) FROM t;
|"p", "CAST(c AS CHAR)"

-- 487
BEGIN;
    CREATE TABLE t (p TEXT, c blob);
    CREATE UNIQUE INDEX x ON t (p);
    INSERT INTO t VALUES
        ("empty", CAST("" AS BINARY))
    ;
COMMIT;
BEGIN;
    DELETE FROM t WHERE p = "empty";
COMMIT;
SELECT p, CAST(c AS CHAR) FROM t;
|"p", "CAST(c AS CHAR)"

-- S 488
BEGIN;
    UPDATE none SET
        DepartmentID = DepartmentID+1000
    WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee;
||table.*not.*exist

-- S 489
BEGIN;
    UPDATE employee SET
        FirstName = "Williams"
    WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee;
||unknown.*FirstName

-- S 490
BEGIN;
    UPDATE employee SET
        DepartmentID = DepartmentID+1000
    WHERE DepartmentID = 33;
COMMIT;
SELECT * FROM employee
ORDER BY LastName;
|"LastName", "DepartmentID"
[Heisenberg 1033]
[Jones 1033]
[Rafferty 31]
[Robinson 34]
[Smith 34]
[Williams <nil>]

-- 491
BEGIN;
    CREATE TABLE IF NOT EXISTS no_id_user (user TEXT, remain int, total int);
    CREATE UNIQUE INDEX UQE_no_id_user_user ON no_id_user (user);
    DELETE FROM no_id_user WHERE user = "xlw";
    INSERT INTO no_id_user (user, remain, total) VALUES ("xlw", 20, 100);
COMMIT;
SELECT user, remain, total FROM no_id_user WHERE user = "xlw" LIMIT 1;
|"user", "remain", "total"
[xlw 20 100]

-- 492
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
COMMIT;
SELECT * FROM t WHERE i < 4 ; -- ordered -> index is used
|"i"
[1]
[2]
[3]

-- 493
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
COMMIT;
SELECT * FROM t WHERE i <= 4; -- ordered -> index is used
|"i"
[1]
[2]
[3]
[4]

-- 494
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
COMMIT;
SELECT * FROM t WHERE i = 4;
|"i"
[4]

-- 495
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
COMMIT;
SELECT * FROM t WHERE i >= 4; -- ordered -> index is used
|"i"
[4]
[5]
[6]

-- 496
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
COMMIT;
SELECT * FROM t WHERE i > 4;
|"i"
[5]
[6]

-- 497
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t (i);
    CREATE TABLE u (i int);
    CREATE INDEX y ON u (i);
    INSERT INTO t VALUES (1), (2), (3), (4), (5), (6);
    INSERT INTO u VALUES (10), (20), (30), (40), (50), (60);
COMMIT;
SELECT * FROM
    (SELECT i FROM t WHERE i < 4) AS t,
    (SELECT * FROM u WHERE i < 40) AS u; -- ordered -> both indices are used
|"i", "i"
[1 10]
[1 20]
[1 30]
[2 10]
[2 20]
[2 30]
[3 10]
[3 20]
[3 30]


-- 510
BEGIN;
    CREATE TABLE t (name TEXT, mail TEXT);
    INSERT INTO t VALUES
        ("a", "foo@example.com"),
        ("b", "bar@example.com"),
        ("c", "baz@example.com"),
        ("d", "foo@example.com"),
        ("e", "bar@example.com"),
        ("f", "baz@example.com")
    ;
COMMIT;
SELECT *
FROM t
WHERE name = "b" AND mail = "bar@example.com";
|"name", "mail"
[b bar@example.com]

-- 511
BEGIN;
    CREATE TABLE t (name TEXT, mail TEXT);
    INSERT INTO t VALUES
        ("a", "foo@example.com"),
        ("b", "bar@example.com"),
        ("c", "baz@example.com"),
        ("d", "foo@example.com"),
        ("e", "bar@example.com"),
        ("f", "baz@example.com")
    ;
COMMIT;
SELECT *
FROM t
WHERE name = "b" and mail = "bar@example.com";
|"name", "mail"
[b bar@example.com]

-- 512
BEGIN;
    CREATE TABLE t (name TEXT, mail TEXT);
    INSERT INTO t VALUES
        ("a", "foo@example.com"),
        ("b", "bar@example.com"),
        ("c", "baz@example.com"),
        ("d", "foo@example.com"),
        ("e", "bar@example.com"),
        ("f", "baz@example.com")
    ;
COMMIT;
SELECT *
FROM t
WHERE name = "b" OR mail = "bar@example.com"
ORDER BY name;
|"name", "mail"
[b bar@example.com]
[e bar@example.com]

-- 513
BEGIN;
    CREATE TABLE t (name TEXT, mail TEXT);
    INSERT INTO t VALUES
        ("a", "foo@example.com"),
        ("b", "bar@example.com"),
        ("c", "baz@example.com"),
        ("d", "foo@example.com"),
        ("e", "bar@example.com"),
        ("f", "baz@example.com")
    ;
COMMIT;
SELECT *
FROM t
WHERE name = "b" or mail = "bar@example.com"
ORDER BY name;
|"name", "mail"
[b bar@example.com]
[e bar@example.com]

-- 514
BEGIN;
    CREATE TABLE testA (
        comment TEXT,
        data blob
    );
INSERT INTO testA (comment) VALUES ("c1");
UPDATE testA SET data = CAST("newVal" AS BINARY);
COMMIT;
SELECT * FROM testA;
|"comment", "data"
[c1 [110 101 119 86 97 108]]

-- 516
BEGIN;
    CREATE TABLE testA (
        comment TEXT,
        data blob
    );
INSERT INTO testA (comment) VALUES ("c1"), ("c2");
UPDATE testA SET data = CAST("newVal" AS BINARY) WHERE comment = "c1";
COMMIT;
SELECT * FROM testA ORDER BY comment;
|"comment", "data"
[c1 [110 101 119 86 97 108]]
[c2 <nil>]

-- 517
BEGIN;
    CREATE TABLE testA (
        comment TEXT,
        data blob
    );
INSERT INTO testA (comment) VALUES ("c1"), ("c2");
UPDATE testA SET data = CAST("newVal" AS BINARY) WHERE comment = "c2";
COMMIT;
SELECT * FROM testA ORDER BY comment;
|"comment", "data"
[c1 <nil>]
[c2 [110 101 119 86 97 108]]

-- 518
BEGIN;
    CREATE TABLE testA (
        comment TEXT,
        data blob
    );
INSERT INTO testA (comment) VALUES ("c1"), ("c2");
UPDATE testA SET data = CAST("newVal" AS BINARY);
COMMIT;
SELECT * FROM testA ORDER BY comment;
|"comment", "data"
[c1 [110 101 119 86 97 108]]
[c2 [110 101 119 86 97 108]]

-- 539
BEGIN;
    CREATE TABLE t (a int, b int, c int);
    INSERT INTO t VALUES(NULL, NULL, NULL);
COMMIT;
SELECT * FROM t;
|"a", "b", "c"
[<nil> <nil> <nil>]

-- 540
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL, c int);
    INSERT INTO t VALUES(NULL, 42, NULL);
COMMIT;
SELECT * FROM t;
|"a", "b", "c"
[<nil> 42 <nil>]

-- 541
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL, c int);
    INSERT INTO t VALUES(NULL, NULL, NULL);
COMMIT;
SELECT * FROM t;
||Column b can't be null.

-- 542
BEGIN;
    CREATE TABLE t (a int, b int DEFAULT 42, c int);
    INSERT INTO t VALUES(NULL, NULL, NULL);
COMMIT;
SELECT * FROM t;
|"a", "b", "c"
[<nil> <nil> <nil>]

-- 543
BEGIN;
    CREATE TABLE t (a int, b int, c int);
    CREATE TABLE s (i int);
    INSERT INTO s VALUES (1), (2), (NULL), (3), (4);
    INSERT INTO t(b) SELECT * FROM s;
COMMIT;
SELECT b FROM t ORDER BY b DESC;
|"b"
[4]
[3]
[2]
[1]
[<nil>]

-- 544
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL, c int);
    CREATE TABLE s (i int);
    INSERT INTO s VALUES (1), (2), (NULL), (3), (4);
    INSERT INTO t(b) SELECT * FROM s WHERE i IS NOT NULL;
COMMIT;
SELECT b FROM t ORDER BY b DESC;
|"b"
[4]
[3]
[2]
[1]

-- 545
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL, c int);
    CREATE TABLE s (i int);
    INSERT INTO s VALUES (1), (2), (NULL), (3), (4);
    INSERT INTO t(b) SELECT * FROM s;
COMMIT;
SELECT i FROM t ORDER BY b DESC;
||Column b can't be null.

-- 546
BEGIN;
    CREATE TABLE t (a int, b int, c int);
    INSERT INTO t(b) VALUES (10), (20), (30);
    UPDATE t SET b = NULL WHERE b = 20;
COMMIT;
SELECT b FROM t ORDER BY b DESC;
|"b"
[30]
[10]
[<nil>]

-- 547
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL, c int);
    INSERT INTO t(b) VALUES (10), (20), (30);
    UPDATE t SET b = NULL WHERE b = 20;
COMMIT;
SELECT b FROM t ORDER BY b DESC;
||Column b can't be null.

-- 548
BEGIN;
    CREATE TABLE t (a int, b int NOT NULL DEFAULT 42, c int);
    INSERT INTO t(b) VALUES (10), (20), (30);
    UPDATE t SET b = 42 WHERE b = 20;
COMMIT;
SELECT b FROM t ORDER BY b DESC;
|"b"
[42]
[30]
[10]

-- S 549
SELECT *
FROM employee
LEFT OUTER JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Williams <nil> <nil> <nil>]

-- S 550
SELECT *
FROM employee
LEFT JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Williams <nil> <nil> <nil>]

-- S 551
SELECT *
FROM employee
RIGHT OUTER JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[<nil> <nil> 35 Marketing]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- S 552
SELECT *
FROM employee
RIGHT JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[<nil> <nil> 35 Marketing]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]

-- S 553
SELECT *
FROM employee
JOIN department
ON employee.DepartmentID = none;
||unknown

-- S 554
SELECT *
FROM employee
JOIN department
ON employee.DepartmentID = none;
||unknown

-- 555
BEGIN;
    CREATE TABLE t1 (s1 int);
    CREATE TABLE t2 (s1 int);
    INSERT INTO t1 VALUES (1);
    INSERT INTO t1 VALUES (1);
COMMIT;
SELECT * FROM t1 LEFT JOIN t2 ON t1.s1 = t2.s1;
|"s1", "s1"
[1 <nil>]
[1 <nil>]

-- 556
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a"), (NULL, "an1"), (NULL, "an2");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b"), (NULL, "bn1"), (NULL, "bn2");
COMMIT;
SELECT * FROM a LEFT JOIN b ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[1 a <nil> <nil>]
[3 a 3 b]
[<nil> an1 <nil> <nil>]
[<nil> an2 <nil> <nil>]

-- 557
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a"), (NULL, "an1"), (NULL, "an2");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b"), (NULL, "bn1"), (NULL, "bn2");
COMMIT;
SELECT * FROM a RIGHT JOIN b ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[<nil> <nil> 2 b]
[<nil> <nil> <nil> bn1]
[<nil> <nil> <nil> bn2]
[3 a 3 b]

-- 558
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a"), (NULL, "an1"), (NULL, "an2");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b"), (NULL, "bn1"), (NULL, "bn2");
COMMIT;
SELECT * FROM b LEFT JOIN a ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[2 b <nil> <nil>]
[<nil> bn1 <nil> <nil>]
[<nil> bn2 <nil> <nil>]
[3 b 3 a]

-- 559
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a"), (NULL, "an1"), (NULL, "an2");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b"), (NULL, "bn1"), (NULL, "bn2");
COMMIT;
SELECT * FROM b RIGHT JOIN a ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[<nil> <nil> 1 a]
[3 b 3 a]
[<nil> <nil> <nil> an1]
[<nil> <nil> <nil> an2]

-- 560
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b");
COMMIT;
SELECT * FROM a JOIN b ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[<nil> <nil> 2 b]
[1 a <nil> <nil>]
[3 a 3 b]

-- 561
BEGIN;
    CREATE TABLE a (i int, s TEXT);
    INSERT INTO a VALUES (1, "a"), (3, "a");
    CREATE TABLE b (i int, s TEXT);
    INSERT INTO b VALUES (2, "b"), (3, "b");
COMMIT;
SELECT * FROM a JOIN b ON a.i = b.i
ORDER BY a.s, a.i, b.s, b.i;
|"i", "s", "i", "s"
[<nil> <nil> 2 b]
[1 a <nil> <nil>]
[3 a 3 b]

-- S 562
SELECT *
FROM employee
JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[<nil> <nil> 35 Marketing]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Williams <nil> <nil> <nil>]

-- S 563
SELECT *
FROM employee
JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY employee.LastName;
|"LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[<nil> <nil> 35 Marketing]
[Heisenberg 33 33 Engineering]
[Jones 33 33 Engineering]
[Rafferty 31 31 Sales]
[Robinson 34 34 Clerical]
[Smith 34 34 Clerical]
[Williams <nil> <nil> <nil>]

-- S 564
BEGIN;
    CREATE TABLE t (s TEXT);
    INSERT INTO t VALUES ("A"), ("B");
COMMIT;
SELECT *
FROM t, employee
LEFT JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY t.s, employee.LastName;
|"s", "LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[A Heisenberg 33 33 Engineering]
[A Jones 33 33 Engineering]
[A Rafferty 31 31 Sales]
[A Robinson 34 34 Clerical]
[A Smith 34 34 Clerical]
[A Williams <nil> <nil> <nil>]
[B Heisenberg 33 33 Engineering]
[B Jones 33 33 Engineering]
[B Rafferty 31 31 Sales]
[B Robinson 34 34 Clerical]
[B Smith 34 34 Clerical]
[B Williams <nil> <nil> <nil>]

-- S 565
BEGIN;
    CREATE TABLE t (s TEXT);
    INSERT INTO t VALUES ("A"), ("B");
COMMIT;
SELECT *
FROM t, employee
RIGHT JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY t.s, employee.LastName;
|"s", "LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[A <nil> <nil> 35 Marketing]
[A Heisenberg 33 33 Engineering]
[A Jones 33 33 Engineering]
[A Rafferty 31 31 Sales]
[A Robinson 34 34 Clerical]
[A Smith 34 34 Clerical]
[B <nil> <nil> 35 Marketing]
[B Heisenberg 33 33 Engineering]
[B Jones 33 33 Engineering]
[B Rafferty 31 31 Sales]
[B Robinson 34 34 Clerical]
[B Smith 34 34 Clerical]

-- S 566
BEGIN;
    CREATE TABLE t (s TEXT);
    INSERT INTO t VALUES ("A"), ("B");
COMMIT;
SELECT *
FROM t, employee
JOIN department
ON employee.DepartmentID = department.DepartmentID
ORDER BY t.s, employee.LastName;
|"s", "LastName", "DepartmentID", "DepartmentID", "DepartmentName"
[A <nil> <nil> 35 Marketing]
[A Heisenberg 33 33 Engineering]
[A Jones 33 33 Engineering]
[A Rafferty 31 31 Sales]
[A Robinson 34 34 Clerical]
[A Smith 34 34 Clerical]
[A Williams <nil> <nil> <nil>]
[B <nil> <nil> 35 Marketing]
[B Heisenberg 33 33 Engineering]
[B Jones 33 33 Engineering]
[B Rafferty 31 31 Sales]
[B Robinson 34 34 Clerical]
[B Smith 34 34 Clerical]
[B Williams <nil> <nil> <nil>]

-- 567
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
EXPLAIN SELECT * FROM t;
|""
[┌Iterate all rows of table "t"]
[└Output field names ["i"]]
[┌Evaluate t.i as "t.i",]
[└Output field names ["i"]]

-- 568
BEGIN;
    CREATE TABLE t (i int);
COMMIT;
EXPLAIN SELECT * FROM t;
|""
[┌Iterate all rows of table "t"]
[└Output field names ["i"]]
[┌Evaluate t.i as "t.i",]
[└Output field names ["i"]]

-- 569
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES (314), (0), (NULL), (42), (-1), (278);
COMMIT;
SELECT * FROM t WHERE i != 42;
|"i"
[314]
[0]
[-1]
[278]

-- 570
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (314), (0), (NULL), (42), (-1), (278);
COMMIT;
SELECT * FROM t WHERE i != 42;
|"i"
[-1]
[0]
[278]
[314]

-- 571
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (314), (0), (NULL), (-1), (278);
COMMIT;
SELECT * FROM t WHERE i != 42;
|"i"
[-1]
[0]
[278]
[314]

-- 572
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES (314), (0), (NULL), (-1), (278);
COMMIT;
SELECT * FROM t;
|"i"
[314]
[0]
[<nil>]
[-1]
[278]

-- 573
BEGIN;
    CREATE TABLE t (i int, j int);
    INSERT INTO t VALUES (314, 100), (0, 200), (NULL, 300), (-1, 400), (278, 500);
COMMIT;
SELECT * FROM t WHERE i IS NULL;
|"i", "j"
[<nil> 300]

-- 574
BEGIN;
    CREATE TABLE t (i int, j int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (314, 100), (0, 200), (NULL, 300), (-1, 400), (278, 500);
COMMIT;
SELECT * FROM t WHERE i IS NULL;
|"i", "j"
[<nil> 300]

-- 575
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES (314), (0), (NULL), (-1), (278);
COMMIT;
SELECT * FROM t WHERE i IS NOT NULL;
|"i"
[314]
[0]
[-1]
[278]

-- 576
BEGIN;
    CREATE TABLE t (i int);
    INSERT INTO t VALUES (314), (0), (NULL), (-1), (278);
    CREATE INDEX x ON t(i);
COMMIT;
SELECT * FROM t WHERE i IS NOT NULL;
|"i"
[-1]
[0]
[278]
[314]


-- 577
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (314), (0), (NULL), (-1), (278);
COMMIT;
SELECT * FROM t WHERE -1 < i && 314 > i OR i > 1000 && i < 2000; -- MAYBE use ORed intervals
|"i"
[0]
[278]

-- 578
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t (b);
    INSERT INTO t VALUES(24, false);
    INSERT INTO t VALUES(333, NULL);
    INSERT INTO t VALUES(42, true);
    INSERT INTO t VALUES(240, false);
    INSERT INTO t VALUES(420, true);
COMMIT;
SELECT i FROM t WHERE !b ORDER BY i;
|"i"
[24]
[240]

-- 579
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i = -2;
|"i"

-- 580
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i = -1;
|"i"

-- 581
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i = 0;
|"i"
[0]

-- 582
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i = 1;
|"i"

-- 583
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i = 2;
|"i"

-- 584
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i >= -2;
|"i"
[0]

-- 585
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i >= -1;
|"i"
[0]

-- 586
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i >= 0;
|"i"
[0]

-- 587
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i >= 1;
|"i"

-- 588
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i >= 2;
|"i"

-- 589
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i > -2;
|"i"
[0]

-- 590
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i > -1;
|"i"
[0]

-- 591
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i > 0;
|"i"

-- 592
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i > 1;
|"i"

-- 593
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i > 2;
|"i"

-- 594
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i <= -2;
|"i"

-- 595
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i <= -1;
|"i"

-- 596
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i <= 0;
|"i"
[0]

-- 597
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i <= 1;
|"i"
[0]

-- 598
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i <= 2;
|"i"
[0]

-- 599
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i < -2;
|"i"

-- 600
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i < -1;
|"i"

-- 601
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i < 0;
|"i"

-- 602
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i < 1;
|"i"
[0]

-- 603
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i < 2;
|"i"
[0]

-- 604
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i != -2;
|"i"
[0]

-- 605
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i != -1;
|"i"
[0]

-- 606
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i != 0;
|"i"

-- 607
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i != 1;
|"i"
[0]

-- 608
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i = 0 && i != 2;
|"i"
[0]

-- 609
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t(b);
    INSERT INTO t VALUES (1, false), (NULL, NULL), (-2, false), (0, true), (2, false), (-1, true);
COMMIT;
SELECT * FROM t WHERE !b && b ORDER BY i;
|"i", "b"

-- 610
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t(b);
    INSERT INTO t VALUES (1, false), (NULL, NULL), (-2, false), (0, true), (2, false), (-1, true);
COMMIT;
SELECT * FROM t WHERE !b && !b ORDER BY i;
|"i", "b"
[-2 0]
[1 0]
[2 0]

-- 611
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t(b);
    INSERT INTO t VALUES (1, false), (NULL, NULL), (-2, false), (0, true), (2, false), (-1, true);
COMMIT;
SELECT * FROM t WHERE b && !b ORDER BY i;
|"i", "b"

-- 612
BEGIN;
    CREATE TABLE t (i int, b bool);
    CREATE INDEX x ON t(b);
    INSERT INTO t VALUES (1, false), (NULL, NULL), (-2, false), (0, true), (2, false), (-1, true);
COMMIT;
SELECT * FROM t WHERE b && b ORDER BY i;
|"i", "b"
[-1 1]
[0 1]

-- 613
SELECT * FROM nothing; -- align 5
||.

-- 614
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i = -2;
|"i"

-- 615
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i = -1;
|"i"

-- 616
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i = 0;
|"i"
[0]

-- 617
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i = 1;
|"i"
[1]

-- 618
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i = 2;
|"i"
[2]

-- 619
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i >= -2;
|"i"
[0]
[1]
[2]

-- 620
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i >= -1;
|"i"
[0]
[1]
[2]

-- 621
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i >= 0;
|"i"
[0]
[1]
[2]

-- 622
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i >= 1;
|"i"
[1]
[2]

-- 623
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i >= 2;
|"i"
[2]

-- 624
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i > -2;
|"i"
[0]
[1]
[2]

-- 625
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i > -1;
|"i"
[0]
[1]
[2]

-- 626
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i > 0;
|"i"
[1]
[2]

-- 627
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i > 1;
|"i"
[2]

-- 628
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i > 2;
|"i"

-- 629
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i <= -2;
|"i"

-- 630
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i <= -1;
|"i"

-- 631
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i <= 0;
|"i"
[0]

-- 632
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i <= 1;
|"i"
[0]
[1]

-- 633
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i <= 2;
|"i"
[0]
[1]
[2]

-- 634
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i < -2;
|"i"

-- 635
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i < -1;
|"i"

-- 636
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i < 0;
|"i"

-- 637
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i < 1;
|"i"
[0]

-- 638
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i < 2;
|"i"
[0]
[1]

-- 639
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i != -2;
|"i"
[0]
[1]
[2]

-- 640
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i != -1;
|"i"
[0]
[1]
[2]

-- 641
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i != 0;
|"i"
[1]
[2]

-- 642
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i != 1;
|"i"
[0]
[2]

-- 643
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i >= 0 && i != 2;
|"i"
[0]
[1]

-- 644
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i = -2;
|"i"

-- 645
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i = -1;
|"i"

-- 646
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i = 0;
|"i"

-- 647
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i = 1;
|"i"
[1]

-- 648
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i = 2;
|"i"
[2]

-- 649
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i >= -2;
|"i"
[1]
[2]

-- 650
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i >= -1;
|"i"
[1]
[2]

-- 651
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i >= 0;
|"i"
[1]
[2]

-- 652
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i >= 1;
|"i"
[1]
[2]

-- 653
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i >= 2;
|"i"
[2]

-- 654
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i > -2;
|"i"
[1]
[2]

-- 655
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i > -1;
|"i"
[1]
[2]

-- 656
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i > 0;
|"i"
[1]
[2]

-- 657
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i > 1;
|"i"
[2]

-- 658
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i > 2;
|"i"

-- 659
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i <= -2;
|"i"

-- 660
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i <= -1;
|"i"

-- 661
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i <= 0;
|"i"

-- 662
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i <= 1;
|"i"
[1]

-- 663
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i <= 2;
|"i"
[1]
[2]

-- 664
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i < -2;
|"i"

-- 665
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i < -1;
|"i"

-- 666
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i < 0;
|"i"

-- 667
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i < 1;
|"i"

-- 668
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i < 2;
|"i"
[1]

-- 669
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i != -2;
|"i"
[1]
[2]

-- 670
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i != -1;
|"i"
[1]
[2]

-- 671
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i != 0;
|"i"
[1]
[2]

-- 672
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i != 1;
|"i"
[2]

-- 673
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i > 0 && i != 2;
|"i"
[1]

-- 674
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i = -2;
|"i"
[-2]

-- 675
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i = -1;
|"i"
[-1]

-- 676
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i = 0;
|"i"
[0]

-- 677
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i = 1;
|"i"

-- 678
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i = 2;
|"i"

-- 679
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i >= -2;
|"i"
[-2]
[-1]
[0]

-- 680
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i >= -1;
|"i"
[-1]
[0]

-- 681
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i >= 0;
|"i"
[0]

-- 682
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i >= 1;
|"i"

-- 683
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i >= 2;
|"i"

-- 684
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i > -2;
|"i"
[-1]
[0]

-- 685
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i > -1;
|"i"
[0]

-- 686
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i > 0;
|"i"

-- 687
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i > 1;
|"i"

-- 688
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i > 2;
|"i"

-- 689
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i <= -2;
|"i"
[-2]

-- 690
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i <= -1;
|"i"
[-2]
[-1]

-- 691
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i <= 0;
|"i"
[-2]
[-1]
[0]

-- 692
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i <= 1;
|"i"
[-2]
[-1]
[0]

-- 693
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i <= 2;
|"i"
[-2]
[-1]
[0]

-- 694
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i < -2;
|"i"

-- 695
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i < -1;
|"i"
[-2]

-- 696
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i < 0;
|"i"
[-2]
[-1]

-- 697
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i < 1;
|"i"
[-2]
[-1]
[0]

-- 698
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i < 2;
|"i"
[-2]
[-1]
[0]

-- 699
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i != -2;
|"i"
[-1]
[0]

-- 700
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i != -1;
|"i"
[-2]
[0]

-- 701
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i != 0;
|"i"
[-2]
[-1]

-- 702
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i != 1;
|"i"
[-2]
[-1]
[0]

-- 703
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (NULL), (-2), (0), (2), (-1);
COMMIT;
SELECT i FROM t WHERE i <= 0 && i != 2;
|"i"
[-2]
[-1]
[0]

-- 704
BEGIN;
    CREATE TABLE t (i int);
    CREATE INDEX x ON t(i);
    INSERT INTO t VALUES (1), (2), (3), (-1), (100);
COMMIT;
EXPLAIN SELECT i FROM t WHERE i > 0 and i < 10;
|""
[┌Iterate rows of table "t" using index "x" where i in (0,10) ]
[└Output field names ["i"]]

-- 705
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (1), (2), (3), (-1), (100);
COMMIT;
EXPLAIN SELECT i FROM t WHERE i > 0 and i < 10 and i < 100;
|""
[┌Iterate rows of table "t" using index "xi" where i in (0,10) ]
[└Output field names ["i"]]

-- 706
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (1), (2), (3), (-1), (100);
COMMIT;
SELECT i FROM t WHERE i > 0 and i < 10 and i < 100;
|"i"
[1]
[2]
[3]

-- 707
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (1), (2), (3), (-1), (100);
COMMIT;
EXPLAIN SELECT i FROM t WHERE i > 0 and i < 10 and i < 100 and i IS NOT NULL;
|""
[┌Iterate rows of table "t" using index "xi" where i in (0,10) ]
[└Output field names ["i"]]
[┌FilterDefaultPlan Filter on i IS NOT NULL]
[└Output field names ["i"]]

-- 708
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (0),(1), (2), (3), (-1), (100);
COMMIT;
SELECT i FROM t WHERE i >= 0 and i < 10 and i < 100;
|"i"
[0]
[1]
[2]
[3]

-- 708
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (0),(1), (2), (3), (-1), (100);
COMMIT;
EXPLAIN SELECT i FROM t WHERE i >= 0 and i < 10 and i < 100;
|""
[┌Iterate rows of table "t" using index "xi" where i in [0,10) ]
[└Output field names ["i"]]

-- 709
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (0),(1), (2), (10), (-1), (100);
COMMIT;
SELECT i FROM t WHERE i >= 0 and i <= 10 and i < 100;
|"i"
[0]
[1]
[2]
[10]

-- 710
BEGIN;
    CREATE TABLE t (i TEXT) DEFAULT CHARSET Badcharset;
COMMIT;
||Unknown character set: 'Badcharset'

-- 711
BEGIN;
    CREATE TABLE t (i int, INDEX xi(i));
    INSERT INTO t VALUES (0),(1), (2), (10), (-1), (100);
COMMIT;
EXPLAIN SELECT i FROM t WHERE i >= 0 and i <= 10 and i < 100;
|""
[┌Iterate rows of table "t" using index "xi" where i in [0,10] ]
[└Output field names ["i"]]

-- 712
BEGIN;
    CREATE TABLE t (name TEXT);
    INSERT INTO t VALUES ("test"),("test2"), ("test3");
COMMIT;
SELECT * FROM t WHERE length(name) > 0;
|"name"
[test]
[test2]
[test3]

-- 713
BEGIN;
    -- update rows using index 
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
COMMIT;
EXPLAIN UPDATE t SET name = "z" WHERE name > "c";
|""
[┌Iterate rows of table "t" using index "i_name" where name in (c,+inf] ]
[└Output field names ["id" "name"]]
[└Update fields [{name "z"}]]

-- 714
BEGIN;
    -- update rows *not* using index 
    CREATE TABLE t (id INT, name TEXT);
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
COMMIT;
EXPLAIN UPDATE t SET name = "z" WHERE name > "c";
|""
[┌Iterate all rows of table: t]
[└Update fields [{name "z"}]]

-- 715
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    UPDATE t SET name = "z" WHERE name > "c";
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]
[4 z]
[5 z]
[6 z]

-- 716
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
COMMIT;
EXPLAIN DELETE FROM t WHERE name > "c";
|""
[┌Iterate rows of table "t" using index "i_name" where name in (c,+inf] ]
[└Output field names ["id" "name"]]
[└Delete row]

-- 717
BEGIN;
    CREATE TABLE t (id INT, name TEXT);
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t WHERE name > "c";
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]

-- 718
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t WHERE name > "c";
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]

-- 719
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    UPDATE t SET name = "z" WHERE name > "c" LIMIT 2;
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]
[4 z]
[5 z]
[6 f]

-- 720
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t WHERE name > "c" LIMIT 1;
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]
[5 e]
[6 f]

-- 721
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t LIMIT 6;
COMMIT;
SELECT * FROM t;
|"id", "name"

-- 722
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t LIMIT 100;
COMMIT;
SELECT * FROM t;
|"id", "name"

-- 723
BEGIN;
    CREATE TABLE t (id INT, name TEXT, KEY i_id(id), KEY i_name(name));
    INSERT INTO t VALUES (1, "a");
    INSERT INTO t VALUES (2, "b");
    INSERT INTO t VALUES (3, "c");
    INSERT INTO t VALUES (4, "d");
    INSERT INTO t VALUES (5, "e");
    INSERT INTO t VALUES (6, "f");
    DELETE FROM t LIMIT 0;
COMMIT;
SELECT * FROM t;
|"id", "name"
[1 a]
[2 b]
[3 c]
[4 d]
[5 e]
[6 f]

-- 724
BEGIN;
    CREATE TABLE t (id INT);
    INSERT INTO t VALUES (1), (2), (3);
    SET @@autocommit=0;
COMMIT;
EXPLAIN SELECT * FROM t FOR UPDATE;
|""
[┌Iterate all rows of table "t"]
[└Output field names ["id"]]
[┌Lock row keys for update]
[┌Evaluate t.id as "t.id",]
[└Output field names ["id"]]


-- 725
BEGIN;
	REPLACE INTO none VALUES (1, 2);
COMMIT;
||table .* not exist

-- 726
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	REPLACE INTO t VALUES (1);
COMMIT;
||expect

-- 727
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	REPLACE INTO t VALUES (1, 2, 3);
COMMIT;
||expect

-- 728
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	REPLACE INTO t VALUES (1, 2/(3*5-15));
COMMIT;
||integer divide by zero

-- 729
BEGIN;
	CREATE TABLE t (c1 int, c2 int);
	REPLACE	INTO t VALUES (2+3*4, 2*3+4);
COMMIT;
SELECT * FROM t;
|"c1", "c2"
[14 10]

-- 730
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	REPLACE INTO t (c2, c4) VALUES (1);
COMMIT;
||expect

-- 731
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	REPLACE INTO t (c2, c4) VALUES (1, 2, 3);
COMMIT;
||expect

-- 732
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	REPLACE INTO t (c2, none) VALUES (1, 2);
COMMIT;
||unknown

-- 733
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, c4 int);
	REPLACE INTO t (c2, c3) VALUES (2+3*4, 2*3+4);
	REPLACE INTO t VALUES (1, 2, 3, 4);
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3", "c4"
[<nil> 14 10 <nil>]
[1 2 3 4]

-- 734
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, UNIQUE INDEX (c1, c2));
	REPLACE INTO t (c2, c3) VALUES (1, 2);
	REPLACE INTO t SET c2=1, c3=2;
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3"
[1 2 <nil>]

-- 735
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, UNIQUE INDEX (c1, c2));
	REPLACE INTO t (c2, c3) VALUES (1, 2);
	REPLACE INTO t (c2, c3) VALUES (1, 2, 4);
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3"
[1 2 4]

-- 736
BEGIN;
	CREATE TABLE t (c1 int, c2 int, c3 int, PRIMARY KEY (c1, c2));
	REPLACE INTO t (c2, c3) VALUES (1, 2);
	REPLACE INTO t (c2, c3) VALUES (1, 2, 4);
COMMIT;
SELECT * FROM t;
|"c1", "c2", "c3"
[1 2 4]


-- 737
BEGIN;
	CREATE TABLE t(S TEXT);
	REPLACE INTO t SELECT "perfect!" FROM (SELECT count(*) AS cnt FROM t WHERE S = "perfect!") AS a WHERE cnt = 0;
COMMIT;
SELECT count(*) FROM t;
|"count(*)"
[1]

-- 338
BEGIN;
	CREATE TABLE t(i int, b blob);
	REPLACE INTO t VALUES
		(0, CAST("0" AS BINARY))
	;
COMMIT;
SELECT * FROM t;
|"i", "b"
[0 [48]]
