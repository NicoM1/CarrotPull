package level;

import luxe.Sprite;
import luxe.Vector;
import player.Player;

import luxe.Draw;
import phoenix.BitmapFont;
import phoenix.geometry.TextGeometry;

import luxe.tween.Actuate;

class Bridge extends VisualObject {
	var slideDown: Bool = false;
	var slideUp = true;
	var slideSpeed: Float = 17.0;
	var triggered: Bool = false;

	var gaveBox = false;
	var inPlace = false;

	var originalPos: Vector;

	var button: VisualObject;

	var collider: CollisionObject;
	var bridgeSprite: VisualObject;

	/*var texts: Array<String> = [
		'it\'s hard to accept missed possibility.',
		'...',
		'that idea you always churned around',
		'that haunted you while you slept',
		'you\'ll never finish it.',
		'...',
		'the girl you locked eyes with on the train,',
		'with the deep brown hair.',
		'you\'ll never see her again.',
		'...',
		'the things you always mean\'t to tell him,',
		'before he left.',
		'they\'re worthless now.',
		''
	];*/

	/*var texts: Array<String> = [
		'how many times had she watched that movie?',
		'I\'m not even sure if she remembered\nthe first time she saw it.',
		'was it in the dirty, run-down,\ndrive-in excuse for a theater around the corner.',
		'or Jack\'s house, before his mom ran off,\nbefore he got fed up and skipped town.',
		'but this time was different,',
		'this time she stared into every backdrop,',
		'she found reflections of cameras in their eyes.'
	];*/

	public function new(position: Vector, depth: Float) {
		super('assets/images/bridge.png', position, new Vector(64, 15), 1);
		origin = new Vector(64,3);
		rotation_z = 90;
		originalPos = position.clone();
		dontSave = true;
		collider = Level.instance.addCollider(pos, new Vector(15,64));
		collider.dontSave = true;

		for(v in collider.collider.vertices) {
			v.x -= collider.width;
			v.y -= collider.height;
		}

		/*Luxe.events.listen('player.wrap.left', function(o: {object: Player}) {
			collider.collider.y += collider.height;
			pos.y += size.y;
		});

		Luxe.events.listen('player.wrap.right', function(o: {object: Player}) {
			collider.collider.y -= collider.height;
			pos.y -= size.y;
		});*/

		Luxe.events.listen('player.interact', function(o: {object: Player}) {
			if(Math.abs(o.object.pos.x - pos.x) > 10) return;

			Actuate.tween(collider.collider, 1, {rotation: -90});
			Actuate.tween(this, 1.5, {rotation_z: 0}).ease(luxe.tween.easing.Bounce.easeOut);
		});
	}

	override function editUpdate() {
		super.editUpdate();

		collider.collider.position.x = pos.x;
		collider.collider.position.y = pos.y;
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
