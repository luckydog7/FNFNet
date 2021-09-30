package online;

import haxe.Json;
import haxe.Http;
import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.FlxSubState;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import io.colyseus.Client;
import io.colyseus.Room;
import Controls.*;
import ui.FlxVirtualPad;

using StringTools;

class ChooseSong extends MusicBeatSubstate
{
	var stupidPad:ui.FlxVirtualPad;
	var nmsongs:Array<String> = [
		'Tutorial',
		'Test',
		'Bopeebo',
		'Fresh',
		'Dadbattle',
		'Spookeez',
		'South',
		'Monster',
		'Pico',
		'Philly',
		'Blammed',
		'Satin-Panties',
		'High',
		'Milf',
		'Cocoa',
		'Eggnog',
		'Winter-Horrorland',
		'Senpai',
		'Roses',
		'Thorns'
	];
	var modtxt:FlxText;
	var modlist:ModMeta = {mods: [], orig: ['TrollEngine'], madeby: ['bit of trolling'], desc: ['your shit doesnt work fix ASAP!']};
	public static var bruh:Bool = false;
	public static var celsong:String;
	var songs:Array<SongMetadata> = [];
	public static var rooms:Room<Stuff>;
	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	public static var cutscene:Bool = false;
	public static var gimmick:Bool = false;
	var modtab:Bool;
	var loadingtxt:Alphabet;
	var scoreText:FlxText;
	var diffText:FlxText;
	var cutText:FlxText;
	var dumbText:FlxText;
	var gimText:FlxText;
	var orgin:FlxText;
	var creator:FlxText;
	var scoreBG:FlxSprite;
	var desc:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:FlxTypedGroup<HealthIcon>;

	override function create()
	{
		iconArray = new FlxTypedGroup<HealthIcon>();
		var mdl = new haxe.Http("http://"+Config.data.resourceaddr+"/modlist.json");
		mdl.onData = function(data:String){
			modlist = Json.parse(data);
			/*
			trace(data);
			modlist.mods = data.trim().split('\n');
			for (i in 0...modlist.mods.length)
				{
					modlist.mods[i] = modlist.mods[i].trim();
				}
			*/
		}
		mdl.request();
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			if(i==1){
				songs.push(new SongMetadata(initSonglist[1], 1, 'bf-pixel'));
			}else{
				songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
			}
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing a song in FNFNet", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);
		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		add(iconArray);
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		orgin = new FlxText(scoreText.x, scoreText.y + 72, 0, "Origin:", 20);
		orgin.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);

