
 output C6.o

 org 0x4000


AFFICHE_LOGO_EXO
 incbin affiche_logo.exo
AFFICHE_LOGO_EXO_end



MESSAGE3
  incbin message_3.exo
MESSAGE3_end




 assert $<0x8000
