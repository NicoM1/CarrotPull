package plants;

import luxe.Sprite;
import luxe.Vector;

class Plant extends Sprite {

	public function new(name: String, pos: Vector) {
		super({
			name_unique: true,
			name: name,
			pos: pos,
			centered: false
		});
	}
}
