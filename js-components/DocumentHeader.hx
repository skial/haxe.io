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
		var result = '';
		if (node.nodeName.indexOf('#text') > -1) {
			result = node.textContent;
			
		} else if (node.nodeType == Node.ELEMENT_NODE) {
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
	
	private var max:Int = 0;
	private var pending:Int = 0;
	
	public function attachedCallback() {
		var customElements = this.querySelectorAll(':root > [uid]:not(content)');
		pending = max = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
	}
	
	public function detachedCallback() {
		this.removeEventListener('DOMCustomElementFinished', check);
	}
	
	public function check(?e:CustomEvent) {
		trace( 'checking $htmlName $pending - $_uid' );
		if (e != null) {
			trace( e.detail );
			e.stopPropagation();
			--pending;
		}
		trace( '$htmlName $pending' );
		if (pending == 0) {
			process();
			
		}
	}
	
	public function process() {
		var link = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
		
		for (insertion in root.querySelectorAll('content:not([is])')) {
			var point:ContentElement = untyped insertion;
			var parent = link.parentElement;
			var children = point.getDistributedNodes();
			
			for (child in children) {
				var childUid = uid( child );
				var nodelist = parent.querySelectorAll( link.parentElement.nodeName + ' > ' + child.nodeName );
				
				var match = false;
				for (node in nodelist) {
					var nodeUid = uid( node );
					match = nodeUid == childUid;
					if (match) break;
					
				}
				
				if (!match) {
					var clone = window.document.importNode( child, true );
					parent.insertBefore(clone, link);
					
				}
				
			}
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
			#if !debug
			for (node in window.document.querySelectorAll( '[uid="${this.getAttribute("uid")}"]' )) {
				node.parentNode.removeChild( node );
				
			}
			#end
			
		}
	}
	
}
