package level;

import luxe.Vector;
import luxe.tween.Actuate;

class SetPiece extends VisualObject {
	var loop: Int;
	var wraps: Int = 0;
	var originalPos: Vector;
	public function new(texture: String, pos: Vector, size: Vector, depth: Float, showOn: Int, currentWraps: Int) {
		depth = -100;
		super(texture, pos, size, depth);

		originalPos = pos.clone();
		pos.y += 200;

		visible = false;

		loop = showOn;

		wraps = currentWraps;

		handleWrap();
		Luxe.events.listen('player.wrap.*', function(o: {wraps: Int}) {
			this.wraps = o.wraps;
			inProgressUp = false;
			inProgressDown = false;
		});
	}

	override function update(dt) {
		handleWrap();
	}

	var inProgressDown: Bool = false;
	var inProgressUp: Bool = false;

	function handleWrap() {
		if(doDisplay(wraps)) {
			visible = true;
			if(pos.y != originalPos.y && !inProgressUp) {
				inProgressUp = true;
				Actuate.tween(pos, 1, {y: originalPos.y}).onComplete(function() {
					inProgressUp = false;
				});
			}
		}
		else {
			if(pos.y != originalPos.y + 200 && !inProgressDown) {
				inProgressDown = true;
				Actuate.tween(pos, 1, {y: originalPos.y + 200}).onComplete(function() {
					inProgressDown = false;
					visible = false;
				});
			}
			if(!inProgressDown) {
				visible = false;
			}
		}
		/*if(doDisplay(wraps)) {
			visible = true;
			/*var finalPos: Vector = pos.clone();
			pos.y += size.y;
			Actuate.tween(pos, 1, {y: finalPos});
		}
		else {
			trace(pos.x);
			trace(Main.sceneCamera.pos.x - Main.gameResolution.x/2);
			var doNot: Int = 0;
			if(pos.x + 14 < Main.sceneCamera.pos.x - Main.gameResolution.x/2 || pos.x > Main.sceneCamera.pos.x + Main.gameResolution.x/2) {
				doNot++;
			}
			if(-pos.x + 14 < Main.sceneCamera.pos.x - Main.gameResolution.x/2 || pos.x + Main.wrapPoint > Main.sceneCamera.pos.x + Main.gameResolution.x/2) {
				doNot++;
			}
			if(doNot == 2){
				visible = false;
			}
		}*/
	}

	///call to determine if should be shown this loop
	function doDisplay(wrapTimes: Int): Bool {
		if(wrapTimes == loop) {
			return true;
		}
		return false;
	}
}
