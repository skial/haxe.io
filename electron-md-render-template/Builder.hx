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
		var con:Builder = null;
		trace( 'waiting to finish loading...' );
		switch (window.document.readyState) {
			case 'complete':
				con = new Builder();
				
			case _:
				window.document.addEventListener(
					'DOMContentLoaded', 
					function() con = new Builder(),
					false
				);
				
		}
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
		//sanatize([for (i in 0...window.document.children.length) window.document.children[i]]);
		//clean();
	}
	
	public function processJson(data:Payload) {
		trace( 'processing json' );
		trace( data );
		
		
	}
	
	public function sanatize(children:Array<Element>):Void {
		for (child in children) {
			if (child.shadowRoot != null) {
				trace( child.shadowRoot.children );
				
				if (child.shadowRoot.children.length == 1) {
					child.parentNode.replaceChild(child.shadowRoot.children[0], child);
					
				} else if (child.shadowRoot.children.length > 1) {
					var node = child.shadowRoot.children[0];
					child.parentNode.replaceChild(node, child);
					
					for (i in 1...child.shadowRoot.children.length) if (child.shadowRoot.children[i] != null) {
						node.parentNode.insertBefore(child.shadowRoot.children[i], node.nextSibling);
						node = child.shadowRoot.children[i];
						
					}
					
				}
				
			}
			
			if (child.children != null && child.children.length > 0) {
				sanatize( [for (i in 0...child.children.length) child.children[i]] );
				
			}
			
		}
		
	}
	
	public function clean():Void {
		for (link in window.document.querySelectorAll( 'link[rel="import"]' )) {
			link.parentNode.removeChild( link );
			
		}
	}
	
}
