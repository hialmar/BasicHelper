#labels
 REM |=====================================================|
 REM |=================||| OBJETS |||======================|
 REM |=====================================================|
 DIM ITEM$(48)
 O1=#A000
 POKEO1,48
 FOR I=1 TO 48
 READ ITEM$(I):
 LG=LEN(ITEM$(I))
 O1=O1+1:POKEO1,LG
 IF LG=0 THEN  TItems_0 
 FOR J=1 TO LG
 O1=O1+1:POKEO1,ASC(MID$(ITEM$(I),J,1))
 NEXT
TItems_0
 NEXT
 PRINT"SAUVEGARDE DU TABLEAU"
 REM STORE ITEM$,"T-ITEMS",S
 SAVEO "TITEMS.BIN",A#A000,EO1
 PRINT"OBJETS OK":PING:ZAP:END
 DATA Armure valyrienne,Armure en acier,Armure de fer,Cotte de mailles,Cuirasse,Armure de cuir,Robe de bure:REM 1-7
 DATA Epee valyrienne,Hache de Winterfell,Morgenstern,Fleau d'armes,Marteau,Epee a 2 mains,Epee,Arbalete,Arc court,Fronde,Filet,Poignard:REM 8-19
 DATA Onguent,Bois divin,Potion Ebene,Essence vitale,Potion Divine,Potion Zoman,Potion glaciale:REM 20-26
 DATA Outre,Miche de pain,Cervoise,Poisson sec,Cuisse de sanglier:REM 27-31
 DATA Pot Gregeois, Fut Gregeois, Pied de biche, Boussole, Selle de Dragon:REM 32-36
 DATA DireWolf, Panthere, Molosse, Aigle, Faucon, Dogue, Chat sauvage:REM 37-43
 DATA Couronne, Solitaire, Perles d'Eyrie, Coeur de diamants, Bourse:REM 44-48
