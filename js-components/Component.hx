package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class Component extends Element {
	
	private static var counter:Int = 0;
	private static var uidMapping:Map<String,Array<Node>> = new Map();
	
	public static function main() {
		new Component();
	}
	
	private var mutator:MutationObserver;
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
	
	public function transplant(?parent:Node = null) {
		var node = template.content;
		/*var sections = node.querySelectorAll('document-head, document-body');
		
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
			
		}*/
		
	}
	
	public function createdCallback() {
		//mutator = new MutationObserver(mutated);
		//mutator.observe( this, {childList:true} );
		this.setAttribute('uid', _uid = uid( this ) );
		var node = template.content;
		
		root = this.createShadowRoot();
		root.appendChild( window.document.importNode( node, true ) );
		trace( '$htmlName cb called' );
		
	}
	
	private var max:Int = 0;
	private var pending:Int = 0;
	
	public function attachedCallback() {
		var contents = root.querySelectorAll('content');
		for (i in 0...contents.length) {
			var content:ContentElement = untyped contents[i];
			content.setAttribute('uid', '$_uid.$i' );
			trace( content );
		}
		
		var customElements = this.querySelectorAll('[uid]:not(content)');
		console.log( customElements );
		pending = max = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
	}
	
	public function check(?e:CustomEvent) {
		trace( 'checking $htmlName $pending - $_uid' );
		if (e != null) {
			trace( e.detail );
			e.stopPropagation();
			--pending;
		}
		trace( '$htmlName $pending' );
		if (pending < 1) {
			process();
			
		}
	}
	
	public function detachedCallback() {
		//mutator.disconnect();
		this.removeEventListener('DOMCustomElementFinished', check);
	}
	
	public function process() {
		var parent = this.parentElement;
		var shadowChildren = root.children;
		
		for (child in shadowChildren) {
			if (parent.querySelectorAll(parent.nodeName + ' > ' + child.nodeName + [for (a in child.attributes) '[${a.name}="${a.value}"]'].join('')).length == 0) {
				parent.insertBefore(local.importNode(child, true), this);
				
			}
			
		}
		
		var shadowPoints = root.querySelectorAll('content');
		for (point in shadowPoints) {
			var point:ContentElement = untyped point;
			var cuid = untyped point.getAttribute('uid');
			var distributedNodes = point.getDistributedNodes();
			var placeholder = window.document.querySelectorAll('[uid="$cuid"]')[0];
			trace( placeholder );
			if (placeholder != null) for (node in distributedNodes) {
				placeholder.parentElement.insertBefore(window.document.importNode(node, true), placeholder);
				
			}
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
			#if !debug
			var self = window.document.querySelector( '$htmlName[uid="$_uid"]' );
			if (self != null) self.parentNode.removeChild( self );
			#end
			
		}
	}
	
	/*public function mutated(records:Array<MutationRecord>, observer:MutationObserver) {
		for (record in records) {
			switch (record.type) {
				case 'childList':
					//console.log( record );
					for (child in record.addedNodes) {
						var insertionPoint:ContentElement = untyped child.getDestinationInsertionPoints()[0];
						if (insertionPoint != null) {
							//console.log( insertionPoint.getAttribute('uid'), insertionPoint );
							
						}
						
					}
					
				case _:
					
					
			}
			
		}
		
	}*/
	
}
