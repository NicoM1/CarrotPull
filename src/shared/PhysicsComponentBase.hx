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
	public var damper: Float = 200;

	public var gravity: Float = 400;

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
		if(velocity.x > 0) {
			velocity.x = Math.max(velocity.x - damper*dt, 0);
		}
		if(velocity.x < 0) {
			velocity.x = Math.min(velocity.x + damper*dt, 0);
		}

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
				var i: Int = 0;
				var success: Bool = false;
				while(i < 2) {
					i++;
					collider.y--;
					if(!checkCollision(false)) {
						pos.y -= i;
						success = true;
						break;
					}
				}
				if(!success) {
					velocity.x = 0;
					break;
				}
			}
			else {
				if(!checkCollision(sign(vXNew), 1)) {
					if(checkCollision(sign(vXNew), 2)) {
						pos.y += 1;
					}
				}
			}
			if(!checkCollision(sign(vXNew), 0)) {
				pos.x += sign(vXNew);
			}
			else {
				velocity.x = 0;
				break;
			}
		}
		Luxe.camera.pos.x = pos.x*2 - Math.floor(Luxe.camera.viewport.w/2);
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

	function checkCollision(?offsetX: Float = 0, ?offsetY: Float = 0, ?dirty: Bool = true) {
		if(dirty) {
			alignCollider();
			collider.x += offsetX;
			collider.y += offsetY;
		}
		for(c in Level.instance.colliders) {
			var col = Collision.shapeWithShape(collider, c.collider);
			if(col != null && col.separation.length > 0) {
				return true;
			}
		}
		return false;
	}

	function sign(x: Float) {
		if(x < 0) return -1;
		if(x > 0) return 1;
		return 0;
	}
}
