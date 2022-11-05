package meta.state;

import extension.webview.WebView;
import flixel.FlxBasic;
import flixel.FlxG;

class WebviewHandler extends FlxBasic
{
    public var finishCallback:Void -> Void = null;

	public function new(file:String = '')
	{
		super();

		WebView.onClose = onClose;
		WebView.onURLChanging = onURLChanging;
		WebView.open('file:///android_asset/assets/cutscenes/' + file + '.html', false, null, ['http://exitme(.*)']);
	}

	public override function update(elapsed:Float)
	{
		for (touch in FlxG.touches.list)
		{
			if (touch.justReleased)
			{
				if (finishCallback != null) 
					finishCallback();
			}
		}

		super.update(elapsed);	
	}

	public function onClose()
	{
	 	trace('video closed lmao');

		if (finishCallback != null)
			finishCallback();
	}

	function onURLChanging(url:String) 
	{
		if (url == 'http://exitme/') 
		{
			if (finishCallback != null) 
				finishCallback();
		}

		trace('WebView is about to open: ' + url);
	}
}
