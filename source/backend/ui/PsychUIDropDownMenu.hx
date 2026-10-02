package backend.ui;

import backend.ui.PsychUIBox.UIStyleData;
import flixel.FlxSubState;

class PsychUIDropDownMenu extends PsychUIInputText
{
	public static final CLICK_EVENT = "dropdown_click";

	public var list(default, set):Array<String> = [];
	public var button:FlxSprite;
	public var onSelect:Int->String->Void;

	public static var openMenu(default, null):PsychUIDropDownMenu = null;
	public static function resetOpenMenu():Void
	{
		openMenu = null;
	}
	public var isOpen(default, null):Bool = false;

	public static function isInputBlocked(widget:Dynamic):Bool
	{
		return openMenu != null && openMenu != widget;
	}

	public var selectedIndex(default, set):Int = -1;
	public var selectedLabel(default, set):String = null;

	var _curFilter:Array<String>;
	var _itemWidth:Float = 0;
	public function new(x:Float, y:Float, list:Array<String>, callback:Int->String->Void, ?width:Float = 100)
	{
		super(x, y, 100, '', 12);
		if(list == null) list = [];

		_itemWidth = width - 2;
		setGraphicSize(width, 20);
		updateHitbox();
		textObj.y += 2;

		button = new FlxSprite(behindText.width + 1, 0).loadGraphic(UITheme.dropdownButtonSheet(), true, 20, 20);
		button.animation.add('normal', [0], false);
		button.animation.add('pressed', [1], false);
		button.animation.play('normal', true);
		add(button);

		onSelect = callback;

		onChange = null;
		unfocus = function()
		{
			showDropDownClickFix();
			showDropDown(false);
		}

		for (option in list)
			addOption(option);

		selectedIndex = 0;
		showDropDown(false);
	}

	function set_selectedIndex(v:Int)
	{
		selectedIndex = v;
		if(selectedIndex < 0 || selectedIndex >= list.length) selectedIndex = -1;

		@:bypassAccessor selectedLabel = (selectedIndex >= 0) ? list[selectedIndex] : null;
		text = (selectedLabel != null) ? selectedLabel : '';
		return selectedIndex;
	}

	function set_selectedLabel(v:String)
	{
		var id:Int = list.indexOf(v);
		if(id >= 0)
		{
			@:bypassAccessor selectedIndex = id;
			selectedLabel = v;
			text = selectedLabel;
		}
		else
		{
			@:bypassAccessor selectedIndex = -1;
			selectedLabel = null;
			text = '';
		}
		return selectedLabel;
	}

	override public function refreshLayout()
	{
		super.refreshLayout();
		textObj.y = bg.y + 3;
		if(button != null && button.exists)
		{
			button.x = behindText.x + behindText.width;
			button.y = bg.y;
		}
	}

	var _items:Array<PsychUIDropDownItem> = [];
	public var curScroll:Int = 0;
	var _inUpdate:Bool = false;
	override function update(elapsed:Float)
	{
		if(_inUpdate) return;
		_inUpdate = true;

		if(!visible && openMenu == this) showDropDown(false);
		var overButton:Bool = visible && FlxG.mouse.justPressed && FlxG.mouse.gameX >= button.x && FlxG.mouse.gameX <= button.x + button.width && FlxG.mouse.gameY >= button.y && FlxG.mouse.gameY <= button.y + button.height;
		super.update(elapsed);
		if(overButton)
		{
			button.animation.play('pressed', true);
			if(isOpen)
			{
				PsychUIInputText.focusOn = null;
				showDropDown(false);
			}
			else
			{
				PsychUIInputText.focusOn = this;
				showDropDown(true);
			}
		}
		else if(FlxG.mouse.released && button.animation.curAnim != null && button.animation.curAnim.name != 'normal') button.animation.play('normal', true);

		if(PsychUIInputText.focusOn == this)
		{
			var wheel:Int = FlxG.mouse.wheel;
			if(FlxG.keys.justPressed.UP) wheel++;
			if(FlxG.keys.justPressed.DOWN) wheel--;
			if(wheel != 0) showDropDown(true, curScroll - wheel, _curFilter);
		}
		else if(isOpen && PsychUIInputText.focusOn != this) showDropDown(false);

		_inUpdate = false;
	}

	private function showDropDownClickFix()
	{
		if(FlxG.mouse.justPressed)
		{
			for (item in _items) //extra update to fix a little bug where it wouldnt click on any option if another input text was behind the drop down
				if(item != null && item.active && item.visible)
					item.update(0);
		}
	}

	public function isMouseOverOpenArea(cam:FlxCamera):Bool
	{
		if(cam == null) return false;
		if(button != null && button.exists && FlxG.mouse.overlaps(button, cam)) return true;
		if(bg == null || !bg.exists) return false;
		return FlxG.mouse.overlaps(bg, cam);
	}

