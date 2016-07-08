package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;
import uhx.select.Json;

using haxe.io.Path;

class JsonData extends Element {
	
	public static var data:Map<String, Dynamic> = new Map();
	
	public static function main() {
		window.document.addEventListener('DocumentJsonData', processJsonData);
		new JsonData();
	}
	
	public static function processJsonData(e:CustomEvent) {
		console.log( e );
		var stringly = haxe.Json.stringify(e.detail);
		if (!data.exists(stringly)) data.set(stringly, e.detail);
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
				trace( 'registering element <$htmlName>.' );
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
		
		window.document.addEventListener('DocumentJsonData', storeAndUse);
		
	}
	
	private var max:Int = 0;
	private var pending:Int = 0;
	
	public function attachedCallback() {
		/*for (key in data.keys()) {
			trace( key );
			useJsonData(data.get(key));
			
		}*/
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
		#if !debug
		/*for (node in window.document.querySelectorAll( '[uid="${this.getAttribute("uid")}"]' )) {
			node.parentNode.removeChild( node );
			
		}*/
		#end
		
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
		for (key in data.keys()) {
			trace( key );
			useJsonData(data.get(key));
			
		}
		
	}
	
	public function detachedCallback() {
		this.removeEventListener('DOMCustomElementFinished', check);
		window.document.removeEventListener('DocumentJsonData', storeAndUse);
	}
	
	public function storeAndUse(e:CustomEvent) {
		processJsonData(e);
		useJsonData(e.detail);
	}
	
	public function useJsonData(json:Dynamic) {
		trace( 'using json data' );
		console.log( json );
		
		var selector = this.getAttribute('select');
		console.log( selector );
		var results = [];
		
		for (key in data.keys()) {
			results = results.concat( uhx.select.Json.find(data.get( key ), selector) );
			
		}
		
		console.log( results );
		
		if (results.length > 0) {
			
			if (max > -1) {
				this.removeEventListener('DOMCustomElementFinished', check);
				trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
				this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
				
				pending = max = -1;
				
			}
			
			this.parentNode.insertBefore(window.document.createTextNode(results[0]), this);
			this.parentNode.removeChild(this);
			
		}
		
	}
	
}
