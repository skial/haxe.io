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
import thx.DateTime;
import thx.format.DateFormat;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

typedef Payload = {
	var template:String;
	var created:{raw:String, pretty:String};
	var modified:{raw:String, pretty:String};
	var published:{raw:String, pretty:String};
	var edits:Array<String>;
	var authors:Array<String>;
	var contributors:Array<String>;
}

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

  public var show:Bool = false;
	@alias('r') public var root:String;
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
	private var mdEnvironment:DynamicAccess<DynamicAccess<DynamicAccess<String>>> = {};
	private var markdownIt = require('markdown-it');
	private var server = require('node-static');
	private var port:Int = 8080;
	private var browser:Dynamic;

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
			var ast = preprocessAst( md.parse( content, mdEnvironment ) );
			var html = md.renderer.render( ast, options, mdEnvironment );
			processHtml( html );

		});

	}

	private function preprocessAst(ast:Array<Token>):Array<Token> {
		// Look for `[“”]: ""` and remove.
		var slice = ast.slice(0,3);
		switch (slice) {
			case [{type:'paragraph_open'}, {content:_.startsWith('[“”]') => true}, {type:'paragraph_close'}]:
				//trace( 'removing ast' );
				//for (s in slice) trace( s );
				ast = ast.splice( 3, ast.length );

			case _:
				//trace( slice );

		}

		return ast;
	}

	private function processHtml(html:String):Void {
		ipcMain.on('save', save);
		trace( 'serving from ' + '$cwd/$root'.normalize() );
		var files = untyped __js__("new {0}", server.Server)('$cwd/$root'.normalize());
		var ns = require('http').createServer(function (request, response) {
			request.addListener('end', function () {
		      files.serve(request, response);
					response.setHeader("Content-Security-Policy", "default-src 'self'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';");

		  }).resume();
		});
		ns.listen(0);
		port = ns.address().port;

		browser = untyped __js__("new {0}", electron.BrowserWindow)( config );
		browser.on('closed', function() browser = null );
		var webContents = browser.webContents;
		webContents.send('html', html);
		webContents.on('did-finish-load', function() {
			trace( 'page loaded', webContents.getURL() );
			webContents.openDevTools();
			webContents.send('html', html);
			var created = DateTime.fromString(mdEnvironment['references']['DATE']['title']);
			var published = DateTime.fromString(mdEnvironment['references']['DATE']['title']);
			var modified = DateTime.fromString(mdEnvironment['references']['MODIFIED']['title']);
			webContents.send('json', tink.Json.stringify(({
				template: '' + mdEnvironment['references']['_TEMPLATE']['href'],
				created: {
          raw:mdEnvironment['references']['DATE']['title'],
          pretty:DateFormat.format(created, 'dddd d"${daySuffix(created.day)}" MMMM yyyy')
        },
				published: {
          raw:mdEnvironment['references']['DATE']['title'],
          pretty:DateFormat.format(published, 'dddd d"${daySuffix(published.day)}" MMMM yyyy')
        },
				modified: {
          raw:mdEnvironment['references']['MODIFIED']['title'],
          pretty:DateFormat.format(modified, 'dddd d"${daySuffix(modified.day)}" MMMM yyyy')
        },
				contributors: [],
				authors: [],
				edits: []
			}:Payload)) );
		});
		var url = (input.directory().addTrailingSlash() + mdEnvironment['references']['_TEMPLATE']['href']).replace(root, 'http://localhost:$port').normalize();
		trace( url );
		browser.loadURL( url );
	}

	private function save(event:String, arg:String) {
		if (arg != 'failed') {
			var html = arg.replace( '\n', '\r\n' );
      var fullPath = '$cwd/$output'.normalize();
      var dirname = '$cwd/${output.directory()}'.normalize().addTrailingSlash();
      trace( 'saving file to $dirname' );

      if (!sys.FileSystem.exists( dirname )) {
				createDir( dirname, function() {
					writeFile( dirname, html, 'utf8', function(error) {
						if (error != null) trace( error );
						trace( 'saved file $dirname successfully.' );
            if (!show) browser.close();
					} );

				});

			} else {
				writeFile( fullPath, html, 'utf8', function(error) {
					if (error != null) trace( error );
					trace( 'saved file $fullPath successfully.' );
          if (!show) browser.close();
				} );

			}

		}

	}

  private function createDir(path:String, cb:Function):Void {
		untyped mkdir( path, function(error) {
			if (error != null) {
				var parts = path.split( '/' );
				parts.pop();
				createDir( parts.join( '/' ), cb );
			} else {
				trace( 'create directory', error, path );
				cb();

			}

		});
	}
	
	private function daySuffix(n:Int):String {
		if (n >= 11 && n <= 13) {
				return "th";
		}
		switch (n % 10) {
				case 1:  return "st";
				case 2:  return "nd";
				case 3:  return "rd";
				default: return "th";
		}
	}

}

// @see https://github.com/markdown-it/markdown-it/blob/master/lib/token.js
typedef Token = {
	var type:String;
	var tag:String;
	var attrs:Array<Array<Dynamic>>;
	var map:Array<Int>;
	var nesting:NestingLevel;
	var level:Int;
	var children:Array<Token>;
	var content:String;
	var markup:String;
	var info:String;
	var meta:Dynamic;
	var block:Bool;
	var hidden:Bool;
}

@:enum abstract NestingLevel(Int) from Int to Int {
	var Opening = 1;
	var SelfClosing = 0;
	var Closing = -1;
}
