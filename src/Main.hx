package ;

import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

import phoenix.RenderTexture;
import phoenix.Batcher;
import phoenix.Camera;
import phoenix.Shader;

class Main extends luxe.Game {

	var _canvas: RenderTexture;
	var _canvasSprite: Sprite;
	var _canvasShader: Shader;
	var _sceneCamera: Camera;
	public var shaderBatch: Batcher;

	var test: Sprite;

    override function config(config:luxe.AppConfig) {

        return config;

    }

    override function ready() {
		Luxe.renderer.clear_color = new Color(0,0,0);

		_canvas = new RenderTexture({id: 'canvas'});
		_sceneCamera = new Camera();

		shaderBatch = Luxe.renderer.create_batcher({
			name: 'shaderbatcher',
			no_add: true,
			camera: _sceneCamera
		});

		Luxe.camera.size = new Vector(160,90);

		Luxe.resources.load_shader('postprocess', {frag_id: 'assets/files/shaders/screenshader.glsl', vert_id: 'default'}).then(function(shader) {
			_canvasShader = shader;
			_canvasSprite = new Sprite({
				centered: false,
				pos: new Vector(0, 0),
				size: new Vector(Luxe.camera.size.x, Luxe.camera.size.y),
				texture: _canvas,
				shader: _canvasShader
			});
		});

		test = new Sprite({
			pos: Luxe.camera.center.clone(),
			size: new Vector(160,90),
			batcher: shaderBatch
		});
		var test2 = new Sprite({
			pos: Luxe.camera.center.clone(),
			size: new Vector(160,90),
			batcher: shaderBatch
		});
		test2.pos.x += 40;
		test2.pos.y += 40;
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    }

    override function update(dt:Float) {

    }

	var _transparent: Color = new Color(0,0,0,0);
	override function onrender() {
		Luxe.renderer.target = _canvas;
		Luxe.renderer.clear(_transparent);
		shaderBatch.draw();
		Luxe.renderer.target = null;
	}
}
