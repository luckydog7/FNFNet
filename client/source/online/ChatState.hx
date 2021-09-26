package online;

#if (sys && !mobile)
import Discord.DiscordClient;
#end
import Config.ConfigData;
import openfl.events.KeyboardEvent;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.system.FlxSound;
import haxe.io.Bytes;
import flixel.addons.ui.FlxInputText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Config.data;
import io.colyseus.Client;
import io.colyseus.Room;

typedef NDT = { // NDT means Nessecary Data Types btw!
    var message:String;
    var chatHist:String;
    var uslist:Array<String>;
    var motd:String;
    var rules:String;
    var axY:Int;
}
class ChatState extends MusicBeatState
{  
    var rooms:Room<Stuff>;
    var UI_box:FlxUITabMenu;

    var txtbox:FlxInputText;
    public static var usnbox:FlxInputText;

    public static var isUsN:Bool;
    public static var beentoChat:Bool;
    var pissing:Bool;
    var connected:Bool = false;

    var coly:Client;

    public static var username:String;

    public static var messages:FlxText;
	public static var chatText:FlxText;
    public static var MOTD:FlxText;
    public static var rules:FlxText;

    public var okButton:flixel.ui.FlxButton;
    var pauseMusic:FlxSound;

    override function create()
	{
        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        
        #if (sys && !mobile)
        DiscordClient.changePresence("Chatting in FNFNet", null);
        #end
        
        var coly = new Client('ws://' + data.addr + ':' + data.port);
        FlxG.sound.music.stop();
        var pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 30;
		pauseMusic.play(true, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
        FlxG.sound.list.add(pauseMusic);

        var userlist = new FlxText(FlxG.width - 250, 0, "Users online:\n", 10);
        userlist.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
        userlist.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        beentoChat = true;
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;

        if(FlxG.save.data.username != null) username = FlxG.save.data.username;
        else username = "guest" + FlxG.random.int(0, 9999); 
        
        UI_box = new FlxUITabMenu(null, [
            {name: "tab1", label: 'MOTD'},
            {name: "tab2", label: 'Rules'},
        ], true);

		UI_box.resize(400, 400);
		UI_box.screenCenter(XY);
        UI_box.selected_tab = 0;


        MOTD = new FlxText(3, 3, "Cannot connect to the server!", 13); //UI_box.x + 3, UI_box.y + 50
        MOTD.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
        MOTD.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        rules = new FlxText(3, 3, "Server down?", 18); //UI_box.x + 3, UI_box.y + 50
        rules.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, LEFT);
        rules.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);

        okButton = new flixel.ui.FlxButton(-280, 340, "Ok", function()
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                remove(UI_box);
                this.okButton.visible = false;
            });
        var timer = new haxe.Timer(50);
        connected = false;
        coly.joinOrCreate("chat", [], Stuff, function(err, room) {
            rooms = room;
            if (err != null) {
                trace("JOIN ERROR: " + err);
                return;
            }
            chatText.text = "Connecting...\n";
            chatText.y = txtbox.y - 23;
            //client.send({nen: username});
            room.send("userdata", {usname: username});
            room.onMessage("message", function(message) {
                FlxG.sound.play(Paths.sound("sentmessage"));
                chatText.text = chatText.text + message.message + "\n";
                chatText.applyMarkup(chatText.text,
                [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GREEN), "[G]")]);
                chatText.y -= 16;
                //chatText.applyMarkup(chatText.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "$")]);
            });
            room.onMessage("reul", function(message){
                var users:Array<String> = message.uslist;
                var tmpuser = "Users online:\n";
                for(i in 0...users.length){
                    tmpuser += users[i] + "\n";
                }
                userlist.text = tmpuser;
            });
            room.onMessage("recvprev", function(message){
                connected = true;
                chatText.text = message.chatHist;
                MOTD.text = message.motd;
                rules.text = message.rules;
                chatText.y += Std.int(message.axY); 

                userlist.text = "Users online:\n";
                var users:Array<String> = message.uslist;
            });
        });
        txtbox = new FlxInputText(200, 695.5, FlxG.width, "", 16);
        txtbox.screenCenter(X);
        txtbox.background = true;
        txtbox.backgroundColor = FlxColor.WHITE;
        txtbox.borderColor = 0xFFFFFFFF;
        
        var chatTexts = new FlxTypedGroup<FlxText>();
		add(chatTexts);
        
        chatText = new FlxText(FlxG.width * 0.01, txtbox.y - 23, 0, "Connecting...\n", 26); // FlxG.width * 0.01
        chatText.ID = 1;
        //chatText.screenCenter(X);
        chatTexts.add(chatText);
        chatText.scrollFactor.set();
        chatText.antialiasing = true;
        chatText.autoSize = true;
        chatText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
		chatText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
        //FlxG.watch.addQuick("dababy Y", chatText.y);

        usnbox = new FlxInputText(200, 700, 100);
        usnbox.screenCenter(XY);
        usnbox.background = true;
        usnbox.backgroundColor = FlxColor.WHITE;
        usnbox.borderColor = 0xFFFFFFFF;
        usnbox.visible = false;
		var nameButton = new flixel.ui.FlxButton(txtbox.width - 80, txtbox.y - 20, "Username", function()
            {
                changeUsername();
            });

        okButton.screenCenter(XY);
        okButton.y += 150;
        
		var tab_group_motd = new FlxUI(null, UI_box);
		tab_group_motd.name = "tab1";

        var tab_group_rules = new FlxUI(null, UI_box);
		tab_group_rules.name = "tab2";

        add(menuBG);
        add(txtbox);
        add(chatText);
        add(usnbox);
        add(nameButton);
        add(userlist);

        tab_group_motd.add(MOTD);

        tab_group_rules.add(rules);

        UI_box.addGroup(tab_group_motd);
        UI_box.addGroup(tab_group_rules);
        add(UI_box);
        add(okButton);
        addVirtualPad(NONE, A_B);

		super.create();
	}

	override function update(elapsed:Float)
	{
        super.update(elapsed);
        if(FlxG.keys.justPressed.ENTER && txtbox.text != "" && !isUsN) {
            if(connected)rooms.send("message", {message: txtbox.text});
            txtbox.text = "";
            txtbox.caretIndex = 0;
        }
        if(FlxG.keys.justPressed.ESCAPE || controls.BACK) {
            if(connected)rooms.leave();
            FlxG.switchState(new FNFNetMenu());
        }
        for (touch in FlxG.touches){
        	if (touch.overlaps(usnbox) && touch.justPressed && isUsN){
        		FlxG.stage.window.textInputEnabled = true;
        	}
        	if (touch.overlaps(txtbox) && touch.justPressed && !isUsN){
        		FlxG.stage.window.textInputEnabled = true;
        	}
        }
        	#if android
        	if (FlxG.android.justPressed.BACK){
        		FlxG.stage.window.textInputEnabled = false;
        	}
        	#end
	}
    public function changeUsername(){
        usnbox.visible = !usnbox.visible;
        isUsN = !isUsN;
        if(usnbox.text != ""){
            username = usnbox.text;
            FlxG.save.data.username = usnbox.text;
            FlxG.save.flush();
            usnbox.text = "";
            if(connected)rooms.send("userdata", {usname: username});
        }
    }
}