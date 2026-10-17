;--- <<< First Label #define >>>
#define VILLE 4
#include "map_common_ville.s"
	.text



;--- <<< First Label init_div_var >>>
;-----------------------------------------------------------------------------
; -----                initialise divers variables dont:                   ---
;	             coordonnées coin haut gauche partie table affichée      -----
;                     tuile perso affichée / index position perso
;-----------------------------------------------------------------------------
init_div_var
.(
	lda #FALSE
	sta peut_bouger_horiz			; drapeau deplacement horizontal perso dans fenêtre : 0 => pas de déplacement
	sta peut_bouger_vert			; drapeau deplacement vertical  perso dans fenêtre : 0 => pas de déplacement
	sta est_affiche_texte			; drapeau nom ville à l'écran 	1 : nom à l'ecran , 0 rien
	sta scroll_est_interdit			; drapeau scroll autorisé/interdit 	1 : interdit , 0 autorisé
	sta depl_perso_est_interdit			; drapeau déplacement perso autorisé/interdit 	1 : interdit , 0 autorisé
	sta numero_lieu         ; indique lieu <> Gallia (0)
	ldx #VILLE
	lda _team_cles,x
	and #1
	sta on_a_clef_1
	lda _team_cles,x
	and #2
	sta on_a_clef_2
	lda _team_cles,x
	and #4
	sta mot_de_passe
	lda _team_cles,x
	and #8
	sta laisser_passer
	; cache les tuiles spéciales
	; attention, si on les deplace il faudra changer ces adresses !!!
	lda on_a_clef_1
	beq suite_init1
	ldx #15
	lda #0
	sta _L38,x
suite_init1
	lda on_a_clef_2
	beq suite_init2
	ldx #22
	lda #0
	sta _L41,x
suite_init2
	lda mot_de_passe
	beq suite_init2_2
	ldx #19
	lda #0
	sta _L17,x
suite_init2_2
	ldx #VILLE
	lda _team_combats_coffres,x
	and #1
	beq suite_init3
	ldx #28
	lda #0
	sta _L01,x
suite_init3
	ldx #VILLE
	lda _team_combats_coffres,x
	and #2
	beq suite_init4
	ldx #19
	lda #0
	sta _L10,x
suite_init4
	ldx #VILLE
	lda _team_combats_coffres,x
	and #4
	beq suite_init5
	ldx #19
	lda #0
	sta _L23,x
suite_init5
	ldx #VILLE
	lda _team_combats_coffres,x
	and #8
	beq suite_init6
	ldx #13
	lda #0
	sta _L43,x
suite_init6
	lda _team_boat
	sta a_un_bateau			; drapeau bateau : 1 on a un bateau / 0 pas de bateau
	lda _team_out
	beq load_from_team
	lda #$14		; coordonnées pour l'entrée (départ jeu)
	sta ligne_hg_map			; N° de ligne fixe tant que pas de scroll
	lda #$ff
	sta rang_hg_map			; rang ds ligne fixe tant que pas de scroll
	lda #$22
	sta tuile_perso_aff			; code tuile perso affichée
	lda #$2d
	sta index_perso			; valeur index perso dans table adresses hires fenêtre
	lda #$bc
	sta direction_scroll			;  valeurs => ddirection scroll demandée
	lda #$03
	sta ordo_perso_fen			; Abscisse perso dans fenêtre Hires
	lda #$01
	sta absc_perso_fen			; Ordonnée perso dans fenêtre Hires
	lda #0		; repère tuile Nemausus
	sta tuile_sous_pos_perso			; sous position perso au départ
	rts
load_from_team
	lda _team_ligne_hg_ville		; coordonnées pour l'entrée (départ jeu)
	sta ligne_hg_map			; N° de ligne fixe tant que pas de scroll
	lda _team_rang_hg_ville
	sta rang_hg_map			; rang ds ligne fixe tant que pas de scroll
	lda _team_tuile_perso_aff_ville
	sta tuile_perso_aff			; code tuile perso affichée
	lda _team_index_perso_ville
	sta index_perso			; valeur index perso dans table adresses hires fenêtre
	lda #$bc
	sta direction_scroll			;  valeurs => ddirection scroll demandée
	lda _team_x_ville
	sta ordo_perso_fen			; Abscisse perso dans fenêtre Hires
	lda _team_y_ville
	sta absc_perso_fen			; Ordonnée perso dans fenêtre Hires
	lda _team_tuile_sous_pos_perso_ville		; repère tuile Nemausus
	sta tuile_sous_pos_perso			; sous position perso au départ
	rts
.)



;--- <<< First Label chck_around >>>
; -----------------------------------------------------------------------
; ----------  routine regarde autour du perso  pour détection mer  ------
; -----------------------------------------------------------------------
; en entrée :
; en sortie : 	tuile_sous_pos_perso contient valeur tuile sous perso
;				direction_scroll contient #$38 si scroll impossible (perso en bord de carte ou en bord de mer (si a terre)
chck_around
.(
; d'abord on regarde si une touche flêchée a été pressée sinon direction_scroll contient #$38
		lda direction_scroll
		cmp #$38
		beq sortie_scroll_direct		; inutile de regarder si autre touche que flêchée
; puis déterminons la position perso dans la carte
		lda ordo_perso_fen					; ordonnée perso dans fenête hires
		clc
		adc ligne_hg_map					; N° ligne ds table DataMAP en haut gauche fenêtre
		sta ligne_map
		lda absc_perso_fen					; abscisse perso dans fenètre Hires
		clc
		adc rang_hg_map					; rang tuile ds ligne table dataMap en ahut cauche fenêtre
		sta rang_map
; que nous utilisons ensuite pour regarder autour du perso
		lda direction_scroll					; mémoire touche pressée
		cmp #$ac				; recherche contenu tuile à gauche
		bne sens_2
		dec rang_map			; supprimer si retour
		bpl suite_chck_around_1	; bmi no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; le perso était en bord gauche map
suite_chck_around_1
		jsr rech_tab_map		; en sortie  repère tuile dans $0a
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin,on peut soit scroller soit avancer
		bne tuile_speciale			; sinon test situile spéciale
sens_2
		cmp #$bc				; recherche contenu tuile à droite
		bne sens_3
		lda rang_map
		cmp #$1f				; rang tuile en bord droit de map
		bne suite_chck_around_2 ; Le beq no_scroll, plus simple, donne un "Branch out of range"
		jmp no_scroll			; si perso en bord droit, pas de scroll
suite_chck_around_2
		inc rang_map					; si non, on regarde ce qu'il y a à droite
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin
		bne tuile_speciale
sens_3
		cmp #$9c				; recherche contenu tuile au dessus
		bne sens_4
		dec ligne_map			; a supprimer si retour
		bpl suite_sens_3		;Modif dûe à un "branch out of range"
		jmp no_scroll
;		bmi no_scroll
suite_sens_3
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie		; si00 c'est un chemin
		bne tuile_speciale
sens_4
		cmp #$b4				; recherche contenu tuile en dessous
		bne around_sortie
		lda ligne_map
		cmp #$30
		bne cont_b4
		jmp no_scroll
cont_b4
		inc ligne_map
		jsr rech_tab_map		; en sortie  repère tuile dans tuile_courante
		lda tuile_courante
		beq around_sortie
		bne tuile_speciale
around_sortie
		lda #FALSE
		sta scroll_est_interdit				; ré-autorise scroll (pour une boucle dans la direction demandée)
		sta depl_perso_est_interdit				; ré-autorise mvt perso (pour une boucle dans la direction demandée)
sortie_scroll_direct
		rts
;-----------------------------------------------------------------------------
tuile_speciale
		cmp#$51
		bmi no_scroll
		cmp #$52				; have you the right key for gate 1?
;		bmi no_scroll
		bne chck_54
		lda on_a_clef_1
		bne around_sortie		; test: $18 =1 => on a la clef_1	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
chck_54		; clef_1
		lda tuile_courante
		cmp #$54
		bne chck_58
		lda #TRUE
		sta on_a_clef_1					; met à 1 drapeau clef 1
		ldx #VILLE
		lda _team_cles,x
		ora #1
		sta _team_cles,x
		bne around_sortie
chck_58		; a guard ask for pass word
		lda tuile_courante
		cmp #$58				;
		bne chck_57
		lda mot_de_passe
		bne around_sortie		; test:   $1a =1 => on a mot de passe	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
chck_57		; patricienne donne mdp
		lda tuile_courante
		cmp #$57
		bne chck_55
		lda #TRUE
		sta mot_de_passe					; met à 1 drapeau mote de passe
		ldx #VILLE
		lda _team_cles,x
		ora #4
		sta _team_cles,x
		bne around_sortie
chck_55		; clef_2
		lda tuile_courante
		cmp #$55
		bne chck_53
		lda #TRUE
		sta on_a_clef_2			; met à 1 drapeau clef 2
		ldx #VILLE
		lda _team_cles,x
		ora #2
		sta _team_cles,x
		bne around_sortie
chck_53		; have you the rigth key for gate 2?
		lda tuile_courante
		cmp #$53
		bne around_sortie
		lda on_a_clef_2
		bne around_sortie		; test: $19 =1 => on a la clef_2	=> scroll et/ou delplacement autorisés
		jsr why_no_scoll
		beq no_scroll			; branchement forcé par sortie sp précédent
no_scroll
		lda #TRUE
		sta scroll_est_interdit				;mets à 1 drapeau scroll interdit (pour une boucle, dans la direction demandée)
		sta depl_perso_est_interdit				;mets à 1 drapeau mvt perso  interdit (pour une boucle, dans la direction demandée)
		rts
.)
#include "map_common.s"



