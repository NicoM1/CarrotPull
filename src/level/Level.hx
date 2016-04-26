package level;

import haxe.Json;
import haxe.io.Path;

import luxe.Entity;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.Input;

import dialogs.Dialogs;

import shared.Util;

import phoenix.Texture;
import phoenix.geometry.LineGeometry;

import mint.layout.margins.Margins;

class Level extends Entity {

	public static var instance: Level;

	public var colliders: Array<CollisionObject> = [];
	public var visuals: Array<VisualObject> = [];

	public var toDestroy: Array<EditableObject> = [];

	public var selected: EditableObject;

	public var changed: Bool = false;

	var stampWindow: ui.Window;

	var playMode: Bool = false;

	var current: String;

	var loading: Bool = false;

	var plant: Sprite;

	var conversation: conversation.ConversationTree;

	var stamp: Sprite;

	var leftLine: LineGeometry;
	var rightLine: LineGeometry;

	var stamps: Array<StampInfo> = [
		// { id: 'assets/images/plant.png', w: 15, h: 55 },
		// { id: 'assets/images/ground.png', w: 52, h: 14 },
		// { id: 'assets/images/grass.png', w: 52, h: 12 },
		// { id: 'assets/images/rocks.png', w: 52, h: 14 },
		{ id: 'assets/images/worldWrap128x64_0.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_1.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_2.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_3.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_4.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_5.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_6.png', w: 128, h: 64 },
		{ id: 'assets/images/worldWrap128x64_7.png', w: 128, h: 64 },

	];

	var visualEditing: Bool = true;
	var curStamp: StampInfo;

	var lastDepth: Float = 0;

	function setCurrent(path: String) {
		current = Util.getRelativePath(path);
		Util.saveFile(current, 'curlvl');
	}

	function getCurrent(): String {
		if(current == null) {
			var path = Util.loadFile('curlvl');
			if(path != null) {
				current = path;
			}
		}
		return current;
	}

	public function new() {
		loading = true;
		instance = this;
		super({
			name: 'level'
		});

		setupUI();

		if(getCurrent() != null) {
			loadLevel(current);
		}
		else {
			loadLevel('assets/levels/test.lvl');
			trace('default loaded');
		}
	}

	public function adjustWrapping() {
		if(leftLine != null) {
			leftLine.drop(true);
			rightLine.drop(true);
		}
		leftLine = Luxe.draw.line({
			p0: new Vector(Main.wrapPoint, 0),
			p1: new Vector(Main.wrapPoint, Main.gameResolution.y),
			batcher: Main.sceneBatcher
		});

		rightLine = Luxe.draw.line({
			p0: new Vector(0, 0),
			p1: new Vector(0, Main.gameResolution.y),
			batcher: Main.sceneBatcher
		});
		for(v in visuals) {
			v.adjustWrapping();
		}
	}

