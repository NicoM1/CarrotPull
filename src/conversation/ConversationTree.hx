package conversation;

using StringTools;

import tjson.TJSON;

import luxe.Vector;
import luxe.Input;

import phoenix.geometry.TextGeometry;

class ConversationTree {
	var options: Array<String> = [];

	var convoIDs: Map<String, ConvoNode> = new Map();
	var values: Map<String, String> = new Map();

	var typeIndex = 0;

	var convo: ConvoNode;
	var curnode: ConvoNode;

	var curText: String = '';
	var curResponse: String = '';

	var lastTextGeom: TextGeometry;
	var lastResponseGeom: TextGeometry;

	public function new() {
		var convotext: String = '{
			speech: "
hello plant.
...
its uh, it\'s nice out today.
",
			responses: [{
				response: "
...
can you, can you grow today?."
				prompt: "
you\'re a dirtbag fuck off.
				",
				responses: [{
					response: "
don\'t be an asshole we were friends."
				}]
			}]}';

		convo = cast TJSON.parse(convotext);

		resetTypewriter();

		parseConvoIDs(convo);
		playConvo(convo);
	}

	function parseConvoIDs(convo: ConvoNode) {
		if(convo.id != null) {
			convoIDs[convo.id] = convo;
		}
		if(convo.responses != null) {
			for(r in convo.responses) {
				parseConvoIDs(r);
			}
		}
	}

	var continueTyping: Bool = true;
	public function update() {
		if(Luxe.input.keypressed(Key.space)) {
			if(continueTyping == false) {
				continueTyping = true;
				return;
			}
		}
		if(curnode != null && curnode.responses != null) {
			var responded = false;
			if(curnode.responses.length == 1) {
				if(Luxe.input.keypressed(Key.space)) {
					playConvo(curnode.responses[0]);
					responded = true;
				}
			}
			if(Luxe.input.keypressed(Key.key_1)) {
				playConvo(curnode.responses[0]);
				responded = true;
			}
			if(Luxe.input.keypressed(Key.key_1)) {
				playConvo(curnode.responses[0]);
				responded = true;
			}
			if(Luxe.input.keypressed(Key.key_2)) {
				playConvo(curnode.responses[1]);
				responded = true;
			}
			if(responded) {
				lastResponseGeom.drop(true);
			}
		}
	}

	function playConvo(convo: ConvoNode, ?ignoreVals: Bool = false) {
		resetTypewriter();
		curnode = convo;
		if(!ignoreVals) {
			if(curnode.setVal != null) {
				for(s in curnode.setVal) {
					values[s.k] = s.v;
				}
				trace(values);
			}
		}
		if(curnode.switchTo != null) {
			if(convoIDs[curnode.switchTo] != null) {
				playConvo(convoIDs[curnode.switchTo], true);
				return;
			}
			else {
				throw "convoid: " + "'" + curnode.switchTo + "'" + " not defined.";
			}
		}
		if(curnode.responses != null) {
			/*for(i in 0...curnode.responses.length) {
				options[i].onclick = function() {
					playConvo(curnode.responses[i]);
					return;
				}
			}
			if(options.length > curnode.responses.length) {
				for(i in curnode.responses.length...options.length) {
					options[i].style.display = 'none';
				}
			}*/
		}
		if(curnode.prompt != null) {
			typeLetters(replaceText(curnode.prompt), function() {
				playResponses(curnode);
			}, ++typeIndex);
		}
		else if(curnode.speech != null) {
			typeLetters(true, replaceText(curnode.speech), function() {
				playResponses(curnode);
			}, ++typeIndex);
		}
	}

	function playResponses(convo: ConvoNode, ?index: Int = 0) {
		if(convo.responses == null || index >= convo.responses.length) {
			return;
		}
		typeLetters(true, convo.responses[index].response, playResponses.bind(convo, ++index), ++typeIndex);
	}

	function typeLetters(?response: Bool = false, message: String, ?onComplete: Void -> Void, ?curIndex: Int = null) {
		if(curIndex != null) {
			if(curIndex != typeIndex) return;
		}
		if(continueTyping) {
			if(message.length == 0) {
				onComplete();
				return;
			}
			if(!response) {
				curText += message.charAt(0);
				if(message.charAt(0) == '\n') {
					continueTyping = false;
				}
				if(lastTextGeom != null)
					lastTextGeom.drop(true);
				lastTextGeom = Luxe.draw.text({
					pos: new Vector(10, Main.gameResolution.y - 30),
					immediate: false,
					point_size: 3,
					text: curText
				});
			}
			else {
				curResponse += message.charAt(0);
				if(message.charAt(0) == '\n') {
					continueTyping = false;
				}
				if(lastResponseGeom != null)
					lastResponseGeom.drop(true);
					lastResponseGeom = Luxe.draw.text({
					pos: new Vector(Main.gameResolution.x - 50, Main.gameResolution.y - 30),
					immediate: false,
					point_size: 3,
					text: curResponse
				});
			}
			message = message.substr(1);
		}
		Luxe.timer.schedule(0.050 + Math.random()*0.020, typeLetters.bind(response, message, onComplete, curIndex));
	}

	function replaceText(text: String): String {
		text = text.trim();
		var replaceEReg: EReg = ~/\*\((.*?)\)\*/;
		if(replaceEReg.match(text)) {
			trace(replaceEReg.matched(0));
			text = replaceEReg.replace(text, values[replaceEReg.matched(1)]);
		}
		return text;
	}

	function resetTypewriter() {
		curText = '';
		curResponse = '';
	}
}

typedef ConvoNode = {
	?prompt: String,
	?response: String,
	?speech: String,
	?responses: Array<ConvoNode>,
	?id: String,
	?switchTo: String,
	?setVal: Array<{k: String, v: String}>
}
