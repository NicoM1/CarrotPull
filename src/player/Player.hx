package player;

import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import luxe.Color;

import shared.PhysicsComponentBase;

import level.VisualObject;

class Player extends Sprite {

	var physics: PhysicsComponentBase;
	var mirrorSprite: Sprite;

	var boxSprite: VisualObject;

	var paused: Bool = false;

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
		physics.afterMovement = function() {
			Main.sceneCamera.pos.x = pos.x -Main.gameResolution.x/2;
			Main.sceneCamera.pos.y = pos.y -Main.gameResolution.y/2;
			if(boxSprite != null) {
				boxSprite.pos.copy_from(pos);
				boxSprite.adjustWrapping();
			}
		}
		//Main.rightBatcher.add(this.geometry);
		//Main.leftBatcher.add(this.geometry);

		Luxe.events.listen('text.show', function(e) {paused = true;});
		Luxe.events.listen('text.hide', function(e) {paused = false;});
	}

	public function gotBox() {
		boxSprite = new VisualObject('assets/images/worldWrap128x64_9.png', pos, new Vector(128,64), 1);
		boxSprite.dontSave = true;
	}

	public function lostBox() {
		boxSprite.destroyObject();
		boxSprite = null;
	}


	var s = 20;

	override function update(dt: Float) {
		if(Luxe.input.keypressed(Key.key_e) || Luxe.input.keypressed(Key.rctrl) || Luxe.input.keypressed(Key.rctrl)) {
			Luxe.events.fire('player.interact', {object: this});
		}
		if(paused) return;
		//physics.velocity.x = 0;
		if(Luxe.input.keydown(Key.left) || Luxe.input.keydown(Key.key_a)) {
			 physics.velocity.x = -s;
		}
		if(Luxe.input.keydown(Key.right) || Luxe.input.keydown(Key.key_d)) {
			 physics.velocity.x = s;
		}
		if(physics.onGround() && (Luxe.input.keypressed(Key.up) || Luxe.input.keypressed(Key.key_w) || Luxe.input.keypressed(Key.space))) {
			physics.velocity.y = -120;
		}

		if(pos.x > Main.wrapPoint) {
			Luxe.events.fire('player.wrap.right', {object: this});
			pos.x = pos.x - Main.wrapPoint;
		}
		if(pos.x < 0) {
			Luxe.events.fire('player.wrap.left', {object: this});
			pos.x = Main.wrapPoint + pos.x;
		}

		if(pos.y > 500) {
			pos.y = 0;
		}
	}

	public function adjustMirrorSprite() {
		if(((pos.x <= Main.wrapPoint && pos.x + size.x > Main.wrapPoint) || (pos.x < 0 && pos.x + size.x > 0))) {
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
