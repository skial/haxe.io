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
		ipcRenderer.on('json', function(e, d) processJson( haxe.Json.parse(d) ));
	}
	
	public function processHtml(data:String) {
		trace( 'processing html' );
		var node = window.document.querySelector('#markdown');
		var template:TemplateElement = cast window.document.createElement('template');
		template.innerHTML = data;
		node.parentNode.replaceChild( window.document.importNode(template.content, true), node );
	}
	
	public function processJson(data:DynamicAccess<DynamicAccess<String>>) {
		trace( 'processing json' );
		trace( data );
		
		
	}
	
}
