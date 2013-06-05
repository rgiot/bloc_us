
 org 0x1000
  output affiche_logo2.o

FRAMEWORK_WAIT_VBL: equ 0x000001A6

; Opcodes necessaires
INC_BC_OPCODE	equ	0x03
INC_DE_OPCODE	equ	0x13
LOGO_HEIGHT=72
LOGO_WIDTH=516/2
LARGEUR_OCTETS=96


	call FRAMEWORK_WAIT_VBL
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 +38- (22 - 1) : out (c), c
	ld bc, 0xbc07 : out (c), c : ld bc, 0xbd00 + 22 : out (c), c
	halt
	halt
	halt
	halt
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 + 38 : out (c), c

 
	call scroll_init

	;;;TODO Transition CRTC

loop	
	call FRAMEWORK_WAIT_VBL
	ld bc, 0xbc01 : out (c), c
	ld bc, 0xbd00 + 96/2 : out (c), c
	ld bc, 0xbc06 : out (c), c
	ld bc, 0xbd00 + LOGO_HEIGHT/8  : out (c), c
	call COLOR
	.5 halt
	call scroll_gestion
	call SELECT_SCREEN


.tempo
	ld hl, LOGO_WIDTH*2 
	dec hl
	ld (.tempo+1), hl
	ld a, h
	or l
	jr z, quit_demo
 jr loop


quit_demo
   call FRAMEWORK_WAIT_VBL
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38+21 : out (c), c
    ld bc, 0xbc00+7 : out (c), c
    ld bc, 0xbd00+1 : out (c), c
    halt : halt
    call FRAMEWORK_WAIT_VBL
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38 : out (c), c
    ret

COLOR
    ld bc, 0x7f00
    ld hl, COLOR_set
.loop
    ld a, (hl)
    or a
    ret z

    inc hl
    
    out (c), c
    out (c), a

    inc c
    jr .loop

COLOR_set
; incbin data/logo2/blockus_logo.pal

	db 0x4b ; ink 0
	db 0x54	; ink 1
	db 0x44	; ink 2
	db 0x5c	; ink 3
	db 0x58	; ink 4
	db 0x5d	; ink 5
	db 0x56	; ink 6
	db 0x46	; ink 7
	db 0x5e	; ink 8
	db 0x40	; ink 9
	db 0x5f	; ink 10
	db 0x47	; ink 11
	db 0x4f	; ink 12
	db 0x59	; ink 13
	db 0x5b	; ink 14
	db 0x43	; ink 15
        db 0x4b
	db 0x4b
	db 0x4b
	db 0x4b
	db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Scrolling code

/**
 * macro de calcul de ligne suivante a temps constant
 * Surement inutile en raison du temps perdu ...
 */
 macro GET_NEXT_LINE_CST    
        LD A,H				; TIMING_LD_R_R
        ADD A,#08			; TIMING_ADD_A_n
        LD H,A				; TIMING_LD_R_R
        AND 0x38			; TIMING_AND_n
        jr NZ, .end_next_line1		; TIMING_JR_LOOP	
	nop
	
        LD A,H				; TIMING_LD_R_R
        SUB 0x40				; TIMING_SUB_n
        LD H,A				; TIMING_LD_R_R
        LD A,L				; TIMING_LD_R_R
        ADD A, LARGEUR_OCTETS		; TIMING_ADD_A_n
        LD L,A				; TIMING_LD_R_R
        jr NC, .end_next_line2		; TIMING_JR_LOOP
	nop
	
        INC H				; TIMING_INC_8BITS
        LD A,H				; TIMING_LD_R_R
        AND 0x07				; TIMING_AND_n
        jr NZ, .end_next_line3		; TIMING_JR_LOOP
	nop
	
        LD A,H				; TIMING_LD_R_R
        SUB 0x08				; TIMING_SUB_n
        LD H,A				; TIMING_LD_R_R

	jr .end_next_line		; TIMING_JR_LOOP
	
.end_next_line1 defs TIMING_LD_R_R + TIMING_SUB_n + TIMING_LD_R_R + TIMING_LD_R_R + TIMING_ADD_A_n + TIMING_LD_R_R
.end_next_line2 defs TIMING_INC_8BITS + TIMING_LD_R_R + TIMING_AND_n
.end_next_line3	defs TIMING_LD_R_R + TIMING_SUB_n + TIMING_LD_R_R + TIMING_JR_LOOP

