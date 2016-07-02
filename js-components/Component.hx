package ;

import js.html.*;
import js.Browser.*;

using haxe.io.Path;

class Component extends Element {
	
	public static function main() {
		new Component();
	}
	
	private var local:HTMLDocument;
	private var tagPrefix:String = 'hx';
	private var template:TemplateElement;
	private var root:ShadowRoot;
	
	public function new() {
		local = window.document.currentScript.ownerDocument;
		template = cast local.querySelector('template');
		switch ([template.hasAttribute('data-prefix'), template.hasAttribute('data-name')]) {
			case [_, false]:
				var node = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
				if (node != null) node.parentNode.replaceChild(document.importNode( template.content, true ), node);
				
			case [x, true]:
				if (x) tagPrefix = template.getAttribute('data-prefix');
				trace( 'registering element <$tagPrefix-' + template.getAttribute('data-name') + '>' );
				window.document.registerElement('$tagPrefix-' + template.getAttribute('data-name'), {prototype:this});
				
			case _:
				
		}
		
	}
	
	public function createdCallback() {
		root = this.createShadowRoot();
		root.appendChild( window.document.importNode( template.content, true ) );
		trace( 'cb called' );
		
	}
	
}
