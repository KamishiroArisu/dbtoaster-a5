CREATE STREAM R(A int, B int) 
  FROM FILE '../dbtoaster-experiments-data/simple/tiny/r.dat' LINE DELIMITED
  CSV ();

SELECT A, SUM(B)/A FROM R GROUP BY A;
