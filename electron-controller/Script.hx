package ;

import js.Node.*;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

class Script {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var con:Script = null;
		
		switch (window.document.readyState) {
			case 'complete':
				con = new Script();
				
			case _:
				window.document.addEventListener(
					'DOMContentLoaded', 
					function() con = new Script(),
					false
				);
				
		}
		
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		ipcRenderer.on('scripts::required', recieveScripts);
		ipcRenderer.on('scripts::completed', sendHTML);
		
	}
	
	private function recieveScripts(event:String, arg:String) {
		var scripts:Array<String> = Unserializer.run( arg );
		var loaded = new StringMap<Dynamic>();
		trace( event, scripts );
		
		for (script in scripts) {
			var name = script.withoutExtension();
			loaded.set( script, require( '$__dirname/$script' ) );
			
		}

	}
	
	private function sendHTML(event:String, arg:String) {
		var node = window.document.doctype;
		var doctype = node != null ? "<!DOCTYPE "
				 + node.name
				 + (node.publicId != null ? ' PUBLIC "' + node.publicId + '"' : '')
				 + (node.publicId == null && node.systemId != null ? ' SYSTEM' : '') 
				 + (node.systemId != null ? ' "' + node.systemId + '"' : '')
				 + '>\n' : '';
				 
		var html = window.document.documentElement.outerHTML;
		if (html != null && html != '<html><head></head><body></body></html>') {
			ipcRenderer.send('final::html', doctype + window.document.documentElement.outerHTML);
			
		} else {
			ipcRenderer.send('final::html', 'failed');
			
		}
	}
	
}
