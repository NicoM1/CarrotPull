package shared;

import luxe.Component;
import luxe.collision.Collision;
import luxe.collision.data.ShapeCollision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;
import luxe.Vector;
import luxe.Sprite;

import level.Level;

class PhysicsComponentBase extends Component {
	public var velocity: Vector = new Vector();
	public var damper: Float = 0.98;

	public var gravity: Float = 600;

	var sprite: Sprite;
	var collider: Polygon;

	var aVel: Vector = new Vector();

	public function new(width: Int, height: Int) {
		super({
			name: 'physics'
		});

		collider = Polygon.rectangle(0, 0, width, height, false);
	}

	override function init() {
		sprite = cast entity;
	}

	override function update(dt: Float) {
		velocity.y += gravity * dt;
		velocity.x *= damper;

		aVel.x += velocity.x * dt;
		aVel.y += velocity.y * dt;

		var vXNew: Int = sign(aVel.x) * Math.floor(Math.abs(aVel.x));
		var vYNew: Int = sign(aVel.y) * Math.floor(Math.abs(aVel.y));

		aVel.x -= vXNew;
		aVel.y -= vYNew;

		alignCollider();

		for(y in 0...Std.int(Math.abs(vYNew))) {
			collider.y += sign(vYNew);
			if(checkCollision(false)) {
				collider.y -= sign(vYNew);
				velocity.y = 0;
				break;
			}
		}

		pos.y = collider.y;

		for(x in 0...Std.int(Math.abs(vXNew))) {
			collider.x += sign(vXNew);

			if(checkCollision(false)) {
				collider.x -= sign(vXNew);
				velocity.x = 0;
				break;
			}
		}

		pos.x = collider.x;

		/*if(posReal.y + sprite.size.y > Main.gameResolution.y) {
			posReal.y = Main.gameResolution.y - sprite.size.y;
			velocity.y = 0;
		}*/

		Main.shapeDrawer.drawShape(collider);
	}

	inline function alignCollider() {
		collider.x = Math.floor(pos.x);
		collider.y = Math.floor(pos.y);
	}

	public function onGround(): Bool {
		return checkCollision(0, 1);
	}

	public function touching(): Bool {
		return checkCollision(1,1)
			|| checkCollision(-1,1)
			|| checkCollision(1,-1)
			|| checkCollision(-1,-1);
	}

	var testShape: Polygon;
	function checkCollision(?offsetX: Float = 0, ?offsetY: Float = 0, ?dirty: Bool = true) {
		testShape = Polygon.rectangle(0,60,160,10,false);
		Main.shapeDrawer.drawShape(testShape);
		if(dirty) {
			alignCollider();
			collider.x += offsetX;
			collider.y += offsetY;
		}
		var testShape1 = Polygon.rectangle(95,50,20,10,false);
		Main.shapeDrawer.drawShape(testShape1);
		for(c in Level.instance.colliders) {
			var col = Collision.shapeWithShape(collider, c.collider);
			if(col != null && col.separation.length > 0) {
				return true;
			}
		}
		var col = Collision.shapeWithShape(testShape, collider);
		if(col != null && col.separation.length > 0) {
			return true;
		}
		col = Collision.shapeWithShape(testShape1, collider);
		if(col != null && col.separation.length > 0) {
			return true;
		}
		return false;
	}

	function sign(x: Float) {
		if(x < 0) return -1;
		if(x > 0) return 1;
		return 0;
	}
}
