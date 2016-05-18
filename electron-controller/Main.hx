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
		
		trace( 'loading url http://localhost:${ns.address().port}/$filename' );
		window.loadURL( 'http://localhost:${ns.address().port}/$filename' );
		window.webContents.on('did-finish-load', function() {
			window.webContents.openDevTools();
			untyped window.webContents.debugger.on('detach', function(_) App.quit());
			window.webContents.on('crashed', function(_) App.quit());
			window.webContents.on('devtools-closed', function(_) App.quit());
			window.webContents.send('scripts::required', Serializer.run( scripts ));
			
		});
	}
	
	private function handleScriptCompletion(event:String, args:Array<String>, name:String, map:StringMap<Bool>):Void {
		trace( name, 'completed with ', args );
		map.set( name, true );
		
		var allDone = false;
		for (key in map.keys()) allDone = map.get( key );
		if (allDone) window.webContents.send('scripts::completed', 'true');
	}
	
	private function handleHTML(event:String, arg:String):Void {
		try {
			saveFile(event, Serializer.run( { filename: filename, content: arg.replace('\n', '\r\n') } ));
			if (!wait) App.quit();
			
		} catch (e:Dynamic) {
			trace( e );
			App.quit();
			
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
		trace( 'saving file to::', (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize() );
		
		try {
			writeFileSync( (Sys.getCwd() + '/$outputDir/$dirname/${data.filename}').normalize(), data.content, 'utf8' );
			
		} catch (e:Dynamic) {
			trace( e );
			
		}
	}
	
}
