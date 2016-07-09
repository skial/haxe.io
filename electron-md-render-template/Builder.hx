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
	
	private var max:Int = 2;
	private var counter:Int = 0;
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var con:Builder = new Builder();
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
			window.document.dispatchEvent( new CustomEvent('DocumentHtmlData', {detail:true, bubbles:true}) );
			
		}
		
		counter++;
		if (counter >= max) save();
		
	}
	
	public function processJson(data:Payload) {
		window.document.dispatchEvent( new CustomEvent('DocumentJsonData', {detail:data, bubbles:true}) );
		trace( 'processing json' );
		console.log( data );
		
		counter++;
		if (counter >= max) save();
		
	}
	
	public function clean():Void {
		for (link in window.document.querySelectorAll( 'link[rel="import"]' )) {
			link.parentNode.removeChild( link );
			
		}
		
	}
	
	public function save():Void {
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
	
}
