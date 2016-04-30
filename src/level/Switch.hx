package level;

import luxe.Vector;

class Switch extends VisualObject {
	public function new(pos: Vector) {
		super(null, pos, new Vector(10,10),-1);
		dontSave = true;
	}
}
