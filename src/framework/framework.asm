/**
 * Demo framework
 * Krusty/Benediction 2011
 *
 */
    output framework.o

FRAMEWORK_EXEC          equ 0x100 ; Adresse for loading

ENABLE_LOGO           equ 1
ENABLE_KALEIDOSCOPE   equ 1
ENABLE_PLASMA         equ 1
ENABLE_ROTOZOOM       equ 1
ENABLE_GREETINGS      equ 1
ENABLE_LOGO2          equ 1

 include basic_color.asm

    org FRAMEWORK_EXEC 

launch

    ; Load the banks
    ;call load_banks

    ld a, 0xc0 : call FRAMEWORK_SELECT_BANK
    ld hl, music_bootstrap
    ld de, 0
    ld bc, music_bootstrap_end - music_bootstrap
    ldir

    rst 0
    jp FRAMEWORK_RUN_DEMO
/*********************
 * Usefull functions *
 *********************/

/**
 * Initialize CRTC from table
 */
FRAMEWORK_SET_CRTC
    ld B,&BC
    LD A,(HL)
    or A
    ret Z
    out (C),A
    inc hl 
    inc B
    ld A,(HL)
    out (c),A
    inc hl
    JR FRAMEWORK_SET_CRTC       

/**
 * Call this function before selecting an extra bank.
 * This allow interruptes code to return to the right bank if necessary
 * Input : a represents the bank to select
 * Modfified : B
 */
FRAMEWORK_SELECT_BANK
    ; Save bank
    ld (FRAMEWORK_SELECTED_BANK), a

    ; Select bank
    ld b, 0x7f
    out (c), a 

    ret

FRAMEWORK_SELECTED_BANK db 0xc0

/**
 * Restore the last used BANK
 */
FRAMEWORK_RESTORE_BANK
    ld a, (FRAMEWORK_SELECTED_BANK)
    ld b, 0x7f
    out (c), a
    ret

/**
 * Play the music
 */
FRAMEWORK_PLAY_MUSIC

    di : RST 0 : ei
    ; Select the right bank
    call FRAMEWORK_RESTORE_BANK
    ret
/**
 * Install the interrupted routine able to play music
 */
FRAMEWORK_INSTALL_INTERRUPTED_MUSIC
    ; Copie jump code
    ld de, 0x38
    ld hl, .VECTEUR
    ldi
    ldi
    ldi
    ret

.VECTEUR jp .INTER
/**
 * Code de Longshot
 * http://cpcrulez.free.fr/coding_logon36.htm
 */
.INTER
        PUSH AF              ; sauvegarde de quelques registrcs
        PUSH DE
        PUSH HL
        PUSH BC
        LD      HL,COUNTI+ 1    ; compteur Inter
        LD      B ,0F5H         ; gestion periode compteur
        IN A,(C)
        RRA
        JR      NC,NEXTI
        LD      (HL),0FFH       ; 1ere Inter
NEXTI
        INC     (HL)            ; Num Inter+l (1/300 x 6)
COUNTI  LD      A,0
        CP      6               ; verif pas de pb ( Cas
        JR      C,OK            ; de CRTC bizarroides )
        XOR A
OK
        SLA     A               ; x 2 + TabVectInt
        LD      C,A
        LD      B,0
        LD      HL,TABINT
        ADD     HL,BC

        LD      A,(HL)          ; donne Ptr VeetNum
        INC     HL
        LD      H,(HL)
        LD      L,A
        LD      BC,RETOUR       ; adresse retOUr
        PUSH    BC
        JP      (HL)            ; saut VectNum
RETOUR
        POP BC
        POP HL
        POP DE
        POP AF

        EI
        RET

TABINT  DW INT1
        DW INT2
        DW INT3
        DW INT4
        DW INT5
        DW INT6
        DW INT2 

/**
 * First interruption serves to play music
 */
