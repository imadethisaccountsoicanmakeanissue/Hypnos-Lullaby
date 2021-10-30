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

        /*
        if (darkness == null) {
            darkness = FlxG.bitmap.create(100, 100, FlxColor.BLACK, true);
            darkness.persist = true;
        }

        var blackBackground:FlxSprite = new FlxSprite().loadGraphic(darkness);
        blackBackground.setGraphicSize(FlxG.width, FlxG.height);
        add(blackBackground);

        box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.play('normal', true);
		box.visible = false;
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);
        */
    }
}