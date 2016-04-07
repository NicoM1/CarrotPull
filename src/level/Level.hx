package level;

import luxe.Entity;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;

import phoenix.Texture;

import mint.layout.margins.Margins;

class Level extends Entity {

	public static var instance: Level;

	public var colliders: Array<CollisionObject> = [];
	public var visuals: Array<VisualObject> = [];

	public var selected: EditableObject;

	var plant: Sprite;

	var conversation: conversation.ConversationTree;

	var stamp: Sprite;

	var stamps: Array<StampInfo> = [
		{ id: 'assets/images/plant.png', w: 15, h: 55 },
		{ id: 'assets/images/ground.png', w: 52, h: 14 },
		{ id: 'assets/images/grass.png', w: 52, h: 12 }
	];

	var visualEditing: Bool = true;
	var curStamp: StampInfo;

	var lastDepth: Float = 0;

	public function new() {
		instance = this;
		super({
			name: 'level'
		});

		setupUI();

		colliders.push(new CollisionObject(0,30,10,10));

		addVisual('assets/images/plant.png', new Vector(Luxe.camera.center.x-30, Luxe.camera.center.y - 40), new Vector(15, 55));

		var plant1 = new Sprite({
			name: 'plant1',
			pos: new Vector(Luxe.camera.center.x-45, Luxe.camera.center.y - 45),
			centered: false,
			texture: Luxe.resources.texture('assets/images/carrot.png')
		});
		plant1.texture.filter_mag = FilterType.nearest;

		var ground = new Sprite({
			name: 'ground',
			pos: new Vector(Luxe.camera.center.x-45, Main.gameResolution.y - 30),
			centered: false,
			texture: Luxe.resources.texture('assets/images/ground.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		ground = new Sprite({
			name: 'ground',
			pos: new Vector(Luxe.camera.center.x-80, Main.gameResolution.y - 30),
			centered: false,
			texture: Luxe.resources.texture('assets/images/ground.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		ground = new Sprite({
			name: 'ground',
			pos: new Vector(Luxe.camera.center.x, Main.gameResolution.y - 30),
			centered: false,
			texture: Luxe.resources.texture('assets/images/ground.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		ground = new Sprite({
			name: 'ground1',
			pos: new Vector(Luxe.camera.center.x, Main.gameResolution.y -38),
			centered: false,
			depth:10,
			texture: Luxe.resources.texture('assets/images/grass.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		ground = new Sprite({
			name: 'ground1',
			pos: new Vector(Luxe.camera.center.x-80, Main.gameResolution.y -38),
			centered: false,
			depth:10,
			texture: Luxe.resources.texture('assets/images/grass.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		ground = new Sprite({
			name: 'ground1',
			pos: new Vector(Luxe.camera.center.x-40, Main.gameResolution.y -38),
			centered: false,
			depth:10,
			texture: Luxe.resources.texture('assets/images/grass.png')
		});
		ground.texture.filter_mag = FilterType.nearest;

		conversation = new conversation.ConversationTree();
	}

	function setupUI() {
		var canvas = Main.canvas;
		var layout = Main.layout;

		var stampWindow = new mint.Window({
		   parent: canvas,
		   name: 'stampwindow',
		   title: 'Stamps',
		   options: {
			   color:new Color().rgb(0x121212),
			   color_titlebar:new Color().rgb(0x191919),
			   label: { color:new Color().rgb(0x06b4fb) },
			   close_button: { color:new Color().rgb(0x06b4fb) },
		   },
		   x:5, y:5, w:300, h: 100,
		   w_min: 100, h_min: 100,
		   collapsible:true,
		   closable: false
		});

		var toggle = new mint.Checkbox({
			parent: stampWindow,
			name: 'stamptoggle',
			w: 15, h: 15
		});

		toggle.onchange.listen(function(x,_){editModeChanged(x);});

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
			var img = new mint.Image({
				parent: stampList,
				name: 'image',
				x:0, y:0,
				w:s.w*4, h:s.h*4,
				path: s.id,
				mouse_input: true
			});

			img.onmousedown.listen(function(_,_) {
				trace(s);
				stamp.texture = Luxe.resources.texture(s.id);
				stamp.size.set_xy(s.w, s.h);
				curStamp = s;
			});

			stampList.add_item(img, 0, 8);
		}

		layout.margin(stampList, right, fixed, 5);
		layout.margin(stampList, left, fixed, 5);
		layout.margin(stampList, top, fixed, 30);
		layout.margin(stampList, bottom, fixed, 5);


		stamp = new Sprite({
			name: 'stamp',
			pos: Luxe.screen.cursor.pos,
			centered: false,
			texture: Luxe.resources.texture('assets/images/plant.png'),
			size: new Vector(15, 55),
			depth: 999
		});
		stamp.texture.filter_mag = FilterType.nearest;

		curStamp = {
			id: 'assets/images/plant.png',
			w: 15,
			h: 55
		};
	}

	function editModeChanged(visual: Bool) {
		visualEditing = visual;
		stamp.visible = visualEditing;
	}

	function addVisual(texture: String, pos: Vector, size: Vector, ?centered: Bool = false) {
		if(centered) {
			pos.x -= size.x/2;
			pos.y -= size.y/2;
		}
		pos.int();
		size.int();
		lastDepth += 0.00001;
		visuals.push(new VisualObject(texture, pos, size, lastDepth));
	}

	function addCollider(pos: Vector, size: Vector, ?centered: Bool = false) {
		if(centered) {
			pos.x -= Math.round(size.x/2);
			pos.y -= Math.round(size.y/2);
		}
		colliders.push(new CollisionObject(Math.round(pos.x), Math.round(pos.y), Math.round(size.x), Math.round(size.y)));
	}

	var tmpVector: Vector = new Vector();
	override function update(dt : Float) {
		for(c in colliders) {
			c.update();
		}
		for(v in visuals) {
			v.editUpdate();
		}

		stamp.pos = Luxe.camera.screen_point_to_world(Luxe.screen.cursor.pos);
		stamp.pos.x -= stamp.size.x/2;
		stamp.pos.y -= stamp.size.y/2;
		stamp.pos.int();

		if(Luxe.input.mousepressed(3)) {
			tmpVector.x = Luxe.screen.cursor.pos.x;
			tmpVector.y = Luxe.screen.cursor.pos.y;
			tmpVector = Luxe.camera.screen_point_to_world(tmpVector);
			if(visualEditing) {
				addVisual(curStamp.id, tmpVector, new Vector(curStamp.w, curStamp.h), true);
			}
			else {
				addCollider(tmpVector, new Vector(10,10), true);
			}
		}

		conversation.update();
	}
}

typedef StampInfo = {
	id: String,
	w: Int,
	h: Int
};
