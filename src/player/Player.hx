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

		if(pos.x > 300) {
			pos.x = 0;
		}
		if(pos.x < 0) {
			pos.x = 300;
		}
		Luxe.camera.pos.x = pos.x*2 - Luxe.camera.viewport.w/2;
	}
}
