package ;

import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.Camera;
import luxe.Screen;

import luxe.collision.ShapeDrawerLuxe;

import phoenix.RenderTexture;
import phoenix.Batcher;
import phoenix.Shader;
import phoenix.Texture;

import player.Player;
import level.Level;

import mint.Control;
import mint.types.Types;
import mint.render.luxe.LuxeMintRender;
import mint.render.luxe.Convert;
import mint.layout.margins.Margins;
import mint.focus.Focus;
import mint.Canvas;

import dialogs.Dialogs;

import sdl.SDL;

class Main extends luxe.Game {

	var player: Sprite;
	public static var gameResolution: Vector = new Vector(160,90);
	var zoom: Int = 4;

	public static var shapeDrawer: ShapeDrawerLuxe = new ShapeDrawerLuxe();

	public static var canvas: Canvas;
	public static var rendering: LuxeMintRender;
	public static var layout: Margins;
	public static var focus: Focus;

	var UIBatcher: Batcher;
	var UICamera: Camera;

    override function config(config:luxe.AppConfig) {

		config.window.width = Math.floor(gameResolution.x * zoom);
		config.window.height = Math.floor(gameResolution.y * zoom);

		config.window.title = 'why not just fucking talk to plants';

		config.preload.textures.push({id: 'assets/images/plant.png'});
		config.preload.textures.push({id: 'assets/images/carrot.png'});
		config.preload.textures.push({id: 'assets/images/ground.png'});
		config.preload.textures.push({id: 'assets/images/grass.png'});
		config.preload.textures.push({id: 'assets/images/rocks.png'});
        return config;

    }

    override function ready() {
		Texture.default_filter = FilterType.nearest;
		Luxe.renderer.clear_color = new Color(0,0,0);

		setupUI();
		setupScreen();
		setupBorders();

		new Level();
		player = new Player(new Vector(60,10));
	   	new Sprite({
		  	pos: new Vector(),
			centered: false,
		  	size: new Vector(160,90),
			depth: -100,
			color: new Color(0.2,0.2,0.2)
	  	});
    }

    /*override function onkeyup( e: KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    }*/

	override function onwindowsized(e: WindowEvent) {
		setupScreen();
	}

	function setupScreen() {
		Luxe.camera.size = new Vector(gameResolution.x, gameResolution.y);
		Luxe.camera.viewport.set(0, 0, Luxe.screen.w, Luxe.screen.h);
		UICamera.viewport = new luxe.Rectangle(0, 0, Luxe.screen.w, Luxe.screen.h);
		canvas.set_size(Luxe.screen.w, Luxe.screen.h);
	}

	function setupUI() {
		UICamera = new Camera();
		UIBatcher = Luxe.renderer.create_batcher({
            name: 'uibatcher',
            no_add: false,
            camera: UICamera.view
        });

		rendering = new LuxeMintRender();
		rendering.options.depth = 1000;
		rendering.options.batcher = UIBatcher;
		layout = new Margins();

		var auto_canvas = new AutoCanvas({
            name:'canvas',
            rendering: rendering,
            options: { color:new Color(1,1,1,0.0) },
            x: 0, y:0, w: 960, h: 640
        });

		auto_canvas.auto_listen();
		canvas = auto_canvas;

		focus = new Focus(canvas);
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

	override function ondestroy() {
		if(Level.instance.changed)
			SDL.showSimpleMessageBox(SDLMessageBoxFlags.SDL_MESSAGEBOX_ERROR, 'quit without saving?', 'are you sure you wish to quit?', Luxe.snow.runtime.window);

		for(e in Luxe.scene.entities) {
			e.destroy();
		}
    }
}
