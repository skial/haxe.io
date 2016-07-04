package ;

import js.html.*;
import js.Browser.*;

using haxe.io.Path;

class Component extends Element {
	
	public static function main() {
		new Component();
	}
	
	private var local:HTMLDocument;
	private var htmlPrefix:String = 'hx';
	private var htmlName:String = '';
	private var template:TemplateElement;
	private var root:ShadowRoot;
	
	public function new() {
		local = window.document.currentScript.ownerDocument;
		template = cast local.querySelector('template');
		switch ([template.hasAttribute('data-prefix'), template.hasAttribute('data-name')]) {
			case [_, false]:
				transplant();
				/*var node = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
				if (node != null) node.parentNode.replaceChild(document.importNode( template.content, true ), node);*/
				
			case [x, true]:
				if (x) htmlPrefix = template.getAttribute('data-prefix');
				htmlName = '$htmlPrefix-' + template.getAttribute('data-name');
				trace( 'registering element <$htmlName>' );
				window.document.registerElement('$htmlName', {prototype:this});
				
			case _:
				
		}
		
	}
	
	public function transplant(?parent:Node = null) {
		var node = template.content;
		var sections = node.querySelectorAll('document-head, document-body');
		
	 	if (sections.length > 0) {
			
			for (section in sections) switch (section.nodeName.toLowerCase()) {
				case 'document-head' if (section.childNodes.length > 0):
					trace( 'head' );
					var ele:Element = untyped section;
					var current:Element = untyped window.document.importNode( ele.children[0], true );
					var insertion = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
					
					if (insertion != null) {
						var parent = insertion.parentNode;
						parent.replaceChild(current, insertion);
						if (ele.children.length > 0) for (i in 1...cast ele.children.length) {
							var copy:Element = untyped window.document.importNode( ele.children[i], true );
							//trace( parent.nodeName, copy.nodeName, current.nextElementSibling, [for (a in copy.attributes) a.name => a.value], copy );
							parent.insertBefore(copy, current.nextElementSibling);
							current = copy;
							
						}
						
					}
				
				case 'document-body':
					trace( 'body' );
					
					var node = (parent == null) ? window.document.querySelector('body') : parent;
					var ele:Element = cast section;
					
					if (node != null) {
						var current = untyped window.document.importNode( ele.children[0], true );
						if (parent != null) 
							node.parentNode.replaceChild(current, node) 
						else
							node.insertBefore(current, node.firstChild);
						
						
						if (ele.children.length > 1) for (i in 1...ele.children.length) {
							var copy:Element = untyped window.document.importNode( ele.children[i], true );
							current.parentNode.insertBefore(copy, current.nextSibling);
							current = copy;
							
						}
						
					}
					
				case _:
					trace( 'unmatched', section.nodeName, section );
					
			}
			
		}
		
	}
	
	public function createdCallback() {
		var node = template.content;
		var sections = node.querySelectorAll('document-head, document-body');
		
		if (sections.length == 0) {
			root = this.createShadowRoot();
			root.appendChild( window.document.importNode( node, true ) );
			trace( 'cb called' );
			
		} else {
			trace( htmlName );
			var insertionPoints = window.document.querySelectorAll( htmlName );
			for (point in insertionPoints) transplant(point);
			
		}
		
	}
	
}
