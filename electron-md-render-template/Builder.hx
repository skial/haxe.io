package ;

import js.Node.*;
import js.node.Fs;
import js.html.*;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import haxe.Constraints.Function;
import Controller.Data;
import Controller.Payload;

using StringTools;
using haxe.io.Path;

class Builder {
	
	public static var storage:Storage = window.sessionStorage;
	
	private var max:Int = 2;
	private var counter:Int = 0;
	private var waitFor:Int = 100;	// wait 100ms.
	private var timestamp:Float = 0;
	private var timeoutId:Null<Int>;
	private var maxDuration:Int = 750;	// wait 750ms.
	private var observer:MutationObserver;
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	private var scripts:Array<String> = [];
	private var completedScripts:Map<String, Bool> = new Map();
	
	public static function main() {
		var con:Builder = new Builder();
	}
	
	public function new() {
		trace( 'running script' );
		electron = require('electron');
		
		observer = new MutationObserver(mutation);
		observer.observe(window.document, {childList:true, subtree:true});
		
		ipcRenderer = electron.ipcRenderer;
		ipcRenderer.once('data:payload', function(event:String, arg:String) {
			var data:Data = tink.Json.parse( arg );
			storage.setItem( 'data', arg );
			
			scripts = data.scripts;
			
			processHtml( data.html );
			processJson( data.payload );
			
		});
	}
	
	public function processHtml(data:String) {
		console.log( 'processing html' );
		var node = window.document.querySelector('#markdown');
		
		if (node != null) {
			var template:TemplateElement = cast window.document.createElement('template');
			template.innerHTML = data;
			node.parentNode.replaceChild( window.document.importNode(template.content, true), node );
			window.document.dispatchEvent( new CustomEvent('DocumentHtmlData', {detail:true, bubbles:true}) );
			
		}
		
		counter++;
		if (counter >= max && timeoutId != null) timeoutId = cast setTimeout( preCheck, waitFor );
		
	}
	
	public function processJson(data:Payload) {
		window.document.dispatchEvent( new CustomEvent('DocumentJsonData', {detail:data, bubbles:true}) );
		console.log( 'processing json', data );
		
		counter++;
		if (counter >= max && timeoutId != null) timeoutId = cast setTimeout( preCheck, waitFor );
		
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
				for (script in scripts) {
					var name = script.withoutExtension();
					require( '$__dirname/$script'.normalize() );
					completedScripts.set( name, false );
					window.document.addEventListener( '$name:complete', handleScriptCompletion );
					
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
		// Wait until `maxDuration` has passed of no dom changes before continuing.
		clearTimeout( cast timeoutId );
		observer.disconnect();
		counter = -1;
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
			ipcRenderer.send('save', doctype + html);
			
		} else {
			ipcRenderer.send('save', 'failed');
			
		}
		
	}
	
	private function handleScriptCompletion(event:CustomEvent):Void {
		completedScripts.set( event.detail, true );
		
		if (timeoutId != null) clearTimeout( cast timeoutId );
		
		timestamp = haxe.Timer.stamp() - timestamp;
		
		if (timestamp < maxDuration) {
			timeoutId = cast setTimeout( preCheck, waitFor );
			
		} else {
			timeoutId = cast setTimeout( preCheck, waitFor );
			
		}
	}
	
	private function mutation(changes:Array<MutationRecord>, observer:MutationObserver):Void {
		for (change in changes) switch change.type {
			case 'attributes':
				
			case 'characterData':
				
			case 'childList':
				//console.log( 'child list mutation update' );
				if (timeoutId != null) clearTimeout( cast timeoutId );
				
				timestamp = haxe.Timer.stamp() - timestamp;
				
				if (timestamp < maxDuration) {
					timeoutId = cast setTimeout( preCheck, waitFor );
					
				} else {
					timeoutId = cast setTimeout( preCheck, waitFor );
					
				}
				
			case _:
				
		}
	}
	
}
