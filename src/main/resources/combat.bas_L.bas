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
 PLOT 8,6,"! MONSTERS ATTACK !":PING
 GOSUB  combat_3 
 GOTO  combat_4 
combat_128
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
 PRINT@14,L;" ";CHR$(145);"< SPACE > ";CHR$(144):GETA$:IFA$<>" "THEN combat_5 
 RETURN
combat_6
 GET A$:A=VAL(A$):IFA<1ORA>6THENPING:GOTO combat_6 
 RETURN
combat_70
 PING:PRINT @2,18;CHR$(148)" IMPOSSIBLE "CHR$(144)
 WAITTI*3:GOSUB  combat_7 
 ZAP:PRINT @2,18;"              "
 RETURN
combat_8
 FORII=1TO11:
 PRINT@1,7+II;CHR$(144)"                                         ":NEXTII
 RETURN
combat_131
 FOR J=1TO11
 PRINT @3,10+J;"                                   ":NEXTJ
 RETURN
combat_9
 GOSUB  combat_8 :PRINT @9,12;"Time (1-3) Now:";TI/5;:INPUT TI
 IF TI<1 OR TI>3 THEN PING:GOTO  combat_9 
 TI=5*TI
 RETURN
combat_4
 REM COMBATS
 T=15
 IF VIL > 2 THEN T=12
 IF VIL > 5 THEN T=7
 IF NC=2 THEN T=T-3
 IF NC=3 THEN T=T-5
 IF VIL > 7 THEN T=0
 NE=FNA(4)+1
 IF VIL<3 AND NE>3THEN NE=3
 EV=NE
 FOR I=1 TO NE
 SS=FNA(NM-T):MO(I)=SS
 C1AGI(I)=CM(SS,1)+FNA(VIL)*2
 C2PV(I)= CM(SS,2)+FNA(VIL*2)+NC*4:DC=DC+C2(I)
 C3CC(I)= CM(SS,3)+FNA(VIL)
 C4BF(I)= CM(SS,4)
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
 REPEAT
combat_18
 TEXT:CLS:INK6:POKE#26A,PEEK(#26A) AND 254
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
 PRINT @8,12;"CHANGE YOUR CHOICES (Y/N)?"
 PRINT @8,16;"CHANGE DISPLAY TIME: T"
combat_17
 GETR$:IF R$="" THEN  combat_17 
 IF R$="Y" OR R$="y" THEN  combat_18 
 IF R$="N" OR R$="n" THEN  combat_19 
 IF R$="T" OR R$="t" THEN GOSUB  combat_9 :GOTO  combat_20 
 PING:GOTO  combat_17 
combat_19
 REM tour
 IF DRAG>0 THEN DD=1:GOSUB  combat_21 
 FOR P=1TO6+NE
 ACT$=" attacks ":GOSUB  combat_8 
 PRINT@2,7;CHR$(145)"************** COMBAT ************** "CHR$(144)
 IF ESP(P)=0 AND EV>0 THEN GOTO  combat_22 
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
 'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  ":WAIT100
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
 GOTO  combat_23 
combat_22
 REM monstre
 IF C6OK(AO(P))>4 OR C6OK(AO(P))=0 THEN  combat_23 
 IF C6OK(AO(P))=4 AND EV>0 THEN GOSUB  combat_35 :GOTO  combat_36 
 IF C6OK(AO(P))=6 THEN GOSUB  combat_37 :GOTO  combat_23 
 IF HV>0 THEN GOSUB  combat_38  ELSE  combat_23 
 IF C6OK(AO(P))<2 OR C6OK(AO(P))>3 THEN  combat_36 
 C2(AO(P))=C2(AO(P))-FNA(C6(AO(P))*4)-2
 IF C2(AO(P))> 0 THEN  combat_23 
 IF C6OK(AO(P))=6 THEN FU=0
 C2(AO(P))=0:C6OK(AO(P))=0:EV=EV-1
 PRINT @15,16;MM$(MO(AO(P)));" dies ":EXPLODE:WAIT 5*TI
combat_36
 WAIT 15*TIME
combat_23
 NEXT P
 FOR I=1TO6:PRD(I)=0:NEXT
 GOSUB  combat_39 
combat_13
 UNTIL EV<1 OR HV<1
 IFBUG=1THENBUG=0:HIRES:ZAP:WAIT50:GOTO combat_40 
 FORP=1TO6:BC(P)=CA(P):NEXTP
 IFPD=1THEN GOSUB combat_41 :PD=0
 IF HV>0 THEN  combat_42 
 REM Defeat
 CLS:FORI=7TO0STEP-1:ZAP:WAIT10:PAPERI:NEXT:EXPLODE
 PRINT @6,8;" Your team is destroyed "
 PRINT @5,12;"1.Retry"
 PRINT @5,14;"2.Retreat"
 GOSUB  combat_7 
combat_43
 GETA$:IF A$<"1" OR A$>"2" THEN  combat_43 
 IF A$="1" THEN RELEASE : LOAD "LABY"
 CLS:PRINT@15,5;"Coward !":ZAP:RELEASE:END
 REM |SOUS PROGS
combat_11
 REM ENNEMIS
 FORI=1TO6:PRINT@1,I;"                               ":NEXT
 FORI=1TONE
 S$=STR$(I)+" "+MM$(MO(I)):C=3
 IF C6OK(I)=0 THEN S$=CHR$(149)+CHR$(128)+S$+" (DEAD) "+CHR$(144):C=1:GOTO  combat_44 
 ON C6OK(I) GOTO  combat_45 , combat_46 , combat_47 , combat_48 , combat_49 , combat_50 
combat_46
 C=2:S$=CHR$(130)+S$+" (Poison)"+STR$(C2(I)):GOTO  combat_44 
combat_47
 C=2:S$=CHR$(129)+S$+" (Bleed)"+STR$(C2(I)):GOTO  combat_44 
combat_48
 C=2:S$=CHR$(134)+S$+" (Friend)":GOTO  combat_45 
combat_49
 C=2:S$=CHR$(131)+S$+" (Asleep)":GOTO  combat_45 
combat_50
 C=2:S$=CHR$(132)+S$+" (-Net-)"
combat_45
 IF ZO=1 THEN S$=S$+CHR$(130)+STR$(C2(I))
combat_44
 PRINT@C,I;S$
 NEXTI
 RETURN
combat_7
 REM EQUIPE
 L=19:PRINT@1,L;CHR$(145)"CHARACTERS     CAREER     HP  ST  AC "
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
 REM INVENTARY
 L=7:E1=132:E2=132
 PRINT@2,L;CHR$(145)"*********************************** "CHR$(144)
 S$=" "+N$(P)+" - "+C$(CP(P))+" "
 T=INT((41-LEN(S$))/2)
 PRINT @T,L;S$:L=L+2
 IF EF(P)=0 THEN  combat_51  ELSE IF EF(P)=1 THEN E1=129 ELSE E2=129
