package level;

import luxe.Sprite;
import luxe.Vector;
import luxe.Input;

import phoenix.Texture;

class VisualObject extends Sprite implements EditableObject {
	public var texturePath(default, null): String;

	var dragging: Bool = false;

	public function new(texturePath: String, pos: Vector, size: Vector, depth: Float) {
		super({
			name: texturePath,
			name_unique: true,
			pos: pos,
			centered: false,
			texture: Luxe.resources.texture(texturePath),
			size: size,
			depth: depth
		});
		texture.filter_mag = FilterType.nearest;

		this.texturePath = texturePath;
	}

	var tmpVector: Vector = new Vector();
	var tmpVector1: Vector = new Vector();
	public function editUpdate() {
		if(Level.instance.selected == null || Level.instance.selected == this) {
			tmpVector1.set_xy(pos.x+size.x/2, pos.y+size.y/2);
			Luxe.draw.ring({
				x: tmpVector1.x,
				y: tmpVector1.y,
				r: 3,
				immediate: true,
				depth: 1000
			});

			tmpVector.x = Luxe.screen.cursor.pos.x;
			tmpVector.y = Luxe.screen.cursor.pos.y;
			tmpVector = Luxe.camera.screen_point_to_world(tmpVector);

			if(Luxe.input.mousepressed(1)) {
				if(!dragging && tmpVector1.subtract(tmpVector).length <= 3) {
					dragging = true;
				}
			}
			if(Luxe.input.mousedown(1)) {
				if(dragging) {
					Level.instance.changed = true;
					if(Luxe.input.keypressed(Key.comma)) {
						depth -= 0.00001;
					}
					if(Luxe.input.keypressed(Key.period)) {
						depth += 0.00001;
					}
					if(Luxe.input.keypressed(Key.key_x)) {
						Level.instance.toDestroy.push(this);
						return;
					}
					Level.instance.selected = this;

					pos.x = Math.round(tmpVector.x - size.x/2);
					pos.y = Math.round(tmpVector.y - size.y/2);
				}
			}
			else {
				dragging = false;
				Level.instance.selected = null;
			}
		}
	}

	public function destroyObject() {
		destroy();
	}
}
