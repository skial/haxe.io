package ;

import js.Node.*;
import tink.Json.*;
import js.node.Fs.*;
import thx.DateTime;
import js.Node.process;
import haxe.Serializer;
import js.node.Crypto.*;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import thx.format.DateFormat;
import haxe.Constraints.Function;

using Reflect;
using StringTools;
using haxe.io.Path;

typedef Payload = {
	var input:String;
	var output:String;
	var template:String;
	var created:{raw:String, pretty:String};
	var modified:{raw:String, pretty:String};
	var published:{raw:String, pretty:String};
	var edits:Array<String>;
	var authors:Array<{display:String, url:String}>;
	var contributors:Array<{display:String, url:String}>;
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
	
	private var payload:Payload = {
		input:'',
		output:'',
		template:'',
		created:{raw:'', pretty:''},
		modified:{raw:'', pretty:''},
		published:{raw:'', pretty:''},
		edits:[],
		authors:[],
		contributors:[],
	};
	
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
		
		var index = md.block.ruler.__find__('reference');
		var original = md.block.ruler.__rules__[index].fn;
		
		var replaceReferences = [
			['references', 'AUTHOR'] => function(object:Dynamic) {
				if (object.fields().length > 0) payload.authors.push( {display:object.title, url:object.href} );
				return true;	// delete
			},
			['references', 'CONTRIBUTOR'] => function(object:Dynamic) {
				if (object.fields().length > 0) payload.contributors.push( {display:object.title, url:object.href} );
				return true;	// delete
			},
		];
		
		md.block.ruler.at('reference', function(state, startLine, _endLine, silent) {
			var result = original(state, startLine, _endLine, silent);
			var object:DynamicAccess<Dynamic> = state.env;
			var keys = [for (key in replaceReferences.keys()) key];
			
			for (key in keys) {
				for (segment in key) {
					if (object.exists( segment )) {
						if (segment == key[key.length - 1]) {
							var remove = replaceReferences.get( key )( object[segment] );
							
							if (remove) {
								object.remove( segment );
								
							}
							
						} else {
							object = object[segment];
							
						}
						
					} else {		
						
						
					}
					
				}
				
			}
			
			return result;
		});

		readFile('$cwd/$input'.normalize(), {encoding:'utf8'}, function(error, content) {
			if (error != null) throw error;
			var ast = preprocessAst( md.parse( content, mdEnvironment ) );
			var html = md.renderer.render( ast, options, mdEnvironment );
			console.log( mdEnvironment );
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
			webContents.send('json', tink.Json.stringify(generatePayload(mdEnvironment)));
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
				case _: return "th";
		}
	}
	
	private function formattedDate(v:String):String {
		var date = DateTime.fromString(v);
		return DateFormat.format(date, 'dddd d"${daySuffix(date.day)}" MMMM yyyy');
	}
	
	private function generatePayload(input:DynamicAccess<DynamicAccess<DynamicAccess<String>>>):Payload {
		var paths = [
			['references', '_TEMPLATE', 'href'] => function(values) payload.template = values[0],
			['references', 'TEMPLATE', 'href'] => function(values) payload.template = values[0],
			['references', 'DATE', 'title'] => function(values) {
				payload.created.raw = values[0];
				payload.created.pretty = formattedDate(values[0]);
			},
			['references', 'MODIFIED', 'title'] => function(values) {
				payload.modified.raw = values[0];
				payload.modified.pretty = formattedDate(values[0]);
			},
			['references', 'PUBLISHED', 'title'] => function(values) {
				payload.published.raw = values[0];
				payload.published.pretty = formattedDate(values[0]);
			},
			['references', 'AUTHOR'] => function(values:Array<String>) {
				for (value in values) {
					var object = haxe.Json.parse(value);
					payload.authors.push( { display:object.title, url:object.href } );
				}
			},
			['references', 'CONTRIBUTORS'] => function(values:Array<String>) {
				for (value in values) {
					var object = haxe.Json.parse(value);
					payload.contributors.push( { display:object.title, url:object.href } );
				}
			}
		];
		
		for (key in paths.keys()) {
			var object:DynamicAccess<Dynamic> = input;
			
			for (segment in key) {
				if (object.exists(segment)) {
					if (segment == key[key.length - 1]) {
						console.log( object, segment );
						var value = object.get( segment );
						
						if (Type.typeof(value).match( TObject )) {
							paths.get( key )( [haxe.Json.stringify( value )] );
							
						} else if (Std.is(value, Array) && Type.typeof(value[0]).match( TObject )) {
							paths.get( key )( [for (v in (value:Array<Dynamic>)) haxe.Json.stringify(v)] );
							
						} else if (Std.is(value, Array) && !Type.typeof(value[0]).match( TObject )) {
							paths.get( key )( (value:Array<String>) );
							
						} else {
							paths.get( key )( [value] );
							
						}
						
					} else {
						object = object.get( segment );
						
					}
					
				}
				
			}
			
		}
		
		// Move to external file or make available via command line or environment?
		if (payload.authors.length == 0) payload.authors.push( { display:'Skial Bainn', url:'/twitter.com/skial' } );
		if (payload.input == '') payload.input = cast this.input;
		if (payload.output == '') payload.output = cast this.output;
		
		return payload;
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