combat_51
 PRINT @3,L;CHR$(E1);"1.R:";IT$(WR(P));CHR$(131):L=L+1
 PRINT @3,L;CHR$(E2);"2.L:";IT$(WL(P));CHR$(131):L=L+1
 PRINT @3,L;CHR$(132);"3.Anim:";:IF BT(P)>0 THEN PRINT IT$(BT(P));CHR$(131)
 OP(P)=0
 FORI=1TO6
 IF SAD(P,I)=0 THEN  combat_52 
 PRINT @2,L+I;CHR$(134);I+3;ITEM$(SAD(P,I));CHR$(131):OP(P)=OP(P)+1
combat_52
 NEXT I
 RETURN
combat_16
 REM CHOIX
 PRINT@29,9;CHR$(145)"ACTION "CHR$(144)
 IF WR(P)=0 AND WL(P)=0 AND BT(P)=0 THEN ARM=0 ELSE ARM=1
 IF ARM=1 THEN PRINT@29,11;CHR$(131)"A)TTACK"
 IF OP(P)>0 THEN PRINT@29,12;CHR$(131)"U)SE ITEM"
 PRINT@29,13;CHR$(131)"P)ARRY"
 IF CP(P)>3 THEN PRINT@29,14;CHR$(131)"S)PELL"
combat_57
 GET A$
 IF A$="A" AND ARM=1 THEN ACT(P)=1:GOTO  combat_53 
 IF A$="U" AND OP(P)>0 THEN ACT(P)=2:GOSUB  combat_54 :GOTO  combat_55 
 IF A$="P" THEN ACT(P)=3:PRD(P)=1+FNA(2):GOSUB  combat_7 :GOTO  combat_55 
 IF A$="S" AND CP(P)>3 THEN ACT(P)=4:GOSUB  combat_56 :IF CH=0 THEN  combat_16  ELSE  combat_55 
 GOTO  combat_57 
combat_55
 RETURN
combat_12
 REM FUITE
 FF=1:PRINT@15,12;CHR$(131)"FLEE Y/N"
combat_58
 GETA$
 IF A$="B" THEN BUG=1:RETURN
 IF A$<>"Y" AND A$<>"N" THEN  combat_58 
 IF A$="N" THEN  combat_59 
 TEST=(VIL*2)+FNA(40)+10+NF
 IF TEST>AG(FNA(6)) THEN NF=0:GOTO  combat_60 
 CLS:PRINT@13,8;CHR$(145)" YOU FLEE !!"CHR$(144)
 PRINT@13,10;"BACK TO MAZE":PRINT:NF=NF+20
 FORJ=1TO5:ZAP:WAIT5:NEXT:SHOOT:WAIT5
 GOSUB  combat_61  : FR=FRE("") : RELEASE : LOAD("LABY")
combat_60
 PRINT@15,12;CHR$(131)"  FAIL  ":SHOOT:WAITTI*4
combat_59
 PRINT@15,12;CHR$(131)"         "
 RETURN
combat_53
 IF WL(P)=0 AND BT(P)=0 THEN A$="1":GOTO  combat_62 
 IF WR(P)=0 THEN A$="3":GOTO  combat_63 
 PRINT @4,8;"> Which one 1-3 ? "
combat_64
 GET A$:IF A$<>"1"ANDA$<>"2"ANDA$<>"3" THEN  combat_64 
combat_62
 IF A$="1" THEN BF(P)=IMPACT(WR(P)-7):AU(P)=WR(P):GOTO  combat_65 
 IF A$="2" THEN IF WL(P)>0 THEN BF(P)= IMPACT(WL(P)-7):AU(P)=WL(P) ELSE  combat_64 
combat_63
 IF A$="3" THEN IF BT(P)>0 THEN BF(P)= IA(BT(P)-36):AU(P)=BT(P) ELSE  combat_64 
combat_65
 IF AU(P)=18 AND FU=1 THEN PRINT@25,16;" NET in USE ":WAIT 5*TI:GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 BF(P)=BF(P)+INT(FO(P)/10)+FC(P):GOSUB  combat_66 
 WAIT 5*TI
 RETURN
combat_54
 REM OBJET OC(P)
 PRINT@31,12;CHR$(145)"U)SE "CHR$(144)
 PRINT @29,16;"Which one?":PRINT @31,17;"0: None"
combat_67
 GETA$:CH=VAL(A$):IF (CH>0 AND CH<4) OR CH>OP(P)+3  THEN  combat_67 
 IF CH=0 THEN GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 CH=CH-3:OC(P)=SAD(P,CH):CS(P)=CH
 PRINT@1,11+CH;CHR$(145):PRINT@27,11+CH;CHR$(144)
 IF OC(P)>19 AND OC(P)<25 THEN GOSUB  combat_68 :GOTO  combat_69 
 IF (OC(P)>24 AND OC(P)<34) THEN PING:GOTO  combat_69 
 GOSUB  combat_70 :GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_16 
 WAIT 5*TI
combat_69
 RETURN
combat_68
 REM CIBLER PERSO
 PING:PRINT @2,19;CHR$(148)"  On Who ?  "CHR$(145)
 GOSUB  combat_6 
 TG(P)=VAL(A$)
 PRINT@1,19;CHR$(145)"CHARACTERS     CAREER     HP  ST  AC "
 RETURN
combat_66
 REM CIBLER ENNEMI
 PRINT @3,6;CHR$(145)"* TARGET ? "CHR$(144)
combat_71
 GET A$:IF VAL(A$)<1 OR VAL(A$)>NE THEN  combat_71 
 IF C6OK(VAL(A$))=0 THEN  combat_71 
 PRINT @3,6;CHR$(144)"           "
 TG(P)=VAL(A$)
 RETURN
combat_33
 REM ITEMS
 REM UTIL OBJET
 IF OC(AO(P))=25 OR OC(AO(P))=26 OR OC(AO(P))>31 THEN  combat_72 
 IF OC(AO(P))=20 OR OC(AO(P))=21 THEN GOSUB  combat_73 :GOTO  combat_74 
 IF OC(AO(P))=22 THEN GOSUB  combat_75 :GOSUB  combat_76 :GOTO  combat_74 
 IF OC(AO(P))=23 THEN GOSUB  combat_77 :GOTO  combat_74 
 IF OC(AO(P))=24 THEN GOSUB  combat_78 :GOTO  combat_74 
 IF OC(AO(P))>26 AND OC(AO(P))<32 THEN GOSUB  combat_79 
combat_74
 WAIT 5*TI:GOSUB  combat_7 :GOTO  combat_80 
combat_72
 IF OC(AO(P))=25 THEN PRINT @6,10;N$(AO(P))" use Warg vision ":ZO=1:GOTO  combat_80 
 IF OC(AO(P))=26 THEN PRINT @6,10;N$(AO(P))" use freezing potion":GOSUB  combat_81 :GOTO  combat_80 
 IF OC(AO(P))=32 OR OC(AO(P))=33 THEN PRINT @6,10;N$(AO(P))" explode ";IT$(OC(AO(P))):GOSUB  combat_82 :GOSUB  combat_83 
