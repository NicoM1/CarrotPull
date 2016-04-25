package player;

import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import luxe.Color;

import shared.PhysicsComponentBase;

class Player extends Sprite {

	var physics: PhysicsComponentBase;

	public function new(_pos: Vector) {
		super({
			name: 'player',
			pos: _pos,
			size: new Vector(19,31),
			centered: false,
			batcher: Main.sceneBatcher
		});
		physics = add(new PhysicsComponentBase(Std.int(size.x),Std.int(size.y)));
		//Main.rightBatcher.add(this.geometry);
		//Main.leftBatcher.add(this.geometry);
	}


	var s = 20;

	override function update(dt: Float) {
		//physics.velocity.x = 0;
		if(Luxe.input.keydown(Key.left)) {
			 physics.velocity.x = -s;
		}
		if(Luxe.input.keydown(Key.right)) {
			 physics.velocity.x = s;
		}
		if(physics.onGround() && Luxe.input.keypressed(Key.up)) {
			physics.velocity.y = -120;
		}

		if(pos.x > Main.wrapPoint) {
			pos.x = pos.x - Main.wrapPoint;
		}
		if(pos.x < 0) {
			pos.x = Main.wrapPoint + pos.x;
		}

		if(pos.y > 500) {
			pos.y = 0;
		}
	}
}
