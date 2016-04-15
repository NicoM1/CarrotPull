package shared;

import sys.io.File;

import haxe.io.Path;

using StringTools;

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

	public static function loadFile(path: String): String {
		try {
			return File.getContent(path);
		}
		catch(e: Dynamic) {
			return null;
		}
	}

	public static function getRelativePath(path: String): String {
		if(path.charAt(1) != ':') return path;
		path = Path.normalize(path).toLowerCase();
		var exePath: String = Path.normalize(Path.directory(Sys.executablePath()).toLowerCase());

		var pathBlocks: Array<String> = path.split('/');
		var exeBlocks: Array<String> = exePath.split('/');

		if(pathBlocks.length > exeBlocks.length) {
			return path.replace(exePath + '/', '');
		}
		var i: Int = 0;
		while(i < pathBlocks.length) {
			if(pathBlocks[i] != exeBlocks[i]) {
				break;
			}
			i++;
		}
		var numBack = exeBlocks.length - i;
		var final: String = '';
		for(j in 0...numBack) {
			final += '../';
		}
		for(x in i...pathBlocks.length) {
			final += pathBlocks[i];
		}

		return final;
	}

	public static function getAbsolutePath(path: String): String {
		if(path.charAt(1) == ':') return path;
		path = Path.normalize(path).toLowerCase();
		var exePath: String = Path.normalize(Path.directory(Sys.executablePath()).toLowerCase());

		var pathBlocks: Array<String> = path.split('/');
		var exeBlocks: Array<String> = exePath.split('/');

		var removeCount: Int = 0;

		for(p in pathBlocks) {
			if(p == '..') {
				exeBlocks.splice(exeBlocks.length - 1, 1);
				removeCount++;
			}
		}

		pathBlocks.splice(0, removeCount);

		return exeBlocks.join('/') + '/' + pathBlocks.join('/');
	}

	//LEAVING THIS TO SHOW HOW FUCKING MESSY IT WAS
	/*public static function getRelativePath(path: String): String {
		path = Path.normalize(path).toLowerCase();
		var exePath = Path.normalize(Path.directory(Sys.executablePath()).toLowerCase());

		var pathblocks: Int;
		for(i in 0...path.length) {
			if(i )
		}

		if(path.length < exePath.length) {
			var i: Int = 0;
			var lastChar: String = '';
			while(i < path.length) {
				if(lastChar == '/') {
					trace(path.charAt(i), exePath.charAt(i));
				}
				if(lastChar == '/') {
					var xx = i;
					var block: String = '';
					while(xx <= path.length){
						if(xx == path.length || path.charAt(xx) == '/') {
							break;
						}
						block += path.charAt(i);
						xx++;
					}
					var exeblock: String = '';
					xx = i;
					while(xx <= exePath.length){
						if(xx == exePath.length || exePath.charAt(xx) == '/') {
							break;
						}
						exeblock += exePath.charAt(i);
						xx++;
					}
					if(exeblock != block) {
						break;
					}
				}
				lastChar = path.charAt(i);
				i++;
			}
			var x: Int = exePath.length - 1;
			var numBack: Int = 0;
			while(x > i) {
				if(exePath.charAt(x) == '/') {
					numBack++;
				}
				x--;
			}
			numBack += 1;
			var final: String = '';
			for(j in 0...numBack) {
				final += '../';
			}
			trace(path, i);
			final += path.substr(i);
			return final;
		}
		else {
			trace(exePath);
			return path.replace(exePath, '');
		}
		return '';
	}*/
}
