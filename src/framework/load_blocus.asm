     output load_blocus.o

    org 0x1000

    ld a, 2 : call 0xBC0E

    xor a: ld bc, 3*256 + 3
.loopink
    push bc, af
    call &BC32
    pop af, bc
    inc a
    cp 16
    jr nz, .loopink
    ld bc, 3*256 + 3 : call &BC38
    ld a, 1 : ld bc, 24*256 + 24 : call &BC32

    ld hl, TEXT
.loop
    ld a, (hl)
    or a
    jr z, .endloop
    push hl
    call 0xbb5a
    pop hl
    inc hl
    jr .loop
.endloop

    di
    ld hl, 0xc9fb
    ld (0x38), hl
    ld sp, 0x100

    call FDCON
    ld hl,(&be7d)
    ld a,(hl)
    ld b, 0
    call FDCVARS
    call RECALIBR

    ld bc, 0x7fc4 : out (c), c
    ld hl, C4BANK
    ld de, 0x4000
    ld bc, de
    call LOADFILE
/*
    ld hl, C4
    ld bc, C4_end - C4
    ld de, 0x4000
    ldir
*/
    ld bc, 0x7fC5 : out (c), c
    ld hl, C5BANK
    ld de, 0x4000
    ld bc, de
    call LOADFILE

    ld bc, 0x7fC6 : out (c), c
    ld hl, C6BANK
    ld de, 0x4000
    ld bc, de
    call LOADFILE

    ld bc, 0x7fC7 : out (c), c
    ld hl, C7BANK
    ld de, 0x4000
    ld bc, de
    call LOADFILE


    ld bc, 0xbc00+1 : out (c),c 
    dec c : inc b : out (c), c

    ld bc, 0x7fc0 : out (c), c
    ld hl, BOOTSTRAP
    ld de, 0x4000
    ld bc, BOOTSTRAP_end - BOOTSTRAP_end
    ldir


    jp 0x4000


TEXT
    include src/framework/loading_ascii_art.asm
    db 0


/*
C4
    incbin "BLOCUS.001", 128
C4_end
*/
 assert $<0x4000


C4BANK db 'BLOCUS  001'
C5BANK db 'BLOCUS  002'
C6BANK db 'BLOCUS  003'
C7BANK db 'BLOCUS  004'

BOOTSTRAP
    incbin bootstrap.o
    include READAMSD.MXM
BOOTSTRAP_end

