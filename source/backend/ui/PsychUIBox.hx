package backend.ui;

import flixel.util.FlxSpriteUtil;

typedef UIStyleData = {
	var bgColor:FlxColor;
	var textColor:FlxColor;
	var bgAlpha:Float;
}

class PsychUIBox extends FlxSpriteGroup
{
	public static final CLICK_EVENT = "uibox_click";
	public static final MINIMIZE_EVENT = "uibox_minimize"; //called on both minimizing and maximizing
	public static final DRAG_EVENT = "uibox_drag";
	public static final DROP_EVENT = "uibox_drop";
	public var tabs(default, null):Array<PsychUITab> = [];

	public var selectedTab(default, set):PsychUITab = null;
	public var selectedIndex(default, set):Int = -1;
	public var selectedName(default, set):String = null;

	public var bg:FlxSprite;
	public var borderSpr:FlxSprite;

	public var selectedStyle:UIStyleData = {
		bgColor: UITheme.BTN,
		textColor: UITheme.TEXT,
		bgAlpha: 1
	};
	public var hoverStyle:UIStyleData = {
		bgColor: UITheme.BTN_HOVER,
		textColor: UITheme.TEXT,
		bgAlpha: 1
	};
	public var unselectedStyle:UIStyleData = {
		bgColor: 0xFF1C1C20,
		textColor: UITheme.TEXT_DIM,
		bgAlpha: 1
	};

	public var canMove:Bool = true;
	public var canMinimize(default, set):Bool = true;
	public var isMinimized(default, set):Bool = false;
	public var minimizeOnFocusLost:Bool = false;
	public var canResize:Bool = true;
	public var minResizeWidth:Int = 160;
	public var minResizeHeight:Int = 80;
	static inline var RESIZE_EDGE:Int = 6;

	var _resizing:Bool = false;
	var _resizeMode:Int = 0;
	var _resizeMouseStart:FlxPoint;
	var _resizeSizeStart:FlxPoint;

	public function new(x:Float, y:Float, width:Int, height:Int, tabs:Array<String> = null)
	{
		super(x, y);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(bg);

		borderSpr = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(borderSpr);

		if(tabs != null)
		{
			for (tab in tabs)
			{
				var createdTab:PsychUITab = new PsychUITab(tab);
				this.tabs.push(createdTab);
				add(createdTab);
			}
		}

		resize(width, height);
		selectedIndex = 0;
		forceCheckNext = true;
	}

	var _draggingPos:FlxPoint;
	var _draggingPoint:FlxPoint;
	var _pressedBox:Bool = false;
	var _draggingBox:Bool = false;
	var _lastTab:PsychUITab;
	var _lastClick:Float = 0;

	public var forceCheckNext:Bool = false;
	public var broadcastBoxEvents:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_lastClick += elapsed;

		if(canResize && !isMinimized && _resizeMode == 0 && FlxG.mouse.justPressed && !_draggingBox)
		{
			var m:FlxPoint = FlxG.mouse.getPositionInCameraView(camera);
			var relX:Float = m.x - x;
			var relY:Float = m.y - y;
			if(relY > tabHeight && relX > 20)
			{
				var mode:Int = 0;
				if(relX >= bg.width - RESIZE_EDGE && relX <= bg.width + RESIZE_EDGE && relY <= bg.height + RESIZE_EDGE) mode |= 1;
				if(relY >= bg.height - RESIZE_EDGE && relY <= bg.height + RESIZE_EDGE && relX <= bg.width + RESIZE_EDGE) mode |= 2;
				if(mode != 0)
				{
					_resizeMode = mode;
					_resizing = true;
					_resizeMouseStart = FlxPoint.weak(m.x, m.y);
					_resizeSizeStart = FlxPoint.weak(bg.width, bg.height);
				}
			}
		}

