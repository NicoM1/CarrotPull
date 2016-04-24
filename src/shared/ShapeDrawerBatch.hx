package shared;

import luxe.collision.ShapeDrawer;
import luxe.collision.shapes.Circle;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;

import luxe.Vector;
import luxe.Color;
import phoenix.Batcher;

class ShapeDrawerBatch {

	var _batcher: Batcher;

	public function new(?batcher_: Batcher) {
		_batcher = batcher_;
	}

	public function setBatcher(batcher: Batcher) {
		_batcher = batcher;
	}

	        /** Draw a `Shape`, it will determine the type and draw it for you. */
    public function drawShape( shape:Shape, ?color:Color, ?immediate:Bool = true ) {

        if(Std.is(shape, Polygon)) {
            drawPolygon(cast(shape, Polygon), color, immediate);
            return;
        } else { //circle
            drawCircle(cast(shape, Circle), color, immediate);
            return;
        }

    } //drawShape

        /** Draw a `Polygon` */
    public function drawPolygon( poly:Polygon, ?color:Color, ?immediate:Bool = false ) {

        var v : Array<Vector> = poly.transformedVertices.copy();

        drawVertList( v, color, immediate );

    } //drawPolygon

        /** Draw a `Vector` (with magnitude) */
    public function drawVector( v:Vector, start:Vector, ?color:Color, ?immediate:Bool = false  ) {

        drawLine( start, v, color, immediate );

    } //drawVector

        /** Draw a circle `Shape` */
    public function drawCircle( circle:Circle, ?color:Color, ?immediate:Bool = false ) {

            //now draw it
        Luxe.draw.ring({
        	x: circle.x,
        	y: circle.y,
        	r: circle.transformedRadius,
        	color: color,
        	immediate: immediate,
        	batcher: _batcher
        });

    } //drawCircle


//Internal API


        /** Draw a list of points as lines */
    function drawVertList( _verts : Array<Vector>, ?color:Color, ?immediate:Bool = false ) {

        var _count : Int = _verts.length;
        if(_count < 3) {
            throw "cannot draw polygon with < 3 verts as this is a line or a point.";
        }

            //start at one, and draw from 1 to 0 (backward)
        for(i in 1 ... _count) {
            drawLine( _verts[i], _verts[i-1], color, immediate );
        }

            //finish the polygon by drawing the final point to the first point
        drawLine( _verts[_count-1], _verts[0], color, immediate );

    } //drawVertList

    public function drawLine( start:Vector, end:Vector, ?color:Color, ?immediate:Bool = false) {

        if(color == null) {
            color = new Color().rgb(0xff4b03);
        }

        Luxe.draw.line({
            p0 : start,
            p1 : end,
            color : color,
            depth : 20,
            immediate : immediate,
            batcher: _batcher
        });

    }

}