;--- <<< First Label impl_car >>>
;************************************************
;***   implantation caractères redéfinis      ***
;************************************************ 	peut être lancé séparément pour ne charger dans le jeu
;													que la zone des caractères  une fois rédéfinie
impl_car
.(
	ldx #$00
lp1_impl
	lda dta_car_redef_p1,x
	sta $9d00,x
	inx
	cpx #$FC
	bne lp1_impl
	ldx #$00
lp2_impl
	lda dta_car_redef_p2,x
	sta	$9dfc,x
	inx
	cpx #$FC
	bne lp2_impl
	ldx #$00
lp3_impl
	lda dta_car_redef_p3,x
	sta	$9ef8,x
	inx
	cpx #$fc			;dernier car en $9ff4
	bne lp3_impl
	rts
.)



;--- <<< First Label aff_text >>>
;************************************************
;******* Affiche différents textes   ************
;************************************************
aff_text
.(
;--------------------------------------------------
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$52				; valeur tuile portail traversable avec clef_1
	beq suite_portail
	cmp #$53				; valeur tuile portail traversable avec clef_2
	beq suite_portail	
	jmp key_1
suite_portail	
	ldx #$00
	lda t_portail_1,x
	sta adr_ecr_txt+1
	lda #<t_portail_1+1
	sta write_phrase+1
	lda #>t_portail_1+1
	sta write_phrase+2	
	jsr write_phrase
	ldx #$00
	lda t_portail_2,x
	sta adr_ecr_txt+1
	lda #<t_portail_2+1
	sta write_phrase+1
	lda #>t_portail_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_release_key
	jsr eff_text
;---------------------------------------------------
key_1	
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$54				; valeur tuile clef_1 
	beq suite_clef
	cmp #$55				; valeur tuile clef_2
	beq suite_clef	
	jmp _mot_de_passe
suite_clef
	jsr eff_tuile_spe	
	ldx #$00
	lda t_key_1,x
	sta adr_ecr_txt+1
	lda #<t_key_1+1
	sta write_phrase+1
	lda #>t_key_1+1
	sta write_phrase+2	
	jsr write_phrase
	ldx #$00
	lda t_key_2,x
	sta adr_ecr_txt+1
	lda #<t_key_2+1
	sta write_phrase+1
	lda #>t_key_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_release_key
	jsr eff_text
	ldx #$00
	lda t_key_3,x
	sta adr_ecr_txt+1
	lda #<t_key_3+1
	sta write_phrase+1
	lda #>t_key_3+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_release_key
	jsr eff_text
;-------------------------------------------------------------
_mot_de_passe
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$57				; valeur tuile pour patricienne donne mot de passe
	beq suite_mot_passe
	jmp garde_
suite_mot_passe
	jsr eff_tuile_spe
	ldx #$00
	lda t_m_de_passe_1,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_1+1
	sta write_phrase+1
	lda #>t_m_de_passe_1+1
	sta write_phrase+2
	jsr write_phrase	
	ldx #$00
	lda t_m_de_passe_2,x
	sta adr_ecr_txt+1
	lda #<t_m_de_passe_2+1
	sta write_phrase+1
	lda #>t_m_de_passe_2+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	rts
;-------------------------------------------------
garde_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$58				; valeur tuile pour garde 
	beq suite_garde
	jmp legat_
suite_garde
	jsr eff_tuile_spe
	ldx #$00
	lda t_garde_3,x
	sta adr_ecr_txt+1
	lda #<t_garde_3+1
	sta write_phrase+1
	lda #>t_garde_3+1
	sta write_phrase+2
	jsr write_phrase	
ldx #$00
	lda t_garde_4,x
	sta adr_ecr_txt+1
	lda #<t_garde_4+1
	sta write_phrase+1
	lda #>t_garde_4+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
ldx #$00
	lda t_garde_5,x
	sta adr_ecr_txt+1
	lda #<t_garde_5+1
	sta write_phrase+1
	lda #>t_garde_5+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	rts	
;-------------------------------------------------
legat_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$59				; valeur tuile pour legat qui donne bourse
	beq suite_legat
	jmp entrance_	
suite_legat
	jsr eff_tuile_spe
	lda laisser_passer
	beq suite_legat2
	rts
suite_legat2	
	ldx #VILLE
	lda _team_cles,x
	ora #8
	sta _team_cles,x
	sta laisser_passer
	lda t_legat_1,x
	sta adr_ecr_txt+1
	lda #<t_legat_1+1
	sta write_phrase+1
	lda #>t_legat_1+1
	sta write_phrase+2
	jsr write_phrase	
	ldx #$00
	lda t_legat_2,x
	sta adr_ecr_txt+1
	lda #<t_legat_2+1
	sta write_phrase+1
	lda #>t_legat_2+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	ldx #$00
	lda t_legat_3,x
	sta adr_ecr_txt+1
	lda #<t_legat_3+1
	sta write_phrase+1
	lda #>t_legat_3+1
	sta write_phrase+2
	jsr write_phrase	
	jsr hit_release_key
	jsr eff_text
	; on ajoute 20000 ses = 4e20 en hex 
	clc
	lda _character_ri
	adc #$20
	sta _character_ri
	lda _character_ri+1
	adc #$4e
	sta _character_ri+1
	bcs overflow
	rts
overflow ; on met le max
	lda #$ff
	sta _character_ri
	sta _character_ri+1
	rts
;-------------------------------------------------	
entrance_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$51				; valeur entrée ville
	bne medicus_
	ldx #$00
	lda t_entrance_1,x
	sta adr_ecr_txt+1
	lda #<t_entrance_1+1
	sta write_phrase+1
	lda #>t_entrance_1+1
	sta write_phrase+2	
	jsr write_phrase
	ldx #$00
	lda t_entrance_2,x
	sta adr_ecr_txt+1
	lda #<t_entrance_2+1
	sta write_phrase+1
	lda #>t_entrance_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	jsr retour_map
	jsr eff_text
	rts
;-------------------------------------------------	
medicus_	
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5a				; valeur medicus
	bne armurerie_
	sta type_boutique
	ldx #$00
	lda t_medicus_1,x
	sta adr_ecr_txt+1
	lda #<t_medicus_1+1
	sta write_phrase+1
	lda #>t_medicus_1+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr do_you_enter
	jsr hit_key
	jsr gestion_boutiques
	jsr eff_text
	rts
;-------------------------------------------------
armurerie_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5b				; valeur armurerie
	bne herboriste_
	sta type_boutique
	ldx #$00
	lda t_armurerie_1,x
	sta adr_ecr_txt+1
	lda #<t_armurerie_1+1
	sta write_phrase+1
	lda #>t_armurerie_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr gestion_boutiques
	jsr eff_text
	rts
;-------------------------------------------------
herboriste_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5c				; valeur herboriste
	bne taberna_
	sta type_boutique
	ldx #$00
	lda t_herboriste_1,x
	sta adr_ecr_txt+1
	lda #<t_herboriste_1+1
	sta write_phrase+1
	lda #>t_herboriste_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr gestion_boutiques
	jsr eff_text
	rts
;-------------------------------------------------
taberna_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5e				; valeur auberge
	bne bazar_
	sta type_boutique
	ldx #$00
	lda t_taberna_1,x
	sta adr_ecr_txt+1
	lda #<t_taberna_1+1
	sta write_phrase+1
	lda #>t_taberna_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr gestion_boutiques
	jsr eff_text
;-------------------------------------------------	
bazar_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$5f				; valeur Bazar
	bne coffre_
	sta type_boutique
	ldx #$00
	lda t_bazar_1,x
	sta adr_ecr_txt+1
	lda #<t_bazar_1+1
	sta write_phrase+1
	lda #>t_bazar_1+1
	sta write_phrase+2	
	jsr write_phrase
	jsr do_you_enter
	jsr hit_key
	jsr gestion_boutiques
	jsr eff_text	
;-------------------------------------------------
coffre_
	lda tuile_sous_pos_perso			; valeur tuile sous perso
	cmp #$63				; valeur coffre
	beq suite_coffre
	rts
suite_coffre
	ldx #$00
	lda t_coffre_1,x
	sta adr_ecr_txt+1
	lda #<t_coffre_1+1
	sta write_phrase+1
	lda #>t_coffre_1+1
	sta write_phrase+2	
	jsr write_phrase
	ldx #$00
	lda t_coffre_2,x
	sta adr_ecr_txt+1
	lda #<t_coffre_2+1
	sta write_phrase+1
	lda #>t_coffre_2+1
	sta write_phrase+2	
	jsr write_phrase
	jsr hit_key
	lda direction_scroll
	cmp #$86
	bne sk_ef
	; inc nb_coffres_non_ouverts
	; ajout d'une somme aléatoire
	jsr _random
	clc
	adc _character_ri
	sta _character_ri
	lda _character_ri+1
	adc #0
	sta _character_ri+1
	bcs overflow_coffres
	jmp suite_overflow
overflow_coffres ; on met le max
	lda #$ff
	sta _character_ri
	sta _character_ri+1
suite_overflow
	lda ligne_map
	cmp #1
	bne suite_coffre1
	lda #1
	sta op1
suite_coffre1
	lda ligne_map
	cmp #10
	bne suite_coffre2
	lda #2
	sta op1
suite_coffre2
	lda ligne_map
	cmp #23
	bne suite_coffre3
	lda #4
	sta op1
suite_coffre3
	lda ligne_map
	cmp #43
	bne suite_coffre4
	lda #8
	sta op1
suite_coffre4
	ldx #VILLE
	lda _team_combats_coffres,x
	ora op1
	sta _team_combats_coffres,x
	jsr eff_tuile_spe
sk_ef	
	lda #$38
	sta direction_scroll
	jsr eff_text
	ldx #$00
	lda t_coffre_3,x
	sta adr_ecr_txt+1
	lda #<t_coffre_3+1
	sta write_phrase+1
	lda #>t_coffre_3+1
	sta write_phrase+2	
	jsr write_phrase
;-------------------------------------------------		
fin_txt	
	rts
.)



