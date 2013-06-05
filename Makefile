# Automatic building of the demo
# Krusty/Benediction 2011

include CPC.mk
PNG2MODE0=./tools/fontcatcher
.SILENT:

#############
# Constants #
#############
# DSK
DSK = blockus.dsk
HFE = blockus_dsk.hfe
EXEC = BLOCUS.BND

BOOTSTRAP_LOAD=x4000
BOOTSTRAP_EXEC=x4000

vpath %.asm 	src/ \
		src/framework/ \
		src/plasma/ \
		src/rotozoom/ \
		src/bump/ \
		src/kaleidoscope \
		src/logo src/logo2\
		src/message \
		src/planedeformation \
		src/greetings

.SUFFIXES: .asm, .o, .exo, .cre

vpath %.o .
vpath %.exo .
vpath %.cre .

.PHONY: all
ALL: 
	$(MAKE) $(DSK) 

############################
# Extract data if required #
############################

################################
# Dependicies for source files #
################################
# TODO Automatically compute them

framework.o: src/framework/framework.asm \
	     src/framework/CRTC_detection.asm  \
	     src/framework/deexo.asm  \
	     C4.exo C5.exo C6.exo C7.exo
bootstrap.o: framework.o 
last_banks.o: C5.o C6.o
C5.o: fullscreenrotozoom.exo fullscreenplasma.exo fullscreenkaleidoscope.exo  greetings.exo affiche_logo2.exo message_display.exo 
C6.o:    affiche_logo.exo message_3.exo 
C7.o:  message_2.exo message_1.exo 

fullscreenrotozoom.o: fullscreen_rotozoom_picture.o data/rotozoom/full2.txt
fullscreenplasma.o: src/plasma/plasma_curve1.asm
fullscreenkaleidoscope.o: fullscreen_kaleidoscope_picture.o
fullscreenplanedeformation.o: src/planedeformation/generated_pd.asm
affiche_logo.o: src/logo/macro_bloc.asm src/framework/logo_message_vars.asm data/logo/credits.scr src/logo/clear_logo.asm
message_display.asm:src/framework/logo_message_vars.asm
greetings.o: data/greetings/horizontal_curve.asm src/greetings/image.asm data/greetings/greetings_image.asm
load_blocus.o: bootstrap.o
affiche_logo2.o: data/logo2/blockus_logo.pat

##############
# Build data #
##############
src/planedeformation/generated_pd.asm: tools/planedeformation/planedeformation.py
	python tools/planedeformation/planedeformation.py > src/planedeformation/generated_pd.asm

fullscreen_rotozoom_picture.o: data/rotozoom/fullscreen_image.png
	python tools/png2cpc.py data/rotozoom/fullscreen_image.png -r 0
	python tools/png2cpc.py data/rotozoom/fullscreen_image.png -p
	mv data/rotozoom/fullscreen_image.scr fullscreen_rotozoom_picture.o

fullscreen_kaleidoscope_picture.o: data/kaleidoscope/fullscreen_image.png
	python tools/png2cpc.py data/kaleidoscope/fullscreen_image.png -r 0
	python tools/png2cpc.py data/kaleidoscope/fullscreen_image.png -p
	mv data/kaleidoscope/fullscreen_image.scr fullscreen_kaleidoscope_picture.o




message_because.o: data/messages/because.png
	$(PNG2MODE0) $< $@ 80 0

message_why.o: data/messages/why.png
	$(PNG2MODE0) $< $@ 80 0

message_easy_demos.o: data/messages/easy_demos.png
	$(PNG2MODE0) $< $@ 80 0

data/logo2/blockus_logo.pat: data/logo2/blockus_logo.png
	python tools/png2cpc.py data/logo2/blockus_logo.png -t -x 2 -y 72 -m -p

#data/logo/credits.scr:data/logo/credits.png
#	python tools/png2cpc.py data/logo/credits.png -r 1 

data/greetings/horizontal_curve.asm:tools/greetings/horizontal_curve.py
	python tools/greetings/horizontal_curve.py > data/greetings/horizontal_curve.asm

data/greetings/greetings_image.asm: data/greetings/greetings_image.png
	echo "Build image"
	python tools/greetings/png2ga.py data/greetings/greetings_image.png > data/greetings/greetings_image.asm

#######
# DSK #
#######
#$(EXEC): bootstrap.o
#	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), $(BOOTSTRAP_LOAD), $(BOOTSTRAP_EXEC))

UGLY.001: last_banks.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

BLOCUS.001: C4.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

BLOCUS.002: C5.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

BLOCUS.003: C6.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

BLOCUS.004: C7.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

-BLOC.US: load_blocus.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x1000, x1000)

FILES_TO_PUT= $(EXEC) BLOCUS.001 BLOCUS.002 BLOCUS.003 BLOCUS.004 -BLOC.US
$(DSK): $(FILES_TO_PUT)
	@$(MAKE) check
	#@test -e $@ || $(call CREATE_DSK, $@)
	cp data/catart/catart_dsk.dsk $@
	cpcfs -b blockus.dsk p  -BLOC.US
	cpcfs -b blockus.dsk p  BLOCUS.001   
	cpcfs -b blockus.dsk p  BLOCUS.002   
	cpcfs -b blockus.dsk p  BLOCUS.003   
	cpcfs -b blockus.dsk p  BLOCUS.004
	#@$(foreach file, $(FILES_TO_PUT), \
		$(call PUT_FILE_INTO_DSK2, $@, $(file)) )

#############
# Utilities #
# ###########
.PHONY: clean distclean check
check:
	bash ./tools/check_source_validity.sh || ($(MAKE) clean ; exit 1)
clean:
	-rm $(DATA_SONG_FILE)
	-rm $(DATA_PLAYER_FILE)
	-rm *.o 
	-rm *.bin
	-rm *.exo
	-rm *.lst
	-find . -name "*.sym" -delete

distclean: clean
	-rm $(DSK)
	-rm $(HFE)

$(HFE): $(DSK)
	hxcfloppyemulator_convert  $(DSK) -HFE
