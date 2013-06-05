;;;
;;; Differents masques utiles a la gestion des bitplans
;;; 


	
;;; Gestion de l'encre 1
PIXEL_ENCRE1_G						EQU	%10000000
PIXEL_ENCRE1_D						EQU	%01000000

PIXEL_ENCRE1_G_EFF					EQU	%01111111 ;(~PIXEL_ENCRE1_G) & %11111111
PIXEL_ENCRE1_D_EFF					EQU	%10111111 ;(~PIXEL_ENCRE1_D) & %11111111

PIXEL_ENCRE1_EFF					EQU	PIXEL_ENCRE1_G_EFF & PIXEL_ENCRE1_D_EFF
	

;;; Gestion de l'encre 2
PIXEL_ENCRE2_G						EQU	%00001000
PIXEL_ENCRE2_D						EQU	%00000100

PIXEL_ENCRE2_G_EFF					EQU	%11110111 ;(~PIXEL_ENCRE2_G) & %11111111
PIXEL_ENCRE2_D_EFF					EQU	%11111011 ;(~PIXEL_ENCRE2_D) & %11111111

PIXEL_ENCRE2_EFF					EQU	PIXEL_ENCRE2_G_EFF & PIXEL_ENCRE2_D_EFF	
	
;;; Gestion de l'encre 4
PIXEL_ENCRE4_G						EQU	%00100000
PIXEL_ENCRE4_D						EQU	%00010000
PIXEL_ENCRE4_G_EFF					EQU	%11011111 ;(~PIXEL_ENCRE4_G) & %11111111
PIXEL_ENCRE4_D_EFF					EQU	%11101111 ;(~PIXEL_ENCRE4_D) & %11111111

PIXEL_ENCRE4_EFF					EQU	PIXEL_ENCRE4_G_EFF & PIXEL_ENCRE4_D_EFF

;;; Gestion de l'encre 8
PIXEL_ENCRE8_G						EQU	%00000010
PIXEL_ENCRE8_D						EQU	%00000001
PIXEL_ENCRE8_G_EFF					EQU	%11111101 ;(~PIXEL_ENCRE8_G) & %11111111
PIXEL_ENCRE8_D_EFF					EQU	%11111110 ;(~PIXEL_ENCRE8_D) & %11111111

PIXEL_ENCRE8_EFF					EQU	PIXEL_ENCRE8_G_EFF & PIXEL_ENCRE8_D_EFF

OCTET_ENCRE1						EQU	PIXEL_ENCRE1_G | PIXEL_ENCRE1_D
OCTET_ENCRE2						EQU	PIXEL_ENCRE2_G | PIXEL_ENCRE2_D
OCTET_ENCRE4						EQU	PIXEL_ENCRE4_G | PIXEL_ENCRE4_D
OCTET_ENCRE8						EQU	PIXEL_ENCRE8_G | PIXEL_ENCRE8_D
	

PIXEL_ENCRE0_G  equ 0
PIXEL_ENCRE3_G  equ PIXEL_ENCRE1_G + PIXEL_ENCRE2_G
PIXEL_ENCRE5_G  equ PIXEL_ENCRE4_G + PIXEL_ENCRE1_G
PIXEL_ENCRE6_G  equ PIXEL_ENCRE4_G + PIXEL_ENCRE2_G
PIXEL_ENCRE7_G  equ PIXEL_ENCRE6_G + PIXEL_ENCRE1_G
PIXEL_ENCRE9_G  equ PIXEL_ENCRE8_G + PIXEL_ENCRE1_G
PIXEL_ENCRE10_G equ PIXEL_ENCRE8_G + PIXEL_ENCRE2_G
PIXEL_ENCRE11_G equ PIXEL_ENCRE10_G + PIXEL_ENCRE1_G
PIXEL_ENCRE12_G equ PIXEL_ENCRE8_G + PIXEL_ENCRE4_G
PIXEL_ENCRE13_G equ PIXEL_ENCRE12_G + PIXEL_ENCRE1_G
PIXEL_ENCRE14_G equ PIXEL_ENCRE12_G + PIXEL_ENCRE2_G
PIXEL_ENCRE15_G equ PIXEL_ENCRE14_G + PIXEL_ENCRE1_G


PIXEL_ENCRE0_D  equ 0
PIXEL_ENCRE3_D  equ PIXEL_ENCRE1_D + PIXEL_ENCRE2_D
PIXEL_ENCRE5_D  equ PIXEL_ENCRE4_D + PIXEL_ENCRE1_D
PIXEL_ENCRE6_D  equ PIXEL_ENCRE4_D + PIXEL_ENCRE2_D
PIXEL_ENCRE7_D  equ PIXEL_ENCRE6_D + PIXEL_ENCRE1_D
PIXEL_ENCRE9_D  equ PIXEL_ENCRE8_D + PIXEL_ENCRE1_D
PIXEL_ENCRE10_D equ PIXEL_ENCRE8_D + PIXEL_ENCRE2_D
PIXEL_ENCRE11_D equ PIXEL_ENCRE10_D + PIXEL_ENCRE1_D
PIXEL_ENCRE12_D equ PIXEL_ENCRE8_D + PIXEL_ENCRE4_D
PIXEL_ENCRE13_D equ PIXEL_ENCRE12_D + PIXEL_ENCRE1_D
PIXEL_ENCRE14_D equ PIXEL_ENCRE12_D + PIXEL_ENCRE2_D
PIXEL_ENCRE15_D equ PIXEL_ENCRE14_D + PIXEL_ENCRE1_D