;--- <<< First Label why_no_scoll >>>
;********************************************************	
;****            routine why no scroll               ****
;********************************************************
why_no_scoll
.(
		lda tuile_courante
		cmp #$52	;portail 1 vous n'avez pas clef_1
		bne chck_wns_58
		jsr no_pasaran
		rts
chck_wns_58		
		cmp #$58	; garde vousn 'avez pas mot de pass
		bne chck_wns_53
		jsr garde_nsc
		rts
chck_wns_53	
		cmp #$53	;portail 2 vous n'avez pas clef_2		
		bne fin_wns
		jsr no_pasaran
		rts
fin_wns
;-------------------------------------
garde_nsc
	ldx #$00
	lda t_garde_1,x
	sta adr_ecr_txt+1
	lda #<t_garde_1+1
	sta write_phrase+1
	lda #>t_garde_1+1
	sta write_phrase+2	
	jsr write_phrase	
	ldx #$00
	lda t_garde_2,x
	sta adr_ecr_txt+1
	lda #<t_garde_2+1
	sta write_phrase+1
	lda #>t_garde_2+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text	
	rts
.)
;-------------------------------------
no_pasaran
.(
	ldx #$00
	lda t_portail_3,x
	sta adr_ecr_txt+1
	lda #<t_portail_3+1
	sta write_phrase+1
	lda #>t_portail_3+1
	sta write_phrase+2	
	jsr write_phrase	
	jsr hit_key
	jsr eff_text
	rts
.)



;--- <<< First Label prt_nom_ville >>>
;************************************************
;***            Ecrit nom  ville            *****
;************************************************	
prt_nom_ville	
	jsr ini_adr_dta_nv
	ldy #$11
prt_lign	
	ldx #$0e
ad_dta_nv
	lda $1111,x
ad_ec_nv	
	sta $BAc5,x
	dex
	bpl ad_dta_nv
	jsr maj_adr_nv
	dey
	bpl prt_lign
	rts	
;------------------------------------------------
ini_adr_dta_nv
	lda #<dta_nom_ville
	sta ad_dta_nv+1
	lda #>dta_nom_ville
	sta ad_dta_nv+2
	lda #$c5
	sta ad_ec_nv+1
	lda #$ba
	sta ad_ec_nv+2
	rts	
;------------------------------------------------
maj_adr_nv
	lda ad_dta_nv+1
	clc
	adc #$0f
	sta ad_dta_nv+1
	bcc sk_ret1
	inc ad_dta_nv+2
sk_ret1
	lda ad_ec_nv+1
	clc
	adc #$28
	sta ad_ec_nv+1
	bcc sk_ret2
	inc ad_ec_nv+2
sk_ret2
	rts	



;--- <<< First Label _L00 >>>
;*******************************************
;*******    DATA PLAN/VILLE 14  ************
;*******************************************
_L00
	.byt $13,$03,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$03,$06,$0e,$1d,$1d,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
_L01
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0f,$10,$1d,$1d,$1d,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$63,$20
_L02
	.byt $04,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$07,$00,$13,$03,$03,$04,$1d,$20,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20
_L03
	.byt $05,$00,$0c,$0b,$0a,$0a,$0a,$0a,$0c,$0b,$0a,$0c,$08,$00,$05,$00,$00,$12,$1d,$1d,$00,$00,$00,$20,$00,$20,$00,$20,$00,$20
_L04
	.byt $04,$00,$0c,$08,$00,$35,$00,$00,$0d,$42,$00,$0d,$42,$00,$04,$00,$00,$01,$03,$04,$1d,$20,$00,$20,$00,$20,$00,$20,$00,$20
_L05
	.byt $05,$00,$0c,$08,$00,$00,$00,$00,$00,$00,$00,$58,$00,$00,$05,$00,$00,$00,$00,$12,$1d,$1d,$00,$20,$00,$20,$00,$20,$00,$20
_L06
	.byt $04,$00,$0c,$08,$59,$0c,$07,$14,$0c,$07,$14,$0c,$07,$00,$04,$00,$13,$02,$00,$01,$04,$1d,$00,$00,$00,$20,$00,$20,$00,$20
_L07
	.byt $05,$00,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$08,$00,$05,$00,$05,$00,$00,$06,$21,$1d,$1d,$20,$00,$20,$00,$20,$00,$20
_L08
	.byt $04,$00,$0d,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$42,$00,$04,$00,$04,$00,$00,$0f,$10,$1d,$1d,$20,$00,$20,$00,$20,$00,$20
_L09
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$05,$00,$00,$00,$12,$1d,$1d,$1d,$00,$00,$00,$20,$00,$20
_L10
	.byt $13,$53,$03,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$00,$00,$04,$00,$04,$63,$12,$1d,$1d,$1d,$00,$20,$00,$20,$00,$20
_L11
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$07,$1d,$1d,$20,$00,$20,$00,$20
_L12
	.byt $04,$00,$13,$03,$04,$00,$13,$45,$04,$00,$13,$03,$04,$00,$00,$0c,$0b,$0a,$0a,$0a,$0a,$0c,$08,$41,$1d,$1d,$00,$20,$00,$20
_L13
	.byt $05,$00,$12,$00,$12,$00,$12,$5b,$12,$00,$12,$00,$05,$00,$00,$0c,$08,$00,$00,$00,$14,$0c,$08,$41,$1d,$1d,$00,$20,$00,$20
_L14
	.byt $13,$03,$11,$00,$05,$00,$12,$00,$12,$00,$12,$00,$04,$00,$00,$0d,$42,$00,$06,$0e,$00,$0d,$42,$41,$1d,$1d,$00,$20,$00,$20
_L15
	.byt $05,$00,$00,$00,$13,$03,$11,$00,$13,$03,$11,$00,$13,$02,$00,$00,$00,$00,$0f,$10,$00,$00,$00,$62,$62,$62,$00,$20,$00,$20
_L16
	.byt $04,$00,$04,$00,$05,$00,$00,$00,$05,$00,$00,$00,$12,$00,$00,$0c,$07,$00,$00,$00,$00,$0c,$07,$20,$1d,$1d,$00,$00,$00,$20
_L17
	.byt $05,$00,$05,$00,$04,$00,$04,$00,$04,$00,$04,$00,$05,$00,$00,$0c,$08,$00,$00,$57,$14,$0c,$08,$20,$1d,$1d,$20,$20,$00,$20
_L18
	.byt $04,$00,$04,$00,$05,$00,$05,$00,$05,$00,$05,$00,$00,$00,$00,$06,$06,$06,$06,$06,$06,$06,$08,$20,$1d,$1d,$00,$00,$00,$20
_L19
	.byt $05,$00,$05,$00,$04,$00,$04,$00,$04,$00,$13,$03,$13,$03,$04,$0d,$0a,$0a,$0a,$0a,$0a,$0a,$04,$5e,$1d,$1d,$00,$20,$20,$20
_L20
	.byt $04,$00,$04,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$00,$00,$13,$03,$02,$00,$01,$04,$1d,$1d,$00,$00,$00,$20
_L21
	.byt $12,$00,$12,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$12,$00,$00,$00,$00,$01,$04,$1d,$1d,$20,$00,$20
_L22
	.byt $05,$00,$11,$00,$05,$00,$05,$00,$11,$00,$05,$00,$05,$00,$05,$00,$05,$00,$12,$00,$04,$00,$00,$00,$12,$1d,$1d,$20,$00,$20
_L23
	.byt $51,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$12,$63,$12,$00,$04,$00,$12,$1d,$1d,$20,$00,$20
_L24
	.byt $04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$13,$03,$11,$00,$13,$03,$11,$00,$05,$00,$12,$1d,$1d,$20,$00,$20
_L25
	.byt $12,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$04,$00,$12,$00,$00,$00,$00,$00,$12,$1d,$1d,$20,$00,$20
_L26
	.byt $05,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$12,$00,$12,$00,$00,$00,$00,$06,$21,$1d,$1d,$20,$00,$20
_L27
	.byt $04,$00,$05,$00,$05,$00,$05,$00,$05,$00,$13,$02,$01,$02,$05,$00,$01,$03,$03,$02,$01,$02,$00,$0f,$10,$1d,$1d,$20,$00,$20
