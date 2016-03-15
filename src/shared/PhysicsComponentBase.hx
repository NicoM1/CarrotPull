package shared;

import luxe.Component;
import luxe.Vector;
import luxe.Sprite;

class PhysicsComponentBase extends Component {

	public var posReal: Vector;
	public var velocity: Vector = new Vector();
	public var damper: Float = 0.998;

	public var gravity: Float = 600;

	var sprite: Sprite;

	public function new() {
		super({
			name: 'physics'
		});
	}

	override function init() {
		posReal = pos.clone();
		sprite = cast entity;
	}

	override function update(dt: Float) {
		velocity.y += gravity * dt;
		velocity.x *= damper;

		posReal.x += velocity.x * dt;
		posReal.y += velocity.y * dt;

		if(posReal.y + sprite.size.y > Main.gameResolution.y) {
			posReal.y = Main.gameResolution.y - sprite.size.y;
			velocity.y = 0;
		}

		pos.x = Math.round(posReal.x);
		pos.y = Math.round(posReal.y);
	}
}
