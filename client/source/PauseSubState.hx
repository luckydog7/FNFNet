package;

#if js
import js.html.audio.ChannelMergerNode;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;

class PauseSubState extends MusicBeatSubstate
{
	public static var pracMode:Bool = false;
	public static var skipped:Bool;
	public static var practiceMode:FlxText;
	public static var cS:FlxText;
	public static var kbd:String;

	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Control Scheme', 'Toggle Practice Mode', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();
		switch(FlxG.save.data.ks){
			case null:
				kbd = "WASD";
			case "WASD":
				kbd = "WASD";
			case "DFJK":
				kbd = "DFJK";
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		cS = new FlxText(20, 15 + 64, 0, "", 32);
		cS.text = "Control Scheme: " + kbd;
		cS.scrollFactor.set();
		cS.setFormat(Paths.font('vcr.ttf'), 32);
		cS.updateHitbox();
		add(cS);

		practiceMode = new FlxText(20, 15 + 96, 0, "", 32);
		practiceMode.text = "Practice Mode Toggled";
		practiceMode.scrollFactor.set();
		practiceMode.setFormat(Paths.font('vcr.ttf'), 32);
		practiceMode.updateHitbox();
		add(practiceMode);
		
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		practiceMode.alpha = 0;
		cS.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		practiceMode.x = FlxG.width - (practiceMode.width + 20);
		cS.x = FlxG.width - (cS.width + 20);

		var opa:Int;
		if (pracMode==true){
			opa = 1;
		} else{
			opa = 0;
		}
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(cS, {alpha : 1, y: cS.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7}); //alpha : 1,
		FlxTween.tween(practiceMode, {alpha : opa, y: practiceMode.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9}); //alpha : 1,	
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		addVirtualPad(UP_DOWN, A_B);
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Charting Menu":
					FlxG.switchState(new ChartingState());
				case "Control Scheme":
					if(kbd=="WASD"){
						kbd = "DFJK";
						controls.setKeyboardScheme(Custom, true);
						cS.text = "Control Scheme: " + kbd;
					}else{
						kbd = "WASD";
						controls.setKeyboardScheme(Solo, true);
						cS.text = "Control Scheme: " + kbd;
					}
				case "Toggle Practice Mode":
					if (pracMode==true){
						practiceMode.alpha = 0;
						pracMode = false;
					}else
					{
						practiceMode.alpha = 100;
						pracMode = true;
					}
					practice();
				case "Skip Song":
					skipped = true;
					FlxG.resetState();
					//FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
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
	function practice()
	{

	}
}