_L28
	.byt $05,$00,$04,$00,$04,$00,$04,$00,$04,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$1d,$1d,$20,$00,$20
_L29
	.byt $04,$00,$13,$03,$11,$00,$13,$02,$01,$02,$01,$02,$01,$02,$01,$02,$00,$13,$02,$01,$02,$01,$02,$13,$11,$1d,$20,$00,$00,$20
_L30
	.byt $05,$00,$05,$00,$00,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$12,$1d,$1d,$00,$00,$00,$20
_L31
	.byt $04,$00,$04,$00,$13,$03,$12,$00,$13,$03,$04,$00,$13,$45,$04,$00,$00,$00,$00,$01,$02,$00,$13,$11,$1d,$1d,$00,$20,$00,$20
_L32
	.byt $05,$00,$05,$00,$12,$00,$05,$00,$12,$00,$12,$00,$12,$5c,$12,$00,$00,$04,$00,$00,$00,$00,$12,$1d,$1d,$20,$00,$20,$00,$20
_L33
	.byt $04,$00,$04,$00,$05,$00,$00,$00,$05,$00,$05,$00,$12,$00,$01,$03,$03,$03,$02,$01,$02,$13,$11,$1d,$1d,$20,$00,$20,$00,$20
_L34
	.byt $05,$00,$05,$00,$04,$00,$04,$00,$04,$00,$04,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$12,$1d,$1d,$00,$00,$00,$20,$00,$20
_L35
	.byt $04,$00,$04,$00,$05,$00,$05,$00,$05,$00,$05,$00,$01,$03,$02,$00,$01,$02,$00,$00,$13,$11,$1d,$1d,$00,$20,$00,$20,$00,$20
_L36
	.byt $05,$00,$05,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$21,$1d,$1d,$20,$00,$20,$00,$20,$20,$20
_L37
	.byt $04,$00,$13,$03,$02,$01,$11,$01,$02,$01,$02,$01,$02,$01,$13,$03,$02,$00,$00,$2c,$10,$1d,$1d,$20,$20,$20,$00,$20,$00,$20
_L38
	.byt $05,$00,$12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$54,$00,$00,$13,$11,$1d,$1d,$00,$00,$00,$20,$00,$20,$00,$20
_L39
	.byt $13,$03,$11,$00,$01,$02,$01,$02,$01,$02,$01,$03,$04,$00,$05,$00,$00,$13,$11,$1d,$1d,$13,$52,$04,$00,$20,$00,$20,$00,$20
_L40
	.byt $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$00,$00,$00,$13,$11,$1d,$1d,$13,$11,$00,$12,$00,$20,$00,$20,$00,$20
_L41
	.byt $04,$00,$00,$01,$45,$03,$45,$03,$45,$03,$04,$00,$01,$04,$00,$13,$11,$1d,$1d,$13,$11,$00,$55,$12,$00,$20,$00,$00,$00,$20
_L42
	.byt $05,$00,$00,$00,$5f,$00,$5e,$00,$5a,$00,$12,$00,$00,$05,$00,$12,$1d,$1d,$20,$01,$03,$03,$03,$11,$00,$20,$20,$20,$00,$20
_L43
	.byt $04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$63,$13,$11,$1d,$1d,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20
_L44
	.byt $01,$03,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$02,$01,$11,$1d,$1d,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
ptr_Lignes
	.byt <_L00,>_L00,<_L01,>_L01,<_L02,>_L02,<_L03,>_L03,<_L04,>_L04,<_L05,>_L05,<_L06,>_L06,<_L07,>_L07,<_L08,>_L08,<_L09,>_L09
	.byt <_L10,>_L10,<_L11,>_L11,<_L12,>_L12,<_L13,>_L13,<_L14,>_L14,<_L15,>_L15,<_L16,>_L16,<_L17,>_L17,<_L18,>_L18,<_L19,>_L19
	.byt <_L20,>_L20,<_L21,>_L21,<_L22,>_L22,<_L23,>_L23,<_L24,>_L24,<_L25,>_L25,<_L26,>_L26,<_L27,>_L27,<_L28,>_L28,<_L29,>_L29
	.byt <_L30,>_L30,<_L31,>_L31,<_L32,>_L32,<_L33,>_L33,<_L34,>_L34,<_L35,>_L35,<_L36,>_L36,<_L37,>_L37,<_L38,>_L38,<_L39,>_L39
	.byt <_L40,>_L40,<_L41,>_L41,<_L42,>_L42,<_L43,>_L43,<_L44,>_L44



;--- <<< First Label _t00 >>>
; --------------------------------------------------------------------
;    Table redefinition  des tuiles (N)d'ordre des 4 car redefinis
; --------------------------------------------------------------------
_t00 
		.byt $00,$00,$00,$00 
_t01 
		.byt $01,$01,$02,$03 
_t02 
		.byt $01,$04,$03,$05 
_t03 
		.byt $01,$01,$06,$03 
_t04 
		.byt $07,$04,$07,$08 
_t05 
		.byt $07,$08,$02,$05 
_t06 
		.byt $09,$0a,$0b,$0c 
_t07 
		.byt $04,$00,$08,$00 
_t08 
		.byt $08,$00,$08,$00 
_t09 
		.byt $03,$05,$00,$00 
_t0a 
		.byt $06,$03,$00,$00 
_t0b 
		.byt $0d,$03,$08,$00 
_t0c 
		.byt $0e,$0f,$0e,$0f 
_t0d 
		.byt $02,$03,$00,$00 
_t0e 
		.byt $04,$00,$08,$04 
_t0f 
		.byt $02,$03,$00,$02 
_t10 
		.byt $05,$08,$03,$05 
_t11 
		.byt $07,$08,$03,$05 
_t12 
		.byt $07,$08,$07,$08 
_t13 
		.byt $01,$01,$07,$10 
_t14 
		.byt $11,$12,$13,$14 
_t15 
		.byt $15,$15,$15,$16 
_t16 
		.byt $15,$15,$17,$16 
_t17 
		.byt $15,$15,$17,$15 
_t18 
		.byt $15,$19,$15,$16 
_t19 
		.byt $15,$19,$15,$15 
_t1a 
		.byt $18,$19,$15,$15 
_t1b 
		.byt $18,$15,$15,$15 
_t1c 
		.byt $18,$15,$17,$15 
_t1d 
		.byt $18,$19,$17,$16 
_t1e 
		.byt $00,$00,$1a,$00 
_t1f 
		.byt $00,$1b,$00,$1c 
_t20 
		.byt $1d,$1e,$1f,$20 
_t21 
		.byt $08,$08,$08,$08 
_t22 
		.byt $21,$22,$23,$24 
_t23 
		.byt $21,$25,$26,$27 
_t24 
		.byt $28,$29,$2a,$2b 
_t25 
		.byt $2c,$2d,$2e,$2f 
_t26 
		.byt $30,$31,$32,$33 
_t27 
		.byt $30,$34,$35,$36 
_t28 
		.byt $37,$38,$39,$3a 
_t29 
		.byt $37,$3b,$3c,$3d 
_t2a 
		.byt $42,$43,$08,$08 
_t2b 
		.byt $44,$44,$08,$08 
_t2c 
		.byt $02,$03,$07,$1a 
_t2d 
		.byt $40,$48,$41,$49 
_t2e 
		.byt $4a,$00,$4b,$00 
_t2f 
		.byt $4c,$00,$4d,$00 
_t30 
		.byt $4e,$00,$4f,$00 
_t31 
		.byt $18,$19,$16,$63 
_t32 
		.byt $53,$53,$08,$08 
_t33 
		.byt $54,$55,$00,$56 
_t34 
		.byt $57,$08,$58,$08 
_t35 
		.byt $0a,$5a,$5b,$5c 
_t36 
		.byt $00,$00,$5d,$5e 
_t37 
		.byt $5f,$60,$61,$5e 
_t38 
		.byt $00,$62,$00,$5e 
_t39 
		.byt $63,$63,$64,$65 
_t3a 
		.byt $63,$63,$66,$65 
_t3b 
		.byt $63,$63,$67,$63 
_t3c 
		.byt $63,$63,$64,$63 
_t3d 
		.byt $16,$63,$19,$63 
_t3e 
		.byt $16,$63,$63,$63 
_t3f 
		.byt $63,$00,$63,$00 
_t40 
		.byt $63,$00,$00,$00 
_t41 
		.byt $68,$69,$19,$18 
_t42 
		.byt $05,$00,$00,$00 
_t43 
		.byt $0b,$0b,$02,$03 
_t44 
		.byt $08,$00,$05,$00 
_t45 
		.byt $01,$01,$6a,$6b 
_t46 
		.byt $17,$16,$63,$63 
_t47 
		.byt $00,$00,$00,$00 
_t48 
		.byt $00,$00,$00,$00 
_t49 
		.byt $00,$00,$00,$00 
_t4a 
		.byt $00,$00,$00,$00 
_t4b 
		.byt $00,$00,$00,$00 
_t4c 
		.byt $00,$00,$00,$00 
_t4d 
		.byt $00,$00,$00,$00 
_t4e 
		.byt $00,$00,$00,$00 
_t4f 
		.byt $00,$00,$00,$00 
_t50 
		.byt $00,$00,$00,$00 
