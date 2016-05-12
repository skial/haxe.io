package ;

import js.Node.*;
import js.node.Fs.*;
import js.Node.process;
import electron.main.App;
import electron.main.WebContents;
import electron.main.BrowserWindow;
import electron.main.BrowserWindowOptions;

using StringTools;
using haxe.io.Path;

@:cmd
class Main {
	
	public var input:String;
	public var script:String;
	public var show:Bool = false;
	public var outputDir:String;
	
	private var contents:WebContents;
	private var window:BrowserWindow;
	
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
			width:800, height:600, show:show, center:true, 
		};
		
		trace( (Sys.getCwd() + '$input').normalize() );
		trace( (Sys.getCwd() + '$outputDir').normalize() );
		trace( (Sys.getCwd() + '/$script').normalize() );
		
		if (script != null) config.webPreferences = { 
			preload:( Sys.getCwd() + '/$script' ).normalize() 
		};
		
		var filename = input.withoutDirectory();
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
		trace( 'loading $filename' );
		window = new BrowserWindow( cast config );
		window.on('closed', function() {
	    window = null;
	  });
		
		ipcMain.on('haxeCharacterList', function(event, arg) {
			trace( arg );
			var path = window.webContents.getUrl().replace( 'http://localhost:${ns.address().port}', '' );
			var dirname = path.directory();
			if (dirname == '') dirname == '/';
			//var filename = path.withoutDirectory();
			trace( (Sys.getCwd() + '/$outputDir/$dirname/$filename').normalize() );
			try {
				writeFileSync( (Sys.getCwd() + '/$outputDir/$dirname/$filename').normalize(), arg.replace('\n', '\r\n'), 'utf8' );
				/*writeFile( (Sys.getCwd() + '/$outputDir/$dirname/$filename').normalize(), arg.replace('\n', '\r\n'), 'utf8', function(error) {
					if (error == null) trace( 'it saved!' );
					if (!show) App.quit();
				} );*/
				App.quit();
			} catch (e:Dynamic) {
				App.quit();
			}
		});
		
		ipcMain.on('haxeCharacterList-close', function(event, arg) {
			App.quit();
		});
		trace( 'loading url http://localhost:${ns.address().port}/$filename' );
		window.loadURL( 'http://localhost:${ns.address().port}/$filename' );
		window.webContents.openDevTools();
	}
	
}
