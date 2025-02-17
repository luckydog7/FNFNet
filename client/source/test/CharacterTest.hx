package test;

import sys.io.File;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;
import lime.app.Future;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import test.TestState.songname;

using StringTools;

typedef Offset =
{
	name:String,
	x:Int,
	y:Int
}
class CharacterTest extends FlxSprite
{
    public static var tex(default, default):FlxAtlasFrames;
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	var loaded:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?shit:FlxAtlasFrames)
	{
		super(x, y);
		var tex:FlxAtlasFrames;
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;
				var chardata = haxe.Json.parse(File.getContent("./test/character.json"));
				x = chardata.character.position.x;
				y = chardata.character.position.y;
				loaded = false;
					BitmapData.loadFromFile('./test/character.png').then(function(image){
						frames = FlxAtlasFrames.fromSparrow(image, File.getContent("./test/character.xml"));
						
						animation.addByPrefix('idle', chardata.animations.idle.prefix, 24, false);
						animation.addByPrefix('singUP', chardata.animations.up.prefix, 24, false);
						animation.addByPrefix('singDOWN', chardata.animations.down.prefix, 24, false);
						animation.addByPrefix('singLEFT', chardata.animations.left.prefix, 24, false);
						animation.addByPrefix('singRIGHT', chardata.animations.right.prefix, 24, false);
				
						addOffset('idle', chardata.animations.idle.offsets.x, chardata.animations.idle.offsets.y);
						addOffset("singUP", chardata.animations.up.offsets.x, chardata.animations.up.offsets.y);
						addOffset("singRIGHT", chardata.animations.right.offsets.x, chardata.animations.right.offsets.y);
						addOffset("singLEFT", chardata.animations.left.offsets.x, chardata.animations.left.offsets.y);
						addOffset("singDOWN", chardata.animations.down.offsets.x, chardata.animations.down.offsets.y);
						loaded = true;
						playAnim('idle');
				
						dance();
						
						if(chardata.character.size.width != 0) setGraphicSize(chardata.character.size.width, chardata.character.size.height);
						return Future.withValue(image);
					});
				
	}

	override function update(elapsed:Float)
	{
		if(loaded){
			if (!curCharacter.startsWith('bf'))
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				var dadVar:Float = 4;

				if (curCharacter == 'dad')
					dadVar = 6.1;
				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(loaded){
			animation.play(AnimName, Force, Reversed, Frame);

			var daOffset = animOffsets.get(AnimName);
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
