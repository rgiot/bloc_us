    org 0x1000

SCREEN_WIDTH equ 96
LOGO_HEIGHT equ 165
LOGO_WIDTH  equ 96
DURATION    equ 50*16

/**
 * VAR for rhino display
 */
DISPLAYED_LOGO_WIDTH equ 17
DISPLAYED_LOGO_START equ 40

/**
 * VARS for credits
 */
CREDITS_WIDTH equ 15
CREDITS_HEIGHT equ 32


    call init
    call display_loop
    call copy_logo
    ld hl, 0x2000
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), h
    inc c : dec b
    out (c), c : inc b : out (c), l
    call wait_loop
    ld hl, 0x3000
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), h
    inc c : dec b
    out (c), c : inc b : out (c), l

/*
    ld hl, 0x2000
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), h
    inc c : dec b
    out (c), c : inc b : out (c), l
    ld b, 25
.loop
    push bc
    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC
    halt : halt
    pop bc
    djnz .loop

    ld hl, 0x3000
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), h
    inc c : dec b
    out (c), c : inc b : out (c), l
    ld b, 50 + 75
.loop2
    push bc
    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC
    halt : halt
    pop bc
    djnz .loop2

*/

.loop_clear_logo
    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC

.clear_adr_table
    ld hl, clear_logo_table
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (.clear_adr_table+1), hl
    ld a, e
    or d
    jr z, .end_clear

    ex de, hl
    call clear_logo_bloc
    
    ld hl, (.clear_adr_table+1)
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (.clear_adr_table+1), hl
    ld a, e
    or d
    jr z, .end_clear

    ex de, hl
    call clear_logo_bloc
    

    jr .loop_clear_logo

.end_clear
    call crtc_transition_logo_message_effect
    ret

 
 include clear_logo.asm

/**
 * Initialize effect
 */
init
    ld hl, 0x8000
    ld de, 0x8001
    ld bc, 0x7fff
    ld (hl), 0
    ldir

    call copy_logo
    call patch_logo

    call FRAMEWORK_WAIT_VBL
    call COLOR
    ld bc, 0x7f10 : out (c), c : ld c, 0x4b : out (c), c
    ld bc, 0x7f8d : out (c), c

.init_crtc
    call crtc_transition_effect_to_logo_message_no_music
    ld bc, 0xbc00 +1 : out (c), c : ld bc, 0xbd00 + 96/2 : out (c), c
    ld bc, 0xbc00+6 : out (c), c: ld bc, 0xbd00+21 : out (c), c
    ret


/**
 * Displays logo on screen
 */
copy_logo
    ld hl, LOGO
    ld de, 0xc000
    ld b, LOGO_HEIGHT + 3
.loopy
    push bc

    push de
    ld a, d : sub 0x40 : ld d, a
    ld  bc, LOGO_WIDTH
    ldir
    pop de

    ex de, hl
    call bc26
    ex de, hl


    pop bc
    djnz .loopy
    ret

/**
 * Copy a part of credits
 */
copy_credits
  ld de, 0x8000 + LOGO_WIDTH*19 + 2
.credit_adress
  ld hl, CREDITS
  ld b, 16
.loop
  push bc
  push de

  ld bc, CREDITS_WIDTH
  ldir

  pop de
  ex de, hl
  ld a, h : add 0x40 : ld h, a
  call bc26
  ex de, hl  
  ld a, d : sub 0x40 : ld d, a
  pop bc
  djnz .loop


.tempo ld a,0
  inc a
  ld (.tempo+1), a
  and 7
  ret nz

  ld hl, (.credit_adress+1)
  ld de, CREDITS_WIDTH
  add hl, de
  ld (.credit_adress+1), hl
 ret
/**
 * Remove part of text
 */
patch_logo
.patch1
    ld hl, 0xc000 + LOGO_WIDTH*8 + DISPLAYED_LOGO_START - 4

    ld b, 40
.loop1
    push bc
    push hl
    ld a, h : sub 0x40 : ld h, a
    ld de, hl
    inc de
    ld (hl), 0x0
  .5  ldi
    pop hl
    call bc26
    pop bc
    djnz .loop1


.patch2
    ld hl, 0xc000 + LOGO_WIDTH*7 + DISPLAYED_LOGO_START + DISPLAYED_LOGO_WIDTH*2 - 1

    ld b, 40
.loop2
    push bc
    push hl
    ld a, h : sub 0x40 : ld h, a
    ld de, hl
    inc de
    ld (hl), 0x0
  .4  ldi
    pop hl
    call bc26
    pop bc
    djnz .loop2
 ret

/**
 * Display the screen several seconds
 */   
wait_loop
    call FRAMEWORK_WAIT_VBL
    halt : halt

    ld hl, 0xc9fb
    ld (0x38), hl

    ld bc, DURATION
