package ;

import js.Node.*;
import js.Browser.*;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import js.html.DOMElement;
import haxe.Constraints.Function;

class Sitemap {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var sitemap = new Sitemap();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var body = window.document.getElementsByTagName( 'body' )[0];
		
		if (body != null) {
			var links = [];
			trace( body.querySelectorAll( 'main li[itemtype]' ).length );
			var items = [for (item in body.querySelectorAll( 'main li[itemtype]' )) if (cast (item,DOMElement).getAttribute('id') != 'link') item];
			for (item in items) links.push( cast (cast (item,DOMElement).querySelectorAll( 'a[href]' )[0],DOMElement).getAttribute('href') );
			
			trace( links.length );
			trace( links );
		}
		
	}
	
}
