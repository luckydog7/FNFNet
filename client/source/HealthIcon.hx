package;

import flixel.FlxG;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	var modifier:String;
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		switch(PlayState.curStage){
			case 'school' | 'school-evil':
				modifier = "-pixel";
			case 'mall' | 'mallEvil':
				modifier = "-christmas";
			case 'limo':
				modifier = "-car";
			default:
				modifier = "";
		}
		#if charselection
		if(isPlayer && FlxG.save.data.curcharacter != null){
			if(FlxG.save.data.curcharacter == "BOYFRIEND"){
				loadGraphic(Paths.image("icon-bf"+modifier, "characters"), true, 150, 150);
			}
			else loadGraphic(Paths.image("icon-"+FlxG.save.data.curcharacter+modifier, "characters"), true, 150, 150);
		}
		else loadGraphic(Paths.image("icon-"+char, "characters"), true, 150, 150);
		#else
		loadGraphic(Paths.image("icon-"+char, "characters"), true, 150, 150);
		#end
		antialiasing = true;
		animation.add(char, [0, 1], 0, false, isPlayer);
		/*
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-car', [0, 1], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
		animation.add('spooky', [2, 3], 0, false, isPlayer);
		animation.add('pico', [4, 5], 0, false, isPlayer);
		animation.add('mom', [6, 7], 0, false, isPlayer);
		animation.add('mom-car', [6, 7], 0, false, isPlayer);
		animation.add('tankman', [8, 9], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('senpai', [22, 22], 0, false, isPlayer);
		animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
		animation.add('spirit', [23, 23], 0, false, isPlayer);
		animation.add('bf-old', [14, 15], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('gf-christmas', [16], 0, false, isPlayer);
		animation.add('parents-christmas', [17], 0, false, isPlayer);
		animation.add('monster', [19, 20], 0, false, isPlayer);
		animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
		*/
		animation.play(char);
		scrollFactor.set();
	}
	public function changeIcon(char:String, isPlayer:Bool = false){
		loadGraphic(Paths.image("icon-"+char, "characters"), true, 150, 150);
		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
