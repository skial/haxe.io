package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class DocumentBody extends Element {
	
	public static function main() {
		new DocumentBody();
	}
	
	private var local:HTMLDocument;
	private var htmlPrefix:String = 'hx';
	private var htmlName:String = '';
	private var template:TemplateElement;
	private var root:ShadowRoot;
	private var hash:Hashids = new Hashids();
	private var _uid:String = '';
	
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
		this.setAttribute('uid', _uid = uid( this ) );
		root = this.createShadowRoot();
		root.appendChild( copy );
		trace( '$htmlName cb called' );
		
		
	}
	
	public function attachedCallback() {
		var parent = this.parentElement;
		var self = window.document.querySelectorAll('[uid="$_uid"]');
		console.log( this.parentNode, self, '[uid="$_uid"]' );
		var insertionPoints = root.querySelectorAll('content');
		for (point in insertionPoints) {
			var content:ContentElement = untyped point;
			var distributed:Array<Node> = [for (node in content.getDistributedNodes()) node];
			console.log( distributed );
			
			for (child in distributed) {
				var nodelist = parent.querySelectorAll( parent.nodeName + ' > ' + child.nodeName );
				trace( parent.nodeName, child.nodeName, nodelist.length );
				for (node in nodelist) trace( node );
				
				var match = false;
				for (node in nodelist) {
					match = node == child;
					if (match) break;
					
				}
				
				if (!match) {
					this.parentElement.insertBefore(window.document.importNode( child, true ), this);
					
				}
				
			}
			
		}
		
		#if !debug
		this.parentNode.removeChild( this );
		#end
		
	}
	
}