_t51 
		.byt $00,$00,$00,$00 ; Entrée ville 
_t52 
		.byt $01,$01,$3e,$3f 
_t53 
		.byt $01,$01,$3e,$3f 
_t54 
		.byt $59,$00,$00,$00 
_t55 
		.byt $00,$00,$00,$59 
_t56 
		.byt $00,$00,$00,$00 ; gardien port 
_t57 
		.byt $00,$00,$00,$00 ; Mot de passe 
_t58 
		.byt $00,$00,$00,$00 ; garde 
_t59 
		.byt $00,$00,$00,$00 ; Legat 
_t5a 
		.byt $00,$00,$00,$00 ; Medicus 
_t5b 
		.byt $00,$00,$00,$00 ; Faber armorum 
_t5c 
		.byt $00,$00,$00,$00 ; Herbarius 
_t5d 
		.byt $00,$00,$00,$00 ; Omnia animalia 
_t5e 
		.byt $00,$00,$00,$00 ; Taberna 
_t5f 
		.byt $00,$00,$00,$00 ; Bazar 
_t60 
		.byt $00,$00,$00,$00 ; Navis venalis 
_t61 
		.byt $00,$00,$00,$00 ; Quai 
_t62 
		.byt $6c,$6d,$6c,$6d 
_t63 
		.byt $7a,$7b,$7c,$7d ; coffre 



;--- <<< First Label ptr_t >>>
; -----------------------------------------------
;       Table des pointeurs adresse tuiles  
; -----------------------------------------------
ptr_t ;(pointeurs t pour tuiles)
	.byt <_t00,>_t00,<_t01,>_t01,<_t02,>_t02,<_t03,>_t03,<_t04,>_t04,<_t05,>_t05
	.byt <_t06,>_t06,<_t07,>_t07,<_t08,>_t08,<_t09,>_t09,<_t0a,>_t0a,<_t0b,>_t0b
	.byt <_t0c,>_t0c,<_t0d,>_t0d,<_t0e,>_t0e,<_t0f,>_t0f,<_t10,>_t10,<_t11,>_t11
	.byt <_t12,>_t12,<_t13,>_t13,<_t14,>_t14,<_t15,>_t15,<_t16,>_t16,<_t17,>_t17
	.byt <_t18,>_t18,<_t19,>_t19,<_t1a,>_t1a,<_t1b,>_t1b,<_t1c,>_t1c,<_t1d,>_t1d
	.byt <_t1e,>_t1e,<_t1f,>_t1f,<_t20,>_t20,<_t21,>_t21,<_t22,>_t22,<_t23,>_t23
	.byt <_t24,>_t24,<_t25,>_t25,<_t26,>_t26,<_t27,>_t27,<_t28,>_t28,<_t29,>_t29
	.byt <_t2a,>_t2a,<_t2b,>_t2b,<_t2c,>_t2c,<_t2d,>_t2d,<_t2e,>_t2e,<_t2f,>_t2f
	.byt <_t30,>_t30,<_t31,>_t31,<_t32,>_t32,<_t33,>_t33,<_t34,>_t34,<_t35,>_t35
	.byt <_t36,>_t36,<_t37,>_t37,<_t38,>_t38,<_t39,>_t39,<_t3a,>_t3a,<_t3b,>_t3b
	.byt <_t3c,>_t3c,<_t3d,>_t3d,<_t3e,>_t3e,<_t3f,>_t3f,<_t40,>_t40,<_t41,>_t41
	.byt <_t42,>_t42,<_t43,>_t43,<_t44,>_t44,<_t45,>_t45,<_t46,>_t46,<_t47,>_t47
	.byt <_t48,>_t48,<_t49,>_t49,<_t4a,>_t4a,<_t4b,>_t4b,<_t4c,>_t4c,<_t4d,>_t4d
	.byt <_t4e,>_t4e,<_t4f,>_t4f,<_t50,>_t50,<_t51,>_t51,<_t52,>_t52,<_t53,>_t53
	.byt <_t54,>_t54,<_t55,>_t55,<_t56,>_t56,<_t57,>_t57,<_t58,>_t58,<_t59,>_t59
	.byt <_t5a,>_t5a,<_t5b,>_t5b,<_t5c,>_t5c,<_t5d,>_t5d,<_t5e,>_t5e,<_t5f,>_t5f
	.byt <_t60,>_t60,<_t61,>_t61,<_t62,>_t62,<_t63,>_t63



;--- <<< First Label t_portail_1 >>>
; -----------------------------------------------------------------------------
;                   proposition de textes pour tuiles spéciales
; -----------------------------------------------------------------------------
t_portail_1
	.byt $99
	.asc "You've got the right key",0
t_portail_2	
	.byt $c6 
	.asc "You can cross.",0
t_portail_3
	.byt $96
	.asc "You don't have the right key.",0	
; ------------------------------------	
t_key_1
	.byt $9c
	.asc "You've found a key.",0 ;(key_1)
t_key_2	
	.byt $c2	
	.asc "Now all you have to do",0
t_key_3	
	.byt $9a	
	.asc "is find the right door.",0
; ------------------------------------	
t_port_guard_1
	.byt $93
	.asc "The guard will only allow you access",0
t_port_guard_2	
	.byt $bb	
	.asc "to the pier if you present your pass",0
t_port_guard_3
	.byt $95
	.asc "After seeing your pass, the guard",0
t_port_guard_4	
	.byt $bf	
	.asc "gives you access to the piers.",0	
; ------------------------------------	
t_m_de_passe_1
	.byt $96
	.asc "There is a plaque on the wall",0
t_m_de_passe_2	
	.byt $C4	
	.asc "It reads 'veritas'.",0
; ------------------------------------
t_garde_1
	.byt $9a
	.asc "A guard says 'In vino'",0
t_garde_2
	.byt $bd
	.asc "And is waiting for your answer.",0
t_garde_3
	.byt $9a
	.asc "A guard says 'In vino'",0	
t_garde_4
	.byt $c5
	.asc "You say 'veritas'",0
t_garde_5
	.byt $9a
	.asc "the guard lets you in.",0	
; ------------------------------------
t_legat_1
	.byt $94
	.asc "On orders received from Antoninus,",0
t_legat_2
	.byt $be	
	.asc "the legate gives you a  purse",0
t_legat_3
	.byt $9b	
	.asc "of 10,000 sesterces",0	
; ------------------------------------	
t_entrance_1
	.byt $99	
	.asc "The entrance to the city,",0
t_entrance_2	
	.byt $c3	
	.asc "do you want to leave?",0
; ------------------------------------	
t_do_you_1
	.byt $c6	
	.asc "do you enter?",0	
; ------------------------------------	
t_medicus_1
	.byt $a1	
	.asc "MEDICUS",0
; ------------------------------------	
t_armurerie_1
	.byt $9e	
	.asc "FABER ARMORUM",0
; ------------------------------------	
t_herboriste_1
	.byt $a0	
	.asc "HERBARIUS",0
; ------------------------------------
t_taberna_1
	.byt $a1	
	.asc "TABERNA",0
; ------------------------------------	
t_bazar_1
	.byt $a2	
	.asc "bazar",0
; ------------------------------------
t_coffre_1
	.byt $9d	
	.asc "You find a chest,",0
t_coffre_2
	.byt $c6	
	.asc "do you open it?",0
t_coffre_3
	.byt $9b	
	.asc "You find some coins!",0	
