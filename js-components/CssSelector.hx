package ;

import js.html.*;
import js.Browser.*;

using StringTools;
using haxe.io.Path;

class CssSelector extends ConvertTag {
	
	public static function main() {
		new CssSelector();
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function createdCallback() {
		super.createdCallback();
		window.document.addEventListener('DocumentHtmlData', process);
	}
	
	public override function attachedCallback():Void {
		stampContents();
	}
	
	private override function removeEvents():Void {
		window.document.removeEventListener('DocumentHtmlData', process);
		super.removeEvents();
	}
	
	private override function process() {
		var selector = this.getAttribute('select');
		// TODO figure out why CssSelector appears to be triggering `process` twice, resulting in me needing to add `ct:uid` attributes to ConvertTag elements.
		var matches = [for (match in window.document.querySelectorAll(selector)) /*if (!cast (match, Element).hasAttribute('ct:uid'))*/ match];
		//console.log( matches );
		var attributes = this.attributes;
		//trace( [for( a in this.attributes) a.name => a.value] );
		var results = [];
		
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith('use:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'text':
							results.push(window.document.createTextNode( [for (match in matches) match.textContent].join('') ));
							
						case _:
							
					}
					
				case 'clone':
					
				case _:
					
			}
			
		}
		
		switch ([this.hasAttribute('+:'), this.hasAttribute(':+')]) {
			case [true, _]:
				trace( '+:' );
				for (result in results) {
					this.insertBefore(result, this.childNodes[0]);
					
				}
				
			case [_, true]:
				trace( ':+' );
				for (result in results) {
					this.appendChild( result );
					
				}
				
			case _:
				trace( 'default' );
				for (result in results) {
					this.appendChild( result );
					
				}
				
		}
		
		processComponent();
		done();
		removeSelf();
		
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
	
	/*private override function removeSelf():Void {
		var self = window.document.querySelectorAll( '[uid="$uid"]' );
		for (s in self) s.parentNode.removeChild( s );
	}*/
	
}
