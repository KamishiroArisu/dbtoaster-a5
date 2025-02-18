CREATE STREAM R(A int, B int) 
  FROM FILE '../dbtoaster-experiments-data/simple/tiny/r.dat' LINE DELIMITED
  CSV ();

SELECT R.A AS C, SUM(R.B) AS D
FROM R GROUP BY R.A
UNION
SELECT R.B AS C, SUM(R.A) AS D FROM R GROUP BY R.B