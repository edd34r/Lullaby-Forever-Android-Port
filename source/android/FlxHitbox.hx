package android;

import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import flixel.FlxSprite;

class FlxHitbox extends FlxSpriteGroup
{
    public var hitbox:FlxSpriteGroup;
    public var buttonLeft:FlxButton;
    public var buttonDown:FlxButton;
    public var buttonUp:FlxButton;
    public var buttonRight:FlxButton;
    public var buttonSpace:FlxButton;

    var hitboxGraphic:String = '';
    var spaceButton:Bool = false;
    var spaceBind:Bool = false;
    
    public function new()
    {
        super();

        var hitSetting:String = Init.trueSettings.get('Hitbox Alpha');
        var hitType:String = Init.trueSettings.get('Hitbox Type');

        switch (hitType)
        {
            case 'Up': 
                Main.isUp = true;
                Main.isDown = false;
            case 'Virtual Pad':
                Main.isUp = false;
                Main.isDown = false;
            case 'Down':
                Main.isUp = false;
                Main.isDown = true;
        }

        hitboxGraphic = 'hitbox';
        spaceButton = false;
        spaceBind = false;

        if (Main.isHypno) // buuu
        {
            if (Main.isUp)
                hitboxGraphic = 'hitboxhypno0';
            else if (Main.isDown)
                hitboxGraphic = 'hitboxhypno1';
            spaceButton = true;
            spaceBind = false;
        }

        if (Main.isBronzong)
        {
            hitboxGraphic = 'hitboxbronzong';
            spaceButton = false;
            spaceBind = true;
        }
        
        var hint:FlxSprite = new FlxSprite();
        hint.loadGraphic('assets/android/' + hitboxGraphic + '.png');
        add(hint);

		switch (hitSetting)
		{
			case '50':
                hint.alpha = 0.5;
            case '40':
                hint.alpha = 0.4;
            case '30':
                hint.alpha = 0.3;
            case '20':
                hint.alpha = 0.2;
            case '10':
                hint.alpha = 0.1;
            case '0':
                hint.alpha = 0;
		}

        hitbox = new FlxSpriteGroup();
        hitbox.scrollFactor.set();

        if (spaceButton)
        {
            if (Main.isUp)
            {
                hitbox.add(add(buttonLeft = createHitbox(0, 160, 'left')));
                hitbox.add(add(buttonDown = createHitbox(320, 160, 'down')));
                hitbox.add(add(buttonUp = createHitbox(640, 160, 'up')));
                hitbox.add(add(buttonRight = createHitbox(960, 160, 'right')));
                hitbox.add(add(buttonSpace = createHitbox(0, 0, 'space')));
            }
            else if (Main.isDown)
            {
                hitbox.add(add(buttonLeft = createHitbox(0, 0, 'left')));
                hitbox.add(add(buttonDown = createHitbox(320, 0, 'down')));
                hitbox.add(add(buttonUp = createHitbox(640, 0, 'up')));
                hitbox.add(add(buttonRight = createHitbox(960, 0, 'right')));
                hitbox.add(add(buttonSpace = createHitbox(0, 560, 'space')));
            }
        }
        else if (spaceBind)
        {
            hitbox.add(add(buttonLeft = createHitbox(0, 0, 'left')));
            hitbox.add(add(buttonDown = createHitbox(256, 0, 'down')));
            hitbox.add(add(buttonSpace = createHitbox(512, 0, 'space')));
            hitbox.add(add(buttonUp = createHitbox(768, 0, 'up')));
            hitbox.add(add(buttonRight = createHitbox(1024, 0, 'right')));
        }
        else
        {
            hitbox.add(add(buttonLeft = createHitbox(0, 0, 'left')));
            hitbox.add(add(buttonDown = createHitbox(320, 0, 'down')));
            hitbox.add(add(buttonUp = createHitbox(640, 0, 'up')));
            hitbox.add(add(buttonRight = createHitbox(960, 0, 'right')));
        }
    }

    public function createHitbox(x:Float, y:Float, frameString:String) 
    {
        var button = new FlxButton(x, y);
        var frames = FlxAtlasFrames.fromSparrow('assets/android/' + hitboxGraphic + '.png', 'assets/android/' + hitboxGraphic + '.xml');
        var graphic:FlxGraphic = FlxGraphic.fromFrame(frames.getByName(frameString));

        button.loadGraphic(graphic);
        button.alpha = 0;
        button.onDown.callback = function (){
            FlxTween.num(0, 0.75, .075, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        };
        button.onUp.callback = function (){
            FlxTween.num(0.75, 0, .1, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        }
        button.onOut.callback = function (){
            FlxTween.num(button.alpha, 0, .2, {ease: FlxEase.circInOut}, function (a:Float) { button.alpha = a; });
        }

        return button;
    }

    override public function destroy():Void
    {
        super.destroy();
    
        buttonLeft = null;
        buttonDown = null;
        buttonUp = null;
        buttonRight = null;
        if (spaceButton || spaceBind) buttonSpace = null;
    }
}