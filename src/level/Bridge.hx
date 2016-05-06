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

	var texts: Array<String> = [
		'I went to the park today. Sat down on the bench. The bench we played on as kids, where you would pocket crusts of picnic sandwiches to feed the geese while our parent’s backs were turned. Where you leaned in too close and got that little diamond scar that follows the base of your jaw.',

		'I\'m sure that scar has faded now.',

		'Tim died a few weeks ago, although you would be hard pressed to find someone who didn\'t think he\'d just been savouring his last breath for the past decade.',

		'Your letters feel so impersonal. I don’t want to hear how well school is going. I want to hear about the pretty walk you took the other day, or that annoying patch of dry skin that keeps being worn raw despite every attempt at the right shoe/sock combination.',

		'I saw your mom yesterday. She smiled when she spoke of you but her eyes were sad.',

		'Please come home soon.',

		'I still hike to the cliffs, taste sharp fear as I shuffle closer. I\'ll always take the easier way, but fear still rises. These cliffs have claimed one too many, one too young.',

		'I still sneak onto the waterfront lawns of those so rich they can afford a million dollar home just to lounge about for a week or two every summer. Those who exist solely to make it impossible for us to.',

		'The people here, the people that have watched me grow up, now give me long looks. As if wondering if I\'ll ever move on from here.',

		'I found an apartment, the rent is good and the roommates are my age.',

		'I think it\'s time to leave.'
	];

	var lastText: TextGeometry;

	var textPos: Int = 0;

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
			if(lastText != null) lastText.drop(true);
			/*lastText = Luxe.draw.text({
				batcher: Main.sceneBatcher,
				pos: {var posInt = pos.clone(); posInt.int(); posInt;},
				point_size: 12,
				text: texts[textPos],
				smoothness: 0,
				align: TextAlign.center,
				align_vertical: TextAlign.top
			});*/
			textPos++;

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
