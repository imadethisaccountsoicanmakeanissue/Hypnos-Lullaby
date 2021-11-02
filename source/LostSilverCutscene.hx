import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

/**
    holy shit I think this is my first time programming a cutscene what the fuck also hi its me shubs lmfao
**/
class LostSilverCutscene extends MusicBeatState {

    var cartridgeLines:Array<Array<String>> = [
        ["Wrap it up", "stalling Staniel"],
        ["Totally a", "normal game", "I got here"],
        ["Take it", "you weirdo"],
        ["You're ugly"],
        ["Show your", "shitty viewers", "your skills"],
        ["I'm looking", "sus out here,", "take it"],
        ["Might as well", "throw it out", "instead"],
        ['Wanna listen', 'to some', 'tunes?']
    ];
    
    var globalResizeConstant:Float = 2/3;

    var cartridgeGuy:FlxSprite;
    var dialogueBox:FlxSprite;

    var dialogueGroup:FlxTypedGroup<FlxBasic>;
    var dialogueText:FlxText;
    var dialogueSelector:FlxSprite;

    var finishedSpeaking:Bool = false;
    var speakCounter:Int = 0;

    var optionsGroup:FlxTypedGroup<FlxSprite>;
    var optionsMap:Map<String, FlxSprite>;
    var list:Array<String> = ['Yes', 'No'];
    var curSelected:Int = 0;
    var isEnding:Bool = false;

    override public function create() {
        super.create();

        PreloadState.unlockedSongs[0] = true;
        FlxG.save.data.silverUnlock = true;
        FlxG.save.flush();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);

        cartridgeGuy = new FlxSprite();
        cartridgeGuy.frames = Paths.getSparrowAtlas('lostSilver/CartridgeGuy');
        cartridgeGuy.animation.addByIndices('pre', 'CartridgeGuy', [0], "", 24, false);
        cartridgeGuy.animation.addByIndices('post', 'CartridgeGuy', [1], "", 24, false);
        cartridgeGuy.animation.play('pre');
        cartridgeGuy.scrollFactor.set();
        cartridgeGuy.alpha = 0;

        cartridgeGuy.setGraphicSize(Std.int(cartridgeGuy.width * globalResizeConstant));
        cartridgeGuy.updateHitbox();
        cartridgeGuy.antialiasing = ClientPrefs.globalAntialiasing;
        cartridgeGuy.screenCenter(X);
        cartridgeGuy.x += 50;
        cartridgeGuy.y += 50;
        
        add(cartridgeGuy);

        // create dialogue group
        dialogueGroup = new FlxTypedGroup<FlxBasic>();

        dialogueBox = new FlxSprite();
        dialogueBox.frames = Paths.getSparrowAtlas('lostSilver/Textbox');
        dialogueBox.animation.addByPrefix('box', 'Box', 24, false);
        dialogueBox.animation.play('box');
        dialogueBox.antialiasing = ClientPrefs.globalAntialiasing;
        dialogueBox.setGraphicSize(Std.int(dialogueBox.width * globalResizeConstant));
        dialogueBox.updateHitbox();

        dialogueBox.screenCenter();
        dialogueBox.y += dialogueBox.height - 50;
        dialogueBox.alpha = 0;
        dialogueGroup.add(dialogueBox);

        dialogueText = new FlxText(dialogueBox.x + 20, dialogueBox.y + 20, 0, '', 32);
        dialogueText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        dialogueText.antialiasing = ClientPrefs.globalAntialiasing;
        dialogueText.alpha = 0;
        dialogueGroup.add(dialogueText);

        // add the dialogue group
        add(dialogueGroup);

        FlxTween.tween(cartridgeGuy, {alpha: 1}, 3);
        dialogueGroup.forEach(function(dialogue:FlxBasic){
            FlxTween.tween(dialogue, {alpha: 1}, 1);
        });

