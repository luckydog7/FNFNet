# Charting mods for TrollEngine
ever wanted to make modcharts like kade engine but for TrollEngine instead? This technology uses hscript, which allows arbitrary code execution in-game and you program it in haxe instead of lua.
## Path for chartscripts
The scripts for the charts must be in assets/data/songnameofyourchoice/chartscript

IT MUST BE in the same directory as the charts, and named ``chartscript``
no file extensions, no capitalization, just ``chartscript``

if the file is found, the game will execute the functions in it
## Most basic template
The game will crash if one of the functions isn't available, so:
```haxe
function onStart(){
    //Do something when starting
}

function update(){
    //Do every update call
}

function onDeath(){
    //when boyfriend dies
}
```
## Language
You must have a bit of knowledge about haxeflixel and haxe to make modcharts for this.

I will write examples soon.
## Declared objects
These are the objects that are declared (currently):
* PlayState
* FlxG
* Sys
* Math
* FlxSprite
* FlxObject
* Sys
* Character
* FlxSprite
* FlxTween
* FlxEase
* FlxText
* Alphabet
* MusicBeatState
* curBeat
* iconP1
* iconP2
* playerStrums
* FlxCamera
* camFollow
* FlxTimer