package ui;

import mint.Control;
import mint.Label;

import mint.types.Types;
import mint.core.Signal;
import mint.core.Macros.*;

class Window extends mint.Window {
	public override function mousedown(e: MouseEvent)  {

        //if(close_button.contains(e.x, e.y) && closable) return;
        //if(collapse_handle.contains(e.x, e.y) && collapsible) return;

		for(c in children) {
			if(c == title) continue;
			if(c.visible && c.contains(e.x, e.y)) return;
		}

		var in_title = title.contains(e.x, e.y);

        if(!in_title) {
            super.mousedown(e);
        }

        if(focusable) canvas.bring_to_front(this);

            if(!dragging && moveable) {
                if( in_title ) {
                    dragging = true;
                    drag_x = e.x;
                    drag_y = e.y;
                    focus();
                } //if inside title bounds
            } //!dragging

    } //onmousedown
}
