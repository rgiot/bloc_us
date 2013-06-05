/**
 * Fullscreen rotozoom implementation 
 */

 output fullscreenrotozoom.o

ALONE equ 1=0

NB_FRAMES equ 50*30

LOAD equ 0x1000
ROTOZOOM_HEIGHT equ 31
TEXTURE equ 0x8000

IMAGE_WIDTH equ (64/2)
IMAGE_HEIGHT equ  128
DELTA_X equ (256-IMAGE_WIDTH)/2
DELTA_Y equ 0
OUTPUT_BUFFER equ TEXTURE

CODE_INC_L   equ #2C
CODE_DEC_L   equ #2d
CODE_INC_H   equ #24
CODE_DEC_H   equ #25


 macro COLOR  
       ld bc, 0x7f00

 dup 17
       ld a,(hl)
       out (c),c
       out (c),a
       inc hl
       inc c
 edup
 endm

    org LOAD

 /**
  * Displaying code of the rotozoom
  * Read texture
  * Move in texture
  * Display texture 
  * Anything else
  */
 macro MACRO_ROTOZOOM_LINE_BLOC
BLOC_POS=0
    ;dup 96/2
BLOC_POS=BLOC_POS+1
ADR_START=$
        ld e, (hl)  ; Read texture byte                            ;2
        ld d, e     ; Copy byte for displaying a word              ;1
        
ADR_MOV_HOR=$
        inc l       ; Move in texture horizontal                   ;1
ADR_MOV_VER=$
        nop         ; Move in texture veritical                    ;1

        push de     ; Copy word on screen                          ;4

 ;       push de     ; Copy other word                              ;4
ADR_END=$
    ;edup
    ;defs 96/4*5, 0
    ; => 432 nops

 endm

 /**
  * Select the screen to work on and the other to display
  */
 macro SELECT_SCREEN_TO_WORK nb
    ; Get the right things
    if nb == 0
SCREEN_ADRESS=0xc000+96
CRTC_ADRESS=0x3000 + 96/2
    else
SCREEN_ADRESS=0xc000+96+96
CRTC_ADRESS=0x3000
    endif
 
    ld sp, SCREEN_ADRESS
    ld de, CRTC_ADRESS
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), d 
    dec b : inc c
    out (c), c : inc b : out (c), e
 endm



/**
 * Move the texture
 *
 * HL' = last texture
 * BC' = last fixed point values
 * DE' = deltas
 *
 
 * TODO: need to patch the code when other rotation side
 */
 macro MOVE_TEXTURE_VERTICALLY
START_MOVE_TEXTURE_VERTICALLY=$
    exx

  ; Move in first coordinate

    ld a, c : add e : ld c, a
    jr c, .move_first
    jr .end_move_first  ; b2
.move_first     ; a3
DELTA_FIRST_COORD = $ - START_MOVE_TEXTURE_VERTICALLY
    inc l       ; a4        ; TODO replace by dec h if needed
    nop         ; a5
.end_move_first ; b5, a5
    
    

  ; Move in second coordinate
    ld a, b : add d : ld b, a
    jr c, .move_second
    jr .end_move_second  ; b2
.move_second     ; a3
DELTA_SECOND_COORD = $ - START_MOVE_TEXTURE_VERTICALLY
    inc h       ; a4        ; TODO replace by dec h if needed
    nop         ; a5
.end_move_second ; b5, a5


 ; Export Texture coordinate to main registers
    ld a, h : exx : ld h, a : exx
    ld a, l : exx : ld l, a

 endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;

go

    call rotozoom_init
    ld hl, 0xc9fb : ld (0x38), hl

.main_loop
 ;; Main loop of the demo
    ld b, 0xf5
.vbl
    in a, (c)
    rra
    jr nc, .vbl
    
     ld hl, 0x0701 : ld b, 0xbc
     out (c), h : inc b : out (c), l
     di

effect_loop
  xor a
  ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a
  RST 0


;; Test if the effect is finished
.tempo_display 
    ld bc, NB_FRAMES
 if ALONE
  dw 0
 else
    dec bc
 endif
    ld (.tempo_display+1), bc
    ld a, b
    or c
    jp z, effect_end

  ;pause
  ld b, 156
  djnz $



