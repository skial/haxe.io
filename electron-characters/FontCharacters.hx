package ;

import thx.Url;
import js.Node.*;
import js.Browser.*;
import js.html.Node;
import js.html.Element;
import js.html.DOMElement;
import js.Node.process;
import electron.main.App;

class FontCharacters {
	
	public static function main() {
		console.log( 'loading...' );
		if( window.document.readyState == 'complete' ) {
			var m = new Script();
			
		} else {
			window.document.addEventListener('DOMContentLoaded', function() {
				trace( 'dom loaded' );
				var m = new Script();
			}, false);
			
		}
	}
	
	public function new() {
		var body = window.document.getElementsByTagName('body')[0];
		var charList = [];
		
		trace( body );
		
		if (body != null) {
			charList = buildList( body );
			var link = window.document.querySelectorAll( 'head link[href*="fonts.googleapis.com/css"]' );
			
			trace( charList );
			
			if (link.length > 0) {
				var url:Url = cast(link[0],DOMElement).getAttribute('href');
				var queryString = url.queryString;
				if (queryString != null) trace( 'exists', queryString.exist('text') );
				if (queryString != null && !queryString.exist('text')) {
					queryString.set( 'text', charList.join('') );
					trace( 'search', url.search );
					var search = queryString.toStringWithSymbols('&', '=', function(s)return s);
					var path = url.pathName + '?$search';
					var string = (url.isAbsolute) ?
			      '${url.hasProtocol ? url.protocol + ":" : ""}${url.slashes?"//":""}${url.hasAuth?url.auth+"@":""}${url.host}${path}${url.hasHash?"#"+url.hash:""}'
			    :
			      '${path}${url.hasHash?"#"+url.hash:""}';
						
					trace( 'search', search );
					trace( 'path', path );
					trace( 'thx-core', string );
					//cast (link[0],DOMElement).setAttribute('href', cast (link[0],DOMElement).getAttribute('href') + '&text=' +charList.join(''));
					cast (link[0],DOMElement).setAttribute('href', string);
					
				}
				
				//'<script async="" src="https://www.google-analytics.com/analytics.js"></script>';
				var head = window.document.getElementsByTagName( 'head' )[0];
				
				if (head != null) {
					var ga = window.document.querySelectorAll( 'head script[src*="google"]');
					for (_ga in ga) head.removeChild( _ga );
				}
				
				require('electron').ipcRenderer.send('font.characters::complete', 'true');
				
			} else {
				trace( 'link length', link.length );
				require('electron').ipcRenderer.send('font.characters::complete', 'false');
				
			}
			
			/*trace( 'char list', charList.join('') );
			var node = window.document.doctype;
			
			var doctype = node != null ? "<!DOCTYPE "
					 + node.name
					 + (node.publicId != null ? ' PUBLIC "' + node.publicId + '"' : '')
					 + (node.publicId == null && node.systemId != null ? ' SYSTEM' : '') 
					 + (node.systemId != null ? ' "' + node.systemId + '"' : '')
					 + '>\n' : '';
					 
			var html = window.document.documentElement.outerHTML;
			if (html != null && html != '<html><head></head><body></body></html>') {
				require('electron').ipcRenderer.send('haxeCharacterList', doctype + window.document.documentElement.outerHTML);
				
			} else {
				require('electron').ipcRenderer.send('haxeCharacterList-close', 'true');
				
			}*/
			
			
		} else {
			//require('electron').ipcRenderer.send('haxeCharacterList-close', 'true');
			require('electron').ipcRenderer.send('font.characters::complete', 'false');
			
		}
		
	}
	
	private function buildList(e:Node):Array<String> {
		var results = [];
		if (e == null) return results;
		
	  if (e.nodeType == 3) {
	    for (i in 0...e.textContent.length) {
	      if ([' ', '\t', '\r', '\n'].indexOf( e.textContent.charAt(i) ) == -1 && results.indexOf(e.textContent.charAt(i)) == -1) {
	        results.push(e.textContent.charAt(i));
					
	      }
				
	    }
	    
	  } else {
	    for (i in 0...e.childNodes.length) {
	      var returned = buildList(e.childNodes[i]);
	      for (j in 0...returned.length) if (results.indexOf(returned[j]) == -1) results.push( returned[j] );
				
	    }
	    
	  }
		
	  return results;
	}
	
}
