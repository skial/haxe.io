package ;

import js.Node.*;
import js.node.Fs.*;
import js.Node.process;
import js.node.Crypto.*;
import haxe.Serializer;
import haxe.Unserializer;
//import electron.main.App;
import haxe.ds.StringMap;
//import electron.main.WebContents;
import haxe.Constraints.Function;
//import electron.main.BrowserWindow;
//import electron.main.BrowserWindowOptions;

using StringTools;
using haxe.io.Path;

@:cmd
class Main {
	
	public var input:String;
	@alias('w') public var width:Int;
	@alias('h') public var height:Int;
	public var script:String;
	@alias('s') public var scripts:Array<String> = [];
	public var show:Bool = false;
	public var wait:Bool = false;
	public var outputDir:String;

	private static var app:Dynamic;
	private static var electron:Dynamic;
	private static var ipcMain:{on:String->Function->Dynamic};
	private var window:Dynamic;
	private var contents:Dynamic;
	private var filename:String;
	private var port:Int;
	private var queue:StringMap<Bool> = new StringMap();
	private var queueKeys:Iterator<String>;
	private var running:StringMap<Bool> = new StringMap();
	
	public static function main() {
		electron = require('electron');
		app = electron.app;
		ipcMain = electron.ipcMain;
		
		app.on('ready', function() {
			var m = new Main( Sys.args() );
		} );
		
		app.on('window-all-closed', function() {
		  if (process.platform != 'darwin') {
		    app.quit();
		  }
		});
	}
	
	public function new(args:Array<String>) {
		@:cmd _;
		
		if (width == null) {
			width = electron.screen.getPrimaryDisplay().workAreaSize.width;
			
		}
		
		if (height == null) {
			height = electron.screen.getPrimaryDisplay().workAreaSize.height;
			
		}
		
		var config:Dynamic = { 
			width: width, height: height, show: show, center:true, 
		};
		
		trace( config );
		trace( 'scripts::', scripts );
		trace( 'input::', (Sys.getCwd() + '$input').normalize() );
		trace( 'output::', (Sys.getCwd() + '$outputDir').normalize() );
		trace( 'script::', (Sys.getCwd() + '/$script').normalize() );
		
		queueKeys = queue.keys();
		
		ipcMain.on('fetch::data', function(event:String, arg:String) {
			window.webContents.send('fetched::data::$arg', Serializer.run({input:input}));
		});
		ipcMain.on('continueOrQuit', continueOrQuit);
		ipcMain.on('screenshot::init', screenshot);
		ipcMain.on('queue::add', modifyQueue);
		ipcMain.on('save::file', saveFile);
		ipcMain.on('final::html', handleHTML);
		ipcMain.on('final::failed', function() {
			trace( 'sending html failed' );
			app.quit();
		});
		
		var completed = new StringMap<Bool>();
		
		for (s in scripts) {
			var name = s.withoutExtension();
			
			running.set( name, false );
			ipcMain.on('$name::complete', handleScriptCompletion.bind(_, _, name));
			
		}
		config.webPreferences = {};
		if (script != null) config.webPreferences = { 
			preload:( Sys.getCwd() + '/$script' ).normalize() 
		};
		
		filename = input.withoutDirectory();
		if (filename == '') filename = 'index.html';
		var inputDir = input.directory();
		var ipcMain = require('electron').ipcMain;
		var server = require('node-static');
		trace( 'server root => ' + (Sys.getCwd() + '$inputDir').normalize() );
		var files = untyped __js__("new {0}", server.Server((Sys.getCwd() + '$inputDir').normalize(), {headers:{"Content-Security-Policy": "script-src 'none';"}}) );
		
		var ns = require('http').createServer(function (request, response) {
			request.addListener('end', function () {
		      files.serve(request, response);
					
		  }).resume();
		});
		ns.listen(0);
		port = ns.address().port;
		window = untyped __js__("new {0}", electron.BrowserWindow( config ));
		window.on('closed', function() {
	    window = null;
	  });
		
		window.webContents.on('did-stop-loading', onLoad);
		//window.webContents.on('dom-ready', onLoad);
		
		modifyQueue('manual', Serializer.run([filename]) );
		process.nextTick( processQueue );
	}
	
	private function onLoad():Void {
		var key = window.webContents.getURL().replace( 'http://localhost:$port', '' );
		trace( 'page loaded', window.webContents.getURL(), key );
		if (queue.exists(key)) {
			queue.set( key, true );
			window.webContents.openDevTools();
			window.webContents.send('scripts::required', Serializer.run( scripts ));
			
		}
		
	}
	
	private function handleScriptCompletion(event:String, args:Array<String>, name:String):Void {
		running.set( name, true );
		trace( '$name script has completed', args );
		var allDone = false;
		for (key in running.keys()) {
			var previous = allDone;
			allDone = running.get( key );
			if (previous && !allDone) break;
			
		}
		trace( 'all done?', allDone );
		if (allDone) {
			trace( 'completed!', window.webContents.getURL() );
			for (key in running.keys()) running.set( key, false );
			window.webContents.send('scripts::completed', 'true');
		
		} else {
			trace( 'waiting for ' + [for (k in running.keys()) if (!running.get(k)) k] );
		}
		
	}
	