combat_80
 SAD(AO(P),CS(AO(P)))=0:WAITTI*5
 GOSUB  combat_84 
 RETURN
combat_83
 REM eveil
 IF REVEIL=O THEN  combat_85 
 IF FNA(100)> C5(REVEIL) THEN  combat_85 
 PING:PRINT@2,17;" > noise awakes "+MM$(MO(REVEIL)):WAITTI*8
 C6OK(REVEIL)=1:GOSUB  combat_11 
combat_85
 RETURN
combat_180
 REM CURE
 IF OK(TG(AO(P)))=4 THEN  combat_86 
 SS=FNA(4)+FNA(VIL)+3:IF OC(AO(P))=21 THEN SS=SS+4:OK(TG(AO(P)))=1
 ET(TG(AO(P)))=ET(TG(AO(P)))+SS:IF ET(TG(AO(P)))>PV(TG(AO(P))) THEN ET(TG(AO(P)))=PV(TG(AO(P)))
combat_86
 RETURN
combat_76
 REM LIFE
 IF OK(TG(AO(P)))<>4 THEN  combat_87 
 OK(TG(AO(P)))=1: ET(TG(AO(P)))=INT(PV(TG(AO(P)))/2)
 HV=HV+1:GOSUB  combat_7 
combat_87
 RETURN
combat_79
 REM FOOD
 IF OC(AO(P))=27 THEN M$=" drinks water ":P1=4:P2=2:GOTO  combat_88 
 IF OC(AO(P))=28 THEN M$=" eats some bread ":P1=5:P2=3:GOTO  combat_88 
 IF OC(AO(P))=29 THEN M$=" sips some ale ":P1=8:P2=3:GOTO  combat_88 
 IF OC(AO(P))=30 THEN M$=" swallows fish ":P1=8:P2=4:GOTO  combat_88 
 IF OC(AO(P))=31 THEN M$=" devours boar meat ":P1=10:P2=6
combat_88
 SS=FNA(P1)+P2:S$=N$(AO(P))+M$:L=10:GOSUB  combat_29 
 ET(AO(P))=ET(AO(P))+SS:IF ET(AO(P))>PV(AO(P)) THEN ET(AO(P))=PV(AO(P))
 RETURN
combat_82
 REM GREGEOIS & SORTS COLLECTIFS
 DG=6:IF OC(AO(P))=32 THEN DG=3
combat_178
 FORJ=1TO5:SHOOT:WAIT15:PAPER J:NEXTJ:EXPLODE:PAPER0:GOSUB  combat_8 
combat_179
 IF EV=0 THEN  combat_89 
 LG=0:REVEIL=0
 FORI=1TO NE
 IF C6OK(I)<1 THEN  combat_90 
 IF C6OK(I)=5 THEN REVEIL=I:PING
 LG=LG+1
 SS=FNA(DG)+DG:IF C6OK>4 THEN SS=SS*3
 S$=MM$(MO(I))+" looses "+STR$(SS)+" HP":GOSUB  combat_91 
 PRINT @3,9+LG;S$:WAIT TI*5
combat_90
 NEXT I
 DD=0
 IF EV<=0 THEN  combat_89 
 GOSUB  combat_11 :WAIT TI*5
combat_89
 RETURN
combat_91
 REM mort ?
 C2PV(I)=C2(I)-SS:IF C2(I)>0 THEN  combat_92 
 S$=S$+CHR$(129)+" and dies":IF C6OK(I)=6 THEN FU=0
 EV=EV-1:C6OK(I)=0:IF C6=4THENAMI=0
 IFDD=1THENMT(SD)=MT(SD)+1ELSEMT(AO(P))=MT(AO(P))+1
combat_92
 RETURN
 REM + Tri persos
combat_10
 FOR P=1TO 6:JA=FNA(10):AO(P)=P:ESP(P)=1:VE(P)=AG(P)+JA:MT(P)=0:NEXTP
 FOR E=1TONE:JA=FNA(10):AO(E+6)=E:ESP(E+6)=0:VE(E+6)=C1AG(E)+JA:NEXTE
combat_39
 REPEAT
 SS=0
 FOR J=1 TO 5+NE
 IF VE(J)>=VE(J+1) THEN  combat_93 
 TP=VE(J):VE(J)=VE(J+1):VE(J+1)=TP
 TP=ESP(J):ESP(J)=ESP(J+1):ESP(J+1)=TP
 TP=AO(J):AO(J)=AO(J+1):AO(J+1)=TP
 SS=1
combat_93
 NEXTJ
 UNTIL SS=0
 RETURN
combat_84
 REM  TRI SAC
 FOR I=1TO5
 IF SAD(AO(P),I)>0 THEN  combat_94 
 IF SAD(AO(P),I+1)>0 THEN SAD(AO(P),I)=SAD(AO(P),I+1):SAD(AO(P),I+1)=0
combat_94
 NEXT I
 RETURN
combat_28
 REM ARMES
 IF AU(AO(P))>19 THEN ARM=3:TST=3:ACT$=" casts "+IT$(BT(AO(P)))+" on ":GOTO  combat_95 
 IF AU(AO(P))>7  AND AU(AO(P))<15 OR AU(AO(P))=19 THEN TST=1:ARM=1:GOTO  combat_95 
 IF AU(AO(P))>14 AND AU(AO(P))<18 THEN TST=2:ARM=2
 IF AU(AO(P))=15 THEN ACT$=" shoots a bolt on ":DFF=20:GOTO  combat_95 
 IF AU(AO(P))=16 THEN ACT$=" shoots an arrow on ":DFF=10:GOTO  combat_95 
 IF AU(AO(P))=17 THEN ACT$=" shoots a stone on ":DFF=-5:GOTO  combat_95 
 IF AU(AO(P))=18 THEN TST=3:DFF=15:ARM=4:ACT$=" throws the net on "
combat_95
 RETURN
combat_31
 REM EFFET ARME
 IF C6OK(TG(AO(P)))>4 OR VE(AO(P))> 80 THEN RT=1
 IF RT=0 THEN PING:PRINT@15,14;" and fails ! ":GOTO  combat_96 
 SS=VIL+FNA(5)+BF(AO(P))
 IF EF(AO(P))>0 THEN SS=SS+((1+FNA(2))*(BF(AO(P))))
 IF C6OK(TG(AO(P)))>4 THEN SS=SS+C2PV(TG(AO(P)))
 C2PV(TG(AO(P)))=C2PV(TG(AO(P)))-SS
 PRINT @12,14;"inflicts it "SS" damage"
 IF C2PV(TG(AO(P))) <= 0 THEN MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_97 
combat_96
 WAIT 15*TI
 RETURN