.end_next_line
 endm

 /*
  * Chg de ligne cst depuis BC
  */
 macro GET_NEXT_LINE_CST_BC

        LD  A,B				; TIMING_LD_R_R
        ADD A,#08			; TIMING_ADD_A_n
        LD  B,A				; TIMING_LD_R_R
        AND $38				; TIMING_AND_n
        jr  NZ, .end_next_line1		; TIMING_JR_LOOP	
	nop
	
        LD  A, B			; TIMING_LD_R_R
        SUB $40				; TIMING_SUB_n
        LD  B, A			; TIMING_LD_R_R
        LD  A, C			; TIMING_LD_R_R
        ADD A, LARGEUR_OCTETS		; TIMING_ADD_A_n
        LD  C, A			; TIMING_LD_R_R
        jr  NC, .end_next_line2		; TIMING_JR_LOOP
	nop
	
        INC	B			; TIMING_INC_8BITS
        LD	A,B			; TIMING_LD_R_R
        AND	$07			; TIMING_AND_n
        jr	NZ, .end_next_line3	; TIMING_JR_LOOP
	nop
	
        LD  A,B				; TIMING_LD_R_R
        SUB 0x08			; TIMING_SUB_n
        LD  B,A				; TIMING_LD_R_R

	jr  .end_next_line		; TIMING_JR_LOOP
	nop



.end_next_line1 block 1 + 2 + 1 +1 + 2 + 1 + 3 
.end_next_line2 block 1 + 1 + 2 + 3 
.end_next_line3	block 1 + 2 + 1  + 3  

.end_next_line
 endm

 /*
  * Chg de ligne cst depuis DE
  */
 macro GET_NEXT_LINE_CST_DE

        LD  A,D				; TIMING_LD_R_R
        ADD A,#08			; TIMING_ADD_A_n
        LD  D,A				; TIMING_LD_R_R
        AND $38				; TIMING_AND_n
        jr  NZ, .end_next_line1		; TIMING_JR_LOOP	
	nop
	
        LD  A, D			; TIMING_LD_R_R
        SUB $40				; TIMING_SUB_n
        LD  D, A			; TIMING_LD_R_R
        LD  A, E			; TIMING_LD_R_R
        ADD A, LARGEUR_OCTETS		; TIMING_ADD_A_n
        LD  E, A			; TIMING_LD_R_R
        jr  NC, .end_next_line2		; TIMING_JR_LOOP
	nop
	
        INC	D			; TIMING_INC_8BITS
        LD	A,D			; TIMING_LD_R_R
        AND	$07			; TIMING_AND_n
        jr	NZ, .end_next_line3	; TIMING_JR_LOOP
	nop
	
        LD  A,D				; TIMING_LD_R_R
        SUB $08	    			; TIMING_SUB_n
        LD  D,A				; TIMING_LD_R_R

	jr  .end_next_line		; TIMING_JR_LOOP


.end_next_line1 block 1 + 2 + 1 +1 + 2 + 1 + 3 
.end_next_line2 block 1 + 1 + 2 + 3 
.end_next_line3	block 1 + 2 + 1  + 3 

.end_next_line
 endm




ADRESSE_ECRAN_SCROLL			EQU	0xc000
MASQUE_CRTC				EQU	00110000b 
MASQUE_SCROLL				EQU	MASQUE_CRTC | 3

; timing constant
  macro	SCROLL_COMMUN	 memory_offset, crtc_offset, memory_offset2


					ld	ix, memory_offset
					ld	iy, memory_offset2
					CALL	DRAW_SCROLL ; affichage de la bande droite du scroll

					ld	iy, crtc_offset
					CALL	SCROLL_OFFSET ; decalage
				
					CALL	SCROLL_HARD_GESTION
	endm

;timing constant
SCROLL1	
					SCROLL_COMMUN OFFSET_MEMORY_1, OFFSET_CRTC_1, OFFSET_MEMORY_2
					ld	hl, SCROLL2
					ret


;timing constant
SCROLL2 
					SCROLL_COMMUN OFFSET_MEMORY_2, OFFSET_CRTC_2, OFFSET_MEMORY_1
					ld	hl, SCROLL1
					ret
/*
 * Initialisations
 * Effacement de l'ecran du scroll
 */

scroll_init
					ld	hl, ADRESSE_ECRAN_SCROLL
					ld	de, ADRESSE_ECRAN_SCROLL+1
					ld	bc, 0x3fff
					xor	a
					ld	(hl), a
					ldir
	
					ld bc, 0x7f8c : out (c), c				
					ret
					

