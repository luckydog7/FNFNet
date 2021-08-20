package;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class EzText extends FlxText
{
    public function new(x:Float, y:Float, text:String, size:Int, bordersize:Int){
        super(x, y, 0, text);
        scrollFactor.set();
		setFormat(Paths.font('vcr.ttf'), size);
		updateHitbox();
		setBorderStyle(OUTLINE, FlxColor.BLACK, bordersize); //300 modifier btw
		antialiasing = true;
    }
    override function update(elapsed:Float){
        super.update(elapsed);
    }
}