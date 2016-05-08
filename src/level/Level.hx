package level;

import haxe.Json;
import haxe.io.Path;

import luxe.Entity;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.Input;
import luxe.tween.Actuate;
import player.Player;

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

	var playMode: Bool = true;

	var loaded: Bool = false;

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
		{ id: 'assets/images/worldWrap128x64_8.png', w: 128, h: 64 },
		{ id: 'assets/images/mossyrock.png', w: 80, h: 128 },
		{ id: 'assets/images/rock.png', w: 80, h: 128 },
		{ id: 'assets/images/rockhor.png', w: 128, h: 80 },
		{ id: 'assets/images/arbutus.png', w: 277, h: 250 },
		{ id: 'assets/images/moss.png', w: 64, h: 15 },
		{ id: 'assets/images/moss1.png', w: 64, h: 15 },
		{ id: 'assets/images/moss2.png', w: 33, h: 27 },
		{ id: 'assets/images/note.png', w: 14, h: 22 },
	];

	var textPos: Int = 0;

	var showing: Bool = false;

	var texts: Array<String> = [
		'I went to the park today. Sat down on the bench. The bench we played on as kids, where you would pocket crusts of picnic sandwiches to feed the geese while our parent’s backs were turned. Where you leaned in too close and got that little diamond scar that follows the base of your jaw.',

		'I\'m sure that scar has faded now.',

		'Tim died a few weeks ago, although you would be hard pressed to find someone who didn\'t think he\'d just been savouring his last breath for the past decade.',

		'Your letters feel so impersonal. I don’t want to hear how well school is going. I want to hear about the pretty walk you took the other day, or that annoying patch of dry skin that keeps being worn raw despite every attempt at the right shoe/sock combination.',

		'I saw your mom yesterday. She smiled when she spoke of you but her eyes were sad.',

		'Please come home soon.',

		'I still hike to the cliffs, taste sharp fear as I shuffle closer. I\'ll always take the easier way, but fear still rises. These cliffs have claimed one too many, one too young.',

		'I still sneak onto the waterfront lawns of those so rich they can afford a million dollar home just to lounge about for a week or two every summer. Those who exist solely to make it impossible for us to.',

		'The people here, the people that have watched me grow up, now give me long looks. As if wondering if I\'ll ever move on from here.',

		'I found an apartment, the rent is good and the roommates are my age.',

		'I think it\'s time to leave.'
	];

	var notePositions: Array<Float> = [];
	//once a note has been found, store it's position;
	var notes: Array<Int> = [];

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

		for(i in 0...texts.length) {
			notes[i] = -1;
		}

		Luxe.events.listen('player.interact', function(o: {object: Player}) {
			var foundNote: Bool = false;
			var text: Int = 0;
			for(i in 0...notePositions.length) {
				var note = notePositions[i];
				if(Math.abs(o.object.pos.x + (o.object.size.x/2) - note) < 15) {
					foundNote = true;
					if(notes[i] == -1) {
						notes[i] = textPos;
						textPos++;
					}
					text = notes[i];
					break;
				}
			}
			if(!foundNote) return;

			if(!showing) {
				Main.showText(texts[text]);
				showing = true;
			}
			else {
				Main.hideText();
				showing = false;
			}
		});
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
			Util.saveFile(Json.stringify(makeJSON(), '\t'), path);
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
			loaded = true;
		}
		else {
			trace('level ($path) null');
		}
		new Bridge(new Vector(364,110+64), -1);
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
		if(texture == 'assets/images/note.png') {
			notePositions.push(pos.x);
		}
		new VisualObject(texture, pos, size, depth);
	}

	public function addCollider(pos: Vector, size: Vector, ?centered: Bool = false): CollisionObject {
		if(!loading)
			changed = true;
		if(centered) {
			pos.x -= Math.round(size.x/2);
			pos.y -= Math.round(size.y/2);
		}
		var collider: CollisionObject = new CollisionObject(Math.round(pos.x), Math.round(pos.y), Math.round(size.x), Math.round(size.y));
		colliders.push(collider);
		return collider;
	}

	override function destroy(?from_parent: Bool) {
		destroyLevel();
		stamp.destroy();
		super.destroy(from_parent);
	}

	function resetLevel() {
		Main.wrapPoint = 300;
		selected = null;
		destroyLevel();
	}

	function destroyLevel() {
		for(c in colliders) {
			c.destroyObject();
		}
		colliders = [];
		for(v in visuals) {
			v.destroyObject();
		}
		visuals = [];
	}

	function makeJSON(): LevelInfo {
		var final: LevelInfo = {
			colliders: [],
			visuals: []
		};

		for(c in colliders) {
			if(c.dontSave) continue;
			var cObject: ColliderInfo = {
				pos: { x: Math.round(c.collider.x), y: Math.round(c.collider.y) },
				size: { x: c.width, y: c.height }
			};
			final.colliders.push(cObject);
		}

		for(v in visuals) {
			if(v.dontSave) continue;
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
		if(!loaded) return;
		if(!playMode) {
			timer += dt;
			if(timer > 10) {
				timer = 0;
				autoSave();
			}
		}
		if(Luxe.input.keypressed(Key.key_p)) {
			playMode = !playMode;
			stamp.visible = !playMode;
		}
		if(!playMode) {
			stamp.visible = true;
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
			stamp.visible = false;
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
