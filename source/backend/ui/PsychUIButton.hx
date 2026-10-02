package backend.ui;

import backend.ui.PsychUIBox.UIStyleData;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class PsychUIButton extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'button_click';

	public var name:String;
	public var label(default, set):String;
	public var bg:FlxSprite;
	public var text:FlxText;

	public var onChangeState:String->Void;
	public var onClick:Void->Void;

	public var clickStyle:UIStyleData = {
		bgColor: UITheme.BTN_DOWN,
		textColor: FlxColor.WHITE,
		bgAlpha: 1
	};
	public var hoverStyle:UIStyleData = {
		bgColor: UITheme.BTN_HOVER,
		textColor: FlxColor.WHITE,
		bgAlpha: 1
	};
	public var normalStyle:UIStyleData = {
		bgColor: UITheme.BTN,
		textColor: UITheme.TEXT,
		bgAlpha: 1
	};

	var _bgWidth:Int = 0;
	var _bgHeight:Int = 0;
	var _borderSpr:FlxSprite;
	var _targetFill:FlxColor;
	var _targetAlpha:Float = 1;
	var _targetText:FlxColor;
	var _pressed:Bool = false;

	public function new(x:Float = 0, y:Float = 0, label:String = '', ?onClick:Void->Void = null, ?wid:Int = 80, ?hei:Int = 20)
	{
		super(x, y);
		_borderSpr = new FlxSprite();
		add(_borderSpr);
		bg = new FlxSprite();
		add(bg);

		text = new FlxText(0, 0, 1, '', 8);
		text.alignment = CENTER;
		text.wordWrap = false;
		add(text);
		resize(wid, hei);
		bg.color = normalStyle.bgColor;
		bg.alpha = 1;
		text.color = normalStyle.textColor;
		_targetFill = normalStyle.bgColor;
		_targetText = normalStyle.textColor;
		this.label = label;

		this.onClick = onClick;
		forceCheckNext = true;
	}

	public var isClicked:Bool = false;
	public var forceCheckNext:Bool = false;
	public var broadcastButtonEvent:Bool = true;
	var _firstFrame:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(_firstFrame)
		{
			applyStyle(normalStyle);
			_firstFrame = false;
		}

		if(isClicked && FlxG.mouse.released)
		{
			forceCheckNext = true;
			isClicked = false;
		}

		if(forceCheckNext || FlxG.mouse.justMoved || FlxG.mouse.justPressed)
		{
			var mx:Float = FlxG.mouse.gameX;
			var my:Float = FlxG.mouse.gameY;
			var overlapped:Bool = (mx >= bg.x && mx <= bg.x + bg.width && my >= bg.y && my <= bg.y + bg.height);

			forceCheckNext = false;

			if(!isClicked)
			{
				applyStyle(overlapped ? hoverStyle : normalStyle);
				_pressed = false;
				positionText();
			}

			if(overlapped && visible && FlxG.mouse.justPressed && !PsychUIDropDownMenu.isInputBlocked(this))
			{
				isClicked = true;
				applyStyle(clickStyle, true);
				_pressed = true;
				positionText();
				if(onClick != null) onClick();
				if(broadcastButtonEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
			}
		}

		if(bg.color != _targetFill || bg.alpha != _targetAlpha)
		{
			bg.color = FlxColor.interpolate(bg.color, _targetFill, 0.35);
			bg.alpha += (_targetAlpha - bg.alpha) * 0.35;
		}
		if(text.color != _targetText)
			text.color = FlxColor.interpolate(text.color, _targetText, 0.35);
	}

	function applyStyle(style:UIStyleData, snap:Bool = false)
	{
		_targetFill = style.bgColor;
		_targetAlpha = style.bgAlpha;
		_targetText = style.textColor;
		if(snap)
		{
			bg.color = _targetFill;
			bg.alpha = _targetAlpha;
			text.color = _targetText;
		}
	}

	public function refreshLayout()
	{
		if(bg == null || !bg.exists || text == null || !text.exists) return;
		text.fieldWidth = Std.int(bg.width);
		text.updateHitbox();
		positionText();
	}

	function positionText()
	{
		if(bg == null || !bg.exists || text == null || !text.exists) return;
		text.x = bg.x;
		text.y = bg.y + bg.height / 2 - text.height / 2 + (_pressed ? 1 : 0);
	}

	public function resize(width:Int, height:Int)
	{
		width = Std.int(Math.max(4, width));
		height = Std.int(Math.max(4, height));
		if(width != _bgWidth || height != _bgHeight || bg.pixels == null)
		{
			_bgWidth = width;
			_bgHeight = height;
			bg.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawRoundRect(bg, 0.5, 0.5, width - 1, height - 1, 4, 4, FlxColor.WHITE);
			_borderSpr.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawRoundRect(_borderSpr, 0.5, 0.5, width - 1, height - 1, 4, 4, FlxColor.TRANSPARENT, {thickness: 1, color: UITheme.BORDER});
		}
		text.fieldWidth = width;
		text.updateHitbox();
		positionText();
	}

	function set_label(v:String)
	{
		if(text != null && text.exists)
		{
			text.text = v;
			text.font = Paths.font(Language.pickFont(v));
			text.size = Std.int(8 * Language.textScale(v));
			text.updateHitbox();
			if(bg != null && bg.pixels != null)
			{
				text.fieldWidth = bg.width;
				positionText();
			}
		}
		return (label = v);
	}
}