        optionsGroup = new FlxTypedGroup<FlxSprite>();
        optionsMap = new Map<String, FlxSprite>();
        for (i in 0...list.length) {
            var newSprite:FlxSprite = new FlxSprite();
            newSprite.frames = Paths.getSparrowAtlas('lostSilver/${list[i]}');
            newSprite.animation.addByPrefix(list[i], list[i], 24, false);
            newSprite.animation.play(list[i]);
            newSprite.antialiasing = ClientPrefs.globalAntialiasing;
            newSprite.alpha = 0;
            optionsGroup.add(newSprite);
            
            newSprite.setGraphicSize(Std.int(newSprite.width * globalResizeConstant));
            newSprite.updateHitbox();
            newSprite.x = dialogueBox.x + 40 + (i * (dialogueBox.width - newSprite.width - 80));
            newSprite.y = dialogueBox.y + dialogueBox.height - (newSprite.height + 20);
            // save to identifier
            optionsMap.set(list[i], newSprite);
        }

        dialogueSelector = new FlxSprite();
        dialogueSelector.frames = Paths.getSparrowAtlas('lostSilver/OptionTriangle');
        dialogueSelector.animation.addByPrefix('OptionTriangle', 'OptionTriangle', 12, true);
        dialogueSelector.animation.play('OptionTriangle');
        dialogueSelector.antialiasing = ClientPrefs.globalAntialiasing;
        dialogueSelector.setGraphicSize(Std.int(dialogueSelector.width * globalResizeConstant));
        dialogueSelector.updateHitbox();
        dialogueSelector.alpha = 0;
        // position the dialogue selector
        dialogueSelector.setPosition(optionsMap[list[curSelected]].x - (dialogueSelector.width + 5), 
            optionsMap[list[curSelected]].y + (dialogueSelector.height / 3)); 
        optionsGroup.add(dialogueSelector);

