#labels
 REM DICES TESTS
 CLS:D=10:PAPER0:INK 3:P=1:TRY=1
 INPUT "HERO NAME:";NOM$:NOM$(1)=LEFT$(NO$,10)
 INPUT "CULTURE: (1-7)";CULT(1)
 INPUT "ROLE: (1-6)";ROLE(1)
 INPUT "VITESSE TIRAGE (1-3)";VT
 POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
 DEF FN A(X)=INT(RND(1)*X)+1
 GOSUB  dices_0 
dices_14
 CLS:TT=0
 S$=" "+NOM$(P)+" the "+CULT$(ROLE(P))+" "
 T=INT((40-LEN(S$))/2)
 PRINT @T,1;CHR$(148);S$;CHR$(144)
 S$=" > "+ROLE$(ROLE(P))+" < "
 T=INT((40-LEN(S$))/2)
 PRINT @T,2;CHR$(148);S$;CHR$(144)
 S$=" <  ROLL 2x10 DICES > | TRY:"+CHR$(144)
 PRINT@ 6,4;CHR$(148);S$;TRY
 PRINT@ 5,12;CHR$(148);"Ml - Rg - St - Ag - IQ - MS | HP ";CHR$(144)
 PRINT@ 1,11;"2D:"
 FOR C=1TO7
 GOSUB  dices_1 
 PRINT @12,5;" >                      "
 PRINT @12,5;" > ";CA$(C)
dices_2
 GETA$:IFA$<>" " THEN  dices_2 
 PING:PRINT @13,20;"                "
 IF C<7 THEN GOSUB  dices_3 :PRINT@ C*5,11;DD
 ON C GOTO  dices_4 , dices_5 , dices_6 , dices_7 , dices_8 , dices_9 , dices_10 
dices_4
 ML(P)=DD+15:CARAC(C)=ML(P)
 PRINT@ 5,13;ML(P):GOTO  dices_11 
dices_5
 RG(P)=DD+15:CARAC(C)=RG(P)
 PRINT@10,13;RG(P):GOTO  dices_11 
dices_6
 ST(P)=DD+15:CARAC(C)=ST(P)
 PRINT@15,13;ST(P):GOTO  dices_11 
dices_7
 AG(P)=DD+15:CARAC(C)=AG(P)
 PRINT@20,13;AG(P):GOTO  dices_11 
dices_8
 IQ(P)=DD+15:CARAC(C)=IQ(P)
 PRINT@25,13;IQ(P):GOTO  dices_11 
dices_9
 MS(P)=DD+15:CARAC(C)=MS(P)
 PRINT@30,13;MS(P):GOTO  dices_11 
dices_10
 HP(P)=6+FNA(4)+INT(ST(P)/10)
 ZAP:WAIT50:CARAC(7)=HP(P):PRINT@35,13;HP(P)
dices_11
 NEXT C
 PRINT@ 34,11;"=";TT
 PRINT@13,20;CHR$(145);" IS IT OK (Y/N) ";CHR$(144)
dices_12
 GETA$:IFA$="" THEN  dices_12 
 IF TRY=3 THEN TRY=1:GOTO dices_13 
 IF A$= "Y" THEN  dices_13 
 IF A$<>"N" THEN  dices_12 
 ZAP:TRY=TRY+1:GOTO dices_14 
dices_13
 PRINT@12,20;CHR$(145);"^  CULTURE BONUS  ^ ";CHR$(144)
 FORI=1TO7
 PRINT@ I*5+1,14;BC(CULT(P),I):WAITVT*40:PING
 PRINT@ I*5,15;CARAC(I)+BC(CULT(P),I):WAITVT*40:PING
 NEXT I
 
 PRINT@12,20;CHR$(148);"^   ROLE  BONUS  ^ ";CHR$(144)
 FORI=1TO7
 PRINT@ I*5+1,16;BR(ROLE(P),I):WAITVT*40:PING
 PRINT@ I*5,17;CARAC(I)+BR(ROLE(P),I):WAITVT*40:PING
 NEXT I
 END:REM ++++++++++++++++++++++++++++++++++++++++++++++++++++++
dices_1
 REM ++  DICES ROLL  ++++++++
 PRINT @13,7;CHR$(138);"                   "
 PRINT @13,8;CHR$(138);"                   "
 PRINT @14,20;"< Press Space>"
 RETURN
dices_3
 FOR I=1TO15
 WAIT VT*3
 D1=FN A(D):D2=FN A(D)
 PRINT @14,7;CHR$(138);D1
 PRINT @14,8;CHR$(138);D1
 PRINT @19,7;CHR$(138);D2
 PRINT @19,8;CHR$(138);D2
 NEXT
 DD=D1+D2:TT=TT+DD
 PRINT @24,7;CHR$(138);"=";DD
 PRINT @24,8;CHR$(138);"=";DD
 WAIT VT*25
 RETURN
dices_0
 FORI=1TO6:READ ROLE$(I):NEXTI:REM 6 roles
 FORI=1TO7:READ CULT$(I):NEXTI:REM 7 cultures (races)
 FORI=1TO7:READ CARAC$(I):NEXTI:REM 7 CARACTERISTICS
 FOR R=1TO6: FOR C=1TO7:REM ++ Bonus des Roles
 READ BR(R,C)
 NEXT C, R
 FOR R=1TO7: FOR C=1TO7:REM ++ Bonus des Cultures
 READ BC(R,C)
 NEXT C, R
 RETURN
 DATA Legionary, Gladiator, Scout, Druid, Sem-Priest, Vestal
 DATA Celtic, Egyptian, Gallic, Goth, Persian, Roman, Viking
 DATA Melee Skill, Range Skill, Strength
 DATA Agility, Intelligence
 DATA Mental Strength, Health Points
 REM   Ml Rg St  Ag IQ MS HP  les 7 bonus de roles
 DATA   8, 4, 6, 3, 0, 5, 5: REM Legionary
 DATA   9, 2, 5, 5, 0, 6, 4: REM Gladiator
 DATA   4, 8, 4, 8, 2, 6, 3: REM Scout (Eclaireur)
 DATA   0, 4, 4, 6, 6, 6, 2: REM Druid
 DATA  -2,-2, 2, 8, 4, 6, 1: REM Sem-Priest
 DATA  -4,-4, 0, 9, 9, 9,-1: REM Vestal
 REM   Ml Rg St  Ag IQ MS HP  les 7 bonus de culture
 DATA   2, 0, 0, 1, 1, 1, 1: REM Celtic
 DATA  -1, 2, 0, 2, 1, 1, 0: REM Egyptian
 DATA   3, 0, 2, 2,-2, 1, 1: REM Gallic
 DATA   4,-2, 4, 0,-4, 0, 2: REM Goth
 DATA  -2, 4, 0, 3, 0, 0,-1: REM Perse
 DATA   3, 0, 0, 0, 3, 0, 0: REM Roman
 DATA   3, 0, 4, 0,-3, 5, 3: REM Viking