INT1

    ; Save registers
    push ix, iy
    exx : push hl : push bc : push de : exx
    ex af,af' 
    push af
    ex af,af'

    CALL FRAMEWORK_PLAY_MUSIC

    ; Restore registers
    ex af, af' 
    pop af
    ex af, af'
    exx : pop de : pop bc : pop hl : exx
    pop iy, ix

    RET

INT2
INT3
INT4
INT5
INT6
    RET

  /**
   * Wait the vbl
   * @modified: bc, af
   */
FRAMEWORK_WAIT_VBL

 ; Wait VBL
      ld b,&f4:inc b
.loop    in a, (c)
         rra
      jr nc, .loop
     ret
 

  defb 'cent pour cent pur assembleur. sans langage compile dedans !'
  defb "naturellement, la demo ayant ete faite a l'arrache elle est bourree d'erreurs."
  defb "une ligne de merde dans le kaleidoscope, musique pas a 50 Hz lors des transitions,"
  defb "un rotozoom approximatif qui pourrait avoir une plus grande texture, des transitions pourraves,"
  defb "et j'en passe!"
  defb "Pkoi les splits rasters sont bien positionnes avec mon CRTC1 et pas mon CRTC0 ?"
  defb 'je suis preneur de remarques constructives !'
  defb "J'ai d'ailleurs besoin d'infos pour faire des transitions en rvi ..."

/**
 * Border gestion
 */
FRAMEWORK_BORDER
.REGBORDER db 8 ; 8 ou 6
.BORDERONOFF dw 0x0030 ;&0030 ou &0100

/**
 * Activate Border
 */
    
    ld b, 0xbc      ; 2
    ld a, (.REGBORDER)  ; 3
    out (c), a      ; 4
    inc b           ; 1
    ld a, (.BORDERONOFF+0)  ; 3
    out (c), a      ; 4
    ret         ; => 25

/**
 * Deactivate Border
 */
.OFF
    ld b, 0xbc
    ld a, (.REGBORDER)
    out (c), a
    inc b
    ld a, (.BORDERONOFF+1)
    out (c), a

    ret

/**
 * Reset CRTC parameters to avoid bug
 */
FRAMEWORK_RESET_CRTC
flipointro_init_crtc
                            LD  HL, donnees_crtc
                            LD  B, &BC
flipointro_init_crtc_boucle
                            LD  A, (HL)
                            CP  &ff
                            RET Z ; fin de la boucle

                            OUT (C), A ; Selection registre

                            INC B
                            INC HL
                            LD  A, (HL)
                            OUT (C), A ; Chg valeur

                            INC HL
                            DEC B

                            JR  flipointro_init_crtc_boucle
                            

donnees_crtc
    DB  0, 0x3f     ; Nombre de caracteres total en horizontal 0-255.
    DB  1, 0x28     ; Nombre de caracteres affiches en horizontal 0-255.
;   DB  2, 0x2e
    DB  3, 0x8e     ; Longueur de synchronisation 0-15.
    DB  4, 0x26     ; Nombre de lignes total en vertical 0-127
    DB  5, 0x00     ; Synchronisation verticale 0-31
    DB  6, 0x19     ; Nombre de caracteres affiches en vertical 0-127
;   DB  7, 0 ;0x1e      ; Synchronisation verticale (position) 0-127
    DB  8, 0x00     ; Mode entrelace 0-3.
    DB  9, 0x07     ; Scanning 0-31. (Nombre-1 de lignes composants un caractere)
    DB  10, 0x00        ; Ligne de depart du scanning du curseur 0-31
    DB  11, 0x00        ; Ligne de fin du scanning du curseur 0-31.
    DB  12, 0x30        ; Adresse de depart de la memoire ecran 0x8000-0xfff
    DB  13, 0x00        ; 3 est l'octet le moins significatif (poids faible). 
    DB  &ff     ; fin


 ret


/**
 * Decompress data through exomizer
 */
FRAMEWORK_EXOMIZER
 include deexo.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/**
 * RUN the demo
 */