combat_32
 REM NET
 IF RT=1 THEN C6OK(TG(AO(P)))=6:S$=" ENEMY CAPTURED WITH THE NET !":FU=1 ELSE S$="net misses target"
 PRINT @8,14;S$:WAIT 10*TI:IF RT=1 THEN GOSUB  combat_11 
 RETURN
combat_30
 REM + TESTS > D100
 SS=FNA(100):RT=0
 ON TST GOTO  combat_98 , combat_99 , combat_100 , combat_101 , combat_102 
combat_98
 REM Combat
 IF ESP(AO(P))=0 THEN  combat_103 
 IF SS < CC(AO(P))  +DFF THEN RT=1:GOTO  combat_104 
combat_103
 IF SS < C3CC(AO(P))+DFF THEN RT=1
combat_104
 WAIT100:RETURN:'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  "
combat_99
 REM Tir
 IF ESP(AO(P))=0 THEN  combat_105 
 IF SS<CT(AO(P))  +DFF THEN RT=1:GOTO  combat_106 
combat_105
 IF SS<C3CC(AO(P))+DFF THEN RT=1
combat_106
 WAIT100:RETURN:'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  "
combat_100
 REM Agility
 IF ARM=3 THEN IF SS < AANIM(AO(P))+DFF THEN RT=1:GOTO  combat_107 
 IF ESP(AO(P))=1 THEN IF SS<AGI(AO(P))+DFF THEN RT=1:GOTO  combat_107 
 IF ESP(AO(P))=0 THEN IF SS<C1AG(AO(P))+DFF THEN RT=1
combat_107
 WAIT100:RETURN:'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  "
combat_101
 REM QI
 IF ESP(AO(P))=0 THEN  combat_108 
 IF SS<IN(AO(P)) +DFF THEN RT=1:GOTO  combat_109 
combat_108
 IF SS<C5QI(AO(P))+DFF THEN RT=1
combat_109
 WAIT100:RETURN:'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  "
combat_102
 REM FM
 IF ESP(AO(P))=0 THEN  combat_110 
 IF SS<FM(AO(P))+DFF THEN RT=1:GOTO  combat_111 
combat_110
 IF SS<C5QI(AO(P))+DFF THEN RT=1
combat_111
 WAIT100:RETURN:'PRINT@6,6;"TST";TST;"SS";SS;"RT";RT;"  "
 REM ENEMY
combat_37
 REM net
 S$=MM$(MO(AO(P)))
 PRINT @2,10;CHR$(129);S$;" tries to get free ":WAIT TI*5
 TST=3:DFF=-30:GOSUB  combat_30 :WAIT 8*TI
 IF RT=0 THEN S$=S$+" stays captured " ELSE S$=S$+" frees from the net "
 PRINT @2,12;CHR$(129);S$:WAIT 8*TI
 IF RT=1 THEN FU=0:C6OK(AO(P))=1:ZAP:GOSUB  combat_11 
 GOSUB  combat_8 
 RETURN
combat_38
 REM Enemy attack
combat_112
 TE=FNA(6):IF OK(TE)=4 THEN  combat_112 
 TE$=N$(TE):SS$=" attacks ":TST=1
 IF MO(AO(P))>14 THEN IF FNA(10)>7 THEN SS$=" casts a spell on":TST=4:IF MO(AO(P))> 20 THEN TE$="the team"
 L=10:S$=CHR$(129)+MM$(MO(AO(P)))+SS$:GOSUB  combat_29 :ZAP
 L=12:S$=CHR$(129)+TE$:GOSUB  combat_29 :WAITTI*10
 DFF=(2*VIL)+FNA(10):GOSUB  combat_30 :IF RT=0 THEN SS$="and fails": GOTO  combat_113 
 IF TST=4 THEN GOTO  combat_114 
 SS=1+VIL+FNA(VIL)+CM(AO(P),4)-BC(TE)-PRD(TE)'FORMULA MONSTER ATTACK
 IF SS<=0 THEN SS$="the armor resists !":GOTO  combat_113 
combat_121
 SS$="inflicts him "+STR$(SS)+" damage"
 ET(TE)=ET(TE)-SS:ZAP:WAIT TI*5
 IF ET(TE)<=0 THEN ET(TE)=0:OK(TE)=4:HV=HV-1
combat_113
 L=14:S$=SS$:GOSUB  combat_29 :WAITTI*5
 IF OK(TE)=4 THEN PRINT @15,16;"and s/he dies...":EXPLODE
 GOSUB  combat_7 
 GOTO  combat_115 
combat_114
 REM week spells
 IF MO(AO(P)) > 20 THEN  combat_116 
combat_123
 IF FNA(10)>6 THEN SM=FNA(4)ELSE SM=1
 ON SM GOTO  combat_117 , combat_118 , combat_119 , combat_120 
combat_117
 FOR I=1TO13:PRINT@3+I,12;CHR$(129);"*":WAIT3:NEXT:SHOOT
 SS=6+FNA(VIL)-INT(FM(TE)/10):GOTO  combat_121 
 GOTO  combat_122 
combat_118
 IF OK(TE)=1 THEN SS$="he poisons him":OK(TE)=2 ELSE  combat_123 
 GOTO  combat_122 
combat_119
 IF OK(TE)=1 THEN SS$="his muscles doesn't respond":OK(TE)=3 ELSE  combat_123 
 GOTO  combat_122 
combat_120
 SS$="his protection decreases":BC(TE)=BC(TE)-1-FNA(2)
 IF BC(TE)<0 THEN BC(TE)=0
combat_122
 L=14:S$=SS$:GOSUB  combat_29 :WAITTI*12
 GOTO  combat_115 
combat_116
 REM strong spells
 SM=FNA(5)
 GOSUB  combat_8 
 L=9:S$=SM$(SM):GOSUB  combat_29 :ZAP:WAITTI*20:LL=10
 IF SM=4 THEN MALUS=MALUS+1+FNA(2):GOTO  combat_115 
 IF SM=5 THEN GOSUB  combat_124 :GOTO  combat_115 
 FORJ=1TO6
 IF OK(J)=4 THEN  combat_125  ELSE LL=LL+1
 IF SM > 1 THEN  combat_126 
 BC(J)=BC(J)-1-FNA(2)
 IF BC(J)<0 THEN BC(J)=0
 S$=" "+STR$(BC(J))+" "
 PRINT@35,19+J;S$:GOTO  combat_125 
combat_126
 SS=VIL+2+FNA(4)+CM(AO(P),4)
 IF CP(J)>3 THEN SS=SS-INT(QI(J)*2/10):IF SS<=0 THEN SS=1
 PRINT @5,LL;N$(J);" looses ";SS;" hp":ET(J)=ET(J)-SS
 IF ET(J)<=0 THEN ET(J)=0:OK(J)=4:HV=HV-1
 IF OK(J)=4 THEN PRINT @30,LL;"and dies!":EXPLODE
 WAITTI*5
 GOSUB  combat_7 
