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

import shared.ShapeDrawerBatch;

import sdl.SDL;

class Main extends luxe.Game {

	var player: Sprite;
	public static var gameResolution: Vector = new Vector(512,256);
	static var zoom: Int = 2;

	public static var shapeDrawer: ShapeDrawerBatch = new ShapeDrawerBatch();

	public static var canvas: Canvas;
	public static var rendering: LuxeMintRender;
	public static var layout: Margins;
	public static var focus: Focus;

	var UIBatcher: Batcher;
	var UICamera: Camera;

	var sceneView: RenderTexture;
	var sceneSprite: Sprite;
	var sceneCamera: Camera;
	public static var sceneBatcher: Batcher;

	var rightView: RenderTexture;
	var rightSprite: Sprite;
	var rightCamera: Camera;
	public static var rightBatcher: Batcher;

	var leftView: RenderTexture;
	var leftSprite: Sprite;
	var leftCamera: Camera;
	public static var leftBatcher: Batcher;

	public static var wrapPoint(default, null): Int = 300;

    override function config(config:luxe.AppConfig) {
		config.window.resizable = false;
		config.window.borderless = true;
		config.window.width = Math.floor(gameResolution.x * zoom);
		config.window.height = Math.floor(gameResolution.y * zoom);

		config.window.title = 'why not just fucking talk to plants';

		config.preload.textures.push({id: 'assets/images/plant.png'});
		config.preload.textures.push({id: 'assets/images/carrot.png'});
		config.preload.textures.push({id: 'assets/images/ground.png'});
		config.preload.textures.push({id: 'assets/images/grass.png'});
		config.preload.textures.push({id: 'assets/images/rocks.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_0.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_1.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_2.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_3.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_4.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_5.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_6.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_7.png'});
        return config;

    }

    override function ready() {
		Texture.default_filter = FilterType.nearest;
		Luxe.renderer.clear_color = new Color(0,0,0);

		setupUI();
		setupScreen();
		setupWrapping();
		//setupBorders();

		new Level();
		player = new Player(new Vector(60,10));
    }

	function setupWrapping() {
		sceneCamera = new Camera({name: 'sceneCamera'});
		sceneBatcher = Luxe.renderer.create_batcher({
			name: 'sceneBatcher',
			camera: sceneCamera.view,
			no_add: true
		});
		shapeDrawer.setBatcher(sceneBatcher);
		sceneView = new RenderTexture({
			id: 'sceneView',
			width: Math.floor(gameResolution.x),
			height: Math.floor(gameResolution.y)
		});
		sceneView.filter_mag = FilterType.nearest;
		sceneSprite = new Sprite({
			centered: false,
			pos: new Vector(0, 0),
			texture: sceneView,
			size: new Vector(gameResolution.x * 2, gameResolution.y * 2),
			depth: 1
		});

		rightCamera = new Camera({name: 'rightCamera'});
		//rightCamera.pos.set_xy(50,50);
		rightCamera.viewport = new luxe.Rectangle(0,0,gameResolution.x/2,gameResolution.y);
		rightBatcher = Luxe.renderer.create_batcher({
			name: 'rightBatcher',
			camera: rightCamera.view,
			no_add: true
		});
		rightView = new RenderTexture({
			id: 'rightView',
			width: Math.floor(gameResolution.x/2),
			height: Math.floor(gameResolution.y)
		});
		rightView.filter_mag = FilterType.nearest;
		rightSprite = new Sprite({
			centered: false,
			pos: new Vector(0,0),
			texture: rightView,
			size: new Vector(rightView.width*zoom,rightView.height*zoom),
			depth: 2
		});
		rightSprite.pos.x = wrapPoint*zoom;

		leftCamera = new Camera({name: 'leftCamera'});
		leftCamera.pos.set_xy(wrapPoint-gameResolution.x/2,0);
		leftCamera.viewport = new luxe.Rectangle(0,0,gameResolution.x/2,gameResolution.y);
		leftBatcher = Luxe.renderer.create_batcher({
			name: 'leftBatcher',
			camera: leftCamera.view,
			no_add: true
		});
		leftView = new RenderTexture({
			id: 'leftView',
			width: Math.floor(gameResolution.x/2),
			height: Math.floor(gameResolution.y)
		});
		leftView.filter_mag = FilterType.nearest;
		leftSprite = new Sprite({
			centered: false,
			pos: new Vector(0,0),
			texture: leftView,
			size: new Vector(leftView.width*zoom,leftView.height*zoom),
			depth: -1
		});
		leftSprite.pos.x = -leftSprite.size.x;
	}

    override function onkeyup( e: luxe.KeyEvent ) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    }

	override function onwindowsized(e: WindowEvent) {
		setupScreen();
	}

	function setupScreen() {
		//Luxe.camera.size = new Vector(gameResolution.x, gameResolution.y);
		Luxe.camera.viewport.set(0, 0, gameResolution.x*zoom, gameResolution.y*zoom);
		UICamera.viewport = new luxe.Rectangle(0, 0, Luxe.screen.w, Luxe.screen.h);
		canvas.set_size(Luxe.screen.w, Luxe.screen.h);
	}

	public static function screen_point_to_world(point: Vector) {
		point = Luxe.camera.screen_point_to_world(point);
		point.divideScalar(zoom);
		return point;
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
            x: 0, y:0, w: gameResolution.x * zoom, h: gameResolution.y * zoom
        });

		auto_canvas.auto_listen();
		canvas = auto_canvas;

		focus = new Focus(canvas);
	}

	/*function setupBorders() {
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
	}*/

    override function update(dt:Float) {
    }

	var _transparent: Color = new Color(0,0,0,0);
	override function onrender() {
		Luxe.renderer.target = leftView;
		Luxe.renderer.clear(new Color(0,0,0,0));
		leftBatcher.draw();
		Luxe.renderer.target = sceneView;
		Luxe.renderer.clear(new Color(0,0,0,0));
		sceneBatcher.draw();
		Luxe.renderer.target = rightView;
		Luxe.renderer.clear(new Color(0,0,0,0));
		rightBatcher.draw();
		Luxe.renderer.target = null;
	}

	override function onpostrender() {
	}

	override function ondestroy() {
		if(Level.instance.changed)
			SDL.showSimpleMessageBox(SDLMessageBoxFlags.SDL_MESSAGEBOX_ERROR, 'quit without saving?', 'are you sure you wish to quit?', Luxe.snow.runtime.window);

		Level.instance.destroy();
		for(e in Luxe.scene.entities) {
			e.destroy();
		}
    }
}
