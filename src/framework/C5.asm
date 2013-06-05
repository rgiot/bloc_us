 output C5.o
 org 0x4000

/**
 * Contains:
 * End of music (if size too big for C4)
 * Other effects
 */
FREESPACE_FOR_MUSIC: equ 0x00002E00
ADRZIKEND: equ 0x00003D80
ADRZIK: equ 0x00001200
ZIKNB: equ 0x00000001

;    incbin "data/music/ELIOT.AYC", 128 + FREESPACE_FOR_MUSIC



FULLSCREEN_KALEIDOSCOPE_EXO
  incbin fullscreenkaleidoscope.exo
FULLSCREEN_KALEIDOSCOPE_EXO_end



FULLSCREEN_PLASMA_EXO
  incbin fullscreenplasma.exo
FULLSCREEN_PLASMA_EXO_end

FULLSCREEN_ROTOZOOM_EXO
  incbin fullscreenrotozoom.exo
FULLSCREEN_ROTOZOOM_EXO_end


GREETINGS_EXO
  incbin greetings.exo
GREETINGS_EXO_end

AFFICHE_LOGO2_EXO
 incbin affiche_logo2.exo
AFFICHE_LOGO2_EXO_end


MESSAGE_DISPLAY
    incbin "message_display.exo"
MESSAGE_DISPLAY_end
 assert $ < 0x8000
