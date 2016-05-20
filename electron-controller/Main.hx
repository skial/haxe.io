package ;

import js.Node.*;
import js.node.Fs.*;
import js.Node.process;
import haxe.Serializer;
import haxe.Unserializer;
import electron.main.App;
import haxe.ds.StringMap;
import electron.main.WebContents;
import haxe.Constraints.Function;
import electron.main.BrowserWindow;
import electron.main.BrowserWindowOptions;

using StringTools;
using haxe.io.Path;

@:cmd
class Main {
	
	public var input:String;
	@alias('w') public var width:Int = 800;
	@alias('h') public var height:Int = 600;
	public var script:String;
	@alias('s') public var scripts:Array<String> = [];
	public var show:Bool = false;
	public var wait:Bool = false;
	public var outputDir:String;

	private var electron:Dynamic;
	private var ipcMain:{on:String->Function->Dynamic};
	private var contents:WebContents;
	private var window:BrowserWindow;
	private var filename:String;
	private var port:Int;
	private var queue:StringMap<Bool> = new StringMap();
	private var queueKeys:Iterator<String>;
	
	public static function main() {
		App.on('ready', function() {
			var m = new Main( Sys.args() );
		} );
		
		App.on('window-all-closed', function() {
		  if (process.platform != 'darwin') {
		    App.quit();
		  }
		});
	}
	
	public function new(args:Array<String>) {
		@:cmd _;
		
		var config:Dynamic = { 
			width: width, height: height, show: show, center:true, 
		};
		
		electron = require('electron');
		ipcMain = electron.ipcMain;
		
		trace( 'scripts::', scripts );
		trace( 'input::', (Sys.getCwd() + '$input').normalize() );
		trace( 'output::', (Sys.getCwd() + '$outputDir').normalize() );
		trace( 'script::', (Sys.getCwd() + '/$script').normalize() );
		
		queueKeys = queue.keys();
		
		ipcMain.on('queue::add', modifyQueue);
		ipcMain.on('save::file', saveFile);
		ipcMain.on('final::html', handleHTML);
		ipcMain.on('final::failed', function() {
			trace( 'sending html failed' );
			App.quit();
		});
		
		var completed = new StringMap<Bool>();
		
		for (s in scripts) {
			var name = s.withoutExtension();
			
			completed.set( name, false );
			ipcMain.on('$name::complete', handleScriptCompletion.bind(_, _, name, completed));
			
		}
		
		if (script != null) config.webPreferences = { 
			preload:( Sys.getCwd() + '/$script' ).normalize() 
		};
		
		filename = input.withoutDirectory();
		if (filename == '') filename = 'index.html';
		var inputDir = input.directory();
		var ipcMain = require('electron').ipcMain;
		var server = require('node-static');
		var files = untyped __js__("new {0}", server.Server((Sys.getCwd() + '$inputDir').normalize()) );
		
		var ns = require('http').createServer(function (request, response) {
			request.addListener('end', function () {
		      files.serve(request, response);
					
		  }).resume();
		});
		ns.listen(0);
		port = ns.address().port;
		trace( 'loading $filename' );
		window = new BrowserWindow( cast config );
		window.on('closed', function() {
	    window = null;
	  });
		
		/*trace( 'loading url http://localhost:${ns.address().port}/$filename' );
		window.loadURL( 'http://localhost:${ns.address().port}/$filename' );*/
		window.webContents.on('did-finish-load', onLoad);
		//window.webContents.on('dom-ready', onLoad);
		window.webContents.on('did-fail-load', function(e, c, d, u, b) {
		trace( 'page failed', window.webContents.getUrl()/*, e, c, d, u, b*/ );
			//App.quit();
			//trace( 'reloading $u' );
			//window.webContents.reload();
			/*
			event Event
			errorCode Integer
			errorDescription String
			validatedURL String
			isMainFrame Boolean
			*/
			
			//processQueue();
			
		});
		window.webContents.on('did-get-response-details', function(e, s, nu, ou, c, m, r, h, t) {
			/*
			event Event
			status Boolean
			newURL String
			originalURL String
			httpResponseCode Integer
			requestMethod String
			referrer String
			headers Object
			resourceType String
			*/
			if (c == 404) {
				//trace(e, s, nu, ou, c, m, r, h, t);
				var key = ou.replace( 'http://localhost:$port', '' );
				if (queue.exists(key)) {
					queue.set( key, true );
					window.webContents.stop();
					setImmediate( processQueue );
					
				}
				
			}
			
		});
		
		modifyQueue('manual', Serializer.run([filename]) );
		setImmediate( processQueue );
	}
	
