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

	public function new(pos: Vector, depth: Float) {
		super('assets/images/worldWrap128x64_7.png', pos, new Vector(128,64), depth);
		originalPos = pos.clone();
		dontSave = true;
		Luxe.events.listen('player.interact', function(o: {object: Player}) {
			if(Math.abs((pos.x + size.x/2) - (o.object.pos.x + o.object.size.x/2)) < 30) {
				if(!gaveBox) {
					texture = Luxe.resources.texture('assets/images/worldWrap128x64_10.png');
					setMirrorPos();
					o.object.gotBox();
					gaveBox = true;
				}
				else if(!inPlace) {
					texture = Luxe.resources.texture('assets/images/worldWrap128x64_7.png');
					o.object.lostBox();
					setMirrorPos();
					inPlace = true;
				}
				else {
					texture = Luxe.resources.texture('assets/images/worldWrap128x64_8.png');
					triggered = true;
				}
			}
		});
		Luxe.events.listen('player.wrap.*', function(o: {object: Player}) {
			if(triggered && !slideDown) {
				slideDown = true;
			}
			else if(slideDown) {
				texture = Luxe.resources.texture('assets/images/worldWrap128x64_4.png');
				mirrorSprite.texture = texture;
				slideDown = false;
				slideUp = true;
			}
		});
	}

	override function update(dt: Float) {
		super.update(dt);
		if(pos.y <= Main.gameResolution.y - 80 && slideDown) {
			pos.y += slideSpeed * dt;
			adjustMirrorSprite();
		}
		else if(slideUp && pos.y > originalPos.y) {
			pos.y -= slideSpeed * dt;
			adjustMirrorSprite();
		}
	}
}
