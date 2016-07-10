package ;

import js.html.*;
import js.Browser.*;
import uhx.select.Json;

using StringTools;
using haxe.io.Path;

class CssSelector extends Component {
	
	public static function main() {
		new CssSelector();
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function createdCallback() {
	/*	var node = template.content;
		var copy = window.document.importNode( node, true );
		
		this.setAttribute('uid', uid = stampUid( this ) );
		root = this.createShadowRoot();
		root.appendChild( copy );
		trace( '$htmlName cb called' );*/
		super.createdCallback();
		window.document.addEventListener('DocumentHtmlData', process);
	}
	
	/*public override function attachedCallback() {
		var contents = root.querySelectorAll('content');
		for (i in 0...contents.length) {
			var content:ContentElement = untyped contents[i];
			content.setAttribute('uid', '$_uid.$i' );
			trace( content );
		}
		
	}*/
	
	public override function processComponent() {
		var selector = this.getAttribute('select');
		var matches = window.document.querySelectorAll(selector);
		//console.log( matches );
		var attributes = this.attributes;
		trace( [for( a in this.attributes) a.name => a.value] );
		var results = [];
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith('use:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'text':
							for (match in matches) results.push(window.document.createTextNode(match.textContent));
							
						case _:
							
					}
					
				case 'clone':
					
				case _:
					
			}
			
		}
		
		//console.log( results );
		
		for (result in results) {
			this.parentNode.insertBefore(result, this);
		}
		
		/*this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:uid, bubbles:true, cancelable:true}) );
		window.document.removeEventListener('DocumentHtmlData', process);*/
		
		/*var self = window.document.querySelectorAll( '[uid="$_uid"]' );
		//console.log( self );
		for (s in self) s.parentNode.removeChild( s );*/
		
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith('source:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'remove':
							for (match in matches) match.parentNode.removeChild( match );
							
						case _:
						
					}
					
				case _:
					
			}
			
		}
		
	}
	
	private override function removeSelf():Void {
		var self = window.document.querySelectorAll( '[uid="$uid"]' );
		//console.log( self );
		for (s in self) s.parentNode.removeChild( s );
	}
	
	/*public override function detachedCallback() {
		window.document.removeEventListener('DocumentHtmlData', process);
	}*/
	
}
