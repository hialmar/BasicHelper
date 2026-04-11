#labels
 REM {+++++++ ORIC - TYRANN 3 - janvier 2014 +++++++++++}
 PAPER0:INK7:LOAD "FONT.BIN":HIRES:LOAD"PAGE1.HRS":POKE 48035,0
 POKE#26A,PEEK(#26A) AND 254 'Vire le curseur
 PRINT:PRINT SPC(9);" TYRANN 3 - ORIC 2015 "
 WAIT500:PRINT SPC(14);" < ESPACE >"
creation_0
 IF KEY$<>" " THEN  creation_0 
 A=DEEK(#308):R=RND(-A)
 TEXT:CLS:INK3
 PRINT CHR$(17);CHR$(20):REM +++ EFFACE CURSEUR ET CAPS
 PRINTSPC(2);CHR$(4);CHR$(27);"JMAXIMUS et HIALMAR ";CHR$(27)"BPRESENTENT"
 PRINT:PRINT:PRINT
 PRINTSPC(12);CHR$(27);"A";CHR$(27)"JTYRANN 3";CHR$(4)
 PRINT:PRINT:PRINT
 PRINT "   "CHR$(27);"E";CHR$(96)" RENDEZ VOUS A WESTEROS":PRINT
 A$=CHR$(126):B$=CHR$(255)
 LP$=B$:FORI=1TO34:LP$=LP$+B$:NEXTI
 L$=B$:FORI=1TO33:L$=L$+B$:NEXTI:L$=L$+B$
 PRINT LP$
 PRINT B$;SPC(33);B$
 PRINT B$;"   Vous avez survecu a Tyrann 1  ";B$
 PRINT B$;SPC(33);B$
 PRINT B$;"   Vous avez vaincu Nargaloth    ";B$
 PRINT B$;SPC(33);B$
 PRINT L$
 PRINT B$;SPC(33);B$
 PRINT B$;"  Par les Sept ! survivrez vous  ";B$
 PRINT B$;SPC(33);B$
 PRINT B$;SPC(33);B$
 PRINT B$;"     a ce qui vient du Nord      ";B$
 PRINT B$;SPC(33);B$
 PRINT LP$
 WAIT300:PLOT 28,24," ESPACE >"
creation_1
 GETA$:IF A$<>" " THEN  creation_1 
 PRINT CHR$(17);CHR$(20)
 SEARCH "TEAM.BIN"
 IF EF=1 THEN  creation_2 
 REM ++++++++++ CREATION DES PERSONNAGES ++++++++++++
creation_30
 GOSUB  creation_3 :REM ++++ MESSAGE INFO ++++
 DEF FNA(X)=INT(RND(1)*X)+1:D=10:REM ++ CREATION du D� 10 faces (D10) ++
 FORI=1TO6:READ C$(I):NEXTI:REM ++ Carrieres ++
 FORI=1TO9:READ M$(I),CR$(I):NEXTI:REM ++ Maisons M$ et Royaume CR$ ++
 FOR I=1TO6:READ CAR$(I):NEXTI:REM +++ 6 CARACTERISTIQUES principales +++
 FOR C=1TO6:FORB=1TO6:READ BC(C,B):NEXT B, C:REM ++ Bonus des carrieres ++
 FOR P=1TO6:REM +++++++  6 PERSOS , LA VARIABLE P EST r�serv�e +++++++++
 FOR I=1TO6:SAD(P,I)=0:NEXTI:REM ++ INITIALISE LE SAC A DOS
creation_7
 CLS:PRINT:PRINTSPC(12);CHR$(4);CHR$(27)"JTYRANN 3";CHR$(4)
 PRINT
 PRINT:S$=" ******* CREATION PERSONNAGES ****** ":GOSUB  creation_4 :PRINT
 IF P=1 THEN  creation_5 
 S$="Equipe: ":GOSUB  creation_6 :PRINT:T=P-1
 FORI=1TO T:PRINT I;C$(CP(I));:S$=N$(I)
 PRINT @16,I+8;S$:IF MP(I)>1 THEN PRINT @27,I+8;M$(MP(I))
 NEXT
creation_5
 PRINT:S$="PRENOM DU PERSO No"+STR$(P)+" (10 lettres max)":GOSUB  creation_6 
 INPUTN$(P)
 IFLEN(N$(P))<2THENZAP:GOTO creation_7 
 IFLEN(N$(P))>10THENN$(P)=LEFT$(N$(P),10)
 GOSUB  creation_8 
creation_12
 S$=N$(P)
 N=6:X=1:GOSUB  creation_9 
 PRINT @6,13;"QUELLE CARRIERE ? ";
creation_10
 GETC$:IFVAL(C$)<1ORVAL(C$)>6THEN  creation_10 
 C=VAL(C$):CP(P)=C:PRINT C$(CP(P))
 GOSUB  creation_11 :IF OK$="N" THEN  creation_12 
creation_14
 S$=C$(CP(P))+" "+N$(P):N=9:X=0:GOSUB  creation_9 
 PRINT @6,15;" QUELLE MAISON ? ";
creation_13
 GET M$:IFVAL(M$)<1ORVAL(M$)>9THEN  creation_13 
 MP(P)=VAL(M$):PRINT M$(MP(P))
 GOSUB  creation_11 :IF OK$="N" THEN  creation_14 
 T=1:NI(P)=1
creation_24
 REM ++++++++ TIRAGE DES CARACTERISTIQUES + BONUS CARRIERE +++++++
 IF MP(P)=1 THEN M$="" ELSE M$=M$(MP(P))
 CLS:S$=" "+C$(CP(P))+" "+N$(P)+" "+M$+" ":GOSUB creation_6 
 S$=" LANCER de DES <espace> ":GOSUB creation_4 
 PRINTCHR$(145)" Essai:"T" ";CHR$(144):PRINT
 PRINT@2,4;"FORMULE CARAC:";:PRINT@24,4;"Bonus"
 PRINT@2,5;"Base 15    +    2D  +";:PRINT@24,5;"Carriere"
 S$="CC:"+CAR$(1)+">":  GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :CC(P)=D1+D2+15+BC(CP(P),1)
 S$=STR$(BC(CP(P),1))+" >":PRINT@26, 7;S$;:S$=STR$(CC(P))+"  ":GOSUB creation_6 :PRINT
 S$="CT:"+CAR$(2)+" > ":GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :CT(P)=D1+D2+15+BC(CP(P),2)
 S$=STR$(BC(CP(P),2))+" >":PRINT@26,10;S$;:S$=STR$(CT(P))+"  ":GOSUB creation_6 :PRINT
 S$="FO:"+CAR$(3)+" > ":GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :FO(P)=D1+D2+15+BC(CP(P),3)
 S$=STR$(BC(CP(P),3))+" >":PRINT@26,13;S$;:S$=STR$(FO(P))+"  ":GOSUB creation_6 :PRINT
 S$="AG:"+CAR$(4)+" > ":GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :AG(P)=D1+D2+15+BC(CP(P),4)
 S$=STR$(BC(CP(P),4))+" >":PRINT@26,16;S$;:S$=STR$(AG(P))+"  ":GOSUB creation_6 :PRINT
 S$="QI:"+CAR$(5)+" > ":GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :IN(P)=D1+D2+15+BC(CP(P),5)
 S$=STR$(BC(CP(P),5))+" >":PRINT@26,19;S$;:S$=STR$(IN(P))+"  ":GOSUB creation_6 :PRINT
 S$="FM:"+CAR$(6)+" > ":GOSUB creation_4 :GOSUB creation_15 :GOSUB  creation_16 :FM(P)=D1+D2+15+BC(CP(P),6)
 S$=STR$(BC(CP(P),6))+" >":PRINT@26,22;S$;:S$=STR$(FM(P))+"  ":GOSUB creation_6 :PRINT
 GOSUB creation_15 
 PV(P)=INT((FO(P)*2)/10)+4+FNA(3)
 IF CP(P)<4 THEN PV(P)=PV(P)+CP(P)
 'IF CP(P)>3 THEN PV(P)=PV(P)-(CP(P)-3)
 ET(P)=PV(P)
 XP(P)=1:CA(P)=10:OK(P)=1
 RI(P)=FNA(150)+200:WAIT100: REM ++ FIN INITIALISATION
 REM +++ APPLICATIONS DES MAISONS +++
 MP=MP(P)
 IF MP=1 THEN AG(P)=AG(P)+3:CT(P)=CT(P)+2:IN(P)=IN(P)+3:RI(P)=RI(P)-50
 IF MP=8 OR MP=9 THEN FO(P)=FO(P)+3:FM(P)=FM(P)+2
 IF MP=4 OR MP=5 THEN IN(P)=IN(P)+3:RI(P)=RI(P)+150+INT(FNA(200))
 IF MP=3 OR MP=6 THEN FO(P)=FO(P)+2:PV(P)=PV(P)+3:ET(P)=PV(P)
 IF MP=2 OR MP=7 THEN AG(P)=AG(P)+2:CC(P)=CC(P)+3
 CUMUL=CC(P)+CT(P)+FO(P)+AGI(P)+IN(P)+FM(P)
 GOTO  creation_17 
 REM PAUSE
 WAIT 100
creation_19
 PRINT @15,24;CHR$(148);"< ESPACE >";CHR$(144):PING
creation_18
 A$=KEY$:IF A$="" THEN  creation_18 
 IF A$<>" " THEN  creation_19 
 RETURN
creation_11
 REM OK ?
 PING:WAIT 100
 PRINT@11,17;CHR$(148)" < OK ? O/N > "CHR$(144)
creation_20
 OK$=KEY$:IF OK$="" THEN  creation_20 
 IF OK$<>"N" AND OK$<>"O" THEN  creation_20 
 RETURN
creation_8
 REM Mise en minuscule du prenom
 S$=N$(P):N$(P)=LEFT$(S$,1)
 FORI=2TOLEN(S$)
 MI=ASC(MID$(S$,I,1))
 IF MI>64 AND MI<91 THEN MI=MI+32
 L$=CHR$(MI)
 N$(P)=N$(P)+L$
 NEXT
 RETURN
creation_17
 CLS:PAPER 0:INK 7
 PRINT@10,1;CHR$(138);CHR$(145);" Fiche de ";N$(P)" ";CHR$(144)
 PRINT@10,2;CHR$(138);CHR$(145);" Fiche de ";N$(P)" ";CHR$(144)
 S$=M$(MP(P)):IF MP(P)=1THENS$="Roturier"
 PRINT@4,4;CHR$(148)" "C$(CP(P))" "CHR$(144);" + BONUS ";S$
 S$=" CC  CT  Fo  Ag  In  FM  => Cumul "
 PRINT@4,7;CHR$(148)S$CHR$(144)
 S$=STR$(CC(P))+" "+STR$(CT(P))+" "+STR$(FO(P))+" "+STR$(AG(P))+" "+STR$(IN(P))+" "+STR$(FM(P))+"     "+STR$(CUMUL)
 PRINT@5,9;S$:PRINT:PRINT
 PRINT@4,12;CHR$(148)" Richesse: "CHR$(144);RI(P);" Cerfs d'argent"
 PRINT@4,14;CHR$(148)" PV (Points de Vie): "CHR$(144);PV(P)
 IF T=3 THEN  creation_21 
 IF T=1 THEN S$="IL VOUS RESTE 2 ESSAIS" ELSE S$="!! DERNIER ESSAI !!"
 PRINT@10,18; S$:PRINT
 PRINT@6,20; "VOUS GARDEZ CE PERSONNAGE ?...O/N":GOTO creation_22 
creation_21
 PRINT@10,18; "C'ETAIT LE DERNIER ESSAI"
 PRINT@15,20;CHR$(148)" < O)K > "CHR$(144)
creation_22
 GETOK$
 IF T=3 AND OK$="O" THEN  creation_23 
 IFOK$="O"THEN  creation_23 
 IFOK$<>"N"THEN  creation_22 
 IF T<3 THEN T=T+1:GOTO  creation_24 
creation_23
 NEXT P
 GOTO  creation_25 
creation_3
 CLS:S$="******* CREATION PERSONNAGES ******* ":GOSUB creation_4 :PRINT:PRINT
 PRINT "Vous allez creer 6 personnages, choi-"
 PRINT "sissez leur un prenom et une carriere"
 PRINT "ensuite choisissez leur une maison...":PRINT
 PRINT "Comme dans tous les jeux de roles, il"
 PRINT "faut lancer 2 D10 pour definir les  6"
 PRINT "caracteristiques et les Points de vie":PRINT
 PRINT "Equilibrez bien votre equipe, chaque "
 PRINT "choix a ses points forts et faibles  ":PRINT
 PRINT "Vous avez 3 essais par personnage... ":PRINT
 PRINT @6,18;"Bonne creation d'equipe ! ;-)":PRINT@15 ,22;CHR$(148)"< Espace > "CHR$(144)
creation_26
 GETA$:IFA$<>" " THEN  creation_26 
 RETURN
creation_4
 REM +++++++++  TEXTE SUR FOND BLEU +++++++++++++++
 PRINTCHR$(148);S$;CHR$(144)
 RETURN
creation_6
 REM +++++++++  TEXTE SUR FOND ROUGE +++++++++++++++
 PRINTCHR$(145);S$;CHR$(144)
 RETURN
 REM |======================================================|
creation_25
 REM |>>>>>>>>>>> INITIALISATION & SAUVEGARDE  >>>>>>>>>>>>>|
 REM |======================================================|
 CLS:GOSUB  creation_27 :DIM CB(20),CF(9,8)
creation_28
 A$=KEY$:IF A$="" THEN  creation_28 
 S$="   SAUVEGARDES EN COURS - PATIENCE  ":GOSUB  creation_6 
 VIL=1:TL=1:BS=0:FIL=0:SD=0:NP=0:PM=0' ni boussole, ni Filet, ni Selle
 O1=#A000:POKE O1,0
 O1=O1+1:POKEO1,1 'numero de version
 O1=O1+1:POKEO1,85'X
 O1=O1+1:POKEO1,2'Y
 O1=O1+1:POKEO1,S
 O1=O1+1:POKEO1,CA
 O1=O1+1:POKEO1,VIL
 FOR P=1TO6
 O1=O1+1:POKEO1,LEN(N$(P))'Longueur du pr�nom
 FORJ=1TOLEN(N$(P))
 O1=O1+1:POKEO1,ASC(MID$(N$(P),J,1))'stockage du pr�nom
 NEXTJ
 O1=O1+1:DOKEO1,INT(RI(P)/10)' argent sur 2 octets
 O1=O1+2:POKEO1,CP(P):REM + Carriere du Personnage
 O1=O1+1:POKEO1,MP(P):REM + Maison du Personnage
 O1=O1+1:POKEO1,CC(P):REM + Capacite de Combat
 O1=O1+1:POKEO1,CT(P):REM + Capacite de Tir
 O1=O1+1:POKEO1,FO(P):REM + Force
 O1=O1+1:POKEO1,AG(P):REM + Agilite
 O1=O1+1:POKEO1,IN(P):REM + Intelligence
 O1=O1+1:POKEO1,FM(P):REM + Force Mentale
 O1=O1+1:POKEO1,PV(P):REM > Points de Vie ou de Blessures
 O1=O1+1:POKEO1,ET(P):REM > Etat des PV
 O1=O1+1:OK(P)=1:POKEO1,OK(P):REM > Sante
 O1=O1+1:NI(P)=1:POKEO1,NI(P):REM > Niveau du perso
 O1=O1+1:XP(P)=0:DOKEO1,XP(P):REM > Experience
 O1=O1+2:WR(P)=0:POKEO1,WR(P):REM > ARME DROITE (WEAPON RIGHT)
 O1=O1+1:WL(P)=0:POKEO1,WL(P):REM > ARME G (WEAPON LEFT)
 O1=O1+1:PT(P)=0:POKEO1,PT(P):REM > PROTECTION
 O1=O1+1:CA(P)=0:POKEO1,CA(P):REM > Classe d'armure
 O1=O1+1:BT(P)=0:POKEO1,BT(P):REM > BETE (ANIMAL)
 FORI=1TO6:O1=O1+1:POKEO1,SAD(P,I):NEXTI:REM Sac � Dos
 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:POKEO1,SN(P,I):NEXT'SORTS
 NEXT P
 O1=O1+1:POKEO1,BS'Boussole
 O1=O1+1:POKEO1,FI'Filet
 O1=O1+1:POKEO1,SD'Selle de Dragon: maitre des dragons (1 � 6)
 FOR L=1TO9:FOR C=1TO4:O1=O1+1:CLEF(L,C)=0:POKEO1,CLEF(L,C):NEXT C,L:REM Trousseau de clefs
 FORI=1TO6:O1=O1+1:POKEO1,IG(I):NEXT' tableau des 6 ingr�dients de la potion
 FOR V=1TO9:FORM=1TO5:O1=O1+1:POKEO1,0:NEXT M,V' tableau coffres et combats � 0
 O1=O1+1:POKEO1,0'DEdans (portes speciales franchies ou pas - bits 0-3) + Potion Magique (bit 6) + Wall (bit 7)
 O1=O1+1:POKEO1,1'TL = Team Level
 O1=O1+1:POKEO1,0'NP = Nombre d'ingredients de la Potion (NI utilise pour Items)
 O1=O1+1:POKEO1,0'NF = Nombre de fuites
 O1=O1+1:POKEO1,0'PM = Potion faite
 PING
 SAVEU "TEAM.BIN",A#A000,EO1
 SAVEU "TEAM2.BIN",A#A000,EO1:REM Copie secours
 LOAD"VILLE"
creation_27
 REM AFFICHE EQUIPE
 CLS:PRINT@8,1;CHR$(145)" * TYRANN 3 - EQUIPE *  "CHR$(144)
 L=3:PRINT@3,L;CHR$(145)"PERSONNAGES� MAISON    CARRIERE   "CHR$(144)
 PRINT@3,L+1;CHR$(148)" Argent      CC CT Fo Ag In FM PV "CHR$(144):L=5
 FOR I=1TO6
 IF CP(I)=1 THEN ENC=131
 IF CP(I)=2 THEN ENC=135
 IF CP(I)=3 THEN ENC=134
 IF CP(I)=4 THEN ENC=133
 IF CP(I)=5 THEN ENC=132
 IF CP(I)=6 THEN ENC=130
 PRINT @ 1,L;CHR$(ENC);I;N$(I);:PRINT @ 17,L;M$(MP(I)):PRINT @ 27,L;C$(CP(I))
 PRINT @ 4,L+1;STR$(RI(I));" ca"
 S$=STR$(CC(I))+STR$(CT(I))+STR$(FO(I))+STR$(AG(I))+STR$(IN(I))+STR$(FM(I))+STR$(PV(I))
 PRINT@16,L+1;S$:L=L+3
 NEXT I:PRINT@3,L-1;CHR$(148)" Argent      CC CT Fo Ag In FM PV "CHR$(144)
 ENC=4
 RETURN
creation_9
 REM +++ AFFICHEUR  ++++
 CLS:PRINT
 PRINT"    ******************************"
 T=INT((37-LEN(S$))/2)
 PRINT @ T,1;" ";CHR$(145);" ";S$;"  ";CHR$(144)
 PRINT"    *                            *"
 FOR I=1TON:L=I+2
 IF X=0 THEN C$=M$(I) ELSE C$=C$(I)
 PRINT @6,L;"*":PRINT @35,L;"*"
 PRINT @14,L;I;C$
 NEXT I
 PRINT"    *                            *"
 PRINT"    ******************************"
 RETURN
creation_15
 PING
creation_29
 GETA$:IF A$<>" " THEN  creation_29 
 RETURN
 REM +++ LANCER DE D�s +++
creation_16
 D1=FNA(D):PRINT "D1:";D1;
 D2=FNA(D):PRINT "D2:";D2;" = ";D1+D2
 RETURN
creation_2
 PRINT "Une sauvegarde existe."
 PRINT "Voulez-vous continuer le jeu ? (O/N)"
 GETA$:IF A$<>"O" AND A$<>"o" THEN  creation_30 
 LOAD "VILLE"
 DATA Chevalier,Mercenaire,Ranger,Sorcier,Mestre,Septon
 DATA "Aucune","KING'S LANDING", MARTELL,DORNE, BARATHEON,"STORM'S END"
 DATA TYRELL,HIGHGARDEN, GREYJOY,PIKE, ARRYN,EYRIE
 DATA LANNISTER,CASTERLY ROC, TULLY,RIVERRUN, STARK,WINTERFELL
 DATA Capacite de Combat, Capacite de Tir, Force
 DATA Agilite, Intelligence, Force Mentale
 REM  CC CT FO AGI IN FM
 DATA  9, 0, 9, 2, 2, 4: REM CHEVALIER
 DATA  7, 2, 6, 6, 6, 6: REM MERCENAIRE
 DATA  4, 8, 4,10, 0, 0: REM RANGER
 DATA  2, 2, 2, 6, 6, 8: REM SORCIER
 DATA  0, 0, 0, 4, 8, 6: REM MESTRE
 DATA -2,-2, 0, 4,10,10: REM SEPTON
 DATA  1,2,1,1,1,1,3,1,3,3,1,1,2,3,1,1,1,1,1,2,2,1,1,1,3
