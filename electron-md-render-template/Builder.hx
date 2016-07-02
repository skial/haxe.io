package ;

import js.Node.*;
import js.node.Fs;
import js.Browser.*;
import js.html.Node;
import js.html.Element;
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
		ipcRenderer.on('payload', function(e, d) process( haxe.Json.parse(d) ));
	}
	
	public function process(data:DynamicAccess<DynamicAccess<String>>) {
		trace( 'processing' );
		trace( data );
	}
	
}
