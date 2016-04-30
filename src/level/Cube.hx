package level;

import luxe.Sprite;
import luxe.Vector;
import player.Player;

class Cube extends VisualObject {
	var slideDown: Bool = false;
	var slideUp = true;
	var slideSpeed: Float = 17.0;
	var triggered: Bool = false;

	var gaveBox = false;
	var inPlace = false;

	var originalPos: Vector;

	var button: VisualObject;

	var collider: CollisionObject;

	public function new(position: Vector, depth: Float) {
		super('assets/images/worldWrap128x64_7.png', position, new Vector(128,64), depth);
		originalPos = position.clone();
		dontSave = true;
		collider = Level.instance.addCollider(new Vector(pos.x + 54, pos.y), new Vector(15,64));

		Luxe.events.listen('player.wrap.left', function(o: {object: Player}) {
			collider.collider.y += collider.height;
			pos.y += size.y;
		});

		Luxe.events.listen('player.wrap.right', function(o: {object: Player}) {
			collider.collider.y -= collider.height;
			pos.y -= size.y;
		});
	}

	override function update(dt: Float) {
		super.update(dt);
		/*if(pos.y <= Main.gameResolution.y - 80 && slideDown) {
			pos.y += slideSpeed * dt;
			adjustMirrorSprite();
		}
		else if(slideUp && pos.y > originalPos.y) {
			pos.y -= slideSpeed * dt;
			adjustMirrorSprite();
		}
		if(inPlace && button.pos.y > pos.y) {
			button.pos.y -= slideSpeed * dt;
		}*/
	}
}
