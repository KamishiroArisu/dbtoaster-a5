CREATE STREAM R(A int, B int)
FROM FILE '../dbtoaster-experiments-data/simple/tiny/r.dat' LINE DELIMITED
CSV ();

CREATE STREAM S(C int, D int)
FROM FILE '../dbtoaster-experiments-data/simple/tiny/s.dat' LINE DELIMITED
CSV ();

SELECT R.* FROM R NATURAL JOIN S;
