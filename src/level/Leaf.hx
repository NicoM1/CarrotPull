package level;

import luxe.Sprite;
import luxe.Vector;
import player.Player;

import luxe.Draw;
import phoenix.BitmapFont;
import phoenix.geometry.TextGeometry;

import luxe.tween.Actuate;

class Leaf extends VisualObject {

	public function new(position: Vector) {
		super('assets/images/note.png', position, new Vector(14, 22), 1);
		dontSave = true;
	}

	override function editUpdate() {

	}

	var lastVelX: Float = 0;
	var lastVelY: Float = 0;
	override function update(dt: Float) {
		if(Math.round(Luxe.time) % 5 == 0) {
			lastVelX = 23 + Luxe.utils.random.float(-5, 5);
			lastVelY = 5 * Luxe.utils.random.float(-2, 2.5);
		}
		super.update(dt);
		pos.x += lastVelX * dt;
		pos.y += lastVelY * dt;
		if(pos.x > Main.wrapPoint) {
			pos.x = pos.x - Main.wrapPoint;
		}
		if(pos.x < 0) {
			pos.x = Main.wrapPoint + pos.x;
		}
		if(pos.y > 173) {
			pos.y = 173;
			lastVelY = 0;
		}
	}
}
