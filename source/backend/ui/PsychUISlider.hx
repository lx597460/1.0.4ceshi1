package backend.ui;

import flixel.util.FlxSpriteUtil;

class PsychUISlider extends FlxSpriteGroup
{
	public static final CHANGE_EVENT = "slider_change";
	public var bar:FlxSprite;
	public var minText:FlxText;
	public var maxText:FlxText;
	public var valueText:FlxText;
	public var handle:FlxSprite;
	public var label(get, set):String;
	public var labelText:FlxText;

	public var value(default, set):Float = 0;
	public var onChange:Float->Void;
	public var step:Float = 0;
	public var min(default, set):Float = -999;
	public var max(default, set):Float = 999;
	public var decimals(default, set):Int = 2;
	public function new(x:Float = 0, y:Float = 0, callback:Float->Void, def:Float = 0, min:Float = -999, max:Float = 999, wid:Float = 200, mainColor:FlxColor = UITheme.ACCENT, handleColor:FlxColor = UITheme.TEXT)
	{
		super(x, y);
		this.onChange = callback;

		bar = new FlxSprite().makeGraphic(Std.int(wid), 6, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRoundRect(bar, 0.5, 0.5, wid - 1, 5, 3, 3, FlxColor.WHITE);
		bar.updateHitbox();
		bar.color = mainColor;
		add(bar);

		minText = new FlxText(0, 0, 80, '', 8);
		minText.alignment = CENTER;
		minText.color = mainColor;
		add(minText);
		maxText = new FlxText(0, 0, 80, '', 8);
		maxText.alignment = CENTER;
		maxText.color = mainColor;
		add(maxText);
		valueText = new FlxText(0, 0, 80, '', 8);
		valueText.alignment = CENTER;
		valueText.color = handleColor;
		add(valueText);
		labelText = new FlxText(0, 0, wid, '', 8);
		labelText.alignment = CENTER;
		add(labelText);

		handle = new FlxSprite().makeGraphic(11, 11, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCircle(handle, 5.5, 5.5, 5, FlxColor.WHITE);
		handle.updateHitbox();
		handle.color = handleColor;
		add(handle);

		this.min = min;
		this.max = max;
		this.value = def;
		_updatePositions();
		forceNextUpdate = true;
	}

	public var movingHandle:Bool = false;
	public var forceNextUpdate:Bool = false;
	public var broadcastSliderEvent:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.mouse.justMoved || FlxG.mouse.justPressed || forceNextUpdate)
		{
			forceNextUpdate = false;
			if(FlxG.mouse.justPressed && !PsychUIDropDownMenu.isInputBlocked(this) && (FlxG.mouse.overlaps(bar, camera) || FlxG.mouse.overlaps(handle, camera)))
				movingHandle = true;

			if(movingHandle)
			{
				var lastValue:Float = FlxMath.roundDecimal(value, decimals);
				var raw:Float = FlxMath.remapToRange(FlxG.mouse.getPositionInCameraView(camera).x, bar.x, bar.x + bar.width, min, max);
				if(step > 0) raw = Math.round(raw / step) * step;
				value = Math.max(min, Math.min(max, raw));
				if(this.onChange != null && lastValue != value)
				{
					this.onChange(FlxMath.roundDecimal(value, decimals));
					if(broadcastSliderEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
				}
			}
		}

		if(FlxG.mouse.released)
			movingHandle = false;
	}

	function _updatePositions()
	{
		minText.x = bar.x - minText.width/2;
		maxText.x = bar.x + bar.width - maxText.width/2;
		valueText.x = bar.x + bar.width/2 - valueText.width/2;

		labelText.x = bar.x + bar.width/2 - labelText.width/2;
		if(label.length > 0) bar.y = labelText.y + 24;

		minText.y = maxText.y = valueText.y = bar.y + 12;

		_updateHandleX();
		handle.y = bar.y + bar.height/2 - handle.height/2;
	}

	function _updateHandleX()
		handle.x = bar.x - handle.width/2 + ((max == min) ? 0 : FlxMath.remapToRange(FlxMath.roundDecimal(value, decimals), min, max, 0, bar.width));

	function set_decimals(v:Int)
	{
		decimals = v;
		minText.text = Std.string(FlxMath.roundDecimal(min, decimals));
		maxText.text = Std.string(FlxMath.roundDecimal(max, decimals));
		valueText.text = Std.string(FlxMath.roundDecimal(value, decimals));
		if(this.onChange != null) this.onChange(FlxMath.roundDecimal(value, decimals));
		_updatePositions();
		return decimals;
	}

	function set_min(v:Float)
	{
		if(v > max) max = v;
		min = v;
		minText.text = Std.string(FlxMath.roundDecimal(min, decimals));
		_updateHandleX();
		return min;
	}

	function set_max(v:Float)
	{
		if(v < min) min = v;
		max = v;
		maxText.text = Std.string(FlxMath.roundDecimal(max, decimals));
		_updateHandleX();
		return max;
	}

	function set_value(v:Float)
	{
		value = Math.max(min, Math.min(max, v));
		valueText.text = Std.string(FlxMath.roundDecimal(value, decimals));
		_updateHandleX();
		return value;
	}

	function set_label(v:String)
	{
		labelText.text = v;
		labelText.size = Std.int(8 * Language.textScale(v));
		_updatePositions();
		return labelText.text;
	}
	function get_label()
		return labelText.text;
}
