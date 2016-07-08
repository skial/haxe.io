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
import js.html.DOMElement;
import haxe.Constraints.Function;
import Controller.Payload;

using StringTools;

class Builder {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var con:Builder = new Builder();
		/*trace( 'waiting to finish loading...' );
		switch (window.document.readyState) {
			case 'complete':
				con = new Builder();
				
			case _:
				window.document.addEventListener(
					'DOMContentLoaded', 
					function() con = new Builder(),
					false
				);
				
		}*/
	}
	
	public function new() {
		trace( 'running script' );
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		ipcRenderer.on('html', function(e, d) processHtml( d ));
		ipcRenderer.on('json', function(e, d) processJson( tink.Json.parse(d) ));
	}
	
	public function processHtml(data:String) {
		trace( 'processing html' );
		var node = window.document.querySelector('#markdown');
		
		if (node != null) {
			var template:TemplateElement = cast window.document.createElement('template');
			template.innerHTML = data;
			node.parentNode.replaceChild( window.document.importNode(template.content, true), node );
			
		}
		//clean();
		
	}
	
	public function processJson(data:Payload) {
		window.document.dispatchEvent( new CustomEvent('DocumentJsonData', {detail:data, bubbles:true}) );
		trace( 'processing json' );
		console.log( data );
		
		/*var shadowPoints = window.document.querySelectorAll('content[select]');
		for (point in shadowPoints) {
			var content:ContentElement = untyped point;
			var parent = content.parentNode;
			var selector = content.getAttribute('select');
			var matches = window.document.querySelectorAll(selector);
			for (match in matches) {
				parent.insertBefore(window.document.importNode(match, true), content);
				
			}
			
		}*/
		
	}
	
	public function clean():Void {
		for (link in window.document.querySelectorAll( 'link[rel="import"]' )) {
			link.parentNode.removeChild( link );
			
		}
	}
	
}
