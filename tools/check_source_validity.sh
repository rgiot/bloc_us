# check if symbols in list are identic in both files
# if it is not the case, we need to copy paste from source to destination


function check {


if ! test -e $SOURCE ;
then
	echo "$SOURCE does not exist !"
	exit -1
fi

#echo $LIST
#echo $SOURCE
#echo $DESTINATION

for symbol in $LIST; do



    source_line=$(grep "^$symbol:" $SOURCE)
    destination_line=$(grep "^$symbol:" $DESTINATION)
    source_value=$(echo $source_line | sed -e 's/.*: equ //')
    destination_value=$(echo $destination_line| sed -e 's/.*: equ //')

    if test -z $destination_value ;
    then
	    echo "ERROR - You did not add the line !! $source_line"
            echo 'TRY an automatic repair => you need to build again' ;
	    echo $source_line >> $DESTINATION;
	    exit 1
    fi

 #   echo "$SOURCE => $DESTINATION [$symbol] ($source_value, $destination_value)"
    test $source_value = $destination_value || (\
        echo 'ERROR - Different values for symbol' $symbol; 
        echo 'TRY an automatic repair => you need tobuild again' ;
        sed -i $DESTINATION -e "s/^$destination_line.*/$source_line/"
        exit 1)
done
}


# Music splitted in two banks
LIST='ADRZIKEND ADRZIK FREESPACE_FOR_MUSIC ZIKNB '
SOURCE='C4.sym'
DESTINATION='src/framework/C5.asm'
check

LIST='PLAYER'
SOURCE='C4.sym'
DESTINATION='src/framework/framework.asm'
check


#DATA in C5
LIST='FULLSCREEN_ROTOZOOM_EXO FULLSCREEN_ROTOZOOM_EXO_end'
LIST="$LIST FULLSCREEN_PLASMA_EXO FULLSCREEN_PLASMA_EXO_end"
LIST="$LIST FULLSCREEN_KALEIDOSCOPE_EXO FULLSCREEN_KALEIDOSCOPE_EXO_end"
LIST="$LIST GREETINGS_EXO GREETINGS_EXO_end"
LIST="$LIST AFFICHE_LOGO2_EXO AFFICHE_LOGO2_EXO_end"
LIST="$LIST MESSAGE_DISPLAY MESSAGE_DISPLAY_end"
SOURCE='C5.sym'
DESTINATION='src/framework/framework.asm'
check


#DATA in C6
LIST="MESSAGE3  MESSAGE3_end "
LIST="$LIST AFFICHE_LOGO_EXO AFFICHE_LOGO_EXO_end"
SOURCE='C6.sym'
DESTINATION='src/framework/framework.asm'
check

#DATA in C7
LIST="MESSAGE2 MESSAGE2_end "
LIST="$LIST MESSAGE1  MESSAGE1_end "
SOURCE='C7.sym'
DESTINATION='src/framework/framework.asm'
check


LIST='FRAMEWORK_WAIT_VBL FRAMEWORK_INSTALL_INTERRUPTED_MUSIC FRAMEWORK_PLAY_MUSIC'
SOURCE='framework.sym'
DESTINATION='src/logo/affiche_logo.asm'
check

LIST='FRAMEWORK_WAIT_VBL'
SOURCE='framework.sym'
DESTINATION='src/logo2/affiche_logo2.asm'
check


LIST='FRAMEWORK_WAIT_VBL FRAMEWORK_PLAY_MUSIC FRAMEWORK_INSTALL_INTERRUPTED_MUSIC'
SOURCE='framework.sym'
DESTINATION='src/message/message_display.asm'
check


LIST='FRAMEWORK_WAIT_VBL'
SOURCE='framework.sym'
DESTINATION='src/greetings/greetings.asm'
check
