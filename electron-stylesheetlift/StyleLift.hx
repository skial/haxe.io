package ;

import js.Node.*;
import js.node.Http;
import js.node.Https;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import js.html.DOMElement;
import haxe.Constraints.Function;

using haxe.io.Path;

class StyleLift {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var lifter = new StyleLift();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		// naughty embedded scripts injecting <link> tags.
		var links = window.document.querySelectorAll('body link');
		trace( links.length );
		var completed = 0;
		ipcRenderer.on('stylelift::saved', function() {
			trace( 'style lift checking completion', completed );
			completed++; 
			if (completed >= (links.length - 1)) ipcRenderer.send('stylelift::complete', 'true');
		} );
		if (links.length > 0) trace( [for(l in links) untyped l.getAttribute('href')] );
		if (links.length > 0) for (node in links) {
			var link:DOMElement = cast node;
			var url:String = link.getAttribute('href');
			var request = (url.indexOf('https') > -1) ? Https.request(url) : Http.request(url);
			var content = '';
			request.on('response', function( res ) {
				
	    	res.on('data', function( data ) {
					content += data.toString();
					//trace( content );
					
				} );
				res.on('end', function(d) {
					//console.log( d );
					trace( 'completed downloading $url' );
					ipcRenderer.send('save::file', Serializer.run( { filename: url.withoutDirectory(), content: content, reply:'stylelift::saved' } ));
					
				});
			} );
			
			request.end();
			
		} else {
			ipcRenderer.send('stylelift::complete', 'false');
			
		}
	}
	
}
