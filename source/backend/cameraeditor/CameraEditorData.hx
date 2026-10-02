package backend.cameraeditor;

import flixel.util.FlxColor;
import backend.Song;
import backend.Paths;
import states.PlayState;
import states.editors.content.PsychJsonPrinter;
import sys.io.File;
import sys.FileSystem;

typedef EditorLayer = {name:String, typeName:String, color:Int}

class CameraEditorData
{
	public static final LAYER_FOCUS:Int = 0;
	public static final LAYER_ZOOM:Int = 1;
	public static final LAYER_ADD_ZOOM:Int = 2;
	public static final LAYER_FOLLOW_POS:Int = 3;
	public static final LAYER_PLAY_ANIM:Int = 4;
	public static final LAYER_ANGLE:Int = 5;
	public static final LAYER_OTHER:Int = 6;
	public static final BUILTIN_LAYER_COUNT:Int = 7;

	public static final DEFAULT_LAYER_COLORS:Array<Int> = [0xFF99C198, 0xFF70959D, 0xFF8070A0, 0xFFC19FB1, 0xFFFFFFCC];

	public static final MANAGED_EVENTS:Array<String> =
	[
		'Focus Camera',
		'Zoom Camera',
		'Play Animation',
		'Add Camera Zoom',
		'Camera Follow Pos',
		'Camera Angle'
	];

	public static final BUILTIN_EVENTS:Array<String> =
	[
		'Focus Camera',
		'Zoom Camera',
		'Add Camera Zoom',
		'Camera Follow Pos',
		'Play Animation',
		'Camera Angle'
	];

	public static var layers:Array<EditorLayer> = [{name: 'Default', typeName: '', color: DEFAULT_LAYER_COLORS[0]}];

	public static function builtinEvents():Array<String>
	{
		return BUILTIN_EVENTS.copy();
	}

	public static function layerCount():Int
	{
		return layers.length;
	}

	public static function layerIndex(layer:Int):Int
	{
		if(layer < 0) return 0;
		if(layer >= layers.length) return layers.length - 1;
		return layer;
	}

	public static function layerName(layer:Int):String
	{
		if(layers.length == 0) return 'Default';
		return layers[layerIndex(layer)].name;
	}

	public static function layerType(layer:Int):String
	{
		if(layers.length == 0) return '';
		return layers[layerIndex(layer)].typeName;
	}

	public static function layerColor(layer:Int):FlxColor
	{
		if(layers.length == 0) return DEFAULT_LAYER_COLORS[0];
		return layers[layerIndex(layer)].color;
	}

	public static function layerColors():Array<Int>
	{
		return [for(l in layers) l.color];
	}

	public static function setLayerColors(colors:Array<Int>):Void
	{
		if(colors == null) return;
		for(i in 0...layers.length)
			if(i < colors.length) layers[i].color = colors[i];
	}

	public static function layerOf(name:String):Int
	{
		for(i in 0...layers.length)
			if(layers[i].typeName == name && name != null && name.length > 0) return i;
		return 0;
	}

	public static function eventNameOfLayer(layer:Int):String
	{
		return layerType(layer);
	}

	public static function nextLayerColor():Int
	{
		return DEFAULT_LAYER_COLORS[layers.length % DEFAULT_LAYER_COLORS.length];
	}

	public static function addLayer(name:String, typeName:String, color:Int):Int
	{
		var nm:String = (name == null || name.length < 1) ? 'Layer ' + (layers.length + 1) : name;
		layers.push({name: nm, typeName: (typeName == null) ? '' : typeName, color: color});
		return layers.length - 1;
	}

	public static function isDefaultLayer(idx:Int):Bool
	{
		return idx >= 0 && idx < layers.length && layers[idx].name == 'Default';
	}

	public static function removeLayer(idx:Int):Bool
	{
		if(layers.length <= 1) return false;
		if(idx < 0 || idx >= layers.length) return false;
		if(isDefaultLayer(idx)) return false;
		layers.splice(idx, 1);
		return true;
	}

	public static function moveLayer(idx:Int, dir:Int):Bool
	{
		if(idx < 0 || idx >= layers.length) return false;
		var tgt:Int = idx + dir;
		if(tgt < 0 || tgt >= layers.length) return false;
		var tmp:EditorLayer = layers[idx];
		layers[idx] = layers[tgt];
		layers[tgt] = tmp;
		return true;
	}