	private function handleHTML(event:String, arg:String):Void {
		if (arg == 'failed') {
			continueOrQuit();
			
		} else {
			saveFile(event, Serializer.run( { filename: filename, content: arg.replace('\n', '\r\n'), reply:'continueOrQuit' } ));
			
		}
	}
	
	private function continueOrQuit():Void {
		//trace( 'queue length', [for (k in queue.keys()) if (!queue.get(k)) k].length);
		if ([for (k in queue.keys()) if (!queue.get(k)) k].length != 0) {
			//trace( 'still in queue', [for (k in queue.keys()) if (!queue.get(k)) k] );
			process.nextTick( processQueue );
			
		} else {
			trace( queue );
			if (!wait) app.quit();
			
		}
	}
	
	private function saveFile(event:String, arg:String):Void {
		var data:{filename:String, directory:String, content:String, reply:String} = Unserializer.run( arg );
		var path:String = (window.webContents.getURL():String).replace( 'http://localhost:${port}', '' );
		var dirname = (data.directory != null && data.directory != '') ? data.directory : path.directory();
		if (dirname == null || dirname == '') dirname = '/';
		trace( 'saving file', path, dirname, data.filename, data.reply, (Sys.getCwd() + '/$outputDir/$dirname/').normalize().addTrailingSlash() );
		if (data.filename == null || data.filename == '') {
			trace( 'data filename cannot be empty.' );
			window.webContents.send(data.reply, 'false');
			return;
		}
		
		if (data.content == null || data.content == '') {
			trace( 'data content cannot be empty.' );
			window.webContents.send(data.reply, 'false');
			return;
		}
		
		//try {
			if (!sys.FileSystem.exists( Sys.getCwd() + '/$outputDir/$dirname/' )) {
				createDir( (Sys.getCwd() + '/$outputDir/$dirname/').normalize().addTrailingSlash(), function() {
					writeFile( (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize(), data.content, 'utf8', function(error) {
						if (error != null) trace( error );
						trace( 'saved file /$outputDir/$dirname/${data.filename} successfully.' );
						window.webContents.send(data.reply, 'true');
					} );
					
				});
				
			} else {
				writeFile( (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize(), data.content, 'utf8', function(error) {
					if (error != null) trace( error );
					trace( 'saved file /$outputDir/$dirname/${data.filename} successfully.' );
					window.webContents.send(data.reply, 'true');
				} );
				
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
	
	private function modifyQueue(event:String, arg:String):Void {
		var links:Array<String> = [];
		links = Unserializer.run(arg);
		//trace( 'recieved', links );
		for (link in links) if (!link.endsWith('swf') && !queue.exists( link ) && !queue.exists( link.directory().addTrailingSlash() )) {
			var key = link.endsWith( 'index.html' ) ? link.directory().addTrailingSlash() : link;
			queue.set(key, false);
			//trace( 'adding $key' );
		}
		
	}
	
	private function processQueue():Void {
		var key = '';
		var keys = queue.keys();
		
		while (keys.hasNext()) {
			key = keys.next();
			if (!queue.get( key )) break;
		}
		
		if (!queue.get( key )) {
			//queue.set( key, true );
			trace( 'attempting to load http://localhost:$port$key' );
			window.loadURL( 'http://localhost:$port$key' );
			
		}
		
	}
	
	private function screenshot(event:String, arg:String):Void {
		trace( 'attempting screen grab of ' + window.webContents.getURL(), arg );
		if (window != null && window.webContents != null) {
			window.webContents.closeDevTools();
			if (window.isFocused()) window.blur();
			window.capturePage(function(image) {
				var path:String = (window.webContents.getURL():String).replace( 'http://localhost:$port', '' );
				var dirname = path.directory();
				var output = '/img/$dirname/preview.png'.normalize();
				var size:{width:Int,height:Int} = image.getSize();
				trace( output, size, (Sys.getCwd() + '/$outputDir/img/$dirname/').normalize().addTrailingSlash() );
				var data = { width:size.width,height:size.height,path:output};
				if (!sys.FileSystem.exists((Sys.getCwd() + '/$outputDir/img/$dirname/').normalize().addTrailingSlash())) {
					createDir( (Sys.getCwd() + '/$outputDir/img/$dirname/').normalize(), function () writeFile( (Sys.getCwd() + '/$outputDir/$output').normalize(), image.toPng(), function(error) {
						if (error != null) trace( error );
						trace( 'saving preview of ${window.webContents.getURL()} to ' + Sys.getCwd() + '/$outputDir/$output' );
						window.webContents.openDevTools();
						window.webContents.send('screenshot::complete', Serializer.run(data));
					}));
				
				} else {
					writeFile( (Sys.getCwd() + '/$outputDir/$output').normalize(), image.toPng(), function(error) {
						if (error != null) trace( error );
						trace( 'saving preview of ${window.webContents.getURL()} to ' + Sys.getCwd() + '/$outputDir/$output' );
						window.webContents.openDevTools();
						window.webContents.send('screenshot::complete', Serializer.run(data));
					});
					
				}
				
			});
			
		} else {
			window.webContents.send('screenshot::complete', 'false');
			
		}
		
	}
	
}
