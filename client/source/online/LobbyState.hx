package online;
#if (sys && !mobile)
import Discord.DiscordClient;
#end
import flixel.addons.ui.FlxInputText;
import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.addons.ui.FlxUI;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUITabMenu;
import flixel.text.FlxText;
import haxe.MainLoop;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.graphics.cairo.CairoPattern;
import io.colyseus.Room;
import online.ConnectingState.songmeta;

typedef Boolean = Bool; //doing this just to piss off haya :troll:
class LobbyState extends MusicBeatState{
    public static var rooms:Room<Stuff>;
    var p1:FlxSprite;
    public static var p2:FlxSprite;
    public static var songdata:ConnectingState.SongData = {song: '', week: 1, difficulty: 1};
    public static var roomcode:FlxText;
    public static var code:String;

    var p1name:FlxText;
    var p2name:FlxText;
    var readybtn:FlxButton;
    var ready:Boolean = false;
    public static var playertxt:FlxTypedGroup<FlxText>;

    override function create(){
        PlayStateOnline.playedgame = false;
        var songname = songdata.song;
        var songweek = songdata.week;
        var songdiff = switch(songdata.difficulty){
            case 0:
                'Easy';
            case 1:
                'Normal';
            case 3:
                'Hard';
            default:
                'Normal';
        };
        #if (sys && !mobile)
        DiscordClient.changePresence("In the FNFNet Lobby", null);
        #end
        var info = new FlxText(-140, -55);
        info.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        info.text = '
        Song: $songname
        Week: $songweek
        Difficulty: $songdiff
        ';
        //info.text = "Song: " + songdata.song + "\n Week: " + songdata.week + "Difficulty: " + songdata.difficulty;
        
        roomcode = new FlxText(5, FlxG.height *0.001, 0, "Room code: " + code, 12);
        roomcode.scrollFactor.set();
        roomcode.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        p1 = new FlxSprite(180, 303);
        p1.frames = Paths.getSparrowAtlas('BOYFRIEND');
        p1.flipX = true;
        p1.animation.addByPrefix('idle', 'BF idle dance', 24, true);
        p1.animation.play("idle");

        p2 = new Character(660, 303);
        p2.frames = Paths.getSparrowAtlas('BOYFRIEND');
        p2.flipX = true;
        p2.animation.addByPrefix('idle', 'BF idle dance', 24, true);
        p2.animation.play("idle");
        p2.alpha = 0;
        if(ConnectingState.conmode == 'join')p2.alpha = 1;
        p1name = new FlxText(p1.x + 100, p1.y - 30);
        p2name = new FlxText(p2.x + 100, p2.y - 30);
        
        p1name.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		p1name.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        p2name.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		p2name.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        playertxt = new FlxTypedGroup<FlxText>();
        var ptxt = new FlxText(p1.x, p1.y, 0, "Not Ready");
        ptxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		ptxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        ptxt.applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
        playertxt.add(ptxt);

        var ptxt = new FlxText(p2.x, p2.y, 0, "Not Ready");
        ptxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
		ptxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        ptxt.applyMarkup("/r/Not Ready/r/", [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "/r/")]);
        playertxt.add(ptxt);
        ConnectingState.inlobby = true;

        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        var UI_box = new FlxUITabMenu(null, [
            {name: "tab1", label: 'Player'},
            {name: "tab2", label: 'Info'},
        ], true);
        var characters = CoolUtil.coolTextFile(Paths.txt('characterList'));
        var characterdropdown = new FlxUIDropDownMenu(0,0,FlxUIDropDownMenu.makeStrIdLabelArray(characters,true), function(character:String){
            p1 = new Character(p1.x, p1.y, characters[Std.parseInt(character)]); 
        });

        var usnbox = new FlxInputText(250, 50, 120);
        usnbox.background = true;
        usnbox.backgroundColor = FlxColor.WHITE;
        usnbox.borderColor = 0xFFFFFFFF;

        readybtn = new FlxButton(50, 50, "Ready", function(){
            ready = !ready;
            if(ready) readybtn.text = "Unready";
            else readybtn.text = "Ready";
            rooms.send("misc", {ready: ready});
        });

        var namebtn = new FlxButton(usnbox.x, usnbox.y + 15, "Change Name", function(){
            if(usnbox.text != ""){
                if(ConnectingState.conmode == "host")ConnectingState.p1name = usnbox.text;
                else ConnectingState.p2name = usnbox.text;
                usnbox.text = "";
                usnbox.caretIndex = 0;
                if(ConnectingState.conmode == "host")rooms.send("chatHist", {name: ConnectingState.p1name});
                else rooms.send("chatHist", {name: ConnectingState.p2name});
            }
        });

		UI_box.resize(400, 200);
		UI_box.screenCenter(X);
        UI_box.y += 50;
        UI_box.x += 400;
        UI_box.selected_tab = 0;

        var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "tab1";

        var tab_info = new FlxUI(null, UI_box);
		tab_info.name = "tab2";
		//tab_group_song.add(UI_songTitle);
        //tab_group.add(characterdropdown);
        tab_group.add(readybtn);
        tab_group.add(usnbox);
        tab_group.add(namebtn);
        tab_info.add(info);
        UI_box.addGroup(tab_group);
        UI_box.addGroup(tab_info);
        add(stageCurtains);
        add(p1);
        add(p2);
        add(p1name);
        add(p2name);
        add(playertxt);
        add(UI_box);
        addVirtualPad(NONE, A_B);
        if(ConnectingState.conmode != "join")add(roomcode);

        super.create();
    }

    override function update(elapsed:Float){
        p1name.text = ConnectingState.p1name;
        p2name.text = ConnectingState.p2name;
        if(PlayStateOnline.startedMatch){
            LoadingOnline.loadAndSwitchState(new PlayStateOnline());
        }
        if(FlxG.keys.justPressed.ESCAPE || controls.BACK) {
            rooms.leave();
            FlxG.switchState(new FNFNetMenu());
        }
        super.update(elapsed);
    }
}