; timing constant
scroll_gestion

scroll_gestion_rout			call	SCROLL1
					ld	(scroll_gestion_rout+1), hl
					
					; sauvegarde de l'a dresse ecran
					call	SAVE_SCREEN	
					ret
					

; timing constant
SAVE_SCREEN	
					LD	a,(IY+0)
					ld	(SELECT_SCREEN_L+1), a
					LD	A,(IY+1)
					ld	(SELECT_SCREEN_A+1), a
					RET
					
;;
;; Selection de la bonne portion a afficher.
; timing constant
SELECT_SCREEN	
SELECT_SCREEN_L				LD L,0 ;(IY+0)
SELECT_SCREEN_A				LD A,0 ;(IY+1)
					OR MASQUE_CRTC ;selection de la banque
					
					LD BC,0xBC0C
					OUT (C),C
					INC B
					OUT (C),A
					
					DEC B
					INC C
					OUT (C),C
					INC B
					OUT (C),L 
					RET
					
					
		
;;
;; Decale l'offset ecran afin d'effectuer le scrolling
; timing constant
SCROLL_OFFSET 
SCROLL_OFFSET_CRTC
					ld	l, (iy+0) : ld	h, (iy+1) ; lecture adresse
					inc	hl ; incrementation
					
					ld	a, h ; verification
					and	11b ; seuls les deux premiers bits servent a l'offset
					
					ld	(iy+1), a : ld 	(iy+0), l ; sauvegarde adresse
					
SCROLL_OFFSET_MEMORY
 ; premier ecran
					ld	hl, (OFFSET_MEMORY_1)
					inc     hl

					; HL ne doit pas depasser 0x800	
					ld a,h : and 7 : ld h,a

					ld	de, ADRESSE_ECRAN_SCROLL ; ajout de l'offset ecran
					add	hl,de
					
					ld	(OFFSET_MEMORY_1), hl
 ; second ecran
					ld	hl, (OFFSET_MEMORY_2)
					inc     hl

					ld a,h : and 7 : ld h,a
				
					ld	de, ADRESSE_ECRAN_SCROLL ; ajout de l'offset ecran
					add	hl,de
					
					ld	(OFFSET_MEMORY_2), hl
					
					ret
					
					
					
  macro SCROLL_macro 
				ld	a, (hl)	; recuperation octet
				inc	hl
				
				ld	(bc), a ; affichage octet
				ld	(de), a
endm

;C0
 macro SCROLL_macro1	
				SCROLL_macro
				set	3, d
				set	3, b
endm

;c8
 macro SCROLL_macro2	
				SCROLL_macro
				set	4, d
				set	4, b
endm

;d8
	 macro SCROLL_macro3
				SCROLL_macro
				res	3, d
				res	3, b
 endm


;d0
  macro SCROLL_macro4	
				SCROLL_macro
				set	5, d
				set	5, b
 endm


;f0
  macro SCROLL_macro5	
				SCROLL_macro
				set	3, d
				set	3, b
 endm


;f8
	 macro SCROLL_macro6
				SCROLL_macro
				res	4, d
				res	4, b
 endm


;e8
  macro SCROLL_macro7	
				SCROLL_macro
				res	3, d
				res	3, b
 endm

;e0
  macro SCROLL_macro8	; REste a optimiser
				SCROLL_macro

    ld	a, 00011000b ;1
    or	d            ;2
    ld	d, a         ;3 

     ld	a, 00011000b ;1
    or	b            ;2
    ld	b, a         ;3 

				GET_NEXT_LINE_CST_BC
				GET_NEXT_LINE_CST_DE
 endm
				


/**
 * Macros pour l'affichage de blanc
 */
				
  macro SCROLL_macro_space 
			xor a	
			ld	(bc), a ; affichage octet
			ld	(de), a
endm

;C0
 macro SCROLL_macro_space1	
				SCROLL_macro_space
				set	3, d
				set	3, b
endm

;c8
 macro SCROLL_macro_space2	
				SCROLL_macro_space
				set	4, d
				set	4, b
endm

;d8
	 macro SCROLL_macro_space3
				SCROLL_macro_space
				res	3, d
				res	3, b
 endm


;d0
  macro SCROLL_macro_space4	
				SCROLL_macro_space
				set	5, d
				set	5, b
 endm


;f0
  macro SCROLL_macro_space5	
				SCROLL_macro_space
				set	3, d
				set	3, b
 endm


;f8
	 macro SCROLL_macro_space6
				SCROLL_macro_space
				res	4, d
				res	4, b
 endm


