package ;

import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.Camera;
import luxe.Screen;

import phoenix.RenderTexture;
import phoenix.Batcher;
import phoenix.Shader;
import phoenix.Texture;

import player.Player;

class Main extends luxe.Game {

	var player: Sprite;
	public static var gameResolution: Vector = new Vector(160,90);
	var zoom: Int = 4;

    override function config(config:luxe.AppConfig) {

		config.window.width = Math.floor(gameResolution.x * zoom);
		config.window.height = Math.floor(gameResolution.y * zoom);
        return config;

    }

    override function ready() {
		Texture.default_filter = FilterType.nearest;
		Luxe.renderer.clear_color = new Color(0,0,0);

		setupScreen();
		setupBorders();

		player = new Player(Luxe.camera.center.clone());
	   	new Sprite({
		  	pos: new Vector(),
			centered: false,
		  	size: new Vector(160,90),
			depth: -100,
			color: new Color(0.2,0.2,0.2)
	  	});
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    }

	override function onwindowsized(e: WindowEvent) {
		setupScreen();
	}

	function setupScreen() {
		Luxe.camera.size = new Vector(gameResolution.x, gameResolution.y);
		Luxe.camera.viewport.set(0, 0, Luxe.screen.w, Luxe.screen.h);
	}

	function setupBorders() {
		new Sprite({
			centered: false,
			pos: new Vector(gameResolution.x, -500),
			size: new Vector(1000, gameResolution.y+1000),
			color: new Color(0,0,0),
			depth: 1000
		});

		new Sprite({
			centered: false,
			pos: new Vector(-1000, -500),
			size: new Vector(1000, gameResolution.y+1000),
			color: new Color(0,0,0),
			depth: 1000
		});

		new Sprite({
			centered: false,
			pos: new Vector(0, -1000),
			size: new Vector(gameResolution.x, 1000),
			color: new Color(0,0,0),
			depth: 1000
		});

		new Sprite({
			centered: false,
			pos: new Vector(0, gameResolution.y),
			size: new Vector(gameResolution.x, 1000),
			color: new Color(0,0,0),
			depth: 1000
		});
	}

    override function update(dt:Float) {
    }

	var _transparent: Color = new Color(0,0,0,0);
	override function onrender() {
	}
}
