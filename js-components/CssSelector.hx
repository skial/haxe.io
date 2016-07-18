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
		var matches = window.document.querySelectorAll(selector);
		var attributes = this.attributes;
		var results = [];
		
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith(':') => true if (attribute.value != ''):
					var _selector = attribute.value;
					var _matches = [for (match in window.document.querySelectorAll( _selector )) match.textContent];
					if (_matches.length > 0) {
						var name = '_' + attribute.name.substring(1);
						var value = _matches.join(' ');
						
						if (this.hasAttribute( name )) value = this.getAttribute( name ) + ' $value';
						
						this.setAttribute( name, value );
						
					}
					
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
	
}