		if(_resizing)
		{
			if(FlxG.mouse.released)
			{
				_resizing = false;
				_resizeMode = 0;
				if(broadcastBoxEvents) PsychUIEventHandler.event(DROP_EVENT, this);
			}
			else
			{
				var newPoint:FlxPoint = FlxG.mouse.getPositionInCameraView(camera);
				var newW:Float = bg.width;
				var newH:Float = bg.height;
				if((_resizeMode & 1) != 0) newW = _resizeSizeStart.x + (newPoint.x - _resizeMouseStart.x);
				if((_resizeMode & 2) != 0) newH = _resizeSizeStart.y + (newPoint.y - _resizeMouseStart.y);
				newW = Math.max(minResizeWidth, Math.min(newW, FlxG.width - x - 2));
				newH = Math.max(minResizeHeight, Math.min(newH, FlxG.height - y - 2));
				if(Std.int(newW) != Std.int(bg.width) || Std.int(newH) != Std.int(bg.height))
					resize(Std.int(newW), Std.int(newH));
			}
			return;
		}

		if(!FlxG.mouse.released && _draggingBox && canMove)
		{
			var newPoint:FlxPoint = FlxG.mouse.getPositionInCameraView(camera);
			setPosition(_draggingPos.x - (_draggingPoint.x - newPoint.x), _draggingPos.y - (_draggingPoint.y - newPoint.y));
		}
		else
		{
			var wasDragging:Bool = _draggingBox;
			_draggingPos = null;
			_draggingPoint = null;
			_draggingBox = false;
			if(FlxG.mouse.released)
			{
				if(_pressedBox) forceCheckNext = true;
				_pressedBox = false;
			}
			if(wasDragging && broadcastBoxEvents) PsychUIEventHandler.event(DROP_EVENT, this);
		}

		var wid:Int = (tabs.length > 0) ? Std.int((tabBarWidth > 0 ? tabBarWidth : bg.width) / tabs.length) : 0;
		for (num => tab in tabs)
		{
			tab.scrollFactor.set(scrollFactor.x, scrollFactor.y);
			tab.text.scrollFactor.set(scrollFactor.x, scrollFactor.y);
			tab.x = x + wid * num;
			if(tab.y != y) tab.y = y;
		}

		if(onResize != null && !isMinimized)
		{
			var wantH:Int = 20;
			for (tab in tabs)
			{
				if(tab.text != null && tab.text.exists)
				{
					var th:Int = Std.int(Math.ceil(tab.text.textField.textHeight)) + 6;
					if(th > wantH) wantH = th;
				}
			}
			if(wantH != tabHeight)
			{
				tabHeight = wantH;
				updateTabs();
			}
			onResize(this);
		}

		var _ignoreTabUpdate:Bool = false;
		if(forceCheckNext || FlxG.mouse.justMoved || FlxG.mouse.justPressed || FlxG.mouse.justReleased)
		{
			forceCheckNext = false;
			for (tab in tabs)
			{
				if(FlxG.mouse.overlaps(tab, camera))
				{
					tab.color = hoverStyle.bgColor;
					tab.alpha = hoverStyle.bgAlpha;
					tab.text.color = hoverStyle.textColor;

					if(FlxG.mouse.justPressed)
						_pressedBox = true;

					if(!_draggingBox && canMove && _pressedBox && FlxG.mouse.pressed && (Math.abs(FlxG.mouse.deltaScreenX) > 1 || Math.abs(FlxG.mouse.deltaScreenY) > 1))
					{
						_draggingPos = FlxPoint.weak(x, y);
						_draggingPoint = FlxG.mouse.getPositionInCameraView(camera);
						_draggingBox = true;
						if(broadcastBoxEvents) PsychUIEventHandler.event(DRAG_EVENT, this);
					}

					if(FlxG.mouse.justReleased && canMinimize && _lastClick < 0.15 && selectedTab == tab && _lastTab == selectedTab)
					{
						_ignoreTabUpdate = true;
						isMinimized = !isMinimized;
						_lastClick = 0;
						//trace('do minimize: $isMinimized');
					}

					if(FlxG.mouse.justPressed)
					{
						if(selectedTab != tab)
						{
							isMinimized = false;
							_ignoreTabUpdate = true;
						}
						_lastTab = selectedTab;
						selectedTab = tab;
						_lastClick = 0;
						if(broadcastBoxEvents) PsychUIEventHandler.event(CLICK_EVENT, this);
					}
					else if(selectedTab != tab) continue;
				}

				var style:UIStyleData = (selectedTab == tab) ? selectedStyle : unselectedStyle;
			tab.color = style.bgColor;
			tab.alpha = style.bgAlpha;
			tab.text.color = style.textColor;
		}
		}

