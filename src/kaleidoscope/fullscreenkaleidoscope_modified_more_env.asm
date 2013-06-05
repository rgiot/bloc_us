/**
 * Fullscreen rotozoom implementation 
 */

 output fullscreenkaleidoscope.o

ALONE equ 1
NB_FRAMES equ 50*20

LOAD equ 0x1000
ROTOZOOM_HEIGHT equ 32
TEXTURE equ 0x8000

TEMPO equ 35
IMAGE_WIDTH equ (32/2)
IMAGE_HEIGHT equ  64
DELTA_X equ (256-IMAGE_WIDTH)/2
DELTA_Y equ 0
OUTPUT_BUFFER equ TEXTURE


CODE_INC_L   equ #2C
CODE_DEC_L   equ #2d
CODE_INC_H   equ #24
CODE_DEC_H   equ #25


 macro COLOR  
       ld bc, 0x7f00

 dup 16
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
 macro MACRO_ROTOZOOM_LINE_BLOC pb
BLOC_POS=0
BLOC_POS=BLOC_POS+1
ADR_START=$
        ld c, (hl)  ; Read texture byte                            ; 2
        ld b, c     ; Copy byte for displaying a word              ; 1
        
ADR_MOV_HOR=$
        inc l       ; Move in texture horizontal                   ; 1
ADR_MOV_VER=$
        nop         ; Move in texture veritical                    ; 1

        push bc     ; Copy word on screen                          ; 4

	ld a, c							   ; 1
        ld (de), a						   ; 3
        inc e                                                      ; 3 
        ld (de), a						   ; 3

 if pb
	inc de
 else
        inc e   ; mettre en de aux endroits problematiques                                                   ;1
 endif
 

ADR_END=$

 endm

 /**
  * Select the screen to work on and the other to display
  */
 macro SELECT_SCREEN_TO_WORK nb

    ld e, (iy+2) : ld d, (iy+3)
    ld l, (iy+0) : ld h, (iy+1)
    ld sp, hl

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
    
.main_loop
 ;; Main loop of the demo
    ld b, 0xf5
.vbl
    in a, (c)
    rra
    jr nc, .vbl
     ld hl, 0xc9fb
    ld (0x38), hl


     di
     ld hl, 0x0701 : ld b, 0xbc
     out (c), h : inc b : out (c), l
     

effect_loop
  xor a
  ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a

  ld hl, 0x3000 + 96*16/2
  ld bc, 0xbc00 + 12 : out (c), c : inc b : out (c), h : dec b : inc c
  out (c), c : inc b : out (c), l



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

    RST 0



.tempo_couleur
    ld bc, 1
    dec bc
 ;   ld (.tempo_couleur+1), bc
    ld a, b
    or c
    jr nz, .no_color_change

.pos_table
    ld hl, COULEURS_TABLE+4
.pos_table_after
    ld e, (hl) : inc hl
    ld d, (hl) : inc hl
    ld a, e
    or d
    jr nz, .no_pb
    ld hl, COULEURS_TABLE
    jr .pos_table_after
.no_pb
    ld c, (hl) : inc hl
    ld b, (hl) : inc hl

    ld (.pos_table+1), hl
    ld (.tempo_couleur+1), de
 ;   ld (.selected_color+1), bc

  
.no_color_change




   ld de, (.delta+1)
.code_fonction
    call rotozoom_genere_code_pos_pos



    defs TEMPO
.parameters
    exx
.delta    ld de, 255*128 + 0
    ld bc, de
    exx


.texture_start
    ld hl, TEXTURE + 128 + 5*256
.u  ld a, 0
    add l
    ld l, a
.v  ld a, 0
    add h
    ld a, h
    push hl
    exx : pop hl : exx

    LD IY, ROTOZOOM_TABLE_CRTC_ADRESSES
    ld (backspa+1), sp
    SELECT_SCREEN_TO_WORK 0
second_halfa
    ld ix, second_half_end_copya
    jp copy_texture
second_half_end_copya
second_half_before_move_texturea
second_half_real_enda
    ld de, 6 : add iy, de
backspa ld sp, 0

    exx: push hl : exx : pop hl

    call ROTOZOOM_LINE_BLOC

  ld bc, 0xbc01 : out (c), c : inc b : dec c : out (c), c
 

.tempo_add
  ld a, 0
  inc a
  ld (.tempo_add+1), a
  and %1
  ld hl, (effect_loop.texture_start+1)
  add l
  ld l, a
  ld (effect_loop.texture_start+1), hl
   

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; nextstep
.rotozoom_next_step
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
  ld (.rotozoom_next_step+1), hl
  push hl
  ld e, a
  or a

  ld hl, ROTOZOOM_GENERATEUR_FONCTIONS
  add hl, de
  add hl, de
  ld e, (hl) : inc hl : ld d, (hl)
  ld (effect_loop.code_fonction+1), de


  ; Verification de non debordement
  pop hl
  ld de, ROTOZOOM_TABLE_DECALAGE_FIN
  or a : sbc hl, de
  ld a, h
  cp l
  or a
  jr nz, .nextstep_no_move

  ld hl, ROTOZOOM_TABLE_DECALAGE
  ld (.rotozoom_next_step+1), hl
  jr .nextstep_end
.nextstep_no_move
  defs 6
.nextstep_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; nextstep
.selected_color
   ld hl, COULEURS_DAMIER_BN
   COLOR 