	public function showDropDown(vis:Bool = true, scroll:Int = 0, onlyAllowed:Array<String> = null)
	{
		if(vis)
		{
			if(openMenu != null && openMenu != this) openMenu.showDropDown(false);
			openMenu = this;
			isOpen = true;
		}
		else
		{
			isOpen = false;
			if(openMenu == this) openMenu = null;
		}

		if(!vis)
		{
			text = selectedLabel;
			_curFilter = null;
		}

		curScroll = Std.int(Math.max(0, Math.min(onlyAllowed != null ? (onlyAllowed.length - 1) : (list.length - 1), scroll)));
		if(vis)
		{
			var n:Int = 0;
			for (item in _items)
			{
				var match:Bool = (onlyAllowed == null) || onlyAllowed.contains(item.label);
				item.active = item.visible = (match && n >= curScroll);
				if(match) n++;
			}

			var visItems:Array<PsychUIDropDownItem> = [];
			for (item in _items)
				if(item.visible) visItems.push(item);

			var txtY:Float = behindText.y + behindText.height + 1;
			var totalH:Float = 0;
			for (item in visItems)
				totalH += item.height;

			var up:Bool = (txtY + totalH > FlxG.height - 2) && (behindText.y - totalH - 1 > 0);
			if(up)
			{
				var uy:Float = behindText.y - totalH - 1;
				for (item in visItems)
				{
					item.x = behindText.x;
					item.y = uy;
					uy += item.height;
					item.forceNextUpdate = true;
				}
				bg.scale.y = 20;
				bg.updateHitbox();
			}
			else
			{
				for (item in visItems)
				{
					item.x = behindText.x;
					item.y = txtY;
					txtY += item.height;
					item.forceNextUpdate = true;
				}
				bg.scale.y = txtY - behindText.y + 2;
				bg.updateHitbox();
			}

			var moved:Bool = false;
			var sub:FlxSubState = (FlxG.state != null && FlxG.state.subState != null) ? FlxG.state.subState : null;
			if(sub != null && sub.remove(this, true) != null)
			{
				sub.add(this);
				moved = true;
			}
			if(!moved && FlxG.state != null && FlxG.state.remove(this, true) != null)
				FlxG.state.add(this);
		}
		else
		{
			for (item in _items)
				item.active = item.visible = false;

			bg.scale.y = 20;
			bg.updateHitbox();
		}
	}

	public var broadcastDropDownEvent:Bool = true;
	function clickedOn(num:Int, label:String)
	{
		selectedIndex = num;
		showDropDown(false);
		PsychUIInputText.focusOn = null;
		if(onSelect != null) onSelect(num, label);
		if(broadcastDropDownEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
	}

	function addOption(option:String)
	{
		@:bypassAccessor list.push(option);
		var curID:Int = list.length - 1;
		var item:PsychUIDropDownItem = cast recycle(PsychUIDropDownItem, () -> new PsychUIDropDownItem(1, 1, this._itemWidth), true);
		item.cameras = cameras;
		item.label = option;
		item.visible = item.active = false;
		item.onClick = function() clickedOn(curID, option);
		item.forceNextUpdate = true;
		_items.push(item);
		insert(1, item);
	}

	function set_list(v:Array<String>)
	{
		var selected:String = selectedLabel;
		showDropDown(false);

		for (item in _items)
			item.kill();

		_items = [];
		list = [];
		for (option in v)
			addOption(option);

		if(selectedLabel != null) selectedLabel = selected;
		return v;
	}
}

class PsychUIDropDownItem extends FlxSpriteGroup
{
	public var hoverStyle:UIStyleData = {
		bgColor: UITheme.ACCENT,
		textColor: FlxColor.WHITE,
		bgAlpha: 1
	};
	public var normalStyle:UIStyleData = {
		bgColor: 0xFF232329,
		textColor: UITheme.TEXT,
		bgAlpha: 1
	};

	public var bg:FlxSprite;
	public var text:FlxText;
	public function new(x:Float = 0, y:Float = 0, width:Float = 100)
	{
		super(x, y);

		bg = new FlxSprite().makeGraphic(1, 1, normalStyle.bgColor);
		bg.setGraphicSize(width, 20);
		bg.updateHitbox();
		add(bg);

		text = new FlxText(0, 0, width, '', 10);
		text.color = normalStyle.textColor;
		add(text);
	}

	public var onClick:Void->Void;
	public var forceNextUpdate:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(FlxG.mouse.justMoved || FlxG.mouse.justPressed || forceNextUpdate)
		{
			var mx:Float = FlxG.mouse.gameX;
			var my:Float = FlxG.mouse.gameY;
			var overlapped:Bool = (mx >= bg.x && mx <= bg.x + bg.width && my >= bg.y && my <= bg.y + bg.height);

			var style = overlapped ? hoverStyle : normalStyle;
			bg.color = style.bgColor;
			text.color = style.textColor;
			bg.alpha = style.bgAlpha;
			forceNextUpdate = false;

			if(overlapped && visible && FlxG.mouse.justPressed && onClick != null)
				onClick();
		}

		text.x = bg.x;
		text.y = bg.y + bg.height/2 - text.height/2;
	}

	public var label(default, set):String;
	function set_label(v:String)
	{
		label = v;
		text.text = v;
		text.font = Paths.font(Language.pickFont(v));
		text.size = Std.int(10 * Language.textScale(v));
		bg.scale.y = text.height + 6;
		bg.updateHitbox();
		return v;
	}
}
