package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class DocumentHeader extends Element {
	
	public static function main() {
		new DocumentHeader();
	}
	
	private var local:HTMLDocument;
	private var htmlPrefix:String = 'hx';
	private var htmlName:String = '';
	private var template:TemplateElement;
	private var root:ShadowRoot;
	private var hash:Hashids = new Hashids();
	
	public function new() {
		local = window.document.currentScript.ownerDocument;
		template = cast local.querySelector('template');
		switch ([template.hasAttribute('data-prefix'), template.hasAttribute('data-name')]) {
			case [x, true]:
				if (x) htmlPrefix = template.getAttribute('data-prefix');
				htmlName = '$htmlPrefix-' + template.getAttribute('data-name');
				trace( 'registering element <$htmlName>' );
				window.document.registerElement('$htmlName', {prototype:this});
				
			case _:
				throw 'Define `data-prefix` and `data-name`.';
				
		}
		
	}
	
	public function uid(node:Node):String {
		//console.log( node );
		var result = '';
		if (node.nodeName.indexOf('#text') > -1) {
			result = node.textContent;
			
		} else {
			var ele:Element = untyped node;
			var stamp = ele.nodeName + [for (a in ele.attributes) if (a.name != 'uid') a.name + a.value].join('') + ele.getElementsByTagName('*').length;
			result = hash.encode( [for (i in 0...stamp.length) stamp.charCodeAt(i)] );
			
		}
		
		return result;
	}
	
	public function createdCallback() {
		var node = template.content;
		var copy = window.document.importNode( node, true );
		
		this.setAttribute('uid', uid( this ) );
		root = this.createShadowRoot();
		root.appendChild( copy );
		trace( '$htmlName cb called' );
		
	}
	
	public function attachedCallback() {
		var link = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
		
		for (insertion in root.querySelectorAll('content')) {
			var point:ContentElement = untyped insertion;
			var parent = link.parentElement;
			var children = point.getDistributedNodes();
			
			for (child in children) {
				var childUid = uid( child );
				var nodelist = parent.querySelectorAll( link.parentElement.nodeName + ' > ' + child.nodeName );
				//trace( parent.nodeName + ' > ' + child.nodeName, parent.nodeName, child.nodeName, nodelist.length );
				//for (node in nodelist) trace( node );
				
				var match = false;
				for (node in nodelist) {
					var nodeUid = uid( node );
					match = nodeUid == childUid;
					if (match) break;
					
				}
				
				if (!match) {
					parent.insertBefore(window.document.importNode( child, true ), link);
					
				}
				
			}
			
		}
		
		#if !debug
		for (node in window.document.querySelectorAll( '[uid="${this.getAttribute("uid")}"]' )) {
			node.parentNode.removeChild( node );
			
		}
		#end
		
	}
	
}
