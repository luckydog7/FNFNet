package online;

import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.system.FlxSound;
import networking.sessions.Session;
import networking.utils.NetworkEvent;
import networking.utils.NetworkMode;
import networking.Network;
import haxe.io.Bytes;
import flixel.addons.ui.FlxInputText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if desktop
import Config.data;
#end
class ChatStateOld extends MusicBeatState
{  
    public static var client:Session;
    var UI_box:FlxUITabMenu;

    var txtbox:FlxInputText;
    public static var usnbox:FlxInputText;

    public static var isUsN:Bool;
    public static var beentoChat:Bool;


    public static var username:String;

    public static var messages:FlxText;
	public static var chatText:FlxText;
    public static var MOTD:FlxText;
    public static var rules:FlxText;

    public var okButton:flixel.ui.FlxButton;
    var pauseMusic:FlxSound;

    override function create()
	{
        #if desktop
        FlxG.sound.music.stop();
        var pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 30;
		pauseMusic.play(true, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
        FlxG.sound.list.add(pauseMusic);

        var userlist = new FlxText(FlxG.width - 150, 0, "Users online:\n", 10);
        userlist.borderSize = 1;
        userlist.borderColor = FlxColor.BLACK;

        beentoChat = true;
        FlxG.mouse.visible = true;
        FlxG.autoPause = false;

        if(FlxG.save.data.username != null) username = FlxG.save.data.username;
        else username = "guest" + FlxG.random.int(0, 9999); 

        var client = Network.registerSession(NetworkMode.CLIENT, { ip: data.addr, port: data.port});

        UI_box = new FlxUITabMenu(null, [
            {name: "tab1", label: 'MOTD'},
            {name: "tab2", label: 'Rules'},
        ], true);

		UI_box.resize(400, 400);
		UI_box.screenCenter(XY);
        UI_box.selected_tab = 0;

        MOTD = new FlxText(3, 3, "dummy", 13); //UI_box.x + 3, UI_box.y + 50
        rules = new FlxText(3, 3, "dummy", 13); //UI_box.x + 3, UI_box.y + 50
        okButton = new flixel.ui.FlxButton(-280, 340, "Ok", function()
            {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                remove(UI_box);
                this.okButton.visible = false;
            });

        client.addEventListener(NetworkEvent.MESSAGE_RECEIVED, function(event: NetworkEvent) { 
            
            if(event.data.chathist != null) {
                chatText.text = event.data.chathist;
                MOTD.text = event.data.motd;
                rules.text = event.data.rules;
                chatText.y += event.data.axY; 
            }

            if(event.data.message != null){
                FlxG.sound.play(Paths.sound("sentmessage"));
                chatText.text = chatText.text + event.data.message + "\n";
                chatText.y -= 20;
                //chatText.applyMarkup(chatText.text, [new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "$")]);

            }

            if(event.data.uslist != null){
                userlist.text = "Users online:\n";
                var users:Array<String> = event.data.uslist;
                for(i in 0...users.length){
                    userlist.text += users[i] + "\n";
                }
            }
            //if(event.data.message != null) chatText.y -= 20; 
        }); //event.data.axY;
          
        client.addEventListener(NetworkEvent.CONNECTED, function(event: NetworkEvent) {
            add(UI_box);
            add(okButton);
            chatText.text = "";
            chatText.y = txtbox.y - 23;
            client.send({nen: username});
        });

        client.addEventListener(NetworkEvent.SERVER_FULL, function(event: NetworkEvent) {
            chatText.text = "Server is full! Try joining later!\n";
            chatText.y = txtbox.y - 23;
        });

        client.addEventListener(NetworkEvent.DISCONNECTED, function(event: NetworkEvent) {
            chatText.text = "You have been disconnected from the server!\n";
            chatText.y = txtbox.y - 23;
        });

        client.start();

        txtbox = new FlxInputText(200, 704.5, FlxG.width);
        txtbox.screenCenter(X);
        txtbox.background = true;
        txtbox.backgroundColor = FlxColor.WHITE;
        txtbox.borderColor = 0xFFFFFFFF;
        
        var chatTexts = new FlxTypedGroup<FlxText>();
		add(chatTexts);
        
        chatText = new FlxText(FlxG.width * 0.01, txtbox.y - 23, 0, "Connecting...\n", 16); // FlxG.width * 0.01
        chatText.ID = 1;
        //chatText.screenCenter(X);
        chatTexts.add(chatText);
        chatText.scrollFactor.set();
        chatText.antialiasing = true;
        chatText.autoSize = true;
        //FlxG.watch.addQuick("dababy Y", chatText.y);

        usnbox = new FlxInputText(200, 700, 100);
        usnbox.screenCenter(XY);
        usnbox.background = true;
        usnbox.backgroundColor = FlxColor.WHITE;
        usnbox.borderColor = 0xFFFFFFFF;
        usnbox.visible = false;

		var nameButton = new flixel.ui.FlxButton(txtbox.width - 80, txtbox.y, "Username", function()
            {
                changeUsername();
            });

        okButton.screenCenter(XY);
        okButton.y += 150;

        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        
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

		super.create();
        #end
	}

	override function update(elapsed:Float)
	{
        #if desktop
        super.update(elapsed);
        if(FlxG.keys.justPressed.ESCAPE) {
            Network.destroySession(Network.sessions[0]);
            FlxG.switchState(new MainMenuState());
        }
        if(FlxG.keys.justPressed.ENTER && txtbox.text != "" && !isUsN) {
            var session = Network.sessions[0];
            session.send({message: txtbox.text, name: username}); //Bytes.ofString(txtbox.text)
            txtbox.text = "";
            txtbox.caretIndex = 0;
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
        }
    }
}