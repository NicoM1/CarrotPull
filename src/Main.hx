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
import phoenix.geometry.TextGeometry;

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

import luxe.tween.Actuate;

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

	static var sceneView: RenderTexture;
	static var sceneSprite: Sprite;
	public static var sceneCamera: Camera;
	public static var sceneBatcher: Batcher;

	static var renderView: RenderTexture;
	static var renderSprite: Sprite;
	public static var renderCamera: Camera;
	public static var renderBatcher: Batcher;

	static var rightView: RenderTexture;
	static var rightSprite: Sprite;
	static var rightCamera: Camera;
	public static var rightBatcher: Batcher;

	static var leftView: RenderTexture;
	static var leftSprite: Sprite;
	static var leftCamera: Camera;
	public static var leftBatcher: Batcher;

	static var blurDist: Float = 0;
	static var darkness: Float = 1;

	public static var wrapPoint(default, set): Int = 300;

    override function config(config:luxe.AppConfig) {
		config.window.resizable = false;
		config.window.borderless = true;
		config.window.width = Math.floor(gameResolution.x * zoom);
		config.window.height = Math.floor(gameResolution.y * zoom);

		config.window.title = 'Every other Wednesday.';

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
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_8.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_9.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_10.png'});
		config.preload.textures.push({id: 'assets/images/worldWrap128x64_11.png'});
		config.preload.textures.push({id: 'assets/images/bridge.png'});
		config.preload.textures.push({id: 'assets/images/mossyrock.png'});
		config.preload.textures.push({id: 'assets/images/rock.png'});
		config.preload.textures.push({id: 'assets/images/rockhor.png'});
		config.preload.textures.push({id: 'assets/images/arbutus.png'});
		config.preload.textures.push({id: 'assets/images/moss.png'});
		config.preload.textures.push({id: 'assets/images/moss1.png'});
		config.preload.textures.push({id: 'assets/images/moss2.png'});
		config.preload.textures.push({id: 'assets/images/note.png'});
		config.preload.textures.push({id: 'assets/images/player.png'});
		config.preload.textures.push({id: 'assets/images/playersheet.png'});
		config.preload.textures.push({id: 'assets/images/rope.png'});
		config.preload.textures.push({id: 'assets/images/cache.png'});
		config.preload.textures.push({id: 'assets/images/cacheopen.png'});
		config.preload.fonts.push({id: 'assets/fonts/font.fnt'});
		config.preload.jsons.push({id: 'assets/files/animation/player_anim.json'});
		config.preload.shaders.push({id: 'assets/shaders/base.glsl', vert_id: 'default', frag_id: 'assets/shaders/base.glsl'});
        return config;
    }

    override function ready() {
		Texture.default_filter = FilterType.nearest;
		Luxe.renderer.clear_color = new Color(0,0,0);

		setupUI();
		setupScreen();
		setupWrapping();
		//setupBorders();

		Luxe.resources.texture('assets/fonts/font.png').filter_mag = FilterType.nearest;

		new Level();
		player = new Player(new Vector(60,10));
    }

	static public function darken(value: Float) {
		value = 1-value;
		Actuate.tween(Main, 1, {darkness: value});
	}

	static var text: TextGeometry;

	static public function showText(msg: String) {
		if(text == null) {
			text = Luxe.draw.text({
				batcher: renderBatcher,
				text: '',
				color: new Color(0.8,0.8,0.8),
				font: Luxe.resources.font('assets/fonts/font.fnt'),
				point_size: 9,
				depth: 10000
			});
		}
		/*var chars: Int = 0;
		var final: String = '';
		for(i in 0...msg.length) {
			chars++;
			if(chars > 50 && msg.charAt(i) == ' ') {
				chars = 0;
				final += '\n';
			}
			else {
				final += msg.charAt(i);
			}
		}*/

		text.text = msg;
		text.bounds = new phoenix.Rectangle(0,0,300);
		text.align = phoenix.BitmapFont.TextAlign.center;
		text.bounds_wrap = true;
		text.transform.pos.x = gameResolution.x/2 - 150;
		text.transform.pos.y = gameResolution.y/2 - text.text_height/2;
		text.color.a = 0;
		luxe.tween.Actuate.tween(Main, 1, {blurDist: 0.03});
		luxe.tween.Actuate.tween(Main, 1, {darkness: 0.4});
		luxe.tween.Actuate.tween(text.color, 1, {a: 1});
		Luxe.events.fire('text.show');
	}

	static public function hideText() {
		luxe.tween.Actuate.tween(Main, 1, {blurDist: 0});
		luxe.tween.Actuate.tween(Main, 1, {darkness: 1});
		luxe.tween.Actuate.tween(text.color, 1, {a: 0});
		Luxe.events.fire('text.hide');
	}

	static function set_wrapPoint(v: Int): Int {
		wrapPoint = v;
		regenWrapping();
		return v;
	}

	function setupWrapping() {
		renderCamera = new Camera({name: 'renderCamera'});
		renderBatcher = Luxe.renderer.create_batcher({
			name: 'renderBatcher',
			camera: renderCamera.view,
			no_add: true
		});
		renderView = new RenderTexture({
			id: 'renderView',
			width: Math.floor(gameResolution.x),
			height: Math.floor(gameResolution.y)
		});
		renderView.filter_mag = FilterType.nearest;
		renderSprite = new Sprite({
			centered: false,
			pos: new Vector(0, 0),
			texture: renderView,
			size: new Vector(gameResolution.x*zoom, gameResolution.y * zoom),
			depth: 5
		});

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
			batcher: renderBatcher,
			centered: false,
			pos: new Vector(0, 0),
			texture: sceneView,
			size: new Vector(gameResolution.x, gameResolution.y),
			depth: 1,
			shader: Luxe.resources.shader('assets/shaders/base.glsl')
		});

		sceneSprite.shader.set_vector2('delta', new Vector(0,0));

		rightCamera = new Camera({name: 'rightCamera'});
		rightCamera.viewport = new luxe.Rectangle(0,0,gameResolution.x/2,gameResolution.y*2);
		rightBatcher = Luxe.renderer.create_batcher({
			name: 'rightBatcher',
			camera: rightCamera.view,
			no_add: true
		});
		rightView = new RenderTexture({
			id: 'rightView',
			width: Math.floor(gameResolution.x/2),
			height: Math.floor(gameResolution.y*2)
		});
		rightView.filter_mag = FilterType.nearest;
		rightSprite = new Sprite({
			centered: false,
			batcher: sceneBatcher,
			pos: new Vector(0,0),
			texture: rightView,
			size: new Vector(rightView.width, rightView.height),
			depth: 2
		});

		leftCamera = new Camera({name: 'leftCamera'});
		leftCamera.viewport = new luxe.Rectangle(0,0,gameResolution.x/2,gameResolution.y*2);
		leftBatcher = Luxe.renderer.create_batcher({
			name: 'leftBatcher',
			camera: leftCamera.view,
			no_add: true
		});
		leftView = new RenderTexture({
			id: 'leftView',
			width: Math.floor(gameResolution.x/2),
			height: Math.floor(gameResolution.y*2)
		});
		leftView.filter_mag = FilterType.nearest;
		leftSprite = new Sprite({
			batcher: sceneBatcher,
			centered: false,
			pos: new Vector(0,0),
			texture: leftView,
			size: new Vector(leftView.width,leftView.height),
			depth: 2
		});
		regenWrapping();
	}

	static function regenWrapping() {
		rightSprite.pos.x = wrapPoint;
		leftSprite.pos.x = -leftSprite.size.x;
		leftCamera.pos.x = wrapPoint - gameResolution.x/2;
		if(Level.instance != null) {
			Level.instance.adjustWrapping();
		}
	}

    override function onkeyup( e: luxe.KeyEvent ) {
		if(e.keycode == Key.equals) {
			wrapPoint += 50;
			regenWrapping();
		}
		if(e.keycode == Key.minus) {
			wrapPoint -= 50;
			regenWrapping();
		}
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
		point = sceneCamera.screen_point_to_world(point.clone().divideScalar(zoom));
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
		sceneSprite.shader.set_float('blurdist', blurDist);
		sceneSprite.shader.set_float('darkness', darkness);
		//sceneSprite.shader.set_float('wraps', Level.wrapTimes);
    }

	var _transparent: Color = new Color(0,0,0,0);
	override function onrender() {
		Luxe.renderer.target = leftView;
		Luxe.renderer.clear(new Color(0,0,0,0));
		leftBatcher.draw();
		Luxe.renderer.target = rightView;
		Luxe.renderer.clear(new Color(0,0,0,0));
		rightBatcher.draw();
		Luxe.renderer.target = sceneView;
		Luxe.renderer.clear(new Color().rgb(0x202012));
		sceneBatcher.draw();
		Luxe.renderer.target = renderView;
		Luxe.renderer.clear(new Color(1,1,1,1));
		renderBatcher.draw();
		Luxe.renderer.target = null;
	}

	override function onpostrender() {
	}

	override function ondestroy() {
		//if(Level.instance.changed)
		//	SDL.showSimpleMessageBox(SDLMessageBoxFlags.SDL_MESSAGEBOX_ERROR, 'quit without saving?', 'are you sure you wish to quit?', Luxe.snow.runtime.window);

		Level.instance.destroy();
    }
}
