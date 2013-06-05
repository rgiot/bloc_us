/**
 * Load data from the three latests banks in one unique file
 * Interruption must be set
 * C4.exo must be already load (with load_last_banks) separately
 */

  output load_last_banks.o

   org 0
   defs 5

   jr LOADER

/**
 * Leave interrupt
 */
LEAVE
   ld bc, 0x7fc0 ; 3
   out (c), c    ; 2

LOADER
	JP really_load

   ; Do nothing during an interruption
   defs 0x38 - $
   ei
   ret

   ; Stack place
   defs 0x100 - $



really_load

.init
 call FDCON
 ld a, 0 ; TODO use AMSDOS info
 ld b, 0
 call FDCVARS

.readf1
 ld hl, FNAME
 ld de, 0x4000
 ld bc, de
 call LOADFILE
 or a
 jp nz, error_while_loading
.stop
 call FDCOFF

 ;pop hl
 ;pop hl
	JP LEAVE

 include src/framework/READAMSD.MXM


/**
 * Display the type of error
 */
error_while_loading
	cp 1 : jp z, error_disc_missing
	cp 2 : jp z, error_read_fail
error_file_not_found
	ld a, 0x4c ; rouge

display_error
	ld bc, 0x7f10
.loop
	out (c), c
	out (c), a
	dec c
	jr nc, .loop
	jp $

error_disc_missing
	ld a, 0x56 ; vert
	jp display_error

error_read_fail
	ld a, 0x4b ; blanc
	jp display_error

FNAME
 db "UGLY    001"

	assert $<0x4000
