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

class Version {

	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	private var hashedPaths:StringMap<String> = new StringMap();
	private var input:String = '';
	private var counter:Int = 0;

	public static function main() {
		var v = new Version();
	}

	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;

		ipcRenderer.send('fetch::data', 'version');
		ipcRenderer.on('fetched::data::version', function(event:String, arg:String) {
			var data:{input:String} = Unserializer.run(arg);
			if (data.input != null) input = data.input;
			for (node in window.document.querySelectorAll( 'link[href]' )) process('href', cast node);
			for (node in window.document.querySelectorAll( 'body [src], script[src]' )) process('src', cast node);
			for (node in window.document.querySelectorAll( 'meta[content*="ms"]' )) process('content', cast node);

		});

	}

	private function process(attr:String, node:DOMElement):Void {
		var value:String = node.getAttribute( attr );
		trace( value );
		var url = parse( value, true, true );
		//trace( input );
		if (url.host == null || url.host == '') {
			counter++;
			//trace( format( url ));
			if ((url.query:DynamicAccess<String>).exists('v')) {
				Reflect.deleteField(url, 'search');
				(url.query:DynamicAccess<String>).remove('v');

			}

			value = format( url );
			trace( format(url).normalize() );
			var cb = modifyUrl.bind(node, attr, _, _);
			hash('content::hash', format(url).normalize(), cb);

		} else {
			if (url.host != null && url.host.indexOf('haxe.io') > -1) {
				counter++;
				var cb = modifyUrl.bind(node, attr, _, _);
				//trace( value, format(url), value.substring( value.lastIndexOf('haxe.io') + 7 ));
				if ((url.query:DynamicAccess<String>).exists('v')) {
					Reflect.deleteField(url, 'search');
					(url.query:DynamicAccess<String>).remove('v');

				}
				url.protocol = url.hostname = url.host = '';
				trace( format(url).normalize() );
				hash('content::hash', format(url).normalize(), cb);

			}

		}
	}

	private function modifyUrl(node:DOMElement, attr:String, event:String, arg:String):Void {
		if (arg != 'failed'){
			var value:String = node.getAttribute( attr );
			var url = parse( value, true, true );

			Reflect.deleteField(url, 'search');
			if (url.query == null) url.query = {};
			if ((url.query:DynamicAccess<String>).exists('v')) {
				Reflect.deleteField(url, 'search');
				(url.query:DynamicAccess<String>).remove('v');

			}
			(url.query:DynamicAccess<String>).set('v', arg);
			//trace( format( url ) );
			node.setAttribute( attr, format( url ));

		} else {
			trace( event, arg, node.getAttribute(attr) );
		}

		counter--;
		//trace( counter );
		if (counter < 1) ipcRenderer.send('version::complete', 'true');
	}

	private function hash(event:String, arg:String, cb:String->String->Void):Void {
		var path = (__dirname + input.directory() + arg).normalize();
		//trace( path.extension() );
		if (path.extension() == '') path += '/index.html';
		trace( path );
		if (hashedPaths.exists(path)) {
			cb('content::hashed::$arg', hashedPaths.get( path ));

		} else {
			stat(path, function(error, stats) {
				if (error == null && stats.isFile()) {
					var hash = createHash('md5');
					var stream = createReadStream(path);
					stream.on('readable', function() {
						var data = stream.read();
						if (data != null) {
							hash.update(data);

						} else {
							var digest = hash.digest('hex');
							
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