.parameters
    exx
.delta    ld de, 255*128 + 0
    ld bc, de
    exx


.texture_start
    ld hl, 0x4000 - 35 + 7*256
.u  ld a, 0
    add l
    ld l, a
.v  ld a, 0
    add h
    ld h, a
  ;  ld l, -40

.move ld a, 0
    inc a
    and 127
    ld (.move+1), a
    
    add l
    ld l, a
    push hl
    exx : pop hl : exx


    call ROTOZOOM_LINE_BLOC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; nextstep
rotozoom_next_step
  ld hl, ROTOZOOM_TABLE_DECALAGE+ 5*(137)

  ; Gestion u
  ld a, (hl) : inc hl
  ld (effect_loop.u+1),a

  ; Gestion v
  ld a, (hl) : inc hl
  ld (effect_loop.v+1),a

  ; Gestion X
  ld a, (hl) : inc hl
  ld (effect_loop.delta+1), a

  ; Gestion Y
  ld a, (hl) : inc hl
  ld (effect_loop.delta+2), a

  ; Gestion generation code
  ld d, 0
  ld a, (hl) : inc hl
  ld (rotozoom_next_step+1), hl
  push hl
  ld e, a
  or a

  ld hl, ROTOZOOM_GENERATEUR_FONCTIONS
  add hl, de
  add hl, de
  ld e, (hl) : inc hl : ld d, (hl)
  ld (code_fonction+1), de


  ; Verification de non debordement
  pop hl
  ld de, ROTOZOOM_TABLE_DECALAGE_FIN
  or a : sbc hl, de
  ld a, h
  cp l
  or a
  jr nz, nextstep_no_move

  ld hl, ROTOZOOM_TABLE_DECALAGE
  ld (rotozoom_next_step+1), hl
  jr nextstep_end
nextstep_no_move
  defs 6
nextstep_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; nextstep

    ld b, 70
    djnz $

    ld bc, 0xbc00+1 : xor a
    out (c), c : inc b : out (c), a



   ld de, (effect_loop.delta+1)
code_fonction
    call rotozoom_genere_code_pos_pos
 


  ld a, 1
  ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a

    ld b,16*4 -3
    djnz $
    jp effect_loop


/**
 * Leave effect
 */
effect_end
 ld hl, 0x0907
 ld b, 0xbc
 out (c), h: inc b: out (c), l : dec b
 ld hl, 0x0400+38
 out (c), h : inc b : out (c), l


  di:RST 0:ei
 ret

/**
 * Code de copie de texture
 */
copy_texture
copy_texture_begin
    MACRO_ROTOZOOM_LINE_BLOC
copy_texture_end
    defs (copy_texture_end-copy_texture_begin)* ( (96/2) - 1), 0
    jp (ix)

/**
 * Code for displaying a line in the rotozoom
 */
ROTOZOOM_LINE_BLOC
    ld (backsp+1), sp
    ld a, ROTOZOOM_HEIGHT/2
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
     SELECT_SCREEN_TO_WORK 0
ROTOZOOM_LINE_BLOC_LOOP

;;; Code for the odd lines
first_half
    ld ix, first_half_end_copy
    jp copy_texture
first_half_end_copy
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    defs 27 - 9 - (3+2+4+1+4)
   ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a

first_half_real_end



;;; Code for the even lines
second_half    
    ld ix, second_half_end_copy
    jp copy_texture
second_half_end_copy
    SELECT_SCREEN_TO_WORK 0
second_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    defs 27  - (2+1+3+1+4+9)
second_half_real_end

ROTOZOOM_LINE_BLOC_COUNT
    ld a, ROTOZOOM_HEIGHT/2
    dec a
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
    or a
    jp nz, ROTOZOOM_LINE_BLOC_LOOP

first_half2
    ld ix, first_half_end_copy2
    jp copy_texture
first_half_end_copy2
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture2
    MOVE_TEXTURE_VERTICALLY
    defs 27 - 9 - (3+2+4+1+4)
   ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a

first_half_real_end2




ROTOZOOM_LINE_BLOC_END
backsp ld sp, 0
    ret


rotozoom_init 

.copy_code
 ld hl, copy_texture_begin
 ld de, copy_texture_end
 ld bc, (copy_texture_end-copy_texture_begin)*((96/2)-1)
 ldir
       