;e8
  macro SCROLL_macro_space7	
				SCROLL_macro_space
				res	3, d
				res	3, b
 endm

;e0
  macro SCROLL_macro_space8	; REste a optimiser
				SCROLL_macro_space

    ld	a, 00011000b ;1
    or	d            ;2
    ld	d, a         ;3 

     ld	a, 00011000b ;1
    or	b            ;2
    ld	b, a         ;3 

				GET_NEXT_LINE_CST_BC
				GET_NEXT_LINE_CST_DE
 endm
	


;;
;; Affiche la nouvelle portion de scroll 
;;
;; Affichage d'une coloone de 1 octet dans les deux ecrans
; Timing constant
DRAW_SCROLL
					ld	e, (ix+0)
					ld	d, (ix+1)
					

					ld	c, (iy+0)
					ld	b, (iy+1)
	
	inc de: inc bc				
	inc de: inc bc				
draw_scroll_decalage_octet2		nop				; INC_BC_OPCODE
draw_scroll_decalage_octet		defb	INC_DE_OPCODE		; INC_DE_OPCODE


;ld 	a, 0xff
;ld	(de), a
;ld	(bc), a
;Affichage d'un caractere vide
/*
			SCROLL_macro_space1
			SCROLL_macro_space2
			SCROLL_macro_space3
			SCROLL_macro_space4
			SCROLL_macro_space5
			SCROLL_macro_space6
			SCROLL_macro_space7
			SCROLL_macro_space8
*/			
					
draw_scroll_adr_fonte			ld	hl, LOGO
			

					ld	a, LOGO_HEIGHT/8
draw_scroll_boucle			ex	af, af'
					
draw_scroll_val_octet			

					SCROLL_macro1
					SCROLL_macro2
					SCROLL_macro3
					SCROLL_macro4
					SCROLL_macro5
					SCROLL_macro6
					SCROLL_macro7
					SCROLL_macro8
					
					ex	af, af'
					dec	a
					jp	nz,	draw_scroll_boucle
					ex	af, af'
					
					; Inversion du decalage
					ld	a, (draw_scroll_decalage_octet)
					xor	 INC_DE_OPCODE
					ld	(draw_scroll_decalage_octet), a
					
					ld	a, (draw_scroll_decalage_octet2)
					xor	 INC_BC_OPCODE
					ld	(draw_scroll_decalage_octet2), a
					
					ret


TIMING_NOP					equ	1

;decrement
TIMING_DEC_8BITS				equ	1
TIMING_DEC_DD					equ	2
TIMING_INC_8BITS				equ	1
TIMING_INC_DD					equ	2

; instructions de saut
TIMING_JR_LOOP					equ	3
TIMING_JR_NO_LOOP				equ	2


; LD
TIMING_LD_DD_nn					equ	3
TIMING_LD_R_R					equ	1
TIMING_LD_R_HL					equ	3 ; ld r,(hl)
TIMING_LD_R_n					equ	2 ; ld registre, nombre

TIMING_LD_mm_HL					equ	5 ; ld (mm), hl
TIMING_LD_mm_A					equ	4 ; ld (mm), a
TIMING_LD_DD_mm					equ	6 ; ld de,(mm)


; add
TIMING_ADD_HL_DD				equ	3
TIMING_ADD_A_n					equ	2

; sub
TIMING_SUB_n					equ	2

; cp
TIMING_CP_N					equ	2 ; cp &ff



; and
TIMING_AND_n					equ	2






; Temps en cycle machine pris par les instructions Z80
; ----------------------------------------------------
; Table extraite d'un article "confidentiel" de Gozeur sur la
; programmation de ruptures ecran.
 
; Classement alphabetique et modestes corrections par T&J/GPA.
; Les instructions "cachees" ne sont pas prises en compte dans la
; liste. Qui s'en sert vraiment, a part Madram et Emlsoft ?

; R = registre 8 bits : A,B,C,D,E
; DD = registre 16 bits : HL, BC, DE
; XY = registres d'index IX ou IY

; n = valeur 8 bits
; nn = valeur 16 bits
; cc = condition (C, Z, NZ, P, etc... )

; Certaines instructions ne prennent pas toujours le meme nombre de
; cycles.

; Les sauts executes ou non suite a un test (JR, JP, CALL) :
; * La valeur avant le / correspond au temps pris si la condition est remplie
; * La valeur apres le / correspond au temps pris si la condition n'est pas
  ; remplie

