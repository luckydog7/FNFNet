package;

import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import Controls.Control;
using StringTools;
/*
** this code genuinely sucks i apologize
*/
class CharacterSelection extends MusicBeatState
{
	var ticktockclock = false;
	var controlsStrings:Array<String> = [];
	var curChar:FlxSprite;
	
	var grpControls:FlxTypedGroup<Alphabet>;
	var funkers:FlxTypedGroup<FlxSprite>;
	var nospam:Bool;
	var curSelected:Int = 0;

	var yellowBG:FlxSprite;
	var icon:FlxSprite;

	override function create()
	{
		nospam = false;
		//Assets.loadLibrary("shared");
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 445, FlxColor.fromRGB(255, 195, 128));
		var mnrbar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		var blackBarThingie:FlxSprite = new FlxSprite(0, 500).makeGraphic(FlxG.width, 400, FlxColor.BLACK);

		controlsStrings = CoolUtil.coolTextFile(Paths.txt("CustomCharacters", "characters"));

		icon = new FlxSprite(50, 550).loadGraphic(Paths.image("icon-"+actualIcon(true), "characters"));

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;

		add(menuBG);
		add(blackBarThingie);
		add(mnrbar);
		grpControls = new FlxTypedGroup<Alphabet>();
		funkers = new FlxTypedGroup<FlxSprite>();
		add(grpControls);
		//add(yellowBG);
		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, 0, controlsStrings[i], true, false, 0.78, 70, false);
			controlLabel.screenCenter(XY);
			controlLabel.y += 200;
			controlLabel.isMenuItem = true;
			controlLabel.y += ((controlLabel.height + 20) * i);
			//controlLabel.targetY = controlLabel.y*i+1;

			var curChar = new FlxSprite(30, 72);
			curChar.frames = Paths.getSparrowAtlas(controlsStrings[i]);
			curChar.animation.addByPrefix("idle", 'BF idle dance', 24, true);
			curChar.animation.addByPrefix("hey", 'BF HEY!!', 24, false);
			curChar.screenCenter(X);
			curChar.x += (500*i);
			curChar.animation.play("idle");
			curChar.antialiasing = true;
			grpControls.add(controlLabel);
			funkers.add(curChar);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
		add(yellowBG);
		add(funkers);
		add(icon);
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
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
		if(controls.ACCEPT){
			/* FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK FUCK 
			var tmp = grpControls.members[curSelected].x;
			grpControls.members[curSelected] = new Alphabet(0, grpControls.members[curSelected].y, "ping!", true, false);
			grpControls.members[curSelected].x = tmp;
			*/
			var stopspamming:Bool = false;
			if (stopspamming == false)
			{
				var daSelected:String = controlsStrings[curSelected];
				funkers.members[curSelected].animation.play("hey");
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.save.data.curcharacter = daSelected;
				FlxG.save.flush();
				stopspamming = true;
			}
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
		}

	}
	function changeSelection(change:Int = 0)
		{
			if(nospam == false)
			{
				ticktockclock = false;
				nospam = true;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected += change;

				if (curSelected < 0){
					curSelected++;
					ticktockclock = true;
				}
				if (curSelected >= grpControls.length){
					curSelected--;
					ticktockclock = true;
				}
				if(change == 0) ticktockclock = true;
				yellowBG.color = CoolUtil.dominantColor(funkers.members[curSelected]);
				// selector.y = (70 * curSelected) + 30;
		
				var bullShit:Int = 0;
				var asscrap:Int = 0;
				var thing:Int = 0;
				for (item in funkers.members){
					thing = asscrap - curSelected;
					asscrap++;
		
					item.alpha = 0.6;
					item.setGraphicSize(Std.int(item.width * 0.8));
		
					if (thing == 0)
					{
						item.alpha = 1;
						item.setGraphicSize(Std.int(item.width));
					}

				}
				for (item in grpControls.members)
				{
					item.targetY = bullShit - curSelected;
					bullShit++;
		
					item.alpha = 0.6;
					//item.setGraphicSize(Std.int(item.width * 0.8));
		
					if (item.targetY == 0)
					{
						item.alpha = 1;
						//item.setGraphicSize(Std.int(item.width));
					}
				} 
				/*
				if(curSelected > 2){
					var tmp = grpControls.members[curSelected].x;
					grpControls.members[curSelected] = new Alphabet(0, grpControls.members[curSelected].y, controlsStrings[curSelected], true, false);
					grpControls.members[curSelected].x = tmp;
				}
				*/
				icon.loadGraphic(Paths.image("icon-"+actualIcon(), "characters"));

				var daSelected:String = controlsStrings[curSelected];
				//curChar.frames = Paths.getSparrowAtlas(daSelected);
				//curChar.animation.addByPrefix("idle", 'BF idle dance', 24, true);
				//curChar.animation.play("idle");
				// dont uncomment if epileptic FlxTween.tween(yellowBG, {color: CoolUtil.dominantColor(funkers.members[curSelected])}, 5, {ease: FlxEase.sineInOut});
				/*
				grpControls.forEach(function(stuff:Alphabet){
					if (change == -1) FlxTween.tween(stuff, {y: stuff.y + 50}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
					else if (change == 1) FlxTween.tween(stuff, {y: stuff.y - 50}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
				});
				*/
				var asd:Int = 0;
				//for(i in 0...funkers.members.length)
				//	if(change != 0)funkers.members[i].x = 470 - (funkers.members[i].x / i+1);//((FlxG.width/2) * (curSelected + i) - (FlxG.width/2) * (curSelected + i))

				funkers.forEach(function(stuff:FlxSprite){
					//asd++;
					//if(change != 0)stuff.x = 500 * (curSelected);
					if(curSelected == 0 && !ticktockclock) FlxTween.tween(stuff, {x: stuff.x + 500}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
					if (curSelected == controlsStrings.length && ticktockclock) FlxTween.tween(stuff, {x: stuff.x + 500 * controlsStrings.length}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
					else{
						if (change == -1 && !ticktockclock) FlxTween.tween(stuff, {x: stuff.x + 500}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
						else if (change == 1 && !ticktockclock) FlxTween.tween(stuff, {x: stuff.x - 500}, 0.2, {ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween){ nospam = false; }});
					}
				});
				if(change == 0 || ticktockclock) nospam = false;
				
				//nospam = false;
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
		function actualIcon(?piss:Bool){
			var icawn:String;
			if(controlsStrings[curSelected] == "BOYFRIEND"){
				icawn = "bf";
			}else
			icawn = controlsStrings[curSelected];
			if(piss) icawn = "bf";
			return icawn;
		}
}
