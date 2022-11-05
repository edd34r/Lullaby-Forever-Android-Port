package android;

import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSave;
import flixel.math.FlxPoint;
import haxe.Json;
import meta.MusicBeat;
import android.FlxVirtualPad;
import android.FlxHitbox;
import android.Config;

using StringTools;

class MobileControls extends MusicBeatSubState
{
	var controlItems:Array<String> = ['Right Control', 'Left Control', 'Keyboard', 'Custom', 'Hitbox'];
	var vpad:FlxVirtualPad;
	var hitbox:FlxHitbox;

	var inputVar:FlxText;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var curSelected:Int = 0;
	var buttonIsTouched:Bool = false;
	var bindButton:flixel.ui.FlxButton;
	var config:Config;

	public function new()
	{
		super();

		config = new Config();

		var sleft:FlxSprite = new FlxSprite(78, 120);
		sleft.frames = Paths.getSparrowAtlas('menus/options/S Unown');
		sleft.animation.addByPrefix('idle', 'S Unown', 24, true);
		sleft.animation.play('idle');
		sleft.updateHitbox();
		add(sleft);

		var sright:FlxSprite = new FlxSprite(916, 335);
		sright.frames = Paths.getSparrowAtlas('menus/options/S Unown');
		sright.animation.addByPrefix('idle', 'S Unown', 24, true);
		sright.animation.play('idle');
		sright.updateHitbox();
		add(sright);

		var uUnown:FlxSprite = new FlxSprite(850, 50);
		uUnown.frames = Paths.getSparrowAtlas('menus/options/U Unown');
		uUnown.animation.addByPrefix('idle', 'U Unown', 24, true);
		uUnown.animation.play('idle');
		uUnown.updateHitbox();
		add(uUnown);

		vpad = new FlxVirtualPad(RIGHT_FULL, NONE);
		vpad.alpha = 0;
		this.add(vpad);

		hitbox = new FlxHitbox();
		hitbox.visible = false;
		add(hitbox);

		inputVar = new FlxText(0, 30, 0, controlItems[0], 48);
		inputVar.setFormat('assets/android/menu/esewe.ttf', 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		inputVar.borderSize = 0;
		add(inputVar);
		
		var arrowsFrame = FlxAtlasFrames.fromSparrow('assets/android/menu/arrows.png', 'assets/android/menu/arrows.xml');
		leftArrow = new FlxSprite(0, inputVar.y - 15);
		leftArrow.frames = arrowsFrame;
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', 'arrow push left');
		leftArrow.animation.play('idle');
		add(leftArrow);

		rightArrow = new FlxSprite(0, leftArrow.y);
		rightArrow.frames = arrowsFrame;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24, false);
		rightArrow.animation.play('idle');
		add(rightArrow);

		var descTxt:FlxText = new FlxText(5, FlxG.height - 25, 0, 'Press BACK to return to the options.', 20);
		descTxt.setFormat('assets/android/menu/esewe.ttf', 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descTxt.borderSize = 0;
		add(descTxt);

		curSelected = config.getcontrolmode();

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var androidBack:Bool = HSys.androidBack() || controls.BACK;

		if (controls.LEFT_P)
			changeSelection(-1);
		else if (controls.RIGHT_P)
			changeSelection(1);

		if (androidBack)
		{
			save();
			FlxG.switchState(new meta.state.menus.OptionsMenuState());
		}
		
		for (touch in FlxG.touches.list)
		{
			if (touch.overlaps(leftArrow) && touch.justPressed)
				changeSelection(-1);
			else if (touch.overlaps(rightArrow) && touch.justPressed)
				changeSelection(1);

			trackButton(touch);
		}
	}

	function changeSelection(change:Int = 0,?forceChange:Int)
	{
		curSelected += change;
	
		if (curSelected < 0)
			curSelected = controlItems.length - 1;
		if (curSelected >= controlItems.length)
			curSelected = 0;
	
		if (forceChange != null)
			curSelected = forceChange;
	
		inputVar.text = controlItems[curSelected];
		inputVar.screenCenter(X);
		leftArrow.x = inputVar.x - 60;
		rightArrow.x = inputVar.x + inputVar.width + 10;

		if (forceChange != null)
		{
			if (curSelected == 2)
				vpad.visible = true;
			return;
		}
			
		hitbox.visible = false;
	
		switch (curSelected)
		{
			case 0:
				this.remove(vpad);
				vpad = null;
				vpad = new FlxVirtualPad(RIGHT_FULL, NONE);
				vpad.alpha = 0.75;
				this.add(vpad);
			case 1:
				this.remove(vpad);
				vpad = null;
				vpad = new FlxVirtualPad(FULL, NONE);
				vpad.alpha = 0.75;
				this.add(vpad);
			case 2:
				trace(2);
				vpad.alpha = 0;
			case 3:
				trace(3);
				this.add(vpad);
				vpad.alpha = 0.75;
				loadcustom();
			case 4:
				remove(vpad);
				vpad.alpha = 0;
				hitbox.visible = true;
		}
	}

	function trackButton(touch:flixel.input.touch.FlxTouch)
	{
		if (buttonIsTouched)
		{
			if (bindButton.justReleased && touch.justReleased)
			{
				bindButton = null;
				buttonIsTouched = false;
			}
			else 
				moveButton(touch, bindButton);
		}
		else 
		{
			if (vpad.buttonUp.justPressed) 
			{
				if (curSelected != 3)
					changeSelection(0, 3);

				moveButton(touch, vpad.buttonUp);
			}
			
			if (vpad.buttonDown.justPressed) 
			{
				if (curSelected != 3)
					changeSelection(0, 3);

				moveButton(touch, vpad.buttonDown);
			}

			if (vpad.buttonRight.justPressed) 
			{
				if (curSelected != 3)
					changeSelection(0, 3);

				moveButton(touch, vpad.buttonRight);
			}

			if (vpad.buttonLeft.justPressed) 
			{
				if (curSelected != 3)
					changeSelection(0, 3);

				moveButton(touch, vpad.buttonLeft);
			}
		}
	}

	function moveButton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton) 
	{
		button.x = touch.x - vpad.buttonUp.width / 2;
		button.y = touch.y - vpad.buttonUp.height / 2;

		bindButton = button;
		buttonIsTouched = true;
	}

