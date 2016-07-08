package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class ConvertTag extends Element {
	
	public static function main() {
		new ConvertTag();
	}
	
	private var to(get, set):String;
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
				trace( 'registering element <$htmlName>.' );
				window.document.registerElement('$htmlName', {prototype:this});
				
			case _:
				throw 'Define `data-prefix`, `data-name` and `data-extends`.';
				
		}
		
	}
	
	public function uid(node:Node):String {
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
		var toElement = window.document.createElement( to );
		for (child in this.childNodes) {
			var clone = window.document.importNode( child, true );
			toElement.appendChild( clone );
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
		}
		
		console.log( toElement );
		this.parentNode.replaceChild(toElement, this);
		
	}
	
	private function get_to():String return this.getAttribute('to');
	private function set_to(v:String):String {
		this.setAttribute('to', v);
		return v;
	}
	
}