	var visualToggleButton: mint.Checkbox;
	function setupUI() {
		var canvas = Main.canvas;
		var layout = Main.layout;

		stampWindow = new ui.Window({
		   parent: canvas,
		   name: 'stampwindow',
		   title: 'Stamps',
		   options: {
			   color:new Color().rgb(0x121212),
			   color_titlebar:new Color().rgb(0x191919),
			   label: { color:new Color().rgb(0x06b4fb) },
			   close_button: { color:new Color().rgb(0x06b4fb) },
		   },
		   x: 5, y: 5, w: 150, h: 300,
		   w_min: 100, h_min: 100,
		   collapsible: false,
		   closable: false
		});

		visualToggleButton = new mint.Checkbox({
			parent: stampWindow,
			name: 'stamptoggle',
			options: {
			  	color:new Color().rgb(0x121212)
		  	},
			w: 15, h: 15
		});

		visualToggleButton.onchange.listen(function(x,_){editModeChanged(x);});

		var stampList = new mint.List({
			parent: stampWindow,
			name: 'stamplist',
			options: {
				view: {
					color: new Color().rgb(0x19191c)
				}
			},
			w: 90,
			h: 65
		});

		for(s in stamps) {
			var texture = Luxe.resources.texture(s.id);
			texture.filter_mag = FilterType.nearest;

			var img = new mint.Image({
				parent: stampList,
				name: 'image',
				x:0, y:0,
				w:s.w/2, h:s.h/2,
				path: s.id,
				mouse_input: true
			});

			img.onmousedown.listen(function(_,_) {
				trace(s);
				stamp.texture = texture;
				stamp.size.set_xy(s.w, s.h);
				curStamp = s;
			});

			stampList.add_item(img, 0, 8);
		}

		layout.margin(stampList, right, fixed, 5);
		layout.margin(stampList, left, fixed, 5);
		layout.margin(stampList, top, fixed, 30);
		layout.margin(stampList, bottom, fixed, 5);

		var saveButton = new mint.Button({
			parent: stampWindow,
			name: 'savebutton',
			text: ' save ',
			options: {
			  	color:new Color().rgb(0x121212)
		  	},
			x: 20,
			w: 25, h:15
		});

		var loadButton = new mint.Button({
			parent: stampWindow,
			name: 'loadbutton',
			text: ' load ',
			options: {
			  	color:new Color().rgb(0x121212)
		  	},
			x: 50,
			w: 25, h:15
		});

		var resetButton = new mint.Button({
			parent: stampWindow,
			name: 'resetbutton',
			text: ' reset ',
			options: {
			  	color:new Color().rgb(0x121212)
		  	},
			x: 80,
			w: 25, h:15
		});

		saveButton.onmousedown.listen(function(_, _) {
			trace('save');
			pickSave();
		});

		loadButton.onmousedown.listen(function(_, _) {
			trace('load');
			pickLevel();
		});

		resetButton.onmousedown.listen(function(_, _) {
			trace('reset');
			resetLevel();
		});

		stamp = new Sprite({
			name: 'stamp',
			pos: Luxe.screen.cursor.pos,
			centered: false,
			texture: Luxe.resources.texture('assets/images/plant.png'),
			size: new Vector(15, 55),
			depth: 999,
			batcher: Main.sceneBatcher
		});
		stamp.texture.filter_mag = FilterType.nearest;

		curStamp = {
			id: 'assets/images/plant.png',
			w: 15,
			h: 55
		};
	}

	function pickSave() {
		var path = Dialogs.save('save level.', {
			ext: 'lvl',
			desc: 'level file'
		});
		saveLevel(path);
	}

	function saveLevel(path: String, ?autosave: Bool = false) {
		if(path != null) {
			if(path.indexOf('.lvl') == -1) {
				path += '.lvl';
			}
			if(!autosave) {
				setCurrent(path);
				changed = false;
			}
			Util.saveFile(Json.stringify(makeJSON()), path);
		}
	}

	function autoSave() {
		saveLevel('autosave.bak', true);
	}

	function pickLevel() {
		var path = Dialogs.open('load level.', [{
			ext: 'lvl',
			desc: 'level file'
		},{
			ext: 'json',
			desc: 'generic JSON file.'
		}]);
		if(path != null) {
			loadLevel(path);
			changed = false;
		}
	}

	function loadLevel(path: String) {
		var data = Util.loadFile(path);
		if(data != null) {
			setCurrent(path);
			parseJSON(data);
		}
		else {
			trace('level ($path) null');
		}
		adjustWrapping();
	}

	function editModeChanged(visual: Bool) {
		visualEditing = visual;
		stamp.visible = visualEditing;
	}

	function addVisual(texture: String, pos: Vector, size: Vector, ?centered: Bool = false, ?depth: Float) {
		if(!loading)
			changed = true;
		if(centered) {
			pos.x -= size.x/2;
			pos.y -= size.y/2;
		}
		pos.int();
		size.int();
		if(depth == null) {
			lastDepth += 0.00001;
			depth = lastDepth;
		}
		visuals.push(new VisualObject(texture, pos, size, depth));
	}

	function addCollider(pos: Vector, size: Vector, ?centered: Bool = false) {
		if(!loading)
			changed = true;
		if(centered) {
			pos.x -= Math.round(size.x/2);
			pos.y -= Math.round(size.y/2);
		}
		colliders.push(new CollisionObject(Math.round(pos.x), Math.round(pos.y), Math.round(size.x), Math.round(size.y)));
	}

	override function destroy(?from_parent: Bool) {
		super.destroy(from_parent);
		resetLevel();
	}

	function resetLevel() {
		Main.wrapPoint = 300;
		selected = null;
		for(c in colliders) {
			c.destroyObject();
		}
		colliders = [];
		for(v in visuals) {
			v.destroyObject();
		}
		visuals = [];
	}

