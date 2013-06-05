    org 0x1000
    output credits_screen.o


CREDITS_HEIGHT = 50

;	border everywhere
	ld bc, 0xbc00+1 : out (c), c
	dec c : inc b 
	out (c), c



credits_loop
	ld b, 0xf5
.vbl
	in (a), c
    rra
	jr nc, .vbl
	ei

	halt
	halt

	di
	ld hl, CREDIT_TEXT

	
	dup CREDITS_HEIGHT
		call display_line
	edup



	jp credits_loop


	
	


display_line
 dup 8
	outi		; Read color, move in table, output color
	inc b		; Get back to 0x7f
 edup
 ret

CREDIT_TEXT
  include credits_image.asm