.loop
    push bc
    call FRAMEWORK_WAIT_VBL
    ld bc, 0x7f8d : out (c), c
    call FRAMEWORK_PLAY_MUSIC
    halt:halt

	ld b, 40
.looptempo
	defs 64-5
	djnz .looptempo
	
	defs 9 + 61
    call split_rasters


    call copy_credits

    pop bc
    dec bc
    ld a, b
    or c
    jp nz, .loop

    ret

/**
 * displays split rasters
 */
split_rasters

	di
	ld bc, 0x7f02 : out (c), c
	;ld hl, 0x4c40
	;ld de, 0x4e58

COL1=0x5d
COL2=0x4e
COL3=0x42
        ld hl, 0x4240
        ld de, 0x5d4e
	dup 30
	call split_raster_rout2
	edup
	dup 30
	call split_raster_rout2
	edup
	out (c), l

/*

	ld bc, 0x7f5e
	ld hl, 0x0010
	out (c), h : out (c), c
	out (c), l : out (c), c

 	ld b, 30
.loop
	defs 64-5
	djnz .loop
 */
	ld bc, 0x7f4b
	ld hl, 0x0010
	out (c), h : out (c), c
	out (c), l : out (c), c


	ei

    ret

split_raster_rout2
TEMPO1a=20 - 5 - 4 -2-1
TEMPO1b=5+2+1
TEMPO2=11
TEMPO3=7
	defs TEMPO1a, 0
	out (c), e
	defs TEMPO1b,0
	out (c), l
	defs TEMPO2, 0
	out (c), h
	defs TEMPO3, 0
	out (c), d
	defs 64 - 3 - 5 - TEMPO3-4- TEMPO1a - TEMPO1b - 4 - TEMPO2 -4 - 4, 0
	ret




/**
 * Display logo on screen
 */
display_loop
	halt : halt

NB_BLOC=0 
SCREEN_ADRESS=0xc000 + DISPLAYED_LOGO_START
    dup LOGO_HEIGHT/8 + 1
NB_BLOC=NB_BLOC+1
DELAY=NB_BLOC*15
DELAY_POKE=$+1
        ld bc, DELAY
        ld a, b
        or c
        jr z, 2f
        dec BC
        ld (DELAY_POKE), bc
        jr 1f
2
        ld hl, SCREEN_ADRESS
SCREEN_ADRESS=SCREEN_ADRESS+SCREEN_WIDTH
PIXEL_NUMBER=$+1
        ld bc, 0

        ld a, 8*8
        cp c
        jr z, 1f
        push bc
        call display_line_bloc
        pop  bc
        inc c
        ld (PIXEL_NUMBER), bc
1
    edup
    ld a, (PIXEL_NUMBER)
    cp 8*8
    ret z
    jp display_loop
    
/**
 * Display the eight lines of one logo
 */
display_line_bloc
  ; Store start adress
  push hl

 if 0
 dup 8
  push hl
  ld bc, LOGO_WIDTH
  ldir
  pop hl
  call bc26
 edup
 
else


  ; Select the display routine
  ld ix, DISPLAY_BLOC_TABLE
  add ix, bc
  add ix, bc
  ld c, (ix+0)
  ld b, (ix+1)
  ld (.rout+1), bc

  ; copy one bloc in all width
/*
  ld b, LOGO_WIDTH
.copy_blocs
  push bc
  push hl
*/
.rout call BLOC_DISPLAY_ROUTINES_PIX0
/*
  pop hl
 .2 inc hl
  pop bc
  djnz .copy_blocs
 endif
*/  
  ; Compute next line bloc
   pop hl

   ; next screen line
   ld bc, SCREEN_WIDTH
   add hl, bc

        ret


LINE_TABLE_METHOD
 defs LOGO_HEIGHT/8, 0

/**
 * Compute next line adress
 */
bc26
        ld a,8
        add h
        ld h,a
        and 64
        ret nz
        ld bc,0x3fa0
        sbc hl,bc
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
    db &4b
    db &54
    db &40
    db &56
    db 0


 include src/framework/logo_message_vars.asm
    include macro_bloc.asm

CREDITS
    defs CREDITS_WIDTH*10
    defs CREDITS_WIDTH*10
    incbin "data/logo/credits.scr", 128
  ;  incbin data/logo/credits.scr
  ;  incbin "data/logo/CREDITS.WIN", 128+2
    defs CREDITS_WIDTH*50



LOGO
    incbin "data/logo/rhino.scr", 128
    defs 96*4
    assert $ < 0x8000
    assert $<0xc000
FRAMEWORK_WAIT_VBL: equ 0x000001A6
FRAMEWORK_INSTALL_INTERRUPTED_MUSIC: equ 0x0000013B
FRAMEWORK_PLAY_MUSIC: equ 0x00000134
