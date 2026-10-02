package states.editors;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxStringUtil;
import flixel.input.keyboard.FlxKey;
import lime.system.Clipboard;
import backend.Conductor;
import backend.ClientPrefs;
import backend.Language;
import backend.MusicBeatSubstate;
import backend.Paths;
import backend.Song;
import backend.ui.PsychUIButton;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUIInputText;
import backend.ui.PsychUIDropDownMenu;
import backend.ui.PsychUINumericStepper;
import backend.ui.PsychUISlider;
import backend.ui.UITheme;
import backend.cameraeditor.CameraEditorData;
import backend.cameraeditor.CustomEase;
import backend.cameraeditor.EdEvent;
import states.PlayState;
import objects.Character;
import objects.StrumNote;
import states.editors.content.FileDialogHandler;
import flash.net.FileFilter;

class CameraEditorState extends MusicBeatSubstate
{

	static var EASE_BASES:Array<String> = ['linear', 'INSTANT', 'CLASSIC', 'sine', 'quad', 'cube', 'quart', 'quint', 'expo', 'smoothStep', 'smootherStep', 'elastic', 'back', 'bounce', 'circ'];
	static var EASE_UI_FOCUS:Array<String> = ['linear', 'INSTANT', 'CLASSIC', 'sine', 'quad', 'cube', 'quart', 'quint', 'expo', 'smoothStep', 'smootherStep', 'elastic', 'back', 'bounce', 'circ', '自定义'];
	static var EASE_UI_OTHER:Array<String> = ['linear', 'INSTANT', 'sine', 'quad', 'cube', 'quart', 'quint', 'expo', 'smoothStep', 'smootherStep', 'elastic', 'back', 'bounce', 'circ', '自定义'];
	static var EASE_CUSTOM:String = '自定义';
	static var EASE_GRAPH_W:Int = 100;
	static var EASE_STRIP_W:Int = 16;
	static var EASE_DOT_FRAMES:Int = 30;
	static var EASE_DIRS:Array<String> = ['In', 'Out', 'InOut'];
	static var EASE_NO_DIR:Array<String> = ['INSTANT', 'CLASSIC'];

	var uiScale:Float = 1;
	var topH:Int = 48;
	var rightW:Int = 440;
	var layerLabelW:Int = 140;
	var rulerH:Int = 28;
	var layerH:Int = 88;
	var timelineAreaH:Int = 0;
	var strumH:Int = 0;
	var draggingSplitter:Bool = false;
	var splitterBar:FlxSprite;
	var resizeCursor:FlxSprite;
	var dragResizeMode:Int = 0;
	var timelineX:Int = 140;
	var timelineRight:Int = 0;
	var selectedLayer:Int = 0;
	var layerRowBtns:Array<PsychUIButton> = [];
	var boxPending:Bool = false;
	var boxSelecting:Bool = false;
	var boxStartX:Float = 0;
	var boxStartY:Float = 0;
	var boxRect:FlxSprite;
	var timelineTop:Int = 0;
	var tlTop:Int = 0;
	var toolbarH:Int = 38;
	var scrollbarH:Int = 16;
	var panelAX:Float = 0;
	var panelAY:Float = 0;
	var panelBX:Float = 0;
	var panelBY:Float = 0;
	var draggingPanelA:Bool = false;
	var draggingPanelB:Bool = false;
	var previewZoom:Float = 0.55;
	var vfWinScale:Float = 1.0;
	var prevCamZoom:Float = 1;
	var vcamZoom:Float = 1;
	var vcamScrollX:Float = 0;
	var vcamScrollY:Float = 0;
	var vcamAngle:Float = 0;
	var vcamFollowX:Float = 0;
	var vcamFollowY:Float = 0;
	var vcamHasFollow:Bool = false;
	var vcamManualFollow:Bool = false;
	var manualFollowTimer:Float = 0;
	var eventHoldTimer:Float = 0;
	var vcamZoomTween:FlxTween;
	var vcamAngleTween:FlxTween;
	var vcamFollowTween:FlxTween;
	var pvGz:Float = 1;
	var prevFollowLerp:Float = 1;
	var prevDefaultCamZoom:Float = 1;
	var prevChartCamFollow:Bool = true;
	var easeTitle:FlxText;
	var easeCurveBg:FlxSprite;
	var easeGraphFrame:FlxSprite;
	var easeDotFrame:FlxSprite;
	var easeDotStrip:FlxSprite;
	var easeRef0:FlxSprite;
	var easeRef1:FlxSprite;
	var easeBase:PsychUIDropDownMenu;
	var easeDir:PsychUIDropDownMenu;
	var easeCurveBars:Array<FlxSprite> = [];
	var easeCurveVals:Array<Float> = [];
	var easeDot:FlxSprite;
	var easeDotT:Float = 0;
	var easeDotPause:Float = 0;
	var easeVisible:Bool = false;
	var autoScrollDrop:PsychUIDropDownMenu;
	var zoomSlider:PsychUISlider;
	var panelAUserHidden:Bool = false;
	var panelALastSel:Int = -2;
	var panelAHideBtn:PsychUIButton;
	var curveEditorBg:FlxSprite;
	var curveLine:FlxSprite;
	var curveHandles:Array<FlxSprite> = [];
	var customCurve:Array<Float> = [];
	var curveDragging:Int = -1;
	var curveEditorX:Float = 0;
	var curveEditorY:Float = 0;
	var curveEditorW:Float = 0;
	var curveEditorH:Float = 0;
	var rulerPressX:Float = 0;
	var rulerMoved:Bool = false;
	var rightLine:FlxSprite;
	var autoScroll:Bool = false;
	var showPassepartout:Bool = false;
	var passeAlpha:Float = 0.5;
	var doBopping:Bool = false;
	var showExtendedBounds:Bool = false;
	var viewfinderBox:FlxSprite;
	var viewfinderCrossH:FlxSprite;
	var viewfinderCrossV:FlxSprite;
	var vcamSlice:FlxSprite;
	var vcamSliceSolid:FlxSprite;
	var vcamCornerTL:FlxSprite;
	var vcamCornerTR:FlxSprite;
	var vcamCornerBL:FlxSprite;
	var vcamCornerBR:FlxSprite;
	var vcamLineT:FlxSprite;
	var vcamLineB:FlxSprite;
	var vcamLineL:FlxSprite;
	var vcamLineR:FlxSprite;
	var vcamCenter:FlxSprite;
	var passeT:FlxSprite;
	var passeB:FlxSprite;
	var passeL:FlxSprite;
	var passeR:FlxSprite;
	var extL:FlxSprite;
	var extR:FlxSprite;
	var vcamSmall:Array<FlxSprite> = [];
	var vcamCutState:Int = -1;
	var viewfinderDot:FlxSprite;
	var viewfinderEdges:Array<FlxSprite> = [];
	var vfNine:Array<FlxSprite> = [];
	var miniBg:FlxSprite;
	var miniViewfinder:FlxSprite;
	var miniDot:FlxSprite;
	var miniText:FlxText;
	var previewBorder:FlxSprite;
	var previewZoomText:FlxText;
	var panelAContentY:Float = 0;
	var panelBContentY:Float = 0;
	var panelDragOffX:Float = 0;
	var panelDragOffY:Float = 0;
	var panelBgB:FlxSprite;
	var panelTitleB:FlxText;
	var panelALabels:Array<FlxText> = [];
	var panelH_A:Int = 360;
	var panelH_B:Int = 248;
	var panelPS:Float = 1;

	var events:Array<EdEvent> = [];
	var selectedIndex:Int = -1;
	var selectedIndexes:Array<Int> = [];
	var draggingIndex:Int = -1;
	var dragMouseMsOffset:Float = 0;
	var dragDeltaMs:Float = 0;
	var dragDeltaDurMs:Float = 0;
	var ghostSprites:Array<FlxSprite> = [];
	var panLastX:Float = 0;
	var currentSongName:String = '?';

	function primarySel():Int
	{
		return (selectedIndexes.length > 0) ? selectedIndexes[selectedIndexes.length - 1] : -1;
	}

	function clearSelection():Void
	{
		selectedIndexes = [];
		selectedIndex = -1;
	}

	var bookmarks:Array<Float> = [];
	var bookmarkSprites:Array<FlxSprite> = [];
	var clipboardEvents:Array<EdEvent> = [];

	var keybindings:Dynamic = null;
	static final DEFAULT_BINDS:Dynamic = {
		togglePlayback: 'SPACE',
		toggleShader: 'G',
		undo: 'CTRL+Z',
		redo: 'CTRL+Y',
		copy: 'CTRL+C',
		paste: 'CTRL+V',
		duplicate: 'CTRL+D',
		addEvent: 'N',
		restart: 'R',
		seekSelected: 'F',
		delete: 'DELETE',
		quantUp: 'E',
		quantDown: 'Q',
		panLeft: 'A',
		panRight: 'D',
		addBookmark: 'M',
		help: 'F1'
	};
	static final BIND_ACTIONS:Array<{action:String, label:String}> =
	[
		{action: 'togglePlayback', label: '播放/暂停'},
		{action: 'toggleShader', label: '着色器开关'},
		{action: 'undo', label: '撤销'},
		{action: 'redo', label: '重做'},
		{action: 'copy', label: '复制选中 (Ctrl+C)'},
		{action: 'paste', label: '粘贴到播放头 (Ctrl+V)'},
		{action: 'duplicate', label: '快速复制到下一拍 (Ctrl+D)'},
		{action: 'addEvent', label: '添加事件'},
		{action: 'restart', label: '回到开头 (R)'},
		{action: 'seekSelected', label: '定位选中'},
		{action: 'delete', label: '删除'},
		{action: 'quantUp', label: '吸附精度+'},
		{action: 'quantDown', label: '吸附精度-'},
		{action: 'panLeft', label: '时间轴左移'},
		{action: 'panRight', label: '时间轴右移'},
		{action: 'addBookmark', label: '添加书签'},
		{action: 'help', label: '帮助'}
	];

	function bind(action:String):String
	{
		if(action == 'help') return 'F1';
		if(keybindings != null && Reflect.hasField(keybindings, action))
		{
			var v:Dynamic = Reflect.field(keybindings, action);
			if(v != null && Std.string(v).length > 0) return Std.string(v);
		}
		return Reflect.field(DEFAULT_BINDS, action);
	}

	function keyJustPressed(bindKey:String):Bool
	{
		if(bindKey == null || bindKey.length < 1) return false;
		var ctrl:Bool = false;
		var shift:Bool = false;
		var keyName:String = bindKey;
		if(keyName.indexOf('+') >= 0)
		{
			var parts:Array<String> = keyName.split('+');
			ctrl = parts.contains('CTRL');
			shift = parts.contains('SHIFT');
			keyName = parts[parts.length - 1];
		}
		var k:FlxKey = FlxKey.fromString(keyName);
		if(k == NONE) return false;
		if(ctrl != FlxG.keys.pressed.CONTROL) return false;
		if(shift != FlxG.keys.pressed.SHIFT) return false;
		return FlxG.keys.checkStatus(k, JUST_PRESSED);
	}

	var scrollMs:Float = 0;
	var pxPerMs:Float = 0.05;
	var songEndMs:Float = 0;
	var quantSteps:Int = 4;
	static final QUANT_OPTIONS:Array<Int> = [1, 2, 4, 8, 16];
	var quantOptionIndex:Int = 2;

	var isPlaying:Bool = false;
	var livePreview:Bool = false;
	var previewCursorMs:Float = 0;
	var triggeredFlags:Array<Bool> = [];
	var shaderEnabledPref:Bool = true;

	var undoStack:Array<Array<EdEvent>> = [];
	var redoStack:Array<Array<EdEvent>> = [];
	var undoNames:Array<String> = [];
	var redoNames:Array<String> = [];
	var deleteLayerOpen:Bool = false;
	var deleteLayerTarget:Int = -1;
	var renameLayerOpen:Bool = false;
	var renameLayerTarget:Int = -1;
	var layerMenuOpen:Int = -1;
	static final MAX_UNDO:Int = 50;
	static final EDGE_ZONE:Float = 40;
	static final EDGE_MAX_SPEED:Float = 1500;
	var dragStartSnap:Array<EdEvent> = [];
	var dragStartTime:Float = -1;

	var titleText:FlxText;
	var timeText:FlxText;
	var quantText:FlxText;
	var prototypeText:FlxText;
	var saveMarkText:FlxText;
	var menuOpen:String = null;
	var menuPanel:FlxSprite;
	var menuItemH:Int = 22;
	var menuItemTexts:Array<FlxText> = [];
	var menuItemFns:Array<Void->Void> = [];
	var menuButtons:Array<PsychUIButton> = [];
	var menuDefs:Array<{label:String, items:Array<{text:String, fn:Void->Void}>}> = [];
	var statusText:FlxText;
	var statusTimer:Float = 0;
	var saveBtn:PsychUIButton;
	var autoGenBtn:PsychUIButton;
	var importBtn:PsychUIButton;
	var exportBtn:PsychUIButton;
	var helpBtn:PsychUIButton;
	var closeBtn:PsychUIButton;
	var keybindBtn:PsychUIButton;
	var customLayerBtn:PsychUIButton;

	var topBarBg:FlxSprite;
	var timelineBg:FlxSprite;
	var rulerBg:FlxSprite;
	var panelBg:FlxSprite;
	var playhead:FlxSprite;
	var gridLines:Array<FlxSprite> = [];
	var rulerLabels:Array<FlxText> = [];
	var layerLabelTexts:Array<FlxText> = [];
	var timelineLayerUI:Array<FlxSprite> = [];
	var fullscreenBg:FlxSprite;
	var editorCam:FlxCamera;
	var viewfinderCam:FlxCamera;
	var vfWinX:Float = 0;
	var vfWinY:Float = 0;
	var vfWinW:Float = 0;
	var vfWinH:Float = 0;
	var toolbarBg:FlxSprite;
	var prevScrollX:Float = 0;
	var prevScrollY:Float = 0;
	var prevCamY:Float = 0;
	var vfDrag:Bool = false;
	var vfDragLastX:Float = 0;
	var vfDragLastY:Float = 0;
	var camRestoreMap:Map<FlxBasic, Array<FlxCamera>> = new Map<FlxBasic, Array<FlxCamera>>();
	var toolbarTimeText:FlxText;
	var playBtnSprite:FlxSprite;
	var snapBtnSprite:FlxSprite;
	var autoScrollMode:Int = 1;
	var manualScrollTimer:Float = 0;
	var addMenuLayer:Int = -1;
	static final AUTO_SCROLL_LABELS:Array<String> = ['No Scroll', 'Page Scroll', 'Smooth Scroll'];
	var snapIconState:Int = -1;
	var autoScrollLabel:FlxText;
	var zoomLabel:FlxText;
	var snapEnabled:Bool = true;
	var scrollbarBg:FlxSprite;
	var scrollbarThumb:FlxSprite;
	var scrollbarPlayheadMark:FlxSprite;
	var addLayerBtn:FlxSprite;
	var deleteLayerBtn:FlxSprite;
	var draggingScrollbar:Bool = false;
	var layerVisible:Array<Bool> = [];
	var layerEyeBoxes:Array<FlxSprite> = [];
	var layerLabelBgs:Array<FlxSprite> = [];
	var layerColorBars:Array<FlxSprite> = [];
	var eventSprites:Array<FlxSprite> = [];
	var eventIconSprites:Array<FlxSprite> = [];
	var eventTriSprites:Array<FlxSprite> = [];
	var selFrameSprites:Array<FlxSprite> = [];
	var dragTargetLayer:Int = -1;
	var hintText:FlxText;

	var panelTitle:FlxText;
	var panelInfo:FlxText;
	var typeDropdown:PsychUIDropDownMenu;
	var timeInput:PsychUIInputText;
	var v1Input:PsychUIInputText;
	var v2Input:PsychUIInputText;
	var addBtn:PsychUIButton;
	var dupBtn:PsychUIButton;
	var delBtn:PsychUIButton;
	var playBtn:PsychUIButton;
	var pasteBtn:PsychUIButton;
	var shaderCheckBox:PsychUICheckBox;
	var strumCheckBox:PsychUICheckBox;
	var autoScrollBox:PsychUICheckBox;
	var panelUpdating:Bool = false;
	var pLb:Array<FlxText> = [];
	var fcTarget:PsychUIDropDownMenu;
	var fcX:PsychUINumericStepper;
	var fcY:PsychUINumericStepper;
	var fcDur:PsychUINumericStepper;
	var zcZoom:PsychUINumericStepper;
	var zcDur:PsychUINumericStepper;
	var zcMode:PsychUIDropDownMenu;
	var paTarget:PsychUIDropDownMenu;
	var paAnim:PsychUIDropDownMenu;
	var azA:PsychUINumericStepper;
	var azB:PsychUINumericStepper;
	var fpX:PsychUINumericStepper;
	var fpY:PsychUINumericStepper;
	var fpDur:PsychUINumericStepper;
	var anAngle:PsychUINumericStepper;
	var anDur:PsychUINumericStepper;

	var autoGenBg:FlxSprite;
	var autoGenOpen:Bool = false;
	var autoGenLabels:Array<FlxText> = [];
	var focusGenCheck:PsychUICheckBox;
	var zoomGenCheck:PsychUICheckBox;
	var zoomIntervalStepper:PsychUINumericStepper;
	var zoomTargetInput:PsychUIInputText;
	var genBtn:PsychUIButton;
	var cancelGenBtn:PsychUIButton;

	var helpBg:FlxSprite;
	var helpOpen:Bool = false;
	var helpLines:Array<String> = [];
	var helpScroll:Int = 0;
	var helpText:FlxText;
	var closeHelpBtn:PsychUIButton;
	var aboutOpen:Bool = false;
	var aboutBg:FlxSprite;
	var aboutText:FlxText;
	var closeAboutBtn:PsychUIButton;
	var welcomeOpen:Bool = false;
	var welcomeBg:FlxSprite;
	var welcomeText:FlxText;
	var welcomeHelpBtn:PsychUIButton;
	var welcomeGenBtn:PsychUIButton;
	var closeWelcomeBtn:PsychUIButton;

	var keybindOpen:Bool = false;
	var keybindBg:FlxSprite;
	var kbTitle:FlxText;
	var kbHint:FlxText;
	var keybindInputs:Array<PsychUIInputText> = [];
	var keybindLabels:Array<FlxText> = [];
	var closeKeybindBtn:PsychUIButton;

	var customLayerOpen:Bool = false;
	var customLayerBg:FlxSprite;
	var customLayerTitle:FlxText;
	var customNameInput:PsychUIInputText;
	var customColorInput:PsychUIInputText;
	var customV1Input:PsychUIInputText;
	var customV2Input:PsychUIInputText;
	var addCustomBtn:PsychUIButton;
	var closeCustomBtn:PsychUIButton;
	var customListLabel:FlxText;
	var customLayerRows:Array<FlxText> = [];
	var customFieldLabels:Array<FlxText> = [];
	var customLayerDelBtns:Array<PsychUIButton> = [];
	var customLayerSwatches:Array<FlxSprite> = [];
	var customLayerRowY:Float = 0;

	var deleteLayerBg:FlxSprite;
	var deleteLayerText:FlxText;
	var dlNeverBtn:PsychUIButton;
	var dlFlattenBtn:PsychUIButton;
	var dlDeleteBtn:PsychUIButton;
	var renameLayerBg:FlxSprite;
	var renameLayerText:FlxText;
	var renameLayerInput:PsychUIInputText;
	var renameOkBtn:PsychUIButton;
	var renameCancelBtn:PsychUIButton;
	var autoSortOpen:Bool = false;
	var autoSortBg:FlxSprite;
	var autoSortText:FlxText;
	var asSkipBtn:PsychUIButton;
	var asSortBtn:PsychUIButton;
	var backupDialogOpen:Bool = false;
	var uploadChartOpen:Bool = false;
	var uploadChartBg:FlxSprite;
	var uploadChartText:FlxText;
	var ucOpenBtn:PsychUIButton;
	var ucRecentTitle:FlxText;
	var ucCancelBtn:PsychUIButton;
	var ucRecentBtns:Array<PsychUIButton> = [];
	var fileDialog:FileDialogHandler;
	var backupDialogBg:FlxSprite;
	var backupDialogText:FlxText;
	var bdNoBtn:PsychUIButton;
	var bdFolderBtn:PsychUIButton;
	var bdLoadBtn:PsychUIButton;
	var bdPath:String = null;
	var autoSaveTimer:Float = 0;
	var dirty:Bool = false;
	var prevWindowTitle:String = null;
	var durationSteps:Bool = false;
	var hintDialogOpen:Bool = false;
	var hintDialogBg:FlxSprite;
	var hintDialogText:FlxText;
	var hdIgnoreBtn:PsychUIButton;
	var hdSortBtn:PsychUIButton;
	var addMenuOpen:Bool = false;
	var addMenuMs:Float = 0;
	var addMenuX:Float = 0;
	var addMenuY:Float = 0;
	var addMenuW:Float = 0;
	var addMenuH:Float = 0;
	var addMenuItems:Array<FlxText> = [];
	var addMenuNames:Array<String> = [];

	var lastClickTime:Float = 0;
	var lastClickPos:Float = -9999;
	var lastLayerClickTime:Float = 0;
	var lastLayerClickIdx:Int = -1;

	var strumPreviewVisible:Bool = true;
	var strumPreviewBg:FlxSprite;
	var strumPreviewGroup:FlxTypedGroup<StrumNote>;
	var strumLabels:FlxText;
	var noteMarkGroup:FlxTypedGroup<FlxSprite>;
	var strumPreviewY:Float = 0;
	var songNotesCache:Array<{time:Float, dir:Int, mustHit:Bool}> = [];
	var songNotesPtr:Int = 0;

	function fs(px:Int):Int
	{
		return Std.int(px * uiScale * 1.15);
	}

	function psy(v:Float):Float
	{
		return panelAY + v;
	}

	function recomputeLayerH():Void
	{
		var avail:Float = (timelineAreaH - toolbarH - scrollbarH - rulerH - 40) / Math.max(1, CameraEditorData.layerCount());
		layerH = Std.int(Math.max(22, Math.min(46 * Math.min(uiScale, 1.25), avail)));
	}

	function applyTimelineLayout():Void
	{
		timelineTop = FlxG.height - timelineAreaH;
		tlTop = timelineTop + toolbarH + scrollbarH;
		recomputeLayerH();
		rebuildTimelineLayers();
		rebuildBookmarks();
		updateSplitter();
		positionTimelineToolbar();
		if(statusText != null) statusText.y = strumPreviewY + 10;
		refreshRulerPositions();
		updateGrid();
	}

	function refreshRulerPositions():Void
	{
		if(rulerBg != null) rulerBg.y = tlTop;
		if(rulerLabels != null) for(lbl in rulerLabels) lbl.y = tlTop + 6;
		if(layerRowBtns != null)
		{
			var lbw:Int = Std.int((layerLabelW - 8) / 4) - 3;
			var lbx:Int = 5;
			for(lb in layerRowBtns)
			{
				if(lb == null) continue;
				lb.x = lbx;
				lb.y = tlTop + 3;
				lbx += lbw + 3;
			}
		}
		if(gridLines != null) for(g in gridLines)
		{
			g.y = tlTop + rulerH;
			g.scale.y = Math.max(1, timelineTop + timelineAreaH - (tlTop + rulerH));
		}
		if(rightLine != null)
		{
			rightLine.y = timelineTop;
			rightLine.scale.y = Math.max(1, timelineAreaH);
		}
		if(previewZoomText != null) previewZoomText.y = timelineTop - 26;
		if(timelineBg != null)
		{
			timelineBg.y = timelineTop;
			timelineBg.scale.y = Math.max(1, timelineAreaH / Math.max(1, timelineBg.height));
		}
		if(playhead != null) playhead.y = timelineTop;
	}

