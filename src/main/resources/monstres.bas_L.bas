#labels
 REM |====================================================|
 REM |===============||| MONSTRES |||=====================|
 REM |====================================================|
 O1=#A000
 DIM CM(23,5)
 POKEO1,23
 O1=O1+1:POKEO1,5
 FOR I=1TO23
 FOR J=1TO 5
 READ CM(I,J):PRINT CM(I,J);
 O1=O1+1:POKEO1,CM(I,J)
 NEXTJ
 PRINT
 NEXTI
 PRINT"SAUVEGARDE DU TABLEAU"
 REM STORE CM,"T-MONST",S
 SAVEO "TMONST.BIN",A#A000,EO1
 PRINT"CARACS OK":PING:END
 REM  AGI,PV,CC,BF,QI
 DATA 35,20,40, 1,15'Rat mutant
 DATA 30,25,42, 1,20'Chien-loup
 DATA 35,25,44, 2,25'Chacal
 DATA 35,30,40, 2,28'Gobelin
 DATA 38,35,46, 3,30'Coupe-jarret
 DATA 35,30,44, 3,35'Gueux
 DATA 38,35,48, 4,37'Rodeur
 DATA 45,40,55, 4,37'Spadassin
 DATA 25,55,55, 8,18'Ogre
 DATA 48,45,58, 6,32'Dothrakhi
 DATA 27,65,50, 9,20'Geant
 DATA 49,45,60, 5,30'Sauvageon
 DATA 55,50,50, 6,20'Lion
 DATA 40,65,48, 9,18'Grizzly
 DATA 50,40,35, 5,50'Sorcier de Feu
 DATA 54,40,30, 6,52'Sombre Pretresse
 DATA 56,46,36, 6,54'Moine Fou
 DATA 45,50,34, 6,54'Druide-Demon
 DATA 56,55,30, 7,58'Esprit Noir
 DATA 60,58,44, 7,65'Septon Blanc
 DATA 64,60,60, 8,68'Elfe gris
 DATA 64,65,70,12,75'Chevalier maudit
 DATA 80,80,80,15,45'Marcheur blanc
