package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.util.FlxSave;
import Controls.KeyboardScheme;
class OptionsMenu extends MusicBeatState
{
	public static var notice:FlxText;
	public static var resolution:FlxText;
	public static var fullscreen:FlxText;
	public static var curFPS:FlxText;
	public static var downscroll:FlxText;
	public static var ks:FlxText;
	public static var rn:Int;
	public static var cDat:Int;
	public static var kbd:String;
	var cockJoke = new FlxTypedGroup<FlxText>();
	var selector:FlxText;
	var curSelected:Int = 0;
	var controlsStrings:Array<String> = [];
	var cockjoke:Int = FlxG.updateFramerate;
	private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		if(FlxG.save.data.pgbar == null) FlxG.save.data.pgbar = false;
		switch(FlxG.save.data.ks){
			case null:
				kbd = "WASD";
			case "WASD":
				kbd = "WASD";
			case "DFJK":
				kbd = "DFJK";
		}

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		controlsStrings = ["Framerate", "Pause on Unfocus", "Fullscreen", "Downscroll", "Keyboard Scheme", "Kade Input", "Progress Bar", "Instant Restart"];// nop3CoolUtil.coolTextFile(Paths.txt('controls'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		initSettings(true);

		notice = new FlxText(20, FlxG.height * 0.83, 0, "", 32);
		notice.text = "Use the left and arrow keys to change this option!";
		notice.scrollFactor.set();
		notice.setFormat(Paths.font('vcr.ttf'), 32);
		notice.updateHitbox();
		notice.screenCenter(X);
		notice.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		add(notice);

			grpControls = new FlxTypedGroup<Alphabet>();
			add(grpControls);

			for (i in 0...controlsStrings.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
		 

		super.create();

		//openSubState(new OptionsSubState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			switch(curSelected){
				case 0:
					if(controls.RIGHT_P) {
						if(FlxG.drawFramerate < 120) {
							FlxG.drawFramerate += 20; 
							FlxG.updateFramerate += 20; 
							FlxG.save.data.framerate = FlxG.drawFramerate;
							FlxG.save.flush();
							initSettings(false, 0, "Current Framerate: " + FlxG.drawFramerate);
						}
					}
					if(controls.LEFT_P) {
						if(FlxG.drawFramerate > 20) {
							FlxG.drawFramerate -= 20; 
							FlxG.updateFramerate -= 20; 
							FlxG.save.data.framerate = FlxG.drawFramerate;
							FlxG.save.flush();
							initSettings(false, 0, "Current Framerate: " + FlxG.drawFramerate);
						}
					}					
			}
			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				switch(curSelected){
					case 0:
						{
						FlxTween.tween(notice, {alpha: 1}, 1, {
							ease: FlxEase.quartInOut, 
							onComplete: function(twn:FlxTween)
								{
									new FlxTimer().start(2, function(timer:FlxTimer){
										if (timer.finished) {
											FlxTween.tween(notice, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
										}
									});
								}
						});
					}
					case 1:
						FlxG.autoPause = !FlxG.autoPause;
						FlxG.save.data.pauseonunfocus = FlxG.autoPause;
						FlxG.save.flush();
						initSettings(false, 1, "Pause on Unfocus: " + FlxG.autoPause);
					case 2:
						if(controls.ACCEPT) {
							FlxG.fullscreen = !FlxG.fullscreen;
							FlxG.save.data.fullscreen = FlxG.fullscreen;
							FlxG.save.flush();
							initSettings(false, 2, "Fullscreen: " + FlxG.fullscreen);
						}
					case 3:
						PlayState.downscroll = !PlayState.downscroll;
						FlxG.save.data.downscroll = PlayState.downscroll;
						FlxG.save.flush();
						initSettings(false, 3, "Downscroll: " + PlayState.downscroll);
					case 4:
						if(kbd == "WASD"){
							kbd = "DFJK";
							controls.setKeyboardScheme(KeyboardScheme.Custom, true);
							FlxG.save.data.ks = "DFJK";
							FlxG.save.flush();
							initSettings(false, 4, "Keyboard Scheme: " + kbd);
						}else{
							kbd = "WASD";
							controls.setKeyboardScheme(KeyboardScheme.Solo, true);
							FlxG.save.data.ks = "WASD";
							FlxG.save.flush();
							initSettings(false, 4, "Keyboard Scheme: " + kbd);
						}
					case 2323:
						FlxG.switchState(new ScriptState());	
					case 5:
						if(FlxG.save.data.kadeinput != null)FlxG.save.data.kadeinput = !FlxG.save.data.kadeinput;
						else FlxG.save.data.kadeinput = true;
						FlxG.save.flush();
						initSettings(false, 5, "Kade Input: " + FlxG.save.data.kadeinput);
					case 6:
						FlxG.save.data.pgbar = !FlxG.save.data.pgbar;
						FlxG.save.flush();
						initSettings(false, 6, "Progress Bar: " + FlxG.save.data.pgbar);
					case 7:
						FlxG.save.data.instres = !FlxG.save.data.instres;
						FlxG.save.flush();
						initSettings(false, 7, "Instant Restart: " + FlxG.save.data.instres);
					case 9:
						var request = new haxe.Http("https://fnf.general-infinity.tech/thing.php");
						request.setPostData("no=no");
						request.request(true);
						FlxG.openURL('https://fnf.general-infinity.tech/thefunny.php');	
				}
			}
			if (isSettingControl)
				waitingInput();
			else
			{
				if (controls.BACK)
					FlxG.switchState(new MainMenuState());
				if (controls.UP_P)
					changeSelection(-1);
				if (controls.DOWN_P)
					changeSelection(1);
			}
		 
	}
	function initSettings(noreset, ?thingit, ?text):Void
		{
			if(!noreset){
				cockJoke.members[thingit].text = Std.string(text);
			}
			if(noreset){
				add(cockJoke);
				var curStuff:Array<String> = ["Current Framerate: ", "Pause on Unfocus: ", "Fullscreen: ", "Downscroll: ", "Keyboard Scheme: ", "Kade Input: ", "Progress Bar: ", "Instant Restart: "];
				var curVars:Array<String> = [Std.string(FlxG.updateFramerate), Std.string(FlxG.autoPause), Std.string(FlxG.fullscreen), Std.string(FlxG.save.data.downscroll), kbd, Std.string(FlxG.save.data.kadeinput), Std.string(FlxG.save.data.pgbar), Std.string(FlxG.save.data.instres)];
				for (i in 0...curStuff.length)
				{
					var dababy = new FlxText(20, 15 + (i * 32), 0, curStuff[i] + curVars[i], 32);
					dababy.scrollFactor.set();
					dababy.setFormat(Paths.font('vcr.ttf'), 32);
					dababy.updateHitbox();
					dababy.x = FlxG.width - (dababy.width + 20);
					dababy.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
					cockJoke.add(dababy);
				// LESS GOO !!
				}
			}
		}
	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