	override public function create():Void
	{
		super.create();
		try
		{

		uiScale = Math.max(1, Math.min(FlxG.height / 720, FlxG.width / 1280));
		topH = Std.int(48 * Math.min(uiScale, 1.25));
		rulerH = Std.int(28 * Math.min(uiScale, 1.25));
		layerLabelW = Std.int(140 * Math.min(uiScale, 1.25));
		timelineX = layerLabelW;
		timelineRight = FlxG.width - rightW - 16;

		timelineAreaH = Std.int(FlxG.height * 0.36);
		strumH = Std.int(64 * Math.min(uiScale, 1.25));
		timelineTop = FlxG.height - timelineAreaH;
		tlTop = timelineTop + toolbarH + scrollbarH;
		recomputeLayerH();

		if(PlayState.instance != null)
		{
			PlayState.instance.paused = true;
			PlayState.instance.camZooming = false;
			prevChartCamFollow = PlayState.chartCameraFollow;
			PlayState.chartCameraFollow = true;
			prevDefaultCamZoom = PlayState.instance.defaultCamZoom;
			for(cam in [PlayState.instance.camHUD, PlayState.instance.camOther, PlayState.instance.camOverlay])
				if(cam != null) cam.visible = false;
			if(PlayState.instance.healthBar != null) PlayState.instance.healthBar.visible = false;
			if(PlayState.instance.scoreTxt != null) PlayState.instance.scoreTxt.visible = false;
			if(PlayState.instance.iconP1 != null) PlayState.instance.iconP1.visible = false;
			if(PlayState.instance.iconP2 != null) PlayState.instance.iconP2.visible = false;
			if(PlayState.instance.strumLineNotes != null) PlayState.instance.strumLineNotes.visible = true;
			if(PlayState.instance.camGame != null)
			{
				prevCamZoom = PlayState.instance.camGame.zoom;
				if(prevCamZoom < 0.01) prevCamZoom = 1;
				prevScrollX = PlayState.instance.camGame.scroll.x;
				prevScrollY = PlayState.instance.camGame.scroll.y;
				prevCamY = PlayState.instance.camGame.y;
				prevFollowLerp = PlayState.instance.camGame.followLerp;
				PlayState.instance.camGame.followLerp = 0;
			}
			vcamZoom = Math.max(0.05, prevCamZoom);
			vcamScrollX = prevScrollX;
			vcamScrollY = prevScrollY;
			vcamAngle = 0;
			vcamHasFollow = false;
			vcamFollowX = vcamScrollX + FlxG.width / (2 * vcamZoom);
			vcamFollowY = vcamScrollY + FlxG.height / (2 * vcamZoom);
			pvGz = Math.max(0.05, prevCamZoom * previewZoom);
			PlayState.instance.camGame.angle = 0;
			PlayState.instance.camGame.x = 0;
			PlayState.instance.camGame.y = 0;
			centerSceneOnViewfinder();
		}
		layoutViewfinderWindow();
		viewfinderCam = new FlxCamera();
		viewfinderCam.bgColor.alpha = 0;
		viewfinderCam.x = Std.int(vfWinX);
		viewfinderCam.y = Std.int(vfWinY);
		viewfinderCam.width = Std.int(vfWinW);
		viewfinderCam.height = Std.int(vfWinH);
		FlxG.cameras.add(viewfinderCam, false);
		setViewfinderCameras();
		editorCam = new FlxCamera();
		editorCam.bgColor.alpha = 0;
		editorCam.zoom = 1;
		FlxG.cameras.add(editorCam, false);
		cameras = [editorCam];
		FlxG.camera = editorCam;
		buildPreviewOverlay();
		FlxG.mouse.visible = true;
		livePreview = true;

		CameraEditorData.migrateFromSong();
		trace('[CamEd] migrateFromSong done');
		events = CameraEditorData.loadCamEvents();
		trace('[CamEd] loadCamEvents done: ${events.length}');
		songEndMs = (FlxG.sound.music != null) ? FlxG.sound.music.length : 0;
		if(songEndMs <= 0 && PlayState.SONG != null) songEndMs = 0;
		trace('[CamEd] songEndMs=$songEndMs');
		previewCursorMs = Conductor.songPosition;
		if(previewCursorMs > songEndMs && songEndMs > 0) previewCursorMs = 0;
		currentSongName = (PlayState.SONG != null && PlayState.SONG.song != null) ? PlayState.SONG.song : '?';

		var prefs:Dynamic = CameraEditorData.loadPrefs();
		if(prefs != null)
		{
			if(Reflect.hasField(prefs, 'pxPerMs') && prefs.pxPerMs != null)
			{
				var pp:Float = Std.parseFloat(Std.string(prefs.pxPerMs));
				if(!Math.isNaN(pp) && pp > 0) pxPerMs = pp;
			}
			if(Reflect.hasField(prefs, 'quantOptionIndex') && prefs.quantOptionIndex != null)
			{
				var qi:Null<Int> = Std.parseInt(Std.string(prefs.quantOptionIndex));
				if(qi != null && qi >= 0 && qi < QUANT_OPTIONS.length) quantOptionIndex = qi;
			}
			if(Reflect.hasField(prefs, 'strumPreviewVisible')) strumPreviewVisible = (prefs.strumPreviewVisible == true);
			if(Reflect.hasField(prefs, 'shaderEnabled')) shaderEnabledPref = (prefs.shaderEnabled == true);
			if(Reflect.hasField(prefs, 'autoScrollMode')) autoScrollMode = Std.int(prefs.autoScrollMode);
			else if(Reflect.hasField(prefs, 'autoScroll')) autoScrollMode = (prefs.autoScroll == true) ? 2 : 0;
			if(Reflect.hasField(prefs, 'snapEnabled')) snapEnabled = (prefs.snapEnabled == true);
			if(Reflect.hasField(prefs, 'showPassepartout')) showPassepartout = (prefs.showPassepartout == true);
			if(Reflect.hasField(prefs, 'showExtendedBounds')) showExtendedBounds = (prefs.showExtendedBounds == true);
			if(Reflect.hasField(prefs, 'layerVisible') && prefs.layerVisible != null)
			{
				var lv:Array<Dynamic> = Std.isOfType(prefs.layerVisible, Array) ? prefs.layerVisible : null;
				if(lv != null && lv.length == CameraEditorData.layerCount())
					layerVisible = [for(v in lv) (v == true)];
			}
			if(Reflect.hasField(prefs, 'panelAX')) panelAX = Std.parseFloat(Std.string(prefs.panelAX));
			if(Reflect.hasField(prefs, 'panelAY')) panelAY = Std.parseFloat(Std.string(prefs.panelAY));
			if(Reflect.hasField(prefs, 'panelBX')) panelBX = Std.parseFloat(Std.string(prefs.panelBX));
			if(Reflect.hasField(prefs, 'panelBY')) panelBY = Std.parseFloat(Std.string(prefs.panelBY));
			if(panelAX <= 0 || panelAX >= FlxG.width - rightW) panelAX = FlxG.width - rightW - 16;
			if(panelAY <= 0 || panelAY >= FlxG.height - 60) panelAY = topH + 8;
			if(panelBX <= 0 || panelBX >= FlxG.width - rightW) panelBX = FlxG.width - rightW - 16;
			if(panelBY <= 0 || panelBY >= FlxG.height - 60) panelBY = topH + 320;
			if(Reflect.hasField(prefs, 'scrollMs') && prefs.scrollMs != null)
			{
				var sm:Float = Std.parseFloat(Std.string(prefs.scrollMs));
				if(!Math.isNaN(sm) && sm > 0) scrollMs = sm;
			}
			if(Reflect.hasField(prefs, 'layerColors') && prefs.layerColors != null && Std.isOfType(prefs.layerColors, Array))
			{
				var cols:Array<Int> = [];
				for(c in cast(prefs.layerColors, Array<Dynamic>))
				{
					var cv:Null<Int> = Std.parseInt(Std.string(c));
					if(cv == null) continue;
					cols.push(cv);
				}
				if(cols.length >= CameraEditorData.layerCount()) CameraEditorData.setLayerColors(cols);
			}
			if(Reflect.hasField(prefs, 'keybindings') && prefs.keybindings != null) keybindings = prefs.keybindings;
			if(Reflect.hasField(prefs, 'durationSteps') && prefs.durationSteps != null)
				durationSteps = (Std.string(prefs.durationSteps) == 'true');
			if(Reflect.hasField(prefs, 'bookmarks') && prefs.bookmarks != null)
			{
				var b:Dynamic = prefs.bookmarks;
				if(b != null && Reflect.hasField(b, 'song') && Std.string(Reflect.field(b, 'song')) == currentSongName
					&& Reflect.hasField(b, 'times') && Std.isOfType(Reflect.field(b, 'times'), Array))
				{
					bookmarks = [];
					for(t in cast(Reflect.field(b, 'times'), Array<Dynamic>))
					{
						var tv:Float = Std.parseFloat(Std.string(t));
						if(!Math.isNaN(tv)) bookmarks.push(tv);
					}
				}
			}
		}
		if(scrollMs > songEndMs) scrollMs = Math.max(0, songEndMs - 2000);

		buildFullscreenBg();
		buildTopBar();
		trace('[CamEd] buildTopBar done');
		buildTimelineToolbar();
		trace('[CamEd] buildTimelineToolbar done');
		buildTimeline();
		trace('[CamEd] buildTimeline done');
		buildPanel();
		trace('[CamEd] buildPanel done');
		buildAutoGenPanel();
		trace('[CamEd] buildAutoGenPanel done');
		buildHelpPanel();
		trace('[CamEd] buildHelpPanel done');
		buildAboutPanel();
		trace('[CamEd] buildAboutPanel done');
		buildWelcomePanel();
		trace('[CamEd] buildWelcomePanel done');
		buildDeleteLayerPanel();
		buildRenameLayerPanel();
		buildAutoSortPanel();
		buildBackupPanel();
		buildUploadChartPanel();
		buildStrumPreview();
		trace('[CamEd] buildStrumPreview done');
		buildSplitter();
		buildSongNotesCache();
		trace('[CamEd] buildSongNotesCache done');
		buildKeybindPanel();
		trace('[CamEd] buildKeybindPanel done');
		buildCustomLayerPanel();
		trace('[CamEd] buildCustomLayerPanel done');
		rebuildBookmarks();
		trace('[CamEd] rebuildBookmarks done');

		rebuildEventSprites();
		trace('[CamEd] rebuildEventSprites done');
		buildPlayhead();
		refreshPanel();
		updatePlayhead();
		updateSplitter();
		buildHintDialog();
		buildAddEventMenu();
		applyShaderSuspend(!shaderCheckBox.checked);
		if(events.length == 0) welcomeOpen = true;
		else
		{
			checkBackupOnEnter();
			if(!backupDialogOpen) checkLayerOverlapOnEnter();
		}
		refreshWindowTitle();
		trace('[CamEd] create complete');
		}
		catch(e:Dynamic)
		{
			trace('[CamEd] CREATE ERROR: $e');
			if(PlayState.instance != null)
			{
				for(cam in [PlayState.instance.camGame, PlayState.instance.camHUD, PlayState.instance.camOther, PlayState.instance.camOverlay])
					if(cam != null) cam.visible = true;
				if(PlayState.instance.camGame != null) FlxG.camera = PlayState.instance.camGame;
			}
			var errBg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF1A1A2E);
			errBg.scrollFactor.set();
			add(errBg);
			var errText:FlxText = new FlxText(16, 16, FlxG.width - 32,
				'摄像机编辑器初始化失败：\n$e\n\n请把此窗口或控制台的 [CamEd] 日志发给我。按 ESC 返回游戏。', fs(16));
			errText.setFormat(Paths.font(Language.pickFont(errText.text)), fs(16), 0xFFFF5C5C);
			errText.scrollFactor.set();
			add(errText);
		}
	}

	function buildFullscreenBg():Void
	{
		fullscreenBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, topH, 0xFF1E1E1E);
		fullscreenBg.scrollFactor.set();
		add(fullscreenBg);
	}

	function buildTopBar():Void
	{
		topBarBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, topH, 0xFF141414);
		topBarBg.scrollFactor.set();
		add(topBarBg);

		var songName:String = (PlayState.SONG != null && PlayState.SONG.song != null) ? PlayState.SONG.song : '?';
		titleText = new FlxText(8, 16, 170, '摄像机编辑器 - $songName', fs(11));
		titleText.setFormat(Paths.font(Language.pickFont(titleText.text)), fs(11), FlxColor.WHITE);
		titleText.scrollFactor.set();
		add(titleText);

		saveMarkText = new FlxText(180, 16, 0, '*', fs(11));
		saveMarkText.setFormat(Paths.font(Language.pickFont(saveMarkText.text)), fs(11), 0xFFFFC46B);
		saveMarkText.scrollFactor.set();
		saveMarkText.visible = false;
		add(saveMarkText);

		prototypeText = new FlxText(FlxG.width - 300, 16, 288, 'PROTOTYPE 功能可能变更', fs(11));
		prototypeText.setFormat(Paths.font('Helvetica.ttf'), fs(11), 0xFF8A8A8A);
		prototypeText.alignment = RIGHT;
		prototypeText.scrollFactor.set();
		add(prototypeText);

		var sep:FlxSprite = new FlxSprite(0, topH - 1).makeGraphic(FlxG.width, 1, 0xFF2A2A2A);
		sep.scrollFactor.set();
		add(sep);

		menuDefs = [
			{label: '文件', items: [
				{text: '打开 / 最近打开… (Ctrl+O)', fn: openUploadChartDialog},
				{text: '保存 (Ctrl+S)', fn: doSave},
				{text: '另存为… (Ctrl+Shift+S)', fn: doSaveAs},
				{text: '导出为文件夹…', fn: doExportFolder},
				{text: '导出到剪贴板', fn: doExport},
				{text: '从剪贴板导入', fn: doImport},
				{text: '打开备份文件夹', fn: doOpenBackupsFolder},
				{text: '从最新备份恢复', fn: doShowLatestBackup},
				{text: '关闭 (Ctrl+Q / ESC)', fn: close}
			]},
			{label: '视图', items: [
				{text: '取景框暗角', fn: togglePassepartout},
				{text: '暗角透明度 +', fn: function() { passeAlpha = Math.min(1, Math.round((passeAlpha + 0.1) * 10) / 10); showStatus('暗角透明度 ' + Std.int(passeAlpha * 100) + '%'); }},
				{text: '暗角透明度 -', fn: function() { passeAlpha = Math.max(0.1, Math.round((passeAlpha - 0.1) * 10) / 10); showStatus('暗角透明度 ' + Std.int(passeAlpha * 100) + '%'); }},
				{text: '镜头节拍抖动', fn: function() { doBopping = !doBopping; showStatus(doBopping ? '已开启镜头节拍抖动' : '已关闭镜头节拍抖动'); }},
				{text: '扩展边界', fn: toggleExtendedBounds},
				{text: '重置相机滚动 (Ctrl+R)', fn: resetCameraScroll},
				{text: '重置相机缩放 (Ctrl+G)', fn: resetCameraZoom},
				{text: '重置预览缩放', fn: function() previewZoom = 0.55},
				{text: '重置时间轴缩放', fn: function() pxPerMs = 0.05},
				{text: '%DURUNIT%', fn: function() setDurationUnit(!durationSteps)}
			]},
			{label: '播放', items: [
				{text: '播放/暂停 (空格)', fn: togglePlayback},
				{text: '回到开头', fn: function() seekMusic(0)},
				{text: '跳到末尾', fn: function() seekMusic(songEndMs)},
				{text: '箭头预览开关', fn: toggleStrumPreview}
			]},
			{label: '编辑', items: [
				{text: '%UNDO%', fn: doUndo},
				{text: '%REDO%', fn: doRedo},
				{text: '复制选中 (Ctrl+C)', fn: copySelected},
				{text: '剪切选中 (Ctrl+X)', fn: cutSelected},
				{text: '粘贴到播放头 (Ctrl+V)', fn: pasteClipboard},
				{text: '快速复制 (Ctrl+D)', fn: duplicateSelected},
				{text: '删除选中 (Del)', fn: deleteSelected},
				{text: '全选 (Ctrl+A)', fn: selectAllEvents},
				{text: '添加事件 (N)', fn: addEventAtPlayhead},
				{text: '添加事件菜单 (Shift+A)', fn: function() openAddEventMenu(previewCursorMs, false)}
			]},
			{label: '生成', items: [
				{text: '自动生成运镜', fn: function() autoGenOpen = true},
				{text: '按类型自动排序图层', fn: autoSortLayersByType},
				{text: '清空所有事件', fn: clearAllEvents},
				{text: '重置为默认单层', fn: resetToSingleLayer}
			]},
			{label: '帮助', items: [
				{text: '欢迎', fn: function() welcomeOpen = true},
				{text: '关于', fn: function() aboutOpen = true},
				{text: '按键设置', fn: function() keybindOpen = true},
				{text: '自定义层', fn: function() customLayerOpen = true},
				{text: '使用说明 (F1)', fn: function() helpOpen = true}
			]}
		];

		var mx:Int = 188;
		for(def in menuDefs)
		{
			var btn:PsychUIButton = new PsychUIButton(mx, 13, def.label, function() toggleMenu(def.label), 60, 22);
			btn.scrollFactor.set();
			add(btn);
			menuButtons.push(btn);
			mx += 64;
		}

		quantText = new FlxText(FlxG.width - 300, 32, 290, '吸附: 1拍 (Q/E)', fs(11));
		quantText.setFormat(Paths.font(Language.pickFont(quantText.text)), fs(11), 0xFFA9D1F5);
		quantText.alignment = RIGHT;
		quantText.scrollFactor.set();
		add(quantText);

		menuPanel = new FlxSprite(0, topH + 2);
		UITheme.drawPanel(menuPanel, 230, 40, 0xE61B1B1B);
		menuPanel.scrollFactor.set();
		menuPanel.visible = false;
		add(menuPanel);
	}

	function toggleMenu(label:String):Void
	{
		if(menuOpen == label)
		{
			closeMenu();
			return;
		}
		menuOpen = label;
		sfx('ClickDown', 0.7);
		rebuildMenuPanel();
	}

	function closeMenu():Void
	{
		if(menuOpen != null) sfx('ClickUp', 0.7);
		menuOpen = null;
		if(menuPanel != null) menuPanel.visible = false;
		clearMenuItems();
	}

	function clearMenuItems():Void
	{
		for(t in menuItemTexts)
		{
			if(t == null) continue;
			remove(t);
			t.destroy();
		}
		menuItemTexts = [];
		menuItemFns = [];
	}

	function rebuildMenuPanel():Void
	{
		if(menuOpen == null) return;
		if(menuPanel != null) menuPanel.visible = false;
		clearMenuItems();
		if(menuPanel != null)
		{
			if(remove(menuPanel) != null) add(menuPanel);
		}
		var def:{label:String, items:Array<{text:String, fn:Void->Void}>} = null;
		for(d in menuDefs)
		{
			if(d.label == menuOpen)
			{
				def = d;
				break;
			}
		}
		if(def == null) return;

		var idx:Int = -1;
		for(i in 0...menuButtons.length)
		{
			if(menuButtons[i].label == menuOpen)
			{
				idx = i;
				break;
			}
		}
		if(idx < 0) return;

		var px:Float = menuButtons[idx].x;
		menuItemH = Std.int(22 * Math.min(uiScale, 1.25));
		UITheme.drawPanel(menuPanel, 300, Std.int(def.items.length * menuItemH) + 10, 0xE61B1B1B);
		menuPanel.x = px;
		menuPanel.y = menuButtons[idx].y + menuButtons[idx].height + 2;
		menuPanel.visible = true;

		for(i in 0...def.items.length)
		{
			var it:FlxText = new FlxText(px + 10, menuPanel.y + 5 + i * menuItemH, 240, menuItemText(def.items[i].text), fs(11));
			it.setFormat(Paths.font(Language.pickFont(it.text)), fs(11), FlxColor.WHITE);
			it.scrollFactor.set();
			add(it);
			menuItemTexts.push(it);
			menuItemFns.push(def.items[i].fn);
		}
	}

	function menuItemText(raw:String):String
	{
		if(raw == '%UNDO%')
			return (undoNames.length > 0) ? '撤销 ' + undoNames[undoNames.length - 1] + '  (Ctrl+Z)' : '撤销 (Ctrl+Z)';
		if(raw == '%REDO%')
			return (redoNames.length > 0) ? '重做 ' + redoNames[redoNames.length - 1] + '  (Ctrl+Y)' : '重做 (Ctrl+Y)';
		if(raw == '%DURUNIT%')
			return durationSteps ? '时长单位：步（点击切回秒）' : '时长单位：秒（点击切回步）';
		return raw;
	}

	function handleMenuClick():Bool
	{
		if(menuOpen == null) return false;
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		if(menuPanel != null && menuPanel.visible && mx >= menuPanel.x && mx <= menuPanel.x + menuPanel.width && my >= menuPanel.y && my <= menuPanel.y + menuPanel.height)
		{
			var li:Int = Std.int((my - menuPanel.y - 5) / menuItemH);
			if(li >= 0 && li < menuItemFns.length)
			{
				var fn:Void->Void = menuItemFns[li];
				closeMenu();
				if(fn != null) fn();
			}
			return true;
		}
		var zoneBottom:Float = (menuPanel != null) ? (menuPanel.y + menuPanel.height + 4) : (topH + 4);
		if(my < zoneBottom)
		{
			var overBtn:Bool = false;
			for(b in menuButtons)
			{
				if(b != null && mx >= b.x && mx <= b.x + b.width && my >= b.y && my <= b.y + b.height)
				{
					overBtn = true;
					break;
				}
			}
			if(!overBtn) closeMenu();
			return true;
		}
		return false;
	}

	function togglePassepartout():Void
	{
		showPassepartout = !showPassepartout;
		showStatus(showPassepartout ? '已开启取景框暗角' : '已关闭取景框暗角');
	}

	function toggleExtendedBounds():Void
	{
		showExtendedBounds = !showExtendedBounds;
		showStatus(showExtendedBounds ? '已开启扩展边界' : '已关闭扩展边界');
	}

	function toggleStrumPreview():Void
	{
		strumPreviewVisible = !strumPreviewVisible;
		refreshStrumPreview();
		showStatus(strumPreviewVisible ? '已显示箭头预览' : '已隐藏箭头预览');
	}

	function selectAllEvents():Void
	{
		selectedIndexes = [for(i in 0...events.length) i];
		rebuildEventSprites();
		refreshPanel();
		showStatus('已全选 ${events.length} 个事件');
	}

	function onAutoScrollChanged(i:Int):Void
	{
		autoScrollMode = Std.int(Math.max(0, Math.min(2, i)));
		if(autoScrollBox != null) autoScrollBox.checked = (autoScrollMode != 0);
	}

	function refreshSnapIcon():Void
	{
		if(snapBtnSprite == null) return;
		var shift:Bool = FlxG.keys.pressed.SHIFT;
		var eff:Bool = (snapEnabled != shift);
		var st:Int = (shift ? 2 : 0) + (eff ? 1 : 0);
		if(st == snapIconState) return;
		snapIconState = st;
		var key:String = shift
			? (eff ? 'ui/camera-editor/magnet_shift_on' : 'ui/camera-editor/magnet_shift_off')
			: (eff ? 'ui/camera-editor/magnet_snap_on' : 'ui/camera-editor/magnet_snap_off');
		snapBtnSprite.loadGraphic(Paths.image(key));
	}

	function buildTimelineToolbar():Void
	{
		toolbarBg = new FlxSprite(0, timelineTop).makeGraphic(FlxG.width, toolbarH, 0xFF3A3A3A);
		toolbarBg.scrollFactor.set();
		add(toolbarBg);

		toolbarTimeText = new FlxText(10, timelineTop + 9, 150, '0:00.00/0:00.00', fs(12));
		toolbarTimeText.setFormat(Paths.font('Helvetica.ttf'), fs(12), FlxColor.WHITE);
		toolbarTimeText.scrollFactor.set();
		add(toolbarTimeText);

		playBtnSprite = new FlxSprite(172, timelineTop + 6).loadGraphic(Paths.image('ui/camera-editor/play'));
		playBtnSprite.scrollFactor.set();
		add(playBtnSprite);

		autoScrollLabel = new FlxText(214, timelineTop + 9, 76, 'Auto-scroll:', fs(11));
		autoScrollLabel.setFormat(Paths.font('Helvetica.ttf'), fs(11), 0xFFB9B9B9);
		autoScrollLabel.scrollFactor.set();
		add(autoScrollLabel);

		autoScrollDrop = new PsychUIDropDownMenu(292, timelineTop + 9, AUTO_SCROLL_LABELS, function(i:Int, t:String) onAutoScrollChanged(i), 160);
		autoScrollDrop.scrollFactor.set();
		autoScrollDrop.selectedIndex = autoScrollMode;
		add(autoScrollDrop);

		snapBtnSprite = new FlxSprite(468, timelineTop + 6).loadGraphic(Paths.image('ui/camera-editor/magnet_snap_on'));
		snapBtnSprite.scrollFactor.set();
		add(snapBtnSprite);
		refreshSnapIcon();

		zoomLabel = new FlxText(500, timelineTop + 9, 44, 'Zoom:', fs(11));
		zoomLabel.setFormat(Paths.font('Helvetica.ttf'), fs(11), 0xFFB9B9B9);
		zoomLabel.scrollFactor.set();
		add(zoomLabel);

		zoomSlider = new PsychUISlider(556, timelineTop + 8, function(v:Float) pxPerMs = Math.max(0.005, v * 0.05), Math.max(0.1, Math.min(5.0, pxPerMs / 0.05)), 0.1, 5.0, 170);
		zoomSlider.scrollFactor.set();
		zoomSlider.minText.visible = false;
		zoomSlider.maxText.visible = false;
		add(zoomSlider);

		scrollbarBg = new FlxSprite(0, timelineTop + toolbarH).makeGraphic(FlxG.width, scrollbarH, 0xFF2A2A2A);
		scrollbarBg.scrollFactor.set();
		add(scrollbarBg);

		scrollbarThumb = new FlxSprite(timelineX, timelineTop + toolbarH + 2).makeGraphic(60, scrollbarH - 4, 0xFF5A5A5A);
		scrollbarThumb.scrollFactor.set();
		add(scrollbarThumb);

		scrollbarPlayheadMark = new FlxSprite(0, timelineTop + toolbarH + 3).makeGraphic(3, scrollbarH - 6, 0xFFFFFFFF);
		scrollbarPlayheadMark.scrollFactor.set();
		add(scrollbarPlayheadMark);
	}

	function positionTimelineToolbar():Void
	{
		if(toolbarBg == null) return;
		toolbarBg.y = timelineTop;
		if(toolbarTimeText != null) toolbarTimeText.y = timelineTop + 9;
		if(playBtnSprite != null) playBtnSprite.y = timelineTop + 6;
		if(autoScrollLabel != null) autoScrollLabel.y = timelineTop + 9;
		if(autoScrollDrop != null) autoScrollDrop.y = timelineTop + 9;
		if(snapBtnSprite != null) snapBtnSprite.y = timelineTop + 6;
		if(zoomLabel != null) zoomLabel.y = timelineTop + 9;
		if(zoomSlider != null) zoomSlider.y = timelineTop + 8;
		if(scrollbarBg != null) scrollbarBg.y = timelineTop + toolbarH;
		if(scrollbarThumb != null) scrollbarThumb.y = timelineTop + toolbarH + 2;
		if(scrollbarPlayheadMark != null) scrollbarPlayheadMark.y = timelineTop + toolbarH + 3;
	}

	function buildTimeline():Void
	{
		var bgX:Int = 0;
		var bgY:Int = timelineTop;
		var bgW:Int = FlxG.width;
		var bgH:Int = Std.int(Math.max(60, timelineAreaH));

		timelineBg = new FlxSprite(bgX, bgY).makeGraphic(bgW, bgH, 0xFF1E1E1E);
		timelineBg.scrollFactor.set();
		add(timelineBg);

		for(i in 0...300)
		{
			var line:FlxSprite = new FlxSprite(0, tlTop + rulerH).makeGraphic(1, 1, 0xFF3A3A3A);
			line.scrollFactor.set();
			line.origin.set(0, 0);
			line.scale.y = Math.max(1, timelineTop + timelineAreaH - (tlTop + rulerH));
			line.visible = false;
			add(line);
			gridLines.push(line);
		}

		rulerBg = new FlxSprite(0, tlTop).makeGraphic(FlxG.width, rulerH, 0xFF2A2A2A);
		rulerBg.scrollFactor.set();
		add(rulerBg);

		for(i in 0...60)
		{
			var lbl:FlxText = new FlxText(0, tlTop + 6, 60, '', fs(10));
			lbl.setFormat(Paths.font('Helvetica.ttf'), fs(10), 0xFFB9B9B9);
			lbl.scrollFactor.set();
			lbl.visible = false;
			add(lbl);
			rulerLabels.push(lbl);
		}

		for(layer in 0...CameraEditorData.layerCount())
		{
			var y:Float = tlTop + rulerH + layer * layerH;

			var line:FlxSprite = new FlxSprite(0, y).makeGraphic(FlxG.width, 1, 0xFF333333);
			line.scrollFactor.set();
			add(line);
			timelineLayerUI.push(line);

			var lblBg:FlxSprite = new FlxSprite(0, y).makeGraphic(layerLabelW, layerH, 0xCC242424);
			lblBg.scrollFactor.set();
			add(lblBg);
			timelineLayerUI.push(lblBg);
			layerLabelBgs.push(lblBg);

			var color:FlxColor = CameraEditorData.layerColor(layer);
			var colorBar:FlxSprite = new FlxSprite(0, y).makeGraphic(4, layerH, color);
			colorBar.scrollFactor.set();
			add(colorBar);
			timelineLayerUI.push(colorBar);
			layerColorBars.push(colorBar);

			var lbl:FlxText = new FlxText(8, y + layerH/2 - 8, layerLabelW - 30, CameraEditorData.layerName(layer), fs(12));
			lbl.setFormat(Paths.font(Language.pickFont(lbl.text)), fs(12), color);
			lbl.scrollFactor.set();
			add(lbl);
			layerLabelTexts.push(lbl);
			timelineLayerUI.push(lbl);

			var eye:FlxSprite = new FlxSprite(layerLabelW - 22, y + layerH/2 - 7).makeGraphic(16, 14, color);
			eye.scrollFactor.set();
			add(eye);
			layerEyeBoxes.push(eye);
			timelineLayerUI.push(eye);
		}
		if(layerVisible.length != CameraEditorData.layerCount())
		{
			layerVisible = [for(_ in 0...CameraEditorData.layerCount()) true];
			if(CameraEditorData.layerCount() > 0) layerVisible[0] = true;
		}

		rightLine = new FlxSprite(timelineRight, timelineTop).makeGraphic(2, 1, 0xFF4A4A4A);
		rightLine.scrollFactor.set();
		rightLine.origin.set(0, 0);
		rightLine.scale.y = Math.max(1, timelineAreaH);
		add(rightLine);

		var lbDefs:Array<{t:String, fn:Void->Void}> = [
			{t: '＋层', fn: addLayerAtEnd},
			{t: '－层', fn: removeSelectedLayer},
			{t: '↑', fn: function() moveSelectedLayer(-1)},
			{t: '↓', fn: function() moveSelectedLayer(1)}
		];
		var lbw:Int = Std.int((layerLabelW - 8) / 4) - 3;
		var lbx:Int = 5;
		for(d in lbDefs)
		{
			var lb:PsychUIButton = new PsychUIButton(lbx, tlTop + 3, d.t, d.fn, lbw, rulerH - 6);
			lb.scrollFactor.set();
			add(lb);
			layerRowBtns.push(lb);
			lbx += lbw + 3;
		}

		boxRect = new FlxSprite(0, 0).makeGraphic(10, 10, 0xFF5BA3FF);
		boxRect.alpha = 0.25;
		boxRect.scrollFactor.set();
		boxRect.visible = false;
		add(boxRect);

		hintText = new FlxText(10, timelineTop + timelineAreaH - 32, FlxG.width - 20,
			'空格=播放  双击=跳转  Ctrl+双击=按该行类型添加事件  空白拖拽=框选  Ctrl+点击=多选  拖拽=移动  两端=拉长\n滚轮=缩放时间轴  Ctrl+滚轮=平移  Shift+滚轮=缩放取景框(长按)  按住Shift拖拽=自由放置(无吸附)  预览区滚轮=镜头远近  ,/.=加对手/玩家Focus  M=书签  右键空白=添加事件菜单(Shift+A)  右键事件/Delete=删除  F=定位  Q/E=吸附精度  磁铁按钮=吸附开关  A/D=平移',
			fs(9));
		hintText.setFormat(Paths.font(Language.pickFont(hintText.text)), fs(9), 0xFFB9B9B9);
		hintText.scrollFactor.set();
		add(hintText);

		refreshLayerVisibility();
	}

	function refreshLayerVisibility():Void
	{
		var n:Int = CameraEditorData.layerCount();
		for(layer in 0...n)
		{
			var vis:Bool = (layer < layerVisible.length) ? layerVisible[layer] : true;
			var color:FlxColor = CameraEditorData.layerColor(layer);
			if(layer < layerEyeBoxes.length)
			{
				var eye:FlxSprite = layerEyeBoxes[layer];
				eye.makeGraphic(16, 14, vis ? color : 0xFF5A5A5A);
				eye.alpha = vis ? 1 : 0.45;
			}
			if(layer < layerLabelBgs.length) layerLabelBgs[layer].alpha = vis ? 1 : 0.4;
			if(layer < layerLabelTexts.length) layerLabelTexts[layer].alpha = vis ? 1 : 0.4;
			if(layer < layerColorBars.length) layerColorBars[layer].alpha = vis ? 1 : 0.25;
		}
		updateEventSpritePositions();
	}

	function addLayerAtEnd():Void
	{
		var idx:Int = CameraEditorData.addLayer('', '', CameraEditorData.nextLayerColor());
		selectedLayer = idx;
		layerVisible.push(true);
		rebuildTimelineLayers();
		refreshRulerPositions();
		showStatus('已添加图层 ' + CameraEditorData.layerName(idx));
	}

	function removeSelectedLayer():Void
	{
		if(CameraEditorData.layerCount() <= 1)
		{
			showStatus('至少保留一个图层');
			return;
		}
		openDeleteLayer(selectedLayer);
	}

	function openDeleteLayer(id:Int):Void
	{
		var idx:Int = CameraEditorData.layerIndex(id);
		if(idx < 0 || CameraEditorData.layerCount() <= 1)
		{
			showStatus('至少保留一个图层');
			return;
		}
		if(CameraEditorData.isDefaultLayer(idx))
		{
			showStatus('Default 图层受保护，不能删除');
			return;
		}
		deleteLayerTarget = id;
		var cnt:Int = 0;
		for(ev in events) if(ev.layer == idx) cnt++;
		if(deleteLayerText != null)
			deleteLayerText.text = '删除图层 "' + CameraEditorData.layerName(id) + '" ？\n\n该图层当前包含 ' + cnt + ' 个事件。请选择处理方式：\n\n取消 = 什么都不做\n移到 Default = 保留事件并归入默认层\n连事件一起删除 = 永久移除这些事件';
		deleteLayerOpen = true;
	}

	function performDeleteLayer(mode:Int):Void
	{
		deleteLayerOpen = false;
		if(mode == 0) return;
		var idx:Int = CameraEditorData.layerIndex(deleteLayerTarget);
		if(idx < 0 || CameraEditorData.layerCount() <= 1)
		{
			showStatus('至少保留一个图层');
			return;
		}
		if(CameraEditorData.isDefaultLayer(idx))
		{
			showStatus('Default 图层受保护，不能删除');
			return;
		}
		pushUndo(mode == 2 ? '删除图层与事件' : '删除图层(合并到 Default)');
		var moved:Int = 0;
		var removed:Int = 0;
		if(mode == 2)
		{
			var keep:Array<EdEvent> = [];
			for(ev in events)
			{
				if(ev.layer == idx) { removed++; continue; }
				if(ev.layer > idx) ev.layer--;
				keep.push(ev);
			}
			events = keep;
		}
		else
		{
			for(ev in events)
			{
				if(ev.layer == idx) { ev.layer = 0; moved++; }
				else if(ev.layer > idx) ev.layer--;
			}
		}
		CameraEditorData.removeLayer(idx);
		if(idx < layerVisible.length) layerVisible.splice(idx, 1);
		selectedLayer = Std.int(Math.max(0, Math.min(idx - 1, CameraEditorData.layerCount() - 1)));
		clearSelection();
		syncData();
		rebuildEventSprites();
		rebuildTimelineLayers();
		refreshRulerPositions();
		refreshPanel();
		showStatus(mode == 2 ? '已删除图层与 ' + removed + ' 个事件' : '已删除图层，' + moved + ' 个事件移到 Default');
	}

	function openRenameLayer(id:Int):Void
	{
		var idx:Int = CameraEditorData.layerIndex(id);
		if(idx < 0) return;
		if(CameraEditorData.isDefaultLayer(idx))
		{
			showStatus('Default 图层受保护，不能重命名');
			return;
		}
		renameLayerTarget = id;
		if(renameLayerInput != null) renameLayerInput.text = CameraEditorData.layerName(id);
		renameLayerOpen = true;
	}

	function performRenameLayer():Void
	{
		renameLayerOpen = false;
		var nm:String = StringTools.trim(renameLayerInput.text);
		if(nm.length < 1)
		{
			showStatus('层名不能为空');
			return;
		}
		var idx:Int = CameraEditorData.layerIndex(renameLayerTarget);
		if(idx < 0) return;
		CameraEditorData.renameLayer(idx, nm);
		rebuildTimelineLayers();
		refreshRulerPositions();
		showStatus('图层已重命名为 ' + nm);
	}

	function moveSelectedLayer(dir:Int):Void
	{
		var idx:Int = CameraEditorData.layerIndex(selectedLayer);
		if(!CameraEditorData.moveLayer(idx, dir))
		{
			showStatus(dir < 0 ? '已经在最上面' : '已经在最下面');
			return;
		}
		var tgt:Int = idx + dir;
		for(ev in events)
		{
			if(ev.layer == idx) ev.layer = tgt;
			else if(ev.layer == tgt) ev.layer = idx;
		}
		var tv:Bool = layerVisible[idx];
		layerVisible[idx] = layerVisible[tgt];
		layerVisible[tgt] = tv;
		selectedLayer = tgt;
		syncData();
		rebuildTimelineLayers();
		refreshRulerPositions();
		showStatus('已' + (dir < 0 ? '上移' : '下移') + '图层');
	}

	function buildPanel():Void
	{
		if(panelAX == 0) panelAX = FlxG.width - rightW - 16;
		if(panelAY == 0) panelAY = topH + 8;
		if(panelBX == 0) panelBX = FlxG.width - rightW - 16;
		if(panelBY == 0) panelBY = topH + 320;
		panelPS = Math.min(uiScale, 1.25);
		var px:Float = panelAX + 12;
		var lw:Int = rightW - 24;
		panelH_A = Std.int(Math.min(620, Math.max(540, timelineTop - topH - 14)));

		panelBg = new FlxSprite(panelAX, panelAY);
		UITheme.drawPanel(panelBg, rightW, panelH_A, 0xE6191919);
		panelBg.scrollFactor.set();
		add(panelBg);

		panelTitle = new FlxText(panelAX + 12, panelAY + 8, rightW - 24, '事件属性（按住标题拖动）', fs(14));
		panelTitle.setFormat(Paths.font(Language.pickFont(panelTitle.text)), fs(14), FlxColor.WHITE);
		panelTitle.scrollFactor.set();
		add(panelTitle);

		var lbl1:FlxText = new FlxText(px, psy(36), lw, '事件类型', fs(12));
		lbl1.setFormat(Paths.font(Language.pickFont(lbl1.text)), fs(12), 0xFFB9B9B9);
		lbl1.scrollFactor.set();
		add(lbl1);
		panelALabels.push(lbl1);

		typeDropdown = new PsychUIDropDownMenu(px, psy(54), CameraEditorData.builtinEvents(), function(idx:Int, label:String) onTypeChanged(), lw);
		typeDropdown.scrollFactor.set();
		add(typeDropdown);

		var lbl2:FlxText = new FlxText(px, psy(88), lw, '时间 (ms)', fs(12));
		lbl2.setFormat(Paths.font(Language.pickFont(lbl2.text)), fs(12), 0xFFB9B9B9);
		lbl2.scrollFactor.set();
		add(lbl2);
		panelALabels.push(lbl2);

		timeInput = new PsychUIInputText(px, psy(106), lw, '', 12);
		timeInput.scrollFactor.set();
		timeInput.onChange = function(old:String, cur:String) onTimeChanged(cur);
		add(timeInput);

		var lbl3:FlxText = new FlxText(px, psy(138), lw, '值 1', fs(12));
		lbl3.setFormat(Paths.font(Language.pickFont(lbl3.text)), fs(12), 0xFFB9B9B9);
		lbl3.scrollFactor.set();
		add(lbl3);
		panelALabels.push(lbl3);

		v1Input = new PsychUIInputText(px, psy(156), lw, '', 12);
		v1Input.scrollFactor.set();
		v1Input.onChange = function(old:String, cur:String) onV1Changed(cur);
		add(v1Input);

		var lbl4:FlxText = new FlxText(px, psy(188), lw, '值 2', fs(12));
		lbl4.setFormat(Paths.font(Language.pickFont(lbl4.text)), fs(12), 0xFFB9B9B9);
		lbl4.scrollFactor.set();
		add(lbl4);
		panelALabels.push(lbl4);

		v2Input = new PsychUIInputText(px, psy(206), lw, '', 12);
		v2Input.scrollFactor.set();
		v2Input.onChange = function(old:String, cur:String) onV2Changed(cur);
		add(v2Input);

		var rowY:Array<Float> = [psy(150), psy(184), psy(218)];
		for(i in 0...3)
		{
			var lb:FlxText = new FlxText(px, rowY[i] + 4, 96, '值', 12);
			lb.setFormat(Paths.font(Language.pickFont(lb.text)), fs(12), 0xFFB9B9B9);
			lb.text = '';
			lb.scrollFactor.set();
			lb.visible = false;
			add(lb);
			pLb.push(lb);
		}
		var clx:Float = px + 100;
		var clw:Int = lw - 100;
		var halfClw:Int = Std.int((clw - 8) / 2);

		fcTarget = new PsychUIDropDownMenu(clx, rowY[0], ['boyfriend', 'dad', 'girlfriend', 'pos'], function(i:Int, t:String) onSpecChanged(), clw);
		fcX = new PsychUINumericStepper(clx, rowY[1], 10, 0, -99999, 99999, 0, halfClw);
		fcY = new PsychUINumericStepper(clx + halfClw + 8, rowY[1], 10, 0, -99999, 99999, 0, halfClw);
		fcDur = new PsychUINumericStepper(clx, rowY[2], 0.1, 2, 0, 60, 1, clw);

		zcZoom = new PsychUINumericStepper(clx, rowY[0], 0.05, 1, 0.1, 5, 2, clw);
		zcDur = new PsychUINumericStepper(clx, rowY[1], 0.1, 2, 0, 60, 1, clw);
		zcMode = new PsychUIDropDownMenu(clx, rowY[2], ['Stage', 'Absolute'], function(i:Int, t:String) onSpecChanged(), clw);

		paTarget = new PsychUIDropDownMenu(clx, rowY[0], ['boyfriend', 'dad', 'girlfriend'], function(i:Int, t:String) onSpecChanged(), clw);
		paAnim = new PsychUIDropDownMenu(clx, rowY[1], ['idle'], function(i:Int, t:String) onSpecChanged(), clw);

		azA = new PsychUINumericStepper(clx, rowY[0], 0.005, 0.015, 0, 1, 3, clw);
		azB = new PsychUINumericStepper(clx, rowY[1], 0.005, 0.03, 0, 1, 3, clw);

		fpX = new PsychUINumericStepper(clx, rowY[0], 10, 0, -99999, 99999, 0, clw);
		fpY = new PsychUINumericStepper(clx, rowY[1], 10, 0, -99999, 99999, 0, clw);
		fpDur = new PsychUINumericStepper(clx, rowY[2], 0.1, 0.5, 0, 60, 1, clw);

		anAngle = new PsychUINumericStepper(clx, rowY[0], 1, 0, -360, 360, 0, clw);
		anDur = new PsychUINumericStepper(clx, rowY[1], 0.1, 0.3, 0, 60, 1, clw);

		for(c in [fcTarget, fcX, fcY, fcDur, zcZoom, zcDur, zcMode, paTarget, paAnim, azA, azB, fpX, fpY, fpDur, anAngle, anDur])
		{
			c.scrollFactor.set();
			c.visible = false;
			add(c);
		}
		for(s in [fcX, fcY, fcDur, zcZoom, zcDur, azA, azB, fpX, fpY, fpDur, anAngle, anDur])
		{
			s.broadcastStepperEvent = false;
			s.onValueChange = onSpecChanged;
		}

		if(customCurve.length == 0) customCurve = CustomEase.defaultCurve();
		curveEditorX = px;
		curveEditorY = psy(244) + 20;
		curveEditorW = lw - (EASE_GRAPH_W + EASE_STRIP_W + 16);
		curveEditorH = 74;
		curveEditorBg = new FlxSprite(curveEditorX, curveEditorY);
		UITheme.drawPanel(curveEditorBg, Std.int(curveEditorW), Std.int(curveEditorH), 0xFF10161A, 0x884F8DF9, 8);
		curveEditorBg.scrollFactor.set();
		curveEditorBg.visible = false;
		add(curveEditorBg);
		curveLine = new FlxSprite(curveEditorX, curveEditorY);
		curveLine.scrollFactor.set();
		curveLine.visible = false;
		add(curveLine);
		curveHandles = [];
		for(i in 0...CustomEase.SAMPLES)
		{
			var h:FlxSprite = new FlxSprite(0, 0).makeGraphic(12, 12, FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawCircle(h, 6, 6, 5, 0xFF7ABFBC);
			FlxSpriteUtil.drawCircle(h, 6, 6, 2, 0xFFD8FFF9);
			h.dirty = true;
			h.scrollFactor.set();
			h.visible = false;
			add(h);
			curveHandles.push(h);
		}

		panelInfo = new FlxText(px, psy(244), lw, '', fs(11));
		panelInfo.setFormat(Paths.font(Language.pickFont(panelInfo.text)), fs(11), 0xFF9AC8F5);
		panelInfo.scrollFactor.set();
		add(panelInfo);

		panelAHideBtn = new PsychUIButton(panelAX + rightW - 76, panelAY + 5, '收起', function() onHidePanelA(), 64, 20);
		panelAHideBtn.scrollFactor.set();
		add(panelAHideBtn);

		panelBgB = new FlxSprite(panelBX, panelBY);
		UITheme.drawPanel(panelBgB, rightW, panelH_B, 0xE6191919);
		panelBgB.scrollFactor.set();
		add(panelBgB);

		panelTitleB = new FlxText(panelBX + 12, panelBY + 8, rightW - 24, '操作（按住标题拖动）', fs(14));
		panelTitleB.setFormat(Paths.font(Language.pickFont(panelTitleB.text)), fs(14), FlxColor.WHITE);
		panelTitleB.scrollFactor.set();
		add(panelTitleB);

		var halfW:Int = Std.int((lw - 10) / 2);
		var opsY:Float = panelAY + panelH_A - 122;
		addBtn = new PsychUIButton(px, opsY, '添加事件（播放头）', function() addEventAtPlayhead(), lw, 24);
		addBtn.scrollFactor.set();
		add(addBtn);

		dupBtn = new PsychUIButton(px, opsY + 30, '复制 (Ctrl+C)', function() copySelected(), halfW, 24);
		dupBtn.scrollFactor.set();
		add(dupBtn);

		delBtn = new PsychUIButton(px + halfW + 10, opsY + 30, '删除 (Del)', function() deleteSelected(), halfW, 24);
		delBtn.scrollFactor.set();
		add(delBtn);

		playBtn = new PsychUIButton(px, opsY + 60, '播放/暂停', function() togglePlayback(), halfW, 24);
		playBtn.scrollFactor.set();
		add(playBtn);

		pasteBtn = new PsychUIButton(px + halfW + 10, opsY + 60, '粘贴 (Ctrl+V)', function() pasteClipboard(), halfW, 24);
		pasteBtn.scrollFactor.set();
		add(pasteBtn);

		shaderCheckBox = new PsychUICheckBox(px, opsY + 92, '着色器 (G)', halfW, function()
		{
			applyShaderSuspend(!shaderCheckBox.checked);
		});
		shaderCheckBox.scrollFactor.set();
		shaderCheckBox.checked = shaderEnabledPref;
		add(shaderCheckBox);

		strumCheckBox = new PsychUICheckBox(px, opsY + 92, '箭头预览', halfW, function()
		{
			showStatus('箭头预览已移除');
		});
		strumCheckBox.scrollFactor.set();
		strumCheckBox.checked = false;
		strumCheckBox.visible = false;
		add(strumCheckBox);

		autoScrollBox = new PsychUICheckBox(px + halfW + 10, opsY + 92, '播放自动滚动', halfW, function()
		{
			autoScrollMode = autoScrollBox.checked ? 2 : 0;
			if(autoScrollDrop != null) autoScrollDrop.selectedIndex = autoScrollMode;
		});
		autoScrollBox.scrollFactor.set();
		autoScrollBox.checked = (autoScrollMode != 0);
		add(autoScrollBox);

		var halfW2:Int = Std.int((lw - 8) / 2);
		easeTitle = new FlxText(px, psy(306), lw, '缓动曲线（基础 × 方向）', fs(12));
		easeTitle.setFormat(Paths.font(Language.pickFont(easeTitle.text)), fs(12), 0xFFB9B9B9);
		easeTitle.scrollFactor.set();
		easeTitle.visible = false;
		add(easeTitle);

		easeGraphFrame = new FlxSprite(px, psy(346));
		UITheme.drawPanel(easeGraphFrame, EASE_GRAPH_W + 2, EASE_GRAPH_W + 2, 0xFF3A3A3A, 0x884F8DF9, 8);
		easeCurveBg = new FlxSprite(px + 1, psy(347));
		UITheme.drawPanel(easeCurveBg, EASE_GRAPH_W, EASE_GRAPH_W, 0xFF202223, 0x884F8DF9, 8);
		easeRef1 = new FlxSprite(0, 0).makeGraphic(EASE_GRAPH_W, 1, 0xFF404040);
		easeRef0 = new FlxSprite(0, 0).makeGraphic(EASE_GRAPH_W, 1, 0xFF404040);
		easeDotFrame = new FlxSprite(px + EASE_GRAPH_W + 6, psy(346));
		UITheme.drawPanel(easeDotFrame, EASE_STRIP_W + 2, EASE_GRAPH_W + 2, 0xFF3A3A3A, 0x884F8DF9, 8);
		easeDotStrip = new FlxSprite(px + EASE_GRAPH_W + 7, psy(347));
		UITheme.drawPanel(easeDotStrip, EASE_STRIP_W, EASE_GRAPH_W, 0xFF202223, 0x884F8DF9, 8);

		for(s in [easeGraphFrame, easeCurveBg, easeRef1, easeRef0, easeDotFrame, easeDotStrip])
		{
			s.scrollFactor.set();
			s.visible = false;
			add(s);
		}

		easeCurveBars = [];
		for(i in 0...EASE_GRAPH_W)
		{
			var bar:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFFFFFFFF);
			bar.scrollFactor.set();
			bar.origin.set(0, 0);
			bar.offset.set(0, 0);
			bar.visible = false;
			add(bar);
			easeCurveBars.push(bar);
		}

		easeDot = new FlxSprite(0, 0).makeGraphic(7, 7, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawCircle(easeDot, 3, 3, 3, FlxColor.WHITE);
		easeDot.scrollFactor.set();
		easeDot.visible = false;
		add(easeDot);

		easeBase = new PsychUIDropDownMenu(px, psy(392), EASE_UI_FOCUS, function(i:Int, t:String) onEaseChanged(), halfW2);
		easeBase.scrollFactor.set();
		easeBase.visible = false;
		add(easeBase);

		easeDir = new PsychUIDropDownMenu(px + halfW2 + 8, psy(392), EASE_DIRS, function(i:Int, t:String) onEaseChanged(), halfW2);
		easeDir.scrollFactor.set();
		easeDir.visible = false;
		add(easeDir);

		movePanelA();
		movePanelB();
		setPanelAVisible(false);
	}

	function buildAutoGenPanel():Void
	{
		var k:Float = Math.min(uiScale, 1.5);
		var w:Int = Std.int(440 * k);
		var h:Int = Std.int(260 * k);
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 120;

		autoGenBg = new FlxSprite(x, y);
		UITheme.drawPanel(autoGenBg, w, h, 0xFF222222);
		autoGenBg.scrollFactor.set();
		autoGenBg.visible = false;
		add(autoGenBg);

		var t:FlxText = new FlxText(x + 14 * k, y + 10 * k, w - 28 * k, '自动生成摄像机事件', fs(16));
		t.setFormat(Paths.font(Language.pickFont(t.text)), fs(16), FlxColor.WHITE);
		t.scrollFactor.set();
		t.visible = false;
		add(t);
		autoGenLabels.push(t);

		focusGenCheck = new PsychUICheckBox(x + 14 * k, y + 48 * k, '按小节生成 Focus 切换（跟随谱面段落）', Std.int((w - 28 * k) / k));
		focusGenCheck.scrollFactor.set();
		focusGenCheck.visible = false;
		add(focusGenCheck);

		zoomGenCheck = new PsychUICheckBox(x + 14 * k, y + 84 * k, '按拍生成 Zoom 事件', Std.int((w - 28 * k) / k));
		zoomGenCheck.scrollFactor.set();
		zoomGenCheck.visible = false;
		add(zoomGenCheck);

		var l1:FlxText = new FlxText(x + 14 * k, y + 130 * k, 130 * k, '缩放间隔(拍)', fs(12));
		l1.setFormat(Paths.font(Language.pickFont(l1.text)), fs(12), 0xFFB9B9B9);
		l1.scrollFactor.set();
		l1.visible = false;
		add(l1);
		autoGenLabels.push(l1);

		zoomIntervalStepper = new PsychUINumericStepper(Std.int(x + 150 * k), Std.int(y + 128 * k), 1, 4, 1, 64, 0, 80);
		zoomIntervalStepper.scrollFactor.set();
		zoomIntervalStepper.visible = false;
		add(zoomIntervalStepper);

		var l2:FlxText = new FlxText(x + 270 * k, y + 130 * k, 130 * k, '目标缩放', fs(12));
		l2.setFormat(Paths.font(Language.pickFont(l2.text)), fs(12), 0xFFB9B9B9);
		l2.scrollFactor.set();
		l2.visible = false;
		add(l2);
		autoGenLabels.push(l2);

		zoomTargetInput = new PsychUIInputText(Std.int(x + 350 * k), Std.int(y + 128 * k), Std.int(76 * k), '1.05', 12);
		zoomTargetInput.scrollFactor.set();
		zoomTargetInput.visible = false;
		add(zoomTargetInput);

		genBtn = new PsychUIButton(x + 14 * k, y + h - 40 * k, '生成', function() doAutoGenerate(), Std.int(100 * k), Std.int(26 * k));
		genBtn.scrollFactor.set();
		genBtn.visible = false;
		add(genBtn);

		cancelGenBtn = new PsychUIButton(x + w - 114 * k, y + h - 40 * k, '取消', function() autoGenOpen = false, Std.int(100 * k), Std.int(26 * k));
		cancelGenBtn.scrollFactor.set();
		cancelGenBtn.visible = false;
		add(cancelGenBtn);
	}

	function buildKeybindPanel():Void
	{
		var k:Float = Math.min(uiScale, 1.5);
		var rows:Int = BIND_ACTIONS.length;
		var w:Int = Std.int(560 * k);
		var h:Int = Std.int((66 + rows * 24 + 56) * k);
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = Math.max(10, (FlxG.height - h) / 2);

		keybindBg = new FlxSprite(x, y);
		UITheme.drawPanel(keybindBg, w, h, 0xFF222222);
		keybindBg.scrollFactor.set();
		keybindBg.visible = false;
		add(keybindBg);

		kbTitle = new FlxText(x + 14 * k, y + 10 * k, w - 28 * k, '按键设置（直接编辑绑定，格式如 SPACE / G / CTRL+Z）', fs(14));
		kbTitle.setFormat(Paths.font(Language.pickFont(kbTitle.text)), fs(14), FlxColor.WHITE);
		kbTitle.scrollFactor.set();
		kbTitle.visible = false;
		add(kbTitle);

		kbHint = new FlxText(x + 14 * k, y + 38 * k, w - 28 * k, '修改后自动保存；ESC 退出设置', fs(11));
		kbHint.setFormat(Paths.font(Language.pickFont(kbHint.text)), fs(11), 0xFFB9B9B9);
		kbHint.scrollFactor.set();
		kbHint.visible = false;
		add(kbHint);

		keybindInputs = [];
		keybindLabels = [];
		var rowY:Float = y + 66 * k;
		var rowH:Float = 24 * k;
		for(i in 0...BIND_ACTIONS.length)
		{
			var act:{action:String, label:String} = BIND_ACTIONS[i];
			var lb:FlxText = new FlxText(x + 14 * k, rowY + 3 * k, 160 * k, act.label, fs(12));
			lb.setFormat(Paths.font(Language.pickFont(lb.text)), fs(12), 0xFFB9B9B9);
			lb.scrollFactor.set();
			lb.visible = false;
			add(lb);
			keybindLabels.push(lb);

			var inp:PsychUIInputText = new PsychUIInputText(x + 185 * k, rowY, Std.int(200 * k), bind(act.action), 12);
			inp.scrollFactor.set();
			inp.visible = false;
			inp.onChange = function(old:String, cur:String)
			{
				if(cur == null || cur.length < 1) return;
				if(keybindings == null) keybindings = {};
				Reflect.setField(keybindings, act.action, cur.toUpperCase());
				CameraEditorData.savePrefs(gatherPrefs());
			};
			add(inp);
			keybindInputs.push(inp);

			var defTxt:FlxText = new FlxText(x + 400 * k, rowY + 3 * k, 140 * k, '默认:' + Reflect.field(DEFAULT_BINDS, act.action), fs(9));
			defTxt.setFormat(Paths.font(Language.pickFont(defTxt.text)), fs(9), 0xFF6B6B6B);
			defTxt.scrollFactor.set();
			defTxt.visible = false;
			add(defTxt);
			keybindLabels.push(defTxt);

			rowY += rowH;
		}

		closeKeybindBtn = new PsychUIButton(x + 14 * k, y + h - 40 * k, '关闭 (ESC)', function() keybindOpen = false, Std.int(120 * k), Std.int(26 * k));
		closeKeybindBtn.scrollFactor.set();
		closeKeybindBtn.visible = false;
		add(closeKeybindBtn);
	}

	function buildCustomLayerPanel():Void
	{
		var k:Float = Math.min(uiScale, 1.5);
		var w:Int = Std.int(440 * k);
		var h:Int = Std.int(440 * k);
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = Math.max(10, (FlxG.height - h) / 2);

		customLayerBg = new FlxSprite(x, y);
		UITheme.drawPanel(customLayerBg, w, h, 0xFF222222);
		customLayerBg.scrollFactor.set();
		customLayerBg.visible = false;
		add(customLayerBg);

		customLayerTitle = new FlxText(x + 14 * k, y + 10 * k, w - 28 * k, '图层管理', fs(15));
		customLayerTitle.setFormat(Paths.font(Language.pickFont(customLayerTitle.text)), fs(15), FlxColor.WHITE);
		customLayerTitle.scrollFactor.set();
		customLayerTitle.visible = false;
		add(customLayerTitle);

		var hint:FlxText = new FlxText(x + 14 * k, y + 36 * k, w - 28 * k, '绑定事件类型后，双击时间轴空白即在该层添加该类型事件', fs(11));
		hint.setFormat(Paths.font(Language.pickFont(hint.text)), fs(11), 0xFFB9B9B9);
		hint.scrollFactor.set();
		hint.visible = false;
		add(hint);
		customFieldLabels.push(hint);

		customNameInput = new PsychUIInputText(Std.int(x + 120 * k), Std.int(y + 64 * k), Std.int(180 * k), '', 12);
		var nmLb:FlxText = new FlxText(x + 14 * k, y + 67 * k, 100 * k, '图层名称', fs(12));
		nmLb.setFormat(Paths.font(Language.pickFont(nmLb.text)), fs(12), 0xFFB9B9B9);
		nmLb.scrollFactor.set();
		nmLb.visible = false;
		add(nmLb);
		customFieldLabels.push(nmLb);
		customNameInput.scrollFactor.set();
		customNameInput.visible = false;
		add(customNameInput);

		customColorInput = new PsychUIInputText(Std.int(x + 120 * k), Std.int(y + 98 * k), Std.int(180 * k), 'FF9A9A9A', 12);
		var cLb:FlxText = new FlxText(x + 14 * k, y + 101 * k, 100 * k, '颜色 (hex)', fs(12));
		cLb.setFormat(Paths.font(Language.pickFont(cLb.text)), fs(12), 0xFFB9B9B9);
		cLb.scrollFactor.set();
		cLb.visible = false;
		add(cLb);
		customFieldLabels.push(cLb);
		customColorInput.scrollFactor.set();
		customColorInput.visible = false;
		add(customColorInput);

		customV1Input = new PsychUIInputText(Std.int(x + 120 * k), Std.int(y + 132 * k), Std.int(180 * k), '', 12);
		var v1Lb:FlxText = new FlxText(x + 14 * k, y + 135 * k, 100 * k, '绑定类型', fs(12));
		v1Lb.setFormat(Paths.font(Language.pickFont(v1Lb.text)), fs(12), 0xFFB9B9B9);
		v1Lb.scrollFactor.set();
		v1Lb.visible = false;
		add(v1Lb);
		customFieldLabels.push(v1Lb);
		customV1Input.scrollFactor.set();
		customV1Input.visible = false;
		add(customV1Input);

		customV2Input = new PsychUIInputText(Std.int(x + 120 * k), Std.int(y + 166 * k), Std.int(180 * k), '', 12);
		var v2Lb:FlxText = new FlxText(x + 14 * k, y + 169 * k, 100 * k, '默认值2', fs(12));
		v2Lb.setFormat(Paths.font(Language.pickFont(v2Lb.text)), fs(12), 0xFFB9B9B9);
		v2Lb.scrollFactor.set();
		v2Lb.visible = false;
		add(v2Lb);
		customFieldLabels.push(v2Lb);
		customV2Input.scrollFactor.set();
		customV2Input.visible = false;
		add(customV2Input);

		addCustomBtn = new PsychUIButton(x + 14 * k, y + 204 * k, '添加层', function() addCustomLayerFromPanel(), Std.int(120 * k), Std.int(26 * k));
		addCustomBtn.scrollFactor.set();
		addCustomBtn.visible = false;
		add(addCustomBtn);

		customListLabel = new FlxText(x + 14 * k, y + 242 * k, w - 28 * k, '已有自定义层：', fs(12));
		customListLabel.setFormat(Paths.font(Language.pickFont(customListLabel.text)), fs(12), 0xFFB9B9B9);
		customListLabel.scrollFactor.set();
		customListLabel.visible = false;
		add(customListLabel);

		customLayerRowY = y + 268 * k;
		closeCustomBtn = new PsychUIButton(x + 14 * k, y + h - 40 * k, '关闭 (ESC)', function() customLayerOpen = false, Std.int(120 * k), Std.int(26 * k));
		closeCustomBtn.scrollFactor.set();
		closeCustomBtn.visible = false;
		add(closeCustomBtn);

		refreshCustomLayerList();
	}

	function refreshCustomLayerList():Void
	{
		for(t in customLayerRows) { remove(t); t.destroy(); }
		for(b in customLayerDelBtns) { remove(b); b.destroy(); }
		for(s in customLayerSwatches) { remove(s); s.destroy(); }
		customLayerRows = [];
		customLayerDelBtns = [];
		customLayerSwatches = [];

		var k:Float = Math.min(uiScale, 1.5);
		var y:Float = customLayerRowY;
		for(i in 0...CameraEditorData.layerCount())
		{
			var lname:String = CameraEditorData.layerName(i);
			var ltype:String = CameraEditorData.layerType(i);
			var sw:FlxSprite = new FlxSprite(customLayerBg.x + 14 * k, y + 5 * k).makeGraphic(Std.int(12 * k), Std.int(12 * k), CameraEditorData.layerColor(i));
			sw.scrollFactor.set();
			sw.visible = false;
			add(sw);
			customLayerSwatches.push(sw);

			var t:FlxText = new FlxText(customLayerBg.x + 34 * k, y + 2 * k, 270 * k, '${lname}   [${ltype.length > 0 ? ltype : '跟随面板类型'}]', fs(11));
			t.setFormat(Paths.font(Language.pickFont(t.text)), fs(11), FlxColor.WHITE);
			t.scrollFactor.set();
			t.visible = false;
			add(t);
			customLayerRows.push(t);

			var li:Int = i;
			var b:PsychUIButton = new PsychUIButton(customLayerBg.x + 330 * k, y, '删除', function()
			{
				removeLayerByIdx(li);
			}, Std.int(60 * k), Std.int(20 * k));
			b.scrollFactor.set();
			b.visible = false;
			add(b);
			customLayerDelBtns.push(b);

			y += 24 * k;
		}
	}

	function addCustomLayerFromPanel():Void
	{
		var nm:String = (customNameInput.text == null) ? '' : customNameInput.text;
		var cv:Null<Int> = Std.parseInt((customColorInput.text == null) ? '' : customColorInput.text);
		if(cv == null || Math.isNaN(cv)) cv = CameraEditorData.nextLayerColor();
		var ty:String = (customV1Input.text == null) ? '' : customV1Input.text;
		var idx:Int = CameraEditorData.addLayer(nm, ty, cv);
		CameraEditorData.savePrefs(gatherPrefs());
		layerVisible.push(true);
		selectedLayer = idx;
		customNameInput.text = '';
		customV1Input.text = '';
		refreshCustomLayerList();
		refreshDropdownAndTimeline();
		refreshRulerPositions();
		showStatus('已添加图层 ' + CameraEditorData.layerName(idx));
	}

	function removeLayerByIdx(idx:Int):Void
	{
		if(CameraEditorData.layerCount() <= 1)
		{
			showStatus('至少保留一个图层');
			return;
		}
		var i:Int = CameraEditorData.layerIndex(idx);
		for(ev in events)
		{
			if(ev.layer == i) ev.layer = 0;
			else if(ev.layer > i) ev.layer--;
		}
		CameraEditorData.removeLayer(i);
		layerVisible.splice(i, 1);
		selectedLayer = Std.int(Math.max(0, Math.min(i - 1, CameraEditorData.layerCount() - 1)));
		CameraEditorData.savePrefs(gatherPrefs());
		syncData();
		refreshCustomLayerList();
		refreshDropdownAndTimeline();
		refreshRulerPositions();
		showStatus('已删除图层');
	}

	function refreshDropdownAndTimeline():Void
	{

		var oldLabel:String = typeDropdown.text;
		remove(typeDropdown);
		typeDropdown.destroy();
		var px:Float = panelAX + 12;
		var lw:Int = rightW - 24;
		typeDropdown = new PsychUIDropDownMenu(px, psy(54), CameraEditorData.builtinEvents(), function(idx:Int, label:String) onTypeChanged(), lw);
		typeDropdown.scrollFactor.set();
		add(typeDropdown);
		if(oldLabel != null && oldLabel.length > 0)
		{
			typeDropdown.selectedLabel = oldLabel;
			typeDropdown.text = oldLabel;
		}
		refreshPanel();
		movePanelA();

		recomputeLayerH();
		rebuildTimelineLayers();
	}

	function rebuildTimelineLayers():Void
	{
		for(s in timelineLayerUI) { remove(s); s.destroy(); }
		timelineLayerUI = [];
		layerEyeBoxes = [];
		layerLabelBgs = [];
		layerColorBars = [];
		layerLabelTexts = [];
		for(layer in 0...CameraEditorData.layerCount())
		{
			var y:Float = tlTop + rulerH + layer * layerH;
			var sel:Bool = (layer == selectedLayer);
			var sep:FlxSprite = new FlxSprite(0, y).makeGraphic(FlxG.width, 1, 0xFF333333);
			sep.scrollFactor.set();
			add(sep);
			timelineLayerUI.push(sep);
			var lblBg:FlxSprite = new FlxSprite(0, y).makeGraphic(layerLabelW, layerH, sel ? 0xEE3D3D3D : 0xCC242424);
			lblBg.scrollFactor.set();
			add(lblBg);
			timelineLayerUI.push(lblBg);
			layerLabelBgs.push(lblBg);
			var colorBar:FlxSprite = new FlxSprite(0, y).makeGraphic(4, layerH, CameraEditorData.layerColor(layer));
			colorBar.scrollFactor.set();
			add(colorBar);
			timelineLayerUI.push(colorBar);
			layerColorBars.push(colorBar);
			var ltype:String = CameraEditorData.layerType(layer);
			var lbl:FlxText = new FlxText(8, y + layerH/2 - 14, layerLabelW - 30, CameraEditorData.layerName(layer), fs(12));
			lbl.setFormat(Paths.font(Language.pickFont(lbl.text)), fs(12), CameraEditorData.layerColor(layer));
			lbl.scrollFactor.set();
			add(lbl);
			timelineLayerUI.push(lbl);
			layerLabelTexts.push(lbl);
			var sub:FlxText = new FlxText(8, y + layerH/2, layerLabelW - 30, (ltype.length > 0 ? ltype : '双击加事件'), fs(10));
			sub.setFormat(Paths.font(Language.pickFont(sub.text)), fs(10), sel ? 0xFFBFBFBF : 0xFF8A8A8A);
			sub.scrollFactor.set();
			add(sub);
			timelineLayerUI.push(sub);
			var eye:FlxSprite = new FlxSprite(layerLabelW - 22, y + layerH/2 - 7).makeGraphic(16, 14, CameraEditorData.layerColor(layer));
			eye.scrollFactor.set();
			add(eye);
			timelineLayerUI.push(eye);
			layerEyeBoxes.push(eye);
		}
		if(layerVisible.length != CameraEditorData.layerCount())
		{
			var nv:Array<Bool> = [];
			for(i in 0...CameraEditorData.layerCount()) nv.push((i < layerVisible.length) ? layerVisible[i] : true);
			layerVisible = nv;
		}

		strumPreviewY = tlTop + rulerH + CameraEditorData.layerCount() * layerH + 12;
		var barH:Int = strumH;
		if(strumPreviewBg != null) strumPreviewBg.y = strumPreviewY;
		if(strumPreviewGroup != null)
			for(i in 0...strumPreviewGroup.members.length)
				strumPreviewGroup.members[i].y = strumPreviewY + barH/2;
		if(strumLabels != null) strumLabels.y = strumPreviewY + barH/2 - 8;
		if(statusText != null) statusText.y = strumPreviewY + 10;
		updateSplitter();
		rebuildEventSprites();
		updateStrumPreview();
	}

	function buildHelpPanel():Void
	{
		var k:Float = Math.min(uiScale, 1.25);
		var w:Int = Std.int(520 * k);
		var h:Int = Std.int(Math.min(FlxG.height - 120, 640 * k));
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 60;

		helpBg = new FlxSprite(x, y);
		UITheme.drawPanel(helpBg, w, h, 0xFF222222);
		helpBg.scrollFactor.set();
		helpBg.visible = false;
		add(helpBg);

		helpLines = ('摄像机编辑器 - 操作说明（滚轮滚动，ESC 关闭）\n\n'
			+ '· 摄像机事件独立保存于 cam.json（与谱面同目录），谱面 events 保持干净\n'
			+ '· 双击时间轴 = 跳转播放头；Ctrl+双击 = 在该行按类型添加事件\n'
			+ '· 单击事件：选中；Ctrl+点击：多选（批量拖拽/删除/复制）\n'
			+ '· 右键事件 / Delete / Backspace：删除选中事件\n'
			+ '· 右键时间轴空白 / Shift+A：打开添加事件菜单（在该时间点新建同类事件）\n'
			+ '· Ctrl+C：复制选中事件；Ctrl+V：粘贴到播放头；Ctrl+D：快速复制到下一拍\n'
			+ '· Ctrl+X：剪切；Ctrl+A：全选；Ctrl+Z：撤销；Ctrl+Y：重做\n'
			+ '· Ctrl+S：保存；Ctrl+Shift+S：另存为；Ctrl+O / Ctrl+N：打开谱面；Ctrl+Q：关闭\n'
			+ '· HOME：回到开头；F1 / H：本说明\n'
			+ '· 空格：播放/暂停预览（驱动真实镜头）\n'
			+ '· F：播放头定位到选中事件\n'
			+ '· M：在播放头处添加书签；点击书签跳转，右键书签删除\n'
			+ '· 鼠标滚轮：缩放时间轴；Ctrl+滚轮：快速缩放\n'
			+ '· 左键点时间轴空白：定位播放头；拖拽刻度尺 / A、D：平移\n'
			+ '· 事件条两端出现白竖线时按住拖动：拉长/缩短事件时长（只改当前事件）\n'
			+ '· 时间轴位于屏幕底部，其顶部横条上下拖动可调整时间轴高度\n'
			+ '· 顶栏"缩放"：时间轴缩放滑块（等价于滚轮缩放）\n'
			+ '· 顶部为游戏画面预览：预览区滚轮可自由缩放视角（不影响摄像机值）\n'
			+ '· 取景框（蓝框+十字）：显示当前镜头视野范围；红点=当前对焦目标\n'
			+ '· 操作面板"播放时自动滚动"：播放时时间轴跟随播放头\n'
			+ '· 图层标签右侧色块=眼睛开关：点击可单独显示/隐藏该图层（事件仍参与播放）\n'
			+ '· 右侧两个悬浮面板可按住顶部标题拖动位置（自动记忆）\n'
			+ '· Q / E：切换吸附精度（1/2/4/8/16 步）\n'
			+ '· G：开启/关闭着色器预览\n'
			+ '· 显示箭头预览（面板开关）：底部实时显示谱面音符，\n'
			+ '  播放时自动按键动画（对手红/玩家绿）\n'
			+ '· 按键（顶部按钮）：自定义全部快捷键，实时生效\n'
			+ '· 自定义层（顶部按钮）：新增自己的事件层（名称/颜色/默认参数）\n'
			+ '· 右侧面板：编辑选中事件的类型、时间与参数\n'
			+ '· 自动生成：按谱面小节生成 Focus 切换，或按拍生成 Zoom 事件\n'
			+ '· 导入/导出：剪贴板交换事件数据（PE 谱面 events 格式）\n'
			+ '· 文件 > 打开 / 最近打开：载入其它谱面的摄像机数据（Ctrl+O）\n'
			+ '· 文件 > 另存为：把当前摄像机事件保存到指定文件（Ctrl+Shift+S）\n'
			+ '· 文件 > 导出为文件夹：把谱面与 cam.json 一起导出到指定目录\n'
			+ '· 文件 > 保存：写入当前谱面的 cam.json（摄像机数据始终存 cam.json）\n'
			+ '· 编辑器每 30 秒把改动自动备份到 backups/charts/；进入时若有更新的备份会提示恢复\n'
			+ '· 视图 > 时长单位：在秒与步之间切换（步为官方语义，1 步 = 一个 stepCrochet）\n'
			+ '  cam.json 每次改动自动保存\n'
			+ '\n事件参数格式见右侧面板提示。').split('\n');
		helpScroll = 0;
		helpText = new FlxText(x + 16, y + 12, w - 32, '', fs(11));
		helpText.setFormat(Paths.font(Language.pickFont('操作说明')), fs(11), FlxColor.WHITE);
		helpText.scrollFactor.set();
		helpText.visible = false;
		add(helpText);
		refreshHelpText();

		closeHelpBtn = new PsychUIButton(x + w - Std.int(120 * k), y + h - Std.int(40 * k), '关闭 (ESC)', function() helpOpen = false, Std.int(100 * k), Std.int(26 * k));
		closeHelpBtn.scrollFactor.set();
		closeHelpBtn.visible = false;
		add(closeHelpBtn);
	}

	function refreshHelpText():Void
	{
		if(helpText == null || helpBg == null || helpLines.length < 1) return;
		var perLine:Float = Math.max(10, fs(11) * 1.3);
		var maxVis:Int = Std.int((helpBg.height - 70) / perLine);
		if(maxVis < 4) maxVis = 4;
		if(helpScroll > helpLines.length - maxVis) helpScroll = helpLines.length - maxVis;
		if(helpScroll < 0) helpScroll = 0;
		var end:Int = Std.int(Math.min(helpLines.length, helpScroll + maxVis));
		var out:String = '';
		for(i in helpScroll...end)
			out += (i > helpScroll ? '\n' : '') + helpLines[i];
		if(end < helpLines.length) out += '\n……（滚轮继续，' + (helpLines.length - end) + ' 行未显示）';
		helpText.text = out;
	}

	function scrollHelp(delta:Int):Void
	{
		helpScroll += delta;
		refreshHelpText();
	}

	function buildAboutPanel():Void
	{
		var w:Int = 520;
		var h:Int = 300;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 110;

		aboutBg = new FlxSprite(x, y);
		UITheme.drawPanel(aboutBg, w, h, 0xFF222222);
		aboutBg.scrollFactor.set();
		aboutBg.visible = false;
		add(aboutBg);

		aboutText = new FlxText(x + 16, y + 12, w - 32,
			'摄像机编辑器 (Camera Editor)\n版本: 1.0.4  移植自 Funkin 官方摄像机编辑器\n\n'
			+ '本编辑器用于在歌曲内可视化编排摄像机运镜事件：\n'
			+ '聚焦镜头 / 缩放 / 冲击 / 跟随坐标 / 播放动画 / 镜头角度。\n\n'
			+ '事件独立保存于 cam.json（与谱面同目录），\n'
			+ '保存谱面时会自动从 events 中剔除摄像机事件，保持谱面干净。\n\n'
			+ '操作详见「使用说明」，或按 H 随时打开帮助。',
			fs(13));
		aboutText.setFormat(Paths.font(Language.pickFont(aboutText.text)), fs(13), FlxColor.WHITE);
		aboutText.scrollFactor.set();
		aboutText.visible = false;
		add(aboutText);

		closeAboutBtn = new PsychUIButton(x + w - 120, y + h - 40, '关闭 (ESC)', function() aboutOpen = false, 100, 26);
		closeAboutBtn.scrollFactor.set();
		closeAboutBtn.visible = false;
		add(closeAboutBtn);
	}

	function buildWelcomePanel():Void
	{
		var k:Float = Math.min(uiScale, 1.25);
		var w:Int = Std.int(560 * k);
		var h:Int = Std.int(400 * k);
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = Math.max(30, (FlxG.height - h) / 2 - 20);

		welcomeBg = new FlxSprite(x, y);
		UITheme.drawPanel(welcomeBg, w, h, 0xFF222222);
		welcomeBg.scrollFactor.set();
		welcomeBg.visible = false;
		add(welcomeBg);

		welcomeText = new FlxText(x + 16, y + 12, w - 32,
			'欢迎使用摄像机编辑器\n\n'
			+ '你可以在这里为当前歌曲编排摄像机运镜，让画面随节奏律动：\n\n'
			+ '· 聚焦镜头：切换对焦角色（男友 / 爸爸 / 女友）\n'
			+ '· 缩放镜头：平滑推拉镜头\n'
			+ '· 镜头冲击：打击感加成\n'
			+ '· 跟随坐标：锁定镜头到指定坐标\n'
			+ '· 播放动画：触发角色动画\n'
			+ '· 镜头角度：旋转镜头\n\n'
			+ '时间轴位于屏幕底部，双击空白处即可添加事件。\n'
			+ '顶部菜单提供：使用说明 / 自动生成 / 自定义层 / 关于。',
			fs(13));
		welcomeText.setFormat(Paths.font(Language.pickFont(welcomeText.text)), fs(13), FlxColor.WHITE);
		welcomeText.scrollFactor.set();
		welcomeText.visible = false;
		add(welcomeText);

		welcomeHelpBtn = new PsychUIButton(x + Std.int(16 * k), y + h - Std.int(40 * k), '查看使用说明', function() { welcomeOpen = false; helpOpen = true; }, Std.int(130 * k), Std.int(26 * k));
		welcomeHelpBtn.scrollFactor.set();
		welcomeHelpBtn.visible = false;
		add(welcomeHelpBtn);

		welcomeGenBtn = new PsychUIButton(x + Std.int(156 * k), y + h - Std.int(40 * k), '自动生成', function() { welcomeOpen = false; autoGenOpen = true; }, Std.int(110 * k), Std.int(26 * k));
		welcomeGenBtn.scrollFactor.set();
		welcomeGenBtn.visible = false;
		add(welcomeGenBtn);

		closeWelcomeBtn = new PsychUIButton(x + w - Std.int(120 * k), y + h - Std.int(40 * k), '关闭 (ESC)', function() welcomeOpen = false, Std.int(100 * k), Std.int(26 * k));
		closeWelcomeBtn.scrollFactor.set();
		closeWelcomeBtn.visible = false;
		add(closeWelcomeBtn);
	}

	function buildDeleteLayerPanel():Void
	{
		var w:Int = 470;
		var h:Int = 200;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 210;

		deleteLayerBg = new FlxSprite(x, y);
		UITheme.drawPanel(deleteLayerBg, w, h, 0xFF222222);
		deleteLayerBg.scrollFactor.set();
		deleteLayerBg.visible = false;
		add(deleteLayerBg);

		deleteLayerText = new FlxText(x + 16, y + 12, w - 32, '', fs(13));
		deleteLayerText.setFormat(Paths.font(Language.pickFont(deleteLayerText.text)), fs(13), FlxColor.WHITE);
		deleteLayerText.scrollFactor.set();
		deleteLayerText.visible = false;
		add(deleteLayerText);

		dlNeverBtn = new PsychUIButton(x + 16, y + h - 40, '取消', function() performDeleteLayer(0), 120, 26);
		dlNeverBtn.scrollFactor.set();
		dlNeverBtn.visible = false;
		add(dlNeverBtn);

		dlFlattenBtn = new PsychUIButton(x + 150, y + h - 40, '移到 Default', function() performDeleteLayer(1), 130, 26);
		dlFlattenBtn.scrollFactor.set();
		dlFlattenBtn.visible = false;
		add(dlFlattenBtn);

		dlDeleteBtn = new PsychUIButton(x + 294, y + h - 40, '连事件一起删除', function() performDeleteLayer(2), 160, 26);
		dlDeleteBtn.scrollFactor.set();
		dlDeleteBtn.visible = false;
		add(dlDeleteBtn);
	}

	function buildRenameLayerPanel():Void
	{
		var w:Int = 400;
		var h:Int = 150;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 230;

		renameLayerBg = new FlxSprite(x, y);
		UITheme.drawPanel(renameLayerBg, w, h, 0xFF222222);
		renameLayerBg.scrollFactor.set();
		renameLayerBg.visible = false;
		add(renameLayerBg);

		renameLayerText = new FlxText(x + 16, y + 12, w - 32, '输入新的图层名称（回车确定）', fs(13));
		renameLayerText.setFormat(Paths.font(Language.pickFont(renameLayerText.text)), fs(13), FlxColor.WHITE);
		renameLayerText.scrollFactor.set();
		renameLayerText.visible = false;
		add(renameLayerText);

		renameLayerInput = new PsychUIInputText(x + 16, y + 48, w - 32, '', 13);
		renameLayerInput.scrollFactor.set();
		renameLayerInput.visible = false;
		add(renameLayerInput);

		renameOkBtn = new PsychUIButton(x + 16, y + h - 40, '确定', function() performRenameLayer(), 120, 26);
		renameOkBtn.scrollFactor.set();
		renameOkBtn.visible = false;
		add(renameOkBtn);

		renameCancelBtn = new PsychUIButton(x + 150, y + h - 40, '取消', function() renameLayerOpen = false, 120, 26);
		renameCancelBtn.scrollFactor.set();
		renameCancelBtn.visible = false;
		add(renameCancelBtn);
	}

	function buildAutoSortPanel():Void
	{
		var w:Int = 470;
		var h:Int = 300;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 180;

		autoSortBg = new FlxSprite(x, y);
		UITheme.drawPanel(autoSortBg, w, h, 0xFF222222);
		autoSortBg.scrollFactor.set();
		autoSortBg.visible = false;
		add(autoSortBg);

		autoSortText = new FlxText(x + 16, y + 12, w - 32, '', fs(13));
		autoSortText.setFormat(Paths.font(Language.pickFont(autoSortText.text)), fs(13), FlxColor.WHITE);
		autoSortText.scrollFactor.set();
		autoSortText.visible = false;
		add(autoSortText);

		asSkipBtn = new PsychUIButton(x + 16, y + h - 40, '跳过', function() autoSortOpen = false, 120, 26);
		asSkipBtn.scrollFactor.set();
		asSkipBtn.visible = false;
		add(asSkipBtn);

		asSortBtn = new PsychUIButton(x + w - 136, y + h - 40, '排序', function() performAutoSort(), 120, 26);
		asSortBtn.scrollFactor.set();
		asSortBtn.visible = false;
		add(asSortBtn);
	}

	function buildBackupPanel():Void
	{
		var w:Int = 520;
		var h:Int = 220;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 200;

		backupDialogBg = new FlxSprite(x, y);
		UITheme.drawPanel(backupDialogBg, w, h, 0xFF222222);
		backupDialogBg.scrollFactor.set();
		backupDialogBg.visible = false;
		add(backupDialogBg);

		backupDialogText = new FlxText(x + 16, y + 12, w - 32, '', fs(13));
		backupDialogText.setFormat(Paths.font(Language.pickFont(backupDialogText.text)), fs(13), FlxColor.WHITE);
		backupDialogText.scrollFactor.set();
		backupDialogText.visible = false;
		add(backupDialogText);

		bdNoBtn = new PsychUIButton(x + 16, y + h - 40, '不用了', function() backupDialogOpen = false, 110, 26);
		bdNoBtn.scrollFactor.set();
		bdNoBtn.visible = false;
		add(bdNoBtn);

		bdFolderBtn = new PsychUIButton(x + 140, y + h - 40, '打开文件夹', function()
		{
			CameraEditorData.openBackupsFolder();
			showStatus('已打开备份文件夹');
		}, 130, 26);
		bdFolderBtn.scrollFactor.set();
		bdFolderBtn.visible = false;
		add(bdFolderBtn);

		bdLoadBtn = new PsychUIButton(x + 284, y + h - 40, '加载备份', function() doLoadBackup(), 150, 26);
		bdLoadBtn.scrollFactor.set();
		bdLoadBtn.visible = false;
		add(bdLoadBtn);
	}

	function buildHintDialog():Void
	{
		var w:Int = 560;
		var h:Int = 208;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 200;

		hintDialogBg = new FlxSprite(x, y);
		UITheme.drawPanel(hintDialogBg, w, h, 0xFF222222);
		hintDialogBg.scrollFactor.set();
		hintDialogBg.visible = false;
		add(hintDialogBg);

		hintDialogText = new FlxText(x + 16, y + 14, w - 32, '', fs(13));
		hintDialogText.setFormat(Paths.font(Language.pickFont('提示')), fs(13), 0xFFFFC46B);
		hintDialogText.scrollFactor.set();
		hintDialogText.visible = false;
		add(hintDialogText);

		hdIgnoreBtn = new PsychUIButton(x + 16, y + h - 42, '忽略', function() hintDialogOpen = false, 110, 26);
		hdIgnoreBtn.scrollFactor.set();
		hdIgnoreBtn.visible = false;
		add(hdIgnoreBtn);

		hdSortBtn = new PsychUIButton(x + 140, y + h - 42, '自动分层修复', function()
		{
			hintDialogOpen = false;
			autoSortLayersByType();
		}, 150, 26);
		hdSortBtn.scrollFactor.set();
		hdSortBtn.visible = false;
		add(hdSortBtn);
	}

	function singleLayerOverlapCount():Int
	{
		if(CameraEditorData.layerCount() > 1) return 0;
		var list:Array<EdEvent> = [];
		for(ev in events)
		{
			if(!eventResizable(ev)) continue;
			if(ev.v2 == null) continue;
			var di:Int = durIndex(ev.name);
			var pp:Array<String> = ev.v2.split(',');
			if(pp.length <= di) continue;
			var d:Float = Std.parseFloat(pp[di]);
			if(Math.isNaN(d) || d <= 0) continue;
			list.push(ev);
		}
		CameraEditorData.sortByTime(list);
		var n:Int = 0;
		for(i in 1...list.length)
		{
			var pdi:Int = durIndex(list[i - 1].name);
			var pList:Array<String> = list[i - 1].v2.split(',');
			if(pList.length <= pdi) continue;
			var pd:Float = Std.parseFloat(pList[pdi]);
			if(Math.isNaN(pd)) continue;
			if(list[i].time < list[i - 1].time + pd * 1000) n++;
		}
		return n;
	}

	function checkLayerOverlapOnEnter():Void
	{
		var n:Int = singleLayerOverlapCount();
		if(n < 1) return;
		if(hintDialogText != null)
			hintDialogText.text = 'Hey! Listen!\n\n当前只有 1 个图层，但有 $n 处摄像机事件的时长互相重叠，\n同层事件会互相打断。官方做法是按事件类型分层。\n\n要现在自动分层吗？';
		hintDialogText.setFormat(Paths.font(Language.pickFont(hintDialogText.text)), fs(13), 0xFFFFC46B);
		if(remove(hintDialogBg) != null) add(hintDialogBg);
		if(remove(hintDialogText) != null) add(hintDialogText);
		if(remove(hdIgnoreBtn) != null) add(hdIgnoreBtn);
		if(remove(hdSortBtn) != null) add(hdSortBtn);
		hintDialogOpen = true;
	}

	function buildAddEventMenu():Void
	{
		addMenuNames = CameraEditorData.builtinEvents();
		for(nm in addMenuNames)
		{
			var it:FlxText = new FlxText(0, 0, 164, nm, fs(11));
			it.setFormat(Paths.font('Helvetica.ttf'), fs(11), FlxColor.WHITE);
			it.scrollFactor.set();
			it.visible = false;
			add(it);
			addMenuItems.push(it);
		}
	}

	function closeAddEventMenu():Void
	{
		addMenuOpen = false;
		for(it in addMenuItems) if(it != null) it.visible = false;
	}

	function openAddEventMenu(ms:Float, atMouse:Bool = true, layerHint:Int = -1):Void
	{
		if(addMenuItems.length < 1) return;
		var rowH:Int = Std.int(22 * Math.min(uiScale, 1.25));
		var w:Float = 180;
		var h:Float = rowH * addMenuItems.length + 8;
		var mx:Float;
		var my:Float;
		if(atMouse)
		{
			mx = FlxG.mouse.gameX;
			my = FlxG.mouse.gameY;
		}
		else
		{
			mx = msToX(ms);
			my = tlTop + rulerH;
		}
		if(mx + w > FlxG.width - 4) mx = FlxG.width - 4 - w;
		if(mx < 4) mx = 4;
		if(my + h > timelineTop + timelineAreaH - 4) my = timelineTop + timelineAreaH - 4 - h;
		if(my < topH + 2) my = topH + 2;

		addMenuOpen = true;
		addMenuMs = ms;
		addMenuLayer = layerHint;
		addMenuX = mx;
		addMenuY = my;
		addMenuW = w;
		addMenuH = h;
		for(i in 0...addMenuItems.length)
		{
			addMenuItems[i].x = mx + 8;
			addMenuItems[i].y = my + 4 + i * rowH;
			addMenuItems[i].visible = true;
			if(remove(addMenuItems[i]) != null) add(addMenuItems[i]);
		}
	}

	function handleAddEventMenuClick(mx:Float, my:Float):Void
	{
		var rowH:Int = Std.int(22 * Math.min(uiScale, 1.25));
		var hit:Int = -1;
		if(mx >= addMenuX && mx <= addMenuX + addMenuW && my >= addMenuY && my <= addMenuY + addMenuH)
			hit = Std.int((my - addMenuY - 4) / rowH);
		var nm:String = (hit >= 0 && hit < addMenuNames.length) ? addMenuNames[hit] : null;
		closeAddEventMenu();
		if(nm == null) return;
		var lyr:Int = (addMenuLayer >= 0 && addMenuLayer < CameraEditorData.layerCount())
			? addMenuLayer
			: ((selectedLayer >= 0 && selectedLayer < CameraEditorData.layerCount()) ? selectedLayer : CameraEditorData.layerOf(nm));
		addEventAt(snapTime(addMenuMs), nm, true, lyr);
		showStatus('已添加事件：' + nm + ' → 图层 ' + CameraEditorData.layerName(lyr));
	}

	function doLoadBackup():Void
	{
		var p:String = (bdPath != null) ? bdPath : CameraEditorData.latestBackup();
		backupDialogOpen = false;
		if(p == null)
		{
			showStatus('没有可用备份');
			return;
		}
		var loaded:Array<EdEvent> = CameraEditorData.loadBackupEvents(p);
		if(loaded.length < 1)
		{
			showStatus('备份为空或读取失败');
			return;
		}
		pushUndo('加载备份');
		events = loaded;
		clearSelection();
		syncData();
		rebuildEventSprites();
		rebuildTimelineLayers();
		refreshRulerPositions();
		refreshPanel();
		showStatus('已从备份恢复 ' + loaded.length + ' 个事件');
	}

	function checkBackupOnEnter():Void
	{
		var latest:String = CameraEditorData.latestBackup();
		if(latest == null) return;
		if(!CameraEditorData.backupIsNewer(latest)) return;
		bdPath = latest;
		if(backupDialogText != null)
			backupDialogText.text = 'Hey! Listen!\n\n检测到一个比当前谱面更新的摄像机备份：\n'
				+ latest + '\n\n可能是上次编辑时游戏异常退出留下的。要加载它吗？';
		backupDialogOpen = true;
	}

	function doOpenBackupsFolder():Void
	{
		var abs:String = CameraEditorData.openBackupsFolder();
		showStatus('备份目录：' + abs);
	}

	function doShowLatestBackup():Void
	{
		var l:String = CameraEditorData.latestBackup();
		if(l == null)
		{
			showStatus('没有可用备份');
			return;
		}
		bdPath = l;
		if(backupDialogText != null)
			backupDialogText.text = '最新备份：\n' + l + '\n\n要加载它吗？';
		backupDialogOpen = true;
	}

	function sfx(name:String, vol:Float = 1):Void
	{
		try
		{
			if(Paths.soundFileExists('sounds/chartingSounds/' + name))
				FlxG.sound.play(Paths.sound('chartingSounds/' + name), vol);
		}
		catch(e:Dynamic) {}
	}

	function ensureFileDialog():FileDialogHandler
	{
		if(fileDialog == null) fileDialog = new FileDialogHandler();
		return fileDialog;
	}

	function openUploadChartDialog():Void
	{
		if(!uploadChartOpen)
		{
			refreshUploadRecent();
			uploadChartOpen = true;
			sfx('openWindow');
		}
	}

	function refreshUploadRecent():Void
	{
		for(b in ucRecentBtns) if(b != null) { remove(b); b.destroy(); }
		ucRecentBtns = [];
		if(uploadChartBg == null) return;
		var list:Array<String> = CameraEditorData.recentCharts;
		if(list == null || list.length < 1)
		{
			if(ucRecentTitle != null) ucRecentTitle.text = '最近打开：（暂无记录）';
			return;
		}
		if(ucRecentTitle != null) ucRecentTitle.text = '最近打开：';
		var bx:Float = uploadChartBg.x + 18;
		var by:Float = uploadChartBg.y + 160;
		var n:Int = Std.int(Math.min(7, list.length));
		for(i in 0...n)
		{
			var p:String = list[i];
			var label:String = p;
			if(label.length > 56) label = '…' + label.substr(label.length - 55);
			var btn:PsychUIButton = new PsychUIButton(bx, by + i * 26, label, function() loadChartFile(p), 560, 24);
			btn.scrollFactor.set();
			add(btn);
			ucRecentBtns.push(btn);
		}
	}

	function browseOpenChart():Void
	{
		var fd:FileDialogHandler = ensureFileDialog();
		if(!fd.completed)
		{
			showStatus('请先完成上一个文件对话框');
			return;
		}
		try
		{
			fd.open(null, '打开谱面 / 摄像机数据', [new FileFilter('JSON', 'json')],
				function() loadChartFile(fd.path),
				function() {},
				function() showStatus('打开失败'));
		}
		catch(e:Dynamic) showStatus('打开失败: $e');
	}

	function loadChartFile(path:String):Void
	{
		if(path == null || path.length < 1) return;
		var loaded:Array<EdEvent> = CameraEditorData.chartEventsFrom(path);
		if(loaded.length < 1)
		{
			showStatus('该文件没有可识别的摄像机事件：\n' + path);
			return;
		}
		var isCam:Bool = path.toLowerCase().endsWith('-cam.json');
		if(!isCam) Song.chartPath = path;
		pushUndo('打开谱面');
		events = loaded;
		clearSelection();
		syncData();
		rebuildEventSprites();
		rebuildTimelineLayers();
		refreshRulerPositions();
		refreshPanel();
		CameraEditorData.pushRecentChart(path);
		CameraEditorData.savePrefs(gatherPrefs());
		uploadChartOpen = false;
		showStatus('已载入 ${loaded.length} 个事件：\n' + path);
	}

	function doSaveAs():Void
	{
		var fd:FileDialogHandler = ensureFileDialog();
		if(!fd.completed)
		{
			showStatus('请先完成上一个文件对话框');
			return;
		}
		var payload:Dynamic = {format: 'psych_cam_v1', events: CameraEditorData.eventsToRawLayered(events)};
		try
		{
			fd.save('chart-cam.json', haxe.Json.stringify(payload, '\t'),
				function()
				{
					if(fd.path != null)
					{
						CameraEditorData.pushRecentChart(fd.path);
						CameraEditorData.savePrefs(gatherPrefs());
						showStatus('已另存为：\n' + fd.path);
					}
				},
				function() {},
				function() showStatus('另存为已取消'));
		}
		catch(e:Dynamic) showStatus('另存为失败: $e');
	}

	function doExportFolder():Void
	{
		var fd:FileDialogHandler = ensureFileDialog();
		if(!fd.completed)
		{
			showStatus('请先完成上一个文件对话框');
			return;
		}
		try
		{
			fd.openDirectory('选择导出文件夹',
				function()
				{
					var out:String = CameraEditorData.exportCamFolder(fd.path, events);
					if(out != null) showStatus('已导出：\n' + out);
					else showStatus('导出失败');
				},
				function() {},
				function() showStatus('导出已取消'));
		}
		catch(e:Dynamic) showStatus('导出失败: $e');
	}

	function animListFor(target:String):Array<String>
	{
		var ps:PlayState = PlayState.instance;
		var out:Array<String> = [];
		if(ps != null)
		{
			var ch:Character = ps.boyfriend;
			var t:String = (target == null) ? '' : target.toLowerCase();
			if(t == 'dad' || t == 'opponent' || t == '1') ch = ps.dad;
			else if(t == 'gf' || t == 'girlfriend' || t == '2') ch = ps.gf;
			if(ch == null) ch = ps.boyfriend;
			if(ch != null && ch.animation != null)
			{
				try
				{
					var names:Array<String> = ch.animation.getNameList();
					if(names != null) for(n in names) if(n != null && n.length > 0) out.push(n);
				}
				catch(e:Dynamic) {}
			}
		}
		if(out.length < 1) out = ['idle'];
		return out;
	}

	function refreshAnimList():Void
	{
		if(paAnim == null) return;
		var tgt:String = (paTarget != null && paTarget.text != null && paTarget.text.length > 0) ? paTarget.text : 'boyfriend';
		var cur:String = paAnim.text;
		var lst:Array<String> = animListFor(tgt);
		if(cur != null && cur.length > 0 && !lst.contains(cur)) lst.push(cur);
		paAnim.list = lst;
		if(cur != null && cur.length > 0) paAnim.selectedLabel = cur;
		else paAnim.selectedIndex = 0;
	}

	function buildUploadChartPanel():Void
	{
		var w:Int = 600;
		var h:Int = 380;
		var x:Float = (FlxG.width - w) / 2;
		var y:Float = 120;

		uploadChartBg = new FlxSprite(x, y);
		UITheme.drawPanel(uploadChartBg, w, h, 0xFF1E1E1E);
		uploadChartBg.scrollFactor.set();
		uploadChartBg.visible = false;
		add(uploadChartBg);

		uploadChartText = new FlxText(x + 18, y + 14, w - 36,
			'打开谱面 / 摄像机数据\n\n'
			+ '· 选择 .json 谱面：优先读取同目录的 <谱面名>-cam.json\n'
			+ '· 也可以直接选择 -cam.json 文件\n'
			+ '· 打开后「保存」仍写入当前谱面的 cam.json', fs(12));
		uploadChartText.setFormat(Paths.font(Language.pickFont(uploadChartText.text)), fs(12), FlxColor.WHITE);
		uploadChartText.scrollFactor.set();
		uploadChartText.visible = false;
		add(uploadChartText);

		ucOpenBtn = new PsychUIButton(x + 18, y + 96, '浏览并打开谱面…', function() browseOpenChart(), 200, 28);
		ucOpenBtn.scrollFactor.set();
		ucOpenBtn.visible = false;
		add(ucOpenBtn);

		ucRecentTitle = new FlxText(x + 18, y + 136, w - 36, '最近打开：', fs(12));
		ucRecentTitle.setFormat(Paths.font(Language.pickFont(ucRecentTitle.text)), fs(12), 0xFFB9B9B9);
		ucRecentTitle.scrollFactor.set();
		ucRecentTitle.visible = false;
		add(ucRecentTitle);

		ucCancelBtn = new PsychUIButton(x + w - 130, y + h - 42, '取消 (ESC)', function() uploadChartOpen = false, 110, 26);
		ucCancelBtn.scrollFactor.set();
		ucCancelBtn.visible = false;
		add(ucCancelBtn);
	}

	function resetCameraScroll():Void
	{
		vcamScrollX = prevScrollX;
		vcamScrollY = prevScrollY;
		vcamHasFollow = false;
		vcamFollowX = vcamScrollX + FlxG.width / (2 * Math.max(0.05, vcamZoom));
		vcamFollowY = vcamScrollY + FlxG.height / (2 * Math.max(0.05, vcamZoom));
		centerSceneOnViewfinder();
		showStatus('已重置摄像机位置');
	}

	function resetCameraZoom():Void
	{
		vcamZoom = Math.max(0.05, prevCamZoom);
		previewZoom = 0.55;
		refreshPreviewFit();
		showStatus('已重置摄像机缩放与预览缩放');
	}

	function buildPreviewOverlay():Void
	{
		var pvTop:Int = topH;
		previewBorder = new FlxSprite(0, pvTop).makeGraphic(FlxG.width, 3, 0x66101010);
		previewBorder.scrollFactor.set();
		add(previewBorder);

		for(i in 0...9)
		{
			var p:FlxSprite = new FlxSprite();
			p.loadGraphic(Paths.image('ui/camera-editor/vcam/vcam_slice'), true, 30, 30);
			p.animation.add('f', [i], 0, false, false);
			p.animation.play('f');
			p.color = 0xFF7ABFBC;
			p.alpha = 0.5;
			p.scrollFactor.set();
			add(p);
			vfNine.push(p);
		}

		var gc:Array<FlxCamera> = [editorCam];
		for(p in vfNine) p.cameras = gc;

		vcamSliceSolid = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/camera-editor/vcam/vcam_slice_solid'));
		vcamSliceSolid.color = 0xFF7ABFBC;
		vcamSliceSolid.alpha = 0.2;
		vcamSliceSolid.origin.set(0, 0);
		vcamSliceSolid.scrollFactor.set();
		vcamSliceSolid.cameras = gc;
		add(vcamSliceSolid);

		vcamCornerTL = mkVcam('ui/camera-editor/vcam/vcam_corner');
		vcamCornerTR = mkVcam('ui/camera-editor/vcam/vcam_corner');
		vcamCornerTR.flipX = true;
		vcamCornerBL = mkVcam('ui/camera-editor/vcam/vcam_corner');
		vcamCornerBL.flipY = true;
		vcamCornerBR = mkVcam('ui/camera-editor/vcam/vcam_corner');
		vcamCornerBR.flipX = true;
		vcamCornerBR.flipY = true;
		for(p in [vcamCornerTL, vcamCornerTR, vcamCornerBL, vcamCornerBR]) p.cameras = gc;

		vcamLineT = mkVcam('ui/camera-editor/vcam/vcam_line_horizontal');
		vcamLineB = mkVcam('ui/camera-editor/vcam/vcam_line_horizontal');
		vcamLineL = mkVcam('ui/camera-editor/vcam/vcam_line_vertical');
		vcamLineR = mkVcam('ui/camera-editor/vcam/vcam_line_vertical');
		for(p in [vcamLineT, vcamLineB, vcamLineL, vcamLineR]) p.cameras = gc;

		vcamCenter = mkVcam('ui/camera-editor/vcam/vcam_center');
		vcamCenter.cameras = gc;

		passeT = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
		passeB = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
		passeL = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
		passeR = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
		for(p in [passeT, passeB, passeL, passeR])
		{
			p.scrollFactor.set();
			p.cameras = gc;
			p.visible = false;
			add(p);
		}

		extL = mkSlice('ui/camera-editor/vcam/vcam_slice_left');
		extL.color = 0xFF7ABF9B;
		extL.alpha = 0.3;
		extL.cameras = gc;
		extL.visible = false;
		extR = mkSlice('ui/camera-editor/vcam/vcam_slice_right');
		extR.color = 0xFF7ABF9B;
		extR.alpha = 0.3;
		extR.cameras = gc;
		extR.visible = false;

		vcamSmall = [];
		for(i in 0...4)
		{
			var c:FlxSprite = mkVcam('ui/camera-editor/vcam/vcam_corner_small');
			c.alpha = 0.7;
			c.cameras = gc;
			c.visible = false;
			vcamSmall.push(c);
		}
		vcamSmall[1].flipX = true;
		vcamSmall[2].flipY = true;
		vcamSmall[3].flipX = true;
		vcamSmall[3].flipY = true;
		for(i in 0...2)
		{
			var l:FlxSprite = mkVcam('ui/camera-editor/vcam/vcam_line_small');
			l.alpha = 0.7;
			l.cameras = gc;
			l.visible = false;
			if(i == 1) l.flipY = true;
			vcamSmall.push(l);
		}

		viewfinderDot = new FlxSprite(0, 0).makeGraphic(10, 10, 0xFFFF5C5C);
		viewfinderDot.scrollFactor.set();
		viewfinderDot.cameras = gc;
		add(viewfinderDot);

		miniBg = new FlxSprite(0, 0);
		miniViewfinder = new FlxSprite(0, 0);
		miniDot = new FlxSprite(0, 0);
		miniText = new FlxText(0, 0, 0, '');
		miniBg.visible = false;
		miniViewfinder.visible = false;
		miniDot.visible = false;
		miniText.visible = false;

		previewZoomText = new FlxText(8, timelineTop - 26, 420, '', fs(11));
		previewZoomText.setFormat(Paths.font(Language.pickFont(previewZoomText.text)), fs(11), 0xFF9AC8F5);
		previewZoomText.scrollFactor.set();
		add(previewZoomText);
	}

	function mkVcam(img:String):FlxSprite
	{
		var s:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image(img));
		s.scrollFactor.set();
		s.origin.set(0, 0);
		add(s);
		return s;
	}

	function mkSlice(img:String):FlxSprite
	{
		var s:FlxSprite = new FlxSprite(0, 0);
		s.loadGraphic(Paths.image(img), true, 30, 30);
		s.animation.add('f', [4], 0, false, false);
		s.animation.play('f');
		s.scrollFactor.set();
		s.origin.set(0, 0);
		add(s);
		return s;
	}

	function setSliceGraphic(s:FlxSprite, img:String):Void
	{
		if(s == null) return;
		s.loadGraphic(Paths.image(img), true, 30, 30);
		s.animation.add('f', [4], 0, false, false);
		s.animation.play('f');
	}

	function layoutViewfinderWindow():Void
	{
		var bandTop:Float = topH;
		var bandH:Float = timelineTop - topH;
		var bandCY:Float = bandTop + bandH / 2;
		var asp:Float = (FlxG.width > 0 && FlxG.height > 0) ? (FlxG.height / FlxG.width) : 0.5625;
		var wf:Float = FlxG.width * 0.60 * Math.max(0.05, vfWinScale);
		var hf:Float = wf * asp;
		if(hf > bandH * 0.86)
		{
			hf = bandH * 0.86;
			wf = hf / asp;
		}
		vfWinW = wf;
		vfWinH = hf;
		vfWinX = (FlxG.width - wf) / 2;
		vfWinY = bandCY - hf / 2;
	}

	function centerSceneOnViewfinder():Void
	{
		var ps:PlayState = PlayState.instance;
		if(ps == null || ps.camGame == null) return;
		var gz:Float = Math.max(0.05, pvGz);
		var vz:Float = Math.max(0.05, vcamZoom);
		var cx:Float = FlxG.width / 2;
		var cy:Float = topH + (timelineTop - topH) / 2;
		var bandK:Float = vfWinW / (FlxG.width * 0.60);
		var gez:Float = Math.max(0.02, gz * bandK);
		var mx:Float = 0.5 * FlxG.width * (gez - 1) / gez;
		var my:Float = 0.5 * FlxG.height * (gez - 1) / gez;
		ps.camGame.zoom = gez;
		ps.camGame.angle = vcamAngle;
		ps.camGame.x = 0;
		ps.camGame.y = 0;
		ps.camGame.scroll.set(vcamScrollX + 0.5 * FlxG.width / vz - mx - cx / gez,
			vcamScrollY + 0.5 * FlxG.height / vz - my - cy / gez);
	}

	function holdGameCamera():Void
	{
		var ps:PlayState = PlayState.instance;
		if(ps == null || ps.camGame == null) return;
		ps.camZooming = false;
		if(editorCam != null) editorCam.zoom = 1;
		centerSceneOnViewfinder();
	}

	function refreshPreviewFit():Void
	{
		pvGz = Math.max(0.05, prevCamZoom * previewZoom);
		centerSceneOnViewfinder();
	}

	function stepVirtualCamera(elapsed:Float):Void
	{
		var vz:Float = Math.max(0.05, vcamZoom);
		if(vcamHasFollow)
		{
			var tx:Float = vcamFollowX - FlxG.width / (2 * vz);
			var ty:Float = vcamFollowY - FlxG.height / (2 * vz);
			var l:Float = Math.max(0.03, Math.min(1, elapsed * 7));
			vcamScrollX += (tx - vcamScrollX) * l;
			vcamScrollY += (ty - vcamScrollY) * l;
			if(vcamManualFollow)
			{
				manualFollowTimer -= elapsed;
				if(manualFollowTimer <= 0)
				{
					vcamHasFollow = false;
					vcamManualFollow = false;
				}
			}
			else if(isPlaying && eventHoldTimer > 0)
			{
				eventHoldTimer -= elapsed;
				if(eventHoldTimer <= 0) vcamHasFollow = false;
			}
			return;
		}

		var ps:PlayState = PlayState.instance;
		if(ps != null && ps.camFollow != null && !previewPanning)
		{
			var tx:Float = ps.camFollow.x - FlxG.width / (2 * vz);
			var ty:Float = ps.camFollow.y - FlxG.height / (2 * vz);
			var l:Float = Math.max(0.03, Math.min(1, elapsed * 7));
			vcamScrollX += (tx - vcamScrollX) * l;
			vcamScrollY += (ty - vcamScrollY) * l;
			vcamFollowX = ps.camFollow.x;
			vcamFollowY = ps.camFollow.y;
		}
	}

	function setVcamZoomKeepCenter(nz:Float):Void
	{
		var vz0:Float = Math.max(0.05, vcamZoom);
		var cx:Float = vcamScrollX + 0.5 * FlxG.width / vz0;
		var cy:Float = vcamScrollY + 0.5 * FlxG.height / vz0;
		vcamZoom = nz;
		var vz1:Float = Math.max(0.05, nz);
		vcamScrollX = cx - 0.5 * FlxG.width / vz1;
		vcamScrollY = cy - 0.5 * FlxG.height / vz1;
	}

	function simulateCameraAt(ms:Float, recenter:Bool = false):Void
	{
		vcamZoom = Math.max(0.05, prevCamZoom);
		vcamScrollX = prevScrollX;
		vcamScrollY = prevScrollY;
		vcamAngle = 0;
		vcamHasFollow = false;
		vcamFollowX = vcamScrollX + FlxG.width / (2 * vcamZoom);
		vcamFollowY = vcamScrollY + FlxG.height / (2 * vcamZoom);
		if(vcamZoomTween != null) { vcamZoomTween.cancel(); vcamZoomTween = null; }
		if(vcamAngleTween != null) { vcamAngleTween.cancel(); vcamAngleTween = null; }
		if(vcamFollowTween != null) { vcamFollowTween.cancel(); vcamFollowTween = null; }
		var sorted:Array<EdEvent> = events.copy();
		CameraEditorData.sortByTime(sorted);
		for(ev in sorted)
		{
			if(ev.time > ms) break;
			applyEvent(ev, true);
		}
		if(vcamHasFollow)
		{
			var vz:Float = Math.max(0.05, vcamZoom);
			vcamScrollX = vcamFollowX - FlxG.width / (2 * vz);
			vcamScrollY = vcamFollowY - FlxG.height / (2 * vz);
		}
		if(recenter) centerSceneOnViewfinder();
	}

	function easeNameFrom(base:String, dir:String):String
	{
		if(base == null || base.length < 1 || base == 'linear') return 'linear';
		if(base == 'INSTANT' || base == 'CLASSIC') return base;
		if(dir == null || dir.length < 1) dir = 'InOut';
		return base + dir;
	}

	function splitEase(name:String):{base:String, dir:String}
	{
		var n:String = (name == null) ? '' : StringTools.trim(name);
		if(n.length < 1 || n == 'linear') return {base: 'linear', dir: 'InOut'};
		for(b in EASE_NO_DIR) if(n == b) return {base: b, dir: 'InOut'};
		for(b in EASE_BASES)
		{
			if(b == 'linear') continue;
			if(n == b + 'InOut') return {base: b, dir: 'InOut'};
			if(n == b + 'Out') return {base: b, dir: 'Out'};
			if(n == b + 'In') return {base: b, dir: 'In'};
		}
		return {base: 'linear', dir: 'InOut'};
	}

	function setEaseSectionVisible(v:Bool):Void
	{
		easeVisible = v;
		refreshEaseCurveUI();
	}

	function easeTokenNow():String
	{
		if(easeBase != null && easeBase.text == EASE_CUSTOM)
		{
			if(customCurve.length == 0) customCurve = CustomEase.defaultCurve();
			return 'custom:' + CustomEase.encode(customCurve);
		}
		var b:String = (easeBase != null && easeBase.text != null) ? easeBase.text : 'linear';
		var d:String = (easeDir != null && easeDir.text != null) ? easeDir.text : 'InOut';
		if(b == EASE_CUSTOM) b = 'linear';
		return easeNameFrom(b, d);
	}

	function setEaseList(withClassic:Bool):Void
	{
		if(easeBase == null) return;
		var want:Array<String> = withClassic ? EASE_UI_FOCUS : EASE_UI_OTHER;
		if(easeBase.list.length != want.length) easeBase.list = want;
	}

	function applyEaseToPanel(ev:EdEvent, withClassic:Bool, defTok:String):Void
	{
		var tok:String = eventEaseToken(ev);
		if(tok.length < 1) tok = defTok;
		var custom:Bool = (tok.indexOf('custom:') == 0);
		if(custom) customCurve = CustomEase.decode(tok);
		setEaseList(withClassic);
		setEaseValues(custom ? 'custom:' : tok);
		setCurveEditorVisible(custom);
		setEaseSectionVisible(true);
	}

	function setEaseValues(name:String):Void
	{
		if(easeBase == null || easeDir == null) return;
		if(name != null && name.indexOf('custom:') == 0)
		{
			easeBase.selectedLabel = EASE_CUSTOM;
			if(easeBase.text == null || easeBase.text.length < 1) easeBase.text = EASE_CUSTOM;
			return;
		}
		var sp:{base:String, dir:String} = splitEase(name);
		easeBase.selectedLabel = sp.base;
		easeBase.text = sp.base;
		easeDir.selectedLabel = sp.dir;
		easeDir.text = sp.dir;
	}

	function onEaseChanged():Void
	{
		refreshEaseCurveUI();
		if(panelUpdating) return;
		var idx:Int = primarySel();
		if(idx < 0 || idx >= events.length) return;
		var ev:EdEvent = events[idx];
		setEventEase(ev, easeTokenNow());
		setCurveEditorVisible(easeBase != null && easeBase.selectedLabel == EASE_CUSTOM);
		syncData();
		rebuildEventSprites();
		simulateCameraAt(previewCursorMs);
	}

	function refreshEaseCurveUI():Void
	{
		if(easeCurveBg == null || easeCurveBars.length < 2) return;
		var ok:Bool = easeVisible && !panelAUserHidden && panelH_A >= 540;
		layoutPanelInfo();
		var tok:String = '';
		var customSamples:Array<Float> = null;
		var idx:Int = primarySel();
		if(idx >= 0 && idx < events.length)
		{
			var parts:Array<String> = (events[idx].v2 == null) ? [] : events[idx].v2.split(',');
			var ei:Int = easeIndex(events[idx].name);
			if(parts.length > ei)
			{
				var t:String = StringTools.trim(parts[ei]);
				if(t.indexOf('custom:') == 0) customSamples = CustomEase.decode(t);
				else tok = t;
			}
		}
		if(customSamples == null && tok.length < 1) tok = easeTokenNow();

		var base:String = splitEase(tok).base;
		var isCustom:Bool = (customSamples != null) || (easeBase != null && easeBase.selectedLabel == EASE_CUSTOM);
		var showCurve:Bool = ok && !isCustom;
		if(isCustom)
		{
			if(customSamples != null) customCurve = customSamples;
			else if(customCurve.length == 0) customCurve = CustomEase.defaultCurve();
			setCurveEditorVisible(true);
		}
		else
			setCurveEditorVisible(false);

		if(easeTitle != null)
		{
			easeTitle.visible = ok;
			easeTitle.text = isCustom ? '缓动曲线（自定义，见下方编辑器）'
				: (base == 'CLASSIC' ? '缓动曲线（忽略时长，交给摄像机跟随）'
					: (base == 'INSTANT' ? '缓动曲线（忽略时长，瞬间到位）' : '缓动曲线（基础 × 方向）'));
			easeTitle.setFormat(Paths.font(Language.pickFont(easeTitle.text)), fs(12), 0xFFB9B9B9);
		}
		if(easeBase != null) easeBase.visible = ok;
		if(easeDir != null) easeDir.visible = ok && !EASE_NO_DIR.contains(base) && !isCustom;
		if(easeGraphFrame != null) easeGraphFrame.visible = showCurve;
		if(easeCurveBg != null) easeCurveBg.visible = showCurve;
		if(easeDotFrame != null) easeDotFrame.visible = showCurve;
		if(easeDotStrip != null) easeDotStrip.visible = showCurve;
		if(easeRef0 != null) easeRef0.visible = showCurve;
		if(easeRef1 != null) easeRef1.visible = showCurve;
		for(b in easeCurveBars) if(b != null) b.visible = showCurve;
		if(easeDot != null) easeDot.visible = showCurve;

		easeCurveVals = [];
		easeDotT = 0;
		easeDotPause = 0;
		if(!showCurve) return;

		var n:Int = easeCurveBars.length;
		var raw:Array<Float> = [];
		for(i in 0...n)
		{
			var t:Float = i / (n - 1);
			var v:Float = (customSamples != null) ? CustomEase.eval(customSamples, t) : easeRawAt(tok, t);
			if(Math.isNaN(v)) v = t;
			raw.push(v);
		}

		var lo:Float = 0;
		var hi:Float = 1;
		for(v in raw)
		{
			if(v < lo) lo = v;
			if(v > hi) hi = v;
		}
		var span:Float = hi - lo;
		if(span < 0.0001) span = 1;

		var bx:Float = easeCurveBg.x;
		var by:Float = easeCurveBg.y;
		var bw:Float = easeCurveBg.width;
		var bh:Float = easeCurveBg.height;
		if(easeRef1 != null) easeRef1.setPosition(bx, by + (1 - (1 - lo) / span) * (bh - 1));
		if(easeRef0 != null) easeRef0.setPosition(bx, by + (1 - (0 - lo) / span) * (bh - 1));

		var stepX:Float = bw / n;
		var lastY:Float = -1;
		for(i in 0...n)
		{
			var nv:Float = (raw[i] - lo) / span;
			easeCurveVals.push(nv);
			var y:Float = by + (1 - nv) * (bh - 1);
			var y0:Float = (lastY < 0) ? y : Math.min(y, lastY);
			var y1:Float = (lastY < 0) ? y : Math.max(y, lastY);
			var bar:FlxSprite = easeCurveBars[i];
			bar.x = bx + i * stepX;
			bar.y = y0;
			bar.scale.y = Math.max(1, y1 - y0 + 1);
			lastY = y;
		}
		positionEaseDot();
	}

	function easeRawAt(tok:String, t:Float):Float
	{
		if(tok == null || tok.length < 1 || tok == 'linear') return FlxEase.linear(t);
		var fn:Float->Float = Reflect.field(FlxEase, tok);
		if(fn == null) return FlxEase.linear(t);
		return fn(t);
	}

	function positionEaseDot():Void
	{
		if(easeDot == null || easeCurveBg == null || easeCurveVals.length < 2) return;
		var v:Float = Math.max(0, Math.min(1, CustomEase.eval(easeCurveVals, easeDotT)));
		var cy:Float = easeCurveBg.y + (1 - v) * (easeCurveBg.height - 1);
		var cx:Float = (easeDotStrip != null) ? (easeDotStrip.x + (easeDotStrip.width - easeDot.width) / 2) : (easeCurveBg.x + easeCurveBg.width + 8);
		easeDot.setPosition(Math.round(cx), Math.round(cy - easeDot.height / 2));
	}

	function updateEaseDotPreview(elapsed:Float):Void
	{
		if(easeDot == null || !easeDot.visible || easeCurveVals.length < 2) return;
		if(easeDotPause > 0)
		{
			easeDotPause -= elapsed;
			if(easeDotPause <= 0) easeDotT = 0;
		}
		else
		{
			easeDotT += elapsed * (EASE_DOT_FRAMES - 1) / EASE_DOT_FRAMES;
			if(easeDotT >= 1)
			{
				easeDotT = 1;
				easeDotPause = 0.15 + 1 / EASE_DOT_FRAMES;
			}
		}
		positionEaseDot();
	}

	function layoutCurveEditor():Void
	{
		if(curveEditorBg == null || curveHandles.length < 1 || curveLine == null) return;
		if(customCurve.length == 0) customCurve = CustomEase.defaultCurve();
		var n:Int = curveHandles.length;
		var bx:Float = curveEditorX + 6;
		var by:Float = curveEditorY + 6;
		var bw:Float = curveEditorW - 12;
		var bh:Float = curveEditorH - 12;
		curveLine.makeGraphic(Std.int(curveEditorW), Std.int(curveEditorH), FlxColor.TRANSPARENT, true);
		var steps:Int = 40;
		var px:Float = 0;
		var py:Float = 0;
		for(s in 0...steps + 1)
		{
			var t:Float = s / steps;
			var v:Float = Math.max(0, Math.min(1, CustomEase.eval(customCurve, t)));
			var cx:Float = bx + t * bw - curveEditorX;
			var cy:Float = by + (1 - v) * bh - curveEditorY;
			if(s > 0)
			{
				FlxSpriteUtil.drawLine(curveLine, px, py, cx, cy, {thickness: 4, color: 0x447ABFBC});
				FlxSpriteUtil.drawLine(curveLine, px, py, cx, cy, {thickness: 2, color: 0xFF9FE0DC});
			}
			px = cx;
			py = cy;
		}
		curveLine.dirty = true;
		for(i in 0...n)
		{
			var t:Float = (n > 1) ? i / (n - 1) : 0;
			var v:Float = Math.max(0, Math.min(1, customCurve[i]));
			var hsp:FlxSprite = curveHandles[i];
			hsp.x = bx + t * bw - 6;
			hsp.y = by + (1 - v) * bh - 6;
		}
	}

	function setCurveEditorVisible(v:Bool):Void
	{
		if(curveEditorBg != null) curveEditorBg.visible = v;
		if(curveLine != null) curveLine.visible = v;
		for(h in curveHandles) h.visible = v;
		if(v) layoutCurveEditor();
	}

	function applyCustomCurveToEvent():Void
	{
		var idx:Int = primarySel();
		if(idx < 0 || idx >= events.length) return;
		var ev:EdEvent = events[idx];
		if(customCurve.length == 0) customCurve = CustomEase.defaultCurve();
		setEventEase(ev, 'custom:' + CustomEase.encode(customCurve));
		syncData();
		simulateCameraAt(previewCursorMs);
	}

	function handleCurveDrag():Void
	{
		if(curveHandles.length == 0) return;
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		if(curveDragging < 0)
		{
			if(FlxG.mouse.justPressed && curveEditorBg != null && curveEditorBg.visible)
			{
				for(i in 0...curveHandles.length)
				{
					var h:FlxSprite = curveHandles[i];
					if(mx >= h.x - 7 && mx <= h.x + 17 && my >= h.y - 7 && my <= h.y + 17)
					{
						curveDragging = i;
						break;
					}
				}
			}
			return;
		}
		if(FlxG.mouse.justReleased)
		{
			curveDragging = -1;
			pushUndo('编辑自定义曲线');
			applyCustomCurveToEvent();
			return;
		}
		var by:Float = curveEditorY + 6;
		var bh:Float = curveEditorH - 12;
		var v:Float = 1 - (my - by) / bh;
		v = Math.max(0, Math.min(1, v));
		customCurve[curveDragging] = v;
		layoutCurveEditor();
		applyCustomCurveToEvent();
	}

	function setViewfinderCameras():Void
	{
		if(PlayState.instance == null || PlayState.instance.camGame == null || viewfinderCam == null) return;
		camRestoreMap = new Map<FlxBasic, Array<FlxCamera>>();
		var list:Array<FlxCamera> = [PlayState.instance.camGame, viewfinderCam];
		for(m in PlayState.instance.members)
			walkSetCameras(m, list);
	}

	function walkSetCameras(obj:FlxBasic, list:Array<FlxCamera>):Void
	{
		if(obj == null) return;
		if(PlayState.instance != null && obj.cameras != null && obj.cameras.indexOf(PlayState.instance.camHUD) != -1) return;
		if(obj.cameras == null || obj.cameras.indexOf(viewfinderCam) != -1 || obj.cameras.indexOf(editorCam) != -1)
		{
			camRestoreMap.set(obj, obj.cameras);
			obj.cameras = list;
		}
		if(obj is FlxGroup)
		{
			var g:FlxGroup = cast obj;
			for(mem in g.members)
				if(mem != null) walkSetCameras(mem, list);
		}
	}

	function restoreViewfinderCameras():Void
	{
		for(obj => orig in camRestoreMap)
			obj.cameras = orig;
		camRestoreMap = new Map<FlxBasic, Array<FlxCamera>>();
	}

	function applyVcamCutout():Void
	{
		var st:Int = showPassepartout ? 1 : 0;
		if(st == vcamCutState) return;
		vcamCutState = st;
		if(vfNine.length >= 9)
		{
			var key:String = showPassepartout ? 'ui/camera-editor/vcam/vcam_slice_cutout' : 'ui/camera-editor/vcam/vcam_slice';
			for(i in 0...9)
			{
				var p:FlxSprite = vfNine[i];
				p.loadGraphic(Paths.image(key), true, 30, 30);
				p.animation.add('f', [i], 0, false, false);
				p.animation.play('f');
				p.color = 0xFF7ABFBC;
				p.alpha = 0.5;
			}
		}
		if(extL != null)
		{
			setSliceGraphic(extL, showPassepartout ? 'ui/camera-editor/vcam/vcam_slice_cutout_left' : 'ui/camera-editor/vcam/vcam_slice_left');
			extL.color = 0xFF7ABF9B;
			extL.alpha = 0.3;
		}
		if(extR != null)
		{
			setSliceGraphic(extR, showPassepartout ? 'ui/camera-editor/vcam/vcam_slice_cutout_right' : 'ui/camera-editor/vcam/vcam_slice_right');
			extR.color = 0xFF7ABF9B;
			extR.alpha = 0.3;
		}
	}

	function updatePreviewOverlay():Void
	{
		if(PlayState.instance == null || PlayState.instance.camGame == null) return;
		applyVcamCutout();
		var ps:PlayState = PlayState.instance;
		var pvTop:Float = topH;

		layoutViewfinderWindow();
		var vz:Float = Math.max(0.05, vcamZoom);
		var vcamCX:Float = vcamScrollX + 0.5 * FlxG.width / vz;
		var vcamCY:Float = vcamScrollY + 0.5 * FlxG.height / vz;
		var vfZoom:Float = vz * vfWinW / FlxG.width;
		if(viewfinderCam != null)
		{
			var nw:Int = Std.int(vfWinW);
			var nh:Int = Std.int(vfWinH);
			if(viewfinderCam.width != nw || viewfinderCam.height != nh)
			{
				viewfinderCam.width = nw;
				viewfinderCam.height = nh;
			}
			viewfinderCam.x = Std.int(vfWinX);
			viewfinderCam.y = Std.int(vfWinY);
			viewfinderCam.zoom = vfZoom;
			viewfinderCam.angle = vcamAngle;
			viewfinderCam.scroll.set(vcamCX - vfWinW / 2, vcamCY - vfWinH / 2);
		}

		var fx:Float = vfWinX;
		var fy:Float = vfWinY;
		var fw:Float = vfWinW;
		var fh:Float = vfWinH;

		layoutNineSlice(fx, fy, fw, fh);
		vcamSliceSolid.setPosition(fx, fy);
		vcamSliceSolid.setGraphicSize(fw, fh);
		vcamSliceSolid.updateHitbox();
		vcamSliceSolid.origin.set(fw / 2, fh / 2);
		vcamSliceSolid.angle = vcamAngle;

		var cs:Float = Math.min(30, Math.max(16, fw * 0.045));
		vcamCornerTL.setPosition(fx, fy);
		vcamCornerTL.setGraphicSize(cs, cs);
		vcamCornerTL.updateHitbox();
		vcamCornerTR.setPosition(fx + fw - cs, fy);
		vcamCornerTR.setGraphicSize(cs, cs);
		vcamCornerTR.updateHitbox();
		vcamCornerBL.setPosition(fx, fy + fh - cs);
		vcamCornerBL.setGraphicSize(cs, cs);
		vcamCornerBL.updateHitbox();
		vcamCornerBR.setPosition(fx + fw - cs, fy + fh - cs);
		vcamCornerBR.setGraphicSize(cs, cs);
		vcamCornerBR.updateHitbox();

		var lw:Float = Math.max(12, fw * 0.05);
		vcamLineT.setPosition(fx + fw / 2 - lw / 2, fy);
		vcamLineT.setGraphicSize(lw, 6);
		vcamLineT.updateHitbox();
		vcamLineB.setPosition(fx + fw / 2 - lw / 2, fy + fh - 6);
		vcamLineB.setGraphicSize(lw, 6);
		vcamLineB.updateHitbox();
		var lh:Float = Math.max(12, fh * 0.05);
		vcamLineL.setPosition(fx, fy + fh / 2 - lh / 2);
		vcamLineL.setGraphicSize(6, lh);
		vcamLineL.updateHitbox();
		vcamLineR.setPosition(fx + fw - 6, fy + fh / 2 - lh / 2);
		vcamLineR.setGraphicSize(6, lh);
		vcamLineR.updateHitbox();

		vcamCenter.setPosition(fx + fw / 2 - vcamCenter.frameWidth / 2, fy + fh / 2 - vcamCenter.frameHeight / 2);

		for(p in [passeT, passeB, passeL, passeR])
		{
			p.visible = showPassepartout;
			p.alpha = passeAlpha;
		}
		if(showPassepartout)
		{
			passeT.setPosition(fx, pvTop);
			passeT.setGraphicSize(fw, Math.max(0, fy - pvTop));
			passeT.updateHitbox();
			passeB.setPosition(fx, fy + fh);
			passeB.setGraphicSize(fw, Math.max(0, timelineTop - fy - fh));
			passeB.updateHitbox();
			passeL.setPosition(0, fy);
			passeL.setGraphicSize(Math.max(0, fx), fh);
			passeL.updateHitbox();
			passeR.setPosition(fx + fw, fy);
			passeR.setGraphicSize(Math.max(0, FlxG.width - fx - fw), fh);
			passeR.updateHitbox();
		}

		var extW:Float = fw * 0.15;
		extL.visible = showExtendedBounds;
		extL.setPosition(fx - extW, fy);
		extL.setGraphicSize(extW, fh);
		extL.updateHitbox();
		extR.visible = showExtendedBounds;
		extR.setPosition(fx + fw, fy);
		extR.setGraphicSize(extW, fh);
		extR.updateHitbox();

		if(vcamSmall.length >= 6)
		{
			var sc:Float = 14;
			var slh:Float = 30;
			vcamSmall[0].setPosition(fx - extW, fy);
			vcamSmall[1].setPosition(fx + fw + extW - sc, fy);
			vcamSmall[2].setPosition(fx - extW, fy + fh - sc);
			vcamSmall[3].setPosition(fx + fw + extW - sc, fy + fh - sc);
			vcamSmall[4].setPosition(fx - extW, fy + fh / 2 - slh / 2);
			vcamSmall[5].setPosition(fx + fw + extW - 6, fy + fh / 2 - slh / 2);
			for(i in 0...6)
			{
				var s:FlxSprite = vcamSmall[i];
				if(i < 4) s.setGraphicSize(sc, sc);
				else s.setGraphicSize(6, slh);
				s.updateHitbox();
				s.color = showPassepartout ? FlxColor.WHITE : FlxColor.BLACK;
				s.visible = showExtendedBounds;
			}
		}

		var dotX:Float = vcamFollowX;
		var dotY:Float = vcamFollowY;
		viewfinderDot.visible = true;
		viewfinderDot.setPosition(
			(dotX - vcamCX) * vfZoom + fx + fw / 2 - 5,
			(dotY - vcamCY) * vfZoom + fy + fh / 2 - 5);

		updateViewfinderDrag(fx, fy, fw, fh);

		if(previewZoomText != null)
		{
			var zs:String = Std.string(Math.round(previewZoom * 100) / 100);
			previewZoomText.text = '预览缩放 ×' + zs + '（在预览区用滚轮调整，不影响谱面）　取景框 = 游戏实际画面';
			previewZoomText.y = timelineTop - 26;
		}
	}

	function layoutNineSlice(fx:Float, fy:Float, fw:Float, fh:Float):Void
	{
		var bw:Float = 30;
		if(fw < bw * 2 || fh < bw * 2) return;
		var x0:Float = fx;
		var y0:Float = fy;
		var x2:Float = fx + fw - bw;
		var y2:Float = fy + fh - bw;
		var midW:Float = fw - bw * 2;
		var midH:Float = fh - bw * 2;
		var p:FlxSprite;
		p = vfNine[0]; p.setPosition(x0, y0); p.setGraphicSize(bw, bw); p.updateHitbox();
		p = vfNine[1]; p.setPosition(x0 + bw, y0); p.setGraphicSize(midW, bw); p.updateHitbox();
		p = vfNine[2]; p.setPosition(x2, y0); p.setGraphicSize(bw, bw); p.updateHitbox();
		p = vfNine[3]; p.setPosition(x0, y0 + bw); p.setGraphicSize(bw, midH); p.updateHitbox();
		p = vfNine[4]; p.setPosition(x0 + bw, y0 + bw); p.setGraphicSize(midW, midH); p.updateHitbox();
		p = vfNine[5]; p.setPosition(x2, y0 + bw); p.setGraphicSize(bw, midH); p.updateHitbox();
		p = vfNine[6]; p.setPosition(x0, y2); p.setGraphicSize(bw, bw); p.updateHitbox();
		p = vfNine[7]; p.setPosition(x0 + bw, y2); p.setGraphicSize(midW, bw); p.updateHitbox();
		p = vfNine[8]; p.setPosition(x2, y2); p.setGraphicSize(bw, bw); p.updateHitbox();
	}

	function updateMiniViewfinder(fx:Float, fy:Float, fw:Float, fh:Float, dotOx:Float, dotOy:Float):Void
	{
		if(miniBg == null || miniViewfinder == null) return;
		var ps:PlayState = PlayState.instance;
		var baseZoom:Float = (prevCamZoom > 0.01) ? prevCamZoom : 1;
		var fullW:Float = FlxG.width / baseZoom;
		var fullH:Float = FlxG.height / baseZoom;
		var mw:Float = miniBg.width - 12;
		var mh:Float = miniBg.height - 12;
		var ms:Float = Math.min(mw / fullW, mh / fullH);
		var mfw:Float = fullW * ms;
		var mfh:Float = fullH * ms;
		miniViewfinder.setPosition(miniBg.x + (miniBg.width - mfw) / 2, miniBg.y + (miniBg.height - mfh) / 2);
		miniViewfinder.setGraphicSize(mfw, mfh);
		miniViewfinder.updateHitbox();
		var ratioX:Float = mfw / fw;
		var ratioY:Float = mfh / fh;
		miniDot.setPosition(miniViewfinder.x + (fx + dotOx + fw / 2) * ratioX - miniDot.frameWidth / 2,
			miniViewfinder.y + (fy + dotOy + fh / 2) * ratioY - miniDot.frameHeight / 2);
		if(miniText != null)
			miniText.text = '取景 ' + (Std.string(Math.round(baseZoom * 100) / 100));
	}

	function updateViewfinderDrag(fx:Float, fy:Float, fw:Float, fh:Float):Void
	{
		if(PlayState.instance == null) return;
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		var gz:Float = Math.max(0.05, vcamZoom) * vfWinW / FlxG.width;
		if(vfDrag)
		{
			if(FlxG.mouse.justReleased)
			{
				vfDrag = false;
				pushUndo('拖动取景框');
				syncData();
				refreshPanel();
				simulateCameraAt(previewCursorMs);
				return;
			}
			var dx:Float = (mx - vfDragLastX) / gz;
			var dy:Float = (my - vfDragLastY) / gz;
			vfDragLastX = mx;
			vfDragLastY = my;
			if(dx == 0 && dy == 0) return;
			var sel:Int = primarySel();
			if(sel < 0 || sel >= events.length) return;
			var ev:EdEvent = events[sel];
			if(ev.name == 'Camera Follow Pos')
			{
				var xv:Float = Std.parseFloat(Std.string(ev.v1));
				if(Math.isNaN(xv)) xv = 0;
				var fparts:Array<String> = (ev.v2 != null && ev.v2.length > 0) ? ev.v2.split(',') : ['0'];
				var yv:Float = Std.parseFloat(fparts[0]);
				if(Math.isNaN(yv)) yv = 0;
				fparts[0] = Std.string(Math.round((yv + dy) * 10) / 10);
				ev.v1 = Std.string(Math.round((xv + dx) * 10) / 10);
				ev.v2 = fparts.join(',');
			}
			else if(ev.name == 'Focus Camera')
			{
				var parts:Array<String> = ev.v2 != null ? ev.v2.split(',') : [];
				var xv:Float = parts.length > 0 ? Std.parseFloat(StringTools.trim(parts[0])) : 0;
				if(Math.isNaN(xv)) xv = 0;
				var yv:Float = parts.length > 1 ? Std.parseFloat(StringTools.trim(parts[1])) : 0;
				if(Math.isNaN(yv)) yv = 0;
				var rest:Array<String> = (parts.length > 2) ? parts.slice(2, parts.length) : ['2', 'CLASSIC'];
				ev.v2 = [Std.string(Math.round((xv + dx) * 10) / 10), Std.string(Math.round((yv + dy) * 10) / 10)].concat(rest).join(',');
			}
			else
			{
				vfDrag = false;
				return;
			}
			syncData();
			simulateCameraAt(previewCursorMs);
			return;
		}
		if(!FlxG.mouse.justPressed || FlxG.mouse.justPressedRight) return;
		if(draggingIndex >= 0 || dragResizeMode != 0 || draggingSplitter) return;
		if(my < topH || my >= timelineTop) return;
		if(panelBg != null && mx >= panelBg.x && mx <= panelBg.x + rightW && my >= panelBg.y && my <= panelBg.y + panelH_A) return;
		var sel:Int = primarySel();
		if(sel < 0 || sel >= events.length) return;
		var ev:EdEvent = events[sel];
		if(ev.name != 'Camera Follow Pos' && ev.name != 'Focus Camera') return;
		if(mx < fx || mx > fx + fw || my < fy || my > fy + fh) return;
		vfDrag = true;
		vfDragLastX = mx;
		vfDragLastY = my;
	}

	function buildStrumPreview():Void
	{
		try
		{
			strumPreviewY = tlTop + rulerH + CameraEditorData.layerCount() * layerH + 12;
			var barH:Int = strumH;

			strumPreviewBg = new FlxSprite(0, strumPreviewY).makeGraphic(FlxG.width, barH, 0xAA101010);
			strumPreviewBg.scrollFactor.set();
			add(strumPreviewBg);

			strumPreviewGroup = new FlxTypedGroup<StrumNote>();
			var slot:Float = 68;
			var startX:Float = timelineX + 20;
			for(i in 0...8)
			{
				var n:StrumNote = new StrumNote(startX + i * slot, strumPreviewY + barH/2, i % 4, 0);
				n.scrollFactor.set();
				n.playAnim('static');
				n.alpha = 0.9;
				n.updateHitbox();
				strumPreviewGroup.add(n);
			}
			add(strumPreviewGroup);

			strumLabels = new FlxText(startX + 8 * slot + 16, strumPreviewY + barH/2 - 8, 280, '左：对手(红)  右：玩家(绿)  播放时自动按键', fs(12));
			strumLabels.scrollFactor.set();
			add(strumLabels);

			noteMarkGroup = new FlxTypedGroup<FlxSprite>();
			for(i in 0...96)
			{
				var m:FlxSprite = new FlxSprite().makeGraphic(3, 22, 0xFFFFFFFF);
				m.visible = false;
				noteMarkGroup.add(m);
			}
			add(noteMarkGroup);

			refreshStrumPreview();
		}
		catch(e:Dynamic)
		{
			trace('[CamEd] strum preview failed: $e');
			strumPreviewVisible = false;
			if(strumPreviewBg == null) strumPreviewBg = new FlxSprite();
			if(strumPreviewGroup == null) strumPreviewGroup = new FlxTypedGroup<StrumNote>();
			if(noteMarkGroup == null) noteMarkGroup = new FlxTypedGroup<FlxSprite>();
			if(strumLabels == null) strumLabels = new FlxText(0, 0, 0, '');
		}
		strumPreviewVisible = false;
		refreshStrumPreview();
	}

	function buildSplitter():Void
	{
		splitterBar = new FlxSprite(timelineX, strumPreviewY + 2).makeGraphic(timelineRight - timelineX, 8, 0xFF3A3A3A);
		splitterBar.scrollFactor.set();
		add(splitterBar);

		resizeCursor = new FlxSprite(0, tlTop + rulerH).makeGraphic(2, timelineAreaH, 0xFFFFFFFF);
		resizeCursor.scrollFactor.set();
		resizeCursor.visible = false;
		add(resizeCursor);
	}

	function updateSplitter():Void
	{
		if(splitterBar == null) return;
		splitterBar.y = strumPreviewY + 2;
		splitterBar.x = timelineX;
		splitterBar.makeGraphic(timelineRight - timelineX, 8, splitterBar.color);
		if(resizeCursor != null)
		{
			resizeCursor.y = tlTop + rulerH;
			resizeCursor.makeGraphic(2, timelineAreaH, 0xFFFFFFFF);
		}
		refreshRulerPositions();
		if(hintText != null) hintText.y = timelineTop + timelineAreaH - 32;
	}

	function buildSongNotesCache():Void
	{
		songNotesCache = [];
		songNotesPtr = 0;
		if(PlayState.SONG == null) return;
		var secIdx:Int = 0;
		for(sec in PlayState.SONG.notes)
		{
			if(sec == null) { secIdx++; continue; }
			var secTime:Float = getSectionTimeMs(secIdx);
			if(sec.sectionNotes != null)
			{
				for(note in sec.sectionNotes)
				{
					if(note == null || note.length < 2) continue;
					var t:Float = Std.parseFloat(Std.string(note[0]));
					if(Math.isNaN(t)) continue;
					songNotesCache.push({time: t, dir: Std.int(note[1]) % 4, mustHit: sec.mustHitSection});
				}
			}
			secIdx++;
		}
		songNotesCache.sort(function(a, b) return Std.int(a.time - b.time));
	}

	function refreshStrumPreview():Void
	{
		if(strumPreviewBg == null || strumPreviewGroup == null) return;
		var show:Bool = strumPreviewVisible;
		strumPreviewBg.visible = show;
		strumPreviewGroup.visible = show;
		if(strumLabels != null) strumLabels.visible = show;
		if(noteMarkGroup != null) noteMarkGroup.visible = show;
	}

	function updateStrumPreview():Void
	{
		if(!strumPreviewVisible) return;
		if(strumPreviewGroup == null || noteMarkGroup == null) return;

		var poolIdx:Int = 0;
		var members:Array<FlxSprite> = noteMarkGroup.members;
		var laneY:Float = strumPreviewY + 8;
		for(n in songNotesCache)
		{
			var nx:Float = timelineX + (n.time - scrollMs) * pxPerMs;
			if(nx < timelineX - 4 || nx > timelineRight + 4) continue;
			if(poolIdx >= members.length) break;
			var m:FlxSprite = members[poolIdx++];
			m.visible = true;
			m.x = nx - 1.5;
			m.y = laneY + (n.mustHit ? 3 : 29);
			m.color = n.mustHit ? 0xFF7CFC00 : 0xFFFF6961;
		}
		while(poolIdx < members.length)
		{
			members[poolIdx].visible = false;
			poolIdx++;
		}

		if(!isPlaying) return;
		while(songNotesPtr < songNotesCache.length && songNotesCache[songNotesPtr].time <= previewCursorMs)
		{
			var nn = songNotesCache[songNotesPtr];
			var strum:StrumNote = strumPreviewGroup.members[nn.mustHit ? nn.dir : 4 + nn.dir];
			if(strum != null)
			{
				strum.playAnim('confirm');
				strum.animation.finishCallback = function(_) strum.playAnim('static');
			}
			songNotesPtr++;
		}
	}

	function buildPlayhead():Void
	{
		playhead = new FlxSprite(timelineX, timelineTop).makeGraphic(2, 1, 0xFFFF5C5C);
		playhead.scrollFactor.set();
		playhead.origin.set(0, 0);
		playhead.scale.y = Math.max(1, timelineAreaH);
		add(playhead);
	}

	override function update(elapsed:Float):Void
	{
		var dlg:String = dialogInUse();
		setDialogVisible(dlg);
		super.update(elapsed);
		holdGameCamera();

		if(statusTimer > 0)
		{
			statusTimer -= elapsed;
			if(statusTimer <= 0 && statusText != null) statusText.visible = false;
		}

		if(dlg != '')
		{
			handleDialogKeys(dlg);
			return;
		}

		handleKeys();
		handleMouse();

		if(isPlaying || (livePreview && !draggingScrollbar))
		{
			if(isPlaying)
			{
				if(FlxG.sound.music != null && FlxG.sound.music.playing)
				{
					previewCursorMs = FlxG.sound.music.time;
					Conductor.songPosition = previewCursorMs;
				}
				else
				{
					previewCursorMs += elapsed * 1000;
					Conductor.songPosition = previewCursorMs;
				}
			}
			else
			{
				previewCursorMs = Conductor.songPosition;
				if(songEndMs > 0 && previewCursorMs > songEndMs) previewCursorMs = songEndMs;
			}

			if(isPlaying && songEndMs > 0 && previewCursorMs >= songEndMs)
			{
				stopPlayback(true);
			}
			else
			{
				applyPendingEvents();
			}
			stepVirtualCamera(elapsed);
			if(manualScrollTimer > 0) manualScrollTimer -= elapsed;
			else if(autoScrollMode != 0)
			{
				var viewW:Float = timelineRight - timelineX;
				var ppm:Float = Math.max(0.001, pxPerMs);
				if(autoScrollMode == 2)
				{
					scrollMs = Math.max(0, previewCursorMs - viewW * 0.5 / ppm);
				}
				else
				{
					var phPx:Float = (previewCursorMs - scrollMs) * ppm;
					if(phPx > viewW * 0.95 || phPx < 0)
					{
						scrollMs = Math.max(0, previewCursorMs - viewW * 0.05 / ppm);
					}
				}
			}
		}
		else
		{
			stepVirtualCamera(elapsed);
		}

		autoSaveTimer += elapsed;
		if(autoSaveTimer >= 30)
		{
			autoSaveTimer = 0;
			if(dirty)
			{
				var bp:String = CameraEditorData.writeAutoBackup(events);
				if(bp != null) showStatus('已自动备份：' + bp);
			}
		}

		updateEventSpritePositions();
		updateGrid();
		updatePlayhead();
		updateStrumPreview();
		updateBookmarks();
		updateTimeText();
		updateResizeCursor();
		updatePreviewOverlay();
		updateEaseDotPreview(elapsed);
		updateScrollbarVisual();
		if(zoomSlider != null && !zoomSlider.movingHandle && Math.abs(zoomSlider.value - pxPerMs / 0.05) > 0.0001)
			zoomSlider.value = Math.max(0.1, Math.min(5.0, pxPerMs / 0.05));
		if(autoScrollDrop != null && PsychUIInputText.focusOn != autoScrollDrop && autoScrollDrop.selectedIndex != autoScrollMode)
			autoScrollDrop.selectedIndex = autoScrollMode;
		refreshSnapIcon();
	}

	function drivePlayerStrums():Void
	{
		if(PlayState.instance == null || PlayState.instance.playerStrums == null) return;
		while(songNotesPtr < songNotesCache.length && songNotesCache[songNotesPtr].time <= previewCursorMs)
		{
			var nn = songNotesCache[songNotesPtr];
			if(nn.mustHit)
			{
				var strum:StrumNote = PlayState.instance.playerStrums.members[nn.dir];
				if(strum != null) strum.playAnim('confirm' + nn.dir, true);
			}
			songNotesPtr++;
		}
		for(s in PlayState.instance.playerStrums.members)
			if(s != null) s.update(FlxG.elapsed);
	}

	function updateScrollbarVisual():Void
	{
		if(scrollbarThumb == null || scrollbarBg == null) return;
		var trackW:Float = FlxG.width - timelineX - 20;
		if(trackW <= 0) return;
		var ppm:Float = Math.max(0.001, pxPerMs);
		var viewWMs:Float = (timelineRight - timelineX) / ppm;
		var totalMs:Float = Math.max(1, songEndMs);
		var frac:Float = viewWMs / totalMs;
		if(frac > 1) frac = 1;
		var thumbW:Float = Math.max(20, trackW * frac);
		scrollbarThumb.x = timelineX + trackW * (scrollMs / totalMs);
		scrollbarThumb.x = Math.max(timelineX, Math.min(timelineX + trackW - thumbW, scrollbarThumb.x));
		scrollbarThumb.scale.x = thumbW / Math.max(1, scrollbarThumb.frameWidth);
		if(scrollbarPlayheadMark != null)
		{
			var ratio:Float = previewCursorMs / totalMs;
			scrollbarPlayheadMark.x = timelineX + trackW * ratio - 1;
			scrollbarPlayheadMark.visible = ratio >= 0 && ratio <= 1;
		}
	}

	var previewPanning:Bool = false;
	var panStartX:Float = 0;
	var panStartY:Float = 0;
	var panStartScrollX:Float = 0;
	var panStartScrollY:Float = 0;

	function handlePreviewPan():Void
	{
		if(isPlaying) return;
		if(PlayState.instance == null || PlayState.instance.camGame == null) return;
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		if(my < topH || my >= timelineTop || mx < 0 || mx > FlxG.width - rightW)
		{
			previewPanning = false;
			return;
		}
		var pan:Bool = FlxG.mouse.pressedMiddle;
		var gz:Float = Math.max(0.05, pvGz);
		if(pan && !previewPanning)
		{
			previewPanning = true;
			panStartX = mx;
			panStartY = my;
			panStartScrollX = vcamScrollX;
			panStartScrollY = vcamScrollY;
		}
		if(previewPanning && pan)
		{
			vcamScrollX = panStartScrollX - (mx - panStartX) / gz;
			vcamScrollY = panStartScrollY - (my - panStartY) / gz;
			var vz:Float = Math.max(0.05, vcamZoom);
			vcamFollowX = vcamScrollX + FlxG.width / (2 * vz);
			vcamFollowY = vcamScrollY + FlxG.height / (2 * vz);
			vcamHasFollow = true;
			vcamManualFollow = true;
			manualFollowTimer = 9999;
		}
		if(previewPanning && !pan) previewPanning = false;
	}

	function adjustViewfinderZoom(f:Float):Void
	{
		vfWinScale = Math.max(0.4, Math.min(1.6, vfWinScale * f));
		showStatus('取景框缩放 ×' + Std.string(Math.round(vfWinScale * 100) / 100) + '（game 摄像机同步等比缩放）');
	}

	function handlePreviewWheel():Void
	{
		if(isPlaying) return;
		if(FlxG.mouse.wheel == 0) return;
		if(FlxG.keys.pressed.SHIFT)
		{
			adjustViewfinderZoom(FlxG.mouse.wheel > 0 ? 1.1 : 1 / 1.1);
			return;
		}
		var my:Float = FlxG.mouse.gameY;
		if(my < topH || my >= timelineTop) return;
		var mx:Float = FlxG.mouse.gameX;
		if(mx < 0 || mx > FlxG.width - rightW) return;
		var f:Float = FlxG.mouse.wheel > 0 ? 1.1 : 1 / 1.1;
		if(FlxG.keys.pressed.CONTROL)
		{
			var z:Float = Math.max(0.1, Math.min(3.0, vcamZoom * f));
			vcamZoom = z;
			var sel:Int = primarySel();
			if(sel >= 0 && sel < events.length && events[sel].name == 'Zoom Camera')
			{
				events[sel].v1 = Std.string(Math.round(z * 1000) / 1000);
				syncData();
				refreshPanel();
			}
			simulateCameraAt(previewCursorMs);
			return;
		}
		var sel:Int = primarySel();
		if(sel < 0 || sel >= events.length) return;
		var ev:EdEvent = events[sel];
		if(ev.name != 'Zoom Camera') return;
		var z:Float = Math.max(0.1, Math.min(3.0, vcamZoom * f));
		setVcamZoomKeepCenter(z);
		ev.v1 = Std.string(Math.round(z * 1000) / 1000);
		syncData();
		simulateCameraAt(previewCursorMs);
		refreshPanel();
	}

	function updateResizeCursor():Void
	{
		if(resizeCursor == null) return;
		if(dragResizeMode != 0 || draggingSplitter || draggingIndex == -2 || draggingIndex >= 0)
		{
			resizeCursor.visible = false;
			return;
		}
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;
		resizeCursor.visible = false;
		if(my < tlTop + rulerH) return;
		for(i in 0...eventSprites.length)
		{
			if(i >= events.length) break;
			var spr:FlxSprite = eventSprites[i];
			if(!spr.visible) continue;
			if(!eventResizable(events[i])) continue;
			if(my < spr.y - 2 || my > spr.y + Math.max(6, layerH - 6) + 2) continue;
			var w:Float = eventDisplayWidth(events[i]);
			if((mx >= spr.x - 5 && mx <= spr.x + 5) || (mx >= spr.x + w - 5 && mx <= spr.x + w + 5))
			{
				resizeCursor.x = mx - 1;
				resizeCursor.visible = true;
			}
		}
	}

	function dialogInUse():String
	{
		if(uploadChartOpen) return 'upload';
		if(helpOpen) return 'help';
		if(autoGenOpen) return 'autogen';
		if(keybindOpen) return 'keybind';
		if(customLayerOpen) return 'custom';
		if(aboutOpen) return 'about';
		if(welcomeOpen) return 'welcome';
		if(deleteLayerOpen) return 'dellayer';
		if(renameLayerOpen) return 'renlayer';
		if(autoSortOpen) return 'autosort';
		if(backupDialogOpen) return 'backup';
		if(hintDialogOpen) return 'hint';
		return '';
	}

	function handleDialogKeys(dlg:String)
	{
		if(FlxG.keys.justPressed.ESCAPE)
		{
			switch(dlg)
			{
				case 'upload': uploadChartOpen = false;
				case 'help': helpOpen = false;
				case 'autogen': autoGenOpen = false;
				case 'keybind': keybindOpen = false;
				case 'custom': customLayerOpen = false;
				case 'about': aboutOpen = false;
				case 'welcome': welcomeOpen = false;
				case 'dellayer': deleteLayerOpen = false;
				case 'renlayer': renameLayerOpen = false;
				case 'autosort': autoSortOpen = false;
				case 'backup': backupDialogOpen = false;
				case 'hint': hintDialogOpen = false;
			}
		}
		if(dlg == 'renlayer' && FlxG.keys.justPressed.ENTER) performRenameLayer();
		if(dlg == 'help' && FlxG.mouse.wheel != 0) scrollHelp(FlxG.mouse.wheel);
	}

	function setDialogVisible(dlg:String)
	{
		var on:Bool;
		on = dlg == 'upload';
		uploadChartBg.visible = on;
		uploadChartText.visible = on;
		ucOpenBtn.visible = on;
		ucRecentTitle.visible = on;
		ucCancelBtn.visible = on;
		for(b in ucRecentBtns) if(b != null) b.visible = on;
		on = dlg == 'help';
		helpBg.visible = on;
		helpText.visible = on;
		closeHelpBtn.visible = on;
		on = dlg == 'autogen';
		autoGenBg.visible = on;
		focusGenCheck.visible = on;
		zoomGenCheck.visible = on;
		zoomIntervalStepper.visible = on;
		zoomTargetInput.visible = on;
		genBtn.visible = on;
		cancelGenBtn.visible = on;
		for(lb in autoGenLabels) if(lb != null) lb.visible = on;
		on = dlg == 'keybind';
		keybindBg.visible = on;
		closeKeybindBtn.visible = on;
		kbTitle.visible = on;
		kbHint.visible = on;
		for(tf in keybindInputs) tf.visible = on;
		for(lb in keybindLabels) lb.visible = on;
		on = dlg == 'custom';
		customLayerBg.visible = on;
		customLayerTitle.visible = on;
		customNameInput.visible = on;
		customColorInput.visible = on;
		customV1Input.visible = on;
		customV2Input.visible = on;
		addCustomBtn.visible = on;
		closeCustomBtn.visible = on;
		customListLabel.visible = on;
		for(lb in customFieldLabels) lb.visible = on;
		for(row in customLayerRows) row.visible = on;
		for(btn in customLayerDelBtns) btn.visible = on;
		for(sw in customLayerSwatches) sw.visible = on;
		on = dlg == 'about';
		aboutBg.visible = on;
		aboutText.visible = on;
		closeAboutBtn.visible = on;
		on = dlg == 'welcome';
		welcomeBg.visible = on;
		welcomeText.visible = on;
		welcomeHelpBtn.visible = on;
		welcomeGenBtn.visible = on;
		closeWelcomeBtn.visible = on;
		on = dlg == 'dellayer';
		deleteLayerBg.visible = on;
		deleteLayerText.visible = on;
		dlNeverBtn.visible = on;
		dlFlattenBtn.visible = on;
		dlDeleteBtn.visible = on;
		on = dlg == 'renlayer';
		renameLayerBg.visible = on;
		renameLayerText.visible = on;
		renameLayerInput.visible = on;
		renameOkBtn.visible = on;
		renameCancelBtn.visible = on;
		on = dlg == 'autosort';
		autoSortBg.visible = on;
		autoSortText.visible = on;
		asSkipBtn.visible = on;
		asSortBtn.visible = on;
		on = dlg == 'backup';
		backupDialogBg.visible = on;
		backupDialogText.visible = on;
		bdNoBtn.visible = on;
		bdFolderBtn.visible = on;
		bdLoadBtn.visible = on;
		on = dlg == 'hint';
		if(hintDialogBg != null) hintDialogBg.visible = on;
		if(hintDialogText != null) hintDialogText.visible = on;
		if(hdIgnoreBtn != null) hdIgnoreBtn.visible = on;
		if(hdSortBtn != null) hdSortBtn.visible = on;
	}

	function handleKeys():Void
	{
		if(FlxG.keys.justPressed.ESCAPE)
		{
			if(addMenuOpen)
				closeAddEventMenu();
			else if(menuOpen != null)
				closeMenu();
			else if(PsychUIInputText.focusOn != null)
				PsychUIInputText.focusOn = null;
			else
				close();
		}

		var typing:Bool = (PsychUIInputText.focusOn != null);
		if(!typing)
		{
			if(keyJustPressed(bind('togglePlayback'))) togglePlayback();
			if(keyJustPressed(bind('delete'))) deleteSelected();
			if(keyJustPressed(bind('copy'))) copySelected();
			if(keyJustPressed(bind('paste'))) pasteClipboard();
			if(keyJustPressed(bind('duplicate'))) duplicateSelected();
			if(keyJustPressed(bind('undo'))) doUndo();
			if(keyJustPressed(bind('redo'))) doRedo();
			if(keyJustPressed(bind('seekSelected')) && primarySel() >= 0)
			{
				previewCursorMs = events[primarySel()].time;
				seekMusic(previewCursorMs);
			}
			if(keyJustPressed(bind('addEvent'))) addEventAtPlayhead();
			if(keyJustPressed(bind('restart'))) { previewCursorMs = 0; seekMusic(0); }
			if(keyJustPressed(bind('toggleShader'))) toggleShader();
			if(keyJustPressed(bind('addBookmark'))) addBookmark();
			if(keyJustPressed(bind('help'))) helpOpen = true;
			if(keyJustPressed(bind('quantDown'))) cycleQuant(-1);
			if(keyJustPressed(bind('quantUp'))) cycleQuant(1);
			var maxScrollMs:Float = Math.max(0, songEndMs - (timelineRight - timelineX) / Math.max(0.005, pxPerMs));
			if(keyJustPressed(bind('panLeft')))
			{
				scrollMs = Math.max(0, scrollMs - 500);
				manualScrollTimer = 1.5;
			}
			if(keyJustPressed(bind('panRight')))
			{
				scrollMs = Math.min(maxScrollMs, scrollMs + 500);
				manualScrollTimer = 1.5;
			}
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.O) openUploadChartDialog();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.S) doSaveAs();
			if(FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.S) doSave();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.A) selectAllEvents();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.X) cutSelected();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.N) openUploadChartDialog();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Q) close();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R) resetCameraScroll();
			if(FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.G) resetCameraZoom();
			if(FlxG.keys.justPressed.COMMA) quickAddFocus('dad');
			if(FlxG.keys.justPressed.PERIOD) quickAddFocus('boyfriend');
			if(FlxG.keys.justPressed.HOME) { previewCursorMs = 0; seekMusic(0); }
			if(FlxG.keys.justPressed.BACKSPACE) deleteSelected();
			if(FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.A) openAddEventMenu(previewCursorMs, false);
		}
	}

	function quickAddFocus(target:String):Void
	{
		var t:Float = snapTime(previewCursorMs);
		addEventAt(t, 'Focus Camera', true, CameraEditorData.layerOf('Focus Camera'));
		var i:Int = primarySel();
		if(i >= 0 && i < events.length)
		{
			events[i].v1 = target;
			events[i].v2 = '';
			syncData();
			rebuildEventSprites();
			refreshPanel();
		}
		showStatus('已添加聚焦镜头 → ' + target);
	}

	function movePanelA():Void
	{
		if(panelBg == null) return;
		var px:Float = panelAX + 12;
		var lw:Int = rightW - 24;
		panelBg.x = panelAX;
		panelBg.y = panelAY;
		panelTitle.x = panelAX + 12;
		panelTitle.y = panelAY + 8;
		if(panelAHideBtn != null)
		{
			panelAHideBtn.x = panelAX + rightW - 76;
			panelAHideBtn.y = panelAY + 5;
		}

		var r0:Float = panelAY + 150;
		var r1:Float = panelAY + 198;
		var r2:Float = panelAY + 246;

		panelALabels[0].x = px; panelALabels[0].y = panelAY + 40;
		typeDropdown.x = px; typeDropdown.y = panelAY + 58;
		panelALabels[1].x = px; panelALabels[1].y = panelAY + 84;
		timeInput.x = px; timeInput.y = panelAY + 102;
		panelALabels[2].x = px; panelALabels[2].y = r0;
		panelALabels[3].x = px; panelALabels[3].y = r1;
		v1Input.x = px; v1Input.y = r0 + 16;
		v2Input.x = px; v2Input.y = r1 + 16;

		var clx:Float = px + 96;
		var clw:Int = lw - 100;
		var halfClw:Int = Std.int((clw - 8) / 2);
		var rows:Array<Float> = [r0, r1, r2];
		for(i in 0...pLb.length)
		{
			if(i >= 3) break;
			pLb[i].x = px;
			pLb[i].y = rows[i] - 16;
			pLb[i].width = 92;
		}
		fcTarget.x = clx; fcTarget.y = r0;
		fcX.x = clx; fcX.y = r1;
		fcY.x = clx + halfClw + 8; fcY.y = r1;
		fcDur.x = clx; fcDur.y = r2;
		zcZoom.x = clx; zcZoom.y = r0;
		zcDur.x = clx; zcDur.y = r1;
		zcMode.x = clx; zcMode.y = r2;
		paTarget.x = clx; paTarget.y = r0;
		paAnim.x = clx; paAnim.y = r1;
		azA.x = clx; azA.y = r0;
		azB.x = clx; azB.y = r1;
		fpX.x = clx; fpX.y = r0;
		fpY.x = clx; fpY.y = r1;
		fpDur.x = clx; fpDur.y = r2;
		anAngle.x = clx; anAngle.y = r0;
		anDur.x = clx; anDur.y = r1;

		var easeTop:Float = panelAY + 274;
		var gy:Float = easeTop + 20;
		var ddX:Float = px + EASE_GRAPH_W + EASE_STRIP_W + 16;
		if(easeTitle != null) { easeTitle.x = px; easeTitle.y = easeTop; }
		if(easeGraphFrame != null) { easeGraphFrame.x = px; easeGraphFrame.y = gy; }
		if(easeCurveBg != null) { easeCurveBg.x = px + 1; easeCurveBg.y = gy + 1; }
		if(easeDotFrame != null) { easeDotFrame.x = px + EASE_GRAPH_W + 6; easeDotFrame.y = gy; }
		if(easeDotStrip != null) { easeDotStrip.x = px + EASE_GRAPH_W + 7; easeDotStrip.y = gy + 1; }
		curveEditorX = ddX;
		curveEditorY = gy + 26;
		curveEditorW = lw - (EASE_GRAPH_W + EASE_STRIP_W + 16);
		curveEditorH = 74;
		if(curveEditorBg != null) { curveEditorBg.x = curveEditorX; curveEditorBg.y = curveEditorY; }
		if(easeBase != null) { easeBase.x = ddX; easeBase.y = gy + 20; }
		if(easeDir != null) { easeDir.x = ddX; easeDir.y = gy + 50; }
		if(curveEditorBg != null && curveEditorBg.visible) layoutCurveEditor();

		var opsY:Float = panelAY + panelH_A - 122;
		var halfWO:Int = Std.int((lw - 10) / 2);
		if(addBtn != null) { addBtn.x = px; addBtn.y = opsY; }
		if(dupBtn != null) { dupBtn.x = px; dupBtn.y = opsY + 30; }
		if(delBtn != null) { delBtn.x = px + halfWO + 10; delBtn.y = opsY + 30; }
		if(playBtn != null) { playBtn.x = px; playBtn.y = opsY + 60; }
		if(pasteBtn != null) { pasteBtn.x = px + halfWO + 10; pasteBtn.y = opsY + 60; }
		if(shaderCheckBox != null) { shaderCheckBox.x = px; shaderCheckBox.y = opsY + 92; }
		if(strumCheckBox != null) { strumCheckBox.x = px; strumCheckBox.y = opsY + 92; }
		if(autoScrollBox != null) { autoScrollBox.x = px + halfWO + 10; autoScrollBox.y = opsY + 92; }

		refreshEaseCurveUI();
		layoutPanelInfo();
	}

	function layoutPanelInfo():Void
	{
		if(panelInfo == null) return;
		var px:Float = panelAX + 12;
		var lw:Int = rightW - 24;
		var g:Int = EASE_GRAPH_W + EASE_STRIP_W + 16;
		if(easeVisible && panelH_A >= 540)
		{
			panelInfo.x = px + g;
			panelInfo.y = panelAY + 274 + 20 + 76;
			panelInfo.width = lw - g;
		}
		else
		{
			panelInfo.x = px;
			panelInfo.y = panelAY + 274;
			panelInfo.width = lw;
		}
	}

	function movePanelB():Void
	{
		if(panelBgB != null) panelBgB.visible = false;
		if(panelTitleB != null) panelTitleB.visible = false;
	}

	function handleMouse():Void
	{
		var mx:Float = FlxG.mouse.gameX;
		var my:Float = FlxG.mouse.gameY;

		if(FlxG.mouse.pressed && (draggingIndex >= 0 || dragResizeMode != 0 || boxSelecting || boxPending)) applyEdgeAutoScroll(mx);

		if(addMenuOpen)
		{
			if(FlxG.mouse.justPressed)
			{
				handleAddEventMenuClick(mx, my);
				return;
			}
			if(FlxG.mouse.justPressedRight)
			{
				closeAddEventMenu();
				return;
			}
		}

		if(FlxG.mouse.justPressed && handleMenuClick()) return;

		if(FlxG.mouse.justPressed && my >= timelineTop && my < timelineTop + toolbarH)
		{
			if(playBtnSprite != null && mx >= playBtnSprite.x - 4 && mx <= playBtnSprite.x + playBtnSprite.width + 4)
			{
				togglePlayback();
				return;
			}
			if(snapBtnSprite != null && mx >= snapBtnSprite.x - 4 && mx <= snapBtnSprite.x + snapBtnSprite.width + 4)
			{
				snapEnabled = !snapEnabled;
				snapIconState = -1;
				refreshSnapIcon();
				return;
			}
		}
		if(FlxG.mouse.justPressed && my >= timelineTop + toolbarH && my < timelineTop + toolbarH + scrollbarH && mx > timelineX && mx < FlxG.width - 16)
		{
			draggingScrollbar = true;
		}
		if(draggingScrollbar)
		{
			var trackW:Float = FlxG.width - timelineX - 20;
			if(trackW > 0)
			{
				var frac:Float = (mx - timelineX) / trackW;
				scrollMs = Math.max(0, frac * Math.max(1, songEndMs));
				if(FlxG.mouse.released) draggingScrollbar = false;
			}
			return;
		}

		var inTitleA:Bool = panelBg != null && mx >= panelBg.x && mx <= panelBg.x + rightW && my >= panelBg.y && my <= panelBg.y + 28;
		var inTitleB:Bool = false;
		if(draggingPanelA || inTitleA)
		{
			if(FlxG.mouse.justPressed) { draggingPanelA = true; panelDragOffX = mx - panelAX; panelDragOffY = my - panelAY; }
			if(draggingPanelA)
			{
				panelAX = Math.max(4, Math.min(FlxG.width - rightW - 4, mx - panelDragOffX));
				panelAY = Math.max(topH + 4, Math.min(FlxG.height - panelH_A - 4, my - panelDragOffY));
				movePanelA();
				if(FlxG.mouse.released) draggingPanelA = false;
				return;
			}
		}
		if(draggingPanelB || inTitleB)
		{
			if(FlxG.mouse.justPressed) { draggingPanelB = true; panelDragOffX = mx - panelBX; panelDragOffY = my - panelBY; }
			if(draggingPanelB)
			{
				panelBX = Math.max(4, Math.min(FlxG.width - rightW - 4, mx - panelDragOffX));
				panelBY = Math.max(topH + 4, Math.min(FlxG.height - panelH_B - 4, my - panelDragOffY));
				movePanelB();
				if(FlxG.mouse.released) draggingPanelB = false;
				return;
			}
		}
		if(draggingPanelA || draggingPanelB) return;
		var inTimeline:Bool = mx >= timelineX && mx <= timelineRight && my >= tlTop + rulerH && my <= FlxG.height;
		var inRuler:Bool = mx >= timelineX && mx <= timelineRight && my >= timelineTop && my < tlTop + rulerH;
		var splitterY:Float = timelineTop - 4;

		if(draggingSplitter || (splitterBar != null && mx >= timelineX && mx <= timelineRight && Math.abs(my - splitterY) < 12))
		{
			if(splitterBar != null) splitterBar.color = 0xFF6A6A6A;
			if(FlxG.mouse.justPressed) draggingSplitter = true;
			if(draggingSplitter)
			{
				timelineAreaH = Std.int(Math.max(140, Math.min(FlxG.height - topH - 150, FlxG.height - my)));
				applyTimelineLayout();
				if(FlxG.mouse.released)
				{
					draggingSplitter = false;
					if(splitterBar != null) splitterBar.color = 0xFF3A3A3A;
				}
				return;
			}
		}
		else if(splitterBar != null) splitterBar.color = 0xFF3A3A3A;

		if(FlxG.mouse.justPressed && mx < layerLabelW && my >= tlTop + rulerH && my <= FlxG.height)
		{
			var li:Int = Std.int((my - (tlTop + rulerH)) / layerH);
			if(li >= 0 && li < CameraEditorData.layerCount())
			{
				if(mx >= layerLabelW - 26)
				{
					layerVisible[li] = !layerVisible[li];
					refreshLayerVisibility();
					return;
				}
				if(li != selectedLayer)
				{
					selectedLayer = li;
					rebuildTimelineLayers();
					refreshRulerPositions();
				}
				var nowL:Float = haxe.Timer.stamp();
				if(nowL - lastLayerClickTime < 0.5 && lastLayerClickIdx == li)
				{
					lastLayerClickIdx = -1;
					openRenameLayer(li);
					return;
				}
				lastLayerClickTime = nowL;
				lastLayerClickIdx = li;
				return;
			}
		}
		if(FlxG.mouse.justPressedRight && mx < layerLabelW && my >= tlTop + rulerH && my <= FlxG.height)
		{
			var liR:Int = Std.int((my - (tlTop + rulerH)) / layerH);
			if(liR >= 0 && liR < CameraEditorData.layerCount())
			{
				if(liR != selectedLayer)
				{
					selectedLayer = liR;
					rebuildTimelineLayers();
					refreshRulerPositions();
				}
				openDeleteLayer(liR);
				return;
			}
		}

		for(i in 0...bookmarkSprites.length)
		{
			var bs:FlxSprite = bookmarkSprites[i];
			if(!bs.visible) continue;
			if(FlxG.mouse.justPressed && Math.abs(mx - (bs.x + 4.5)) < 9 && Math.abs(my - (bs.y + 4.5)) < 9)
			{
				seekMusic(bookmarks[i]);
				return;
			}
			if(FlxG.mouse.justPressedRight && Math.abs(mx - (bs.x + 4.5)) < 9 && Math.abs(my - (bs.y + 4.5)) < 9)
			{
				bookmarks.splice(i, 1);
				rebuildBookmarks();
				showStatus('已删除书签');
				return;
			}
		}

		if(FlxG.mouse.wheel != 0 && (inTimeline || inRuler))
		{
			var f:Float = (FlxG.mouse.wheel > 0) ? 1.1 : (1 / 1.1);
			if(FlxG.keys.pressed.SHIFT)
			{
				adjustViewfinderZoom(f);
				return;
			}
			if(FlxG.keys.pressed.CONTROL)
			{
				scrollMs += ((FlxG.mouse.wheel > 0) ? -1 : 1) * (220 / Math.max(0.005, pxPerMs)) * pxPerMs;
				if(scrollMs < 0) scrollMs = 0;
				if(scrollMs > songEndMs) scrollMs = Math.max(0, songEndMs - 1000);
				manualScrollTimer = 1.5;
				return;
			}
			var factor:Float = 1.15;
			var beforeMs:Float = xToMs(mx);
			pxPerMs *= (FlxG.mouse.wheel > 0) ? factor : (1.0 / factor);
			pxPerMs = Math.max(0.005, Math.min(0.8, pxPerMs));
			scrollMs = beforeMs - (mx - timelineX) / pxPerMs;
			if(scrollMs < 0) scrollMs = 0;
			manualScrollTimer = 1.5;
			return;
		}
		handlePreviewWheel();
		handlePreviewPan();
		handleCurveDrag();

		if(inRuler && FlxG.mouse.justPressed)
		{
			draggingIndex = -2;
			panLastX = mx;
			rulerPressX = mx;
			rulerMoved = false;
		}
		if(draggingIndex == -2)
		{
			if(FlxG.mouse.pressed)
			{
			if(Math.abs(FlxG.mouse.gameX - rulerPressX) > 4) rulerMoved = true;
			if(rulerMoved)
			{
				scrollMs -= (FlxG.mouse.gameX - panLastX) / pxPerMs;
				manualScrollTimer = 1.5;
			}
			panLastX = FlxG.mouse.gameX;
			}
			if(FlxG.mouse.released)
			{
				if(!rulerMoved)
				{
					var t:Float = Math.max(0, Math.min(Math.max(1, songEndMs), xToMs(rulerPressX)));
					previewCursorMs = t;
					seekMusic(t);
				}
				draggingIndex = -1;
			}
		}

		if(dragResizeMode != 0)
		{
			if(draggingIndex >= 0 && draggingIndex < events.length)
			{
				var rev:EdEvent = events[draggingIndex];
				if(dragResizeMode == 2)
				{
					var durMs:Float = Math.max(20, xToMs(mx) - rev.time);
					dragDeltaMs = 0;
					dragDeltaDurMs = durMs - eventDurMs(rev);
				}
				else
				{
					var t0:Float = Math.max(0, snapTime(xToMs(mx)));
					dragDeltaMs = Math.min(0, t0 - rev.time);
					dragDeltaDurMs = -dragDeltaMs;
				}
			}
			if(FlxG.mouse.released)
			{
				if(draggingIndex >= 0 && draggingIndex < events.length)
				{
					var rev2:EdEvent = events[draggingIndex];
					if(dragResizeMode == 2) setEventDur(rev2, eventDurMs(rev2) + dragDeltaDurMs);
					else
					{
						var endMs:Float = rev2.time + eventDurMs(rev2);
						rev2.time = Math.max(0, rev2.time + dragDeltaMs);
						setEventDur(rev2, endMs - rev2.time);
					}
				}
				if(dragStartSnap.length > 0 && (Math.abs(dragDeltaMs) > 0.5 || Math.abs(dragDeltaDurMs) > 0.5))
				{
					pushUndoSnap(dragStartSnap, '调整事件时长');
				}
				dragResizeMode = 0;
				draggingIndex = -1;
				dragDeltaMs = 0;
				dragDeltaDurMs = 0;
				syncData();
				refreshPanel();
			}
			return;
		}

		if(draggingIndex >= 0 && draggingIndex < events.length)
		{
			var ev:EdEvent = events[draggingIndex];
			var newMs:Float = mouseMsToSnapped(mx) - dragMouseMsOffset;
			dragDeltaMs = Math.max(0, newMs) - ev.time;
			dragDeltaDurMs = 0;
			var rows:Int = CameraEditorData.layerCount();
			var row:Int = Std.int((my - (tlTop + rulerH)) / Math.max(1, layerH));
			if(row < 0) row = 0;
			if(row > rows - 1) row = rows - 1;
			dragTargetLayer = row;
			if(FlxG.mouse.released)
			{
				var targets:Array<Int> = (selectedIndexes.length > 0) ? selectedIndexes : [draggingIndex];
				var movedTime:Bool = Math.abs(dragDeltaMs) > 0.5;
				var movedLayer:Bool = (dragTargetLayer >= 0 && dragTargetLayer != ev.layer);
				if(movedTime || movedLayer)
				{
					for(i in targets)
					{
						if(i < 0 || i >= events.length) continue;
						if(movedTime) events[i].time = Math.max(0, events[i].time + dragDeltaMs);
						if(movedLayer) events[i].layer = dragTargetLayer;
					}
					pushUndoSnap(dragStartSnap, movedTime ? '移动事件' : '更换图层');
				}
				dragDeltaMs = 0;
				dragDeltaDurMs = 0;
				dragTargetLayer = -1;
				syncData();
				draggingIndex = -1;
				refreshPanel();
				if(movedLayer) showStatus('已将 ${targets.length} 个事件移到图层 ' + CameraEditorData.layerName(ev.layer));
			}
			return;
		}

		if(boxSelecting)
		{
			var bx:Float = Math.min(boxStartX, mx);
			var by:Float = Math.min(boxStartY, my);
			var bw:Float = Math.abs(mx - boxStartX);
			var bh:Float = Math.abs(my - boxStartY);
			boxRect.x = bx;
			boxRect.y = by;
			boxRect.makeGraphic(Std.int(Math.max(1, bw)), Std.int(Math.max(1, bh)), 0xFF5BA3FF);
			boxRect.alpha = 0.25;
			boxRect.visible = true;
			if(FlxG.mouse.released)
			{
				boxSelecting = false;
				boxPending = false;
				boxRect.visible = false;
				var hitList:Array<Int> = [];
				for(i in 0...events.length)
				{
					if(i >= eventSprites.length) break;
					var spr:FlxSprite = eventSprites[i];
					if(!spr.visible) continue;
					var w:Float = eventDisplayWidth(events[i]);
					if(spr.x + w >= bx && spr.x <= bx + bw && spr.y + layerH >= by && spr.y <= by + bh) hitList.push(i);
				}
				if(FlxG.keys.pressed.CONTROL)
				{
					for(k in hitList) if(!selectedIndexes.contains(k)) selectedIndexes.push(k);
				}
				else selectedIndexes = hitList;
				selectedIndex = (selectedIndexes.length > 0) ? selectedIndexes[selectedIndexes.length - 1] : -1;
				refreshPanel();
				rebuildEventSprites();
				showStatus('已选中 ' + selectedIndexes.length + ' 个事件');
			}
			return;
		}
		if(boxPending)
		{
			if(FlxG.mouse.pressed && (Math.abs(mx - boxStartX) > 6 || Math.abs(my - boxStartY) > 6))
			{
				boxSelecting = true;
				return;
			}
			if(FlxG.mouse.released)
			{
				boxPending = false;
				previewCursorMs = Math.max(0, Math.min(Math.max(1, songEndMs), xToMs(boxStartX)));
				seekMusic(previewCursorMs);
			}
		}

		if(FlxG.mouse.justPressed)
		{
			var now:Float = haxe.Timer.stamp();
			if(inTimeline && now - lastClickTime < 0.5 && Math.abs(mx - lastClickPos) < 16)
			{
				lastClickTime = 0;
				if(FlxG.keys.pressed.CONTROL)
				{
					var li2:Int = Std.int((my - (tlTop + rulerH)) / Math.max(1, layerH));
					var tname:String = '';
					var lyr:Int = -1;
					if(li2 >= 0 && li2 < CameraEditorData.layerCount())
					{
						lyr = li2;
						tname = CameraEditorData.eventNameOfLayer(li2);
					}
					if(tname.length < 1) tname = currentTypeName();
					addEventAt(mouseMsToSnapped(mx), tname, true, lyr);
				}
				else
				{
					previewCursorMs = Math.max(0, Math.min(Math.max(1, songEndMs), xToMs(mx)));
					seekMusic(previewCursorMs);
					showStatus('已跳转到 ' + Std.int(previewCursorMs) + ' ms');
				}
				return;
			}
			lastClickTime = now;
			lastClickPos = mx;

			var hit:Int = -1;
			for(i in 0...eventSprites.length)
			{
				if(i >= events.length) break;
				var spr:FlxSprite = eventSprites[i];
				if(!spr.visible) continue;
				var w:Float = eventDisplayWidth(events[i]);
				var barH2:Float = Math.max(6, layerH - 6);
				if(mx >= spr.x - 3 && mx <= spr.x + w + 3 && my >= spr.y - 2 && my <= spr.y + barH2 + 2)
					hit = i;
			}

			if(hit >= 0)
			{
				if(FlxG.keys.pressed.CONTROL)
				{

					if(selectedIndexes.contains(hit)) selectedIndexes.remove(hit);
					else selectedIndexes.push(hit);
				}
				else
					selectedIndexes = [hit];

				if(selectedIndexes.length > 0) selectedIndex = selectedIndexes[selectedIndexes.length - 1];
				else selectedIndex = -1;
				draggingIndex = hit;
				dragMouseMsOffset = mouseMsToSnapped(mx) - events[hit].time;
				dragStartSnap = snapshotEvents();
				dragStartTime = events[hit].time;

				if(eventResizable(events[hit]))
				{
					var w2:Float = eventDisplayWidth(events[hit]);
					if(mx >= eventSprites[hit].x - 5 && mx <= eventSprites[hit].x + 5)
						dragResizeMode = 1;
					else if(mx >= eventSprites[hit].x + w2 - 5 && mx <= eventSprites[hit].x + w2 + 5)
						dragResizeMode = 2;
				}

				refreshPanel();
				rebuildEventSprites();
			}
			else if(inTimeline)
			{
				if(selectedIndexes.length > 0)
				{
					clearSelection();
					refreshPanel();
					rebuildEventSprites();
				}
				boxStartX = mx;
				boxStartY = my;
				boxPending = true;
			}
		}

		if(FlxG.mouse.justPressedRight)
		{
			var hitR:Int = -1;
			for(i in 0...eventSprites.length)
			{
				if(i >= events.length) break;
				var spr:FlxSprite = eventSprites[i];
				if(!spr.visible) continue;
				var w:Float = eventDisplayWidth(events[i]);
				if(mx >= spr.x && mx <= spr.x + w && my >= spr.y && my <= spr.y + Math.max(6, layerH - 6)) hitR = i;
			}
			if(hitR >= 0)
			{
				if(!selectedIndexes.contains(hitR))
				{
					selectedIndexes = [hitR];
					selectedIndex = hitR;
				}
				deleteSelected();
			}
			else if(my >= tlTop + rulerH && my <= timelineTop + timelineAreaH && mx > timelineX && mx < timelineRight)
				openAddEventMenu(snapTime(xToMs(mx)));
		}
	}

	function syncData():Void
	{
		CameraEditorData.saveCamEvents(events);
		CameraEditorData.applyToSong(events);
		triggeredFlags = [for(_ in events) false];
		dirty = true;
		if(saveMarkText != null) saveMarkText.visible = true;
		refreshWindowTitle();
	}

	function snapshotEvents():Array<EdEvent>
	{
		return [for(ev in events) {time: ev.time, name: ev.name, v1: ev.v1, v2: ev.v2, layer: ev.layer}];
	}

	function pushUndo(name:String):Void
	{
		pushUndoSnap(snapshotEvents(), name);
	}

	function pushUndoSnap(snap:Array<EdEvent>, name:String):Void
	{
		undoStack.push(snap);
		undoNames.push(name);
		if(undoStack.length > MAX_UNDO)
		{
			undoStack.shift();
			undoNames.shift();
		}
		redoStack = [];
		redoNames = [];
	}

	function doUndo():Void
	{
		if(undoStack.length < 1) return;
		var nm:String = (undoNames.length > 0) ? undoNames.pop() : '';
		redoStack.push(snapshotEvents());
		redoNames.push(nm);
		events = undoStack.pop();
		clearSelection();
		sfx('undo');
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus(nm.length > 0 ? '已撤销：$nm' : '已撤销');
	}

	function doRedo():Void
	{
		if(redoStack.length < 1) return;
		var nm:String = (redoNames.length > 0) ? redoNames.pop() : '';
		undoStack.push(snapshotEvents());
		undoNames.push(nm);
		events = redoStack.pop();
		clearSelection();
		sfx('undo');
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus(nm.length > 0 ? '已重做：$nm' : '已重做');
	}

	function toggleShader():Void
	{
		shaderCheckBox.checked = !shaderCheckBox.checked;
		applyShaderSuspend(!shaderCheckBox.checked);
	}

	function applyShaderSuspend(suspend:Bool):Void
	{
		if(PlayState.instance == null) return;
		for(cam in [PlayState.instance.camGame, PlayState.instance.camHUD, PlayState.instance.camOther, PlayState.instance.camOverlay])
		{
			if(cam == null) continue;
			var st:backend.shadersystem.CameraShaderStack = backend.shadersystem.CameraShaderStack.get(cam);
			if(st == null) continue;
			if(suspend && !st.suspended) st.suspend();
			else if(!suspend && st.suspended) st.resume();
		}
	}

	function currentTypeName():String
	{
		if(typeDropdown == null) return 'Zoom Camera';
		var t:String = typeDropdown.text;
		if(t == null || t.length < 1) return 'Zoom Camera';
		return t;
	}

	function addEventAtPlayhead():Void
	{
		addEventAt(snapTime(previewCursorMs), currentTypeName(), false);
	}

	function addEventAt(time:Float, name:String, select:Bool, layerOverride:Int = -1):Void
	{
		var def:{v1:String, v2:String} = CameraEditorData.defaultValues(name);
		var lyr:Int = (layerOverride >= 0) ? CameraEditorData.layerIndex(layerOverride) : CameraEditorData.layerOf(name);
		var ev:EdEvent = {time: time, name: name, v1: def.v1, v2: def.v2, layer: lyr};
		pushUndo('添加 ' + name);
		sfx('noteLay');
		events.push(ev);
		CameraEditorData.sortByTime(events);
		syncData();

		if(select)
		{
			for(i in 0...events.length)
			{
				if(events[i] == ev)
				{
					selectedIndexes = [i];
					selectedIndex = i;
					break;
				}
			}
		}
		rebuildEventSprites();
		refreshPanel();
	}

	function deleteSelected():Void
	{
		if(selectedIndexes.length < 1) return;
		pushUndo('删除 ' + selectedIndexes.length + ' 个事件');
		sfx('noteErase');
		var list:Array<Int> = selectedIndexes.copy();
		list.sort(function(a:Int, b:Int) return b - a);
		for(i in list)
			if(i >= 0 && i < events.length) events.splice(i, 1);
		clearSelection();
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus('已删除 ${list.length} 个事件');
	}

	function copySelected():Void
	{
		if(selectedIndexes.length < 1) return;
		clipboardEvents = [];
		for(i in selectedIndexes)
		{
			if(i < 0 || i >= events.length) continue;
			var e:EdEvent = events[i];
			clipboardEvents.push({time: e.time, name: e.name, v1: e.v1, v2: e.v2, layer: e.layer});
		}
		clipboardEvents.sort(function(a:EdEvent, b:EdEvent) return Std.int(a.time - b.time));
		showStatus('已复制 ${clipboardEvents.length} 个事件 (Ctrl+V 粘贴)');
	}

	function cutSelected():Void
	{
		if(selectedIndexes.length < 1)
		{
			showStatus('没有选中事件');
			return;
		}
		var n:Int = selectedIndexes.length;
		copySelected();
		deleteSelected();
		showStatus('已剪切 $n 个事件 (Ctrl+V 粘贴)');
	}

	function pasteClipboard():Void
	{
		if(clipboardEvents.length < 1)
		{
			showStatus('剪贴板为空，先用 Ctrl+C 复制事件');
			return;
		}
		var base:Float = previewCursorMs;
		var minT:Float = clipboardEvents[0].time;
		var copies:Array<EdEvent> = [];
		for(c in clipboardEvents)
			copies.push({time: snapTime(base + (c.time - minT)), name: c.name, v1: c.v1, v2: c.v2, layer: c.layer});
		pushUndo('粘贴 ' + copies.length + ' 个事件');
		events = events.concat(copies);
		CameraEditorData.sortByTime(events);
		selectedIndexes = [];
		for(c in copies)
			for(i in 0...events.length)
				if(events[i] == c) { selectedIndexes.push(i); break; }
		selectedIndex = (selectedIndexes.length > 0) ? selectedIndexes[selectedIndexes.length - 1] : -1;
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus('已粘贴 ${copies.length} 个事件到播放头');
	}

	function duplicateSelected():Void
	{
		if(selectedIndexes.length < 1) return;
		var srcIdx:Int = primarySel();
		if(srcIdx < 0 || srcIdx >= events.length) return;
		var src:EdEvent = events[srcIdx];
		var stepMs:Float = Conductor.getBPMFromSeconds(src.time).stepCrochet;
		var copies:Array<EdEvent> = [];
		for(i in selectedIndexes)
		{
			if(i < 0 || i >= events.length) continue;
			var e:EdEvent = events[i];
			copies.push({time: snapTime(e.time + stepMs * 4), name: e.name, v1: e.v1, v2: e.v2, layer: e.layer});
		}
		if(copies.length < 1) return;
		pushUndo('快速复制 ' + copies.length + ' 个事件');
		events = events.concat(copies);
		CameraEditorData.sortByTime(events);
		selectedIndexes = [];
		for(c in copies)
			for(i in 0...events.length)
				if(events[i] == c) { selectedIndexes.push(i); break; }
		selectedIndex = (selectedIndexes.length > 0) ? selectedIndexes[selectedIndexes.length - 1] : -1;
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus('已复制 ${copies.length} 个事件');
	}

	function onTypeChanged():Void
	{
		var idx:Int = primarySel();
		if(panelUpdating || idx < 0 || idx >= events.length) return;
		var name:String = currentTypeName();
		var def:{v1:String, v2:String} = CameraEditorData.defaultValues(name);
		var ev:EdEvent = events[idx];
		ev.name = name;
		if(ev.v1.length < 1 && def.v1.length > 0) ev.v1 = def.v1;
		if(ev.v2.length < 1 && def.v2.length > 0) ev.v2 = def.v2;
		pushUndo('修改事件类型');
		syncData();
		rebuildEventSprites();
		refreshPanel();
	}

	function onTimeChanged(cur:String):Void
	{
		var idx:Int = primarySel();
		if(panelUpdating || idx < 0 || idx >= events.length) return;
		var t:Float = Std.parseFloat(cur);
		if(Math.isNaN(t) || t < 0) return;
		events[idx].time = t;
		syncData();
	}

	function onV1Changed(cur:String):Void
	{
		var idx:Int = primarySel();
		if(panelUpdating || idx < 0 || idx >= events.length) return;
		events[idx].v1 = cur;
		syncData();
	}

	function onV2Changed(cur:String):Void
	{
		var idx:Int = primarySel();
		if(panelUpdating || idx < 0 || idx >= events.length) return;
		events[idx].v2 = cur;
		syncData();
	}

	function refreshPanel():Void
	{
		panelUpdating = true;
		var idx:Int = primarySel();
		var has:Bool = (idx >= 0 && idx < events.length);
		if(idx != panelALastSel)
		{
			panelALastSel = idx;
			panelAUserHidden = false;
		}
		var used:Bool = false;
		if(!panelAUserHidden) setPanelAVisible(has);
		if(has)
		{
			var ev:EdEvent = events[idx];
			typeDropdown.selectedLabel = ev.name;
			if(typeDropdown.text.length < 1 && ev.name.length > 0) typeDropdown.text = ev.name;
			timeInput.text = Std.string(Math.round(ev.time));
			panelInfo.text = CameraEditorData.eventHint(ev.name);
			panelTitle.text = (selectedIndexes.length > 1)
				? '事件属性 - 已选 ${selectedIndexes.length} 个'
				: '事件属性 - ${ev.name}';
			used = syncSpecControls(ev);
			if(!used)
			{
				v1Input.text = ev.v1;
				v2Input.text = ev.v2;
			}
		}
		else
		{
			typeDropdown.selectedIndex = -1;
			typeDropdown.text = '';
			timeInput.text = '';
			v1Input.text = '';
			v2Input.text = '';
			panelInfo.text = '在时间轴上点击事件进行编辑\n双击某一行的空白 = 在该行添加事件\nCtrl+点击 多选';
			panelTitle.text = '事件属性';
			hideSpecControls();
		}
		v1Input.visible = has && !used;
		v2Input.visible = has && !used;
		if(panelALabels.length > 3)
		{
			panelALabels[2].visible = has && !used;
			panelALabels[3].visible = has && !used;
		}
		panelInfo.setFormat(Paths.font(Language.pickFont(panelInfo.text)), fs(11), 0xFF9AC8F5);
		panelTitle.setFormat(Paths.font(Language.pickFont(panelTitle.text)), fs(16), FlxColor.WHITE);
		panelUpdating = false;
	}

	function safeFloat(s:String, def:Float):Float
	{
		if(s == null) return def;
		var v:Float = Std.parseFloat(s);
		if(Math.isNaN(v)) return def;
		return v;
	}

	function stepSec():Float
	{
		var c:Float = Conductor.stepCrochet / 1000;
		return (c > 0.001) ? c : 0.1;
	}

	function durToDisplay(sec:Float):Float
	{
		if(!durationSteps) return sec;
		return Math.max(1, Math.round(sec / stepSec()));
	}

	function durFromDisplay(v:Float):Float
	{
		if(!durationSteps) return v;
		return Math.max(1, Math.round(v)) * stepSec();
	}

	function durationLabel():String
	{
		return durationSteps ? '时长(步)' : '时长(秒)';
	}

	function setDurationUnit(steps:Bool):Void
	{
		durationSteps = steps;
		showStatus(steps ? '时长单位：步（1 步 = ${Math.round(stepSec() * 1000)}ms）' : '时长单位：秒');
		refreshPanel();
		rebuildEventSprites();
	}

	function hideSpecControls():Void
	{
		for(c in [fcTarget, fcX, fcY, fcDur, zcZoom, zcDur, zcMode, paTarget, paAnim, azA, azB, fpX, fpY, fpDur, anAngle, anDur])
			if(c != null) c.visible = false;
		for(lb in pLb) if(lb != null) lb.visible = false;
		setEaseSectionVisible(false);
		setCurveEditorVisible(false);
	}

	function onHidePanelA():Void
	{
		panelAUserHidden = true;
		setPanelAVisible(false);
	}

	function setPanelAVisible(v:Bool):Void
	{
		if(panelBg != null) panelBg.visible = v;
		if(panelTitle != null) panelTitle.visible = v;
		if(panelAHideBtn != null) panelAHideBtn.visible = v;
		for(l in panelALabels) if(l != null) l.visible = v;
		for(c in [typeDropdown, timeInput, v1Input, v2Input, panelInfo]) if(c != null) c.visible = v;
		if(v) return;
		hideSpecControls();
		if(curveEditorBg != null) curveEditorBg.visible = false;
		for(h in curveHandles) if(h != null) h.visible = false;
	}

	function setStepVal(st:PsychUINumericStepper, v:Float):Void
	{
		if(st == null) return;
		if(PsychUIInputText.focusOn == st) return;
		st.value = v;
	}

	function syncSpecControls(ev:EdEvent):Bool
	{
		hideSpecControls();
		switch(normName(ev.name))
		{
			case 'focuscamera':
				pLb[0].text = '对焦目标'; pLb[0].visible = true; fcTarget.visible = true;
				pLb[1].text = '偏移 X / Y'; pLb[1].visible = true; fcX.visible = true; fcY.visible = true;
				pLb[2].text = durationLabel(); pLb[2].visible = true; fcDur.visible = true;
				var tgt:String = (ev.v1 == null || ev.v1.length < 1) ? 'boyfriend' : ev.v1;
				if(tgt != 'boyfriend' && tgt != 'dad' && tgt != 'girlfriend') tgt = 'pos';
				fcTarget.selectedLabel = tgt;
				if(fcTarget.text == null || fcTarget.text.length < 1) fcTarget.text = tgt;
				var offs:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
				fcX.value = (offs.length > 0) ? safeFloat(offs[0], 0) : 0;
				fcY.value = (offs.length > 1) ? safeFloat(offs[1], 0) : 0;
				fcDur.value = durToDisplay((offs.length > 2) ? safeFloat(offs[2], 2) : 2);
				applyEaseToPanel(ev, true, 'CLASSIC');
				return true;
			case 'zoomcamera':
				pLb[0].text = '缩放'; pLb[0].visible = true; zcZoom.visible = true;
				pLb[1].text = durationLabel(); pLb[1].visible = true; zcDur.visible = true;
				pLb[2].text = '缩放模式'; pLb[2].visible = true; zcMode.visible = true;
				zcZoom.value = safeFloat(ev.v1, 1);
				var zp:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
				zcDur.value = durToDisplay((zp.length > 0) ? safeFloat(zp[0], 2) : 2);
				var zm:String = (zp.length > 2 && zp[2].length > 0) ? StringTools.trim(zp[2]) : 'direct';
				var zml:String = (zm == 'stage') ? 'Stage' : 'Absolute';
				zcMode.selectedLabel = zml;
				if(zcMode.text == null || zcMode.text.length < 1) zcMode.text = zml;
				applyEaseToPanel(ev, false, 'linear');
				return true;
			case 'playanimation':
				pLb[0].text = '角色'; pLb[0].visible = true; paTarget.visible = true;
				pLb[1].text = '动画名'; pLb[1].visible = true; paAnim.visible = true;
				var pchar:String = (ev.v2 == null || ev.v2.length < 1) ? 'boyfriend' : ev.v2;
				paTarget.selectedLabel = pchar;
				if(paTarget.text == null || paTarget.text.length < 1) paTarget.text = pchar;
				var pcur:String = (ev.v1 == null) ? '' : ev.v1;
				var pal:Array<String> = animListFor(pchar);
				if(pcur.length > 0 && !pal.contains(pcur)) pal.push(pcur);
				paAnim.list = pal;
				if(pcur.length > 0) paAnim.selectedLabel = pcur;
				else paAnim.selectedIndex = 0;
				if(paAnim.text == null || paAnim.text.length < 1) paAnim.text = pcur;
				return true;
			case 'addcamerazoom':
				pLb[0].text = '镜头加量'; pLb[0].visible = true; azA.visible = true;
				pLb[1].text = 'UI 加量'; pLb[1].visible = true; azB.visible = true;
				setStepVal(azA, safeFloat(ev.v1, 0.015));
				setStepVal(azB, safeFloat(ev.v2, 0.03));
				return true;
			case 'camerafollowpos':
				var fp:Array<String> = (ev.v2 == null || ev.v2.length < 1) ? [] : ev.v2.split(',');
				pLb[0].text = 'X'; pLb[0].visible = true; fpX.visible = true;
				pLb[1].text = 'Y'; pLb[1].visible = true; fpY.visible = true;
				pLb[2].text = durationLabel(); pLb[2].visible = true; fpDur.visible = true;
				fpX.value = safeFloat(ev.v1, 0);
				fpY.value = (fp.length > 0) ? safeFloat(fp[0], 0) : 0;
				fpDur.value = durToDisplay((fp.length > 1) ? safeFloat(fp[1], 0.5) : 0.5);
				applyEaseToPanel(ev, false, 'quadInOut');
				return true;
			case 'cameraangle':
				pLb[0].text = '角度(度)'; pLb[0].visible = true; anAngle.visible = true;
				pLb[1].text = durationLabel(); pLb[1].visible = true; anDur.visible = true;
				anAngle.value = safeFloat(ev.v1, 0);
				var ap:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
				anDur.value = durToDisplay((ap.length > 0) ? safeFloat(ap[0], 0.3) : 0.3);
				applyEaseToPanel(ev, false, 'quadOut');
				return true;
		}
		return false;
	}

	function onSpecChanged():Void
	{
		if(panelUpdating) return;
		var idx:Int = primarySel();
		if(idx < 0 || idx >= events.length) return;
		var ev:EdEvent = events[idx];
		switch(normName(ev.name))
		{
			case 'focuscamera':
				ev.v1 = fcTarget.text;
				ev.v2 = [Std.string(fcX.value), Std.string(fcY.value), Std.string(durFromDisplay(fcDur.value)), 'CLASSIC'].join(',');
				setEventEase(ev, easeTokenNow());
				refreshEaseCurveUI();
			case 'zoomcamera':
				ev.v1 = Std.string(zcZoom.value);
				var zmo:String = (zcMode.text == 'Stage') ? 'stage' : 'direct';
				ev.v2 = [Std.string(durFromDisplay(zcDur.value)), 'linear', zmo].join(',');
				setEventEase(ev, easeTokenNow());
				refreshEaseCurveUI();
			case 'playanimation':
				ev.v1 = paAnim.text;
				ev.v2 = paTarget.text;
				if(!animListFor(paTarget.text).contains(ev.v1)) refreshAnimList();
			case 'addcamerazoom':
				ev.v1 = Std.string(azA.value);
				ev.v2 = Std.string(azB.value);
			case 'camerafollowpos':
				ev.v1 = Std.string(fpX.value);
				ev.v2 = [Std.string(fpY.value), Std.string(durFromDisplay(fpDur.value))].join(',');
				setEventEase(ev, easeTokenNow());
				refreshEaseCurveUI();
			case 'cameraangle':
				ev.v1 = Std.string(anAngle.value);
				ev.v2 = [Std.string(durFromDisplay(anDur.value)), 'quadOut'].join(',');
				setEventEase(ev, easeTokenNow());
				refreshEaseCurveUI();
			default:
				return;
		}
		syncData();
		rebuildEventSprites();
		simulateCameraAt(previewCursorMs);
	}

	static final MAX_EVENT_SPRITES:Int = 400;

	function rebuildEventSprites():Void
	{

		while(eventSprites.length < events.length && eventSprites.length < MAX_EVENT_SPRITES)
		{
			var spr:FlxSprite = new FlxSprite().makeGraphic(10, 80, FlxColor.WHITE);
			spr.scrollFactor.set();
			add(spr);
			eventSprites.push(spr);

			var ic:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/camera-editor/event-icons/focus_event'));
			ic.scrollFactor.set();
			ic.origin.set(0, 0);
			add(ic);
			eventIconSprites.push(ic);

			var tr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/camera-editor/triangle'));
			tr.scrollFactor.set();
			tr.origin.set(0, 0);
			add(tr);
			eventTriSprites.push(tr);
		}
		while(eventSprites.length > events.length)
		{
			var spr:FlxSprite = eventSprites.pop();
			remove(spr);
			spr.destroy();
			var ic:FlxSprite = eventIconSprites.pop();
			if(ic != null) { remove(ic); ic.destroy(); }
			var tr:FlxSprite = eventTriSprites.pop();
			if(tr != null) { remove(tr); tr.destroy(); }
		}

		while(ghostSprites.length < events.length && ghostSprites.length < MAX_EVENT_SPRITES)
		{
			var gh:FlxSprite = new FlxSprite().makeGraphic(10, 80, 0xFF79E0FF);
			gh.scrollFactor.set();
			gh.alpha = 0.45;
			gh.visible = false;
			add(gh);
			ghostSprites.push(gh);
		}
		while(ghostSprites.length > events.length)
		{
			var gh:FlxSprite = ghostSprites.pop();
			if(gh != null) { remove(gh); gh.destroy(); }
		}
		for(gh in ghostSprites) add(gh);

		triggeredFlags = [for(_ in events) false];
		updateEventSpritePositions();
	}

	function eventIconKey(ev:EdEvent):String
	{
		switch(ev.name)
		{
			case 'Focus Camera': return 'ui/camera-editor/event-icons/focus_event';
			case 'Zoom Camera': return 'ui/camera-editor/event-icons/zoom_event';
			case 'Play Animation': return 'ui/camera-editor/event-icons/playanim_event';
		}
		return null;
	}

	function eventInstant(ev:EdEvent):Bool
	{
		switch(normName(ev.name))
		{
			case 'focuscamera' | 'zoomcamera' | 'cameraangle' | 'camerafollowpos':
				var parts:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
				var di:Int = durIndex(ev.name);
				if(parts.length > di)
				{
					var d:Float = Std.parseFloat(parts[di]);
					if(!Math.isNaN(d) && d <= 0) return true;
				}
				return CustomEase.isSnapToken(eventEaseToken(ev));
		}
		return true;
	}

	function eventDurMs(ev:EdEvent):Float
	{
		switch(normName(ev.name))
		{
			case 'focuscamera' | 'zoomcamera' | 'cameraangle' | 'camerafollowpos':
				if(CustomEase.isInstantToken(eventEaseToken(ev))) return 0;
				var parts:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
				var di:Int = durIndex(ev.name);
				if(parts.length > di)
				{
					var d:Float = Std.parseFloat(parts[di]);
					if(!Math.isNaN(d) && d > 0) return d * 1000;
				}
				return 250;
		}
		return 100;
	}

	function eventResizable(ev:EdEvent):Bool
	{
		switch(normName(ev.name))
		{
			case 'focuscamera' | 'zoomcamera' | 'cameraangle' | 'camerafollowpos':
				return !eventInstant(ev);
		}
		return false;
	}

	function eventDisplayWidth(ev:EdEvent):Float
	{
		return Math.max(16, eventDurMs(ev) * pxPerMs);
	}

	function setEventDur(ev:EdEvent, durMs:Float):Void
	{
		if(!eventResizable(ev)) return;
		if(durMs < 20) durMs = 20;
		if(durMs > 30000) durMs = 30000;
		if(durationSteps)
		{
			var st:Float = stepSec();
			durMs = Math.max(1, Math.round(durMs / 1000 / st)) * st * 1000;
		}
		var parts:Array<String> = (ev.v2 == null || ev.v2.length < 1) ? [] : ev.v2.split(',');
		var di:Int = durIndex(ev.name);
		var ei:Int = easeIndex(ev.name);
		while(parts.length <= ei) parts.push('');
		parts[di] = Std.string(Math.round(durMs) / 1000);
		ev.v2 = parts.join(',');
	}

	function updateEventSpritePositions():Void
	{

		var upcoming:Int = -1;
		if(isPlaying)
		{
			for(i in 0...events.length)
			{
				if(!triggeredFlags[i])
				{
					upcoming = i;
					break;
				}
			}
		}

		for(i in 0...eventSprites.length)
		{
			var spr:FlxSprite = eventSprites[i];
			if(i >= events.length)
			{
				spr.visible = false;
				continue;
			}
			var ev:EdEvent = events[i];
			var layerVis:Bool = (ev.layer < layerVisible.length) ? layerVisible[ev.layer] : true;
			var w:Float = eventDisplayWidth(ev);
			spr.origin.set(0, 0);
			spr.scale.x = Math.max(1, w) / 10;
			spr.scale.y = Math.max(1, layerH - 6) / 80;
			var drawLayer:Int = ev.layer;
			if(dragTargetLayer >= 0 && draggingIndex >= 0 && (i == draggingIndex || selectedIndexes.contains(i))) drawLayer = dragTargetLayer;
			spr.x = timelineX + (ev.time - scrollMs) * pxPerMs;
			spr.y = tlTop + rulerH + drawLayer * layerH + 3;
			spr.visible = layerVis && (spr.x + w >= timelineX && spr.x <= timelineRight + 8);

			if(selectedIndexes.contains(i))
			{
				spr.color = 0xFFF7E26B;
				spr.alpha = 1.0;
			}
			else if(isPlaying && i == upcoming)
			{
				spr.color = 0xFFFFFFFF;
				spr.alpha = 1.0;
			}
			else if(isPlaying && triggeredFlags[i])
			{
				spr.color = CameraEditorData.layerColor(ev.layer);
				spr.alpha = 0.4;
			}
			else
			{
				spr.color = CameraEditorData.layerColor(ev.layer);
				spr.alpha = 0.85;
			}

			var icon:FlxSprite = (i < eventIconSprites.length) ? eventIconSprites[i] : null;
			var tri:FlxSprite = (i < eventTriSprites.length) ? eventTriSprites[i] : null;
			var ikey:String = eventIconKey(ev);
			var barH:Float = layerH - 6;
			if(icon != null)
			{
				icon.visible = spr.visible && ikey != null;
				if(icon.visible)
				{
					icon.loadGraphic(Paths.image(ikey));
					icon.origin.set(0, 0);
					icon.offset.set(0, 0);
					var isz:Float = Math.max(6, barH - 8);
					isz = Math.min(isz, Math.max(6, w - 4));
					icon.scale.set(isz / icon.frameWidth, isz / icon.frameHeight);
					icon.x = spr.x + 3;
					icon.y = spr.y + (barH - isz) / 2;
				}
			}
			if(tri != null)
			{
				tri.visible = spr.visible && eventInstant(ev);
				if(tri.visible)
				{
					tri.origin.set(0, 0);
					tri.offset.set(0, 0);
					tri.scale.set(10 / tri.frameWidth, 8 / tri.frameHeight);
					tri.x = spr.x + w - 13;
					tri.y = spr.y + (barH - 8) / 2;
				}
			}
		}
		updateDragGhosts();
		updateSelectionFrames();
	}

	function updateSelectionFrames():Void
	{
		var need:Int = selectedIndexes.length * 4;
		while(selFrameSprites.length < need)
		{
			var f:FlxSprite = new FlxSprite().makeGraphic(10, 10, FlxColor.WHITE);
			f.scrollFactor.set();
			f.origin.set(0, 0);
			f.visible = false;
			add(f);
			selFrameSprites.push(f);
		}
		for(f in selFrameSprites) f.visible = false;

		var k:Int = 0;
		for(i in selectedIndexes)
		{
			if(i < 0 || i >= events.length || i >= eventSprites.length) continue;
			var spr:FlxSprite = eventSprites[i];
			if(!spr.visible) continue;
			var w:Float = eventDisplayWidth(events[i]);
			var barH:Float = Math.max(6, layerH - 6);
			var th:Float = 2;
			var xs:Array<Float> = [spr.x, spr.x, spr.x, spr.x + w - th];
			var ys:Array<Float> = [spr.y, spr.y + barH - th, spr.y, spr.y];
			var ws:Array<Float> = [w, w, th, th];
			var hs:Array<Float> = [th, th, barH, barH];
			for(n in 0...4)
			{
				if(k >= selFrameSprites.length) break;
				var f2:FlxSprite = selFrameSprites[k++];
				f2.x = xs[n];
				f2.y = ys[n];
				f2.origin.set(0, 0);
				f2.scale.set(Math.max(1, ws[n]) / 10, Math.max(1, hs[n]) / 10);
				f2.color = 0xFFFFFFFF;
				f2.alpha = 1;
				f2.visible = true;
			}
		}
	}

	function updateDragGhosts():Void
	{
		var active:Bool = (draggingIndex >= 0) || (dragResizeMode != 0);
		for(i in 0...ghostSprites.length)
		{
			var g:FlxSprite = ghostSprites[i];
			if(!active || i >= events.length || (!selectedIndexes.contains(i) && i != draggingIndex))
			{
				g.visible = false;
				continue;
			}
			var ev:EdEvent = events[i];
			var gTime:Float = ev.time + dragDeltaMs;
			if(gTime < 0) gTime = 0;
			var gDur:Float = eventDurMs(ev) + dragDeltaDurMs;
			if(gDur < 20) gDur = 20;
			if(gDur > 30000) gDur = 30000;
			var w:Float = Math.max(16, gDur * pxPerMs);
			var layerVis:Bool = (ev.layer < layerVisible.length) ? layerVisible[ev.layer] : true;
			var gLayer:Int = ev.layer;
			if(dragTargetLayer >= 0 && draggingIndex >= 0 && (i == draggingIndex || selectedIndexes.contains(i))) gLayer = dragTargetLayer;
			g.origin.set(0, 0);
			g.scale.x = w / 10;
			g.scale.y = Math.max(1, layerH - 6) / 80;
			g.x = timelineX + (gTime - scrollMs) * pxPerMs;
			g.y = tlTop + rulerH + gLayer * layerH + 3;
			g.visible = layerVis && (g.x + w >= timelineX && g.x <= timelineRight + 8);
		}
	}

	function applyEdgeAutoScroll(mx:Float):Void
	{
		if(draggingIndex < 0 && dragResizeMode == 0 && !boxSelecting) return;
		var span:Float = timelineRight - timelineX;
		if(span < EDGE_ZONE * 3) return;
		var spd:Float = 0;
		if(mx < timelineX + EDGE_ZONE)
		{
			var t:Float = (timelineX + EDGE_ZONE - mx) / EDGE_ZONE;
			if(t > 1) t = 1;
			spd = -EDGE_MAX_SPEED * t;
		}
		else if(mx > timelineRight - EDGE_ZONE)
		{
			var t:Float = (mx - (timelineRight - EDGE_ZONE)) / EDGE_ZONE;
			if(t > 1) t = 1;
			spd = EDGE_MAX_SPEED * t;
		}
		if(spd == 0) return;
		var maxMs:Float = Math.max(0, songEndMs - 1000);
		scrollMs += spd * FlxG.elapsed;
		if(scrollMs < 0) scrollMs = 0;
		if(scrollMs > maxMs) scrollMs = maxMs;
	}

	function updateGrid():Void
	{
		var measureMs:Float = Conductor.crochet * 4;
		if(measureMs <= 0) measureMs = 2000;

		var visMs:Float = (timelineRight - timelineX) / pxPerMs;
		var startMs:Float = scrollMs;
		var firstMeasure:Int = Math.floor(startMs / measureMs);
		var count:Int = Std.int(visMs / measureMs) + 3;
		if(count > gridLines.length) count = gridLines.length;

		for(i in 0...gridLines.length)
		{
			var line:FlxSprite = gridLines[i];
			if(i >= count)
			{
				line.visible = false;
				continue;
			}
			var ms:Float = (firstMeasure + i) * measureMs;
			var x:Float = timelineX + (ms - scrollMs) * pxPerMs;
			line.x = x;
			line.visible = (x >= timelineX - 2 && x <= timelineRight + 2);
		}

		for(i in 0...rulerLabels.length)
		{
			var lbl:FlxText = rulerLabels[i];
			if(i >= count)
			{
				lbl.visible = false;
				continue;
			}
			var x:Float = timelineX + ((firstMeasure + i) * measureMs - scrollMs) * pxPerMs;
			lbl.x = x + 3;
			lbl.text = Std.string(firstMeasure + i + 1);
			lbl.visible = (x >= timelineX - 6 && x <= timelineRight - 6);
		}
	}

	function updatePlayhead():Void
	{
		playhead.x = timelineX + (previewCursorMs - scrollMs) * pxPerMs;
	}

	function updateTimeText():Void
	{
		var curMs:Int = Std.int(Math.max(0, previewCursorMs));
		var totMs:Int = Std.int(Math.max(0, songEndMs));
		if(toolbarTimeText != null)
			toolbarTimeText.text = '${FlxStringUtil.formatTime(curMs / 1000, true)}/${FlxStringUtil.formatTime(totMs / 1000, true)}';
		quantText.text = '吸附: ${quantSteps}步 (Q/E)';
	}

	function cycleQuant(dir:Int):Void
	{
		quantOptionIndex = (quantOptionIndex + dir + QUANT_OPTIONS.length) % QUANT_OPTIONS.length;
		quantSteps = QUANT_OPTIONS[quantOptionIndex];
		quantText.text = '吸附: ${quantSteps}步 (Q/E)';
	}

	function addBookmark():Void
	{
		var t:Float = Math.max(0, Math.round(previewCursorMs));
		if(bookmarks.contains(t)) { showStatus('书签已存在 @ ${FlxStringUtil.formatTime(Std.int(t / 1000), false)}'); return; }
		bookmarks.push(t);
		bookmarks.sort(function(a:Float, b:Float) return Std.int(a - b));
		rebuildBookmarks();
		showStatus('已添加书签 @ ${FlxStringUtil.formatTime(Std.int(t / 1000), false)}（右键书签可删除）');
	}

	function rebuildBookmarks():Void
	{
		while(bookmarkSprites.length > bookmarks.length)
		{
			var s:FlxSprite = bookmarkSprites.pop();
			remove(s);
			s.destroy();
		}
		while(bookmarkSprites.length < bookmarks.length && bookmarkSprites.length < 200)
		{
			var s:FlxSprite = new FlxSprite().makeGraphic(9, 9, 0xFFF7E26B);
			s.scrollFactor.set();
			s.angle = 45;
			s.alpha = 0.9;
			add(s);
			bookmarkSprites.push(s);
		}
		updateBookmarks();
	}

	function updateBookmarks():Void
	{
		for(i in 0...bookmarkSprites.length)
		{
			var bs:FlxSprite = bookmarkSprites[i];
			bs.x = timelineX + (bookmarks[i] - scrollMs) * pxPerMs - 4.5;
			bs.y = tlTop + rulerH - 12;
			bs.visible = (bs.x >= timelineX - 6 && bs.x <= timelineRight);
		}
	}

	inline function xToMs(x:Float):Float
		return Math.max(0, scrollMs + (x - timelineX) / pxPerMs);

	inline function msToX(ms:Float):Float
		return timelineX + (ms - scrollMs) * pxPerMs;

	function mouseMsToSnapped(mx:Float):Float
		return snapTime(xToMs(mx));

	function snapTime(t:Float):Float
	{
		if(snapEnabled == FlxG.keys.pressed.SHIFT) return t;
		var tc = Conductor.getBPMFromSeconds(t);
		var stepMs:Float = tc.stepCrochet;
		if(stepMs <= 0) stepMs = Conductor.stepCrochet;
		var snap:Float = stepMs * quantSteps;
		return Math.round(t / snap) * snap;
	}

	function togglePlayback():Void
	{
		if(isPlaying)
			pausePlayback();
		else
			startPlayback();
	}

	function resetNotePtr():Void
	{
		songNotesPtr = 0;
		while(songNotesPtr < songNotesCache.length && songNotesCache[songNotesPtr].time < previewCursorMs - 1)
			songNotesPtr++;
	}

	function startPlayback():Void
	{
		isPlaying = true;
		if(previewCursorMs >= songEndMs && songEndMs > 0) previewCursorMs = 0;
		triggeredFlags = [for(_ in events) false];
		resetNotePtr();
		Conductor.songPosition = previewCursorMs;
		if(FlxG.sound.music != null)
		{
			if(FlxG.sound.music.playing) FlxG.sound.music.pause();
			FlxG.sound.music.time = previewCursorMs;
			FlxG.sound.music.play();
		}
		var psV:PlayState = PlayState.instance;
		if(psV != null)
		{
			if(psV.vocals != null && psV.vocals.length > 0) { psV.vocals.time = previewCursorMs; psV.vocals.play(); }
			if(psV.opponentVocals != null && psV.opponentVocals.length > 0) { psV.opponentVocals.time = previewCursorMs; psV.opponentVocals.play(); }
		}
		playBtn.label = '暂停';
		if(playBtnSprite != null) playBtnSprite.loadGraphic(Paths.image('ui/camera-editor/pause'));
	}

	function pausePlayback():Void
	{
		isPlaying = false;
		if(FlxG.sound.music != null) FlxG.sound.music.pause();
		var psV:PlayState = PlayState.instance;
		if(psV != null)
		{
			if(psV.vocals != null) psV.vocals.pause();
			if(psV.opponentVocals != null) psV.opponentVocals.pause();
		}
		playBtn.label = '播放/暂停';
		if(playBtnSprite != null) playBtnSprite.loadGraphic(Paths.image('ui/camera-editor/play'));
	}

	function stopPlayback(loop:Bool):Void
	{
		isPlaying = false;
		if(!livePreview)
		{
			if(FlxG.sound.music != null) FlxG.sound.music.pause();
			var psV:PlayState = PlayState.instance;
			if(psV != null)
			{
				if(psV.vocals != null) psV.vocals.pause();
				if(psV.opponentVocals != null) psV.opponentVocals.pause();
			}
			previewCursorMs = loop ? 0 : songEndMs;
			Conductor.songPosition = previewCursorMs;
			triggeredFlags = [for(_ in events) false];
			resetNotePtr();
			simulateCameraAt(previewCursorMs, true);
		}
		playBtn.label = '播放/暂停';
		if(playBtnSprite != null) playBtnSprite.loadGraphic(Paths.image('ui/camera-editor/play'));
	}

	function seekMusic(ms:Float):Void
	{
		previewCursorMs = Math.max(0, ms);
		if(songEndMs > 0 && previewCursorMs > songEndMs) previewCursorMs = songEndMs;
		Conductor.songPosition = previewCursorMs;
		triggeredFlags = [for(_ in events) false];
		resetNotePtr();
		if(FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = previewCursorMs;
			if(isPlaying) FlxG.sound.music.play();
		}
		var psV:PlayState = PlayState.instance;
		if(psV != null)
		{
			if(psV.vocals != null && psV.vocals.length > 0)
			{
				psV.vocals.time = previewCursorMs;
				if(isPlaying) psV.vocals.play();
			}
			if(psV.opponentVocals != null && psV.opponentVocals.length > 0)
			{
				psV.opponentVocals.time = previewCursorMs;
				if(isPlaying) psV.opponentVocals.play();
			}
		}
		simulateCameraAt(previewCursorMs, true);
	}

	function applyPendingEvents():Void
	{
		if(PlayState.instance == null) return;
		for(i in 0...events.length)
		{
			if(events[i].time > previewCursorMs) break;
			if(triggeredFlags[i]) continue;
			triggeredFlags[i] = true;
			applyEvent(events[i]);
		}
	}

	static function normName(n:String):String
	{
		if(n == null) return '';
		var s:String = n.toLowerCase();
		s = StringTools.replace(s, ' ', '');
		s = StringTools.replace(s, '_', '');
		s = StringTools.replace(s, '-', '');
		return s;
	}

	function durIndex(name:String):Int
	{
		var n:String = normName(name);
		if(n == 'focuscamera') return 2;
		if(n == 'camerafollowpos') return 1;
		return 0;
	}

	function easeIndex(name:String):Int
	{
		var n:String = normName(name);
		if(n == 'focuscamera') return 3;
		if(n == 'camerafollowpos') return 2;
		return 1;
	}

	function defaultDurFor(name:String):Float
	{
		var n:String = normName(name);
		if(n == 'cameraangle') return 0.3;
		if(n == 'camerafollowpos') return 0.5;
		return 2;
	}

	function setEventEase(ev:EdEvent, tok:String):Void
	{
		var parts:Array<String> = (ev.v2 == null || ev.v2.length < 1) ? [] : ev.v2.split(',');
		var di:Int = durIndex(ev.name);
		var ei:Int = easeIndex(ev.name);
		while(parts.length <= ei) parts.push('');
		if(parts[di] == null || parts[di].length < 1 || Math.isNaN(Std.parseFloat(parts[di])))
			parts[di] = Std.string(defaultDurFor(ev.name));
		parts[ei] = tok;
		ev.v2 = parts.join(',');
	}

	function eventEaseToken(ev:EdEvent):String
	{
		var parts:Array<String> = (ev.v2 == null) ? [] : ev.v2.split(',');
		var ei:Int = easeIndex(ev.name);
		if(parts.length <= ei) return '';
		return StringTools.trim(parts[ei]);
	}

	function applyEvent(ev:EdEvent, instant:Bool = false):Void
	{
		var ps:PlayState = PlayState.instance;
		if(ps == null) return;
		switch(normName(ev.name))
		{
			case 'focuscamera':
				if(vcamFollowTween != null) { vcamFollowTween.cancel(); vcamFollowTween = null; }
				var target:String = (ev.v1 == null || ev.v1.length < 1) ? 'boyfriend' : ev.v1.toLowerCase();
				var offX:Float = 0;
				var offY:Float = 0;
				if(ev.v2 != null && ev.v2.length > 0)
				{
					var parts:Array<String> = ev.v2.split(',');
					offX = Std.parseFloat(parts[0]);
					if(Math.isNaN(offX)) offX = 0;
					if(parts.length > 1)
					{
						offY = Std.parseFloat(parts[1]);
						if(Math.isNaN(offY)) offY = 0;
					}
				}
				var tx:Float = 0;
				var ty:Float = 0;
				var ok:Bool = false;
				if(target == 'pos' || target == 'position')
				{
					tx = offX;
					ty = offY;
					ok = true;
				}
				else
				{
					var ch:Character = ps.boyfriend;
					if(target == 'dad' || target == 'opponent') ch = ps.dad;
					else if(target == 'gf' || target == 'girlfriend') ch = ps.gf;
				if(ch != null)
				{
					if(target == 'boyfriend')
						tx = ch.getMidpoint().x - ch.cameraPosition[0] + offX;
					else
						tx = ch.getMidpoint().x + ch.cameraPosition[0] + offX;
					ty = ch.getMidpoint().y + ch.cameraPosition[1] + offY;
					ok = true;
				}
				}
				if(ok)
				{
					vcamHasFollow = true;
					vcamFollowX = tx;
					vcamFollowY = ty;
					if(instant)
					{
						var vz0:Float = Math.max(0.05, vcamZoom);
						vcamScrollX = vcamFollowX - FlxG.width / (2 * vz0);
						vcamScrollY = vcamFollowY - FlxG.height / (2 * vz0);
					}
				}

			case 'zoomcamera':
				var z:Float = Std.parseFloat(ev.v1);
				if(Math.isNaN(z) || z <= 0) z = 1.0;
				z = Math.max(0.05, Math.min(5, z));
				var dur:Float = 2.0;
				var ease:Float->Float = FlxEase.quadInOut;
				var easeTok:String = '';
				if(ev.v2 != null && ev.v2.length > 0)
				{
					var parts:Array<String> = ev.v2.split(',');
					var d:Float = Std.parseFloat(parts[0]);
					if(!Math.isNaN(d) && d >= 0) dur = d;
					if(parts.length > 1 && parts[1].length > 0)
					{
						easeTok = StringTools.trim(parts[1]);
						ease = CustomEase.getEaseFn(easeTok);
					}
					if(parts.length > 2 && StringTools.trim(parts[2]) == 'stage')
					{
						var zbase:Float = (PlayState.instance != null) ? PlayState.instance.stageBaseZoom : 1;
						z = Math.max(0.05, Math.min(5, z * zbase));
					}
				}
				if(vcamZoomTween != null) { vcamZoomTween.cancel(); vcamZoomTween = null; }
				if(instant || dur <= 0.001 || CustomEase.isSnapToken(easeTok)) setVcamZoomKeepCenter(z);
				else vcamZoomTween = FlxTween.num(vcamZoom, z, dur, {ease: ease}, setVcamZoomKeepCenter);

			case 'addcamerazoom':
				var add:Float = Std.parseFloat(ev.v1);
				if(Math.isNaN(add)) add = 0.015;
				setVcamZoomKeepCenter(Math.max(0.05, Math.min(5, vcamZoom + add)));

			case 'camerafollowpos':
				var nx:Null<Float> = Std.parseFloat(ev.v1);
				if(Math.isNaN(nx)) nx = null;
				var ny:Null<Float> = null;
				var fparts:Array<String> = (ev.v2 == null || ev.v2.length < 1) ? [] : ev.v2.split(',');
				if(fparts.length > 0)
				{
					ny = Std.parseFloat(fparts[0]);
					if(Math.isNaN(ny)) ny = null;
				}
				if(nx != null || ny != null)
				{
					var dur:Float = 0.5;
					var ease:Float->Float = FlxEase.quadInOut;
					var easeTok:String = '';
					if(fparts.length > 1)
					{
						var d:Float = Std.parseFloat(fparts[1]);
						if(!Math.isNaN(d) && d >= 0) dur = d;
						if(fparts.length > 2 && fparts[2].length > 0)
						{
							easeTok = StringTools.trim(fparts[2]);
							ease = CustomEase.getEaseFn(easeTok);
						}
					}
					vcamHasFollow = true;
					var tx:Float = (nx != null) ? nx : vcamFollowX;
					var ty:Float = (ny != null) ? ny : vcamFollowY;
					if(vcamFollowTween != null) { vcamFollowTween.cancel(); vcamFollowTween = null; }
					if(instant || dur <= 0.001 || CustomEase.isSnapToken(easeTok) || CustomEase.isInstantToken(easeTok))
					{
						vcamFollowX = tx;
						vcamFollowY = ty;
						if(instant)
						{
							var vz1:Float = Math.max(0.05, vcamZoom);
							vcamScrollX = vcamFollowX - FlxG.width / (2 * vz1);
							vcamScrollY = vcamFollowY - FlxG.height / (2 * vz1);
						}
					}
					else
					{
						var sx:Float = vcamFollowX;
						var sy:Float = vcamFollowY;
						vcamFollowTween = FlxTween.num(0, 1, dur, {ease: ease}, function(p:Float)
						{
							vcamFollowX = sx + (tx - sx) * p;
							vcamFollowY = sy + (ty - sy) * p;
						});
					}
				}

			case 'playanimation':
				var char:Character = ps.dad;
				var tname:String = (ev.v2 == null ? '' : ev.v2.toLowerCase());
				switch(tname)
				{
					case 'bf' | 'boyfriend': char = ps.boyfriend;
					case 'gf' | 'girlfriend': char = ps.gf;
					default:
						var n:Null<Int> = Std.parseInt(tname);
						if(n != null)
						{
							if(n == 1) char = ps.boyfriend;
							else if(n == 2) char = ps.gf;
						}
				}
				if(char != null && ev.v1 != null && ev.v1.length > 0 && char.hasAnimation(ev.v1))
				{
					char.playAnim(ev.v1, true);
					char.specialAnim = true;
				}

			case 'cameraangle':
				var ang:Float = Std.parseFloat(ev.v1);
				if(Math.isNaN(ang)) ang = 0;
				var durA:Float = 0.3;
				var easeA:Float->Float = FlxEase.quadOut;
				var easeTokA:String = '';
				if(ev.v2 != null && ev.v2.length > 0)
				{
					var partsA:Array<String> = ev.v2.split(',');
					var dA:Float = Std.parseFloat(partsA[0]);
					if(!Math.isNaN(dA) && dA >= 0) durA = dA;
					if(partsA.length > 1 && partsA[1].length > 0)
					{
						easeTokA = StringTools.trim(partsA[1]);
						easeA = CustomEase.getEaseFn(easeTokA);
					}
				}
				if(vcamAngleTween != null) { vcamAngleTween.cancel(); vcamAngleTween = null; }
				if(instant || durA <= 0.001 || CustomEase.isSnapToken(easeTokA)) vcamAngle = ang;
				else vcamAngleTween = FlxTween.num(vcamAngle, ang, durA, {ease: easeA}, function(v:Float) vcamAngle = v);
		}
		if(!instant && vcamHasFollow && !vcamManualFollow) eventHoldTimer = 2.0;
	}

	function doSave():Void
	{
		CameraEditorData.applyToSong(events);
		CameraEditorData.writeBackup(events);
		var path:String = CameraEditorData.saveChart();
		if(path != null)
		{
			dirty = false;
			showStatus('已保存谱面: $path\n（摄像机事件已写入该歌曲 json）');
			if(saveMarkText != null) saveMarkText.visible = false;
			refreshWindowTitle();
		}
		else
			showStatus('保存失败（无谱面路径）', 2);
	}

	function doExport():Void
	{
		CameraEditorData.applyToSong(events);
		var out:Array<Dynamic> = [];
		var sorted:Array<EdEvent> = events.copy();
		CameraEditorData.sortByTime(sorted);
		var curTime:Float = -1;
		var curList:Array<Dynamic> = [];
		for(ev in sorted)
		{
			if(curTime != ev.time)
			{
				if(curList.length > 0) out.push([curTime, curList]);
				curTime = ev.time;
				curList = [];
			}
			curList.push([ev.name, ev.v1, ev.v2]);
		}
		if(curList.length > 0) out.push([curTime, curList]);

		Clipboard.text = haxe.Json.stringify(out);
		showStatus('已复制 ${events.length} 个事件到剪贴板');
	}

	function doImport():Void
	{
		if(Clipboard.text == null || Clipboard.text.length < 1)
		{
			showStatus('剪贴板为空');
			return;
		}
		try
		{
			var parsed:Dynamic = haxe.Json.parse(Clipboard.text);
			if(parsed == null) throw 'null';
			var arr:Array<Dynamic> = Std.isOfType(parsed, Array) ? cast parsed : (Reflect.hasField(parsed, 'events') ? Reflect.field(parsed, 'events') : null);
			if(arr == null) throw 'bad format';

			var newEvents:Array<EdEvent> = [];
			for(entry in arr)
			{
				if(entry == null) continue;
				var time:Float = Std.parseFloat(Std.string(entry[0]));
				if(Math.isNaN(time)) time = 0;
				var list:Dynamic = entry[1];
				if(list == null) continue;
				var subList:Array<Dynamic> = cast list;
				for(sub in subList)
				{
					if(sub == null) continue;
					var name:String = Std.string(sub[0]);
					var v1:String = (sub.length > 1 && sub[1] != null) ? Std.string(sub[1]) : '';
					var v2:String = (sub.length > 2 && sub[2] != null) ? Std.string(sub[2]) : '';
					newEvents.push({time: time, name: name, v1: v1, v2: v2, layer: CameraEditorData.layerOf(name)});
				}
			}

			pushUndo('导入 cam.json');
			events = newEvents;
			CameraEditorData.sortByTime(events);
			syncData();
			clearSelection();
			rebuildEventSprites();
			refreshPanel();
			showStatus('已导入 ${events.length} 个事件（替换原事件）');
		}
		catch(e:Dynamic)
		{
			showStatus('导入失败：剪贴板不是有效的事件数据');
		}
	}

	function autoSortLayersByType():Void
	{
		var changed:Int = 0;
		for(ev in events)
		{
			if(ev.layer != CameraEditorData.layerOf(ev.name)) changed++;
		}
		if(changed == 0)
		{
			showStatus('事件已按类型位于正确图层');
			return;
		}
		if(autoSortText != null)
		{
			var lines:Array<String> = [];
			lines.push('将按事件类型重新分配图层，共 ' + changed + ' 个事件需要移动。\n');
			lines.push('排序前 → 排序后');
			for(i in 0...CameraEditorData.layerCount())
			{
				var before:Int = 0;
				var after:Int = 0;
				for(ev in events)
				{
					if(ev.layer == i) before++;
					if(CameraEditorData.layerOf(ev.name) == i) after++;
				}
				if(before == 0 && after == 0) continue;
				lines.push('· ' + CameraEditorData.layerName(i) + '  :  ' + before + ' → ' + after);
			}
			autoSortText.text = lines.join('\n');
		}
		autoSortOpen = true;
	}

	function performAutoSort():Void
	{
		autoSortOpen = false;
		var changed:Int = 0;
		for(ev in events)
		{
			if(ev.layer != CameraEditorData.layerOf(ev.name)) changed++;
		}
		if(changed == 0) return;
		pushUndo('按类型排序图层');
		for(ev in events) ev.layer = CameraEditorData.layerOf(ev.name);
		CameraEditorData.sortByTime(events);
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus('已按类型重新排序图层，调整 ' + changed + ' 个事件');
	}

	function clearAllEvents():Void
	{
		if(events.length < 1)
		{
			showStatus('当前没有事件');
			return;
		}
		pushUndo('清空所有事件');
		events = [];
		clearSelection();
		syncData();
		rebuildEventSprites();
		refreshPanel();
		showStatus('已清空所有事件');
	}

	function resetToSingleLayer():Void
	{
		if(CameraEditorData.layerCount() <= 1)
		{
			showStatus('当前已经是单层');
			return;
		}
		pushUndo('重置为默认单层');
		while(CameraEditorData.layerCount() > 1)
			CameraEditorData.removeLayer(CameraEditorData.layerCount() - 1);
		for(ev in events) ev.layer = 0;
		layerVisible = [true];
		selectedLayer = 0;
		syncData();
		rebuildEventSprites();
		rebuildTimelineLayers();
		refreshRulerPositions();
		refreshPanel();
		showStatus('已重置为默认单层');
	}

	function doAutoGenerate():Void
	{
		var added:Int = 0;
		pushUndo('自动生成');

		if(focusGenCheck.checked)
		{
			var secIndex:Int = 0;
			for(sec in PlayState.SONG.notes)
			{
				if(sec == null)
				{
					secIndex++;
					continue;
				}
				var secTime:Float = getSectionTimeMs(secIndex);
				if(secTime > songEndMs && songEndMs > 0) break;
				var target:String = 'boyfriend';
				if(sec.gfSection) target = 'girlfriend';
				else if(!sec.mustHitSection) target = 'dad';
				events.push({time: snapTime(secTime), name: 'Focus Camera', v1: target, v2: '', layer: CameraEditorData.LAYER_FOCUS});
				added++;
				secIndex++;
			}
		}

		if(zoomGenCheck.checked)
		{
			var intervalBeats:Int = Std.int(Math.max(1, zoomIntervalStepper.value));
			var targetZoom:String = zoomTargetInput.text;
			if(targetZoom == null || targetZoom.length < 1) targetZoom = '1.05';
			var stepMs:Float = Conductor.stepCrochet;
			var intervalMs:Float = stepMs * 4 * intervalBeats;
			if(intervalMs <= 0) intervalMs = 1000;
			var t:Float = 0;
			while(songEndMs > 0 && t <= songEndMs)
			{
				events.push({time: snapTime(t), name: 'Zoom Camera', v1: targetZoom, v2: '0.5,linear', layer: CameraEditorData.LAYER_ZOOM});
				added++;
				t += intervalMs;
				if(added > 2000) break;
			}
		}

		CameraEditorData.sortByTime(events);
		syncData();
		rebuildEventSprites();
		refreshPanel();
		autoGenOpen = false;
		showStatus('自动生成完成，新增 $added 个事件');
	}

	function getSectionTimeMs(secIndex:Int):Float
	{
		var total:Float = 0;
		for(i in 0...secIndex)
		{
			var sec = (PlayState.SONG != null && PlayState.SONG.notes != null && i < PlayState.SONG.notes.length) ? PlayState.SONG.notes[i] : null;
			var beats:Float = (sec != null && sec.sectionBeats > 0) ? sec.sectionBeats : 4;
			var tc = Conductor.getBPMFromSeconds(total);
			total += tc.stepCrochet * 4 * beats;
		}
		return total;
	}

	static final STATUS_COLORS:Array<Int> = [0xFF8EF5A0, 0xFFFFC46B, 0xFFFF5C5C];

	function showStatus(msg:String, level:Int = 0):Void
	{
		if(statusText == null)
		{
			statusText = new FlxText(76, strumPreviewY + 10, FlxG.width - 90, '', fs(14));
			statusText.scrollFactor.set();
			statusText.visible = false;
			add(statusText);
		}
		if(level < 0) level = 0;
		if(level > 2) level = 2;
		statusText.text = msg;
		statusText.setFormat(Paths.font(Language.pickFont(msg)), fs(14), STATUS_COLORS[level]);
		statusText.visible = true;
		statusTimer = 3.0;
	}

	function refreshWindowTitle():Void
	{
		if(FlxG.stage == null || FlxG.stage.window == null) return;
		if(prevWindowTitle == null) prevWindowTitle = FlxG.stage.window.title;
		try
		{
			FlxG.stage.window.title = 'Camera Editor - ' + currentSongName + (dirty ? ' *' : '');
		}
		catch(e:Dynamic) {}
	}

	function gatherPrefs():Dynamic
	{
		return {
			pxPerMs: pxPerMs,
			quantOptionIndex: quantOptionIndex,
			scrollMs: Math.max(0, scrollMs),
			strumPreviewVisible: strumPreviewVisible,
			shaderEnabled: shaderCheckBox != null ? shaderCheckBox.checked : shaderEnabledPref,
			layerColors: CameraEditorData.layerColors(),
			keybindings: keybindings,
			bookmarks: {song: currentSongName, times: bookmarks},
			autoScrollMode: autoScrollMode,
			snapEnabled: snapEnabled,
			showPassepartout: showPassepartout,
			showExtendedBounds: showExtendedBounds,
			layerVisible: layerVisible,
			durationSteps: durationSteps,
			panelAX: panelAX, panelAY: panelAY, panelBX: panelBX, panelBY: panelBY
		};
	}

	override public function close():Void
	{

		if(prevWindowTitle != null && FlxG.stage != null && FlxG.stage.window != null)
		{
			try { FlxG.stage.window.title = prevWindowTitle; } catch(e:Dynamic) {}
			prevWindowTitle = null;
		}

		sfx('exitWindow', 0.7);
		syncData();
		applyShaderSuspend(false);

		CameraEditorData.savePrefs(gatherPrefs());

		if(editorCam != null) FlxTween.cancelTweensOf(editorCam);
		if(viewfinderCam != null) FlxTween.cancelTweensOf(viewfinderCam);
		if(editorCam != null)
		{
			FlxG.cameras.remove(editorCam);
			editorCam = null;
		}
		if(viewfinderCam != null)
		{
			FlxG.cameras.remove(viewfinderCam);
			viewfinderCam = null;
		}
		restoreViewfinderCameras();
		if(PlayState.instance != null && PlayState.instance.camGame != null)
		{
			if(FlxG.cameras.list.indexOf(PlayState.instance.camGame) == -1)
				FlxG.cameras.add(PlayState.instance.camGame, true);
			FlxG.camera = PlayState.instance.camGame;
		}

		if(PlayState.instance != null)
		{
			PlayState.instance.paused = false;
			PlayState.instance.camZooming = false;
			PlayState.instance.chartLiveMode = false;
			PlayState.chartCameraFollow = prevChartCamFollow;
			PlayState.instance.defaultCamZoom = prevDefaultCamZoom;
			if(PlayState.instance.camGame != null) PlayState.instance.camGame.followLerp = prevFollowLerp;
			FlxG.mouse.visible = false;
			for(cam in [PlayState.instance.camGame, PlayState.instance.camHUD, PlayState.instance.camOther, PlayState.instance.camOverlay])
				if(cam != null) cam.visible = true;
			if(PlayState.instance.healthBar != null) PlayState.instance.healthBar.visible = true;
			if(PlayState.instance.scoreTxt != null) PlayState.instance.scoreTxt.visible = true;
			if(PlayState.instance.iconP1 != null) PlayState.instance.iconP1.visible = true;
			if(PlayState.instance.iconP2 != null) PlayState.instance.iconP2.visible = true;
			previewZoom = 0.55;
			if(PlayState.instance.camGame != null)
			{
				FlxTween.cancelTweensOf(PlayState.instance.camGame);
				PlayState.instance.camGame.zoom = PlayState.instance.defaultCamZoom;
				PlayState.instance.camGame.angle = 0;
				PlayState.instance.camGame.scroll.set(prevScrollX, prevScrollY);
				PlayState.instance.camGame.y = prevCamY;
			}
			if(PlayState.instance.camHUD != null) PlayState.instance.camHUD.zoom = 1;
			if(FlxG.sound.music != null)
				FlxG.sound.music.play();
			if(PlayState.instance != null && PlayState.instance.vocals != null)
			{
				var syncT:Float = (FlxG.sound.music != null) ? FlxG.sound.music.time : Conductor.songPosition;
				if(PlayState.instance.vocals.length > 0)
				{
					PlayState.instance.vocals.time = syncT;
					PlayState.instance.vocals.play();
				}
			}
			try
			{
				PlayState.instance.rebuildFutureEvents(Conductor.songPosition);
				PlayState.instance.checkFocus();
			}
			catch(e:Dynamic) trace('CameraEditor close resync error: $e');
		}
		super.close();
	}

	override public function destroy():Void
	{
		backend.ui.PsychUIDropDownMenu.resetOpenMenu();
		backend.ui.PsychUIInputText.focusOn = null;
		FlxG.mouse.visible = false;
		PlayState.chartCameraFollow = prevChartCamFollow;
		if(PlayState.instance != null && PlayState.instance.camGame != null)
			PlayState.instance.camGame.followLerp = prevFollowLerp;
		if(editorCam != null)
		{
			FlxG.cameras.remove(editorCam, false);
			editorCam.destroy();
			editorCam = null;
		}
		if(viewfinderCam != null)
		{
			FlxG.cameras.remove(viewfinderCam, false);
			viewfinderCam.destroy();
			viewfinderCam = null;
		}
		super.destroy();
	}
}
