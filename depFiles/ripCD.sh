#!/bin/sh
if [ $# -lt 1 ]
then
    echo "Usage: sh $0 <action> <codec>"
    exit 1
else
    VOLUME=/tmp
    RIP_DIR=RIP
    ALAC_DIR=ALAC_RIP
    FLAC_DIR=FLAC_DIR
    DEV=/dev/cdrom
    ACTION=$1
    if [ $ACTION = 'r' ] || [ $ACTION = 'e' ] || [ $ACTION = 'b' ] || [ $ACTION = 'toc' ]; then
        if [ $ACTION = "e" ] || [ $ACTION = 'b' ]; then
            if [  $# -lt 2 ]; then
                echo "If action is 'e' you must to specify a codec. Valid values: flac, alac"
                exit 1
            else
                CODEC=$2
                if ( [ $CODEC = 'flac' ] || [ $CODEC = 'alac' ] ); then
                    ENCODE='s'
                else
                    echo "action Valid values: flac, alac"
                    exit 1
                fi
            fi
        else
            ENCODE='n'
        fi
    else
            echo "Valid <action> values are 'r' for rip, 'e' for encode"
            exit 1
    fi

    if [ $ACTION = 'r' ] ||  [ $ACTION = 'b' ] ; then
        CDDA=$(cdparanoia -Q 2>&1 | grep -c 'audio only')
        CSVFILE=$VOLUME/$RIP_DIR/albums.csv
        if [ "$CDDA" -eq 1 ]; then
            DISCID=$(cd-discid $DEV| awk '{print $1}')
            ALBUMNAME=$(curl -s "http://freedb.freac.org/~cddb/cddb.cgi?cmd=cddb+query+$(cd-discid "$DEV" | sed 's/ /+/g')&hello=user+hostname+cdparanoia+3&proto=3" | sed -e 's/AC\/DC/\ACDC/g' | sed 's/\// - /g'|awk '{$1=""; $2=""; $3=""; sub("  ", " "); print}'| sed s'/.$//' | awk '{gsub(/^[ \t]+|[ \t]+$/,"")};1' | iconv -f=ISO-8859-1 -t=UTF-8)
            PERFORMER=$(echo $ALBUMNAME |  awk -F' -' '{print $1}')
            ALBUM_TITLE=$(echo $ALBUMNAME |  awk -F'- ' '{print $2}')
            #SPEED=$(more /proc/sys/dev/cdrom/info | egrep -i --color 'drive speed:' | awk '{print $3}')
            # Check autodetected info and download art
            read -r -p "Is a compilation?: " COMPILATION
            case $COMPILATION in
                [yY][eE][sS]|[yY])
                read -r -p "Disc number?: " DISCNUMBER
                if [[ -z "$DISCNUMBER"  ]]; then
                    DISCNUMBER='1'
                fi
            ;;
                [nN][oO]|[nN])
                echo -e "No"
                DISCNUMBER='1'
            ;;
                *)
                echo "Invalid input..."
                echo "Quit"
                exit 1
            ;;
            esac
            echo "Artist detected as: "$PERFORMER""
            read -r -p "Is correct: ? [Y/n] " input
            case $input in
                [yY][eE][sS]|[yY])
                echo "Yes"  
            ;;
                [nN][oO]|[nN])
                echo -e "No"
                read -r -p "Enter a new name: " PERFORMER
                    if [[ -z "$PERFORMER" ]]; then
                        echo "Invalid input..."
                        echo "Quit"
                        exit 1
                    fi
            ;;
                *)
                echo "Invalid input..."
                echo "Quit"
                exit 1
            ;;
            esac
            echo "Album detected as: "$ALBUM_TITLE""
            read -r -p "Is correct: ? [Y/n] " input
            case $input in
                [yY][eE][sS]|[yY])
                echo "Yes"  
            ;;
                [nN][oO]|[nN])
                echo -e "No"
                read -r -p "Enter a new name: " ALBUM_TITLE
                    if [[ -z "$ALBUM_TITLE" ]]; then
                        echo "Invalid input..."
                        echo "Quit"
                        exit 1
                    fi
            ;;
                *)
                echo "Invalid input..."
                echo "Quit"
                exit 1
            ;;
            esac

            #  [ Save album info on albums.csv
            if [ ! -e ${CSVFILE} ]; then
                touch ${CSVFILE}
            fi
            grep -qF -- $DISCID ${CSVFILE} || echo ""$DISCID","$PERFORMER","$ALBUM_TITLE","$YEAR","$DISCNUMBER"" >> ${CSVFILE}
            RIP='s'
            if [ $DISCNUMBER -gt 1 ]; then
                    ALBUM_TITLE="$ALBUM_TITLE (CD $DISCNUMBER)"
                fi
            if [ -d "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE" ]; then
                read -r -p "Directory already exists, do you want to rip audio cd?:  [Y/n] " RIP
                    case $RIP in
                        [yY][eE][sS]|[yY])
                        RIP='s'  
                    ;;
                        [nN][oO]|[nN])
                        RIP='n'
                    ;;
                        *)
                        echo "Invalid input..."
                        echo "Quit"
                        exit 1
                    ;;
                    esac
            fi
            if [ $RIP = 's' ];then
                SACAD_PERFORMER=\"${PERFORMER}\"
                SACAD_ALBUM_TITLE=\"${ALBUM_TITLE}\"
                if [ ! -d "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE" ] && [ $RIP = 's' ]; then
                mkdir -p "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE"
                fi
                sacad "$SACAD_PERFORMER" "$SACAD_ALBUM_TITLE"  500 "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE/AlbumArt.jpg"
                cd "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE"
                #cdda2wav -vall cddb=0 -cddbp-server=gnudb.gnudb.org speed="$SPEED" -paranoia -B -D $DEV
                cdda2wav -vall cddb=0 -cddbp-server=gnudb.gnudb.org -paranoia -B -D $DEV
                TOTALTRACKS=$(grep TTITLE audio.cddb |wc -l)
                GENRE=$(grep DGENRE audio.cddb | awk -F '=' '{print $2}')
                YEAR=$(grep DYEAR audio.cddb | awk -F '=' '{print $2}')
                for file in ./*.wav
                    do
                    CFILE=$(echo $file | cut -c 3-)
                    TRACKTITLE=$(grep Tracktitle "${CFILE%wav}inf" |tr -d './' | awk -F= '{print $2}' | sed -e 's/^[[:space:]]*//' | tr -d \')
                    TRACKNUMBER=$(grep Tracknumber "${CFILE%wav}inf" | tr -d './' | awk -F= '{print $2}' | sed -e 's/^[[:space:]]*//')
                    echo "File: $file"
                    ffmpeg -y -i "$file" -metadata album_artist="${PERFORMER}" -metadata artist="${PERFORMER}" -metadata genre="${GENRE}" \
                                    -metadata TRACKTOTAL="$TOTALTRACKS" -metadata date="$YEAR" -metadata album="${ALBUM_TITLE}" \
                                    -metadata disc="${DISCNUMBER}" -metadata track="$TRACKNUMBER" -metadata title="$TRACKTITLE" -c copy "tmp.wav"; 
                    mv "tmp.wav" $file
                    done
            fi
        fi
    fi
    if [ $RIP = 's' ] || [ ACTION = 'toc' ];then
        cdrdao read-toc --fast-toc --device "$DEV" --driver generic-mmc:0x20000 --paranoia-mode 0 --with-cddb --cddb-servers freedb.freac.org:/~cddb/cddb.cgi "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE/$ALBUM_TITLE.toc"
        sed -i -e 's/\\240/ /g' -e 's/\\300/À/g' -e 's/\\340/à/g' \
                -e 's/\\241/¡/g' -e 's/\\301/Á/g' -e 's/\\341/á/g' \
                -e 's/\\242/¢/g' -e 's/\\302/Â/g' -e 's/\\342/â/g' \
                -e 's/\\243/£/g' -e 's/\\303/Ã/g' -e 's/\\343/ã/g' \
                -e 's/\\244/¤/g' -e 's/\\304/Ä/g' -e 's/\\344/ä/g' \
                -e 's/\\245/¥/g' -e 's/\\305/Å/g' -e 's/\\345/å/g' \
                -e 's/\\246/¦/g' -e 's/\\306/Æ/g' -e 's/\\346/æ/g' \
                -e 's/\\247/§/g' -e 's/\\307/Ç/g' -e 's/\\347/ç/g' \
                -e 's/\\250/¨/g' -e 's/\\310/È/g' -e 's/\\350/è/g' \
                -e 's/\\251/©/g' -e 's/\\311/É/g' -e 's/\\351/é/g' \
                -e 's/\\252/ª/g' -e 's/\\312/Ê/g' -e 's/\\352/ê/g' \
                -e 's/\\253/«/g' -e 's/\\313/Ë/g' -e 's/\\353/ë/g' \
                -e 's/\\254/¬/g' -e 's/\\314/Ì/g' -e 's/\\354/ì/g' \
                -e 's/\\255/ /g' -e 's/\\315/Í/g' -e 's/\\355/í/g' \
                -e 's/\\256/®/g' -e 's/\\316/Î/g' -e 's/\\356/î/g' \
                -e 's/\\257/¯/g' -e 's/\\317/Ï/g' -e 's/\\357/ï/g' \
                -e 's/\\260/°/g' -e 's/\\320/Ð/g' -e 's/\\360/ð/g' \
                -e 's/\\261/±/g' -e 's/\\321/Ñ/g' -e 's/\\361/ñ/g' \
                -e 's/\\262/²/g' -e 's/\\322/Ò/g' -e 's/\\362/ò/g' \
                -e 's/\\263/³/g' -e 's/\\323/Ó/g' -e 's/\\363/ó/g' \
                -e 's/\\264/´/g' -e 's/\\324/Ô/g' -e 's/\\364/ô/g' \
                -e 's/\\265/µ/g' -e 's/\\325/Õ/g' -e 's/\\365/õ/g' \
                -e 's/\\266/¶/g' -e 's/\\326/Ö/g' -e 's/\\366/ö/g' \
                -e 's/\\267/·/g' -e 's/\\327/×/g' -e 's/\\367/÷/g' \
                -e 's/\\270/¸/g' -e 's/\\330/Ø/g' -e 's/\\370/ø/g' \
                -e 's/\\271/¹/g' -e 's/\\331/Ù/g' -e 's/\\371/ù/g' \
                -e 's/\\272/º/g' -e 's/\\332/Ú/g' -e 's/\\372/ú/g' \
                -e 's/\\273/»/g' -e 's/\\333/Û/g' -e 's/\\373/û/g' \
                -e 's/\\274/¼/g' -e 's/\\334/Ü/g' -e 's/\\374/ü/g' \
                -e 's/\\275/½/g' -e 's/\\335/Ý/g' -e 's/\\375/ý/g' \
                -e 's/\\276/¾/g' -e 's/\\336/Þ/g' -e 's/\\376/þ/g' \
                -e 's/\\277/¿/g' -e 's/\\337/ß/g' -e 's/\\377/ÿ/g' "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE/$ALBUM_TITLE.toc"
        sed -i -e '/TITLE/s/\\"//g' "$VOLUME/$RIP_DIR/$PERFORMER/$ALBUM_TITLE/$ALBUM_TITLE.toc"
    fi
    if [ $ENCODE = 's' ];then
        # cd $VOLUME/$RIP_DIR
        # find . -name '*.wav' | while read line; do
        #     artistCmd=$(ffmpeg -i "${line}" 2>&1 | grep artist | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')
        #     trackCmd=$(ffmpeg -i "${line}" 2>&1 | grep track | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')
        #     titleCmd=$(ffmpeg -i "${line}" 2>&1 | grep title | awk -F: '{print $2}' | sed -e 's/^[[:space:]]*//')
        #     if [ $CODEC = 'flac' ]; then
        #         OUTDIR="$VOLUME/FLAC_RIP"
        #         EXT="flac"
        #     fi
        #      if [ $CODEC = 'alac' ]; then
        #         OUTDIR="$VOLUME/ALAC_RIP"
        #         EXT="m4a"
        #     fi
        #     OUTSUBDIR=$(echo $line | sed 's/^..//' | awk -F/ '{print $1 "/" $2}')
        #     OUTFILE=$(echo $line | sed 's/^..//')
        #     if [ ! -d "$OUTDIR/$OUTSUBDIR" ]; then
        #         echo "se crea $OUTDIR/$OUTSUBDIR"
        #         mkdir -p "$OUTDIR/$OUTSUBDIR"
        #     fi
        #     ffmpeg -i "${line}" -loglevel verbose -map_metadata 0 -c $CODEC -movflags use_metadata_tags -metadata album_artist="${artistCmd}" "$OUTDIR/${OUTFILE%wav}$EXT"
        #     #echo "ffmpeg -i \"${line}\" -map_metadata 0 -c $CODEC -movflags use_metadata_tags \"$OUTDIR/${OUTFILE%wav}$EXT\""
        # done
        python3 /usr/local/bin/convert_audio.py $VOLUME/$RIP_DIR/ $CODEC
        #DISCID=$(cd-discid $DEV| awk '{print $1}')
        #cddb_query -s gnudb.gnudb.org -P http read misc 0x$DISCID
    fi
fi
