/**
 * This file contains the C4 bank code.
 * This bank embeds the player and the music.
 *
 * The music also overlap an bank C5
 */

    output C4.o

   org 0x0
   defs 5

   jr PLAYER

/**
 * Leave interrupt
 */
LEAVE
   ld bc, 0x7fc0 ; 3
   out (c), c    ; 2


/**
 * Song player for the demo
 */
PLAYER
	ld a, 1
	or a
	jp nz, .init
	call EXE_PLAY
	jr LEAVE
.init
	xor a
	ld (PLAYER+1), a


	call INI_PLAY
	jr LEAVE


NBR_REG	EQU	13
;
;
;
;        Exe
;
;
  ; Place for stack
  defs 0x100 - $
; TODO verify it is always FRAMEWORK_EXEC
EXE_PLAY
	LD	(SAVPILE),SP
; 6
;
;        PREPARE LES ARGUMENTS DE LA ROUTINE DE DECOMPRESSION 1
;
;
COUPLE1
	LD	SP,BUFID1
	POP	DE
	POP	HL
	DEC	SP
	POP	AF
	LD	(COUPLE1+1),SP
	LD	SP,HL
DICO1
	LD	HL,0
NBDATA1
	LD	C,0
	LD	IX,RETDEC1
	DB	#fd
	LD	l,0
	JP	DECOMPRS
RETDEC1
	LD	(SP2HL2+1),SP
; 44
SP2HL2
	LD	HL,0
	LD	SP,(COUPLE1+1)
	PUSH	BC
	INC	SP
	PUSH	HL	; Maj Adr_decrunch
	PUSH	DE	; Maj [ Adr_ch ; Lng_ch ]
;
	LD	a,7
	DB	#fd
	SUB	l
stabil
	OR	a
	JR	z,fin_stab
	DS	36-7
	DEC	a
	JR	stabil
fin_stab
;
;
;        ENVOIE LES 13 REGISTRES COMPRESSES AU PSG
;        (REG 0,1,2,3,4,5,6,7,8,9,10,11,13)
;
;
PUT_AY
	LD	HL,(DICO1+1)
	LD	H,PFO100
;
	LD	B,#F4
	LD	E,1
	EXX	
	LD	B,#F6
	LD	HL,#C080
	OUT	(C),H
	EXX	
; 22us
;REG0
PREG0
	LD	A,(HL)
	INC	H
	DB	#ED,#71
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG1
PREG1
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG2
PREG2
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG3
PREG3
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG4
PREG4
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG5
PREG5
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG6
PREG6
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG7
PREG7
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG8
PREG8
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG9
PREG9
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG10
PREG10
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG11
PREG11
	INC	E
	LD	A,(HL)
	INC	H
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;REG13
PREG13
	LD	A,(HL)
	INC	H
	CP	#FF
	JR	Z,FIX_R13
;
	INC	E
	INC	E
	OUT	(C),E
	EXX	
	DB	#ED,#71
	EXX	
	OUT	(C),A
	EXX	
	OUT	(C),L
	OUT	(C),H
	EXX	
;
DICOBCL
	LD	HL,(DICO1+1)
	INC	L
	INC	H
	LD	A,H
	CP	PFO100+NBR_REG
	JR	NZ,FIX_BCL
	LD	BC,BUFID1
	LD	(COUPLE1+1),BC
	LD	H,PFO100
BCL_REG
	LD	(DICO1+1),HL
;
	LD	SP,(SAVPILE)
	RET	
;
FIX_R13
	DS	26-4
	JR	DICOBCL
FIX_BCL
	DS	11-4
	JR	BCL_REG
;
;
;        INITIALISE TOUS LES REGISTRES DU AY
;
;
END_PSG
	LD	HL,LIST_PSG
	LD	A,14
	LD	B,#F4
	EXX	
	LD	B,#F6
	LD	HL,#C080
	EXX	
;
INI_PSG
	INC	B
	OUTI	
	EXX	
	OUT	(C),H
	DB	#ED,#71
	EXX	
	INC	B
	OUTI	
	EXX	
	OUT	(C),L
	DB	#ED,#71
	EXX	
	DEC	A
	JR	NZ,INI_PSG
;
	RET	
;
LIST_PSG
	DB	0,0,1,0,2,0,3,0,4,0,5,0
	DB	6,0,7,%00111111,8,0,9,0
	DB	10,0,11,0,12,0,13,0
END_LIST
SAVPILE	DW 0	
;
;
;        DECOMPRESSE <NBR_REG> VALEURS D'UN REGISTRE (#100)
;
;        HL = ADRESSE DU DICO
;        DE = [ ADR_CH ; LNG_CH ]
;        SP = ADRESSE DES DATAS A DECOMPRESSER
;        IX = ADRESSE DE RETOUR
;        C = NBR DE VALEURS A DECOMPRESSER
;        A = OCTET D'ID
;
;
flgend1	EQU	#1f
;
DECOMPRS
	INC	d
	DEC	d
	JP	nz,cont
new
	DB	#fd
	INC	l
	DEC	sp
	POP	af
	CP	flgend1
	JP	c,d_car100
;
d_ch100
	SUB	flgend1-2
	CP	c
	JP	nc,c_fois2