	function save() 
	{
		config.setcontrolmode(curSelected);
		
		if (curSelected == 3)
			savecustom();
	}

	function savecustom() 
	{
		trace('saved');

		config.savecustom(vpad);
	}

	function loadcustom():Void
	{
		vpad = config.loadcustom(vpad);	
	}

	override function destroy()
	{
		super.destroy();
	}
}

class MobileDefine extends FlxSpriteGroup
{
	public var mode:ControlsGroup = HITBOX;
	public var hitbox:FlxHitbox;
	public var virtualPad:FlxVirtualPad;

	var config:Config;

	public function new() 
	{
		super();
		
		config = new Config();

		mode = getModeFromNumber(config.getcontrolmode());
		trace(config.getcontrolmode());

		switch (mode)
		{
			case VIRTUALPAD_RIGHT:
				initVirtualPad(0);
			case VIRTUALPAD_LEFT:
				initVirtualPad(1);
			case VIRTUALPAD_CUSTOM:
				initVirtualPad(2);
			case HITBOX:
				hitbox = new FlxHitbox();
				add(hitbox);
			case KEYBOARD:
		}
	}

	function initVirtualPad(vpadMode:Int) 
	{
		switch (vpadMode)
		{
			case 1:
				virtualPad = new FlxVirtualPad(FULL, NONE);
			case 2:
				virtualPad = new FlxVirtualPad(FULL, NONE);
				virtualPad = config.loadcustom(virtualPad);
			default:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
		}
		
		virtualPad.alpha = 0.75;
		add(virtualPad);	
	}

	public static function getModeFromNumber(modeNum:Int):ControlsGroup 
	{
		return switch (modeNum)
		{
			case 0: 
				VIRTUALPAD_RIGHT;
			case 1: 
				VIRTUALPAD_LEFT;
			case 2: 
				KEYBOARD;
			case 3: 
				VIRTUALPAD_CUSTOM;
			case 4:	
				HITBOX;
			default: 
				VIRTUALPAD_RIGHT;
		}
	}
}

enum ControlsGroup 
{
	VIRTUALPAD_RIGHT;
	VIRTUALPAD_LEFT;
	KEYBOARD;
	VIRTUALPAD_CUSTOM;
	HITBOX;
}