/*
 ld b, 3
.wait_beforeleave
   defs 64-5
 djnz .wait_beforeleave
*/

 ld b, (64*3+67+14)/5- 6
 djnz $
 defs 19968-19953+1

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
   ld e, (iy+4) : ld d, (iy+5) 
copy_texture_start_code

 ; To do manually unset the flag where ther is no pb
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0 ;
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 0
    MACRO_ROTOZOOM_LINE_BLOC 1 
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1
    MACRO_ROTOZOOM_LINE_BLOC 1

    jp (ix)

/**
 * Code for displaying a line in the rotozoom
 */
ROTOZOOM_LINE_BLOC
 ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a

    ld (backsp+1), sp
    ld a, ROTOZOOM_HEIGHT/2 
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
ROTOZOOM_LINE_BLOC_LOOP

;;; Code for the odd lines
first_half
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    ld ix, first_half_end_copy
    jp copy_texture
first_half_end_copy
    ld de, 6 : add iy, de
    defs 6
    defs 9
  
first_half_real_end



;;; Code for the even lines
second_half    
    SELECT_SCREEN_TO_WORK 0
second_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    ld ix, second_half_end_copy
    jp copy_texture
second_half_end_copy
    defs 6
    defs 4
    ld de, 6 : add iy, de
second_half_real_end



ROTOZOOM_LINE_BLOC_COUNT
    ld a, ROTOZOOM_HEIGHT/2
    dec a
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
    or a
    jp nz, ROTOZOOM_LINE_BLOC_LOOP


ROTOZOOM_LINE_BLOC_END
    ld bc, 0xbc00+1 : xor a
    out (c), c : inc b : out (c), a

backsp ld sp, 0
    ret


rotozoom_init 

   
.init_display_code
    ld de, 0
    call rotozoom_genere_code_pos_pos



.build_texture
 ld hl, 0x5000
 ld de, 0x5000+1
 ld bc, 0x2fff + 0x4000 +0x4000
 ld (hl), l
 ldir

     ; Copy
  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 0*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 1*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 2*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x4000 + 3*64
  call include_image_in_memory

 
  ld hl, SOURCE
  ld de, 0x8000  + 0x2000 + 0*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x2000 + 1*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x2000 + 2*64
  call include_image_in_memory

  ld hl, SOURCE
  ld de, 0x8000  + 0x2000 + 3*64
  call include_image_in_memory



 ld hl, 0x8000 
  ld de, 0x4000
  ld bc, 0x3fff
  ldir


    ld b, 0xbc
    ld hl, 0x0100 + 96/2
    out (c), h : inc b : out (c), l : dec b
    ld hl, 12*256 + 0x30
    out (c), h : inc b : out (c), l : dec b
    ld hl, 13*256
    out (c), h : inc b : out (c), l : dec b
    ld hl, 0x0200+50
    out (c), h : inc b : out (c), l : dec b
    

    ld bc, 0x7f8c : out (c), c
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

COULEURS_DAMIER_BN
  incbin data/kaleidoscope/fullscreen_image.pal
  incbin data/kaleidoscope/fullscreen_image.pal





COULEURS_TABLE
 ;dw 50*5, COULEURS_DAMIER_BN
 dw 2, COULEURS_DAMIER_BN
 dw 0

DELTA_MOV_HOR equ ADR_MOV_HOR - ADR_START
DELTA_MOV_VER equ ADR_MOV_VER - ADR_START
DELTA_END equ ADR_END - ADR_START


 /**
  * Macro qui patche le code existant
  */
 macro ROTOZOOM_GENERE_GENERATEUR_CODE OPCODE_HORIZ_X, OPCODE_HORIZ_Y
    ld hl, copy_texture_start_code + DELTA_MOV_HOR
    ld b, d: ld c, e ; BC = backup deltas
                     ; DE => adresse stockant la somme

    dup 96/4
    
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



/**
 * Table pour les valeurs CRTC
 */

HEIGHT1= 17
HEIGHT2 = ROTOZOOM_HEIGHT - HEIGHT1
ACTUAL_WORKING_SCREEN_MEMORY=0xc000 +96 
ACTUAL_DISPLAYED_SCREEN_CRTC=0x3000 

ROTOZOOM_TABLE_CRTC_ADRESSES
 dup HEIGHT1
   dw ACTUAL_WORKING_SCREEN_MEMORY +96
   dw ACTUAL_DISPLAYED_SCREEN_CRTC
   dw ACTUAL_WORKING_SCREEN_MEMORY 

ACTUAL_WORKING_SCREEN_MEMORY=ACTUAL_WORKING_SCREEN_MEMORY+96
ACTUAL_DISPLAYED_SCREEN_CRTC=ACTUAL_DISPLAYED_SCREEN_CRTC+96/2
 edup

 dup HEIGHT2
ACTUAL_DISPLAYED_SCREEN_CRTC=ACTUAL_DISPLAYED_SCREEN_CRTC-96/2
   dw ACTUAL_WORKING_SCREEN_MEMORY 
   dw ACTUAL_DISPLAYED_SCREEN_CRTC
   dw ACTUAL_WORKING_SCREEN_MEMORY


 edup

/**
 * Table pour la rotation
 */
ROTOZOOM_TABLE_DECALAGE
    include data/rotozoom/full.txt
ROTOZOOM_TABLE_DECALAGE_FIN

    assert $ < 0x4000
sprite_image
SOURCE
  incbin fullscreen_kaleidoscope_picture.o
inc
    assert $ < 0x5000
    assert $ < TEXTURE