FRAMEWORK_RUN_DEMO
    ; Start the demo
    ld a, 0xc0 : call FRAMEWORK_SELECT_BANK
    ; Install interrupted music player
    call FRAMEWORK_INSTALL_INTERRUPTED_MUSIC
    ei

;;;;; Move from R7 amsdos to R7=0 (base for all effects)
    call FRAMEWORK_WAIT_VBL
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38+29 : out (c), c
    ld bc, 0xbc00+7 : out (c), c
    ld bc, 0xbd00+1 : out (c), c
    halt : halt
    call FRAMEWORK_WAIT_VBL
    ld bc, 0xbc00+4 : out (c), c
    ld bc, 0xbd00+38 : out (c), c

;TODO coder
    ld bc, 0xbc00+2 : out (c), c: ld bc, 0xbd00 + 50 : out (c), c
    ld bc, 0xbc00+1 : out (c), c: ld bc, 0xbd00 + 0 : out (c), c
    
    halt
    halt
    call FRAMEWORK_WAIT_VBL

;;;;

demo_loop
    
 ;;;;;;;;;;;;
 ;;; LOGO ;;;
 ;;;;;;;;;;;;
 if ENABLE_LOGO
    ld b, 4*50
.tempo_wait
    push bc
    call FRAMEWORK_WAIT_VBL
    halt: halt
    pop bc
    djnz .tempo_wait


.manage_logo
 ld hl, 0x3000
 ld bc, 0xbc00  + 12
 out (c), c : inc b : out (c), h
 dec b : inc c
 out (c), c : inc b : out (c), l


 ld hl, AFFICHE_LOGO_EXO
 ld bc, AFFICHE_LOGO_EXO_end - AFFICHE_LOGO_EXO
 assert (AFFICHE_LOGO_EXO_end - AFFICHE_LOGO_EXO) < 0x3fff
 call FRAMEWORK_LAUNCH_EFFECT

 ld a, 0xc7
 ld hl, MESSAGE1
 ld bc, MESSAGE1_end - MESSAGE1
 ld de, 0
 call FRAMEWORK_DISPLAY_PROPAGANDA

  else
   ld a, 0xc5
   ld (FRAMEWORK_LAUNCH_EFFECT.bank+1), a
 endif



 ;;;;;;;;;;;;;;;;;;;;
 ;;; KALEIDOSCOPE ;;;
 ;;;;;;;;;;;;;;;;;;;;
 if ENABLE_KALEIDOSCOPE

.kaleidoscope_all_in_blue
  xor a
  ld bc, 0x7f44
.kaleidoscope_all_in_blue_loop
  out (c), a
  out (c), c
  inc a
  cp 17
  jr nz, .kaleidoscope_all_in_blue_loop
 

.manage_kaleidoscope
 ld hl, FULLSCREEN_KALEIDOSCOPE_EXO
 ld bc, FULLSCREEN_KALEIDOSCOPE_EXO_end - FULLSCREEN_KALEIDOSCOPE_EXO
 assert (FULLSCREEN_KALEIDOSCOPE_EXO_end - FULLSCREEN_KALEIDOSCOPE_EXO) < 0x3fff
 call FRAMEWORK_LAUNCH_EFFECT

 ld a, 0xc7
 ld hl, MESSAGE2
 ld bc, MESSAGE2_end - MESSAGE2
 ld de, 1
 call FRAMEWORK_DISPLAY_PROPAGANDA
 endif

 ;;;;;;;;;;;;;;
 ;;; PLASMA ;;;
 ;;;;;;;;;;;;;;
 if ENABLE_PLASMA
  ld hl, FULLSCREEN_PLASMA_EXO
  ld bc, FULLSCREEN_PLASMA_EXO_end - FULLSCREEN_PLASMA_EXO
  assert (FULLSCREEN_PLASMA_EXO_end - FULLSCREEN_PLASMA_EXO) < 0x3fff
  call FRAMEWORK_LAUNCH_EFFECT


  ld a, 0xc6
  ld hl, MESSAGE3
  ld bc, MESSAGE3_end - MESSAGE3
  ld de, 2
  call FRAMEWORK_DISPLAY_PROPAGANDA

  endif

 ;;;;;;;;;;;;;;;;;
 ;;; ROTOZOOM  ;;;
 ;;;;;;;;;;;;;;;;;
 if ENABLE_ROTOZOOM