        add(optionsGroup);
        extraTimer = new FlxTimer();
    }

    var initialLines:Array<String> = ['Hello player,', 'want a free', 'videogame?'];

    var loopTimes = 0;
    var currentlyTalking:Bool = false;
    var falseText:String = '';
    var extraTimer:FlxTimer;

    var startFading:Bool = false;

    var flips:Int = 1;
    override function update(elapsed:Float) {
        super.update(elapsed);
        // this is such a fucking mess lmfao
        if (!finishedSpeaking) {
            // update speaking
            if (!currentlyTalking && initialLines[speakCounter] != null && dialogueText.alpha == 1 && !extraTimer.active) {
                var newLine:String = initialLines[speakCounter];
                var textSplit:Array<String> = newLine.split("");
                trace(textSplit);
                currentlyTalking = true;
                var coolNewTimer:FlxTimer = new FlxTimer().start(0.0625, function(completed:FlxTimer){
                    falseText += textSplit[loopTimes];
                    FlxG.sound.play(Paths.sound('cartridgeGuy'), 0.2);
                    // alternating flips
                    flips = -flips;
                    dialogueBox.screenCenter(X);
                    dialogueBox.x += flips;
                    loopTimes++;
                    if (loopTimes == initialLines[speakCounter].length) {
                        falseText += '\n';
                        loopTimes = 0;
                        currentlyTalking = false;
                        dialogueBox.screenCenter(X);
                        // delay it a bit
                        if (speakCounter == 0) {
                            extraTimer.start(1, function(time:FlxTimer){
                                // update anim
                                cartridgeGuy.x -= 50;
                                cartridgeGuy.animation.play('post');
                                extraTimer.cancel();
                            });
                        } 
                        speakCounter++;
                    }
                    // always remember to use \n at the end of your text or else the last line wont display! -ya girl shubs B)
                    dialogueText.text = falseText + '\n';
                    dialogueText.screenCenter(X);
                }, initialLines[speakCounter].length);
            } else if (initialLines[speakCounter] == null)
                finishedSpeaking = true;
        } else {
            if (!isEnding) {
                if (!startFading) {
                    // create options timer
                    var optionsTimer:FlxTimer = new FlxTimer().start(1, function(completed:FlxTimer){
                        optionsGroup.forEach(function(dialogue:FlxBasic){
                            FlxTween.tween(dialogue, {alpha: 1}, 1);
                        });
                        var dialogueTimer:FlxTimer = new FlxTimer().start(10, generateNewDialogue);
                    });
                    startFading = true;
                } else {
                    // options n shit
                    var selectedWithinThisFrame:Bool = false;
                    if (dialogueSelector.alpha > 0.3) {
                        var controlArray:Array<Bool> = [controls.UI_LEFT_P, false, controls.UI_RIGHT_P];
                        if (controlArray.contains(true)) {
                            for (i in 0...controlArray.length) {
                                if (controlArray[i] == true && !selectedWithinThisFrame) {
                                    curSelected += i - 1;
                                    if (curSelected < 0)
                                        curSelected = 1;
                                    else if (curSelected > 1) 
                                        curSelected = 0;
    
                                    dialogueSelector.setPosition(optionsMap[list[curSelected]].x - (dialogueSelector.width + 5), 
                                        optionsMap[list[curSelected]].y + (dialogueSelector.height / 3)); 
                                    FlxG.sound.play(Paths.sound('HoverSFX'), 0.3);
                                    selectedWithinThisFrame = true;
                                }
                            }
                            //
                        }
                    }
                    // inputs
                    if (controls.ACCEPT) {
                        FlxG.sound.play(Paths.sound('selector${list[curSelected]}'), 0.3);
                        var fadeTime:Float = 2;
                        switch (list[curSelected]) {
                            case 'Yes':
                                var noTimer:FlxTimer = new FlxTimer().start(fadeTime + 1, function(timer:FlxTimer){
                                    // Nevermind that's stupid lmao
								    PlayState.storyPlaylist = ["Monochrome"];
								    PlayState.isStoryMode = true;
								    PlayState.storyDifficulty = 2;

								    PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
								    PlayState.storyWeek = 1;
								    PlayState.campaignScore = 0;
								    PlayState.campaignMisses = 0;
								    new FlxTimer().start(0.5, function(tmr:FlxTimer)
								    {
									    LoadingState.loadAndSwitchState(new PlayState());
									    FlxG.sound.music.volume = 0;
									    FreeplayState.destroyFreeplayVocals();
								    });
                                });
                            case 'No':
                                var noTimer:FlxTimer = new FlxTimer().start(fadeTime, function(timer:FlxTimer){
                                    MusicBeatState.switchState(new MainMenuState());
                                });
                                FlxTween.tween(FlxG.camera, {zoom: 0.05}, fadeTime);
                        }
                        
                        optionsGroup.forEach(function(dialogue:FlxBasic){
                            FlxTween.tween(dialogue, {alpha: 0}, fadeTime);
                        });
                        FlxTween.tween(cartridgeGuy, {alpha: 0}, fadeTime);
                        dialogueGroup.forEach(function(dialogue:FlxBasic){
                            FlxTween.tween(dialogue, {alpha: 0}, fadeTime);
                        });
                        isEnding = true;
                    }
    
                }
            }
        }
    }

    var firstDialogueTimer:FlxTimer;
    var baseCounterLoopTimes:Int = 0;
    function generateNewDialogue(onComplete:FlxTimer) {
        dialogueText.text = '';
        falseText = '';
        speakCounter = 0;

        var decidedInteger:Int = FlxG.random.int(0, cartridgeLines.length - 1);

        baseCounterLoopTimes = 0;
        firstDialogueTimer = new FlxTimer().start(0.0625, function(completed:FlxTimer){
            var newLine:String = cartridgeLines[decidedInteger][speakCounter];
            var textSplit:Array<String> = newLine.split("");

            loopTimes = 0;
            var coolerNewTimer:FlxTimer = new FlxTimer().start(0.0625, function(completed:FlxTimer){
                falseText += textSplit[loopTimes];
                FlxG.sound.play(Paths.sound('cartridgeGuy'), 0.2);
                flips = -flips;
                dialogueBox.screenCenter(X);
                dialogueBox.x += flips;
                loopTimes++;
                if (loopTimes == cartridgeLines[decidedInteger][speakCounter].length) {
                    falseText += '\n';
                    loopTimes = 0;
                    currentlyTalking = false;
                    dialogueBox.screenCenter(X);
                    speakCounter++;
                    //reactivate first dialogue timer
                    firstDialogueTimer.active = true;
                }
                dialogueText.text = falseText + '\n';
                dialogueText.screenCenter(X);
            }, cartridgeLines[decidedInteger][speakCounter].length); 
            firstDialogueTimer.active = false;
            baseCounterLoopTimes++;
            if (baseCounterLoopTimes == cartridgeLines[decidedInteger].length)
                var newestTimer:FlxTimer = new FlxTimer().start(20, generateNewDialogue);
        }, cartridgeLines[decidedInteger].length);
    }
}