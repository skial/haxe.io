package ;

import js.Node.*;
import tink.Json.*;
import js.node.Fs.*;
import thx.DateTime;
import js.Node.process;
import haxe.Serializer;
import js.node.Crypto.*;
import haxe.Unserializer;
import unifill.CodePoint;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import thx.format.DateFormat;
import tink.json.Representation;
import haxe.Constraints.Function;

using Reflect;
using StringTools;
using thx.Objects;
using haxe.io.Path;
using unifill.Unifill;

typedef Data = {
	var port:Int;
	var html:String;
	var payload:Payload;
	var args:Array<String>;
	var scripts:Array<String>;
}

typedef Payload = {
	var input:{raw:String, directory:String, parts:Array<String>, filename:String, extension:String};
	var output:{raw:String, directory:String, parts:Array<String>, filename:String, extension:String};
	var template:String;
	var created:{raw:String, pretty:String};
	var modified:{raw:String, pretty:String};
	var published:{raw:String, pretty:String};
	var edits:Array<String>;
	var description:String;
	var authors:Array<{display:String, url:String}>;
	var contributors:Array<{display:String, url:String}>;
	var extra:DynamicTink;
}

abstract DynamicTink(Dynamic) from Dynamic {
	
	@:to public inline function toTinkJson():Representation<Array<Int>> {
		var str = haxe.Serializer.run(this);
		return new Representation( [for (i in 0...str.uLength()) str.uCodePointAt(i).toInt()] );
	}
	
	@:from public static inline function fromTinkJson(r:Representation<Array<Int>>):DynamicTink {
		return haxe.Unserializer.run( r.get().map(function(i) return CodePoint.fromInt(i).toString()).join('') );
	}
	
}

@:cmd
class Controller {

	private static var app:Dynamic;
	private static var twemoji:Dynamic;
	private static var electron:Dynamic;
	private static var ipcMain:{on:String->Function->Dynamic, once:String->Function->Dynamic};

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
	@alias public var root:String;
	@alias public var input:String;
	@alias public var output:String;
	@alias public var script:String;
	
	/**
	Extra scripts to be loaded which extend this scripts abilities.
	*/
	@alias('sc')
	public var scripts:Array<String>;
	
	private var completedScripts:Map<String, Bool> = new Map();
	
	/**
	Extra json data to be passed to various custom elements.
	*/
	@alias public var json:Array<String> = [];
	
	@alias public var basePaths:Array<String> = [];
	
	/**
	The markdown-it plugins should be loaded.
	*/
	@alias('md') public var mdPlugins:Array<String> = [];
	
	/**
	Extra options to be passed to markdown-it plugins.
	*/
	@alias('mdo') public var mdOptions:String = '';
	
	private var counter:Int = 0;
	private var cwd = Sys.getCwd();
	private var config:Dynamic = { webPreferences:{} };
	private var mdObject:DynamicAccess<Dynamic>;
	
	private var timeoutId:Null<Int>;
	private var timestamp:Float = 0;
	private var waitFor:Int = 100;	// wait 100ms.
	private var maxDuration:Int = 750;	// wait 750ms.
	
	// General container for transporting data between ipc contexts.
	private var data:Data;
	
	// Information payload.
	private var payload:Payload = {
		input:{raw:'', directory:'', parts:[], filename:'', extension:''},
		output:{raw:'', directory:'', parts:[], filename:'', extension:''},
		template:'',
		created:{raw:'', pretty:''},
		modified:{raw:'', pretty:''},
		published:{raw:'', pretty:''},
		edits:[],
		description: '',
		authors:[],
		contributors:[],
		extra:{},
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
		
		input = input.normalize();
		output = output.normalize();
		
		init();
	}
	
