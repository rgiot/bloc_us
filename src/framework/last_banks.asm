/**
 * 2 may 2011
 * Contains the last three banks in order to load them together
 */

 output last_banks.o

 org 0x4000

BANK_C5
	incbin C5.o
/*
 defs 0x8000 - $ 
BANK_C6
	incbin C6.o

 defs 0xc000 - $ 
BANK_C7
	incbin C7.o

*/

	assert BANK_C5 == 0x4000
/*
	assert BANK_C6 == 0x8000
	assert BANK_C7 == 0xc000
*/
