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

class Main extends luxe.Game {

	var player: Sprite;
	var gameResolution: Vector = new Vector(160,90);
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

		player = new Sprite({
		   pos: Luxe.camera.center.clone(),
		   size: new Vector(11,11),
		   centered: false
	   	});
	   	new Sprite({
		  	pos: new Vector(),
			centered: false,
		  	size: new Vector(160,90),
			depth: -100,
			color: new Color(0.2,0.2,0.2)
	  	});
	   	x = player.pos.x;
	   	y = player.pos.y;
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

	var x: Float = 0;
	var y: Float = 0;
	var g = 600;
	var s = 40;
	var velocity: Vector = new Vector();
    override function update(dt:Float) {
		velocity.y += dt * g;
		if(Luxe.input.keydown(Key.left)) {
			x -= s*dt;
		}
		if(Luxe.input.keydown(Key.right)) {
			x += s*dt;
		}
		if(y + player.size.y >= gameResolution.y && Luxe.input.keypressed(Key.up)) {
			velocity.y = -200;
		}
		y += velocity.y * dt;
		if(y + player.size.y > gameResolution.y) {
			y = gameResolution.y - player.size.y;
			velocity.y = 0;
		}

		player.pos.x = Math.floor(x);
		player.pos.y = Math.floor(y);
    }

	var _transparent: Color = new Color(0,0,0,0);
	override function onrender() {
	}
}
