package player;

import luxe.Sprite;
import luxe.Vector;
import luxe.Input;

import shared.PhysicsComponentBase;

class Player extends Sprite {

	var physics: PhysicsComponentBase;

	public function new(_pos: Vector) {
		super({
			name: 'player',
			pos: _pos,
			size: new Vector(11,11),
			centered: false
		});
		physics = add(new PhysicsComponentBase());
	}


	var s = 40;

	override function update(dt: Float) {
		//physics.velocity.x = 0;
		if(Luxe.input.keydown(Key.left)) {
			 physics.velocity.x = -s;
		}
		if(Luxe.input.keydown(Key.right)) {
			 physics.velocity.x = s;
		}
		if(physics.posReal.y + size.y >= Main.gameResolution.y && Luxe.input.keypressed(Key.up)) {
			physics.velocity.y = -200;
		}
	}
}
