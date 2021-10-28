import flixel.graphics.FlxGraphic;
import sys.thread.Thread;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

enum PreloadType {
    atlas;
    image;
}

class PreloadState extends FlxState {

    var globalRescale:Float = 2/3;
    var preloadStart:Bool = false;

    var loadText:FlxText;
    var assetStack:Map<String, PreloadType> = [
        'hypno/Hypno bg background' => PreloadType.image, 
        'hypno/Hypno bg midground' => PreloadType.image, 
        'hypno/Hypno bg foreground' => PreloadType.image,
        'gf' => PreloadType.atlas,
        'hypno' => PreloadType.atlas,
        'hypno-two' => PreloadType.atlas,
    ];
    var maxCount:Int;

    public static var preloadedAssets:Map<String, FlxGraphic>;
    var backgroundGroup:FlxTypedGroup<FlxSprite>;
    var bg:FlxSprite;

    public static var unlockedSongs:Array<Bool> = [false, false];

    override public function create() {
        super.create();

        maxCount = Lambda.count(assetStack);
        trace(maxCount);
        // create funny assets
        backgroundGroup = new FlxTypedGroup<FlxSprite>();
        FlxG.mouse.visible = false;

        preloadedAssets = new Map<String, FlxGraphic>();

        var unownBg:FlxSprite = new FlxSprite();
		unownBg.loadGraphic(Paths.image('Loading Unown'));
        unownBg.setGraphicSize(Std.int(unownBg.width * globalRescale));
        unownBg.updateHitbox();
		unownBg.alpha = 0;
		backgroundGroup.add(unownBg);

        bg = new FlxSprite();
		bg.loadGraphic(Paths.image('Loading Hypno'));
        bg.setGraphicSize(Std.int(bg.width * globalRescale));
        bg.updateHitbox();
		bg.alpha = 0;
		backgroundGroup.add(bg);

        var gfBg:FlxSprite = new FlxSprite();
		gfBg.loadGraphic(Paths.image('Loading GF'));
        gfBg.setGraphicSize(Std.int(gfBg.width * globalRescale));
        gfBg.updateHitbox();
		gfBg.alpha = 0;
		backgroundGroup.add(gfBg);

        var pendulum:FlxSprite = new FlxSprite();
        pendulum.frames = Paths.getSparrowAtlas('Loading Screen Pendelum');
        pendulum.animation.addByPrefix('load', 'Loading Pendelum Finished', 24, true);
        pendulum.animation.play('load');
        pendulum.setGraphicSize(Std.int(pendulum.width * globalRescale));
        pendulum.updateHitbox();
        backgroundGroup.add(pendulum);
        pendulum.x = FlxG.width - (pendulum.width + 10);
        pendulum.y = FlxG.height - (pendulum.height + 10);

        add(backgroundGroup);
        backgroundGroup.forEach(function(spr:FlxSprite){
            FlxTween.tween(spr, {alpha: 1}, 0.5, {
                onComplete: function(tween:FlxTween){
                    if (spr == bg)
                        Thread.create(function(){
                            assetGenerate();
                        });
                }
            });
        });

        // save bullshit
        if(FlxG.save.data != null) {
            if (FlxG.save.data.silverUnlock != null)
                unlockedSongs[0] = FlxG.save.data.silverUnlock;
            if (FlxG.save.data.missingnoUnlock != null)
                unlockedSongs[1] = FlxG.save.data.missingnoUnlock;
        }

        loadText = new FlxText(5, FlxG.height - (32 + 5), 0, 'Loading...', 32);
		loadText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(loadText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    var storedPercentage:Float = 0;

    function assetGenerate() {
        //
        var countUp:Int = 0;
        for (i in assetStack.keys()) {
            trace('calling asset $i');

            FlxGraphic.defaultPersist = true;
            switch(assetStack[i]) {
                case PreloadType.image:
                    var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image(i, 'shared'));
                    preloadedAssets.set(i, savedGraphic);
                    trace(savedGraphic + ', yeah its working');
                case PreloadType.atlas:
                    var preloadedCharacter:Character = new Character(FlxG.width / 2, FlxG.height / 2, i);
                    preloadedCharacter.visible = false;
                    add(preloadedCharacter);
                    trace('character loaded ${preloadedCharacter.frames}');
            }
            FlxGraphic.defaultPersist = false;
        
            countUp++;
            storedPercentage = countUp/maxCount;
            loadText.text = 'Loading... Progress at ${Math.floor(storedPercentage * 100)}%';
        }

        ///*
        backgroundGroup.forEach(function(spr:FlxSprite){
            FlxTween.tween(spr, {alpha: 0}, 0.5, {
                onComplete: function(tween:FlxTween){
                    if (spr == bg)
                        FlxG.switchState(new TitleState());
                }
            });
        });
        //*/

    }
}