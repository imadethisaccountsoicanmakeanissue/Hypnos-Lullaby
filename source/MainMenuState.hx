package;

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
	
	var optionShit:Array<String> = ['story', 'freeplay', 'credits', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

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
			var newAlphabet:Alphabet = new Alphabet(0, 50 + ((i + 1) * 100), optionShit[i], true);
			newAlphabet.x = 30;
			newAlphabet.alpha = 0.6;
			newAlphabet.ID = i;
			menuItems.add(newAlphabet);
		}

		menuItems.members[curSelected].alpha = 1;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		updateSelection();

		super.create();
	}

	var selectedSomethin:Bool = false;

	/*
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		// var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		// camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (controls.UP) {

		}
		if (controls.DOWN) {

		}
	}
	*/

	var lastCurSelected:Int = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);
	
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];
	
		if ((controlArray.contains(true)) && (!selectedSomethin))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							curSelected--;
						else if (i == 3)
							curSelected++;
	
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					/* idk something about it isn't working yet I'll rewrite it later
							else
							{
								// paaaaaaaiiiiiiiinnnn
								var curDir:Int = 0;
								if (i == 0)
									curDir = -1;
								else if (i == 1)
									curDir = 1;
	
								if (counterControl < 2)
									counterControl += 0.05;
	
								if (counterControl >= 1)
								{
									curSelected += (curDir * (counterControl / 24));
									if (curSelected % 1 == 0)
										FlxG.sound.play(Paths.sound('scrollMenu'));
								}
						}*/
	
					if (curSelected < 0)
						curSelected = optionShit.length - 1;
					else if (curSelected >= optionShit.length)
						curSelected = 0;
				}
				//
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
	
						switch (daChoice)
						{
							case 'story':
								MusicBeatState.switchState(new StoryMenuState());
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
	
		super.update(elapsed);
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