.init_display_code
    ld de, 0
    call rotozoom_genere_code_pos_pos

.build_texture
 ld hl, 0x5000
 ld de, 0x5000+1
 ld bc, 0x2fff + 0x4000 +0x4000
 ld (hl), 0xff
 ldir

     ; Copy
  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 0*128
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 1*128
  call include_image_in_memory

 ld hl, 0x8000 
  ld de, 0x4000
  ld bc, 0x3fff
  ldir


    ld bc, 0x7f8c : out (c), c
    ld b, 0xbc
    ld hl, 0x0100 + 96/2
    out (c), h : inc b : out (c), l : dec b
    ld hl, 12*256 + 0x30
    out (c), h : inc b : out (c), l : dec b
    ld hl, 13*256
    out (c), h : inc b : out (c), l : dec b
    ld hl, 0x0200+50
    out (c), h : inc b : out (c), l : dec b
    
selected_color
   ld hl, COULEURS_DAMIER_BN
   COLOR 

   ld bc, 0x7f10 : out (c), c
   ld bc, 0x7f58 : out (c), c
    ret

include_image_in_memory
  ld a, IMAGE_HEIGHT
.loop_height
	push af ; Store height counter
	push de ; Store output buffer adress
	
	ld a, IMAGE_WIDTH
.loop_width
	push af ; Store width counter

.left_pixel
	ld a, (hl)			; Get byte
	and %10101010 			; Extract left pixel
	ld b, a				; Store left pixel
	or a				; Remove carry
	rra				; Transform in right pixel
	and %01010101
	or b ; double pixel		; Build the byte
	ld (de), a			; Store the byte with two equal pixels
	dec d ; next position		; Move in buffer


.right_pixel
	ld a, (hl)			; Get same byte
	and %01010101 			; Get right pixel
	ld b, a				; Store right pixel
	or a 				; Remove carry
	rla				; Transform in left pixel
	and %10101010
	or b ; double pixel		; Build the byte
	ld (de), a			; Store the byte
	dec d 				; next buffer position
		
	inc hl				; Read next byte for next two pixels

	pop af				; Get width counter
	dec a				; Loop until line finished
	jp nz,.loop_width
	
	pop de				; Get buffer position
	inc e 				; Go to the beginning of next line

	pop af				; Get height counter
	dec a				; loop
	jp nz, .loop_height
 

	ret




 include donneesEncre.asm
CORRES_COUL_BYTE
 db 0
 db OCTET_ENCRE1
 db OCTET_ENCRE2
 db OCTET_ENCRE1 + OCTET_ENCRE2
 db OCTET_ENCRE4
 db OCTET_ENCRE4 + OCTET_ENCRE1
 db OCTET_ENCRE4 + OCTET_ENCRE2
 db OCTET_ENCRE4 + OCTET_ENCRE2+OCTET_ENCRE1
 db OCTET_ENCRE8
 db OCTET_ENCRE8 + OCTET_ENCRE1
 db OCTET_ENCRE8 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE1 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE4
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE1
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE2 + OCTET_ENCRE1




COULEURS_DAMIER_BN
	db 0x54	; ink 0
	db 0x44	; ink 1
	db 0x5c	; ink 2
	db 0x58	; ink 3
	db 0x45	; ink 4
	db 0x56	; ink 5
	db 0x57	; ink 6
	db 0x5e	; ink 7
	db 0x40	; ink 8
	db 0x4e	; ink 9
	db 0x47	; ink 10
	db 0x47	; ink 11
	db 0x52	; ink 12
	db 0x5b	; ink 13
	db 0x43	; ink 14
	db 0x4b	; ink 15

/*
	db 0x54	; ink 0
	db 0x5c	; ink 1
	db 0x54	; ink 2
	db 0x56	; ink 3
	db 0x5e	; ink 4
	db 0x5e	; ink 5
	db 0x40	; ink 6
	db 0x5e	; ink 7
	db 0x5a	; ink 8
	db 0x4a	; ink 9
	db 0x59	; ink 10
	db 0x4b	; ink 11
	db 0x5b	; ink 12
	db 0x4a	; ink 13
	db 0x43	; ink 14
	db 0x4b	; ink 15
*/

	db 0


