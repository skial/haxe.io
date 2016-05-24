package ;

import js.Node.*;
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

using haxe.io.Path;

class ScreenGrab {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var sg = new ScreenGrab();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var tags:Array<Array<Dynamic>> = [];
		
		ipcRenderer.on('screenshot::complete', function(event:String, arg:String) {
			var data:{width:Int,height:Int,path:String} = Unserializer.run(arg);
			
			if (data != null) {
				tags.push( [{tag:'meta', name:'twitter:image'}, {name:'twitter:image', content:'https://haxe.io/${data.path}'.normalize()}] );
				tags.push( [{tag:'meta', property:'og:image'}, {content:'http://haxe.io/${data.path}'.normalize()}] );
				tags.push( [{tag:'meta', property:"og:image:secure_url"}, {content:'https://haxe.io/${data.path}'.normalize()}] );
				tags.push( [{tag:'meta', property:'og:image:width'}, {content:'${data.width}'}] );
				tags.push( [{tag:'meta', property:'og:image:height'}, {content:'${data.height}'}] );
				tags.push( [{tag:'meta', property:"og:image:type" }, {content:'image/${data.path.extension()}'}] );
				processTags( tags );
				
			}
			
			ipcRenderer.send('screengrab::complete', 'true');
		});
		
		ipcRenderer.send('screenshot::init', '' + window.location);
		
		
	}
	
	private function processTags(tags:Array<Array<Dynamic>>):Void {
		var head = cast window.document.getElementsByTagName( 'head' )[0];
		
		for (array in tags) {
			var keys:DynamicAccess<String> = array[0];
			var values:DynamicAccess<String> = array[1];
			var selector = keys.get('tag') + [for(key in keys.keys()) if (key != 'tag') '[$key*="${keys.get(key)}"]'].join('');
			var matches = window.document.querySelectorAll( selector );
			trace( 'matches', selector, matches.length );
			if (matches.length == 0) {
				var element:DOMElement = window.document.createElement( keys.get('tag') );
				for (key in keys.keys()) if (key != 'tag') element.setAttribute( key, keys.get( key ) );
				for (key in values.keys()) element.setAttribute( key, values.get( key ) );
				cast(head,Node).appendChild( element );
				
			} else {
				var element = cast(matches[0],DOMElement);
				if (element.hasAttribute('contents')) element.removeAttribute('contents');
				if (element.hasAttribute('tag')) element.removeAttribute( 'tag' );
				for (key in values.keys()) if (key != 'tag') element.setAttribute( key, values.get( key ) );
				for (i in 1...matches.length) {
					head.removeChild( matches[i] );
				}
				
			}
			
		}
	}
	
}