	public static function renameLayer(idx:Int, name:String):Void
	{
		if(idx < 0 || idx >= layers.length) return;
		if(name == null || name.length < 1) return;
		if(isDefaultLayer(idx)) return;
		layers[idx].name = name;
	}

	public static function setLayerType(idx:Int, typeName:String):Void
	{
		if(idx < 0 || idx >= layers.length) return;
		layers[idx].typeName = (typeName == null) ? '' : typeName;
	}

	public static function setLayerColor(idx:Int, color:Int):Void
	{
		if(idx < 0 || idx >= layers.length) return;
		layers[idx].color = color;
	}

	public static function eventHint(name:String):String
	{
		switch(name)
		{
			case 'Focus Camera':
				return '值1: 对焦目标\n  boyfriend / dad / girlfriend\n  pos = 固定坐标\n值2: "偏移X,偏移Y,时长,缓动"\n  （后两项可省略，默认 2,CLASSIC）\n  CLASSIC / INSTANT 忽略时长';
			case 'Zoom Camera':
				return '值1: 目标缩放\n  （如 1.1）\n值2: "时长,缓动,模式"\n  （如 "2,linear,direct"）\n  模式 direct = 绝对缩放\n  模式 stage = 舞台缩放倍数';
			case 'Add Camera Zoom':
				return '值1: 摄像机加量\n  （默认 0.015）\n值2: UI 加量\n  （默认 0.03）';
			case 'Camera Follow Pos':
				return '值1: X 坐标\n值2: "Y,时长,缓动"\n  （后两项可省略，默认 0.5,quadInOut）\n  INSTANT 忽略时长\n留空两个 = 恢复自动跟随';
			case 'Play Animation':
				return '值1: 动画名\n值2: 角色\n  boyfriend / dad / girlfriend';
			case 'Camera Angle':
				return '值1: 角度(度)\n  （如 -10 / 10，0 = 回正）\n值2: "时长,缓动"\n  （如 "0.3,quadOut"）';
		}
		return '自定义事件：\n值1 / 值2 任意内容\n（由 Lua / HScript 处理）';
	}

	public static function defaultValues(name:String):{v1:String, v2:String}
	{
		switch(name)
		{
			case 'Focus Camera': return {v1: 'boyfriend', v2: '0,0,2,CLASSIC'};
			case 'Zoom Camera': return {v1: '1.1', v2: '2,linear,direct'};
			case 'Add Camera Zoom': return {v1: '0.015', v2: '0.03'};
			case 'Camera Follow Pos': return {v1: '', v2: ''};
			case 'Play Animation': return {v1: 'idle', v2: 'boyfriend'};
			case 'Camera Angle': return {v1: '0', v2: '0.3,quadOut'};
		}
		return {v1: '', v2: ''};
	}

	public static function isManaged(name:String):Bool
	{
		if(MANAGED_EVENTS.contains(name)) return true;
		for(l in layers) if(l.typeName == name && name != null && name.length > 0) return true;
		return false;
	}

	public static function getCamPath():String
	{
		if(Song.chartPath == null || Song.chartPath.length < 6) return null;
		var p:String = Song.chartPath;
		if(p.toLowerCase().endsWith('.json')) p = p.substr(0, p.length - 5);
		return p + '-cam.json';
	}

	public static function camFileExists():Bool
	{
		var p:String = getCamPath();
		return p != null && FileSystem.exists(p);
	}

	public static function loadCamEvents():Array<EdEvent>
	{
		var p:String = getCamPath();
		if(p == null || !FileSystem.exists(p)) return [];
		try
		{
			var raw:String = File.getContent(p);
			if(raw == null || raw.length < 1) return [];
			var parsed:Dynamic = haxe.Json.parse(raw);
			var arr:Array<Dynamic> = null;
			if(Std.isOfType(parsed, Array)) arr = cast parsed;
			else if(parsed != null && Reflect.hasField(parsed, 'events')) arr = cast Reflect.field(parsed, 'events');
			if(arr == null) return [];
			return convertRawEvents(arr);
		}
		catch(e:Dynamic)
		{
			trace('CameraEditor loadCamEvents error: $e');
			return [];
		}
	}

	public static function saveCamEvents(events:Array<EdEvent>):String
	{
		var p:String = getCamPath();
		if(p == null) return null;
		try
		{
			var data:Dynamic = {format: 'psych_cam_v1', events: eventsToRawLayered(events)};
			File.saveContent(p, haxe.Json.stringify(data, '\t'));
			return p;
		}
		catch(e:Dynamic) trace('CameraEditor saveCamEvents error: $e');
		return null;
	}