.rotozoom_all_in_blue
  xor a
  ld bc, 0x7f4b
.rotozoom_all_in_blue_loop
  out (c), a
  out (c), c
  inc a
  cp 17
  jr nz, .rotozoom_all_in_blue_loop

.manage_rotozoom
  ld hl, FULLSCREEN_ROTOZOOM_EXO
  ld bc, FULLSCREEN_ROTOZOOM_EXO_end - FULLSCREEN_ROTOZOOM_EXO
  assert (FULLSCREEN_ROTOZOOM_EXO_end - FULLSCREEN_ROTOZOOM_EXO) < 0x3fff
  call FRAMEWORK_LAUNCH_EFFECT
 endif

 ;;;;;;;;;;;;;;;;;
 ;;; GREETINGS ;;;
 ;;;;;;;;;;;;;;;;;
 call flash
 if ENABLE_GREETINGS
		 ld hl, GREETINGS_EXO
		 ld bc, GREETINGS_EXO_end - GREETINGS_EXO
		 call FRAMEWORK_LAUNCH_EFFECT
 endif

 ;;;;;;;;;;;;;;;;;
 ;;; LAST LOGO ;;;
 ;;;;;;;;;;;;;;;;;
 if ENABLE_LOGO2
.manage_logo2
 ld a, 0xC5: call FRAMEWORK_SELECT_BANK
 ld hl, AFFICHE_LOGO2_EXO
 ld bc, AFFICHE_LOGO2_EXO_end - AFFICHE_LOGO2_EXO
 ld de, 0xc000
 ldir
 ld a, 0xC0: call FRAMEWORK_SELECT_BANK

 ld hl, 0xc000
 ld de, 0x1000
 call FRAMEWORK_EXOMIZER

 call 0x1000
 call FRAMEWORK_INSTALL_INTERRUPTED_MUSIC
 ld bc, 0xbc01 : out (c),c : inc b : dec c : out (c), c
 endif

    ld bc, 16*50
.tempo_wait2
    push bc
    call FRAMEWORK_WAIT_VBL
    halt: halt
    pop bc
    dec bc
    ld a, b
    or c
    jr nz, .tempo_wait2

  ;;;;;;;;;;;;;;;;;;
 ;; RESET PLAYER ;;
 ;;;;;;;;;;;;;;;;;;
 ld a, 0xC0 : call FRAMEWORK_SELECT_BANK
 call flash
.reset_player
 call FRAMEWORK_WAIT_VBL
 ld bc, 0x7f5c
 ld a, 17
.loop
  dec a
  out (c), a
  out (c), c
  or a
  jr nz, .loop

 halt : halt
 ld a, 0xC4 : call FRAMEWORK_SELECT_BANK
 ld hl, 0x4000+PLAYER+1
 ld a, 1
 ld (hl), a

 ld a, 0xC6
 ld (FRAMEWORK_LAUNCH_EFFECT.bank+1), a

 ld bc, 0xbc00 + 1 : out (c), c
 dec c : inc b : out (c), c
 jp demo_loop

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
 halt : halt
 edup
 ret

/**
 * Launch the effect
 */
FRAMEWORK_LAUNCH_EFFECT
 ; Bank selection
.bank
 ld a, 0xC6
 push bc : call FRAMEWORK_SELECT_BANK : pop bc
 ld a, 0xc5
 ld (.bank+1), a

 ; Copie of compressed thing in 0xc000
 ld de, 0xC000
 ldir

 ; Selection of main bank
 ld a, 0xc0 : call FRAMEWORK_SELECT_BANK

 ; Decompression of effect
 ld hl, 0xc000
 ld de, 0x1000
 call FRAMEWORK_EXOMIZER
 ld hl, 0xc000 : ld de, 0xc001 : ld bc, 0x3fff : ld (hl), l : ldir
 call 0x1000
 ld bc, 0xbc00 + 1 : out (c), c : ld bc, 0xbd00  : out (c), c

 call FRAMEWORK_INSTALL_INTERRUPTED_MUSIC
 ret