combat_125
 NEXTJ
combat_115
 RETURN
combat_124
 REM Cure
 L=11
 FOR J=1TONE
 S$=" is cured"
 IF C6(J)<2 OR C6(J)>3 THEN  combat_127 
 C6(J)=1:C2=C2+5+FNA(8)
 S$=MM$(MO(J))+S$:GOSUB  combat_29 :WAIT TI*8:L=L+1
combat_127
 NEXTJ
 GOSUB  combat_11 
 RETURN
combat_42
 REM RECOMPENSES
 TEXT:CLS:POKE#26A,PEEK(#26A) AND 254
 ENC=4:S$="RESULTS OF THE BATTLE":L=22:GOSUB  combat_128 
 PING:PRINT@14,4;"!  YOU WIN  !"
 PRINT@6,6;"Each survivor wins at least:"
 XP=DC*5:PO=DC*3:PRINT@6,8;"> Points:";XP
 PRINT@6,9;"> Money:";PO;" sd"
 FU=0
 FOR P=1TO6
 IF OK(P)>2 THEN  combat_129 
 XP(P)=XP(P)+XP+(MT(P)*20)+FNA(10*VIL)
 RI(P)=RI(P)+PO+(MT(P)*25)+FNA(10*VIL)
combat_129
 IF MT(P)< NE THEN  combat_130 
 S$="Well done "+N$(P):L=11:GOSUB  combat_29 :WAITTI*8
 S$="who killed them all !":L=12:GOSUB  combat_29 :WAITTI*12
 PRIME=(NE*100)+FNA(DC*20)
 S$="A special bounty of"+STR$(PRI)+" ss":L=14:GOSUB  combat_29 :WAITTI*12
 RI(P)=RI(P)+PRI:XP(P)=XP(P)+XP+(MT(P)*20)+FNA(10*VIL)
 L=16:GOSUB  combat_5 :GOSUB  combat_131 
combat_130
 IF XP(P)>1000+(VIL*150) AND NI(P)<21 AND OK(P)<>4 THEN GOSUB  combat_132 
 NEXT P
 L=18:S$="LET'S MOVE ON !":GOSUB  combat_29 
 L=21:GOSUB  combat_5 
 PING
 CA=0
 GOSUB  combat_61  : FR=FRE("") : RELEASE : LOAD("LABY")
combat_132
 REM PROMOTION NEW
 NI(P)=NI(P)+1:XP(P)=0:FORJ=1TO5:PING:WAIT2*J:NEXT
 S$=CHR$(145)+C$(CP(P))+" "+N$(P)+" "+CHR$(144)+CHR$(132):L=11:GOSUB  combat_29 
 S$="rises to level :"+STR$(NI(P)):L=12:GOSUB  combat_29 
 S$="And earns some HP !":L=13:GOSUB  combat_29 :WAITTI*8
 S$=" 1   2   3   4   5   6"
 PLOT 7,15,S$
 S$="Ml  Rg  St  Dx  Ig  MS  "
 PRINT@6,16;CHR$(145)CHR$(135);S$;CHR$(144)CHR$(132)
 S$=STR$(CC(P))+" "+STR$(CT(P))+" "+STR$(FO(P))+" "+STR$(AG(P))+" "+STR$(IN(P))+" "+STR$(FM(P))
 PLOT 7,17,S$
 PRINT @5,19;"Raise which attribute (1-6) ?"
 GOSUB  combat_6 :PROMO=5+FNA(4)
 IF A=1 THEN CC(P)=CC(P)+PRO:IFCC(P)>99THENCC(P)=99:GOTO  combat_133 
 IF A=2 THEN CT(P)=CT(P)+PRO:IFCT(P)>99THENCT(P)=99:GOTO  combat_133 
 IF A=3 THEN FO(P)=FO(P)+PRO:IFFO(P)>99THENFO(P)=99:GOTO  combat_133 
 IF A=4 THEN AG(P)=AG(P)+PRO:IFAG(P)>99THENAG(P)=99:GOTO  combat_133 
 IF A=5 THEN IN(P)=IN(P)+PRO:IFIN(P)>99THENIN(P)=99:GOTO  combat_133 
 IF A=6 THEN FM(P)=FM(P)+PRO:IFFM(P)>99THENFM(P)=99
combat_133
 S$=STR$(CC(P))+" "+STR$(CT(P))+" "+STR$(FO(P))+" "+STR$(AG(P))+" "+STR$(IN(P))+" "+STR$(FM(P))
 PLOT 7,18,S$
 PV(P)=PV(P)+FNA(3)+4:IFPV(P)>99THENPV(P)=99
 L=21:GOSUB  combat_5 :GOSUB  combat_131 
 RETURN
combat_73
 L=11:S$=CHR$(130)+N$(AO(P))+" Heals "+N$(TG((AO(P))))
 GOSUB  combat_29 :GOSUB  combat_134 :WAITTI*5
 L=14:GOSUB combat_29 
 RETURN
combat_78
 REM Potion divine
 L=10:S$=N$(AO(P))+" uses divine Potion ":GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" gets a colossal strength":GOSUB  combat_29 
 FC(TG(AO(P)))=50+FNA(VIL*6):GOSUB combat_135 
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
 REM lower letters
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
combat_75
 L=10:S$=N$(AO(P))+" uses Vital Essence ":GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" revives":GOSUB  combat_29 
 RETURN
combat_77
 L=10:S$=N$(AO(P))+" uses "+IT$(24):GOSUB  combat_29 
 L=13:S$=N$(TG((AO(P))))+" is Invincible !":GOSUB  combat_29 
 BC(TG(AO(P)))=50:ET(TG(AO(P)))=PV(TG(AO(P)))
 RETURN
combat_135
 I=0' indice hero with potion ebony
 REPEAT
 I=I+1
 UNTIL AO(I)=TG(AO(P)) AND ESP(I)=1 ' OR I=6+NE
 VE(I)=90
 RETURN
combat_189
 FORJ=1TONE'freezed enemies
 IF ESP(J)=1THEN  combat_136 
 VE(J)=VE(J)-5
combat_136
 NEXTJ
 GOSUB  combat_39 
 RETURN
combat_56
 REM SPELLS
 GOSUB  combat_8 :SS=NI(P):IFSS>8THENSS=8
 PRINT @14,8;CHR$(129);" < MAGIC > ";CHR$(144)
 FOR I=1TOSS:PRINT@12,I+9;I;"- ";SPELL$(CP(P)-3,I)
 S$="("+STR$(SN(P,I))+" )":PRINT @26,I+9;S$:NEXT
 PRINT @5,9;"None - 0":
combat_137
 GETA$:CH=VAL(A$):IF CH>NI(P) THEN  combat_137 
 IF CH=0 THEN GOSUB  combat_8 :GOSUB  combat_14 :GOTO  combat_138 
 IF SN(P,CH)=0 THEN PING:GOTO  combat_137 
 SPELL(P)=CH
 ON CP(P)-3 GOTO  combat_139 , combat_140 , combat_141 
