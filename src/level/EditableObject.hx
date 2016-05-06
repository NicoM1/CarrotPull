package level;

import luxe.Vector;

interface EditableObject {
	var dontSave: Bool;
	function destroyObject(): Void;
}
