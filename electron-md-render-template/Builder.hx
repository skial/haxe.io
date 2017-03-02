package ;

import js.Node.*;
import js.node.Fs;
import js.html.*;
import js.Browser.*;
import haxe.Serializer;
import Controller.Data;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import Controller.Payload;
import haxe.DynamicAccess;
import haxe.Constraints.Function;
import uhx.pati.Consts.EventConsts;

import electron.renderer.IpcRenderer;

using StringTools;
using haxe.io.Path;

class Builder {
	
	public static var storage:Storage = window.sessionStorage;
	
	private var max:Int = 2;
	private var waitFor:Int = 100;	// wait 100ms.
	private var timestamp:Float = 0;
	private var timeoutId:Null<Int>;
	private var maxDuration:Int = 1000;	// wait 1000ms.
	private var observer:MutationObserver;
	
	private var scripts:Array<String> = [];
	private var completedScripts:Map<String, Bool> = new Map();
	
	public static function main() {
		var con:Builder = new Builder();
		
	}
	
	public function new() {
		IpcRenderer.once('data:payload', function(event:String, arg:String) {
			var data:Data = tink.Json.parse( arg );
			console.log( data );
			storage.setItem( 'data', arg );
			scripts = data.scripts;
			
			processHtml( data.html );
			processJson( data.payload );
			
		});
		
		IpcRenderer.once('scripts:watch', function(event:String, arg:String) {
			observer = new MutationObserver(mutation);
			observer.observe(window.document, {childList:true, subtree:true});
			
		});
	}
	
	public function processHtml(data:String) {
		var node = window.document.querySelector('#markdown');
		
		if (node != null) {
			var template:TemplateElement = cast window.document.createElement('template');
			template.innerHTML = data;
			node.parentNode.replaceChild( window.document.importNode(template.content, true), node );
			
		}
		
	}
	
	public function processJson(data:Payload) {
		window.document.dispatchEvent( new CustomEvent(JsonDataRecieved, {detail:data, bubbles:true}) );
	}
	
	public function clean():Void {
		for (link in window.document.querySelectorAll( 'link[rel="import"]' )) {
			link.parentNode.removeChild( link );
			
		}
		
	}
	
	public function preCheck():Void {
		timestamp = haxe.Timer.stamp() - timestamp;
		
		if (timestamp < maxDuration) {
			if ([for (k in completedScripts.keys()) k].length == 0) {
				 if (scripts.length > 0) for (script in scripts) {
					var name = script.withoutDirectory().withoutExtension();
					
					require( '$__dirname/$script'.normalize() );
					completedScripts.set( name, false );
					
					window.document.addEventListener( '$name:complete', handleScriptCompletion, untyped {once:true} );
					
				} else {
					timeoutId = cast setTimeout( save, waitFor );
					
				}
				
			} else {
				var match = true;
				
				for (key in completedScripts.keys()) {
					match = completedScripts.get( key );
					if (!match) break;
					
				}
				
				timeoutId = cast setTimeout( save, waitFor );
				
			}
			
		} else {
			timeoutId = cast setTimeout( preCheck, waitFor );
			
		}
		
	}
	
	public function save():Void {
		console.log('saving page');
		observer.disconnect();
		// Wait until `maxDuration` has passed of no dom changes before continuing.
		clearTimeout( cast timeoutId );
		//counter = -1;
		clean();
		
		var node = window.document.doctype;
		var doctype = node != null ? "<!DOCTYPE "
				 + node.name
				 + (node.publicId != null ? ' PUBLIC "' + node.publicId + '"' : '')
				 + (node.publicId == null && node.systemId != null ? ' SYSTEM' : '') 
				 + (node.systemId != null ? ' "' + node.systemId + '"' : '')
				 + '>\n' : '';
				 
		var html = window.document.documentElement.outerHTML;
		
		if (html != null && html != '<html><head></head><body></body></html>') {
			IpcRenderer.send('save', doctype + html);
			
		} else {
			IpcRenderer.send('save', 'failed');
			
		}
		
	}
	
	private function handleScriptCompletion(event:CustomEvent):Void {
		completedScripts.set( event.detail, true );
		
		if (timeoutId != null) clearTimeout( cast timeoutId );
		
		timestamp = haxe.Timer.stamp() - timestamp;
		timeoutId = cast setTimeout( preCheck, waitFor );
	}
	
	private function mutation(changes:Array<MutationRecord>, observer:MutationObserver):Void {
		if (timeoutId != null) clearTimeout( cast timeoutId );
		
		timestamp = haxe.Timer.stamp() - timestamp;
		timeoutId = cast setTimeout( preCheck, waitFor );
		
	}
	
}