combat_139
 IF CH >6  THEN  combat_142 
 GOSUB  combat_66 :GOTO  combat_142 
combat_140
 IF CH=5 OR CH=6 THEN  combat_142 
 IF CH<>8 THEN GOSUB  combat_68  ELSE GOSUB  combat_66 
 GOTO  combat_142 
combat_141
 IF CH>3 THEN  combat_142 
 IF CH=3 AND AMI>0 THEN GOSUB  combat_70 :GOTO  combat_137 
 RT=0
 FORJ=1TO6:IF WR(J)>14 OR WL(J)>14 THEN RT=1
 NEXTJ
 IF RT=0 THEN GOSUB  combat_70 :GOTO  combat_56 
combat_145
 IF CH<3 THEN GOSUB  combat_68  ELSE GOSUB  combat_66 
 IF CH<>1 THEN  combat_142 
 IF WR(TG(P))=0  THEN  combat_143 
 IF WR(TG(P))>14 AND (WL(TG(P))=0 OR WL(TG(P))>14) THEN  combat_143 
 GOTO  combat_144 
combat_143
 GOSUB  combat_70 :GOTO  combat_145 
combat_144
 GOSUB  combat_146 
combat_142
 GOSUB  combat_7 
combat_138
 RETURN
combat_146
 GOSUB  combat_8 
 IF WL(TG(P))=0 THEN A=1:GOTO  combat_147  ELSE PRINT @4,10; "Enchant whose sword ?"
 PRINT @3,12;CHR$(132);"1.R:";IT$(WR(TG(P)));CHR$(131)
 PRINT @3,13;CHR$(132);"2.L:";IT$(WL(TG(P)));CHR$(131)
combat_148
 GET A$:A=VAL(A$):IF A<>1 AND A<>2 THEN  combat_148 
combat_147
 EF(TG(P))=A:IF A=1 THEN EF=WR(TG(P)) ELSE EF=WL(TG(P))
 IF EF>14 THEN GOSUB  combat_70 :GOTO  combat_146 
 RETURN
combat_34
 REM SPELLS
 H=CP(AO(P))-3
 L=10:S$=CHR$(134)+N$(AO(P))+" Casts "+SPELL$(H,SP(AO(P))):GOSUB  combat_29 
 SN(AO(P),SP(AO(P)))=SN(AO(P),SP(AO(P)))-1
 ON H GOTO  combat_149 , combat_150 , combat_151 
combat_149
 IF SP(AO(P))<7 AND C6OK(TG(AO(P)))=0 THEN  combat_152 
 IF SP(AO(P))<7 THEN S$=" on  "+MM$(MO(TG(AO(P)))) ELSE S$="on the enemies"
 L=12:GOSUB  combat_29 :WAIT TI*10:S$="fails his invocation"
 ON SPELL(AO(P)) GOSUB  combat_153 , combat_154 , combat_155 , combat_156 , combat_157 , combat_158 , combat_159 , combat_160 
 GOTO  combat_152 
combat_150
 IF SP(AO(P))<7 AND OK(TG(AO(P)))=4 THEN  combat_152 
 IF SP(AO(P))<5 OR SP(AO(P))=7 THEN S$=" on  "+N$(TG(AO(P)))
 IF SP(AO(P))=5 OR SP(AO(P))=6 THEN S$=" on the team"
 IF SP(AO(P))=8 THEN IF C6OK(TG(AO(P)))<>0 THEN S$=" on "+ MM$(MO(TG(AO(P)))) ELSE  combat_152 
 L=12:GOSUB  combat_29 :WAIT TI*10
 ON SPELL(AO(P)) GOSUB  combat_161 , combat_162 , combat_163 , combat_164 , combat_165 , combat_166 , combat_167 , combat_168 
 GOSUB  combat_169 :GOSUB  combat_7 :GOSUB  combat_8 
 GOTO  combat_152 
combat_151
 IF SP(AO(P))=2 THEN S$=" on "+ N$(TG((AO(P))))
 IF SP(AO(P))=3 THEN IF C6OK(TG(AO(P)))<>0 THEN S$=" on "+ MM$(MO(TG(AO(P)))) ELSE  combat_152 
 IF SP(AO(P))=2 OR SP(AO(P))=3 THEN L=12:GOSUB  combat_29 :WAIT TI*10
 IF SP(AO(P))=8 AND SD<>AO(P) THEN S$=" you have no saddle! ":L=12:GOSUB  combat_29 :WAIT TI*10:GOTO combat_152 
 S$="fails his invocation"
 ON SPELL(AO(P)) GOSUB  combat_170 , combat_171 , combat_172 , combat_173 , combat_174 , combat_175 , combat_176 , combat_177 
combat_152
 RETURN
 REM SORCIER
combat_153
 REM 1,1
 TST=4:DFF=20:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 C6OK(TG(AO(P)))=5:S$="takes a good nap...ZZZzzz":GOSUB  combat_169 
 RETURN
combat_154
 REM 1,2 FEU
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 ZAP:FORI=1TO5:PAPER1:WAIT10:PAPER3:WAIT15:NEXT:PAPER0:EXPLODE
 SS=FNA(5)+3:C2PV(TG(AO(P)))=C2PV(TG(AO(P)))-SS
 S$=MM$(MO(TG((AO(P)))))+" looses "+STR$(SS)+" HP":GOSUB  combat_169 
 IF C2PV(TG(AO(P)))<=0 THEN MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_97 
 RETURN
combat_155
 REM 1,3
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 S$="turns into stone":GOSUB  combat_169 
 S$=MM$(MO(TG((AO(P))))):GOTO  combat_97 
combat_156
 REM 1,4
 TST=5:DFF=40:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 C6OK(TG(AO(P)))=2:S$="poison will work"
 GOTO  combat_169 
combat_157
 REM 1,5 SANG
 TST=5:DFF=15:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 C6OK(TG(AO(P)))=3:S$="is bleeding"
 GOTO  combat_169 
combat_158
 REM 1,6 FOUDRE
 TST=4:DFF=30:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 S$="is reduced to ashes !":GOSUB  combat_169 
 MT(AO(P))=MT(AO(P))+1:S$=MM$(MO(TG((AO(P))))):GOTO  combat_97 
combat_159
 REM 1,7 LAVE
 TST=5:DFF=35:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 S$="A lava rain!!!":GOSUB  combat_169 :GOSUB  combat_8 
 DG=10:GOSUB  combat_178 :RETURN
combat_160
 REM 1,8 SEISME
 TST=5:DFF=40:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 EXPLODE:WAIT60:SHOOT
 S$="The ground opens and swallows them!":GOSUB  combat_169 :GOSUB  combat_8 
 DG=20:GOSUB  combat_179 :RETURN
 REM  MESTRE