; Les operations de copie de suites d'octets (LDIR, LDDR) :
; * Prenez votre calculette !


; ADC A,(HL)	2	ADC A,(XY+n)	5	ADC A,n		2
; ADC A,R		1	ADC HL,DD	4	ADC XY,DD	4	
; ADD A,(HL)	2	ADD A,(XY+n)	5	ADD A,n		2
; ADD A,R		1	ADD HL,DD	3	ADD HL,XY	4
; AND (HL)	2	AND (XY+n)	5	AND n		2
; AND R		1	

; BIT n,(HL)	4	BIT n,(XY+n)	6	BIT n,R		2

; CALL cc,nn	3 / 2	CALL nn		5	CCF		1
; CP (HL)		2	CP (XY+n)	5	CP n		2
; CP R		1	CPD		4	CPDR	4+6*(BC-1)
; CPI		4	CPIR	4+6*(BC-1)	CPL		1

; DAA		1	DEC (XY+n)	5	DEC R		1
; DI		1	DJNZ n		3 / 2	

; EI		1	EX (SP),HL	6	EX (SP),XY	7
; EX AF,AF'	1	EX DE,HL	1	EXX		1

; HALT	 	1	

; IM		2	IN A,(n)	3	IN R,(C)	4
; INC (HL)	3	INC (XY +n)	6	INC DD		2
; INC R		1	INC XY		3	IND		5
; INI		5	

; JP (HL)		1	JP (XY)		2	JP cc,nn	3 / 2
; JP nn		3	JR cc,nn	3 / 2	JR n		3

; LD (DD),A	2	LD (HL),n	3	LD (HL),R	2
; LD (nn),A	4	LD (nn),DD	6	LD (nn),HL	5
; LD (nn),XY	6	LD (XY+n),n	5	LD (XY+n),R	5
; LD A,(DD)	2	LD A,(nn)	4	LD A,I		3
; LD A,R		3	LD DD,(nn)	6	LD DD,nn	3
; LD HL,(nn)	5	LD I,A		3	LD R,(HL)	2
; LD R,(ID + n)	5	LD R,A		3	LD R,n		2
; LD R,R		1	LD SP,HL	2	LD SP,XY	3
; LD XY,(nn)	6	LD XY,nn	4	LDD		5
; LDDR	5+6*(BC-1)	LDI		5	LDIR	5+6*(BC-1)

; NEG		2	NOP		1	

; OR (HL)		2	OR (XY+n)	5	OR n		2
; OR R		1	OUT(n),A	3	OUT (C),A	3
; OUT (C),R	4	OUTD		5	OUTI		5

; POP DD		3	POP XY		4	PUSH DD		4
; PUSH XY		5	

; RES n,(HL)	4	RES n,(XY + n)	7	RES n,R		2
; RET		3	RETI		4	RETN		4
; RL (HL)		4	RL (XY + nn)	7	RL R		2
; RLA		1	RLC (HL)	4	RLC (XY+n)	7
; RLC R		2	RLCA		1	RLD		5
; RR (HL)		4	RR (XY+ nn)	7	RR R		2
; RRA		1	RRC (HL)	4	RRC (XY + n)	7
; RRC R		2	RRCA		1	RRD		5

; SBC A,(HL)	2	SBC A,(XY+n)	5	SBC A,n		2
; SBC A,R		1	SCF		1	SET n,(HL)	3
; SET n,(XY+n)	7	SET n,R		2	SLA (HL)	4
; SLA (XY+n)	7	SLA R		2	SRA (HL)	4
; SRA (XY+n)	7	SRA R		2	SRL (HL)	4
; SRL (XY + n)	7	SRL R		2	SUB (HL)	2
; SUB (XY+n)	5	SUB n		2	SUB R		1

; XOR (HL)	2	XOR (XY+n)	5	XOR n		2
; XOR R		1

					
;;
;; Gestion du scroll hard
; timing cense etre constant
TIMING_BLOC_1				equ	TIMING_LD_mm_A + TIMING_LD_DD_mm + TIMING_LD_DD_nn + TIMING_ADD_HL_DD + TIMING_LD_mm_HL
TIMING_BLOC_2_COMMUN			equ	TIMING_LD_DD_nn + TIMING_LD_R_HL + TIMING_CP_N + 3
TIMING_BLOC_2_UNIQUE			equ	TIMING_LD_DD_nn + TIMING_LD_R_HL + TIMING_JR_LOOP
TIMING_BLOC_2_suite 			equ 	TIMING_INC_DD + TIMING_LD_mm_HL + TIMING_LD_R_R + TIMING_LD_R_n + TIMING_LD_DD_nn + 3*TIMING_ADD_HL_DD + TIMING_LD_R_HL + TIMING_LD_mm_A + TIMING_INC_DD + TIMING_LD_R_HL  + TIMING_INC_DD + TIMING_LD_R_HL + TIMING_LD_DD_nn + TIMING_ADD_HL_DD + TIMING_LD_mm_HL
TIMING_BLOC_2	equ TIMING_BLOC_2_suite + TIMING_BLOC_2_COMMUN

