
CRTC_R7_LOGO_MESSAGES_POSITION 	equ 28
CRTC_R7_EFFECTS_POSITION	equ 1

crtc_transition_effect_to_logo_message
 	call FRAMEWORK_WAIT_VBL
	call FRAMEWORK_PLAY_MUSIC
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 +38- (CRTC_R7_LOGO_MESSAGES_POSITION - CRTC_R7_EFFECTS_POSITION) : out (c), c
	ld bc, 0xbc07 : out (c), c : ld bc, 0xbd00 + CRTC_R7_LOGO_MESSAGES_POSITION : out (c), c
	halt
	halt
	halt
	halt
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 + 38 : out (c), c



 ret


crtc_transition_effect_to_logo_message_no_music
 	call FRAMEWORK_WAIT_VBL
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 +38- (CRTC_R7_LOGO_MESSAGES_POSITION - CRTC_R7_EFFECTS_POSITION) : out (c), c
	ld bc, 0xbc07 : out (c), c : ld bc, 0xbd00 + CRTC_R7_LOGO_MESSAGES_POSITION : out (c), c
	halt
	halt
	halt
	halt
	ld bc, 0xbc04 : out (c), c : ld bc, 0xbd00 + 38 : out (c), c



 ret



crtc_transition_logo_message_effect
    call FRAMEWORK_WAIT_VBL

    halt
    halt
    ld hl, 0xc9fb
    ld (0x38), hl

    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38+29 : out (c), c
    ld bc, 0xbc00+7 : out (c), c
    ld bc, 0xbd00+1 : out (c), c
    halt : halt
    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38 : out (c), c

    halt 
    halt 
    call FRAMEWORK_WAIT_VBL
    call FRAMEWORK_PLAY_MUSIC
    halt 
    halt 
    call FRAMEWORK_INSTALL_INTERRUPTED_MUSIC
  ret
