package player;

import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import luxe.Color;

import shared.PhysicsComponentBase;

class Player extends Sprite {

	var physics: PhysicsComponentBase;
	var mirrorSprite: Sprite;

	public function new(_pos: Vector) {
		super({
			name: 'player',
			pos: _pos,
			size: new Vector(19,31),
			centered: false,
			batcher: Main.sceneBatcher,
			depth: 0
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

	public function adjustMirrorSprite() {
		if(((pos.x < Main.wrapPoint && pos.x + size.x > Main.wrapPoint) || (pos.x < 0 && pos.x + size.x > 0))) {
			if(mirrorSprite == null) {
				mirrorSprite = new Sprite({
					batcher: Main.sceneBatcher,
					pos: new Vector(),
					texture: texture,
					size: size,
					centered: false
				});
				Main.leftBatcher.add(mirrorSprite.geometry);
				Main.rightBatcher.add(mirrorSprite.geometry);
				setMirrorPos();
			}
			else {
				setMirrorPos();
			}
		}
		else {
			if(mirrorSprite != null) {
				destroyMirrorSprite();
			}
		}
	}

	function setMirrorPos() {
		if(pos.x < Main.wrapPoint && pos.x + size.x > Main.wrapPoint) {
			mirrorSprite.pos.x = pos.x - Main.wrapPoint;
		}
		else if(pos.x < 0 && pos.x + size.x > 0) {
			mirrorSprite.pos.x = Main.wrapPoint + pos.x;
		}
		mirrorSprite.pos.y = pos.y;
		mirrorSprite.depth = depth;
	}

	override function destroy(?a) {
		super.destroy(a);
		if(mirrorSprite != null)
			destroyMirrorSprite();
	}

	function destroyMirrorSprite() {
		Main.leftBatcher.remove(mirrorSprite.geometry);
		Main.rightBatcher.remove(mirrorSprite.geometry);
		mirrorSprite.destroy();
		mirrorSprite = null;
	}
}
