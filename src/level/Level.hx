package level;

import luxe.Entity;
import luxe.Vector;

class Level extends Entity {

	public static var instance: Level;

	public var colliders: Array<CollisionObject> = [];

	public var selected: CollisionObject;

	public function new() {
		instance = this;
		super({
			name: 'level'
		});

		colliders.push(new CollisionObject(0,30,10,10));
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
	}
}