	private function onLoad():Void {
		var key = window.webContents.getUrl().replace( 'http://localhost:$port', '' );
		trace( 'page loaded', window.webContents.getUrl(), key );
		if (queue.exists(key)) {
			queue.set( key, true );
			window.webContents.openDevTools();
			//untyped window.webContents.debugger.on('detach', function(_) App.quit());
			//window.webContents.on('crashed', function(_) App.quit());
			//window.webContents.on('devtools-closed', function(_) App.quit());
			//while(true) if (!window.webContents.isLoading()) break;
			
			window.webContents.send('scripts::required', Serializer.run( scripts ));
			
		}
		
	}
	
	private function handleScriptCompletion(event:String, args:Array<String>, name:String, map:StringMap<Bool>):Void {
		map.set( name, true );
		trace( '$name is done' );
		var allDone = false;
		for (key in map.keys()) {
			var previous = allDone;
			allDone = map.get( key );
			if (previous && !allDone) break;
			
		}
		trace( 'all done?', allDone );
		if (allDone) {
			trace( window.webContents.getUrl() );
			window.webContents.send('scripts::completed', 'true');
		
		}
		
	}
	
	private function handleHTML(event:String, arg:String):Void {
		if (arg == 'failed') {
			continueOrQuit();
			
		} else {
			saveFile(event, Serializer.run( { filename: filename, content: arg.replace('\n', '\r\n') } ));
			
		}
	}
	
	private function continueOrQuit():Void {
		trace( 'queue length', [for (k in queue.keys()) if (!queue.get(k)) k].length);
		if ([for (k in queue.keys()) if (!queue.get(k)) k].length != 0) {
			trace( 'still in queue', [for (k in queue.keys()) if (!queue.get(k)) k] );
			setImmediate( processQueue );
			
		} else {
			if (!wait) App.quit();
			
		}
	}
	
	private function saveFile(event:String, arg:String):Void {
		var data:{filename:String, content:String} = Unserializer.run( arg );
		var path = window.webContents.getUrl().replace( 'http://localhost:${port}', '' );
		var dirname = path.directory();
		
		if (data.filename == null || data.filename == '') {
			trace( 'data filename cannot be empty.' );
			return;
		}
		
		if (data.content == null || data.content == '') {
			trace( 'data content cannot be empty.' );
			return;
		}
		
		if (dirname == '') dirname == '/';
		
		try {
			if (!sys.FileSystem.exists( Sys.getCwd() + '/$outputDir/$dirname/' )) {
				createDir( Sys.getCwd() + '/$outputDir/$dirname/', function() {
					writeFile( (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize(), data.content, 'utf8', function(error) {
						if (error != null) trace( error );
						trace( 'saved file ${data.filename} successfully.' );
						continueOrQuit();
					} );
					
				});
				
			} else {
				writeFile( (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize(), data.content, 'utf8', function(error) {
					if (error != null) trace( error );
					trace( 'saved file ${data.filename} successfully.' );
					continueOrQuit();
				} );
				
			}
			
		} catch (e:Dynamic) {
			trace( e );
			continueOrQuit();
			
		}
	}
	
	private function createDir(path:String, cb:Function):Void {
		untyped mkdir( path, function(error) {
			if (error != null) {
				var parts = path.split( '/' );
				parts.pop();
				createDir( parts.join( '/' ), cb );
			} else {
				cb();
				
			}
			
		});
	}
	
	private function modifyQueue(event:String, arg:String):Void {
		var links:Array<String> = [];
		links = Unserializer.run(arg);
		trace( 'recieved', links );
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
	
}