combat_161
 REM 2,1 EAU
combat_134
 GOSUB  combat_180 
 S$="S/he is a little better"
 RETURN
combat_162
 REM 2,2 SERUM
 IF OK(TG(AO(P)))<>2 THEN S$="Nope ! read again your grimoire":GOTO  combat_181 
 OK(TG(AO(P)))=1:S$="Poison is cured"
combat_181
 RETURN
combat_163
 REM 2,3 MUSCLE
 IF OK(TG(AO(P)))<>3 THEN S$="Nope ! read again your grimoire":GOTO  combat_182 
 OK(TG(AO(P)))=1:S$="Back to full strength !"
combat_182
 RETURN
combat_164
 REM 2,4 BOUCLIER
 BC(TG(AO(P)))=BC(TG(AO(P)))+FNA(3)+2
 S$="A magical shield !"
 RETURN
combat_165
 REM 2,5 ELIXIR
 FORI=1TO6
 IF OK(I)<>4 THEN ET(I)=PV(I)
 NEXT
 S$="A team healthy again !"
 RETURN
combat_166
 REM 2,6 ECRAN
 FORI=1TO6:BC(I)=10:NEXT
 S$="Maximum Protection !"
 RETURN
combat_167
 REM 2,7 VIE
 IF OK(TG(AO(P)))<>4 THEN   combat_183 
 OK(TG(AO(P)))=1:ET(TG(AO(P)))=PV(TG(AO(P))):HV=HV+1
 S$="A rebirth !"
combat_183
 RETURN
combat_168
 REM 2,8 MORT
 IF C6OK(TG(AO(P)))=0 THEN  combat_184 
 TST=5:DFF=50:GOSUB  combat_30 :IF RT=0 THEN S$="fails his invocation":GOTO  combat_184 
 GOSUB  combat_185 
 S$="A nice Death !"
combat_184
 RETURN
 REM SEPTON
combat_170
 REM 3.1EPEE-FEU
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN EF(TG((AO(P))))=0:GOTO  combat_169 
 IF EF(TG((AO(P))))=1 THEN EF=WR(TG((AO(P)))) ELSE EF=WL(TG((AO(P))))
 WAIT TI*10:L=12:S$="on "+IT$(EF)+" of "+N$(TG((AO(P)))):GOSUB  combat_29 
 ZAP:PAPER1:WAIT TI*10:EXPLODE:PAPER0
 S$="...it inflames ...":GOSUB  combat_169 :WAIT TI*8:GOSUB  combat_8 
 RETURN
combat_171
 REM 3.2FORCE
 TST=4:DFF=20:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 IF OK(TG(AO(P)))=4 THEN  combat_186 
 S$=" his strength grows ":PRINT @12,14;S$:WAIT TI*10
 FC(TG(AO(P)))=FC(TG(AO(P)))+FNA(VIL)+5
combat_186
 RETURN
combat_172
 REM 3.3CHARME
 TST=5:DFF=10:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 AMI=TG(AO(P)):C6OK(AMI)=4:EV=EV-1
 S$="A new friend  ;-)":PRINT @5,14;S$:WAIT TI*15
 RETURN
combat_173
 REM 3.4VISION
 TST=4:DFF=50:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 PRINT @10,12;" uses Warg vision":ZO=1:GOSUB  combat_11 :WAIT TI*12
 RETURN
combat_174
 REM 3.5GLACE
 TST=4:DFF=25:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
combat_81
 ECHEC=0:L=13:PRINT @10,12;" The North's Blow  !! ":WAIT TI*10
 FORI=1TONE
 IF C6OK(I)<1 THEN  combat_187 
 SS=FM(AO(P))-C5(I)+FNA(VIL):L=L+1
 IFSS<3THENEC=EC+1:S$=MM$(MO(I))+" is laughing":GOTO  combat_188 
 C2(I)=C2(I)-SS:S$=MM$(MO(I))+" freezes: -"+STR$(SS)+"hp"
 GOSUB  combat_91 :GOSUB  combat_189 
combat_188
 PRINT@3,L;S$:WAITTI*5
combat_187
 NEXTI
 WAITTI*20:IFEC=EVTHENGOSUB  combat_131 :PRINT@3,15;"Ha Ha Ha a very small spirit !!"
 GOSUB  combat_11 
 RETURN
combat_175
 REM 3.6ILLUSION
 TST=5:DFF=30:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 L=12:PRINT @5,L;"Projects an imaginary monster ":WAIT TI*15
 WIN$=" sneers":LOST$=" flees"
 GOSUB  combat_190 
 RETURN
combat_176
 REM 3,7WIND
 PRINT @10,12;"the horde !":WAIT TI*8
 TST=5:DFF=35:GOSUB  combat_30 :IF RT=0 THEN  combat_169 
 EXPLODE:WAIT60:SHOOT
 S$="A tornado swipes the horde!":GOSUB  combat_169 :GOSUB  combat_8 
 DG=6:GOSUB  combat_179 
 RETURN
combat_177
 REM 3,8DRAGOON
 DR=1
 S$="A Dragon is joining you":GOSUB  combat_169 :GOSUB  combat_8 
 RETURN
combat_21
 GOSUB  combat_8 :S$=CHR$(129)+"! the Dragon rages ! "
 T=INT((41-LEN(S$))/2):PRINT@T,10;S$:WAIT TI*15
 DG=20:GOSUB  combat_178 
 RETURN
combat_169
 L=14:GOSUB  combat_29 :WAIT TI*10
 GOSUB  combat_11 
 RETURN
combat_35
 REM CHARME
 GOSUB  combat_8 :S$=CHR$(134)+" YOUR FRIEND: "+MM$(MO(AMI)):T=INT((41-LEN(S$))/2)
 PRINT @T,7;S$:S$=CHR$(134)+MM$(MO(AMI))+" Attacks the horde "
 T=INT((41-LEN(S$))/2):PRINT@T,10;S$:WAIT TI*15
 TE=FNA(NE)
combat_192
 IF C6OK(TE)<>0 AND C6OK(TE)<>4 THEN  combat_191 
 IFTE<NETHENTE=TE+1ELSETE=1
 GOTO  combat_192 
combat_191
 SS=FNA(6)+2+C4(AMI):IFC6OK(TE)>4THENSS=SS*2
 PRINT @4,12;MM$(MO(TE));" looses ";SS;" hp";:WAIT TI*15
 C2(TE)=C2(TE)-SS:IF C2(TE)<0 THEN C2(TE)=0:C6(TE)=0:GOTO  combat_193 
 RETURN
combat_190
 REM TEST Opposit
 FORJ=1TONE
 IF C6OK(J)=4 OR C6OK(J)=0 OR C6OK(J)=6 THEN  combat_194 
 L=L+1:SS=FNA(100):PRINT@4,8;"SS: ";SS;"QI: ";C5(J)
 IF SS<C5QI(J) THEN RT=1:SS$=MM$(MO(J))+WIN$:GOTO  combat_195 
 SS$=MM$(MO(J))+LOST$:EV=EV-1:C6OK(J)=0:C2(J)=0:MT(AO(P))=MT(AO(P))+1
