extends Node

var images=[]
var winCount=0;

func _ready():
	images=['abacat.jpg', 'banana.jpg', 'bitches.jpg', 'bomba.jpg', 'boob.jpg', 'bunda.jpg', 'cearenese.jpg', 'core.png', 'elgato.jpg', 'elo.jpg', 'family.jpg', 'flamengo.png', 'fofonCard.jpg', 'fonfon.jpg', 'fonfon2.jpg', 'fonfon3.jpg', 'friend.jpg', 'glam.jpg', 'glamFuck.jpg', 'happybday.jpg', 'horny.jpg', 'lesb.jpg', 'michael.jpg', 'pachora.jpg', 'pig.jpg', 'pink.jpg', 'qpora.jpg', 'racismo.jpg', 'simp.jpg', 'sonico.jpg', 'ticktock.jpg', 'ticktok2.jpg', 'wantsome.jpg', 'xd.jpg']

#	var raw=getFilesInFolder("assets/images/")
#	for i in raw:
#		if str(i).ends_with(".png") || str(i).ends_with(".jpg"):
#			images.append(str("'",i,"'"))
#	print(images)
	
func getFilesInFolder(p):
	var files=[];
	var dir=Directory.new();
	dir.open("res://"+p);
	dir.list_dir_begin(true);
	var f=dir.get_next();
	while f!="":
		files+=[f]
		f=dir.get_next();
	return files;
