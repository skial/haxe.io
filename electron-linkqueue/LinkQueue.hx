package ;

import js.Node.*;
import js.Browser.*;
import js.html.Node;
import js.node.Url.*;
import js.html.Element;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import js.html.DOMElement;
import js.node.Url.UrlData;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

class LinkQueue {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var lq = new LinkQueue();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var body = window.document.getElementsByTagName('body')[0];
		
		if (body != null) {
			var links = [];
			var href:String = null;
			var url:UrlData = null;
			
			for (a in body.querySelectorAll('a[href]')) {
				href = cast(a,DOMElement).getAttribute('href');
				url = parse( href );
				if (!href.startsWith('#') && href.startsWith('/') && url.host == null || url.host == '') {
					links.push( href );
				
				} else {
					if (url.host != null && url.host.indexOf('haxe.io') > -1) trace( href );
				
				}
				
			};
			
			trace( 'link length::', links.length );
			trace( links );
			if (links.length > 0) ipcRenderer.send('queue::add', Serializer.run( links ));
			ipcRenderer.send('linkqueue::complete', 'true');
			
		} else {
			ipcRenderer.send('linkqueue::complete', 'false');
			
		}
		
	}
	
}
