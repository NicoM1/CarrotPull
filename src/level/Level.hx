package level;

import luxe.Entity;
import luxe.Vector;
import luxe.Sprite;
import phoenix.Texture;

class Level extends Entity {

	public static var instance: Level;

	public var colliders: Array<CollisionObject> = [];

	public var selected: CollisionObject;

	var plant: Sprite;

	var conversation: conversation.ConversationTree;

	public function new() {
		instance = this;
		super({
			name: 'level'
		});

		colliders.push(new CollisionObject(0,30,10,10));

		plant = new Sprite({
			name: 'plant',
			pos: new Vector(Luxe.camera.center.x-30, Luxe.camera.center.y - 40),
			centered: false,
			texture: Luxe.resources.texture('assets/images/plant.png')
		});
		plant.texture.filter_mag = FilterType.nearest;

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

	var tmpVector: Vector = new Vector();
	override function update(dt : Float) {
		for(c in colliders) {
			c.update();
		}

		if(Luxe.input.mousepressed(3)) {
			tmpVector.x = Luxe.screen.cursor.pos.x;
			tmpVector.y = Luxe.screen.cursor.pos.y;
			tmpVector = Luxe.camera.screen_point_to_world(tmpVector);
			colliders.push(new CollisionObject(Math.round(tmpVector.x)-5, Math.round(tmpVector.y)-5,10,10));
		}

		conversation.update();
	}
}
