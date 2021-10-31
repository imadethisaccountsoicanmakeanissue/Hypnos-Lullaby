package;

import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<Alphabet>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story', 'freeplay', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	// missingno unlock values
	var isDoingKeySequence:Bool = true;
	var keySequence:Array<String> = [];
	var keySequenceProgress:Int = 0;
	var keySequenceDone:Bool = false;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		// generate key sequence dynamically
		keySequenceDone = PreloadState.unlockedSongs[1];
		keySequence = [];
		for (i in 0...3) {
			for (i in 0...2)
				keySequence.push('down');
			for (i in 0...2)
				keySequence.push('up');
		}
		trace(keySequence);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		var menuHypno:FlxSprite = new FlxSprite();
		menuHypno.frames = Paths.getSparrowAtlas('MainMenuHypno');
		menuHypno.animation.addByPrefix('bop', 'HypnoMenu', 24, true);
		menuHypno.animation.play('bop');
		menuHypno.setGraphicSize(Std.int(menuHypno.width * 5/6));
		menuHypno.updateHitbox();
		menuHypno.setPosition(FlxG.width - menuHypno.width + 100, FlxG.height - menuHypno.height + 100);
		add(menuHypno);

		for (i in 0...optionShit.length) {
			var newAlphabet:Alphabet = new Alphabet(0, 75 + ((i + 1) * 100), optionShit[i], true);
			newAlphabet.x = 30;
			newAlphabet.alpha = 0.6;
			newAlphabet.ID = i;
			menuItems.add(newAlphabet);
		}

		menuItems.members[curSelected].alpha = 1;

		FlxG.camera.follow(camFollowPos, null, 1);

		var hypnoShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Hypno's Lullaby v1.0", 12);
		hypnoShit.scrollFactor.set();
		hypnoShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(hypnoShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		hypnoShit.updateHitbox();
		versionHitbox = new FlxObject(hypnoShit.x + hypnoShit.width - 24, hypnoShit.y - 12, 24, 24);
		add(versionHitbox);

		updateSelection();

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow = new FlxSprite(FlxG.width - 650, 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 60, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);


		super.create();
	}
	var versionHitbox:FlxObject;

	var selectedSomethin:Bool = false;
	var lastCurSelected:Int = 0;
	var curDifficulty:Int = 1;

	var lastSelected:Int = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);
		if (controls.UI_RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.UI_LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		if (controls.UI_RIGHT_P)
			changeDifficulty(1);
		if (controls.UI_LEFT_P)
			changeDifficulty(-1);

		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up_p, down_p];
	
		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					if (i == 0)
						curSelected--;
					else if (i == 1)
						curSelected++;
	
					FlxG.sound.play(Paths.sound('scrollMenu'));
	
					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;

					if (!keySequenceDone) {
						if (isDoingKeySequence) {
							if ((keySequence[keySequenceProgress] == 'down' && controls.UI_DOWN_P) 
							|| (keySequence[keySequenceProgress] == 'up' && controls.UI_UP_P))
								keySequenceProgress++;
							else
								isDoingKeySequence = false;

							if (keySequenceProgress > keySequence.length - 1) {
								FlxG.sound.play(Paths.sound('correct', 'shared'));
								keySequenceDone = true;
								FlxG.mouse.visible = true;
							}
						} else if (curSelected == 0) {
							isDoingKeySequence = true;
							keySequenceProgress = 0;
						}
						trace(keySequenceProgress);
					}
					
				}
			}
		}
	
		if ((controls.ACCEPT) && (!selectedSomethin))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
	
			menuItems.forEach(function(spr:Alphabet)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];
						FlxG.mouse.visible = false;
						switch (daChoice)
						{
							case 'story':
								// Nevermind that's stupid lmao
								PlayState.storyPlaylist = ["Safety Lullaby", "Left Unchecked"];
								PlayState.isStoryMode = true;

								var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
								if (diffic == null) 
									diffic = '';

								PlayState.storyDifficulty = curDifficulty;

								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
								PlayState.storyWeek = 1;
								PlayState.campaignScore = 0;
								PlayState.campaignMisses = 0;
								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									LoadingState.loadAndSwitchState(new PlayState());
									FlxG.sound.music.volume = 0;
									FreeplayState.destroyFreeplayVocals();
								});
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
						}
					});
				}
			});
		}
	
		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();
	
		if (keySequenceDone) {
			if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(versionHitbox)) {
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				if (PreloadState.unlockedSongs[1] != true) {
					PreloadState.unlockedSongs[1] = true;
					FlxG.save.data.missingnoUnlock = true;
					FlxG.save.flush();
				}

				// Nevermind that's stupid lmao
				PlayState.storyPlaylist = ["missingno"];
				PlayState.isStoryMode = true;

				var diffic = CoolUtil.difficultyStuff[2][2];
				if (diffic == null) 
					diffic = '';

				PlayState.storyDifficulty = 2;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.storyWeek = 1;
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;

				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
					FreeplayState.destroyFreeplayVocals();
				});
			}
		}

		super.update(elapsed);
	}

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	function changeDifficulty(change:Int = 0):Void
		{
			curDifficulty += change;
	
			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficultyStuff.length-1;
			if (curDifficulty >= CoolUtil.difficultyStuff.length)
				curDifficulty = 0;
	
			sprDifficultyGroup.forEach(function(spr:FlxSprite) {
				spr.visible = false;
				if(curDifficulty == spr.ID) {
					spr.visible = true;
					spr.alpha = 0;
					spr.y = leftArrow.y - 15;
					FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
				}
			});
		}

	private function updateSelection()
	{
		// reset all selections
		menuItems.forEach(function(spr:FlxSprite) {spr.alpha = 0.6;});
		
		// set the sprites and all of the current selection
		menuItems.members[curSelected].alpha = 1;
		lastCurSelected = Math.floor(curSelected);
	}
}
