	output message_display.o

DURATION=50*10

	org 0x1000

    ld hl, TABLE_THEMES
    add hl, de
    add hl, de
    ld e, (hl) : inc hl : ld d, (hl)
  
    ld (attente.selected_table+1), de

FRAMEWORK_WAIT_VBL: equ 0x000001A6

 call crtc_transition_effect_to_logo_message

 call flash


;;; wait
attente
 ld bc, DURATION
.loop_wait
 push bc
 call FRAMEWORK_WAIT_VBL
 ld bc, 0xbc00 + 1 : out (c), c : ld bc, 0xbd00 + 96/2 : out (c), c

 halt
 halt
.selected_table
 ld hl, COLOR_TABLE1
 defs 30
 call diplay_rasters
 
 pop bc
 dec bc
 ld a, b
 or c
 jr nz, .loop_wait
 ld bc, 0xbc00 + 1 : out (c), c : ld bc, 0xbd00  : out (c), c


 ;;; R7 crtc transition

sortie
 call crtc_transition_logo_message_effect


 call flash

 ret



/**
 * Display the colors of the message
 */
diplay_rasters

 ;; Select bakground color
 dec l 
 ld a, (hl)
 inc l 

 ld bc, 0x7f10 : out (c), c : out (c), a
 ld bc, 0x7f00 : out (c), c : out (c), a
 ld bc, 0x7f01 : out (c), c : out (c), a


    exx
.curvea ld hl, curve+30 + 256
.curveb ld de, curve + 256
    exx
.start ld a, 10


 ld d, 200
.loop
    defs 40 - 4

    exx
    add (hl)
    ex de, hl
    add (hl)
    ex de, hl
    
    .2 dec l
    .3 inc e
    exx

    ld l, a
    ld a, (hl)
    out (c), c
    out (c), a

    dec d
    jr nz, .loop
 
.tempo2
 ld a, 0
 inc a
 and 3
 ld (.tempo2+1), a
 jr nz, .next_tempo2
 
 ld a, (.curvea+2) : inc a : ld (.curvea+2), a
 ld a, (.curveb+2) : dec a : ld (.curveb+2), a
 ld a, (.start+1) : inc a : ld (.start+1), a

.next_tempo2
 ret



flash
 dup 3
 call FRAMEWORK_WAIT_VBL
 ld bc, 0x7f10 : out (c), c
 ld bc, 0x7f54 : out (c), c
 halt : halt
 edup

 dup 5
 call FRAMEWORK_WAIT_VBL
 ld bc, 0x7f10 : out (c), c
 ld bc, 0x7f44 : out (c), c
 halt : halt
 edup


 dup 4
 call FRAMEWORK_WAIT_VBL
 ld bc, 0x7f10 : out (c), c
 ld bc, 0x7f40 : out (c), c
 halt : halt
 edup

 dup 5
 call FRAMEWORK_WAIT_VBL
 ld bc, 0x7f10 : out (c), c
 ld bc, 0x7f4b : out (c), c
 halt ; halt
 edup
 ret

 include src/framework/logo_message_vars.asm

TABLE_THEMES
 dw COLOR_TABLE1
 dw COLOR_TABLE2
 dw COLOR_TABLE3


/**
 * Color table
 */

COLOR_VERY_DARK=0x44
COLOR_DARK=0x56
COLOR_NORMAL=0x52
COLOR_LIGHT=0x59

    align 256
COLOR_TABLE1
 defs 256/4, COLOR_LIGHT
 defs 256/4, COLOR_NORMAL
 defs 256/4, COLOR_DARK
 defs 256/4, COLOR_VERY_DARK



COLOR_VERY_DARK=0x58
COLOR_DARK=0x40
COLOR_NORMAL=0x43
COLOR_LIGHT=0x4b

    align 256
COLOR_TABLE2
 defs 256/4, COLOR_LIGHT
 defs 256/4, COLOR_NORMAL
 defs 256/4, COLOR_DARK
 defs 256/4, COLOR_VERY_DARK

COLOR_VERY_DARK=0x54
COLOR_DARK=0x5c
COLOR_NORMAL=0x4c
COLOR_LIGHT=0x4e

    align 256
COLOR_TABLE3
 defs 256/4, COLOR_LIGHT
 defs 256/4, COLOR_NORMAL
 defs 256/4, COLOR_DARK
 defs 256/4, COLOR_VERY_DARK


 align 256
curve
 include src/plasma/plasma_curve1.asm
 assert $<0x4000
FRAMEWORK_PLAY_MUSIC: equ 0x00000134
FRAMEWORK_INSTALL_INTERRUPTED_MUSIC: equ 0x0000013B
