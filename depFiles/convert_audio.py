import os
import sys
import subprocess
from pydub import AudioSegment
from pydub.utils import mediainfo
from pathlib import Path


def convert_to_flac(sourcepath, file):
    fileName = os.path.splitext(file)[0]
    extension = ext
    relpath = sourcepath[len(initPath):len(sourcepath)]
    destinationDir = destinationBaseDir + relpath + "/"
    destinationFile = destinationDir+fileName+extension
    if os.path.exists(destinationFile):
        print(f"File {destinationFile} already exists")
    else:
        source_file = sourcepath+file
        source_audio = AudioSegment.from_file(sourcepath+"/"+file, format="wav")
        Path(destinationDir).mkdir(parents=True, exist_ok=True, mode=0o755)
        # source_audio.export(destinationFile, codec=codec, format=newFormat,
        #                     tags=mediainfo(sourcepath+"/"+file).get('TAG', {}))
        artistCmd = 'ffmpeg -i "'+source_file+'" 2>&1 | grep artist | awk -F: \'{print $2}\' | sed -e \'s/^[[:space:]]*//\''
        artist = out(str(artistCmd))
        trackCmd = 'ffmpeg -i "'+source_file+'" 2>&1 | grep track | awk -F: \'{print $2}\' | sed -e \'s/^[[:space:]]*//\''
        track = out(str(trackCmd))
        titleCmd = 'ffmpeg -i \"'+source_file+'" 2>&1 | grep title | awk -F: \'{print $2}\' | sed -e \'s/^[[:space:]]*//\''
        title = out(str(titleCmd))
        # addAlbumARtist = 'ffmpeg -i "' + source_file + '" -map_metadata 0 -c '+codec+' -movflags use_metadata_tags -metadata album_artist="'+artist.decode("utf-8")+'"'+ destinationDir+trackCmd.decode("utf-8")+"-"+titleCmd.decode("utf-8")+extension + "\""
        print(addAlbumARtist)
        # os.system(addAlbumARtist)
        print(f"Created {destinationFile}")


def list_directory(path):
    with os.scandir(path) as archives:
        extension = '.wav'
        for archive in archives:
            if archive.is_file() and archive.name.endswith(extension):
                convert_to_flac(path, archive.name)
            elif archive.is_dir():
                global relpath
                newPath = path+"/"+archive.name
                list_directory(newPath)


def out(command):
    subprocess.check_output(command)


if len(sys.argv) < 3:
    print(f"Use script: {sys.argv[0]} directory codec")
    exit()
else:
    initPath = sys.argv[1]
    codec = sys.argv[2]
    if codec == "flac":
        destinationBaseDir = "/tmp/FLAC_RIP"
        ext = ".flac"
        newFormat = 'flac'
    elif codec == "alac":
        destinationBaseDir = "/tmp/ALAC_DIR"
        ext = ".m4a"
        newFormat = 'ipod'
    else:
        print('codec not valid')
        exit()
    list_directory(initPath)