	public static function backupsDir():String
	{
		return './backups/charts/';
	}

	static function pad2(n:Int):String
	{
		return (n < 10 ? '0' : '') + n;
	}

	public static function backupStamp():String
	{
		var d:Date = Date.now();
		return pad2(d.getFullYear() % 100) + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()) + '_' + pad2(d.getHours()) + pad2(d.getMinutes()) + pad2(d.getSeconds());
	}

	public static function backupBaseName():String
	{
		var base:String = 'chart';
		if(Song.chartPath != null && Song.chartPath.length > 0)
		{
			var p:String = Song.chartPath;
			var slash:Int = p.lastIndexOf('/');
			if(p.lastIndexOf('\\') > slash) slash = p.lastIndexOf('\\');
			if(slash >= 0 && slash < p.length - 1) p = p.substr(slash + 1);
			if(p.toLowerCase().endsWith('.json')) p = p.substr(0, p.length - 5);
			if(p.length > 0) base = p;
		}
		return base;
	}

	public static function backupName():String
	{
		return backupBaseName() + '_' + backupStamp();
	}

	public static function writeAutoBackup(events:Array<EdEvent>):String
	{
		var dir:String = backupsDir();
		try
		{
			if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
			var file:String = dir + backupBaseName() + '_autosave.json';
			var data:Dynamic = {format: 'psych_cam_backup_v1', savedAt: Date.now().toString(), camFile: getCamPath(), events: eventsToRawLayered(events)};
			File.saveContent(file, haxe.Json.stringify(data, '\t'));
			return file;
		}
		catch(e:Dynamic) trace('CameraEditor writeAutoBackup error: $e');
		return null;
	}

	public static function writeBackup(events:Array<EdEvent>):String
	{
		var dir:String = backupsDir();
		try
		{
			if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
			var file:String = dir + backupName() + '.json';
			var data:Dynamic = {format: 'psych_cam_backup_v1', savedAt: Date.now().toString(), camFile: getCamPath(), events: eventsToRawLayered(events)};
			File.saveContent(file, haxe.Json.stringify(data, '\t'));
			return file;
		}
		catch(e:Dynamic) trace('CameraEditor writeBackup error: $e');
		return null;
	}

	public static function listBackups():Array<String>
	{
		var dir:String = backupsDir();
		var out:Array<String> = [];
		if(!FileSystem.exists(dir)) return out;
		try
		{
			for(f in FileSystem.readDirectory(dir))
			{
				if(f.toLowerCase().endsWith('.json')) out.push(dir + f);
			}
		}
		catch(e:Dynamic) trace('CameraEditor listBackups error: $e');
		out.sort(function(a:String, b:String):Int
		{
			var ta:Float = 0;
			var tb:Float = 0;
			try { ta = FileSystem.stat(a).mtime.getTime(); } catch(e:Dynamic) {}
			try { tb = FileSystem.stat(b).mtime.getTime(); } catch(e:Dynamic) {}
			if(ta > tb) return -1;
			if(ta < tb) return 1;
			return 0;
		});
		return out;
	}

	public static function latestBackup():String
	{
		var l:Array<String> = listBackups();
		return (l.length > 0) ? l[0] : null;
	}

	public static function backupIsNewer(path:String):Bool
	{
		if(path == null || !FileSystem.exists(path)) return false;
		var cam:String = getCamPath();
		if(cam == null || !FileSystem.exists(cam)) return true;
		try
		{
			return FileSystem.stat(path).mtime.getTime() > FileSystem.stat(cam).mtime.getTime();
		}
		catch(e:Dynamic) {}
		return true;
	}

	public static function loadBackupEvents(path:String):Array<EdEvent>
	{
		if(path == null || !FileSystem.exists(path)) return [];
		try
		{
			var parsed:Dynamic = haxe.Json.parse(File.getContent(path));
			var arr:Array<Dynamic> = null;
			if(parsed != null && Reflect.hasField(parsed, 'events')) arr = cast Reflect.field(parsed, 'events');
			else if(Std.isOfType(parsed, Array)) arr = cast parsed;
			if(arr == null) return [];
			return convertRawEvents(arr);
		}
		catch(e:Dynamic) trace('CameraEditor loadBackupEvents error: $e');
		return [];
	}

	public static function openBackupsFolder():String
	{
		var dir:String = backupsDir();
		var abs:String = dir;
		try
		{
			if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
			abs = FileSystem.fullPath(dir);
		}
		catch(e:Dynamic) trace('CameraEditor openBackupsFolder error: $e');
		#if windows
		try
		{
			Sys.command('explorer', [abs]);
		}
		catch(e:Dynamic) trace('CameraEditor openBackupsFolder cmd error: $e');
		#end
		return abs;
	}

	public static var recentCharts:Array<String> = [];

	public static function pushRecentChart(path:String):Void
	{
		if(path == null || path.length < 1) return;
		var out:Array<String> = [path];
		for(p in recentCharts)
			if(p != path && out.length < 10) out.push(p);
		recentCharts = out;
	}

	public static function camPathForChart(chartPath:String):String
	{
		if(chartPath == null || chartPath.length < 1) return null;
		var p:String = chartPath;
		if(p.toLowerCase().endsWith('.json')) p = p.substr(0, p.length - 5);
		return p + '-cam.json';
	}

	public static function saveCamTo(path:String, events:Array<EdEvent>):Bool
	{
		if(path == null || path.length < 1) return false;
		try
		{
			var data:Dynamic = {format: 'psych_cam_v1', chart: getCamPath(), events: eventsToRawLayered(events)};
			File.saveContent(path, haxe.Json.stringify(data, '\t'));
			return true;
		}
		catch(e:Dynamic) trace('CameraEditor saveCamTo error: $e');
		return false;
	}

	public static function loadCamFrom(path:String):Array<EdEvent>
	{
		if(path == null || !FileSystem.exists(path)) return [];
		try
		{
			var parsed:Dynamic = haxe.Json.parse(File.getContent(path));
			var arr:Array<Dynamic> = null;
			if(Std.isOfType(parsed, Array)) arr = cast parsed;
			else if(parsed != null && Reflect.hasField(parsed, 'events')) arr = cast Reflect.field(parsed, 'events');
			if(arr == null) return [];
			return convertRawEvents(arr);
		}
		catch(e:Dynamic) trace('CameraEditor loadCamFrom error: $e');
		return [];
	}

	public static function chartEventsFrom(path:String):Array<EdEvent>
	{
		if(path == null || !FileSystem.exists(path)) return [];
		var cam:String = camPathForChart(path);
		if(cam != null && FileSystem.exists(cam))
		{
			var ev:Array<EdEvent> = loadCamFrom(cam);
			if(ev.length > 0) return ev;
		}
		try
		{
			var parsed:Dynamic = haxe.Json.parse(File.getContent(path));
			if(parsed == null) return [];
			if(Reflect.hasField(parsed, 'song')) parsed = Reflect.field(parsed, 'song');
			if(parsed == null || !Reflect.hasField(parsed, 'events')) return [];
			var arr:Array<Dynamic> = cast Reflect.field(parsed, 'events');
			if(arr == null) return [];
			var out:Array<EdEvent> = [];
			for(entry in arr)
			{
				if(entry == null) continue;
				var time:Float = Std.parseFloat(Std.string(entry[0]));
				if(Math.isNaN(time)) time = 0;
				var list:Dynamic = entry[1];
				if(list == null) continue;
				for(sub in cast(list, Array<Dynamic>))
				{
					if(sub == null) continue;
					var name:String = Std.string(sub[0]);
					if(!isManaged(name)) continue;
					var v1:String = (sub.length > 1 && sub[1] != null) ? Std.string(sub[1]) : '';
					var v2:String = (sub.length > 2 && sub[2] != null) ? Std.string(sub[2]) : '';
					out.push({time: time, name: name, v1: v1, v2: v2, layer: layerOf(name)});
				}
			}
			sortByTime(out);
			return out;
		}
		catch(e:Dynamic) trace('CameraEditor chartEventsFrom error: $e');
		return [];
	}

	public static function exportCamFolder(dir:String, events:Array<EdEvent>):String
	{
		if(dir == null || dir.length < 1) return null;
		try
		{
			var sep:String = (dir.indexOf('\\') >= 0) ? '\\' : '/';
			if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
			var base:String = 'chart';
			if(Song.chartPath != null && Song.chartPath.length > 0)
			{
				var p:String = Song.chartPath;
				var slash:Int = Std.int(Math.max(p.lastIndexOf('/'), p.lastIndexOf('\\')));
				if(slash >= 0 && slash < p.length - 1) p = p.substr(slash + 1);
				if(p.toLowerCase().endsWith('.json')) p = p.substr(0, p.length - 5);
				if(p.length > 0) base = p;
			}
			saveCamTo(dir + sep + base + '-cam.json', events);
			if(Song.chartPath != null && FileSystem.exists(Song.chartPath))
				File.saveBytes(dir + sep + base + '.json', File.getBytes(Song.chartPath));
			return dir + sep + base + '-cam.json';
		}
		catch(e:Dynamic) trace('CameraEditor exportCamFolder error: $e');
		return null;
	}

	public static function migrateFromSong():Void
	{
		if(camFileExists()) return;
		if(PlayState.SONG == null || PlayState.SONG.events == null) return;

		var camEvents:Array<EdEvent> = [];
		for(entry in PlayState.SONG.events)
		{
			if(entry == null) continue;
			var time:Float = Std.parseFloat(Std.string(entry[0]));
			if(Math.isNaN(time)) time = 0;
			var list:Dynamic = entry[1];
			if(list == null) continue;
			for(sub in cast(list, Array<Dynamic>))
			{
				if(sub == null) continue;
				var name:String = Std.string(sub[0]);
				if(!isManaged(name)) continue;
				var v1:String = (sub.length > 1 && sub[1] != null) ? Std.string(sub[1]) : '';
				var v2:String = (sub.length > 2 && sub[2] != null) ? Std.string(sub[2]) : '';
				camEvents.push({time: time, name: name, v1: v1, v2: v2, layer: layerOf(name)});
			}
		}
		saveCamEvents(camEvents);
	}

	public static function stripManaged(entries:Array<Dynamic>):Array<Dynamic>
	{
		var kept:Array<Dynamic> = [];
		if(entries == null) return kept;
		for(entry in entries)
		{
			if(entry == null) continue;
			var time:Float = Std.parseFloat(Std.string(entry[0]));
			if(Math.isNaN(time)) time = 0;
			var list:Dynamic = entry[1];
			if(list == null) continue;
			var keptSub:Array<Dynamic> = [];
			for(sub in cast(list, Array<Dynamic>))
			{
				if(sub == null) continue;
				if(isManaged(Std.string(sub[0]))) continue;
				keptSub.push(sub);
			}
			if(keptSub.length > 0) kept.push([time, keptSub]);
		}
		return kept;
	}

	public static function applyToSong(events:Array<EdEvent>):Void
	{
		if(PlayState.SONG == null) return;
		var merged:Array<Dynamic> = stripManaged(PlayState.SONG.events).concat(eventsToRaw(events));
		merged.sort(function(a:Dynamic, b:Dynamic)
		{
			var ta:Float = Std.parseFloat(Std.string(a[0]));
			var tb:Float = Std.parseFloat(Std.string(b[0]));
			if(Math.isNaN(ta)) ta = 0;
			if(Math.isNaN(tb)) tb = 0;
			return (ta < tb) ? -1 : (ta > tb ? 1 : 0);
		});
		PlayState.SONG.events = merged;
	}

	public static function mergeCamIntoEvents():Void
	{
		var p:String = getCamPath();
		if(p == null || !FileSystem.exists(p)) return;
		applyToSong(loadCamEvents());
	}

	public static function saveChart():String
	{
		if(PlayState.SONG == null) return null;
		try
		{
			var copy:Dynamic = Reflect.copy(PlayState.SONG);
			if(copy != null && PlayState.SONG.events != null)
				Reflect.setField(copy, 'events', PlayState.SONG.events);
			var chartData:String = PsychJsonPrinter.print(copy, ['sectionNotes', 'events']);
			if(Song.chartPath != null)
			{
				File.saveContent(Song.chartPath, chartData);
				return Song.chartPath;
			}
		}
		catch(e:Dynamic) trace('CameraEditor saveChart error: $e');
		return null;
	}

	public static function prefsPath():String
	{
		#if MODS_ALLOWED
		return Paths.mods('camera_editor_prefs.json');
		#else
		return 'mods/camera_editor_prefs.json';
		#end
	}

	public static function loadPrefs():Dynamic
	{
		try
		{
			if(!FileSystem.exists(prefsPath())) return null;
			var parsed:Dynamic = haxe.Json.parse(File.getContent(prefsPath()));
			if(parsed != null && Reflect.hasField(parsed, 'layers')
				&& parsed.layers != null && Std.isOfType(parsed.layers, Array))
			{
				var loaded:Array<EditorLayer> = [];
				for(l in cast(parsed.layers, Array<Dynamic>))
				{
					if(l == null) continue;
					var nm:String = Std.string(Reflect.field(l, 'name'));
					if(nm.length < 1) continue;
					var ty:String = Reflect.hasField(l, 'typeName') ? Std.string(Reflect.field(l, 'typeName')) : '';
					var cv:Null<Int> = Std.parseInt(Std.string(Reflect.field(l, 'color')));
					loaded.push({name: nm, typeName: ty, color: cv == null ? nextLayerColor() : cv});
				}
				if(loaded.length > 0) layers = loaded;
			}
			if(parsed != null && Reflect.hasField(parsed, 'recentCharts') && Reflect.field(parsed, 'recentCharts') != null)
			{
				var rc:Array<String> = [];
				for(r in cast(Reflect.field(parsed, 'recentCharts'), Array<Dynamic>))
				{
					var rs:String = Std.string(r);
					if(rs.length > 0 && rc.length < 10) rc.push(rs);
				}
				recentCharts = rc;
			}
			return parsed;
		}
		catch(e:Dynamic) return null;
	}

	public static function savePrefs(prefs:Dynamic):Void
	{
		try
		{
			var path:String = prefsPath();
			var dir:String = path.substr(0, path.lastIndexOf('/'));
			if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
			if(prefs != null) Reflect.setField(prefs, 'layers', layers);
			if(prefs != null) Reflect.setField(prefs, 'recentCharts', recentCharts);
			File.saveContent(path, haxe.Json.stringify(prefs, '\t'));
		}
		catch(e:Dynamic) {}
	}

	public static function convertRawEvents(arr:Array<Dynamic>):Array<EdEvent>
	{
		var result:Array<EdEvent> = [];
		for(entry in arr)
		{
			if(entry == null) continue;
			var time:Float = Std.parseFloat(Std.string(entry[0]));
			if(Math.isNaN(time)) time = 0;
			var list:Dynamic = entry[1];
			if(list == null) continue;
			for(sub in cast(list, Array<Dynamic>))
			{
				if(sub == null) continue;
				var name:String = Std.string(sub[0]);
				var v1:String = (sub.length > 1 && sub[1] != null) ? Std.string(sub[1]) : '';
				var v2:String = (sub.length > 2 && sub[2] != null) ? Std.string(sub[2]) : '';
				var layer:Int = layerOf(name);
				if(sub.length > 3 && sub[3] != null)
				{
					var lv:Float = Std.parseFloat(Std.string(sub[3]));
					if(!Math.isNaN(lv) && lv >= 0) layer = layerIndex(Std.int(lv));
				}
				result.push({time: time, name: name, v1: v1, v2: v2, layer: layer});
			}
		}
		sortByTime(result);
		return result;
	}

	public static function eventsToRaw(events:Array<EdEvent>):Array<Dynamic>
	{
		var sorted:Array<EdEvent> = events.copy();
		sortByTime(sorted);

		var out:Array<Dynamic> = [];
		var curTime:Float = -1;
		var curList:Array<Dynamic> = [];
		for(ev in sorted)
		{
			if(ev.name.length < 1) continue;
			if(curTime != ev.time)
			{
				if(curList.length > 0) out.push([curTime, curList]);
				curTime = ev.time;
				curList = [];
			}
			curList.push([ev.name, ev.v1, ev.v2]);
		}
		if(curList.length > 0) out.push([curTime, curList]);
		return out;
	}

	public static function eventsToRawLayered(events:Array<EdEvent>):Array<Dynamic>
	{
		var sorted:Array<EdEvent> = events.copy();
		sortByTime(sorted);

		var out:Array<Dynamic> = [];
		var curTime:Float = -1;
		var curList:Array<Dynamic> = [];
		for(ev in sorted)
		{
			if(ev.name.length < 1) continue;
			if(curTime != ev.time)
			{
				if(curList.length > 0) out.push([curTime, curList]);
				curTime = ev.time;
				curList = [];
			}
			curList.push([ev.name, ev.v1, ev.v2, ev.layer]);
		}
		if(curList.length > 0) out.push([curTime, curList]);
		return out;
	}

	public static function sortByTime(arr:Array<EdEvent>):Void
	{
		arr.sort(function(a:EdEvent, b:EdEvent)
		{
			if(a.time < b.time) return -1;
			if(a.time > b.time) return 1;
			return 0;
		});
	}
}
