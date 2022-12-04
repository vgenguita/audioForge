import os
import sys
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
        source_audio = AudioSegment.from_file(sourcepath+"/"+file, format="wav")
        Path(destinationDir).mkdir(parents=True, exist_ok=True, mode=0o755)
        source_audio.export(destinationFile, codec=codec, format=newFormat,
                            tags=mediainfo(sourcepath+"/"+file).get('TAG', {}))
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


if len(sys.argv) < 3:
    print(f"Use script: {sys.argv[0]} directory codec")
    exit()
else:
    initPath = sys.argv[1]
    codec = sys.argv[2]
    if codec == "flac":
        destinationBaseDir = "/media/flac/"
        ext = ".flac"
        newFormat = 'flac'
    elif codec == "alac":
        destinationBaseDir = "/media/alac/"
        ext = ".m4a"
        newFormat = 'ipod'
    else:
        print('codec not valid')
        exit()
    list_directory(initPath)
