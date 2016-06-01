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

class Sitemap {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var sitemap = new Sitemap();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var path = window.document.location.pathname;
		
		if (path == '/' || path == '/index.html') {
			var body = window.document.getElementsByTagName( 'body' )[0];
			
			if (body != null) {
				var links = [];
				var items = [for (item in body.querySelectorAll( 'main li[itemtype]' )) if (cast (item,DOMElement).getAttribute('id') != 'link') item];
				for (item in items) links.push( cast (cast (item,DOMElement).querySelectorAll( 'a[href]' )[0],DOMElement).getAttribute('href') );
				
				if (links.length > 0) {
					var xml = new StringBuf();
					
					xml.add( '<?xml version="1.0" encoding="UTF-8"?>\n' );
					xml.add( '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n\t' );
					
					xml.add( '<url>\n\t\t' );
						xml.add( '<loc>http://www.haxe.io/</loc>\n\t\t' );
						xml.add( '<changefreq>weekly</changefreq>\n\t' );
					xml.add( '</url>\n\t' );
					
					for (link in links) {
						var path = 'http://www.haxe.io/$link'.normalize().addTrailingSlash();
						
						xml.add( '<url>\n\t\t' );
							xml.add( '<loc>$path</loc>\n\t\t' );
						xml.add( '</url>\n\t' );
						
					}
					
					xml.add( '</urlset>' );
					
					ipcRenderer.on('sitemap::saved', function() ipcRenderer.send('sitemap::complete', 'true'));
					ipcRenderer.send('save::file', Serializer.run( { filename: 'sitemap.xml', content: xml.toString(), reply:'sitemap::saved' } ));
					
				}
				
			}
			
		} else {
			ipcRenderer.send('sitemap::complete', 'false');
			
		}
		
	}
	
}