combat_195
 PRINT @5,L;SS$:WAIT TI*15
combat_194
 NEXTJ
 GOSUB  combat_11 
 RETURN
combat_97
 REM ENNEMI MORT
 PRINT @15,16;S$;" dies ":EXPLODE:WAIT 5*TI
combat_185
 IF C6OK(TG(AO(P)))=6 THEN FU=0
 IF C6OK(TG(AO(P)))=4 THEN AMI=0
 C2PV(TG(AO(P)))=0:C6OK(TG(AO(P)))=0
combat_193
 EV=EV-1
 GOSUB  combat_11 ' affichage monstres
 RETURN
 REM Lecture TITEMS.BIN
combat_1
 CLS:PRINT @ 8,12;CHR$(145);CHR$(135);"++ PLEASE WAIT ++ ";CHR$(144):
 DIM ITEM$(55), CM(23,5)
 LOAD "TITEMS.BIN"
 O1=#A000
 LI=PEEK(O1)
 REM PRINT "LG IT:";LI
 FOR I=1 TO LI
 O1=O1+1:LG=PEEK(O1)
 S$=""
 IF LG=0 THEN  combat_196 
 FOR J=1 TO LG
 O1=O1+1:S$=S$+CHR$(PEEK(O1))
 NEXT
combat_196
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
 GOSUB combat_197  ' chargement
 REM LOAD"TEAM.BIN"
 O1=#A000
 O1=O1+1:VIL=PEEK(O1)
 REM PRINT"version " VIL
 O1=O1+1:X=PEEK(O1)
 O1=O1+1:Y=PEEK(O1)
 O1=O1+1:S=PEEK(O1)
 O1=O1+1:CA=PEEK(O1)
 O1=O1+1:VIL=PEEK(O1)
 REM PRINT"Ville " VIL "X " X "Y " Y "S " S "CA " CA
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
 O1=O1+1:PV(P)=PEEK(O1):GOSUB combat_198 
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
 GOSUB combat_198 :NEXT P
 O1=O1+1:BS=PEEK(O1)
 O1=O1+1:FI=PEEK(O1)
 O1=O1+1:SD=PEEK(O1):GOSUB combat_198 
 FOR V=1TO9:FOR C=1TO4:O1=O1+1:CL(V,C)=PEEK(O1):NEXT C,V
 FOR I=1TO6:O1=O1+1:IG(I)=PEEK(O1):NEXT
 FOR V=1TO9:FORM=1TO5:O1=O1+1:TC(V,M)=PEEK(O1):NEXT M,V:REM PRINT "FIN";TC(VILLE,1);O1;(O1-#A000)
 O1=O1+1:DE=PEEK(O1):GOSUB combat_198 
 O1=O1+1:TL=PEEK(O1):REM PRINT "TL";TL
 O1=O1+1:NP=PEEK(O1)
 O1=O1+1:NF=PEEK(O1)
 O1=O1+1:PM=PEEK(O1):GOSUB combat_198 
 REM IF KEY$<> " " THEN 48297
 RETURN
combat_61
 CLS:PRINT @ 8,12;CHR$(148);CHR$(131);"++ BACK TO MAZE ++ ";CHR$(144)
 O1=#A000:GOSUB combat_199 
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
 O1=O1+1:POKEO1,ET(P):GOSUB combat_198 
 O1=O1+1:POKEO1,OK(P)
 O1=O1+1:POKEO1,NI(P)
 O1=O1+1:DOKEO1,XP(P)
 O1=O1+2:POKEO1,WR(P)
 O1=O1+1:POKEO1,WL(P)
 O1=O1+1:POKEO1,PT(P)
 O1=O1+1:POKEO1,CA(P)
 O1=O1+1:POKEO1,BT(P)::GOSUB combat_198 
 FORI=1TO6:O1=O1+1:POKEO1,SAD(P,I):NEXTI
 IF CP(P)>3 THEN FORI=1TO8:O1=O1+1:POKEO1,SN(P,I):NEXT
 NEXT P
 O1=O1+1:POKEO1,BS
 O1=O1+1:POKEO1,FI
 O1=O1+1:POKEO1,SD
 FOR V=1TO9:FOR C=1TO4:O1=O1+1:POKEO1,CL(V,C):NEXT C,V
 FORI=1TO6:O1=O1+1:POKEO1,IG(I):NEXT:GOSUB combat_198 
 FOR V=1TO9:FORM=1TO5:O1=O1+1:POKEO1,TC(V,M):NEXT M,V:REM PRINT "COMBATS";CO;TC(VILLE,1);O1;(O1-#A000)
 O1=O1+1:POKEO1,DE:GOSUB combat_198 
 O1=O1+1:POKEO1,TL
 O1=O1+1:POKEO1,NP
 O1=O1+1:POKEO1,NF
 O1=O1+1:POKEO1,PM:GOSUB combat_198 
 PING:SAVEU "TEAM.BIN",A#A000,EO1
 CG=0
 RETURN
combat_197
 CLS:PRINT@6,8;".. Loading * Please Wait .."
 S$=CHR$(148)+" "+CHR$(144):CU=1:GOTO combat_198 
combat_199
 CLS:PRINT@6,8;"++ Saving + Please Wait ++"
 S$=CHR$(145)+" "+CHR$(144):CU=1
combat_198
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
 DATA "OK","-Poison-","-Paral- ",">DEAD< "
 DATA Knight,Mercenary,Ranger,Wizard,Maester,Septon
 DATA None,MARTELL,BARATHEON,TYRELL
 DATA GREYJOY,ARRYN,LANNISTER,TULLY,STARK
 DATA 7,6,5,5,4,4,3,3,2,2,1,1
 DATA 75,8, 70,6, 50,5, 80,4, 95,3, 55,2
 DATA 23,Mutant rat, Wolf-dog, Jackal, Goblin, Cut-throat, Beggar, Prowler, Swordsman
 DATA Ogre, Dothrakhi, Giant, Wildling, Lion, Bear
 DATA Fire Warlock, Dark Priestess, Mad Monk
 DATA Demon-Druid, Black Spirit, White Septon
 DATA Grey Elf, Damned Knight, White Walker
 DATA SLEEP, FIRE, STONE, VENOM, BLOOD,  LIGHTNING, LAVA, EARTHQUAKE
 DATA WATER, SERUM, MUSCLE, SHIELD, ELIXIR, SCREEN, LIFE, DEATH
 DATA FIRESWORD, STRENGTH, CHARM, VISION, FREEZE, ILLUSION, WIND, DRAGON
 DATA "I reduce your armor !","** fireballs **","blades rain !","I destroy your weapons !","Healing friends"