	function makeJSON() {
		var final: LevelInfo = {
			colliders: [],
			visuals: []
		};

		for(c in colliders) {
			var cObject: ColliderInfo = {
				pos: { x: Math.round(c.collider.x), y: Math.round(c.collider.y) },
				size: { x: c.width, y: c.height }
			};
			final.colliders.push(cObject);
		}

		for(v in visuals) {
			if(v.pos.x > Main.wrapPoint || v.pos.x + v.size.x < 0) continue;
			var vObject: VisualInfo = {
				tex: v.texturePath,
				pos: { x: Math.round(v.pos.x), y: Math.round(v.pos.y) },
				size: { x: Math.round(v.size.x), y: Math.round(v.size.y) },
				depth: v.depth
			};
			final.visuals.push(vObject);
		}

		final.wrapPoint = Main.wrapPoint;

		return(final);
	}

	function parseJSON(json: String) {
		loading = true;
		resetLevel();
		var jsonO: LevelInfo = Json.parse(json);

		for(c in jsonO.colliders) {
			addCollider(new Vector(c.pos.x, c.pos.y), new Vector(c.size.x, c.size.y));
		}
		for(v in jsonO.visuals) {
			addVisual(v.tex, new Vector(v.pos.x, v.pos.y), new Vector(v.size.x, v.size.y), v.depth);
		}

		if(jsonO.wrapPoint != null) {
			Main.wrapPoint = jsonO.wrapPoint;
		}
		trace('done');
		loading = false;
	}

	var timer: Float = 0;
	var tmpVector: Vector = new Vector();
	override function update(dt : Float) {
		if(!playMode) {
			timer += dt;
			if(timer > 10) {
				timer = 0;
				autoSave();
			}
		}
		if(Luxe.input.keypressed(Key.key_s)) {
			parseJSON(Json.stringify(makeJSON()));
		}
		if(Luxe.input.keypressed(Key.key_p)) {
			playMode = !playMode;
			stamp.visible = !playMode;
		}
		if(!playMode) {
			leftLine.visible = true;
			rightLine.visible = true;
			stampWindow.visible = true;
			if(Luxe.input.keypressed(Key.key_v)) {
				visualToggleButton.state = !visualToggleButton.state;
			}
			for(c in colliders) {
				c.update();
			}
			for(v in visuals) {
				v.editUpdate();
			}

			if(selected == null && visualToggleButton.state) {
				stamp.visible = true;
			}
			else {
				stamp.visible = false;
			}

			for(d in toDestroy) {
				if(Std.is(d, CollisionObject)) {
					colliders.remove(cast d);
				}
				else if(Std.is(d, VisualObject)) {
					visuals.remove(cast d);
				}
				d.destroyObject();
				changed = true;
			}
			if(toDestroy.length != 0) {
				selected = null;
				toDestroy = [];
			}

			stamp.pos = Main.screen_point_to_world(Luxe.screen.cursor.pos);
			stamp.pos.x -= stamp.size.x/2;
			stamp.pos.y -= stamp.size.y/2;
			stamp.pos.int();

			if(Luxe.input.mousepressed(3)) {
				tmpVector.x = Luxe.screen.cursor.pos.x;
				tmpVector.y = Luxe.screen.cursor.pos.y;
				tmpVector = Main.screen_point_to_world(tmpVector);
				if(visualEditing) {
					addVisual(curStamp.id, tmpVector, new Vector(curStamp.w, curStamp.h), true);
				}
				else {
					addCollider(tmpVector, new Vector(10,10), true);
				}
			}
		}
		else {
			leftLine.visible = false;
			rightLine.visible = false;
			stampWindow.visible = false;
		}

		//conversation.update();
	}
}

typedef StampInfo = {
	id: String,
	w: Int,
	h: Int
};

typedef LevelInfo = {
	visuals: Array<VisualInfo>,
	colliders: Array<ColliderInfo>,
	?wrapPoint: Int
}

typedef VisualInfo = {
	tex: String,
	pos: Point,
	size: Point,
	depth: Float
}

typedef ColliderInfo = {
	pos: Point,
	size: Point
}

typedef Point = {
	x: Int,
	y: Int
}