		creator = new FlxText(scoreText.x, scoreText.y + 102, 0, "Made By:", 20);
		creator.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);

		desc = new FlxText(scoreText.x, scoreText.y + 136, 0, "Description:", 20);
		desc.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.45), 105, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		dumbText = new FlxText(scoreText.x, scoreText.y + (36 * 2), 0, "Press M/C to switch to mods.", 24);
		dumbText.font = scoreText.font;
		add(dumbText);

		loadingtxt = new Alphabet(0, 0, "Loading Songs please wait...", true);
		loadingtxt.screenCenter(XY);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */
		// addVirtualPad(FULL, NONE);
		stupidPad = new FlxVirtualPad(FULL, A_B_C);
		stupidPad.alpha = 0.65;
		this.add(stupidPad);
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var pressedA:Bool = stupidPad.buttonA.justPressed;
		var pressedB:Bool = stupidPad.buttonB.justPressed;
		var pressedC:Bool = stupidPad.buttonC.justPressed;
		if(FlxG.keys.justPressed.M || pressedC){
			if(!modtab){
				modtab = true;
				scoreBG.setGraphicSize(Std.int(scoreBG.width), Std.int(scoreBG.height + 700));
				remove(grpSongs);
				remove(iconArray);
				grpSongs.clear();
				iconArray.clear();
				grpSongs = new FlxTypedGroup<Alphabet>();
				iconArray= new FlxTypedGroup<HealthIcon>();
				songs = [];
				remove(dumbText);
				for (i in 0...modlist.mods.length){
					addSong(modlist.mods[i], 1, 'face');
				}
				curSelected = 0;
				for (i in 0...modlist.mods.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpSongs.add(songText);
			
						var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
						icon.sprTracker = songText;
			
						// using a FlxGroup is too much fuss!
						iconArray.add(icon);
			
						// songText.x += 40;
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						// songText.screenCenter(X);
					}
					add(grpSongs);
					add(iconArray);
					add(orgin);
					add(creator);
					add(desc);
					orgin.text = "Origin: " + modlist.orig[curSelected];
					creator.text = "Made By: " + modlist.madeby[curSelected];
					desc.text = "Description: " + modlist.desc[curSelected];
				}else init();
		}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		var upP = controls.UP_P || stupidPad.buttonUp.justPressed;
		var downP = controls.DOWN_P || stupidPad.buttonDown.justPressed;
		var accepted = pressedA;

		if (upP || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (downP || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}
		if (controls.LEFT_P || stupidPad.buttonLeft.justPressed)
			changeDiff(-1);
		if (controls.RIGHT_P || stupidPad.buttonRight.justPressed)
			changeDiff(1);

		if (pressedB)
		{
			//rooms.leave();
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), 2);
			if(nmsongs.contains(songs[curSelected].songName)){
				PlayStateOnline.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase(), false);
				PlayStateOnline.isStoryMode = false;
				PlayStateOnline.storyDifficulty = curDifficulty;
	
				PlayStateOnline.storyWeek = songs[curSelected].week;
				//LoadingOnline.loadAndSwitchState(new PlayStateOnline());
				rooms.send('songname', {song: songs[curSelected].songName.toLowerCase(), diff: curDifficulty, week: songs[curSelected].week});
				LobbyState.songdata.song = songs[curSelected].songName;
				LobbyState.songdata.week = songs[curSelected].week;
				LobbyState.songdata.difficulty = curDifficulty;
				LoadingOnline.loadAndSwitchState(new LobbyState());
			}
			else{
				FreeplayState.songname = songs[curSelected].songName.toLowerCase();
				trace(songs[curSelected].songName.toLowerCase());
				add(loadingtxt);
				PlayStateOnline.modinst = new Sound(new URLRequest('http://'+Config.data.resourceaddr+'/songs/'+songs[curSelected].songName.toLowerCase()+'/Inst.ogg'));
				PlayStateOnline.modvoices = new Sound(new URLRequest('http://'+Config.data.resourceaddr+'/songs/'+songs[curSelected].songName.toLowerCase()+'/Voices.ogg'));
				ConnectingState.modded = true;
				var modif = switch(curDifficulty){
					case 0:
						"-easy";
					default:
						"";
					case 2:
						"-hard";
				}
				var http = new haxe.Http('http://'+Config.data.resourceaddr+'/songs/'+songs[curSelected].songName.toLowerCase()+'/chart$modif.json');

				http.onData = function (data:String) {
					PlayStateOnline.SONG = Song.loadFromJson(data, songs[curSelected].songName.toLowerCase(), true);
					PlayStateOnline.isStoryMode = false;
					PlayStateOnline.storyDifficulty = curDifficulty;
		
					PlayStateOnline.storyWeek = songs[curSelected].week;
					//LoadingOnline.loadAndSwitchState(new PlayStateOnline());
					rooms.send('songname', {song: songs[curSelected].songName.toLowerCase(), diff: curDifficulty, week: songs[curSelected].week});
					LobbyState.songdata.song = songs[curSelected].songName;
					LobbyState.songdata.week = songs[curSelected].week;
					LobbyState.songdata.difficulty = curDifficulty;
					LoadingOnline.loadAndSwitchState(new LobbyState());
				}

				http.onError = function (error) {
					FlxG.switchState(new FNFNetMenu());
				}

				http.request();
			}
		}
//		if(bruh){
//			var poop:String = Highscore.formatSong(celsong, 2);
//		
//			PlayStateOnline.SONG = Song.loadFromJson(poop, celsong);
//			PlayStateOnline.isStoryMode = false;
//			PlayStateOnline.storyDifficulty = 2;
//
//			PlayStateOnline.storyWeek = 1;
//			LoadingOnline.loadAndSwitchState(new PlayStateOnline());
//			bruh = false;
//		}
	}
	function init(){
		modtab = false;
		add(dumbText);
		scoreBG.setGraphicSize(Std.int(scoreBG.width), 105);
		songs = [];
		addWeek(['Tutorial', 'Test'], 1, ['gf', 'bf-pixel']);
		if (StoryMenuState.weekUnlocked[2])
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2])
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);

		if (StoryMenuState.weekUnlocked[3])
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4])
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5])
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6])
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		remove(grpSongs);
		remove(iconArray);
		grpSongs.clear();
		iconArray.clear();
		grpSongs = new FlxTypedGroup<Alphabet>();
		iconArray= new FlxTypedGroup<HealthIcon>();
		for (i in 0...songs.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpSongs.add(songText);
	
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;
	
				// using a FlxGroup is too much fuss!
				iconArray.add(icon);
	
				// songText.x += 40;
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				// songText.screenCenter(X);
			}
			add(grpSongs);
			add(iconArray);
			remove(orgin);
			remove(creator);
			remove(desc);
	}
	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		if(modtab){
			orgin.text = "Origin: " + modlist.orig[curSelected];
			creator.text = "Made By: " + modlist.madeby[curSelected];
			desc.text = "Description: " + modlist.desc[curSelected];
		}
		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.members.length)
		{
			iconArray.members[i].alpha = 0.6;
		}

		iconArray.members[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}

typedef ModMeta = {
	mods:Array<String>,
	orig:Array<String>,
	madeby:Array<String>,
	desc:Array<String>
}