	private function init() {
		data = { scripts:[], payload:payload, html:'', args:Sys.args(), port:port };
		// Modify the json structure.
		for (object in json) {
			console.log( json );
			console.log( payload.extra );
			if (object.trim().startsWith('{')) {
				var struct = haxe.Json.parse( object );
				payload.extra = thx.Objects.assign( cast payload.extra, struct, function(field, oldv, newv) {
					if ((oldv is Array<Any>) && (newv is Array<Any>)) {
						for (value in (newv:Array<Any>)) {
							(oldv:Array<Any>).push( value );
							
						}
						
						return oldv;
						
					}
					return newv;
				} );
				
			} else try {
				payload.extra = thx.Objects.assign( cast payload.extra, haxe.Json.parse( sys.io.File.getContent( object ) ), function(field, oldv, newv) {
					if ((oldv is Array<Any>) && (newv is Array<Any>)) {
						for (value in (newv:Array<Any>)) {
							(oldv:Array<Any>).push( value );
							
						}
						
						return oldv;
						
					}
					return newv;
				} );
				
			} catch (e:Dynamic) {
				console.log('Unable to load $object');
				
			}
			console.log( payload.extra );
			
		}
		
		// Pass extra options to markdownIt plugins.
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
		
		// Modify the markdownIt `reference` token rule.
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
		
		// Add twemoji support to markdownIt
		twemoji = require('twemoji');
		md.renderer.rules.emoji = function(token, idx) {
			return twemoji.parse(token[idx].content, {ext:'.svg', base:'/twemoji/', folder:'svg'});
		};
		
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
		ipcMain.once('save', save);
		
		trace( 'serving from ' + '$cwd/$root'.normalize() );
		var files = untyped __js__("new {0}", server.Server)('$cwd/$root'.normalize());
		var ns = require('http').createServer(function (request, response) {
			request.addListener('end', function () {
		      files.serve(request, response);
					response.setHeader("Content-Security-Policy", "default-src 'self'; script-src http://localhost:*/templates/ http://localhost:*/js/component.js http://localhost:*/js/convert.tag.js http://localhost:*/js/css.selector.js http://localhost:*/js/document.body.js http://localhost:*/js/document.head.js http://localhost:*/js/json.data.js; connect-src 'self'; img-src 'self'; style-src 'self';");
					
		  }).resume();
		});
		ns.listen(0);
		port = ns.address().port;
		
		browser = untyped __js__("new {0}", electron.BrowserWindow)( config );
		browser.on('closed', function() browser = null );
		var webContents = browser.webContents;
		webContents.send('html', html);
		webContents.on('did-finish-load', function() {
			console.log( 'page loaded', webContents.getURL() );
			webContents.openDevTools();
			
			data.port = port;
			data.html = html;
			data.scripts = scripts;
			data.payload = generatePayload( mdEnvironment );
			webContents.send( 'data:payload', tink.Json.stringify( data ) );
			/*webContents.send( 'scripts:load', haxe.Json.stringify( {scripts:scripts} ) );
			webContents.send( 'html', html );
			webContents.send( 'json', tink.Json.stringify(generatePayload(mdEnvironment)) );*/
		});
		
		var url = (input.directory().addTrailingSlash() + mdEnvironment['references']['_TEMPLATE']['href']).replace(root, 'http://localhost:$port').normalize();
		browser.loadURL( url );
	}
	
	private function save(event:String, arg:String):Void {
		if (arg != 'failed') {
			var html = arg.replace( '\n', '\r\n' );
      var fullPath = '$cwd/$output'.normalize();
      var dirname = '$cwd/${output.directory()}'.normalize().addTrailingSlash();
      console.log( 'saving file to $dirname' );
			
      if (!sys.FileSystem.exists( dirname )) {
				createDir( dirname, function() {
					writeFile( fullPath, html, 'utf8', function(error) {
						if (error != null) console.log( error );
						console.log( 'saved file $dirname successfully.' );
            if (!show) browser.close();
						
					} );
					
				});
				
			} else {
				writeFile( fullPath, html, 'utf8', function(error) {
					if (error != null) console.log( error );
					console.log( 'saved file $fullPath successfully.' );
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
				console.log( 'create directory', error, path );
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
			['references', 'DESCRIPTION', 'title'] => function(values) {
				payload.description = values[0];
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
		var _modified = this.input;
		if (payload.input.raw == '') payload.input = {
			raw:this.input.normalize(), parts:[for (part in this.input.normalize().split('/')) if (basePaths.indexOf(part) == -1) part], 
			filename:this.input.withoutDirectory().withoutExtension(), 
			extension:this.input.extension(),
			directory:([for (part in basePaths) if (_modified.startsWith(part)) _modified = _modified.replace(part, '')] != null ? _modified : _modified).normalize().directory(),
		};
		var _modified = this.output;
		if (payload.output.raw == '') payload.output = {
			raw:this.output.normalize(), parts:[for (part in this.output.normalize().split('/')) if (basePaths.indexOf(part) == -1) part], 
			filename:this.output.withoutDirectory().withoutExtension(), 
			extension:this.output.extension(),
			directory:([for (part in basePaths) if (_modified.startsWith(part)) _modified = _modified.replace(part, '')] != null ? _modified : _modified).normalize().directory(),
		};
		
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
