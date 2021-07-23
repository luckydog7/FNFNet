package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
import Controls.Control;

class GimmickState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	var controlsStrings:Array<String> = [];
	private var grpControls:FlxTypedGroup<Alphabet>;
	var parser = new hscript.Parser();
	var interp = new hscript.Interp();
	public static var menuBG:FlxSprite;
	
	//the variables for the gimmick control
	public static var invisarrow:Bool = false;
	public static var upsidedown:Bool = false;
	public static var instantdeath:Bool = false;
	public static var perfectcombo:Bool = false;
	public static var diffvocals:Bool = false;
	public static var automatic:Bool = false;

	var cockJoke = new FlxTypedGroup<FlxText>();
	var checkboxArray:FlxTypedGroup<FlxSprite>;
	override function create()
	{

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = FlxColor.fromRGB(130, 255, 249);
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		initSettings(true);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);
		controlsStrings = [
            "Invisible Arrows",
            "Upside Down",
			"Instant Death",
			"Perfect Combo",
			"Difficulty Vocals",
			//"Automatic",
            "Start"
        ];
		add(checkboxArray);
		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);

			/*
			var icon:FlxSprite = new FlxSprite();
			icon.frames = Paths.getSparrowAtlas("checkboxThingie");
			icon.animation.addByPrefix("idle", "Check Box Selected Static", 24, true);
			icon.animation.play("idle");
			// using a FlxGroup is too much fuss!
			checkboxArray.add(icon);
			*/
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		 

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

			switch(curSelected){}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
                switch(controlsStrings[curSelected]){
                    case "Invisible Arrows":
						invisarrow = !invisarrow;
						initSettings(false, 0, "Invisible Arrows: " + Std.string(invisarrow));
                        //PlayState.babyArrow.alpha = 0;
					case "Upside Down":
						upsidedown = !upsidedown;
						grpControls.members[curSelected].text = grpControls.members[curSelected].text + " " + upsidedown;
						initSettings(false, 1, "Upside Down: " + Std.string(upsidedown));
                    case "Instant Death":
						instantdeath = !instantdeath;
						initSettings(false, 2, "Instant Death: " + Std.string(instantdeath));
					case "Perfect Combo":
						perfectcombo = !perfectcombo;
						initSettings(false, 3, "Perfect Combo: " + Std.string(perfectcombo));
					case "Difficulty Vocals":
						diffvocals = !diffvocals;
						initSettings(false, 4, "Difficulty Vocals: " + Std.string(diffvocals));
					case "Automatic":
						automatic = !automatic;
                    case "Start":
                        LoadingState.loadAndSwitchState(new PlayState());
                }
			}
			if (isSettingControl)
				waitingInput();
			else
			{
				if (controls.BACK)
					FlxG.switchState(new FreeplayState());
				if (controls.UP_P)
					changeSelection(-1);
				if (controls.DOWN_P)
					changeSelection(1);
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
	function initSettings(noreset, ?thingit, ?text):Void
		{
			if(!noreset){
				cockJoke.members[thingit].text = Std.string(text);
			}
			if(noreset){
				add(cockJoke);
				var curStuff:Array<String> = ["Invisible Arrows: ","Upside Down:","Instant Death: ","Perfect Combo: ", "Difficulty Vocals: "];
				var curVars:Array<String> = [Std.string(invisarrow), Std.string(upsidedown), Std.string(instantdeath), Std.string(perfectcombo), Std.string(diffvocals)];
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
}
