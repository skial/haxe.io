package ;

import js.Node.*;
import js.node.Fs.*;
import js.html.*;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

@:cmd
class ScreenGrab {
	
	private static var data:{payload:{output:{raw:String, parts:Array<String>}}, port:Int, args:Array<String>};
	
	@alias public var width:Int = 1280;
	@alias public var height:Int = 800;
	
	/**
	The base path to save resources to.
	*/
	@alias('rs')
	public var resourcePath:String;
	private var dirname:String;
	
	private var remote:Dynamic;
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	private var browser:Dynamic;
	
	public static function main() {
		data = tink.Json.parse( window.sessionStorage.getItem( 'data' ) );
		var sg = new ScreenGrab( data.args );
	}
	
	public function new(args:Array<String>) {
		electron = require('electron');
		remote = electron.remote;
		ipcRenderer = electron.ipcRenderer;
		
		browser = remote.getCurrentWindow();
		dirname = data.payload.output.parts.slice( 1, data.payload.output.parts.length - 1 ).join('/');
		
		@:cmd _;
		
		setTimeout( function() {
			browser.webContents.closeDevTools();
			
			setTimeout( attemptScreenshot, 0 );
			
		}, 0 );
		
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
	
	private function attemptScreenshot():Void {
		if (browser != null && browser.webContents != null) {
			
			if (browser.isFocused()) browser.blur();
			
			var rect = {x:0, y:0, width:width, height:height};
			
			browser.setBounds( rect );
			
			setTimeout( function () browser.capturePage(rect, function(image) {
				var path:String = (browser.webContents.getURL():String).replace( 'http://localhost:${data.port}', '' );
				//var size:{width:Int,height:Int} = image.getSize();
				var fullPath = Sys.getCwd() + '/$resourcePath/img/$dirname/'.normalize().addTrailingSlash();
				
				if (!sys.FileSystem.exists(fullPath)) {
					createDir( fullPath, function () writeFile( '$fullPath/preview.png', image.toPng(), function(error) {
						if (error != null) console.log( error );
						console.log( 'saving preview of ${browser.webContents.getURL()} to $fullPath/preview.png' );
						finish();
						
					}));
				
				} else {
					writeFile( '$fullPath/preview.png', image.toPng(), function(error) {
						if (error != null) console.log( error );
						console.log( 'saving preview of ${browser.webContents.getURL()} to $fullPath/preview.png' );
						finish();
						
					});
					
				}
				
			}), 1000 );	// Have to wait until internal? graphics cache? updates with resized browser.
			
		} else {
			finish();
			
		}
		
	}
	
	private function finish():Void {
		setTimeout( function() {
			browser.webContents.openDevTools();
			window.document.dispatchEvent( new CustomEvent('screengrab:complete', {detail:'screengrab', bubbles:true, cancelable:true}) );
		}, 0 );
	}
	
}
