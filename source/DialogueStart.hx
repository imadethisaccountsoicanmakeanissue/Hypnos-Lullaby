import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;

class DialogueStart extends FlxSpriteGroup {

    public static var darkness:FlxGraphic;
    public var box:FlxSprite;

    public function new() {
        super();   

        if (darkness == null) {
            darkness = FlxG.bitmap.create(100, 100, FlxColor.BLACK, true);
            darkness.persist = true;
        }

        var blackBackground:FlxSprite = new FlxSprite().loadGraphic(darkness);
        blackBackground.setGraphicSize(FlxG.width, FlxG.height);
        blackBackground.updateHitbox();
        add(blackBackground);

        var centerText:Alphabet = new Alphabet(0, FlxG.height / 2, 'BF is missing, GF went out by herself looking for him worried sick...', false, true, 0.125 / 2, 1);
        centerText.setPosition(20, FlxG.height / 2 - 200);
        centerText.alpha = 0;
        add(centerText);

        var gf:FlxSprite = new FlxSprite();
        gf.frames = Paths.getSparrowAtlas('dialogue/Dialogue GF');
        gf.animation.addByPrefix('call', 'GF Sprite 1', 24, false);
        gf.animation.addByPrefix('call2', 'GF Sprite 2', 24, false);
        gf.animation.addByPrefix('disappoint', 'GF Sprite 3', 24, false);
        gf.animation.addByPrefix('shock', 'GF Sprite 4', 24, false);
        gf.animation.play('call');
        gf.setGraphicSize(Std.int(gf.width * 0.6));
        gf.updateHitbox();
        gf.alpha = 0;
        add(gf);

        box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.play('normal', true);
		box.alpha = 0;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

        gf.setPosition(box.x + box.width - (gf.width * 1.25), box.y - (gf.height / 2) + 50);

        // lmfao
        FlxTween.tween(centerText, {alpha: 1}, 0.75, {onComplete: function(tween:FlxTween){
            var newTimer:FlxTimer = new FlxTimer().start(5, function(timer:FlxTimer){
                FlxTween.tween(centerText, {alpha: 0}, 0.75, {onComplete: function(tween:FlxTween){
                    centerText.kill();
                    centerText.destroy();
                }});
                FlxTween.tween(blackBackground, {alpha: 0.5}, 2, {onComplete: function(tween:FlxTween){
                    FlxTween.tween(gf, {alpha: 1}, 0.25);
                    FlxTween.tween(box, {alpha: 1}, 0.25, {onComplete: function(tween:FlxTween){
                        var newText:Alphabet = new Alphabet(0, 0, 'Bf?', false, true, 0.1, 1);
                        newText.color = FlxColor.BLACK;
                        newText.setPosition(box.x + 20, box.y + 80);
                        add(newText);
                    }});
                }});

            });
        }});
    }
}