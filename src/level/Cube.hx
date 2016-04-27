package level;

import luxe.Vector;
import player.Player;

class Cube extends VisualObject {
	var slideDown: Bool = false;
	var slideSpeed: Float = 33.0;
	var triggered: Bool = false;

	public function new(pos: Vector, depth: Float) {
		super('assets/images/worldWrap128x64_7.png', pos, new Vector(128,64), depth);
		dontSave = true;
		Luxe.events.listen('player.interact', function(o: {object: Player}) {
			if(Math.abs((pos.x + size.x/2) - (o.object.pos.x + o.object.size.x/2)) < 30) {
				texture = Luxe.resources.texture('assets/images/worldWrap128x64_8.png');
				triggered = true;
			}
		});
		Luxe.events.listen('player.wrap.*', function(o: {object: Player}) {
			if(triggered) {
				slideDown = true;
			}
		});
	}

	override function update(dt: Float) {
		super.update(dt);
		if(pos.y <= Main.gameResolution.y - 80 && slideDown) {
			pos.y += slideSpeed * dt * ((Main.gameResolution.y - 80 - pos.y)/80);
			adjustMirrorSprite();
		}
	}
}