; ------------------------------------
dta_bandeau		
	.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$00,$04,$02,$44,$00,$04,$00,$04,$00,$04,$00,$04,$40,$03,$7F,$5C,$00,$04,$00,$04,$00,$04,$00,$04,$00,$02,$48,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$03,$40,$4F,$00,$04,$00,$04,$00,$04,$00,$04,$07,$40,$6E,$74,$00,$04,$00,$04,$00,$04,$00,$04,$03,$40,$7C,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$02,$40,$5F,$60,$00,$04,$00,$04,$00,$04,$40,$40,$03,$4F,$50,$00,$04,$00,$04,$00,$04,$00,$04,$02,$41,$7E,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$03,$40,$5F,$64,$00,$04,$00,$04,$00,$04,$07,$40,$41,$7E,$6E,$00,$04,$00,$04,$00,$04,$00,$03,$40,$49,$7E,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$02,$40,$4F,$76,$00,$04,$00,$04,$00,$04,$03,$40,$47,$5F,$5B,$60,$00,$04,$00,$04,$00,$04,$02,$40,$5B,$7C,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$03,$40,$43,$7F,$13,$10,$00,$04,$00,$04,$00,$07,$40,$4E,$5E,$69,$70,$00,$04,$00,$04,$00,$04,$40,$40,$13,$00,$4F,$10,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$41,$7B,$12,$10,$00,$04,$00,$04,$00,$03,$40,$4C,$5F,$58,$70,$00,$04,$00,$04,$00,$04,$40,$02,$7F,$77,$60,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$03,$40,$7D,$6F,$00,$04,$00,$04,$00,$04,$07,$40,$4C,$4E,$70,$70,$00,$04,$00,$04,$00,$04,$03,$40,$7D,$6F,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$40,$02,$40,$5F,$5E,$00,$04,$02,$44,$00,$04,$03,$40,$58,$4F,$50,$58,$00,$04,$00,$02,$48,$00,$02,$40,$5E,$7E,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$03,$4E,$78,$00,$03,$40,$44,$00,$04,$07,$40,$58,$4E,$70,$58,$00,$04,$03,$40,$48,$02,$03,$40,$47,$5C,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$02,$40,$66,$7F,$70,$00,$02,$6E,$00,$04,$03,$40,$50,$5F,$58,$48,$00,$04,$02,$40,$5D,$40,$40,$43,$7F,$59,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$03,$40,$7E,$77,$60,$40,$41,$7E,$00,$04,$07,$40,$58,$5F,$68,$58,$00,$04,$03,$40,$5F,$60,$40,$41,$7B,$5F,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$02,$40,$5F,$57,$4F,$40,$40,$12,$10,$00,$03,$40,$4C,$7F,$54,$70,$00,$04,$40,$40,$12,$10,$02,$7C,$7A,$7E,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$00,$03,$40,$5C,$4E,$5E,$40,$60,$7F,$44,$00,$07,$40,$47,$7F,$6B,$60,$00,$04,$03,$48,$7F,$41,$40,$5E,$5C,$4E,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$41,$7F,$5F,$7E,$40,$71,$7F,$6E,$00,$03,$40,$43,$7F,$75,$00,$04,$02,$40,$5D,$7F,$63,$40,$5F,$7E,$7F,$60,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$03,$40,$43,$7F,$7F,$7C,$40,$7B,$6E,$7E,$00,$07,$40,$5F,$7F,$7A,$78,$00,$03,$40,$5F,$5D,$77,$40,$4F,$7F,$7F,$70,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$47,$60,$61,$70,$40,$7E,$75,$7C,$00,$03,$40,$5F,$7F,$7D,$58,$00,$02,$40,$4F,$6B,$5F,$40,$43,$61,$41,$78,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$02,$41,$7C,$00,$03,$5F,$5B,$5C,$00,$7F,$7F,$87,$7F,$7A,$6C,$00,$03,$40,$4E,$76,$7E,$40,$02,$4F,$60,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$05,$12,$00,$4F,$7F,$60,$45,$46,$10,$7F,$04,$13,$00,$42,$69,$10,$02,$40,$67,$57,$7E,$40,$43,$7F,$7F,$00,$04,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$43,$78,$5B,$7E,$03,$4F,$6D,$7F,$60,$07,$41,$7F,$7F,$7E,$6A,$00,$03,$41,$7F,$6D,$7C,$02,$5F,$76,$47,$70,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$4F,$40,$48,$4F,$60,$47,$7B,$5F,$00,$03,$41,$7F,$7F,$7F,$56,$00,$02,$40,$7E,$77,$78,$41,$7C,$44,$40,$7C,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$5C,$40,$48,$41,$78,$03,$7D,$7E,$00,$07,$41,$7F,$7F,$7E,$6A,$00,$03,$40,$5F,$6F,$02,$47,$60,$44,$40,$4E,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$02,$40,$70,$05,$48,$02,$4E,$41,$7F,$78,$00,$03,$41,$7F,$7F,$7F,$56,$00,$02,$40,$47,$7F,$60,$4C,$05,$44,$02,$43,$00,$04,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$02,$40,$43,$60,$05,$4C,$02,$47,$03,$7F,$02,$58,$07,$41,$7F,$7F,$7E,$6A,$00,$03,$46,$41,$7F,$02,$58,$05,$4C,$02,$41,$70,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$47,$40,$05,$53,$02,$41,$78,$4B,$40,$64,$03,$41,$7F,$7F,$7F,$56,$02,$40,$49,$40,$74,$47,$70,$05,$72,$40,$02,$78,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$4E,$05,$41,$6C,$70,$02,$4E,$58,$40,$62,$07,$41,$7F,$7F,$7E,$6A,$40,$02,$51,$40,$46,$5C,$05,$43,$4D,$60,$02,$5C,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$4C,$05,$42,$4A,$78,$02,$43,$70,$40,$52,$40,$04,$FF,$13,$00,$69,$10,$02,$52,$40,$43,$70,$05,$47,$54,$50,$02,$4C,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$4C,$05,$45,$67,$48,$40,$02,$7C,$40,$44,$40,$40,$87,$7F,$7E,$6A,$40,$02,$48,$40,$4F,$40,$05,$44,$79,$68,$02,$4C,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$5C,$05,$45,$6D,$60,$40,$02,$4B,$60,$48,$40,$04,$13,$00,$42,$6B,$10,$02,$44,$41,$74,$40,$05,$41,$6D,$68,$02,$4E,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$5C,$05,$41,$50,$6C,$40,$02,$44,$5E,$7C,$07,$40,$5F,$7F,$7E,$6C,$40,$02,$4F,$5E,$48,$40,$05,$4D,$42,$60,$02,$4E,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$5C,$05,$46,$5A,$54,$40,$02,$43,$63,$63,$60,$03,$5F,$7F,$7D,$54,$02,$41,$71,$71,$70,$40,$05,$4A,$56,$58,$02,$4E,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$5C,$05,$45,$65,$48,$40,$03,$5F,$7C,$02,$58,$07,$5F,$7F,$7A,$68,$02,$46,$03,$4F,$7E,$40,$05,$44,$69,$68,$02,$4E,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$54,$05,$42,$5D,$68,$02,$43,$7A,$7E,$40,$44,$03,$4F,$7F,$7D,$50,$02,$48,$40,$5F,$57,$70,$05,$45,$6E,$50,$02,$4A,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$48,$05,$41,$61,$40,$03,$47,$77,$5F,$02,$54,$07,$4F,$7F,$7A,$70,$03,$4A,$40,$7E,$7B,$78,$40,$05,$61,$60,$02,$44,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$02,$40,$4C,$05,$41,$6A,$70,$02,$4B,$6E,$6E,$60,$6A,$03,$47,$7F,$75,$60,$02,$55,$41,$5D,$5D,$74,$05,$43,$55,$60,$02,$4C,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$05,$5A,$40,$03,$51,$7E,$7C,$02,$62,$07,$43,$7F,$7B,$40,$02,$51,$03,$4F,$5F,$62,$40,$05,$56,$40,$40,$40,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$05,$41,$65,$60,$02,$47,$77,$7C,$40,$5C,$03,$43,$7F,$75,$40,$02,$4E,$40,$4F,$7B,$78,$05,$41,$69,$60,$40,$40,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$05,$59,$60,$03,$43,$7E,$7E,$40,$40,$07,$41,$7F,$6A,$40,$40,$40,$03,$5F,$5F,$70,$05,$41,$66,$40,$40,$40,$00,$04,$00,$04,$0
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$05,$42,$40,$02,$41,$5D,$6F,$40,$40,$03,$41,$7F,$56,$40,$40,$40,$02,$7D,$6E,$60,$40,$05,$50,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$05,$47,$40,$40,$03,$5B,$7F,$60,$40,$40,$40,$87,$6C,$40,$40,$03,$41,$7F,$76,$40,$40,$05,$78,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$05,$42,$40,$40,$02,$7E,$7F,$40,$40,$40,$03,$5F,$58,$40,$40,$40,$02,$7F,$5F,$40,$40,$05,$50,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$03,$7F,$58,$40,$40,$40,$07,$4E,$70,$40,$40,$40,$03,$46,$7F,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$02,$4F,$70,$40,$40,$40,$03,$47,$60,$40,$40,$40,$02,$43,$7C,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$03,$47,$70,$40,$40,$40,$07,$46,$60,$40,$40,$40,$03,$43,$78,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$40,$40,$40,$40,$40,$02,$41,$70,$40,$40,$40,$03,$4F,$50,$40,$40,$40,$02,$43,$60,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$40,$40,$40,$40,$40,$40,$02,$60,$40,$40,$40,$07,$4E,$70,$40,$40,$40,$02,$41,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$03,$4F,$50,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$4
	.byt $00,$04,$00,$04,$00,$04,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$07,$5F,$68,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$00,$04,$00,$04,$0a
;--------------------------------------------------	
dta_nom_ville
	.byt $1,$40,$40,$40,$40,$40,$40,$47,$4E,$40,$40,$40,$47,$40,$40
	.byt $1,$47,$7C,$40,$40,$40,$40,$47,$4E,$40,$40,$40,$47,$40,$40
	.byt $1,$47,$7F,$40,$40,$40,$40,$47,$4E,$40,$40,$40,$47,$40,$40
	.byt $1,$47,$47,$40,$40,$40,$40,$47,$40,$40,$40,$40,$47,$40,$40
	.byt $1,$47,$47,$47,$47,$4E,$71,$77,$4E,$47,$7C,$7F,$47,$47,$78
	.byt $1,$47,$47,$47,$47,$4F,$73,$7F,$4E,$5F,$79,$7F,$67,$4F,$7C
	.byt $1,$47,$7C,$47,$47,$4F,$47,$6F,$4E,$58,$71,$43,$67,$48,$5C
	.byt $1,$47,$7F,$47,$47,$4E,$47,$47,$4E,$58,$70,$43,$67,$40,$5C
	.byt $1,$47,$47,$67,$47,$4E,$47,$47,$4E,$58,$70,$7F,$67,$47,$7C
	.byt $1,$47,$43,$67,$47,$4E,$47,$47,$4E,$5F,$71,$7F,$67,$4F,$7C
	.byt $1,$47,$43,$67,$47,$4E,$47,$47,$4E,$5F,$61,$73,$67,$4E,$5C
	.byt $1,$47,$47,$67,$4F,$4E,$47,$6F,$4E,$58,$41,$73,$67,$4E,$5C
	.byt $1,$47,$7F,$47,$7F,$4E,$43,$7F,$4E,$5F,$71,$7F,$67,$4F,$7C
	.byt $1,$47,$7E,$43,$77,$4E,$41,$77,$4E,$5F,$78,$7F,$67,$47,$7C
	.byt $1,$40,$40,$40,$40,$40,$40,$40,$40,$78,$58,$40,$40,$40,$0
	.byt $1,$40,$40,$40,$40,$40,$40,$40,$40,$78,$58,$40,$40,$40,$40
	.byt $1,$40,$40,$40,$40,$40,$40,$40,$40,$5F,$78,$40,$40,$40,$40
	.byt $1,$40,$40,$40,$40,$40,$40,$40,$40,$4F,$60,$40,$40,$40,$40