/**
 * Display a propaganda message
 * TODO: crtc trnasitions
 */
FRAMEWORK_DISPLAY_PROPAGANDA
 push de

 ; Select propaganda bank
 push bc
 call FRAMEWORK_SELECT_BANK
 pop bc


 ; Copy of compressed things to 
 ld de, 0xc000
 ldir

 ; Selection of main bank
 ld a, 0xc0 : call FRAMEWORK_SELECT_BANK

 ; Decompression of picture
 ld hl, 0xc000
 ld de, 0x1000
 call FRAMEWORK_EXOMIZER
 

;;; copy picture
 ld hl, 0x1000
 ld de, 0xc000
 ld b, 170-2
.loopy
 push bc
 push de
 ld bc, 96
 ldir
 pop de
 ex de, hl
 call bc26_96
 ex de, hl
 pop bc
 djnz .loopy



;;; choose screen
 ld bc, 0xbc00 + 12 : out (c), c : ld bc, 0xbd00 + 0x30 : out (c),c 
 ld bc, 0xbc00 + 13 : out (c), c : ld bc, 0xbd00 + 0 : out (c),c 
 ld bc, 0x7f8e : out (c), c





 ld a, 0xc5 : call FRAMEWORK_SELECT_BANK
 ld hl, MESSAGE_DISPLAY
 ld de, 0x1000
 call FRAMEWORK_EXOMIZER
 ld a, 0xc0 : call FRAMEWORK_SELECT_BANK
 pop de
 call 0x1000

 ret

bc26_96
        ld a,8
        add h
        ld h,a
        and 64
        ret nz
        ld bc,0x3fa0
        sbc hl,bc
        ret  
/**
 * All the code after this line may be lost without any problem
 */
LOOSABLE_CODE
 assert $< 0x1000

/**
 * Bootstrap of playing music. (this is the same for the bank loading code)
 * Needs to by copied in 0x0000 and called with RST0
 */
music_bootstrap
  DISP 0x0000
  ld bc, 0x7fc2     ; 3
  out (c),c     ; 2
INTERRUPT_go
  defs 5+2      ; wait
INTERRUPT_return 
  ret
  ENT
music_bootstrap_end


  assert $ < 0x4000


 assert $ <0x8000

PLAYER: equ 0x0000000C
FULLSCREEN_ROTOZOOM_EXO: equ 0x00004FAA
FULLSCREEN_ROTOZOOM_EXO_end: equ 0x0000603E
FULLSCREEN_PLASMA_EXO: equ 0x00004A97
FULLSCREEN_KALEIDOSCOPE_EXO: equ 0x00004000
MESSAGE1: equ 0x00005E99


MESSAGE1_end: equ 0x00007E1C


FULLSCREEN_PLASMA_EXO_end: equ 0x00004FAA
FULLSCREEN_KALEIDOSCOPE_EXO_end: equ 0x00004A97


AFFICHE_LOGO_EXO: equ 0x00004000
AFFICHE_LOGO_EXO_end: equ 0x00005B93
AFFICHE_LOGO2_EXO: equ 0x0000699F
AFFICHE_LOGO2_EXO_end: equ 0x00007B86
MESSAGE_DISPLAY: equ 0x00007B86
MESSAGE_DISPLAY_end: equ 0x00007F39
GREETINGS_EXO: equ 0x0000603E
GREETINGS_EXO_end: equ 0x0000699F
MESSAGE2: equ 0x00004000

MESSAGE2_end: equ 0x00005E99

MESSAGE3: equ 0x00005B93
MESSAGE3_end: equ 0x00007EFB
