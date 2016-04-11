package shared;

import sys.io.File;

class Util {
	public static function saveFile(data: String, path: String): Bool {
		try {
			File.saveContent(path, data);
		}
		catch(e: Dynamic) {
			return false;
		}
		return true;
	}

	public static function loadFile(path: String) : String {
		try {
			return File.getContent(path);
		}
		catch(e: Dynamic) {
			return null;
		}
	}
}