;--- <<< First Label dta_car_redef_p1 >>>
; -----------------------------------------------
;       Table redéfinition  2nd jeu de car
; -----------------------------------------------
dta_car_redef_p1
;00 en $9d00
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;01 en $9d06
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
;02 en $9d0c
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $49	;0,1,0,0,1,0,0,1
	.byt $f8	;1,1,1,1,1,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $fe	;1,1,1,1,1,1,1,0
;03 en $9d12
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $79	;0,1,1,1,1,0,0,1
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $c6	;1,1,0,0,0,1,1,0
;04 en $9d18
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;05 en $9d1e
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $da	;1,1,0,1,1,0,1,0
	.byt $72	;0,1,1,1,0,0,1,0
	.byt $c6	;1,1,0,0,0,1,1,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $c1	;1,1,0,0,0,0,0,1
;06 en $9d24
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $c8	;1,1,0,0,1,0,0,0
	.byt $7b	;0,1,1,1,1,0,1,1
	.byt $c3	;1,1,0,0,0,0,1,1
;07 en $9d2a
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
;08 en $9d30
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;09 en $9d36
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;0A en $9d3c
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0
;0B en $9d42
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
;0C en $9d48
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $cc	;1,1,0,0,1,1,0,0
;0D en $9d4e
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $e8	;1,1,1,0,1,0,0,0
	.byt $6b	;0,1,1,0,1,0,1,1
	.byt $eb	;1,1,1,0,1,0,1,1
;0E en $9d54
	.byt $d9	;1,1,0,1,1,0,0,1
	.byt $e6	;1,1,1,0,0,1,1,0
	.byt $d9	;1,1,0,1,1,0,0,1
	.byt $e6	;1,1,1,0,0,1,1,0
	.byt $d9	;1,1,0,1,1,0,0,1
	.byt $e6	;1,1,1,0,0,1,1,0
;0F en $9d5a
	.byt $ec	;1,1,1,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $ec	;1,1,1,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $ec	;1,1,1,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
;10 en $9d60
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $e8	;1,1,1,0,1,0,0,0
	.byt $6b	;0,1,1,0,1,0,1,1
	.byt $ea	;1,1,1,0,1,0,1,0
;11 en $9d66
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $66	;0,1,1,0,0,1,1,0
	.byt $43	;0,1,0,0,0,0,1,1
;12 en $9d6c
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $50	;0,1,0,1,0,0,0,0
;13 en $9d72
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0
;14 en $9d78
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $7d	;0,1,1,1,1,1,0,1
	.byt $7e	;0,1,1,1,1,1,1,0
	.byt $7d	;0,1,1,1,1,1,0,1
;15 en $9d7e
	.byt $77	;0,1,1,1,0,1,1,1
	.byt $dc	;1,1,0,1,1,1,0,0
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $6e	;0,1,1,0,1,1,1,0
	.byt $c2	;1,1,0,0,0,0,1,0
;16 en $9d84
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $fd	;1,1,1,1,1,1,0,1
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $e7	;1,1,1,0,0,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
;17 en $9d8a
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $fb	;1,1,1,1,1,0,1,1
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $f7	;1,1,1,1,0,1,1,1
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $cf	;1,1,0,0,1,1,1,1
;18 en $9d90
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $fe	;1,1,1,1,1,1,1,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $fd	;1,1,1,1,1,1,0,1
;19 en $9d96
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e1	;1,1,1,0,0,0,0,1
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
;1A en $9d9c
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $55	;0,1,0,1,0,1,0,1
;1B en $9da2
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $64	;0,1,1,0,0,1,0,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $48	;0,1,0,0,1,0,0,0
;1C en $9da8
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $64	;0,1,1,0,0,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;1D en $9dae
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6b	;0,1,1,0,1,0,1,1
	.byt $44	;0,1,0,0,0,1,0,0
;1E en $9db4
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $51	;0,1,0,1,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
;1F en $9dba
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;20 en $9dc0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $ea	;1,1,1,0,1,0,1,0
;21 en $9dc6
	.byt $4e	;0,1,0,0,1,1,1,0
	.byt $51	;0,1,0,1,0,0,0,1
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $4d	;0,1,0,0,1,1,0,1
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $47	;0,1,0,0,0,1,1,1
;22 en $9dcc
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $76	;0,1,1,1,0,1,1,0
;23 en $9dd2
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;24 en $9dd8
	.byt $61	;0,1,1,0,0,0,0,1
	.byt $65	;0,1,1,0,0,1,0,1
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $4b	;0,1,0,0,1,0,1,1
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;25 en $9dde
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
;26 en $9de4
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
;27 en $9dea
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $69	;0,1,1,0,1,0,0,1
	.byt $56	;0,1,0,1,0,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
;28 en $9df0
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
;29 en $9df6
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
dta_car_redef_p2
;2A en $9dfc
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
;2B en $9e02
	.byt $74	;0,1,1,1,0,1,0,0
	.byt $6e	;0,1,1,0,1,1,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $60	;0,1,1,0,0,0,0,0
;2C en $9e08
	.byt $4e	;0,1,0,0,1,1,1,0
	.byt $51	;0,1,0,1,0,0,0,1
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $49	;0,1,0,0,1,0,0,1
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $47	;0,1,0,0,0,1,1,1
;2D en $9e0e
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $74	;0,1,1,1,0,1,0,0
	.byt $7a	;0,1,1,1,1,0,1,0
;2E en $9e14
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
;2F en $9e1a
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
;30 en $9e20
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $4f	;0,1,0,0,1,1,1,1
;31 en $9e26
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $6b	;0,1,1,0,1,0,1,1
;32 en $9e2c
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
;33 en $9e32
	.byt $65	;0,1,1,0,0,1,0,1
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
;34 en $9e38
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
;35 en $9e3e
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $41	;0,1,0,0,0,0,0,1
;36 en $9e44
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $69	;0,1,1,0,1,0,0,1
	.byt $66	;0,1,1,0,0,1,1,0
	.byt $48	;0,1,0,0,1,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
;37 en $9e4a
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $47	;0,1,0,0,0,1,1,1
;38 en $9e50
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
;39 en $9e56
	.byt $4b	;0,1,0,0,1,0,1,1
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;3A en $9e5c
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $49	;0,1,0,0,1,0,0,1
	.byt $46	;0,1,0,0,0,1,1,0
;3B en $9e62
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $76	;0,1,1,1,0,1,1,0
	.byt $7d	;0,1,1,1,1,1,0,1
;3C en $9e68
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;3D en $9e6e
	.byt $79	;0,1,1,1,1,0,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $4c	;0,1,0,0,1,1,0,0
;3E en $9e74
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $cf	;1,1,0,0,1,1,1,1
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $c3	;1,1,0,0,0,0,1,1
;3F en $9e7a
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $7f	;0,1,1,1,1,1,1,1
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $f8	;1,1,1,1,1,0,0,0
;40 en $9e80
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
;41 en $9e86
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $7f	;0,1,1,1,1,1,1,1
;42 en $9e8c
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $4e	;0,1,0,0,1,1,1,0
	.byt $f3	;1,1,1,1,0,0,1,1
;43 en $9e92
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $c2	;1,1,0,0,0,0,1,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $c3	;1,1,0,0,0,0,1,1
;44 en $9e98
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $c6	;1,1,0,0,0,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $cc	;1,1,0,0,1,1,0,0
;45 en $9e9e
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $c1	;1,1,0,0,0,0,0,1
	.byt $f0	;1,1,1,1,0,0,0,0
;46 en $9ea4
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $c6	;1,1,0,0,0,1,1,0
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
;47 en $9eaa
	.byt $6e	;0,1,1,0,1,1,1,0
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $d8	;1,1,0,1,1,0,0,0
	.byt $77	;0,1,1,1,0,1,1,1
	.byt $c9	;1,1,0,0,1,0,0,1
