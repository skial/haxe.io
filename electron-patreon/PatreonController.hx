package ;

import js.Node.*;
import tink.Json.*;
import js.node.Fs.*;
import js.Node.process;
import js.node.Crypto.*;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.Constraints.Function;

import CommunityPatreon.PatreonData;
import CommunityPatreon.PatreonPayload;
import CommunityPatreon.PatreonDuration;

using StringTools;
using haxe.io.Path;

@:cmd
class PatreonController {
	
	private static var app:Dynamic;
	private static var electron:Dynamic;
	private static var ipcMain:{on:String->Function->Dynamic};
	
	public static function main() {
		electron = require('electron');
		app = electron.app;
		ipcMain = electron.ipcMain;
		trace( 'starting');
		app.on('ready', function() {
			var m = new PatreonController( Sys.args() );
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
	private var cwd = Sys.getCwd();
	private var config:Dynamic = { webPreferences:{} };
	private var payload:PatreonPayload;
	private var counter:Int = 0;
	
	public function new(args:Array<String>) {
		@:cmd _;
		
		if (script != null) config.webPreferences.preload = '$cwd/$script'.normalize();
		if (input == null) app.quit();
		
		readFile( '$cwd/$input'.normalize(), {encoding:'utf8'}, function(e, d) {
			if (e != null) throw e;
			process( payload = parse(d) );
		} );
	}
	
	private function process(payload:PatreonPayload):Void {
		for (page in payload.data) {
			counter++;
			var browser = untyped __js__('new {0}', electron.BrowserWindow)( config );
			ipcMain.on(page.uri, updatePayload.bind(browser, page.uri, _, _));
			browser.on('closed', function() browser = null );
			browser.webContents.on('did-finish-load', onLoad.bind(browser, page));
			browser.loadURL( page.uri );
			
		}
		
	}
	
	private function onLoad(browser:Dynamic, data:PatreonData):Void {
		trace( 'loaded ' + data.uri );
		browser.webContents.openDevTools();
		browser.webContents.send('payload', stringify(data));
	}
	
	private function updatePayload(browser:Dynamic, uri:String, event:Dynamic, json:String):Void {
		for (i in 0...payload.data.length) if (payload.data[i].uri == uri) {
			trace( uri );
			payload.data[i] = parse(json);
			break;
		
		}
		counter--;
		browser.close();
		if (counter < 1) {
			trace( 'saving $input' );
			writeFile( '$cwd/$output'.normalize(), stringify(payload), function(error) {
				if (error != null) trace( error );
				trace( 'exiting' );
				app.quit();
			} );
			
		}
	}
	
}
