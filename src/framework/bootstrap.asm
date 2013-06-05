/**
 * Bootstrap code to launch the demo (which cannot be loaded by amsdos)
 * TODO exomize the data
 */

    output bootstrap.o

    ; To obtain framework adress
    include framework.sym

    org 0x4000
    

    jp  code
data
    incbin framework.o
data_end

code
   di
   ld hl, 0xc9fb
   ld (0x38), hl
   ld sp, 0x100
    ld hl, data
    ld de, FRAMEWORK_EXEC
    ld bc, data_end - data
    ldir

    jp FRAMEWORK_EXEC    

    assert $ <0xc000 ; do not destruct amsdos var. Can be bigger without problem
   ; assert (data_end - data + FRAMEWORK_EXEC) < data
