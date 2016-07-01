package ;

import js.Node.*;
import tink.Json.*;
import js.node.Fs.*;
import js.Node.process;
import haxe.Serializer;
import js.node.Crypto.*;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

@:cmd
class Controller {
	
	private static var app:Dynamic;
	private static var electron:Dynamic;
	private static var ipcMain:{on:String->Function->Dynamic};
	
	public static function main() {
		electron = require('electron');
		app = electron.app;
		ipcMain = electron.ipcMain;
		
		app.on('ready', function() {
			var m = new Controller( Sys.args() );
		} );
		
		app.on('window-all-closed', function() {
		  if (process.platform != 'darwin') {
		    app.quit();
		  }
		});
	}
	
	@alias('i') public var input:String;
	@alias('o') public var output:String;
	@alias('s') public var script:String;
	@alias('md') public var mdPlugins:Array<String> = [];
	@alias('mdo') public var mdOptions:String = '';
	
	private var counter:Int = 0;
	private var cwd = Sys.getCwd();
	private var config:Dynamic = { webPreferences:{} };
	private var mdObject:DynamicAccess<Dynamic>;
	
	private var md:Dynamic;
	private var markdownIt = require('markdown-it');
	
	public function new(args:Array<String>) {
		@:cmd _;
		
		if (script != null) config.webPreferences.preload = '$cwd/$script'.normalize();
		if (input == null) app.quit();
		
		init();
	}
	
	private function init() {
		md = untyped __js__('new {0}', markdownIt)({ html: true, linkify: true, typographer: true });
		var options = {};
		
		if (mdOptions != null) mdObject = (mdOptions == '') ? {} : haxe.Json.parse( mdOptions );
		
		for (plugin in mdPlugins) {
			if (mdOptions != null && mdObject.exists( plugin )) {
				options = mdObject.get( plugin );
				
			}
			
			trace( 'fetching $plugin' );
			md.use( require(plugin), options );
		
		}
		
		readFile('$cwd/$input'.normalize(), {encoding:'utf8'}, function(error, content) {
			if (error != null) throw error;
			var ast = md.parse( content, {} );
			var html = md.renderer.render( ast, options, {} );
			trace( html );
			app.quit();
		});
		
	}
	
	private function preprocessMD(ast:Array<{}>) {
		
	}
	
}
