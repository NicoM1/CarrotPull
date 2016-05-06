package level;

import luxe.Vector;
import luxe.Input;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

class CollisionObject implements EditableObject {
	public var collider(default, null): Polygon;

	public var dontSave: Bool = false;

	public var width: Int;
	public var height: Int;

	var dragging: Bool = false;
	var resizing: Bool = false;

	var lastX: Float = 0;
	var lastY: Float = 0;

	public function new(x: Int, y: Int, width: Int, height: Int, ?vertices: Array<Vector>) {
		this.width = width;
		this.height = height;

		if(vertices == null) {
			collider = Polygon.rectangle(x, y, width, height, false);
		}
		else {
			collider = new Polygon(x, y, vertices);
		}
	}


	var tmpVector: Vector = new Vector();
	var tmpVector1: Vector = new Vector();
	public function update() {
		Main.shapeDrawer.drawShape(collider);

		if(Level.instance.selected == null || Level.instance.selected == this) {
			tmpVector1.set_xy(collider.x+width/2, collider.y+height/2);
			Luxe.draw.ring({
				x: tmpVector1.x,
				y: tmpVector1.y,
				r: 3,
				immediate: true,
				depth: 1000,
				batcher: Main.sceneBatcher
			});

			tmpVector.x = Luxe.screen.cursor.pos.x;
			tmpVector.y = Luxe.screen.cursor.pos.y;
			tmpVector = Main.screen_point_to_world(tmpVector);

			if(Luxe.input.mousepressed(1)) {
				if(!dragging && tmpVector1.subtract(tmpVector).length <= 3) {
					dragging = true;
				}
				else if(!resizing && Math.abs((tmpVector.x) - (collider.x + width)) < 5 && Math.abs(tmpVector.y - (collider.y + height)) < 5) {
					resizing = true;
					lastX = tmpVector.x;
					lastY = tmpVector.y;
				}
			}
			if(Luxe.input.mousedown(1)) {
				if(dragging) {
					Level.instance.changed = true;
					if(Luxe.input.keypressed(Key.key_x)) {
						Level.instance.toDestroy.push(this);
						return;
					}
					Level.instance.selected = this;

					collider.x = Math.round(tmpVector.x - width/2);
					collider.y = Math.round(tmpVector.y - height/2);
				}
				else if(resizing) {
					Level.instance.changed = true;
					Level.instance.selected = this;
					width -= Math.round(lastX) - Math.round(tmpVector.x);
					height -= Math.round(lastY) - Math.round(tmpVector.y);
					collider.vertices[1].x = width;
					collider.vertices[2].x = width;
					collider.vertices[3].y = height;
					collider.vertices[2].y = height;
					collider.x += 0;
					lastX = tmpVector.x;
					lastY = tmpVector.y;
				}
			}
			else {
				dragging = false;
				resizing = false;
				Level.instance.selected = null;
			}
		}
	}

	public function destroyObject() {
		collider.destroy();
	}
}