		updateOpenDropdownLayer();

		if(_ignoreTabUpdate)
		{
			if(broadcastBoxEvents)
				PsychUIEventHandler.event(MINIMIZE_EVENT, this);
		}
		else if(selectedTab != null && !isMinimized)
			selectedTab.updateMenu(this, elapsed);

		if(minimizeOnFocusLost && FlxG.mouse.justPressed && !isMinimized && !FlxG.mouse.overlaps(bg, camera))
		{
			isMinimized = true;
			if(broadcastBoxEvents)
				PsychUIEventHandler.event(MINIMIZE_EVENT, this);
		}
	}

	override function set_cameras(v:Array<FlxCamera>)
	{
		for (tab in tabs) tab.cameras = v;
		return super.set_cameras(v);
	}

	override function set_camera(v:FlxCamera)
	{
		for (tab in tabs) tab.camera = v;
		return super.set_camera(v);
	}

	override function draw()
	{
		super.draw();

		if(selectedTab != null && !isMinimized)
			selectedTab.drawMenu(this);
	}

	var _openDropdown:PsychUIDropDownMenu = null;
	var _stateIndexBeforeOpen:Int = -1;

	function updateOpenDropdownLayer():Void
	{
		var dd:PsychUIDropDownMenu = PsychUIDropDownMenu.openMenu;

		if(dd != _openDropdown)
		{
			if(_openDropdown != null)
			{
				restoreStateOrder();
				_openDropdown = null;
			}
			if(dd != null && ownsDropdown(dd)) _openDropdown = dd;
		}
		if(dd == null || _openDropdown != dd) return;

		for (tab in tabs)
		{
			if(tab.menu == null || tab.menu.members == null) continue;
			moveToEnd(cast(tab.menu.members, Array<Dynamic>), dd);
		}

		if(!isMinimized)
		{
			var st = FlxG.state;
			if(st != null && st.members != null)
			{
				var myIdx:Int = st.members.indexOf(this);
				if(myIdx >= 0 && myIdx != st.members.length - 1)
				{
					if(_stateIndexBeforeOpen < 0) _stateIndexBeforeOpen = myIdx;
					moveToEnd(cast(st.members, Array<Dynamic>), this);
				}
			}
		}

		if(FlxG.mouse.justPressed && !dd.isMouseOverOpenArea(camera))
			dd.showDropDown(false);
	}

	static function moveToEnd(list:Array<Dynamic>, item:Dynamic):Bool
	{
		if(list == null) return false;

		var idx:Int = list.indexOf(item);
		if(idx < 0 || idx == list.length - 1) return false;

		list.splice(idx, 1);
		list.push(item);
		return true;
	}

	function ownsDropdown(dd:PsychUIDropDownMenu):Bool
	{
		for (tab in tabs)
		{
			if(tab.menu == null || tab.menu.members == null) continue;
			if(cast(tab.menu.members, Array<Dynamic>).indexOf(dd) >= 0) return true;
		}
		return false;
	}

	function restoreStateOrder():Void
	{
		var st = FlxG.state;
		if(_stateIndexBeforeOpen < 0 || st == null || st.members == null) return;

		var myIdx:Int = st.members.indexOf(this);
		if(myIdx >= 0 && myIdx != _stateIndexBeforeOpen)
		{
			st.members.splice(myIdx, 1);
			var list:Array<Dynamic> = cast(st.members, Array<Dynamic>);
			list.insert(Std.int(Math.min(_stateIndexBeforeOpen, list.length)), this);
		}
		_stateIndexBeforeOpen = -1;
	}

	override function destroy()
	{
		tabs = null;
		selectedTab = null;
		super.destroy();
	}

	public function addTab(name:String)
	{
		var createdTab:PsychUITab = new PsychUITab(name);
		tabs.push(createdTab);
		add(createdTab);
		updateTabs();

		if(selectedTab == null)
			selectedTab = createdTab;
	}

	public var tabHeight:Int = 20;
	public var tabBarWidth:Int = 0;
	public function updateTabs()
	{
		if(tabs == null || tabs.length < 1) return;
		var wid:Int = Std.int((tabBarWidth > 0 ? tabBarWidth : bg.width) / tabs.length);
		for (num => tab in tabs)
		{
			tab.x = x + wid * num;
			tab.y = y;
			tab.resize(wid, tabHeight);
			tab.cameras = cameras;
			tab.scrollFactor.set(scrollFactor.x, scrollFactor.y);
			tab.text.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		}
	}

	var _originalHeight:Int = 0;
	var bgBaseH:Float = 1;
	public var onResize:PsychUIBox->Void;

	public function resize(width:Int, height:Int)
	{
		_originalHeight = height;
		tabBarWidth = width;
		bgBaseH = height;
		var r:Float = (width < 60 || height < 60) ? Math.min(width, height) / 5 : 10;
		bg.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRoundRect(bg, 0.5, 0.5, width - 1, height - 1, r, r, 0xE91D1D22);
		bg.dirty = true;
		redrawBorder(width, height);
		updateTabs();
		if(onResize != null) onResize(this);
	}

	function redrawBorder(width:Int, height:Int)
	{
		if(width <= 0 || height <= 0)
		{
			borderSpr.visible = false;
			return;
		}
		borderSpr.visible = true;
		borderSpr.makeGraphic(width, height, FlxColor.TRANSPARENT, true);
		var r:Float = (width < 60 || height < 60) ? Math.min(width, height) / 5 : 10;
		FlxSpriteUtil.drawRoundRect(borderSpr, 1.5, 1.5, width - 3, height - 3, r - 1, r - 1, FlxColor.TRANSPARENT, {thickness: 3, color: 0x334F8DF9});
		FlxSpriteUtil.drawRoundRect(borderSpr, 0.5, 0.5, width - 1, height - 1, r, r, FlxColor.TRANSPARENT, {thickness: 1, color: UITheme.BORDER});
		borderSpr.dirty = true;
	}

	private function set_selectedTab(v:PsychUITab)
	{
		if(v != null)
		{
			@:bypassAccessor selectedName = v.name;
			@:bypassAccessor selectedIndex = tabs.indexOf(v);
		}
		else
		{
			@:bypassAccessor selectedName = null;
			@:bypassAccessor selectedIndex = -1;
		}
		return (selectedTab = v);
	}

	private function set_selectedName(v:String)
	{
		if(v == null || v.trim().length < 1) selectedTab = null;

		for (tab in tabs)
		{
			if(tab.name == v)
			{
				selectedTab = tab;
				return v;
			}
		}
		return null;
	}

	private function set_selectedIndex(v:Int)
	{
		v = Std.int(Math.max(Math.min(v, tabs.length-1), -1));
		if(v > -1) selectedTab = tabs[v];
		else selectedTab = null;
		return v;
	}

	public function getTab(name:String)
	{
		for (tab in tabs)
			if(tab.name == name)
				return tab;

		return null;
	}

	function set_canMinimize(v:Bool)
	{
		isMinimized = false;
		return (canMinimize = v);
	}

	function set_isMinimized(v:Bool)
	{
		if(!v)
		{
			bg.scale.set(1, 1);
			bg.updateHitbox();
			bg.visible = true;
			borderSpr.visible = true;
		}
		else
		{
			bg.scale.set(1, (tabHeight + 20) / Math.max(1, bgBaseH));
			bg.updateHitbox();
			borderSpr.visible = false;
			selectedTab = null;
		}
		return (isMinimized = v);
	}
}