SCROLL_HARD_GESTION
	
	ld hl, LOGO_WIDTH
	ld a, h
	or l
	ret z
	dec hl
	ld (SCROLL_HARD_GESTION+1), hl
					
; Get tile number
.map_table
  ld hl, MAP
  ld e, (hl)
  inc hl
  ld (.map_table+1), hl

; Get pointer of column adress
  ld hl, COLUMN_ADRESS
  ld d, 0
  add hl, de
  add hl, de

; Get tile adress
  ld e, (hl)
  inc hl
  ld d, (hl)

  ld	(draw_scroll_adr_fonte+1), de		; TIMING_LD_DD_mm	
  ret

  
					;decalage au bloc suivant
					ld	de, (draw_scroll_adr_fonte+1)		; TIMING_LD_DD_mm	

					ld	hl, LOGO_HEIGHT				; TIMING_LD_DD_nn
					add	hl, de					; TIMING_ADD_HL_DD
					LD	(draw_scroll_adr_fonte+1), hl		; TIMING_LD_mm_HL
					
					ret	
					


OFFSET_CRTC_1	DEFW	0				
OFFSET_MEMORY_1	DEFW	ADRESSE_ECRAN_SCROLL + LARGEUR_OCTETS -2
					
					
OFFSET_CRTC_2	DEFW	(LOGO_HEIGHT/8)	* LARGEUR_OCTETS/2 + 1
OFFSET_MEMORY_2	DEFW	ADRESSE_ECRAN_SCROLL + LARGEUR_OCTETS -2 + ((LOGO_HEIGHT/8)	* LARGEUR_OCTETS)  + 2
					

;;; Table of tiles
MAP
 incbin data/logo2/blockus_logo.map

COLUMN_ADRESS
IDX=0
 dup LOGO_WIDTH
  dw LOGO + LOGO_HEIGHT*IDX
IDX=IDX+1
 edup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA to scroll
LOGO
;;Code lua pour mettre la fonte en code gray
 LUA ALLPASS
	-- Ne peux fonctionner que avec une hauteur multiple de 8
	-- affichage incorrecte pour les dernieres lignes ...
	

	local f = assert(io.open("data/logo2/blockus_logo.pat", "rb"))
	local count = 0
	
	while true do
		local byte1

		
		byte1 = f:read(1)
		
		if byte1 
		then
--			if (count < 39)
--			then
				local byte2 = assert(f:read(1))
				if (not byte2) then return nil end
				
				local byte3 = assert(f:read(1))
				if (not byte3) then return  nil end
				
				local byte4 = assert(f:read(1))
				if (not byte4) then return  nil end
				
				local byte5 = assert(f:read(1))
				if (not byte5) then return  nil end
				
				local byte6 = assert(f:read(1))
				if (not byte6) then return  nil end
				
				local byte7 = assert(f:read(1))
				if (not byte7) then return  nil end
				
				local byte8 = assert(f:read(1))
				if (not byte8) then return  nil end


				
				_pc(string.format("DB 0x%02X ", string.byte(byte1)))
				_pc(string.format("DB 0x%02X ", string.byte(byte2)))
				_pc(string.format("DB 0x%02X ", string.byte(byte4)))
				_pc(string.format("DB 0x%02X ", string.byte(byte3)))
				_pc(string.format("DB 0x%02X ", string.byte(byte7)))
				_pc(string.format("DB 0x%02X ", string.byte(byte8)))
				_pc(string.format("DB 0x%02X ", string.byte(byte6)))
				_pc(string.format("DB 0x%02X ", string.byte(byte5)))
				
--				count = count+7
--			else
--				if (count == 41)
--				then
--					count = -1
--				end
--			end
--			
--			count = count + 1
		else
			f:close()
			break
		end
	end
 ENDLUA
  
 defs LOGO_HEIGHT*2
 assert $<0xc000
