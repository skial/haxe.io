package ;

import js.Node.*;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import js.html.DOMElement;
import haxe.Constraints.Function;

using haxe.io.Path;

class ScriptStripper {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var scriptstripper = new ScriptStripper();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var scripts = window.document.querySelectorAll('body script');
		trace( scripts.length );
		if (scripts.length > 0) trace( [for (s in scripts) untyped s.getAttribute('src')] );
		if (scripts.length > 0) for (node in scripts) {
			var script:DOMElement = cast node;
			untyped if (script.readyState != null && script.readyState == 'complete') {
				remove( script );
				
			} else if (script.onreadystatechange != null) {
				script.onreadystatechange = remove.bind( script );
				
			} else {
				remove( script );
			}
			
		}
		
		ipcRenderer.send('scriptstripper::complete', 'true');
	}
	
	private function remove(script:DOMElement):Void {
		if (script.parentNode != null) script.parentNode.removeChild( script );
	}
	
}