COULEURS_TABLE
 dw 50*5, COULEURS_DAMIER_BN
 dw 50*5, COULEURS_DAMIER_BN
 dw 50*5, COULEURS_DAMIER_BN
 dw 0

DELTA_MOV_HOR equ ADR_MOV_HOR - ADR_START
DELTA_MOV_VER equ ADR_MOV_VER - ADR_START
DELTA_END equ ADR_END - ADR_START


 /**
  * Macro qui patche le code existant
  */
 macro ROTOZOOM_GENERE_GENERATEUR_CODE OPCODE_HORIZ_X, OPCODE_HORIZ_Y
    ld hl, copy_texture + DELTA_MOV_HOR
    ld b, d: ld c, e ; BC = backup deltas
                     ; DE => adresse stockant la somme

    dup 96/2
    
 ;  ld a, 96/2
4
   ex af, af'


    ;; Delta horizontal
      ld a, e ; Recuperation ancienne valeur
      add c   ; Ajout du decalage
      ld e, a ; stocke nouvelle valeur
      jr nc, 2f ;test si overflow et necessite de changer le pixel
;.overflowx
1
      ; besoin de modifier la pente X
      ld a, OPCODE_HORIZ_X
      jr 3f
;.pasoverflowx ; pas besoin de modifier la pente X
2
      xor a
      nop
      nop
      nop
;.store
3
      ld (hl), a
      inc hl ; Decalage a l'operation suivante


 ;; Delta vertical
      ld a, d ; Recuperation ancienne valeur
      add b   ; Ajout du decalage
      ld d, a ; stocke nouvelle valeur
      jr nc, 2f ;test si overflow et necessite de changer le pixel
;.overflowx
1
      ; besoin de modifier la pente X
      ld a, OPCODE_HORIZ_Y
      jr 3f
;.pasoverflowx ; pas besoin de modifier la pente X
2
      xor a
      nop
      nop
      nop
;.store
3
      ld (hl), a

      dup DELTA_END - DELTA_MOV_VER + DELTA_MOV_HOR
       inc hl
      edup


  ; ex af, af'
 ;  dec a
 ;  jr nz, 4b
 edup
 endm

 /**
  * Code de substitutation des opcodes de decalage vertical de la texture
  */
 macro PATCH_DELTA_VERTICAL CODE_X, CODE_Y
    ld a, CODE_X
    ld (first_half_before_move_texture + DELTA_FIRST_COORD), a
    ld (second_half_before_move_texture + DELTA_FIRST_COORD), a

    ld a, CODE_Y
    ld (first_half_before_move_texture + DELTA_SECOND_COORD), a
    ld (second_half_before_move_texture + DELTA_SECOND_COORD), a
 endm

rotozoom_genere_code_pos_pos
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_INC_L, CODE_INC_H
.end
    PATCH_DELTA_VERTICAL            CODE_INC_H, CODE_DEC_L
    ret

rotozoom_genere_code_neg_pos
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_DEC_L, CODE_INC_H
.end
    PATCH_DELTA_VERTICAL            CODE_DEC_H, CODE_DEC_L
    ret

rotozoom_genere_code_pos_neg
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_INC_L, CODE_DEC_H
.end
    PATCH_DELTA_VERTICAL            CODE_INC_H, CODE_INC_L
    ret

rotozoom_genere_code_neg_neg
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_DEC_L, CODE_DEC_H
.end
    PATCH_DELTA_VERTICAL            CODE_DEC_H, CODE_INC_L
    ret


ROTOZOOM_GENERATEUR_FONCTIONS
 dw rotozoom_genere_code_pos_neg   ; 01
 dw rotozoom_genere_code_neg_pos   ; 10
 dw rotozoom_genere_code_pos_pos   ; 11
 dw rotozoom_genere_code_neg_neg

ROTOZOOM_TABLE_DECALAGE
    include data/rotozoom/full.txt
    include data/rotozoom/full2.txt
ROTOZOOM_TABLE_DECALAGE_FIN

  assert $ < 0x4000
sprite_image
SOURCE
  incbin fullscreen_rotozoom_picture.o
inc
    assert $ < 0x5000
    assert $ < TEXTURE


