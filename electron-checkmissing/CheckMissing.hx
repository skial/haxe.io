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

class CheckMissing {
	
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var cm = new CheckMissing();
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		
		var head = cast window.document.getElementsByTagName( 'head' )[0];
		var script = window.document.querySelectorAll( 'head script[src*="haxe.io.js"]' )[0];
		var tags:Array<Array<Dynamic>> = [
			[{tag:'link', rel:'apple-touch-icon', sizes:'57x57'/*, href:"/apple-touch-icon-57x57.png"*/}, {href:"/apple-touch-icon-57x57.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'60x60'/*, href:"/apple-touch-icon-60x60.png"*/}, {href:"/apple-touch-icon-60x60.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'72x72'/*, href:"/apple-touch-icon-72x72.png"*/}, {href:"/apple-touch-icon-72x72.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'76x76'/*, href:"/apple-touch-icon-76x76.png"*/}, {href:"/apple-touch-icon-76x76.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'114x114'/*, href:"/apple-touch-icon-114x114.png"*/}, {href:"/apple-touch-icon-114x114.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'120x120'/*, href:"/apple-touch-icon-120x120.png"*/}, {href:"/apple-touch-icon-120x120.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'144x144'/*, href:"/apple-touch-icon-144x144.png"*/}, {href:"/apple-touch-icon-144x144.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'152x152'/*, href:"/apple-touch-icon-152x152.png"*/}, {href:"/apple-touch-icon-152x152.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'apple-touch-icon', sizes:'180x180'/*, href:"/apple-touch-icon-180x180.png"*/}, {href:"/apple-touch-icon-180x180.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'icon', type:"image/png", sizes:'16x16'/*, href:"/favicon-16x16.png"*/}, {href:"/favicon-16x16.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'icon', type:"image/png", sizes:'32x32'/*, href:"/favicon-32x32.png"*/}, {href:"/favicon-32x32.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'icon', type:"image/png", sizes:'96x96'/*, href:"/favicon-96x96.png"*/}, {href:"/favicon-96x96.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'icon', type:"image/png", sizes:'192x192'/*, href:"/favicon-192x192.png"*/}, {href:"/favicon-192x192.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'icon', type:"image/png", sizes:'194x194'/*, href:"/favicon-194x194.png"*/}, {href:"/favicon-194x194.png?v=wAANbdxLQn"}],
			[{tag:'link', rel:'manifest'/*, href:"/manifest.json"*/}, {href:"/manifest.json?v=wAANbdxLQn"}],
			[{tag:'link', rel:'mask-icon', color:"#fffdf9", /*href:"/safari-pinned-tab.svg"*/}, {href:"/safari-pinned-tab.svg?v=wAANbdxLQn"}],
			[{tag:'link', rel:'shortcut icon'/*, href:"/favicon.ico"*/}, {href:"/favicon.ico?v=wAANbdxLQn"}],
			[{tag:'meta', name:'msapplication-TileColor', content:"#f15922"}, {}],
			[{tag:'meta', name:'msapplication-TileImage'/*, content:"/mstile-144x144.png"*/}, {content:"/mstile-144x144.png?v=wAANbdxLQn"}],
			[{tag:'meta', name:'theme-color', content:"#ffffff"}, {}],
			[{tag:'script', src:'/js/haxe.io.js'}, {async:'async', defer:'defer'}]
		];
		
		for (array in tags) {
			var keys:DynamicAccess<String> = array[0];
			var values:DynamicAccess<String> = array[1];
			var selector = keys.get('tag') + [for(key in keys.keys()) if (key != 'tag') '[$key*="${keys.get(key)}"]'].join('');
			var matches = window.document.querySelectorAll( selector );
			if (matches.length == 0) {
				var element:DOMElement = window.document.createElement( keys.get('tag') );
				for (key in keys.keys()) if (key != 'tag') element.setAttribute( key, keys.get( key ) );
				for (key in values.keys()) element.setAttribute( key, values.get( key ) );
				cast(head,Node).appendChild( element );
				
			} else {
				var element = cast(matches[0],DOMElement);
				if (element.hasAttribute( 'tag')) element.removeAttribute( 'tag' );
				for (key in values.keys()) if (key != 'tag') element.setAttribute( key, values.get( key ) );
				
			}
			
		}
		
		/*if (script == null) {
			
			if (head != null) {
				var element:DOMElement = window.document.createElement( 'script' );
				element.setAttribute( 'src', '/js/haxe.io.js' );
				element.setAttribute( 'async', 'async' );
				element.setAttribute( 'defer', 'defer' );
				cast(head,Node).appendChild( element );
				
				ipcRenderer.send('checkmissing::complete', 'true');
				
			} else {
				ipcRenderer.send('checkmissing::complete', 'false');
				
			}
			
		} else {
			ipcRenderer.send('checkmissing::complete', 'false');
			
		}*/
		ipcRenderer.send('checkmissing::complete', 'true');
		
	}
	
}
