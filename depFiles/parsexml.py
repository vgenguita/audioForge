from xml.dom import minidom
import xml.etree.ElementTree as ET
# parse an xml file by name
# mydoc = minidom.parse('/home/victor/nfs/media/audio/RIP/Albert King/Stax Profiles/audio.cdindex')
# items = mydoc.getElementsByTagName('Track')

# # one specific item attribute
# print('Item #2 attribute:')
# print(items[1].attributes['Num'].value)

# all item attributes
# print('nAll attributes:')
# for elem in items:
#     print(elem.attributes['Num'].value)

tree = ET.parse('/home/victor/nfs/media/audio/RIP/Barón Rojo/20+//audio.cdindex')
root = tree.getroot()

print("Root tag: "+root.tag)
print("Items: ")
for child in root:
    print(child.tag, child.attrib)

for track in root.findall("./SingleArtistCD/Track"):
    trackName=track.find('Name').text.encode('utf8')
    print("Track Number: "+track.attrib['Num'])
    print("Track name: "+str(trackName))