;48 en $9eb0
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $c9	;1,1,0,0,1,0,0,1
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $c9	;1,1,0,0,1,0,0,1
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $c9	;1,1,0,0,1,0,0,1
;49 en $9eb6
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $d9	;1,1,0,1,1,0,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $f1	;1,1,1,1,0,0,0,1
;4A en $9ebc
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
;4B en $9ec2
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;4C en $9ec8
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;4D en $9ece
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;4E en $9ed4
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $54	;0,1,0,1,0,1,0,0
;4F en $9eda
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $50	;0,1,0,1,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;50 en $9ee0
	.byt $c1	;1,1,0,0,0,0,0,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;51 en $9ee6
	.byt $5c	;0,1,0,1,1,1,0,0
	.byt $c6	;1,1,0,0,0,1,1,0
	.byt $72	;0,1,1,1,0,0,1,0
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;52 en $9eec
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $54	;0,1,0,1,0,1,0,0
;53 en $9ef2
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $c6	;1,1,0,0,0,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $40	;0,1,0,0,0,0,0,0
dta_car_redef_p3
;54 en $9ef8
	.byt $4e	;0,1,0,0,1,1,1,0
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
;55 en $9efe
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $c3	;1,1,0,0,0,0,1,1
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $50	;0,1,0,1,0,0,0,0
;56 en $9f04
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $40	;0,1,0,0,0,0,0,0
;57 en $9f0a
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $e4	;1,1,1,0,0,1,0,0
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $e4	;1,1,1,0,0,1,0,0
	.byt $7a	;0,1,1,1,1,0,1,0
	.byt $e4	;1,1,1,0,0,1,0,0
;58 en $9f10
	.byt $fb	;1,1,1,1,1,0,1,1
	.byt $66	;0,1,1,0,0,1,1,0
	.byt $fd	;1,1,1,1,1,1,0,1
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $cd	;1,1,0,0,1,1,0,1
	.byt $73	;0,1,1,1,0,0,1,1
;59 en $9f16
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $71	;0,1,1,1,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
;5A en $9f1c
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $7e	;0,1,1,1,1,1,1,0
;5B en $9f22
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $4b	;0,1,0,0,1,0,1,1
	.byt $45	;0,1,0,0,0,1,0,1
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $41	;0,1,0,0,0,0,0,1
;5C en $9f28
	.byt $5f	;0,1,0,1,1,1,1,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $76	;0,1,1,1,0,1,1,0
	.byt $7b	;0,1,1,1,1,0,1,1
	.byt $7d	;0,1,1,1,1,1,0,1
	.byt $5e	;0,1,0,1,1,1,1,0
;5D en $9f2e
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
;5E en $9f34
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
;5F en $9f3a
	.byt $5f	;0,1,0,1,1,1,1,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $77	;0,1,1,1,0,1,1,1
	.byt $7b	;0,1,1,1,1,0,1,1
	.byt $7d	;0,1,1,1,1,1,0,1
	.byt $40	;0,1,0,0,0,0,0,0
;60 en $9f40
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
;61 en $9f46
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $73	;0,1,1,1,0,0,1,1
;62 en $9f4c
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $57	;0,1,0,1,0,1,1,1
	.byt $6b	;0,1,1,0,1,0,1,1
	.byt $4d	;0,1,0,0,1,1,0,1
	.byt $72	;0,1,1,1,0,0,1,0
	.byt $4e	;0,1,0,0,1,1,1,0
;63 en $9f52
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $6e	;0,1,1,0,1,1,1,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $77	;0,1,1,1,0,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $7b	;0,1,1,1,1,0,1,1
;64 en $9f58
	.byt $5b	;0,1,0,1,1,0,1,1
	.byt $4d	;0,1,0,0,1,1,0,1
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $fe	;1,1,1,1,1,1,1,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $fd	;1,1,1,1,1,1,0,1
;65 en $9f5e
	.byt $5b	;0,1,0,1,1,0,1,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $5b	;0,1,0,1,1,0,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
;66 en $9f64
	.byt $5b	;0,1,0,1,1,0,1,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $5b	;0,1,0,1,1,0,1,1
	.byt $fe	;1,1,1,1,1,1,1,0
	.byt $42	;0,1,0,0,0,0,1,0
	.byt $fd	;1,1,1,1,1,1,0,1
;67 en $9f6a
	.byt $5a	;0,1,0,1,1,0,1,0
	.byt $6c	;0,1,1,0,1,1,0,0
	.byt $5a	;0,1,0,1,1,0,1,0
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $ff	;1,1,1,1,1,1,1,1
;68 en $9f70
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $61	;0,1,1,0,0,0,0,1
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $5f	;0,1,0,1,1,1,1,1
	.byt $4f	;0,1,0,0,1,1,1,1
;69 en $9f76
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $70	;0,1,1,1,0,0,0,0
;6A en $9f7c
	.byt $7f	;0,1,1,1,1,1,1,1
	.byt $ff	;1,1,1,1,1,1,1,1
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $cf	;1,1,0,0,1,1,1,1
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $c3	;1,1,0,0,0,0,1,1
;6B en $9f82
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $f0	;1,1,1,1,0,0,0,0
	.byt $47	;0,1,0,0,0,1,1,1
	.byt $fc	;1,1,1,1,1,1,0,0
	.byt $41	;0,1,0,0,0,0,0,1
	.byt $ff	;1,1,1,1,1,1,1,1
;6C en $9f88
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $6f	;0,1,1,0,1,1,1,1
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $6d	;0,1,1,0,1,1,0,1
;6D en $9f8e
	.byt $fd	;1,1,1,1,1,1,0,1
	.byt $7d	;0,1,1,1,1,1,0,1
	.byt $fd	;1,1,1,1,1,1,0,1
	.byt $6d	;0,1,1,0,1,1,0,1
	.byt $fd	;1,1,1,1,1,1,0,1
	.byt $7d	;0,1,1,1,1,1,0,1
;6E en $9f94
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $ef	;1,1,1,0,1,1,1,1
;6F en $9f9a
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $5e	;0,1,0,1,1,1,1,0
	.byt $f3	;1,1,1,1,0,0,1,1
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $fc	;1,1,1,1,1,1,0,0
;70 en $9fa0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $c0	;1,1,0,0,0,0,0,0
	.byt $7e	;0,1,1,1,1,1,1,0
	.byt $c3	;1,1,0,0,0,0,1,1
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $e3	;1,1,1,0,0,0,1,1
;71 en $9fa6
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $78	;0,1,1,1,1,0,0,0
	.byt $7c	;0,1,1,1,1,1,0,0
	.byt $66	;0,1,1,0,0,1,1,0
	.byt $63	;0,1,1,0,0,0,1,1
;72 en $9fac
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $49	;0,1,0,0,1,0,0,1
	.byt $67	;0,1,1,0,0,1,1,1
	.byt $43	;0,1,0,0,0,0,1,1
	.byt $5b	;0,1,0,1,1,0,1,1
;73 en $9fb2
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $ef	;1,1,1,0,1,1,1,1
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $eb	;1,1,1,0,1,0,1,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $ea	;1,1,1,0,1,0,1,0
;74 en $9fb8
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $69	;0,1,1,0,1,0,0,1
	.byt $e8	;1,1,1,0,1,0,0,0
	.byt $6b	;0,1,1,0,1,0,1,1
	.byt $ea	;1,1,1,0,1,0,1,0
;75 en $9fbe
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $ed	;1,1,1,0,1,1,0,1
	.byt $62	;0,1,1,0,0,0,1,0
	.byt $eb	;1,1,1,0,1,0,1,1
	.byt $64	;0,1,1,0,0,1,0,0
	.byt $e7	;1,1,1,0,0,1,1,1
;76 en $9fc4
	.byt $61	;0,1,1,0,0,0,0,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $58	;0,1,0,1,1,0,0,0
	.byt $4c	;0,1,0,0,1,1,0,0
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $43	;0,1,0,0,0,0,1,1
;77 en $9fca
	.byt $60	;0,1,1,0,0,0,0,0
	.byt $53	;0,1,0,1,0,0,1,1
	.byt $68	;0,1,1,0,1,0,0,0
	.byt $55	;0,1,0,1,0,1,0,1
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;78 en $9fd0
	.byt $61	;0,1,1,0,0,0,0,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $58	;0,1,0,1,1,0,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $43	;0,1,0,0,0,0,1,1
;79 en $9fd6
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $52	;0,1,0,1,0,0,1,0
	.byt $d5	;1,1,0,1,0,1,0,1
	.byt $54	;0,1,0,1,0,1,0,0
	.byt $6a	;0,1,1,0,1,0,1,0
	.byt $55	;0,1,0,1,0,1,0,1
;7A en $9fdc
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $4f	;0,1,0,0,1,1,1,1
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $59	;0,1,0,1,1,0,0,1
;7B en $9fe2
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $74	;0,1,1,1,0,1,0,0
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $6e	;0,1,1,0,1,1,1,0
;7C en $9fe8
	.byt $44	;0,1,0,0,0,1,0,0
	.byt $e6	;1,1,1,0,0,1,1,0
	.byt $e0	;1,1,1,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;7D en $9fee
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $d1	;1,1,0,1,0,0,0,1
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
	.byt $40	;0,1,0,0,0,0,0,0
;7E en $9ff4
	.byt $61	;0,1,1,0,0,0,0,1
	.byt $70	;0,1,1,1,0,0,0,0
	.byt $58	;0,1,0,1,1,0,0,0
	.byt $4a	;0,1,0,0,1,0,1,0
	.byt $46	;0,1,0,0,0,1,1,0
	.byt $43	;0,1,0,0,0,0,1,1



