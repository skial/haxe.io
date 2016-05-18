package ;

import js.Node.*;
import js.Browser.*;
import js.html.Node;
import js.html.Element;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import js.html.DOMElement;
import haxe.Constraints.Function;

using haxe.io.Path;

class CheckMissing {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var cm = new CheckMissing();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var script = window.document.querySelectorAll( 'head script[src*="haxe.io.js"]' )[0];
		
		if (script == null) {
			var head = cast window.document.getElementsByTagName( 'head' )[0];
			
			if (head != null) {
				var element:DOMElement = window.document.createElement( 'script' );
				element.setAttribute( 'src', '/js/haxe.io.js' );
				element.setAttribute( 'async', 'async' );
				element.setAttribute( 'defer', 'defer' );
				cast(head,Node).appendChild( element );
				
				ipcRenderer.send('checkmissing::complete', 'true');
				
			} else {
				ipcRenderer.send('checkmissing::complete', 'false');
				
			}
			
		} else {
			ipcRenderer.send('checkmissing::complete', 'false');
			
		}
	}
	
}
