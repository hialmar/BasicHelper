#labels
 REM {++ ORIC 2014 + TYRANN 3 VO MAXIMUS +}
 POKE 48035,0
 PAPER0:INK6:POKE#26A,PEEK(#26A) AND 254
 A=DEEK(#308):R= RND(-A)
 GRAB : HIMEM 40959 : GOSUB  combat_0 : GOSUB  combat_1  : POKE 48035,0
 NO=CA-30 ' numero du combat
 IF NO<13 THEN NC=1:GOTO  combat_2  ' niveau du combat
 IF NO<18 THEN NC=2:GOTO  combat_2 
 NC=3
combat_2
 CLS:PAPER0:INK6:POKE#26A,PEEK(#26A) AND 254
 PLOT 8,6,"! EN POSITION DE COMBAT !":PING
 GOSUB  combat_3 
 GOTO  combat_4 
combat_129
 PAPER0:INK ENC:PRINT
 PRINT" ************************************"
 FORI=1TOL:PRINT@2,I;"*":PRINT@38,I;"*":NEXTI
 T=INT((33-LEN(S$))/2)
 PRINT @ T,1;" ";CHR$(145);"< ";S$;" > ";CHR$(144)
 PRINT@2,I;"*************************************"
 RETURN
combat_29
 T=INT((42-LEN(S$))/2):PRINT @T,L;S$
 RETURN
combat_5
 PRINT@14,L;" ";CHR$(145);"< ESPACE > ";CHR$(144):GETA$:IFA$<>" "THEN combat_5 
 RETURN
combat_6
 GET A$:A=VAL(A$):IFA<1ORA>6THENPING:GOTO combat_6 
 RETURN
combat_71
 PING:PRINT @2,18;CHR$(148)" IMPOSSIBLE "CHR$(144)
 WAITTI*3:GOSUB  combat_7 
 ZAP:PRINT @2,18;"              "
 RETURN
combat_8
 REM CLS
 FORII=1TO11:
 PRINT@1,7+II;CHR$(144)"                                        ":NEXTII
 RETURN
combat_132
 FOR J=1TO11
 PRINT @3,10+J;"                                   ":NEXTJ
 RETURN
combat_9
 GOSUB  combat_8 :PRINT @9,12;"Time (1-3) Now:";TI/5;:INPUT TI
 IF TI<1 OR TI>3 THEN PING:GOTO  combat_9 
 TI=5*TI
 RETURN
combat_4
 REM |===/ COMBATS \===|
 T=15'curseur pour piocher dans la banque des monstres
 IF VIL > 2 THEN T=12
 IF VIL > 5 THEN T=7
 IF NC=2 THEN T=T-3
 IF NC=3 THEN T=T-5
 IF VIL > 7 THEN T=0
 IF VIL = 10 THEN T=12
 NE=FNA(4)+1'Creation des ennemis
 IF VIL<3 AND NE>3THEN NE=3
 EV=NE ' Ennemis Vivants = compteur
 FOR I=1 TO NE
 SS=FNA(NM-T):MO(I)=SS
 C1AGI(I)=CM(SS,1)+FNA(VIL)*2
 C2PV(I)= CM(SS,2)+FNA(VIL*2)+NC*4:DC=DC+C2(I)
 C3CC(I)= CM(SS,3)+FNA(VIL)
 C4BF(I)= CM(SS,4)+FNA(3)
 C5QI(I)= CM(SS,5)+FNA(VIL)
 C6OK(I)=1
 NEXT I
 DC=INT(DC/7)+FNA(VIL)
 REM INIT
 FU=0:ZO=0:HV=6:DR=0:DD=0:AMI=0:FF=0
 GOSUB  combat_10 'Tri
 FOR I=1TO6:BC(I)=CA(I):EF(I)=0:FC(I)=0:PRD(I)=0
 IF OK(I)=4 THEN HV=HV-1
 NEXT
combat_40
 REPEAT:REM AFFICHAGE COMBAT
combat_18
 CLS:INK6:POKE#26A,PEEK(#26A) AND 254
 POKE 48035,0
 GOSUB  combat_11 
 GOSUB  combat_7 
 IF FF= 0 THEN GOSUB  combat_12 
 IF BUG=1 THEN  combat_13 
 FOR P=1TO6
 ACT(P)=3
 IF OK(P)<3 THEN GOSUB  combat_14  ELSE  combat_15 
 GOSUB  combat_16 
combat_15
 GOSUB  combat_8 
 NEXT P
combat_20
 PRINT @8,12;"CHANGER VOS CHOIX (O/N) ?"
 PRINT @8,16;"REGLER TEMPS AFFICHAGE: T"
combat_17
 GETR$:IF R$="" THEN  combat_17 
 IF R$="O" OR R$="o" THEN  combat_18 
 IF R$="N" OR R$="n" THEN  combat_19 
 IF R$="T" OR R$="t" THEN GOSUB  combat_9 :GOTO  combat_20 
 PING:GOTO  combat_17 
combat_19
 REM tour de combat
 FR = FRE("")
 IF DRAG>0 THEN DD=1:GOSUB  combat_21 
 FOR P=1TO6+NE
 ACT$=" attaque ":GOSUB  combat_8 
 PRINT@2,7;CHR$(145)"************** COMBAT ************** "CHR$(144)
 IF ESP(P)=0 AND EV>0 THEN GOTO  combat_22 'action ennemis
 REM HEROS
 IF OK(AO(P))>2 THEN  combat_23 
 ON ACT(AO(P)) GOTO  combat_24 , combat_25 , combat_26 , combat_27 
combat_24
 IF C2PV(TG(AO(P)))<=0 THEN  combat_23 
 GOSUB  combat_28 
 L=10:S$=N$(AO(P))+ACT$:GOSUB  combat_29 :WAIT TI*5
 L=12:S$=MM$(MO(TG(AO(P)))):ZAP:GOSUB  combat_29 :WAIT TI*5
 IF C6OK(TG(AO(P)))>2 THEN DFF=DFF+30
 GOSUB  combat_30 :DFF=FNA(VIL*3)
 IF ARM <4 THEN GOSUB  combat_31  ELSE GOSUB  combat_32 
 GOTO  combat_26 
combat_25
 REM ACT 2
 GOSUB  combat_33 
 GOTO  combat_26 
combat_27
 REM ACT 4
 IF EV=0 THEN  combat_23 
 GOSUB  combat_34 
combat_26
 IF OK(AO(P))=2 THEN ET(AO(P))=ET(AO(P))-FNA(2)-FNA(VIL)
 IF ET(AO(P))<=0 THEN OK(AO(P))=4:ET(AO(P))=0:HV=HV-1
 GOTO  combat_23 'Fin action perso
combat_22
 REM Attaque du monstre
 IF C6OK(AO(P))>4 OR C6OK(AO(P))=0 THEN  combat_23 
 IF C6OK(AO(P))=4 AND EV>0 THEN GOSUB  combat_35 :GOTO  combat_36 
 IF C6OK(AO(P))=6 THEN GOSUB  combat_37 :GOTO  combat_23 
 IF HV>0 THEN GOSUB  combat_38  ELSE  combat_23 
 IF C6OK(AO(P))<2 OR C6OK(AO(P))>3 THEN  combat_36 
 C2(AO(P))=C2(AO(P))-FNA(C6(AO(P))*4)-2
 IF C2(AO(P))> 0 THEN  combat_23 
 IF C6OK(AO(P))=6 THEN FU=0
 C2(AO(P))=0:C6OK(AO(P))=0:EV=EV-1
 PRINT @15,16;MM$(MO(AO(P)));" meurt ":EXPLODE:WAIT 5*TI
combat_36
 WAIT 15*TIME
combat_23
 NEXT P
 FOR I=1TO6:PRD(I)=0:NEXT
 GOSUB  combat_39 
combat_13
 UNTIL EV<1 OR HV<1
 IF BUG=1 THEN BUG=0:CLS:ZAP:WAIT50:GOTO  combat_40 
 FORP=1TO6:BC(P)=CA(P):NEXTP
 IFPD=1THEN GOSUB combat_41 :PD=0
 IF HV>0 THEN  combat_42 
 REM Defaite
 CLS:FORI=7TO0STEP-1:ZAP:WAIT10:PAPERI:NEXT:EXPLODE
 PRINT @6,8;" Votre equipe est detruite "
 PRINT @5,12;"1.Recommencer"
 PRINT @5,14;"2.Battre en retraite"
 GOSUB  combat_7 
combat_43
 GETA$:IF A$<"1" OR A$>"2" THEN  combat_43 
 IF A$="1" THEN RELEASE : GOTO  combat_44 
 CLS:PRINT@15,5;"Pleutre !":ZAP
 PRINT@5,8;"Memoire restante:";:PRINT FRE(""):PING:RELEASE:END
 REM |SOUS PROGS COMBAT
combat_11
 REM AFFICHE ENNEMIS
 REM ZO=1'DEV A VIRER
 FORI=1TO6:PRINT@1,I;"                               ":NEXT
 REM PRINT@3,6;"DC:";DC;"EV:";EV
 FORI=1TONE
 S$=STR$(I)+" "+MM$(MO(I)):C=3
 IF C6OK(I)=0 THEN S$=CHR$(149)+CHR$(128)+S$+" (Mort) "+CHR$(144):C=1:GOTO  combat_45 
 ON C6OK(I) GOTO  combat_46 , combat_47 , combat_48 , combat_49 , combat_50 , combat_51 
combat_47
 C=2:S$=CHR$(130)+S$+" (Poison)"+STR$(C2(I)):GOTO  combat_45 
combat_48
 C=2:S$=CHR$(129)+S$+" (Saigne)"+STR$(C2(I)):GOTO  combat_45 
combat_49
 C=2:S$=CHR$(134)+S$+" (Ami)":GOTO  combat_46 
combat_50
 C=2:S$=CHR$(131)+S$+" (Endormi)":GOTO  combat_46 
combat_51
 C=2:S$=CHR$(132)+S$+" (Filet)"
combat_46
 IF ZO=1 THEN S$=S$+CHR$(130)+STR$(C2(I))
combat_45
 PRINT@C,I;S$
 NEXTI
 RETURN
combat_7
 REM AFFICHE EQUIPE
 FR = FRE(""):L=19:PRINT@1,L;CHR$(145)"PERSONNAGES    CASTE      PV  ET  CA"
 FOR I=1TO6:L=L+1
 IF CP(I)=1 THEN ENC=131
 IF CP(I)=2 THEN ENC=135
 IF CP(I)=3 THEN ENC=134
 IF CP(I)=4 THEN ENC=133
 IF CP(I)=5 THEN ENC=132
 IF CP(I)=6 THEN ENC=130
 IF OK(I)=4 THEN ENC=129
 IF OK(I)>1 THEN S$=OK$(OK(I)) ELSE S$=C$(CP(I))
 PRINT @ 1,L;CHR$(ENC);I;N$(I);:PRINT @ 17,L;S$;
 S$=STR$(BC(I)+PRD(I)):IF BC(I)+PRD(I)>9 THEN S$="MAX"
 IFBC(I)=50THEN S$="GOD"
 PRINT @ 27,L;PV(I):PRINT @ 34-LEN(STR$(ET(I))),L;ET(I):PRINT @ 36,L;S$
 NEXT I
 RETURN
combat_14
 REM INVENTAIRE
 L=7:E1=132:E2=132
 PRINT@2,L;CHR$(145)"*********************************** "CHR$(144)
 S$=" "+N$(P)+" - "+C$(CP(P))+" "
 T=INT((41-LEN(S$))/2)
 PRINT @T,L;S$:L=L+2
 IF EF(P)=0 THEN  combat_52  ELSE IF EF(P)=1 THEN E1=129 ELSE E2=129
combat_52
 PRINT @3,L;CHR$(E1);"1.D:";IT$(WR(P));CHR$(131):L=L+1
 PRINT @3,L;CHR$(E2);"2.G:";IT$(WL(P));CHR$(131):L=L+1
 PRINT @3,L;CHR$(132);"3.Anim:";:IF BT(P)>0 THEN PRINT IT$(BT(P));CHR$(131)
 OP(P)=0
 FORI=1TO6
 IF SAD(P,I)=0 THEN  combat_53 
 PRINT @2,L+I;CHR$(134);I+3;ITEM$(SAD(P,I));CHR$(131):OP(P)=OP(P)+1
combat_53
 NEXT I
 RETURN
combat_16
 REM MENU DE CHOIX
 PRINT@31,9;CHR$(145)"ACTION "CHR$(144)
 IF WR(P)=0 AND WL(P)=0 AND BT(P)=0 THEN ARM=0 ELSE ARM=1
 IF ARM=1 THEN PRINT@31,11;CHR$(131)"A)RMES"
 IF OP(P)>0 THEN PRINT@31,12;CHR$(131)"O)BJET"
 PRINT@31,13;CHR$(131)"P)ARER"
 IF CP(P)>3 THEN PRINT@31,14;CHR$(131)"S)ORTS"
combat_58
 GET A$
 IF A$="A" AND ARM=1 THEN ACT(P)=1:GOTO  combat_54 
 IF A$="O" AND OP(P)>0 THEN ACT(P)=2:GOSUB  combat_55 :GOTO  combat_56 
 IF A$="P" THEN ACT(P)=3:PRD(P)=1+FNA(2):GOSUB  combat_7 :GOTO  combat_56 
 IF A$="S" AND CP(P)>3 THEN ACT(P)=4:GOSUB  combat_57 :IF CH =0 THEN  combat_16  ELSE  combat_56 
 GOTO  combat_58 
combat_56
 RETURN
combat_12
 REM FUITE
 FF=1:PRINT@15,12;CHR$(131)"FUIR O/N"
combat_59
 GETA$
 IF A$<>"O" AND A$<>"N" THEN  combat_59 
 IF A$="N" THEN  combat_60 
 TEST=(VIL*2)+FNA(40)+10+NF
 IF TEST>AG(FNA(6)) THEN NF=0:GOTO  combat_61 
 CLS:PRINT@13,8;CHR$(145)" VOUS DETALEZ !!"CHR$(144)
 PRINT@13,10;"RETOUR LABYRINTHE":PRINT:NF=NF+20
 FORJ=1TO5:ZAP:WAIT5:NEXT:SHOOT:WAIT5
 GOTO  combat_62 
combat_61
 PRINT@15,12;CHR$(131)"  ECHEC  ":SHOOT:WAITTI*4
combat_60
 PRINT@15,12;CHR$(131)"         "
 RETURN
combat_54
 REM CHOIX ARMES (1-3)
 IF WL(P)=0 AND BT(P)=0 THEN A$="1":GOTO  combat_63 
 IF WR(P)=0 THEN A$="3":GOTO  combat_64 
 PRINT @4,8;"> Laquelle 1-3 ? "
combat_65
 GET A$:IF A$<>"1"ANDA$<>"2"ANDA$<>"3" THEN  combat_65 
combat_63
 IF A$="1" THEN BF(P)=IMPACT(WR(P)-7):AU(P)=WR(P):GOTO  combat_66 
 IF A$="2" THEN IF WL(P)>0 THEN BF(P)= IMPACT(WL(P)-7):AU(P)=WL(P) ELSE  combat_65 
combat_64
 IF A$="3" THEN IF BT(P)>0 THEN BF(P)= IA(BT(P)-36):AU(P)=BT(P) ELSE  combat_65 
combat_66
 IF AU(P)=18 AND FU=1 THEN PRINT@25,16;" FILET ACTIF ":WAIT 5*TI:GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 BF(P)=BF(P)+INT(FO(P)/10)+FC(P):GOSUB  combat_67 
 WAIT 5*TI
 RETURN
combat_55
 REM CHOIX OBJET OC(P)
 PRINT@31,12;CHR$(145)"O)BJET "CHR$(144)
 PRINT @31,16;"Lequel ?":PRINT @31,17;"0:Aucun"
combat_68
 GETA$:CH=VAL(A$):IF (CH>0 AND CH<4) OR CH>OP(P)+3  THEN  combat_68 
 IF CH=0 THEN GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 CH=CH-3:OC(P)=SAD(P,CH):CS(P)=CH
 PRINT@1,11+CH;CHR$(145):PRINT@27,11+CH;CHR$(144)
 IF OC(P)>19 AND OC(P)<25 THEN GOSUB  combat_69 :GOTO  combat_70 
 IF (OC(P)>24 AND OC(P)<34) THEN PING:GOTO  combat_70 
 GOSUB  combat_71 :GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 WAIT 5*TI
combat_70
 RETURN
combat_69
 REM CIBLER PERSO
 PING:PRINT @2,19;CHR$(148)"  Sur Qui ?  "CHR$(145)
 GOSUB  combat_6 
 TG(P)=VAL(A$)
 PRINT@1,19;CHR$(145)"PERSONNAGES    CASTE      PV  ET  CA"
 RETURN
combat_67
 REM CIBLER ENNEMI
 PRINT @3,6;CHR$(145)"* CIBLE ? "CHR$(144)
combat_72
 GET A$:IF VAL(A$)<1 OR VAL(A$)>NE THEN  combat_72 
 IF C6OK(VAL(A$))=0 THEN  combat_72 
 PRINT @3,6;CHR$(144)"         "
 TG(P)=VAL(A$)
 RETURN
combat_33
 REM ITEMS
 REM UTIL OBJET
 IF OC(AO(P))=25 OR OC(AO(P))=26 OR OC(AO(P))>31 THEN  combat_73 
 IF OC(AO(P))=20 OR OC(AO(P))=21 THEN GOSUB  combat_74 :GOTO  combat_75 
 IF OC(AO(P))=22 THEN GOSUB  combat_76 :GOSUB  combat_77 :GOTO  combat_75 
 IF OC(AO(P))=23 THEN GOSUB  combat_78 :GOTO  combat_75 
 IF OC(AO(P))=24 THEN GOSUB  combat_79 :GOTO  combat_75 
 IF OC(AO(P))>26 AND OC(AO(P))<32 THEN GOSUB  combat_80 
combat_75
 WAIT 5*TI:GOSUB  combat_7 :GOTO  combat_81 
combat_73
 IF OC(AO(P))=25 THEN PRINT @6,10;N$(AO(P))" utilise la vision Zoman ":ZO=1:GOTO  combat_81 
 IF OC(AO(P))=26 THEN PRINT @6,10;N$(AO(P))" utilise potion glaciale":GOSUB  combat_82 :GOTO  combat_81 
 IF OC(AO(P))=32 OR OC(AO(P))=33 THEN PRINT @6,10;N$(AO(P))" Fait peter ";IT$(OC(AO(P))):GOSUB  combat_83 :GOSUB  combat_84 
combat_81
 SAD(AO(P),CS(AO(P)))=0:WAITTI*5
 GOSUB  combat_85 
 RETURN
combat_84
 REM eveil
 IF REVEIL=O THEN  combat_86 
 IF FNA(100)> C5(REVEIL) THEN  combat_86 
 PING:PRINT@2,17;" > le bruit reveille "+MM$(MO(REVEIL)):WAITTI*8
 C6OK(REVEIL)=1:GOSUB  combat_11 
combat_86
 RETURN
combat_182
 REM CURE
 IF OK(TG(AO(P)))=4 THEN  combat_87 
 SS=FNA(4)+FNA(VIL)+3:IF OC(AO(P))=21 THEN SS=SS+4:OK(TG(AO(P)))=1
 ET(TG(AO(P)))=ET(TG(AO(P)))+SS:IF ET(TG(AO(P)))>PV(TG(AO(P))) THEN ET(TG(AO(P)))=PV(TG(AO(P)))
combat_87
 RETURN
combat_77
 REM LIFE
 IF OK(TG(AO(P)))<>4 THEN  combat_88 
 OK(TG(AO(P)))=1: ET(TG(AO(P)))=INT(PV(TG(AO(P)))/2)
 HV=HV+1:GOSUB  combat_7 
combat_88
 RETURN
combat_80
 REM FOOD
 IF OC(AO(P))=27 THEN M$=" boit de l'eau ":P1=4:P2=2:GOTO  combat_89 
 IF OC(AO(P))=28 THEN M$=" mange du pain ":P1=5:P2=3:GOTO  combat_89 
 IF OC(AO(P))=29 THEN M$=" sirote la cervoise ":P1=8:P2=3:GOTO  combat_89 
 IF OC(AO(P))=30 THEN M$=" engloutit le poisson ":P1=8:P2=4:GOTO  combat_89 
 IF OC(AO(P))=31 THEN M$=" devore le sanglier ":P1=10:P2=6
combat_89
 SS=FNA(P1)+P2:S$=N$(AO(P))+M$:L=10:GOSUB  combat_29 
 ET(AO(P))=ET(AO(P))+SS:IF ET(AO(P))>PV(AO(P)) THEN ET(AO(P))=PV(AO(P))
 RETURN
combat_83
 REM ++ GREGEOIS & SORTS COLLECTIFS
 DG=6:IF OC(AO(P))=32 THEN DG=3
combat_180
 FORJ=1TO5:SHOOT:WAIT15:PAPER J:NEXTJ:EXPLODE:PAPER0:GOSUB  combat_8 
combat_181
 IF EV=0 THEN  combat_90 
 LG=0:REVEIL=0
 FORI=1TO NE
 IF C6OK(I)<1 THEN  combat_91 
 IF C6OK(I)=5 THEN REVEIL=I:PING
 LG=LG+1
 SS=FNA(DG)+DG:IF C6OK>4 THEN SS=SS*3
 S$=MM$(MO(I))+" perd "+STR$(SS)+" PV":GOSUB  combat_92 
 PRINT @3,9+LG;S$:WAIT TI*5
combat_91
 NEXT I
 DD=0
 IF EV<=0 THEN  combat_90 
 GOSUB  combat_11 :WAIT TI*5
combat_90
 RETURN
combat_92
 REM mort ?
 C2PV(I)=C2(I)-SS:IF C2(I)>0 THEN  combat_93 
 S$=S$+CHR$(129)+" et meurt":IF C6OK(I)=6 THEN FU=0
 EV=EV-1:C6OK(I)=0:IF C6=4THENAMI=0
 IFDD=1THENMT(SD)=MT(SD)+1ELSEMT(AO(P))=MT(AO(P))+1
combat_93
 RETURN
 REM + Tri des persos
combat_10
 FOR P=1TO 6:JA=FNA(10):AO(P)=P:ESP(P)=1:VE(P)=AG(P)+JA:MT(P)=0:NEXTP
 FOR E=1TONE:JA=FNA(10):AO(E+6)=E:ESP(E+6)=0:VE(E+6)=C1AG(E)+JA:NEXTE
combat_39
 REPEAT
 SS=0
 FOR J=1 TO 5+NE
 IF VE(J)>=VE(J+1) THEN  combat_94 
 TP=VE(J):VE(J)=VE(J+1):VE(J+1)=TP
 TP=ESP(J):ESP(J)=ESP(J+1):ESP(J+1)=TP
 TP=AO(J):AO(J)=AO(J+1):AO(J+1)=TP
 SS=1
combat_94
 NEXTJ
 UNTIL SS=0
 RETURN
combat_85
 REM TRI SAC
 FOR I=1TO5
 IF SAD(AO(P),I)>0 THEN  combat_95 
 IF SAD(AO(P),I+1)>0 THEN SAD(AO(P),I)=SAD(AO(P),I+1):SAD(AO(P),I+1)=0
combat_95
 NEXT I
 RETURN
combat_28
 REM ARMES
 IF AU(AO(P))>19 THEN ARM=3:TST=3:ACT$=" lache "+IT$(BT(AO(P)))+" Sur ":GOTO  combat_96 
 IF AU(AO(P))>7  AND AU(AO(P))<15 OR AU(AO(P))=19 THEN TST=1:ARM=1:GOTO  combat_96 
 IF AU(AO(P))>14 AND AU(AO(P))<18 THEN TST=2:ARM=2
 IF AU(AO(P))=15 THEN ACT$=" decoche un carreau sur ":DFF=20:GOTO  combat_96 
 IF AU(AO(P))=16 THEN ACT$=" decoche une fleche sur ":DFF=10:GOTO  combat_96 
 IF AU(AO(P))=17 THEN ACT$=" projete un caillou sur ":DFF=-5:GOTO  combat_96 
 IF AU(AO(P))=18 THEN TST=3:DFF=15:ARM=4:ACT$=" lance son filet sur "
combat_96
 RETURN
combat_31
 REM EFFET ARME
 IF C6OK(TG(AO(P)))>4 OR VE(AO(P))> 80 THEN RT=1
 IF RT=0 THEN PING:PRINT@15,14;" et loupe ! ":GOTO  combat_97 
 SS=VIL+FNA(5)+BF(AO(P))
 IF EF(AO(P))>0 THEN SS=SS+((1+FNA(2))*(BF(AO(P))))
 IF C6OK(TG(AO(P)))>4 THEN SS=SS+C2PV(TG(AO(P)))
 C2PV(TG(AO(P)))=C2PV(TG(AO(P)))-SS
 PRINT @12,14;"lui inflige "SS" pv  "
 IF C2PV(TG(AO(P))) <= 0 THEN MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_98 
combat_97
 WAIT 15*TI
 RETURN
combat_32
 REM NET
 IF RT=1 THEN C6OK(TG(AO(P)))=6:S$=" ENNEMI PRIS AU FILET !":FU=1 ELSE S$="Le filet rate sa cible"
 PRINT @8,14;S$:WAIT 10*TI:IF RT=1 THEN GOSUB  combat_11 
 RETURN
combat_30
 REM + TESTS > D100
 SS=FNA(100):RT=0
 ON TST GOTO  combat_99 , combat_100 , combat_101 , combat_102 , combat_103 
combat_99
 REM Combat
 IF ESP(AO(P))=0 THEN  combat_104 
 IF SS < CC(AO(P))  + DFF THEN RT=1:GOTO  combat_105 
combat_104
 IF SS < C3CC(AO(P)) +DFF THEN RT=1
combat_105
 RETURN
combat_100
 REM Tir
 IF ESP(AO(P))=0 THEN  combat_106 
 IF SS<CT(AO(P))  +DFF THEN RT=1:GOTO  combat_107 
combat_106
 IF SS<C3CC(AO(P))+DFF THEN RT=1
combat_107
 RETURN
combat_101
 REM Agilite
 IF ARM=3 THEN IF SS < AANIM(AO(P))+DFF THEN RT=1:GOTO  combat_108 ' Test pour animal de combat
 IF ESP(AO(P))=1 THEN IF SS<AGI(AO(P))+DFF THEN RT=1:GOTO  combat_108 
 IF ESP(AO(P))=0 THEN IF SS<C1AG(AO(P))+DFF THEN RT=1
combat_108
 RETURN
combat_102
 REM QI
 IF ESP(AO(P))=0 THEN  combat_109 
 IF SS<IN(AO(P)) +DFF THEN RT=1:GOTO  combat_110 
combat_109
 IF SS<C5QI(AO(P))+DFF THEN RT=1
combat_110
 RETURN
combat_103
 REM FM
 IF ESP(AO(P))=0 THEN  combat_111 
 IF SS<FM(AO(P))+DFF THEN RT=1:GOTO  combat_112 
combat_111
 IF SS<C5QI(AO(P))+DFF THEN RT=1
combat_112
 RETURN
 REM ENNEMIS
combat_37
 REM filet
combat_37
 S$=MM$(MO(AO(P)))
 PRINT @2,10;CHR$(129);S$;" tente de se liberer ":WAIT TI*5
 TST=3:DFF=-30:GOSUB  combat_30 :WAIT 8*TI
 IF RT=0 THEN S$=S$+" reste prisonnier " ELSE S$=S$+" se degage du filet "
 PRINT @2,12;CHR$(129);S$:WAIT 8*TI
 IF RT=1 THEN FU=0:C6OK(AO(P))=1:ZAP:GOSUB  combat_11 
 GOSUB  combat_8 
 RETURN
combat_38
 REM ATTAQUE  ENNEMIS
combat_113
 TE=FNA(6):IF OK(TE)=4 THEN  combat_113 
 TE$=N$(TE):SS$=" attaque ":TST=1
 IF MO(AO(P))>14 THEN IF FNA(10)>7 THEN SS$=" jette un sort sur":TST=4:IF MO(AO(P))> 20 THEN TE$="l'equipe"
 L=10:S$=CHR$(129)+MM$(MO(AO(P)))+SS$:GOSUB  combat_29 :ZAP
 L=12:S$=CHR$(129)+TE$:GOSUB  combat_29 :WAITTI*10
 DFF=(2*VIL)+FNA(10):GOSUB  combat_30 :IF RT=0 THEN SS$="et loupe": GOTO  combat_114 
 IF TST=4 THEN GOTO  combat_115 
 SS=1+VIL+FNA(VIL)+CM(AO(P),4)-BC(TE)-PRD(TE):REM *** FORMULE ATTAQUE MONSTRE ***
 IF SS<=0 THEN SS$="l'armure resiste !":GOTO  combat_114 
combat_122
 SS$="lui inflige "+STR$(SS)+" pv"
 ET(TE)=ET(TE)-SS:ZAP:WAIT TI*5
 IF ET(TE)<=0 THEN ET(TE)=0:OK(TE)=4:HV=HV-1
combat_114
 L=14:S$=SS$:GOSUB  combat_29 :WAITTI*5
 IF OK(TE)=4 THEN PRINT @15,16;"et meurt...":EXPLODE
 GOSUB  combat_7 
 GOTO  combat_116 
combat_115
 REM SORTS faibles
 IF MO(AO(P)) > 20 THEN  combat_117 
combat_124
 IF FNA(10)>6 THEN SM=FNA(4)ELSE SM=1
 ON SM GOTO  combat_118 , combat_119 , combat_120 , combat_121 
combat_118
 FOR I=1TO13:PRINT@3+I,12;CHR$(129);"*":WAIT3:NEXT:SHOOT
 SS=6+FNA(VIL)-INT(FM(TE)/10):GOTO  combat_122 
 GOTO  combat_123 
combat_119
 IF OK(TE)=1 THEN SS$="il l'empoisonne":OK(TE)=2 ELSE  combat_124 
 GOTO  combat_123 
combat_120
 IF OK(TE)=1 THEN SS$="ses muscles ne repondent plus":OK(TE)=3 ELSE  combat_124 
 GOTO  combat_123 
combat_121
 SS$="son armure diminue":BC(TE)=BC(TE)-1-FNA(2)
 IF BC(TE)<0 THEN BC(TE)=0
combat_123
 L=14:S$=SS$:GOSUB  combat_29 :WAITTI*12
 GOTO  combat_116 
combat_117
 REM SORTS forts
 SM=FNA(5)
 GOSUB  combat_8 
 L=9:S$=SM$(SM):GOSUB  combat_29 :ZAP:WAITTI*20:LL=10
 IF SM=4 THEN MALUS=MALUS+1+FNA(2):GOTO  combat_116 
 IF SM=5 THEN GOSUB  combat_125 :GOTO  combat_116 
 FORJ=1TO6
 IF OK(J)=4 THEN  combat_126  ELSE LL=LL+1
 IF SM > 1 THEN  combat_127 
 BC(J)=BC(J)-1-FNA(2)
 IF BC(J)<0 THEN BC(J)=0
 S$=" "+STR$(BC(J))+" "
 PRINT@35,19+J;S$:GOTO  combat_126 
combat_127
 SS=VIL+2+FNA(4)+CM(AO(P),4)
 IF CP(J)>3 THEN SS=SS-INT(QI(J)*2/10):IF SS<=0 THEN SS=1
 PRINT @5,LL;N$(J);" perd ";SS;" pv":ET(J)=ET(J)-SS
 IF ET(J)<=0 THEN ET(J)=0:OK(J)=4:HV=HV-1
 IF OK(J)=4 THEN PRINT @30,LL;"et meurt!":EXPLODE
 WAITTI*5
 GOSUB  combat_7 
combat_126
 NEXTJ
combat_116
 RETURN
combat_125
 REM SOINS
 L=11
 FOR J=1TONE
 S$=" est gueri"
 IF C6(J)<2 OR C6(J)>3 THEN  combat_128 
 C6(J)=1:C2=C2+5+FNA(8)
 S$=MM$(MO(J))+S$:GOSUB  combat_29 :WAIT TI*8:L=L+1
combat_128
 NEXTJ
 GOSUB  combat_11 
 RETURN
combat_42
 REM RECOMPENSES
 CLS:POKE#26A,PEEK(#26A) AND 254
 ENC=4:S$="BILAN DE LA BATAILLE":L=22:GOSUB  combat_129 
 PING:PRINT@9,4;"!  VOUS AVEZ VAINCU  !"
 PRINT@4,6;"Chaque survivant gagne au moins:"
 XP=DC*5:PO=DC*3:PRINT@6,8;"> Points:";XP
 PRINT@6,9;"> Argent:";PO;"ca"
 FU=0
 FOR P=1TO6
 IF OK(P)>2 THEN  combat_130 
 XP(P)=XP(P)+XP+(MT(P)*20)+FNA(10*VIL)
 RI(P)=RI(P)+PO+(MT(P)*25)+FNA(10*VIL)
combat_130
 IF MT(P)< NE THEN  combat_131 
 S$="Bravo a "+N$(P):L=11:GOSUB  combat_29 :WAITTI*8
 S$="Tueur de tous les ennemis":L=12:GOSUB  combat_29 :WAITTI*12
 PRIME=(NE*100)+FNA(DC*20)
 S$="Voila une prime de"+STR$(PRI)+" ca":L=14:GOSUB  combat_29 :WAITTI*12
 RI(P)=RI(P)+PRI:XP(P)=XP(P)+XP+(MT(P)*20)+FNA(10*VIL)
 L=16:GOSUB  combat_5 :GOSUB  combat_132 
combat_131
 IF XP(P)>1000+(VIL*150) AND NI(P)<21 AND OK(P)<>4 THEN GOSUB  combat_133 
 NEXT P
 L=18:S$="DECAMPEZ MAINTENANT":GOSUB  combat_29 
 L=21:GOSUB  combat_5 
 PING
 CA=0
combat_62
 GOSUB  combat_134 
combat_44
 PRINT OUT
 IF OUT=1 THEN LOAD("MAP") ELSE LOAD("LABY")
combat_133
 REM PROMOTION NEW
 NI(P)=NI(P)+1:XP(P)=0:FORJ=1TO5:PING:WAIT2*J:NEXT
 S$=CHR$(145)+C$(CP(P))+" "+N$(P)+" "+CHR$(144)+CHR$(132):L=11:GOSUB  combat_29 
 S$=" passe au niveau:"+STR$(NI(P)):L=12:GOSUB  combat_29 
 S$="Et gagne qqs PV !":L=13:GOSUB  combat_29 :WAITTI*8
 S$=" 1   2   3   4   5   6"
 PLOT 7,15,S$
 S$="CC  CT  Fo  Ag  In  FM  "
 PRINT@6,16;CHR$(145)CHR$(135);S$;CHR$(144)CHR$(132)
 S$=STR$(CC(P))+" "+STR$(CT(P))+" "+STR$(FO(P))+" "+STR$(AG(P))+" "+STR$(IN(P))+" "+STR$(FM(P))
 PLOT 7,17,S$
 PRINT @5,19;"Augmenter quelle carac (1-6) ?"
 GOSUB  combat_6 :PROMO=5+FNA(4)
 IF A=1 THEN CC(P)=CC(P)+PRO:IFCC(P)>99THENCC(P)=99:GOTO  combat_135 
 IF A=2 THEN CT(P)=CT(P)+PRO:IFCT(P)>99THENCT(P)=99:GOTO  combat_135 
 IF A=3 THEN FO(P)=FO(P)+PRO:IFFO(P)>99THENFO(P)=99:GOTO  combat_135 
 IF A=4 THEN AG(P)=AG(P)+PRO:IFAG(P)>99THENAG(P)=99:GOTO  combat_135 
 IF A=5 THEN IN(P)=IN(P)+PRO:IFIN(P)>99THENIN(P)=99:GOTO  combat_135 
 IF A=6 THEN FM(P)=FM(P)+PRO:IFFM(P)>99THENFM(P)=99
combat_135
 S$=STR$(CC(P))+" "+STR$(CT(P))+" "+STR$(FO(P))+" "+STR$(AG(P))+" "+STR$(IN(P))+" "+STR$(FM(P))
 PLOT 7,18,S$
 PV(P)=PV(P)+FNA(3)+4:IFPV(P)>99THENPV(P)=99
 L=21:GOSUB  combat_5 :GOSUB  combat_132 
 RETURN
 'FOR J=1TO11:PRINT @3,10+J;"                                    ":NEXTJ
 'RETURN
combat_74
 L=11:S$=CHR$(130)+N$(AO(P))+" Soigne "+N$(TG((AO(P))))
 GOSUB  combat_29 :GOSUB  combat_136 :WAITTI*5
 L=14:GOSUB combat_29 
 RETURN
combat_79
 REM Potion divine: Mise en majuscule du prenom
 L=10:S$=N$(AO(P))+" utilise Potion divine ":GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" a une force de colosse":GOSUB  combat_29 
 FC(TG(AO(P)))=50+FNA(VIL*6):GOSUB combat_137 
 PD=1:PP=1
 S$=N$(TG((AO(P)))):N$(TG((AO(P))))=LEFT$(S$,1)
 FORI=2TOLEN(S$)
 MJ=ASC(MID$(S$,I,1))
 IF MJ>96 AND MI<123 THEN MJ=MJ-32
 L$=CHR$(MJ)
 N$(TG((AO(P))))=N$(TG((AO(P))))+L$
 NEXT
 RETURN
combat_41
 REM Mise en minuscule des prenoms
 FORP=1TO6
 S$=N$(P):N$(P)=LEFT$(S$,1)
 FORI=2TOLEN(S$)
 MI=ASC(MID$(S$,I,1))
 IF MI>64 AND MI<91 THEN MI=MI+32
 L$=CHR$(MI)
 N$(P)=N$(P)+L$
 NEXTI
 NEXTP
 RETURN
combat_76
 L=10:S$=N$(AO(P))+" utilise Essence Vitale":GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" revient a la vie":GOSUB  combat_29 
 RETURN
combat_78
 L=10:S$=N$(AO(P))+" utilise "+IT$(24):GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" est Invincible !":GOSUB  combat_29 
 BC(TG(AO(P)))=50:ET(TG(AO(P)))=PV(TG(AO(P)))
 RETURN
combat_137
 I=0'recherche indice du heros dope par potion ebene
 REPEAT
 I=I+1
 UNTIL AO(I)=TG(AO(P)) AND ESP(I)=1 ' OR I=6+NE
 VE(I)=90
 RETURN
combat_191
 FORJ=1TONE'monstres congele = perte de vitesse
 IF ESP(J)=1THEN  combat_138 
 VE(J)=VE(J)-5
combat_138
 NEXTJ
 GOSUB  combat_39 
 RETURN
combat_57
 REM SORTS
 GOSUB  combat_8 :SS=NI(P):IFSS>8THENSS=8
 PRINT @14,8;CHR$(129);" < MAGIE > ";CHR$(144)
 FOR I=1TOSS:PRINT@12,I+9;I;"- ";SPELL$(CP(P)-3,I)
 S$="("+STR$(SN(P,I))+" )":PRINT @26,I+9;S$:NEXT
 PRINT @5,9;"Aucun - 0":
combat_139
 GETA$:CH=VAL(A$):IF CH>NI(P) THEN  combat_139 
 IF CH=0 THEN GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_140 
 IF SN(P,CH)=0 THEN PING:GOTO  combat_139 
 SPELL(P)=CH
 ON CP(P)-3 GOTO  combat_141 , combat_142 , combat_143 
combat_141
 IF CH >6  THEN  combat_144 
 GOSUB  combat_67 :GOTO  combat_144 
combat_142
 IF CH=5 OR CH=6 THEN  combat_144 
 IF CH<>8 THEN GOSUB  combat_69  ELSE GOSUB  combat_67 
 GOTO  combat_144 
combat_143
 IF CH>3 THEN  combat_144 
 IF CH=3 AND AMI>0 THEN GOSUB  combat_71 :GOTO  combat_139 
 RT=0
 FORJ=1TO6:IFWR(J)>14ORWL(J)>14THENRT=1
 NEXTJ
 IFRT=0THENGOSUB combat_71 :GOTO combat_57 
combat_147
 IFCH<3THENGOSUB combat_69 ELSEGOSUB combat_67 
 IFCH<>1THEN combat_144 
 IFWR(TG(P))=0THEN combat_145 
 IF WR(TG(P))>14 AND (WL(TG(P))=0 OR WL(TG(P))>14) THEN  combat_145 
 GOTO  combat_146 
combat_145
 GOSUB  combat_71 :GOTO  combat_147 
combat_146
 GOSUB  combat_148 
combat_144
 GOSUB  combat_7 
combat_140
 RETURN
combat_148
 GOSUB  combat_8 
 IF WL(TG(P))=0 THEN A=1:GOTO  combat_149  ELSE PRINT @4,10; "Enchanter Laquelle ?"
 PRINT @3,12;CHR$(132);"1.D:";IT$(WR(TG(P)));CHR$(131)
 PRINT @3,13;CHR$(132);"2.G:";IT$(WL(TG(P)));CHR$(131)
combat_150
 GET A$:A=VAL(A$):IF A<>1 AND A<>2 THEN  combat_150 
combat_149
 EF(TG(P))=A:IF A=1 THEN EF=WR(TG(P)) ELSE EF=WL(TG(P))
 IF EF>14 THEN GOSUB  combat_71 :GOTO  combat_148 
 RETURN
combat_34
 REM EXECUTION SORTS
 H=CP(AO(P))-3
 L=10:S$=CHR$(134)+N$(AO(P))+" Invoque "+SPELL$(H,SP(AO(P))):GOSUB  combat_29 
 SN(AO(P),SP(AO(P)))=SN(AO(P),SP(AO(P)))-1
 ON H GOTO  combat_151 , combat_152 , combat_153 
combat_151
 IF SP(AO(P))<7 AND C6OK(TG(AO(P)))=0 THEN  combat_154 
 IF SP(AO(P))<7 THEN S$=" sur  "+MM$(MO(TG(AO(P)))) ELSE S$="sur les ennemis"
 L=12:GOSUB  combat_29 :WAIT TI*10:S$="loupe son invocation"
 ON SPELL(AO(P)) GOSUB  combat_155 , combat_156 , combat_157 , combat_158 , combat_159 , combat_160 , combat_161 , combat_162 
 GOTO  combat_154 
combat_152
 IF SP(AO(P))<7 AND OK(TG(AO(P)))=4 THEN  combat_154 
 IF SP(AO(P))<5 OR SP(AO(P))=7 THEN S$=" sur  "+N$(TG(AO(P)))
 IF SP(AO(P))=5 OR SP(AO(P))=6 THEN S$=" sur  l'equipe"
 IF SP(AO(P))=8 THEN IF C6OK(TG(AO(P)))<>0 THEN S$=" sur "+ MM$(MO(TG(AO(P)))) ELSE  combat_154 
 L=12:GOSUB  combat_29 :WAIT TI*10
 ON SPELL(AO(P)) GOSUB  combat_163 , combat_164 , combat_165 , combat_166 , combat_167 , combat_168 , combat_169 , combat_170 
 GOSUB  combat_171 :GOSUB  combat_7 :GOSUB  combat_8 
 GOTO  combat_154 
combat_153
 IF SP(AO(P))=2 THEN S$=" sur "+ N$(TG((AO(P))))
 IF SP(AO(P))=3 THEN IF C6OK(TG(AO(P)))<>0 THEN S$=" sur "+ MM$(MO(TG(AO(P)))) ELSE  combat_154 
 IF SP(AO(P))=2 OR SP(AO(P))=3 THEN L=12:GOSUB  combat_29 :WAIT TI*10
 IF SP(AO(P))=8 AND SD<>AO(P) THEN S$=" Et la selle ? ":L=12:GOSUB  combat_29 :GOTO combat_154 
 S$="loupe son invocation"
 ON SPELL(AO(P)) GOSUB  combat_172 , combat_173 , combat_174 , combat_175 , combat_176 , combat_177 , combat_178 , combat_179 
combat_154
 RETURN
 REM SORCIER
combat_155
 REM 1,1
 TST=4:DFF=20:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 C6OK(TG(AO(P)))=5:S$="pique un roupillon...ZZZzzz":GOSUB  combat_171 
 RETURN
combat_156
 REM 1,2  FEU
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 ZAP:FORI=1TO5:PAPER1:WAIT10:PAPER3:WAIT15:NEXT:PAPER0:EXPLODE
 SS=FNA(5)+3:C2PV(TG(AO(P)))=C2PV(TG(AO(P)))-SS
 S$=MM$(MO(TG((AO(P)))))+" perd "+STR$(SS)+" PV":GOSUB  combat_171 
 IF C2PV(TG(AO(P)))<=0 THEN MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_98 
 RETURN
combat_157
 REM 1,3  PIERRE
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 S$="se transforme en pierre":GOSUB  combat_171 
 S$=MM$(MO(TG((AO(P))))):GOTO  combat_98 
combat_158
 REM 1,5 VENIN
 TST=5:DFF=40:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 C6OK(TG(AO(P)))=2:S$="le poison va faire son effet"
 GOTO  combat_171 
combat_159
 REM 1,4 : SANG
 TST=5:DFF=15:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 C6OK(TG(AO(P)))=3:S$="saigne inexorablement"
 GOTO  combat_171 
combat_160
 REM 1,6 FOUDRE
 TST=4:DFF=30:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 S$="Est reduit en cendres !":GOSUB  combat_171 
 MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_98 
combat_161
 REM 1,7 LAVE
 TST=5:DFF=35:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 S$="Et une pluie de lave, Une!!!":GOSUB  combat_171 :GOSUB  combat_8 
 DG=10:GOSUB  combat_180 :RETURN
combat_162
 REM 1,8 SEISME
 TST=5:DFF=40:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 EXPLODE:WAIT60:SHOOT
 S$="La terre s'ouvre et les engloutit!":GOSUB  combat_171 :GOSUB  combat_8 
 DG=20:GOSUB  combat_181 :RETURN
 REM  MESTRE
combat_163
 REM 2,1 EAU
combat_136
 GOSUB  combat_182 
 S$="Il va un peu mieux"
 RETURN
combat_164
 REM 2,2 SERUM
 IF OK(TG(AO(P)))<>2 THEN S$="et non ! relisez votre grimoire":GOTO  combat_183 
 OK(TG(AO(P)))=1:S$="Le poison est detruit"
combat_183
 RETURN
combat_165
 REM 2,3 MUSCLE
 IF OK(TG(AO(P)))<>3 THEN S$="et non ! relisez votre grimoire":GOTO  combat_184 
 OK(TG(AO(P)))=1:S$="Muscles a nouveau au top !"
combat_184
 RETURN
combat_166
 REM 2,4 BOUCLIER
 BC(TG(AO(P)))=BC(TG(AO(P)))+FNA(3)+2
 S$="Un bouclier magique !"
 RETURN
combat_167
 REM 2,5 ELIXIR
 FORI=1TO6
 IF OK(I)<>4 THEN ET(I)=PV(I)
 NEXT
 S$="Une equipe en pleine forme !"
 RETURN
combat_168
 REM 2,6 ECRAN
 FORI=1TO6:BC(I)=10:NEXT
 S$="Protection maximale !"
 RETURN
combat_169
 REM 2,7 VIE
 IF OK(TG(AO(P)))<>4 THEN   combat_185 
 OK(TG(AO(P)))=1:ET(TG(AO(P)))=PV(TG(AO(P))):HV=HV+1
 S$="une renaissance !"
combat_185
 RETURN
combat_170
 REM 2,8 MORT
 IF C6OK(TG(AO(P)))=0 THEN  combat_186 
 TST=5:DFF=50:GOSUB  combat_30 :IF RT=0 THEN S$="loupe son invocation":GOTO  combat_186 
 GOSUB  combat_187 
 S$="Une belle mort !"
combat_186
 RETURN
 REM SEPTON
combat_172
 REM 3.1 EPEE-FEU
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN EF(TG((AO(P))))=0:GOTO  combat_171 
 IF EF(TG((AO(P))))=1 THEN EF=WR(TG((AO(P)))) ELSE EF=WL(TG((AO(P))))
 WAIT TI*10:L=12:S$="sur "+IT$(EF)+" de "+N$(TG((AO(P)))):GOSUB  combat_29 
 ZAP:PAPER1:WAIT TI*10:EXPLODE:PAPER0
 S$="...qui s'enflamme ...":GOSUB  combat_171 :WAIT TI*8:GOSUB  combat_8 
 RETURN
combat_173
 REM 3.2 FORCE
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 IF OK(TG(AO(P)))=4 THEN  combat_188 
 S$=" sa force grandit ":PRINT @12,14;S$:WAIT TI*10
 FC(TG(AO(P)))=FC(TG(AO(P)))+FNA(VIL)+5
combat_188
 RETURN
combat_174
 REM 3.3 CHARME
 TST=5:DFF=10:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 AMI=TG(AO(P)):C6OK(AMI)=4:EV=EV-1
 S$="Et voila un nouvel ami ;-)":PRINT @5,14;S$:WAIT TI*15
 RETURN
combat_175
 REM 3.4 VISION ZOMAN
 TST=4:DFF=50:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 PRINT @10,12;" utilise la vision Zoman ":ZO=1:GOSUB  combat_11 :WAIT TI*12
 RETURN
combat_176
 REM 3.5 GLACE
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
combat_82
 ECHEC=0:L=13:PRINT @10,12;" Le souffle du Nord  !! ":WAIT TI*10
 FORI=1TONE
 IF C6OK(I)<1 THEN  combat_189 
 SS=FM(AO(P))-C5(I)+FNA(VIL):L=L+1
 IFSS<3THENEC=EC+1:S$=MM$(MO(I))+" se marre":GOTO  combat_190 
 C2(I)=C2(I)-SS:S$=MM$(MO(I))+" gele: -"+STR$(SS)+"pv"
 GOSUB  combat_92 :GOSUB  combat_191 
combat_190
 PRINT@3,L;S$:WAITTI*5
combat_189
 NEXTI
 WAITTI*20:IFEC=EVTHENGOSUB  combat_132 :PRINT@3,15;"Ha Ha Ha un Mental de minus !!"
 GOSUB  combat_11 
 RETURN
combat_177
 REM 3.6 ILLUSION
 TST=5:DFF=30:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 L=12:PRINT @5,L;"Projete un monstre imaginaire ":WAIT TI*15
 WIN$=" ricane":LOST$=" s'enfuit"
 GOSUB  combat_192 
 RETURN
combat_178
 REM 3,7 VENT
 PRINT @10,12;"la horde !":WAIT TI*8
 TST=5:DFF=35:GOSUB  combat_30 :IF RT=0 THEN  combat_171 
 EXPLODE:WAIT60:SHOOT
 S$="Une tornade balaie la horde!":GOSUB  combat_171 :GOSUB  combat_8 
 DG=6:GOSUB  combat_181 
 RETURN
combat_179
 REM 3,8 DRAGONS
 DR=1
 S$="Un Dragon se joint a vous":GOSUB  combat_171 :GOSUB  combat_8 
 RETURN
combat_21
 GOSUB  combat_8 :S$=CHR$(129)+"! le Dragon se dechaine ! "
 T=INT((41-LEN(S$))/2):PRINT@T,10;S$:WAIT TI*15
 DG=20:GOSUB  combat_180 
 RETURN
combat_171
 L=14:GOSUB  combat_29 :WAIT TI*10
 GOSUB  combat_11 
 RETURN
combat_35
 REM (CHARME)
 GOSUB  combat_8 :S$=CHR$(134)+" VOTRE AMI: "+MM$(MO(AMI)):T=INT((41-LEN(S$))/2)
 PRINT @T,7;S$:S$=CHR$(134)+MM$(MO(AMI))+" Attaque la horde "
 T=INT((41-LEN(S$))/2):PRINT@T,10;S$:WAIT TI*15
 TE=FNA(NE)
combat_194
 IF C6OK(TE)<>0 AND C6OK(TE)<>4 THEN  combat_193 
 IFTE<NETHENTE=TE+1ELSETE=1
 GOTO  combat_194 
combat_193
 SS=FNA(6)+2+C4(AMI):IFC6OK(TE)>4THENSS=SS*2
 PRINT @4,12;MM$(MO(TE));" perd ";SS;" pv";:WAIT TI*15
 C2(TE)=C2(TE)-SS:IF C2(TE)<0 THEN C2(TE)=0:C6(TE)=0:GOTO  combat_195 
 RETURN
combat_192
 REM TEST Oppose
 FORJ=1TONE
 IF C6OK(J)=4 OR C6OK(J)=0 OR C6OK(J)=6 THEN  combat_196 
 L=L+1:SS=FNA(100):PRINT@4,8;"SS: ";SS;"QI: ";C5(J)
 IF SS<C5QI(J) THEN RT=1:SS$=MM$(MO(J))+WIN$:GOTO  combat_197 
 SS$=MM$(MO(J))+LOST$:EV=EV-1:C6OK(J)=0:C2(J)=0:MT(AO(P))=MT(AO(P))+1
combat_197
 PRINT @5,L;SS$:WAIT TI*15
combat_196
 NEXTJ
 GOSUB  combat_11 
 RETURN
 REM ACTION ORDER (pour la dev)
 TEXT:CLS
 PRINT"AO  VE  AG       FC":PRINT
 FORI=1TONE+6
 IF ESP(I)=0 THEN  combat_198 
 PRINTI;VE(I);AG(AO(I));N$(AO(I));FC(AO(I)):GOTO  combat_199 
combat_198
 PRINTI;VE(I);C1(AO(I));MM$(MO(AO(I)))
combat_199
 NEXTI
 PRINT:PRINT"Quitter:R"
combat_200
 GETA$:IFA$<>"R"THEN combat_200 
 RETURN
combat_98
 REM ENNEMI MORT
 PRINT @15,16;S$;" meurt ":EXPLODE:WAIT 5*TI
combat_187
 IF C6OK(TG(AO(P)))=6 THEN FU=0
 IF C6OK(TG(AO(P)))=4 THEN AMI=0
 C2PV(TG(AO(P)))=0:C6OK(TG(AO(P)))=0
combat_195
 EV=EV-1
 GOSUB  combat_11 ' affichage monstres
 RETURN
 REM Lecture TITEMS.BIN
combat_1
 CLS:PRINT @ 8,12;CHR$(145);CHR$(135);"++ VEUILLEZ PATIENTER ++ ";CHR$(144):
 DIM ITEM$(55), CM(23,5)
 LOAD "TITEMS.BIN"
 O1=#A000
 LI=PEEK(O1)
 REM PRINT "LG IT:";LI
 FOR I=1 TO LI
 O1=O1+1:LG=PEEK(O1)
 S$=""
 IF LG=0 THEN  combat_201 
 FOR J=1 TO LG
 O1=O1+1:S$=S$+CHR$(PEEK(O1))
 NEXT
combat_201
 ITEM$(I)=S$
 REM PRINT "ITEM ";I;" = ";ITEM$(I)
 NEXT
 REM Lecture TMONST.BIN
 LOAD "TMONST.BIN"
 O1=#A000
 LI=PEEK(O1)
 O1=O1+1:LG=PEEK(O1)
 FOR I=1TOLI
 FOR J=1TO LG
 O1=O1+1:CM(I,J)=PEEK(O1)
 NEXTJ
 NEXTI
 RETURN
combat_0
 GOSUB combat_202  ' chargement
 REM LOAD"TEAM.BIN"
 O1=#A000
 O1=O1+1:VIL=PEEK(O1)
 PRINT"version " VIL
 O1=O1+1:X=PEEK(O1)
 O1=O1+1:Y=PEEK(O1)
 O1=O1+1:S=PEEK(O1)
 O1=O1+1:CA=PEEK(O1)
 O1=O1+1:VIL=PEEK(O1)
 PRINT"Ville " VIL "X " X "Y " Y "S " S "CA " CA
 FOR P=1TO6
 O1=O1+1:DD=PEEK(O1)
 FORJ=1TODD:O1=O1+1:N$(P)=N$(P)+CHR$(PEEK(O1)):NEXTJ
 O1=O1+1:RI(P)=DEEK(O1)*10:O1=O1+2:CP(P)=PEEK(O1)
 O1=O1+1:MP(P)=PEEK(O1)
 O1=O1+1:CC(P)=PEEK(O1)
 O1=O1+1:CT(P)=PEEK(O1)
 O1=O1+1:FO(P)=PEEK(O1)
 O1=O1+1:AG(P)=PEEK(O1)
 O1=O1+1:IN(P)=PEEK(O1)
 O1=O1+1:FM(P)=PEEK(O1)
 O1=O1+1:PV(P)=PEEK(O1):GOSUB combat_203 
 O1=O1+1:ET(P)=PEEK(O1)
 O1=O1+1:OK(P)=PEEK(O1)
 O1=O1+1:NI(P)=PEEK(O1)
 O1=O1+1:XP(P)=DEEK(O1)
 O1=O1+2:WR(P)=PEEK(O1)
 O1=O1+1:WL(P)=PEEK(O1)
 O1=O1+1:PT(P)=PEEK(O1)
 O1=O1+1:CA(P)=PEEK(O1)
 O1=O1+1:BT(P)=PEEK(O1)
 FORI=1TO6:O1=O1+1:SAD(P,I)=PEEK(O1):NEXTI
 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:SN(P,I)=PEEK(O1):NEXT
 GOSUB combat_203 :NEXT P
 O1=O1+1:BS=PEEK(O1)
 O1=O1+1:FI=PEEK(O1)
 O1=O1+1:SD=PEEK(O1):GOSUB combat_203 
 FOR V=1TO9:FOR C=1TO4:O1=O1+1:CL(V,C)=PEEK(O1):NEXT C,V
 FOR I=1TO6:O1=O1+1:IG(I)=PEEK(O1):NEXT
 FOR V=1TO9:FORM=1TO5:O1=O1+1:TC(V,M)=PEEK(O1):NEXT M,V:REM PRINT "FIN";TC(VILLE,1);O1;(O1-#A000)
 O1=O1+1:DE=PEEK(O1):GOSUB combat_203 
 O1=O1+1:TL=PEEK(O1):REM PRINT "TL";TL
 O1=O1+1:NP=PEEK(O1)
 O1=O1+1:NF=PEEK(O1)
 O1=O1+1:PM=PEEK(O1)
 O1=O1+1:OUT=PEEK(O1):GOSUB combat_203 :REM PRINT "OUT";OUT
 REM IF KEY$<> " " THEN 48349
 RETURN
combat_134
 CLS:PRINT @ 8,12;CHR$(148);CHR$(131);"++ RETOUR LABYRINTHE ++ ";CHR$(144)
 O1=#A000:GOSUB combat_204 
 O1=O1+1:POKEO1,1
 O1=O1+1:POKEO1,X
 O1=O1+1:POKEO1,Y
 O1=O1+1:POKEO1,S
 O1=O1+1:POKEO1,CA
 O1=O1+1:POKEO1,VIL
 FOR P=1TO6
 O1=O1+1:POKEO1,LEN(N$(P))
 FORJ=1TOLEN(N$(P)):O1=O1+1:POKEO1,ASC(MID$(N$(P),J,1)):NEXT
 O1=O1+1:DOKEO1,INT(RI(P)/10)
 O1=O1+2:POKEO1,CP(P)
 O1=O1+1:POKEO1,MP(P)
 O1=O1+1:POKEO1,CC(P)
 O1=O1+1:POKEO1,CT(P)
 O1=O1+1:POKEO1,FO(P)
 O1=O1+1:POKEO1,AG(P)
 O1=O1+1:POKEO1,IN(P)
 O1=O1+1:POKEO1,FM(P)
 O1=O1+1:POKEO1,PV(P)
 O1=O1+1:POKEO1,ET(P):GOSUB combat_203 
 O1=O1+1:POKEO1,OK(P)
 O1=O1+1:POKEO1,NI(P)
 O1=O1+1:DOKEO1,XP(P)
 O1=O1+2:POKEO1,WR(P)
 O1=O1+1:POKEO1,WL(P)
 O1=O1+1:POKEO1,PT(P)
 O1=O1+1:POKEO1,CA(P)
 O1=O1+1:POKEO1,BT(P)::GOSUB combat_203 
 FORI=1TO6:O1=O1+1:POKEO1,SAD(P,I):NEXTI
 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:POKEO1,SN(P,I):NEXT
 NEXT P
 O1=O1+1:POKEO1,BS
 O1=O1+1:POKEO1,FI
 O1=O1+1:POKEO1,SD
 FOR V=1TO9:FOR C=1TO4:O1=O1+1:POKEO1,CL(V,C):NEXT C,V
 FORI=1TO6:O1=O1+1:POKEO1,IG(I):NEXT:GOSUB combat_203 
 FOR V=1TO9:FORM=1TO5:O1=O1+1:POKEO1,TC(V,M):NEXT M,V:REM PRINT "COMBATS";CO;TC(VILLE,1);O1;(O1-#A000)
 O1=O1+1:POKEO1,DE:GOSUB combat_203 
 O1=O1+1:POKEO1,TL
 O1=O1+1:POKEO1,NP
 O1=O1+1:POKEO1,NF
 O1=O1+1:POKEO1,PM
 O1=O1+1:POKEO1,OUT:GOSUB combat_203 
 PING:SAVEU "TEAM.BIN",A#A000,EO1
 CG=0
 RETURN
combat_202
 CLS:PRINT@6,8;".. Chargement * Patientez .."
 S$=CHR$(148)+" "+CHR$(144):CU=1:GOTO combat_203 
combat_204
 CLS:PRINT@6,8;"++ Sauvegarde + Patientez ++"
 S$=CHR$(145)+" "+CHR$(144):CU=1
combat_203
 CU=CU+2:PRINT@CU,9;S$
 RETURN
combat_3
 REM TABLEAUX
 TIME=10:DFF=0:ENC=6:GU$=CHR$(34)
 FOR I=1TO4:READ OK$(I):NEXTI
 DEF FNA(SS)=INT(RND(1)*SS)+1
 FORI=1TO6:READ C$(I):NEXTI:PRINT ".";
 FORI=1TO9:READ M$(I):NEXTI:PRINT ".";
 DIM IMPACT(19)
 FOR I=1TO 12:READ IMPACT(I):NEXTI
 FOR I=1TO6:READ AA(I),IA(I):NEXT I
 REM  Monstres
 READ NM:DIM MM$(NM)
 FORI=1TONM:READ MM$(I):NEXTI
 DIM AO(11),ESPECE(11),VE(11)
 FORH=1TO3:FORI=1TO8:READ SPELL$(H,I):NEXTI,H
 FORI=1TO5:READ SM$(I):NEXT
 RESTORE:RETURN
 DATA "OK","-Empoi- ","-Paral- ",">MORT< "
 DATA Chevalier,Mercenaire,Ranger,Sorcier,Mestre,Septon
 DATA Aucune,MARTELL,BARATHEON,TYRELL
 DATA GREYJOY,ARRYN,LANNISTER,TULLY,STARK
 DATA 7,6,5,5,4,4,3,3,2,2,1,1
 DATA 75,8, 70,6, 50,5, 80,4, 95,3, 55,2
 DATA 23,Rat mutant, Chien-loup, Chacal, Gobelin, Coupe-jarret, Gueux, Rodeur, Spadassin
 DATA Ogre, Dothrakhi, Geant, Sauvageon, Lion, Grizzly
 DATA Sorcier de Feu, Sombre Pretresse, Moine Fou
 DATA Druide-Demon, Esprit Noir, Septon Blanc
 DATA Elfe gris, Chevalier maudit, Marcheur blanc
 DATA SOMMEIL, FEU, PIERRE, VENIN, SANG,  FOUDRE, LAVE, SEISME
 DATA EAU, SERUM, MUSCLE, BOUCLIER, ELIXIR, ECRAN, VIE, MORT
 DATA EPEE-FEU, FORCE, CHARME, VISION, GLACE, ILLUSION, VENT, DRAGON
 DATA "j'abaisse votre garde !","** Boules de feu **","Pluie de lames !","Je detruis vos armes !","Je soigne mes amis"
