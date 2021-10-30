import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxCamera;

class GFGameoverSubstate extends MusicBeatSubstate {

	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

    var lePlayState:PlayState;

    var gf:FlxSprite;

    var constantResize:Float = 2/3;

    public static var redGraphic:FlxGraphic;
    var camHUD:FlxCamera;
    var retry:FlxSprite;

    public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
    {
        lePlayState = state;
        state.setOnLuas('inGameOver', true);
        super();

        Conductor.songPosition = 0;
        camHUD = new FlxCamera();
        FlxG.cameras.add(camHUD);
        FlxCamera.defaultCameras = [camHUD];

        if (redGraphic == null) {
            redGraphic = FlxG.bitmap.create(100, 100, FlxColor.RED);
            redGraphic.persist = true;
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('death/forest', 'shared'));
        bg.setGraphicSize(Std.int(bg.width * constantResize));
        bg.updateHitbox();
        add(bg);

        gf = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
        gf.frames = Paths.getSparrowAtlas('death/gf_gameover_sprite', 'shared');
        gf.animation.addByPrefix('deathLoopStart', 'GF_DIZZLE_OPENING instance 1', 24, false);
        gf.animation.addByPrefix('deathLoop', 'GF_DIZZLE_LOOP instance 1', 24, true);
        gf.animation.addByPrefix('deathConfirm', 'GF_WAKEUP instance 1', 24, false);
        gf.animation.play('deathLoopStart');
        gf.setGraphicSize(Std.int(gf.width * constantResize));
        gf.updateHitbox();
        gf.x -= gf.width * (1 - constantResize);
        gf.x += 150;
        gf.y -= gf.height * (1 - constantResize);
        gf.antialiasing = ClientPrefs.globalAntialiasing;
        add(gf);

        var hando:FlxSprite = new FlxSprite();
        hando.frames = Paths.getSparrowAtlas('death/hypnos_grabby_grabby', 'shared');
        hando.animation.addByPrefix('claw', 'hypno_claw instance 1', 24, false);
        hando.animation.addByPrefix('clawStill', 'hypno_claw_still instance 1', 24, true);
        hando.animation.play('claw');
        hando.setGraphicSize(Std.int(hando.width * 0.5));
        hando.updateHitbox();
        hando.x -= hando.width / 2; 
        hando.antialiasing = ClientPrefs.globalAntialiasing;
        // hando.y -= hando.height * (1 - constantResize);
        add(hando);

        retry = new FlxSprite(75, 300);
        retry.frames = Paths.getSparrowAtlas('death/retry', 'shared');
        retry.animation.addByPrefix('start', "gameover_start' instance 1", 24, false);
        retry.animation.addByPrefix('idle', "gameover_over instance 1", 24, true);
        retry.animation.addByPrefix('concept', 'gameover_concept instance 1', 24, false);
        retry.setGraphicSize(Std.int(retry.width * 0.5));
        retry.updateHitbox();
        add(retry);
        retry.animation.play('start');

        var redTransition:FlxSprite = new FlxSprite().loadGraphic(redGraphic);
        redTransition.setGraphicSize(1280, 720);
        redTransition.updateHitbox();
        add(redTransition);
        FlxTween.tween(redTransition, {alpha: 0}, 1.25);
    }

    override function update(elapsed:Float)
        {
            super.update(elapsed);
    
            lePlayState.callOnLuas('onUpdate', [elapsed]);
            
            if (gf.animation.curAnim.name == 'deathLoopStart' && gf.animation.curAnim.finished)
                gf.animation.play('deathLoop');

            if (retry.animation.curAnim.name == 'start' && retry.animation.curAnim.finished) {
                retry.animation.play('idle');
                retry.x -= 50;
            }
    
            if (controls.ACCEPT)
                endBullshit();
    
            if (controls.BACK)
            {
                FlxG.sound.music.stop();
                PlayState.deathCounter = 0;
                PlayState.seenCutscene = false;
    
                if (PlayState.isStoryMode)
                    MusicBeatState.switchState(new MainMenuState());
                else
                    MusicBeatState.switchState(new FreeplayState());
    
                FlxG.sound.playMusic(Paths.music('HYPNO_MENU'));
                lePlayState.callOnLuas('onGameOverConfirm', [false]);
            }
    
            /*
            if (bf.animation.curAnim.name == 'firstDeath')
            {
                if(bf.animation.curAnim.curFrame == 12)
                {
                    FlxG.camera.follow(camFollowPos, LOCKON, 1);
                    updateCamera = true;
                }
    
                if (bf.animation.curAnim.finished)
                {
                    coolStartDeath();
                    bf.startedDeath = true;
                }
            }
            */

            if (FlxG.sound.music.playing)
            {
                Conductor.songPosition = FlxG.sound.music.time;
            }
            lePlayState.callOnLuas('onUpdatePost', [elapsed]);
        }
    
        override function beatHit()
        {
            super.beatHit();
    
            //FlxG.log.add('beat');
        }
    
        var isEnding:Bool = false;
    
        function coolStartDeath(?volume:Float = 1):Void
        {
            FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
        }
    
        function endBullshit():Void
        {
            if (!isEnding)
            {
                isEnding = true;
                gf.animation.play('deathConfirm', true);
                gf.x -= 50;
                retry.animation.play('concept');
                FlxG.sound.music.stop();
                FlxG.sound.play(Paths.music(endSoundName));
                new FlxTimer().start(0.7, function(tmr:FlxTimer)
                {
                    camHUD.fade(FlxColor.BLACK, 2, false, function()
                    {
                        MusicBeatState.resetState();
                    });
                });
                lePlayState.callOnLuas('onGameOverConfirm', [true]);
            }
        }
}