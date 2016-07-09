package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class Component extends Element {
	
	public static function main() {
		new Component();
	}
	
	private var max:Int = 0;
	private var pending:Int = 0;
	private var local:HTMLDocument;
	private var htmlPrefix:String = 'hx';
	private var htmlName:String = '';
	private var template:TemplateElement;
	private var root:ShadowRoot;
	private var hash:Hashids = new Hashids();
	private var _uid:String = '';
	private var self:Component = null;
	
	public function new() {
		local = window.document.currentScript.ownerDocument;
		template = cast local.querySelector('template');
		
		switch ([template.hasAttribute('data-prefix'), template.hasAttribute('data-name')]) {
			case [x, true]:
				if (x) htmlPrefix = template.getAttribute('data-prefix');
				htmlName = '$htmlPrefix-' + template.getAttribute('data-name');
				trace( 'registering element <$htmlName>' );
				if (self == null) self = this;
				register();
				
			case _:
				
		}
		
	}
	
	public function register() {
		if (self != null) window.document.registerElement('$htmlName', {prototype:self});
	}
	
	public function uid(node:Node):String {
		var result = '';
		
		if (node.nodeType == Node.TEXT_NODE) {
			result = node.textContent;
			
		} else if (node.nodeType != Node.COMMENT_NODE) {
			var ele:Element = untyped node;
			var stamp = ele.nodeName + [for (a in ele.attributes) if (a.name != 'uid') a.name + a.value].join('') + ele.querySelectorAll('*').length;
			trace( stamp );
			result = hash.encode( [for (i in 0...stamp.length) stamp.charCodeAt(i)] );
			
		}
		
		return result;
	}
	
	public function createdCallback() {
		this.setAttribute('uid', _uid = uid( this ) );
		var node = template.content;
		
		root = this.createShadowRoot();
		root.appendChild( window.document.importNode( node, true ) );
		trace( '$htmlName cb called' );
		
	}
	
	public function attachedCallback() {
		var contents = root.querySelectorAll('content');
		for (i in 0...contents.length) {
			var content:ContentElement = untyped contents[i];
			content.setAttribute('uid', '$_uid.$i' );
			trace( content );
		}
		
		var customElements = this.querySelectorAll(':root > [uid]:not(content)');
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
		if (pending == 0) {
			process();
			
		}
	}
	
	public function detachedCallback() {
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
			var self = window.document.querySelector( '[uid="$_uid"]' );
			if (self != null) self.parentNode.removeChild( self );
			#end
			
		}
	}
	
}
