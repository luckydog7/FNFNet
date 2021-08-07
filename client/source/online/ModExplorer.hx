package online;

import flixel.FlxSprite;

class ModExplorer extends MusicBeatState 
{
    override function create(){
        var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0xFFea71fd;
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
        super.create();
    }
    override function update(elapsed:Float){
        super.update(elapsed);
    }
}