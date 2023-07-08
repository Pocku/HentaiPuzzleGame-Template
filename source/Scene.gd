extends Node2D

onready var winBG = $WinScreen/BG
onready var winSfx = $WinSfx
onready var timeLabel = $WinScreen/BG/TimeLabel
onready var youWinLabel = $WinScreen/BG/YouWinLabel
onready var blocks = $Blocks
onready var cam = $Cam
onready var tw = $Tween

var blockSize=Vector2();
var mouseGrid=Vector2();
var mouseGridCopy=Vector2();

var curBlock=null;
var nextBlock=null;
var completed=false;
var confirmed=false;

var time=0.0;
var timeCopy=0.0;
var sliceCount=4;

var mouseRight=false;

func _ready():
	var img=load("res://assets/images/%s"%Game.images[0]);
	
	winBG.modulate.a=0.0;
	sliceCount=int(4+(max(floor(Game.winCount/15),0)*2));

	blockSize.x=img.get_width()/sliceCount;
	blockSize.y=img.get_height()/sliceCount;
	blocks.show_behind_parent=true;

	cam.position=Vector2(img.get_width()/2.0,img.get_height()/2.0);
	
	var axis=[];
	var yaxis=[];
	while len(axis)<sliceCount:
		randomize();
		var targetVal=int(randi()%sliceCount);
		if !targetVal in axis:
			axis.append(targetVal);
	while len(yaxis)<sliceCount:
		randomize();
		var targetVal=int(randi()%sliceCount);
		if !targetVal in yaxis:
			yaxis.append(targetVal);
		
	for x in sliceCount:
		for y in sliceCount:
			var block=preload("res://source/Block.tscn").instance();
			block.texture=img;
			block.centered=false;
			block.region_enabled=true;
			block.region_rect=Rect2(x*blockSize.x,y*blockSize.y,1*blockSize.x,1*blockSize.y);
			block.column=axis[x];
			block.row=axis[y];
			block.baseColumn=x;
			block.baseRow=y;
			blocks.add_child(block);
			tw.interpolate_property(block,"position",Vector2.ZERO,Vector2(axis[x]*blockSize.x,axis[y]*blockSize.y),0.32,Tween.TRANS_CUBIC,Tween.EASE_OUT);
	tw.start();
		
func _input(ev):
	if ev is InputEventKey:
#		if ev.scancode==KEY_R && !ev.echo && ev.pressed && !confirmed:
#			onCompleted();
#
		if ev.scancode==KEY_ENTER && !ev.echo && ev.pressed && !confirmed && completed:
			if len(Game.images)>1:
				get_tree().reload_current_scene();
				confirmed=true;
				Game.images.remove(0);
				Game.winCount+=1;

	if ev is InputEventMouseButton:
		if ev.button_index in [BUTTON_WHEEL_UP,BUTTON_WHEEL_DOWN]:
			var dirY=int(ev.button_index==BUTTON_WHEEL_DOWN)-int(ev.button_index==BUTTON_WHEEL_UP);
			cam.zoom.x=max(cam.zoom.x+(dirY*0.1),0.2);
			cam.zoom.y=max(cam.zoom.y+(dirY*0.1),0.2);
		
		if ev.button_index==BUTTON_RIGHT:
			mouseRight=ev.pressed;
			
		if ev.button_index==BUTTON_LEFT && !ev.is_echo() && ev.pressed:
			for block in get_tree().get_nodes_in_group("block"):
				var isBlockUnderMouse=block.is_pixel_opaque(block.get_local_mouse_position());
				
				if isBlockUnderMouse:
					if curBlock==null:
						curBlock=block;
					elif curBlock!=block:
						nextBlock=block;
						var curBlockGrid=Vector2(curBlock.column,curBlock.row);
						var nextBlockGrid=Vector2(nextBlock.column,nextBlock.row);
						
						curBlock.column=nextBlockGrid.x;
						curBlock.row=nextBlockGrid.y;
						
						nextBlock.column=curBlockGrid.x;
						nextBlock.row=curBlockGrid.y;
						
						tw.interpolate_property(curBlock,"position",curBlock.position,Vector2(curBlock.column*blockSize.x,curBlock.row*blockSize.y),0.32,Tween.TRANS_CUBIC,Tween.EASE_OUT);
						tw.interpolate_property(nextBlock,"position",nextBlock.position,Vector2(nextBlock.column*blockSize.x,nextBlock.row*blockSize.y),0.32,Tween.TRANS_CUBIC,Tween.EASE_OUT);
						tw.start();
						
						curBlock=null;
						nextBlock=null;
					else:
						curBlock=null;
						nextBlock=null;
	if !completed:
		if ev is InputEventMouseMotion && mouseRight:
			cam.position+=-ev.relative*cam.zoom;
		
						
func _physics_process(dt):
	if !completed:
		time+=dt;
	
	mouseGrid=(get_global_mouse_position()-blockSize/2.0).snapped(blockSize);
	mouseGridCopy=lerp(mouseGridCopy,mouseGrid,0.32);
	
	var finished=true;
	for block in get_tree().get_nodes_in_group("block"):
		block.modulate=Color.white;
		if block.row!=block.baseRow || block.column!=block.baseColumn:
			finished=false;
			break;
	
	if finished && !completed:
		onCompleted();
		completed=true;
		
	if curBlock!=null: curBlock.modulate=Color.gray
	if nextBlock!=null: nextBlock.modulate=Color.gray
	
	var seconds = int(timeCopy)%60;
	var minutes = (int(timeCopy)/60)%60;
	var hours = (int(timeCopy)/60)/60;
	timeLabel.text="%s:%s:%s"%[str(hours).pad_zeros(2),str(minutes).pad_zeros(2),str(seconds).pad_zeros(2)];
	update();

func _draw():
	draw_rect(Rect2(mouseGridCopy,blockSize),Color.red,false,1.0);

func onCompleted():
	if len(Game.images)==1:
		youWinLabel.text="YOU COMPLETED 'EM ALL!"
	else:
		youWinLabel.text="YOU WON!"
	
	tw.interpolate_property(winBG,"modulate:a",0.0,1.0,0.3,Tween.TRANS_CUBIC,Tween.EASE_OUT);
	tw.interpolate_property(self,"timeCopy",0.0,time,0.3,Tween.TRANS_CUBIC,Tween.EASE_OUT);
	tw.start();
	winSfx.play();
