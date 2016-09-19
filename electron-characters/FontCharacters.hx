package ;

import thx.Url;
import js.Node.*;
import js.html.*;
import js.Browser.*;
import js.Node.process;

class FontCharacters {
	
	public static function main() {
		var fs = new FontCharacters();
	}
	
	public function new() {
		var body = window.document.getElementsByTagName('body')[0];
		var charList = [];
		
		if (body != null) {
			charList = buildList( body );
			var link = window.document.querySelectorAll( 'head link[href*="fonts.googleapis.com/css"]' );
			
			if (link.length > 0) {
				var url:Url = cast(link[0],DOMElement).getAttribute('href');
				var queryString = url.queryString;
				if (queryString != null) trace( 'exists', queryString.exist('text') );
				if (queryString != null && !queryString.exist('text')) {
					queryString.set( 'text', charList.join('') );
					
					var search = queryString.toStringWithSymbols('&', '=', function(s)return s);
					var path = url.pathName + '?$search';
					var string = (url.isAbsolute) ?
			      '${url.hasProtocol ? url.protocol + ":" : ""}${url.slashes?"//":""}${url.hasAuth?url.auth+"@":""}${url.host}${path}${url.hasHash?"#"+url.hash:""}'
			    :
			      '${path}${url.hasHash?"#"+url.hash:""}';
						
					cast (link[0],DOMElement).setAttribute('href', string);
					
				}
				
			} else {
				trace( 'link length', link.length );
				
			}
			
		}
		
		window.document.dispatchEvent( new CustomEvent('font.characters:complete', {detail:'font.characters', bubbles:true, cancelable:true}) );
		
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
