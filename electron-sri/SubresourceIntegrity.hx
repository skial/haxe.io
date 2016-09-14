package ;

import js.Node.*;
import js.node.Fs.*;
import js.Node.process;
import js.node.Crypto.*;
import js.Browser.*;
import js.html.Node;
import js.node.Url.*;
import js.html.Element;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import js.html.DOMElement;
import js.node.Url.UrlData;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

class SubresourceIntegrity {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	private var hashedPaths:StringMap<String> = new StringMap();
	private var input:String = '';
	private var counter:Int = 0;
	
	public static function main() {
		var sri = new SubresourceIntegrity();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var nodes = [for (n in window.document.querySelectorAll('link[href], script[src], body [src], meta[content*="ms"]')) n];
		
		for (node in nodes) {
			process( switch node.nodeName.toLowerCase() {
				case 'link': 'href';
				case 'script': 'src';
				case 'meta': 'content';
				case _: 'src';
			}, cast node );
			
		}
		
	}
	
	private function process(attr:String, node:DOMElement):Void {
		var value:String = node.getAttribute( attr );
		var url = parse( value, true, true );
		
		if (url.host == null || url.host == '') {
			counter += 2;
			
			if ((url.query:DynamicAccess<String>).exists('v')) {
				Reflect.deleteField(url, 'search');
				(url.query:DynamicAccess<String>).remove('v');

			}
			
			value = format( url );
			
			var sricb = modifiySri.bind(node, _, _);
			var urlcb = modifyUrl.bind(node, attr, _, _);
			var formattedUrl = format(url).normalize();
			
			hash('content::hash', formattedUrl, 'hex', urlcb);
			hash('content::hash', formattedUrl, 'base64', sricb);
			
		} else {
			if (url.host != null && url.host.indexOf('haxe.io') > -1) {
				counter += 2;
				var sricb = modifiySri.bind(node, _, _);
				var urlcb = modifyUrl.bind(node, attr, _, _);
				
				if ((url.query:DynamicAccess<String>).exists('v')) {
					Reflect.deleteField(url, 'search');
					(url.query:DynamicAccess<String>).remove('v');
					
				}
				
				url.protocol = url.hostname = url.host = '';
				
				var formattedUrl = format(url).normalize();
				hash('content::hash', formattedUrl, 'hex', urlcb);
				hash('content::hash', formattedUrl, 'base64', sricb);
				
			}
			
		}
	}
	
	private function modifyUrl(node:DOMElement, attr:String, event:String, arg:String):Void {
		if (arg != 'failed') {
			var value:String = node.getAttribute( attr );
			var url = parse( value, true, true );
			
			Reflect.deleteField(url, 'search');
			if (url.query == null) url.query = {};
			if ((url.query:DynamicAccess<String>).exists('v')) {
				Reflect.deleteField(url, 'search');
				(url.query:DynamicAccess<String>).remove('v');
				
			}
			
			(url.query:DynamicAccess<String>).set('v', arg);
			
			node.setAttribute( attr, format( url ));
			
		} else {
			console.log( 'sri hashing failed', event, arg, node.getAttribute(attr) );
			
		}
		
		counter--;
		
		if (counter < 1) ipcRenderer.send('version::complete', 'true');
	}
	
	private function modifiySri(node:DOMElement, event:String, arg:String):Void {
		node.setAttribute('integrity', 'sha512-$arg');
		node.setAttribute('crossorigin', 'anonymous');
	}
	
	private function hash(event:String, arg:String, encoding:String, cb:String->String->Void):Void {
		var path = (__dirname + input.directory() + arg).normalize();
		//trace( path.extension() );
		if (path.extension() == '') path += '/index.html';
		trace( path );
		if (hashedPaths.exists(path)) {
			cb('content::hashed::$arg', hashedPaths.get( path ));
			
		} else {
			stat(path, function(error, stats) {
				if (error == null && stats.isFile()) {
					var hash = createHash('sha512');
					var stream = createReadStream(path);
					stream.on('readable', function() {
						var data = stream.read();
						if (data != null) {
							hash.update(data);
							
						} else {
							var digest = hash.digest( encoding );
							
							hashedPaths.set( path, digest );
							//try {
							//trace( hashedPaths.get( path ));
								cb('content::hashed::$arg', digest);

							/*} catch (e:Dynamic) {
								console.log( path, hashedPaths.get( path ), e );

							}*/

						}
					});
					
				} else {
					trace( error );
					cb('content::hashed::$arg', 'failed');
					
				}
				
			});
			
		}
		
	}
	
}