;
a_fois2
	LD	b,a
	LD	a,c
	SUB	b
	LD	c,a
	DEC	sp
	POP	af
	INC	a
	LD	e,a
	LD	a,l
	SUB	e
	LD	e,a
cop_a2
	LD	d,h
copie_a2
	LD	a,(de)
	LD	(hl),a
	INC	l
	INC	e
	DS	2
	DEC	b
	JP	nz,copie_a2
	JR	new
;
c_fois2
	SUB	c
	LD	b,a
	DEC	sp
	POP	af
	INC	a
	LD	e,a
	LD	a,l
	SUB	e
	LD	e,a
cop_c2
	LD	d,h
copie_c2
	LD	a,(de)
	LD	(hl),a
	INC	l
	INC	e
	DS	2
	DEC	c
	JP	nz,copie_c2
	LD	d,b	;  e est ok
	LD	b,0
	JP	(ix)
;
cont
	DB	#fd
	INC	l
	OR	a
	JP	nz,cont_car
cont_ch
	DS	14
	LD	a,d
	CP	c
	JP	nc,c_fois3
a_fois3
	LD	b,a
	LD	a,c
	SUB	b
	LD	c,a
	JR	cop_a2
c_fois3
	SUB	c
	LD	b,a
	JR	cop_c2
cont_car
	DS	3
	LD	a,d
	JR	d_car10
;
d_car100
	INC	a
d_car10
	DS	12
	CP	c
	JP	nc,c_fois1
;
a_fois1
	LD	b,a
	LD	a,c
	SUB	b
	LD	c,a
copie_a1
	DEC	sp
	POP	af
	LD	(hl),a
	INC	l
	DEC	b
	JP	nz,copie_a1
	JP	new
;   --->   fini dc doit fournir DE en sortie
c_fois1
	NOP	
	SUB	c
	LD	d,a
copie_c1
	DEC	sp
	POP	af
	LD	(hl),a
	INC	l
	DEC	c
	JP	nz,copie_c1
	LD	b,1
	JP	(ix)
;
;        Ini
;
;        HL = Adr AYC
;
BUFID1	DS	NBR_REG*5
;
INI_PLAY
	LD	HL,ADRZIK
	LD	DE,BUFID1
	LD	B,NBR_REG
FILL_ID
	INC	DE
	EX	DE,HL
	LD	(HL),0 ;	 D = 0 suffit
	EX	DE,HL
	INC	DE
;
	PUSH	bc
	LD	bc,ADRZIK
	LD	a,(hl)
	ADD	a,c
	LD	(de),a
	INC	hl
	INC	de
	LD	a,(hl)
	ADC	a,b
	LD	(de),a
	INC	hl
	INC	de
	POP	bc
;
	INC	de	; Cont ch ou car
	DJNZ	FILL_ID
;
	CALL	END_PSG
;
;        INITIALISE ROUTINE D'INITIALISATION (HIHI)
;
	LD	HL,DICO100+#100
	LD	(DICO0+1),HL
	LD	HL,BUFID1+5
	LD	(COUPLE0+1),HL
;
;        INITIALISE LES DATAS EN "ESCALIER"
;
	LD	BC,(NBR_REG-1)*256+1
INI_DICO
	PUSH	BC
	LD	(SAVPILE),SP
;
COUPLE0
	LD	SP,BUFID1+5
	POP	DE
	POP	HL
	DEC	SP
	POP	AF
	LD	(COUPLE0+1),SP
	LD	SP,HL
DICO0
	LD	HL,DICO100+#100
;
	LD	IX,RETDEC0
	JP	DECOMPRS
RETDEC0
	LD	(SP2HL1+1),SP
;
SP2HL1
	LD	HL,0
	LD	SP,(COUPLE0+1)
	PUSH	BC
	INC	SP
	PUSH	HL	; Maj Adr_decrunch
	PUSH	DE	; Maj [ Adr_ch ; Lng_ch ]
;
;
	LD	SP,(SAVPILE)
	POP	BC
;
	LD	HL,(DICO0+1)
	INC	H
	LD	(DICO0+1),HL
;
	INC	C
	DJNZ	INI_DICO
;
;        INITIALISE ROUTINE DE DECOMPRESSION 1
;
	LD	HL,DICO100
	LD	(DICO1+1),HL
	LD	HL,BUFID1
	LD	(COUPLE1+1),HL
	LD	A,NBR_REG
	LD	(NBDATA1+1),A
;
	RET	
PLAYER_END

/**
 * Dictionnary of the song player
 */
   align 256
DICO100
PFO100	EQU	DICO100/256	;POIDS FORT DES DICOS (SET 6,H !)

  defs 0x5100-0x4400

/**
 * Song to play
 */
ADRZIK
FREESPACE_FOR_MUSIC equ 0x4000 - ADRZIK
ZIKNB equ 0x1

;    incbin "data/music/BLOCUS.AYC", 128, FREESPACE_FOR_MUSIC ;+ 128
    incbin "data/music/BLOCUS.AYC", 128
	
ADRZIKEND

/**
 * Split song in several parts if needed
 */
;    assert $ == 0x4000
