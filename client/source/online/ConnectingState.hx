package online;

import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.FlxSprite;
import haxe.display.Protocol.HaxeNotificationMethod;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextFormat;
import io.colyseus.Client;
import io.colyseus.Room;
import Config.data;
import flixel.FlxG;

using StringTools;
typedef SongData = {
    song:String,
    difficulty:Int,
    week:Int
}
class ConnectingState extends MusicBeatState {
    var loadprog:Alphabet;
    public static var modded:Bool = false;
    public static var songmeta:SongData;
    public static var p1name:String;
    public static var inlobby:Bool = false;
    public static var p2name:String;
    public static var conmode:String;
    public static var rooms:Room<Stuff>;
    public static var coly:Client;
    var nmsongs:Array<String> = [
		'tutorial',
		'test',
		'bopeebo',
		'fresh',
		'dadbattle',
		'spookeez',
		'south',
		'monster',
		'pico',
		'philly',
		'blammed',
		'satin-Panties',
		'high',
		'milf',
		'cocoa',
		'eggnog',
		'winter-Horrorland',
		'senpai',
		'roses',
		'thorns'
	];

    public function new(state:String, type:String, ?code:String){
        super();
        inlobby = false;
        p2name = '';
        FlxG.autoPause = false;
        PlayStateOnline.assing = false;
        coly = new Client('ws://' + data.addr + ':' + data.port);
        Note.single = false;
        switch(state){
            case 'battle':
                if(type == "host")
                {
                    conmode = 'host';
                    if(FlxG.save.data.username != null) p1name = FlxG.save.data.username; 
                    else p1name = "guest" + FlxG.random.int(0, 9999);
                    p2name = "";
                    FlxG.switchState(new ChooseSong());
                    coly.create("battle", [], Stuff, function(err, room) { 
                        if (err != null) {
                            trace("JOIN ERROR: " + err);
                            FlxG.switchState(new FNFNetMenu());
                            return;
                        }
                        PlayStateOnline.rooms = room;
                        ChooseSong.rooms = room;
                        LobbyState.rooms = room;
                        try{
                            room.send('recvprev', {name: p1name});
                            room.onMessage('creatematch', function(message){
                                ChooseSong.celsong = message.song;
                                ChooseSong.bruh = true;
                            });
                            room.onError += function(code, message) {
                                FlxG.switchState(new FNFNetMenu("a strange error has occured"));
                              };
                            room.onMessage("chatHist", function(message){
                                p1name = message.p1name;
                                p2name = message.p2name;
                            });
                            room.onMessage('message', function(message){
                                if(LobbyState.code == message.iden) PlayStateOnline.onlinemodetext.text = "Player Found! Starting...";
                                LobbyState.code = message.iden;	
                            });
                            room.onMessage("misc", (message) -> {
                                if(message.p1) {
                                    LobbyState.playertxt.members[0].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                }else{
                                    LobbyState.playertxt.members[0].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                }
                                if(message.p2) {
                                    LobbyState.playertxt.members[1].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                }else{
                                    LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                }
                            });
                            room.onMessage("start", function(message){
                                PlayStateOnline.startedMatch = true;
                                remove(PlayStateOnline.onlinemodetext);
                                remove(PlayStateOnline.roomcode);
                                add(PlayStateOnline.p1scoretext);
                                add(PlayStateOnline.p2scoretext);
                                //new PlayStateOnline().starts();
                                ConnectingState.inlobby = false;
                            });
                            room.onMessage('loaded', function(message){
                                PlayStateOnline.assing = true;
                            });
                            room.onMessage('finished', function(message){
                                PlayStateOnline.otherfinished = true;
                            });
                            room.onMessage('userjoin', function(message){
                                LobbyState.p2.alpha = 1;
                                p2name = message.name;
                            });
                            room.onMessage('userleft', function(message){
                                LobbyState.p2.alpha = 0;
                                if(PlayStateOnline.startedMatch) PlayStateOnline.leftText.text = "User left the game.";
                                if(!PlayStateOnline.startedMatch)p2name = '';
                                if(!PlayStateOnline.playedgame)LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                            });
                            room.onMessage("retscore", function(message){
                                PlayStateOnline.p1score = message.p1score;
                                PlayStateOnline.p2score = message.p2score;

                                PlayStateOnline.p1scoretext.text = p1name + " Score: " + PlayStateOnline.p1score;
                                PlayStateOnline.p2scoretext.text = p2name + " Score: " + PlayStateOnline.p2score;
                            });
                        }catch(e:Any){
                            PlayStateOnline.connected = false;
                            trace("Could not connect to the server");
                            if(FlxG.random.bool(0.1))PlayStateOnline.onlinemodetext.text = "bitch git gud internet";
                            else PlayStateOnline.onlinemodetext.text = "Not connected to the server.";
                            PlayStateOnline.onlinemodetext.screenCenter(XY);
                        }
                    });
                }else if(type == "join"){
                    conmode = 'join';
                    if(FlxG.save.data.username != null) p2name = FlxG.save.data.username;
                    else p2name = "guest" + FlxG.random.int(0, 9999);
                    try{
                        coly.join("battle", [], Stuff, function(err, room) { 
                            if (err != null) {
                                trace("JOIN ERROR: " + err);
                                FlxG.switchState(new FNFNetMenu("Could not find a room"));
                                return;
                            }
                            rooms = room;
                            LobbyState.rooms = room;
                            PlayStateOnline.rooms = room;
                            room.send('recvprev', {name: p2name});
                            room.onMessage("start", function(message){
                                LoadingOnline.loadAndSwitchState(new PlayStateOnline());
                                PlayStateOnline.startedMatch = true;
                                //new PlayStateOnline().starts();
                                ConnectingState.inlobby = false;
                            });
                            room.onMessage('loaded', function(message){
                                PlayStateOnline.assing = true;
                            });
                            room.onMessage('finished', function(message){
                                PlayStateOnline.otherfinished = true;
                            });
                            room.onError += function(code, message) {
                                FlxG.switchState(new FNFNetMenu("A strange error occured"));
                              };
                            room.onMessage("chatHist", function(message){
                                p1name = message.p1name;
                                p2name = message.p2name;
                            });
                            room.onMessage("misc", (message) -> {
                                if(inlobby){
                                    if(message.p1) {
                                        LobbyState.playertxt.members[0].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                    }else{
                                        LobbyState.playertxt.members[0].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                    }
                                    if(message.p2) {
                                        LobbyState.playertxt.members[1].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                    }else{
                                        LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                    }
                                }
                            });
                            room.onMessage('userleft', function(message){
                                LobbyState.p2.alpha = 0;
                                if(PlayStateOnline.startedMatch) PlayStateOnline.leftText.text = "User left the game.";
                                if(!PlayStateOnline.playedgame){
                                    FlxG.switchState(new FNFNetMenu());
                                    p2name = '';
                                }
                                if(!PlayStateOnline.playedgame)LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                            });
                            room.onMessage("message", function(message){
                                p1name = message.p1name;
                                LobbyState.songdata.song = message.song;
                                LobbyState.songdata.week = message.week;
                                var sng = message.song;
                                var wk = message.week;
                                var dif = message.diff;
                                var modif = switch(dif){
                                    case 0:
                                        "-easy";
                                    default:
                                        "";
                                    case 2:
                                        "-hard";
                                }
                                trace(nmsongs.contains(message.song));
                                if(!nmsongs.contains(message.song)){
                                    FreeplayState.songname = sng;
                                    modded = true;
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Instrumental...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    PlayStateOnline.modinst = new Sound(new URLRequest('http://'+data.resourceaddr+'/songs/$sng/Inst.ogg'));
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Voices...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    PlayStateOnline.modvoices = new Sound(new URLRequest('http://'+data.resourceaddr+'/songs/$sng/Voices.ogg'));
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Chart...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    var http = new haxe.Http('http://'+data.resourceaddr+'/songs/$sng/chart$modif.json');
                    
                                    http.onData = function (data:String) {
                                        trace("bing bong");
                                        PlayStateOnline.SONG = Song.loadFromJson(data, message.song, true);
                                        PlayStateOnline.isStoryMode = false;
                                        PlayStateOnline.storyDifficulty = message.diff;
                            
                                        PlayStateOnline.storyWeek = message.week;
                                        LobbyState.songdata.difficulty = PlayStateOnline.storyDifficulty;
                                        remove(loadprog);
                                        loadprog = new Alphabet(0, 0, "All Done!", true);
                                        loadprog.screenCenter(XY);
                                        add(loadprog);
                                        LoadingOnline.loadAndSwitchState(new LobbyState());
                                    }
                                    http.request();
                                }else{
                                    modded = false;
                                    var poop:String = Highscore.formatSong(message.song, 2);

                                    PlayStateOnline.SONG = Song.loadFromJson(poop, message.song);
                                    PlayStateOnline.isStoryMode = false;
                                    PlayStateOnline.storyDifficulty = message.diff;
                        
                                    PlayStateOnline.storyWeek = message.week;
                                    LobbyState.songdata.difficulty = PlayStateOnline.storyDifficulty;
                                    LoadingOnline.loadAndSwitchState(new LobbyState());
                                }
                            });

                            room.onMessage("retscore", function(message){
                                PlayStateOnline.p1score = message.p1score;
                                PlayStateOnline.p2score = message.p2score;

                                PlayStateOnline.p1scoretext.text = p1name + " Score: " + PlayStateOnline.p1score;
                                PlayStateOnline.p2scoretext.text = p2name + " Score: " + PlayStateOnline.p2score;
                            });
                        });
                    }catch(e:Any){
                        trace(e);
                    }
                    //var poop:String = Highscore.formatSong("philly", 2);

                    ///PlayStateOnline.SONG = Song.loadFromJson(poop, "philly");
                    ///PlayStateOnline.isStoryMode = false;
                    ///PlayStateOnline.storyDifficulty = 2;
        
                   /// PlayStateOnline.storyWeek = 3;
                    //LoadingOnline.loadAndSwitchState(new PlayStateOnline());
                }else if(type == "code"){
                    conmode = 'join';
                    if(FlxG.save.data.username != null) p2name = FlxG.save.data.username;
                    else p2name = "guest" + FlxG.random.int(0, 9999);
                    try{
                        coly.joinById(code, [], Stuff, function(err, room) { 
                            if (err != null) {
                                trace("JOIN ERROR: " + err);
                                FlxG.switchState(new FNFNetMenu("Could not find a room"));
                                return;
                            }
                            rooms = room;
                            LobbyState.rooms = room;
                            PlayStateOnline.rooms = room;
                            room.send('recvprev', {name: p2name});
                            room.onMessage("start", function(message){
                                LoadingOnline.loadAndSwitchState(new PlayStateOnline());
                                PlayStateOnline.startedMatch = true;
                                //new PlayStateOnline().starts();
                                ConnectingState.inlobby = false;
                            });
                            room.onMessage('loaded', function(message){
                                PlayStateOnline.assing = true;
                            });
                            room.onMessage('finished', function(message){
                                PlayStateOnline.otherfinished = true;
                            });
                            room.onError += function(code, message) {
                                FlxG.switchState(new FNFNetMenu("A strange error occured"));
                              };
                            room.onMessage("chatHist", function(message){
                                p1name = message.p1name;
                                p2name = message.p2name;
                            });
                            room.onMessage("misc", (message) -> {
                                if(inlobby){
                                    if(message.p1) {
                                        LobbyState.playertxt.members[0].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                    }else{
                                        LobbyState.playertxt.members[0].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                    }
                                    if(message.p2) {
                                        LobbyState.playertxt.members[1].applyMarkup("/r/Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "/r/")]);
                                    }else{
                                        LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                                    }
                                }
                            });
                            room.onMessage('userleft', function(message){
                                LobbyState.p2.alpha = 0;
                                if(PlayStateOnline.startedMatch) PlayStateOnline.leftText.text = "User left the game.";
                                if(!PlayStateOnline.playedgame){
                                    FlxG.switchState(new FNFNetMenu());
                                    p2name = '';
                                }
                                if(!PlayStateOnline.playedgame)LobbyState.playertxt.members[1].applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
                            });
                            room.onMessage("message", function(message){
                                p1name = message.p1name;
                                LobbyState.songdata.song = message.song;
                                LobbyState.songdata.week = message.week;
                                var sng = message.song;
                                var wk = message.week;
                                var dif = message.diff;
                                var modif = switch(dif){
                                    case 0:
                                        "-easy";
                                    default:
                                        "";
                                    case 2:
                                        "-hard";
                                }
                                trace(nmsongs.contains(message.song));
                                if(!nmsongs.contains(message.song)){
                                    modded = true;
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Instrumental...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    PlayStateOnline.modinst = new Sound(new URLRequest('http://'+data.resourceaddr+'/songs/$sng/Inst.ogg'));
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Voices...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    PlayStateOnline.modvoices = new Sound(new URLRequest('http://'+data.resourceaddr+'/songs/$sng/Voices.ogg'));
                                    remove(loadprog);
                                    loadprog = new Alphabet(0, 0, "Loading Chart...", true);
                                    loadprog.screenCenter(XY);
                                    add(loadprog);
                                    var http = new haxe.Http('http://'+data.resourceaddr+'/songs/$sng/chart$modif.json');
                    
                                    http.onData = function (data:String) {
                                        trace("bing bong");
                                        PlayStateOnline.SONG = Song.loadFromJson(data, message.song, true);
                                        PlayStateOnline.isStoryMode = false;
                                        PlayStateOnline.storyDifficulty = message.diff;
                            
                                        PlayStateOnline.storyWeek = message.week;
                                        LobbyState.songdata.difficulty = PlayStateOnline.storyDifficulty;
                                        remove(loadprog);
                                        loadprog = new Alphabet(0, 0, "All Done!", true);
                                        loadprog.screenCenter(XY);
                                        add(loadprog);
                                        LoadingOnline.loadAndSwitchState(new LobbyState());
                                    }
                                    http.request();
                                }else{
                                    modded = false;
                                    var poop:String = Highscore.formatSong(message.song, 2);

                                    PlayStateOnline.SONG = Song.loadFromJson(poop, message.song);
                                    PlayStateOnline.isStoryMode = false;
                                    PlayStateOnline.storyDifficulty = message.diff;
                        
                                    PlayStateOnline.storyWeek = message.week;
                                    LobbyState.songdata.difficulty = PlayStateOnline.storyDifficulty;
                                    LoadingOnline.loadAndSwitchState(new LobbyState());
                                }
                            });

                            room.onMessage("retscore", function(message){
                                PlayStateOnline.p1score = message.p1score;
                                PlayStateOnline.p2score = message.p2score;

                                PlayStateOnline.p1scoretext.text = p1name + " Score: " + PlayStateOnline.p1score;
                                PlayStateOnline.p2scoretext.text = p2name + " Score: " + PlayStateOnline.p2score;
                            });
                        });
                    }catch(e:Any){
                        trace(e);
                    }
                    //var poop:String = Highscore.formatSong("philly", 2);
                }
                
        }
    }
    override function create(){
        FlxG.autoPause = false;
        var logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = true;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		var ldBG = new FlxSprite(0, 0).loadGraphic(Paths.image('loadyBG'));
		var loading = new FlxSprite(0, FlxG.height * 0.5).loadGraphic(Paths.image('loadingLoader'));
		loading.screenCenter(X);
		var motherfunkers = new FlxSprite(0, 0).loadGraphic(Paths.image('loadingFunkers'));
		motherfunkers.setGraphicSize(Std.int(FlxG.width * 0.5), Std.int(FlxG.height * 1.1));
		motherfunkers.screenCenter(Y);
		loading.x += FlxG.width * 0.14;
		motherfunkers.x -= FlxG.width * 0.14;
        loadprog = new Alphabet(0, 0, "Loading...", true);
        loadprog.screenCenter(XY);
		motherfunkers.antialiasing = true;
		loading.antialiasing = true;
		//bgColor = 0xcaff4d;
		add(ldBG);
		add(motherfunkers);
		add(loading);
        add(loadprog);
        super.create();
    }
    override function update(elapsed:Float){
        if(FlxG.keys.justPressed.ESCAPE){
            rooms.leave();
            FlxG.switchState(new FNFNetMenu());
        }
        super.update(elapsed);
    }
}