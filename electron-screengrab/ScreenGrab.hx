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

import electron.Rectangle;
import electron.renderer.Remote;
import electron.main.BrowserWindow;

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
	
	private var browser:BrowserWindow;
	
	public static function main() {
		data = tink.Json.parse( window.sessionStorage.getItem( 'data' ) );
		var sg = new ScreenGrab( data.args );
	}
	
	public function new(args:Array<String>) {
		browser = Remote.getCurrentWindow();
		dirname = data.payload.output.parts.slice( 1, data.payload.output.parts.length - 1 ).join('/');
		
		@:cmd _;
		
		setTimeout( function() {
			browser.webContents.closeDevTools();
			
			setTimeout( attemptScreenshot, 250 );
			
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
		console.log( 'attempting to take screenshot' );
		if (browser != null && browser.webContents != null) {
			
			if (browser.isFocused()) browser.blur();
			
			var rect:Rectangle = {x:0, y:0, width:width, height:height};
			
			browser.setBounds( rect );
			
			setTimeout( function () browser.capturePage(rect, function(image) {
				var path:String = (browser.webContents.getURL():String).replace( 'http://localhost:${data.port}', '' );
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
				
			}), 500 );	// Have to wait until internal? graphics cache? updates with resized browser.
			
		} else {
			finish();
			
		}
		
	}
	
	private function finish():Void {
		setTimeout( function() {
			browser.webContents.openDevTools();
			window.document.dispatchEvent( new CustomEvent('screengrab:complete', {detail:'screengrab', bubbles:true, cancelable:true}) );
		}, 350 );
	}
	
}
