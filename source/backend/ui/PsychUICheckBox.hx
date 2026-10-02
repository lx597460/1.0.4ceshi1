package backend.ui;

class PsychUICheckBox extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'checkbox_click';

	public var name:String;
	public var box:FlxSprite;
	public var text:FlxText;
	public var label(get, set):String;

	public var checked(default, set):Bool = false;
	public var onClick:Void->Void = null;

	public function new(x:Float, y:Float, label:String, ?textWid:Int = 100, ?callback:Void->Void)
	{
		super(x, y);

		box = new FlxSprite();
		boxGraphic();
		add(box);

		text = new FlxText(box.width + 4, 0, textWid, label, Std.int(8 * Language.textScale(label)));
		text.wordWrap = false;
		text.font = Paths.font(Language.pickFont(label));
		text.y += box.height/2 - text.height/2;
		text.color = UITheme.TEXT;
		add(text);

		this.onClick = callback;
	}

	public function refreshLayout()
	{
		if(box == null || !box.exists || text == null || !text.exists) return;
		text.x = box.x + box.width + 4;
		text.y = box.y + box.height / 2 - text.height / 2;
	}

	public function boxGraphic()
	{
		box.loadGraphic(UITheme.checkboxSheet(), true, 16, 16);
		box.animation.add('false', [0]);
		box.animation.add('true', [1]);
		box.animation.play('false');
	}

	public var broadcastCheckBoxEvent:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		var over:Bool = (mx >= x && mx < x + width) && (my >= y && my < y + height);
		var targetText:FlxColor = over ? FlxColor.WHITE : UITheme.TEXT;
		var targetBox:Float = over ? 1 : 0.85;
		if(text.color != targetText) text.color = FlxColor.interpolate(text.color, targetText, 0.35);
		box.alpha += (targetBox - box.alpha) * 0.35;

		if(visible && FlxG.mouse.justPressed && !PsychUIDropDownMenu.isInputBlocked(this))
		{
			if(over)
			{
				checked = !checked;
				if(onClick != null) onClick();
				if(broadcastCheckBoxEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
			}
		}
	}

	function set_checked(v:Any)
	{
		var v:Bool = (v != null && v != false);
		box.animation.play(Std.string(v));
		return (checked = v);
	}

	function get_label():String {
		return text.text;
	}
	function set_label(v:String):String {
		text.text = v;
		text.font = Paths.font(Language.pickFont(v));
		text.size = Std.int(8 * Language.textScale(v));
		text.updateHitbox();
		text.y = box.y + box.height/2 - text.height/2;
		return v;
	}
}
