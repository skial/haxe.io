package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

@:expose
class DocumentJson extends Element {
	
	public static var data:Map<String, Dynamic> = new Map();
	
	public static function main() {
		window.document.addEventListener('DocumentJsonData', processJsonData);
		new DocumentJson();
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
		trace( 'adding event listener for DocumentJsonData' );
		window.document.addEventListener('DocumentJsonData', function(e){
			processJsonData(e);
			useJsonData(e.detail);
		});
	}
	
	public function attachedCallback() {
		for (key in data.keys()) {
			trace( key );
			useJsonData(data.get(key));
			
		}
		
		#if !debug
		/*for (node in window.document.querySelectorAll( '[uid="${this.getAttribute("uid")}"]' )) {
			node.parentNode.removeChild( node );
			
		}*/
		#end
		
	}
	
	public function useJsonData(data:Dynamic) {
		trace( 'using json data' );
		console.log( data );
		
		var children = this.childNodes;
		console.log( children );
	}
	
}
