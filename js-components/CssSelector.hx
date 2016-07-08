package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;
import uhx.select.Json;

using haxe.io.Path;

class CssSelector extends Element {
	
	public static function main() {
		new CssSelector();
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
		
		window.document.addEventListener('DocumentHtmlData', process);
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
		
	}
	
	public function process() {
		var selector = this.getAttribute('select');
		var matches = window.document.querySelectorAll(selector);
		console.log( matches );
		var attributes = this.attributes;
		trace( [for( a in this.attributes) a.name => a.value] );
		var results = [];
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case 'textcontent':
					for (match in matches) results.push(window.document.createTextNode(match.textContent));
					
				case 'clone':
					
				case _:
					
			}
			
		}
		
		console.log( results );
		
		for (result in results) {
			this.parentNode.insertBefore(result, this);
		}
		
		this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
		window.document.removeEventListener('DocumentHtmlData', process);
		
		var self = window.document.querySelectorAll( '[uid="$_uid"]' );
		console.log( self );
		for (s in self) s.parentNode.removeChild( s );
		
		for (attribute in attributes) {
			switch ([attribute.name.toLowerCase(), attribute.value.toLowerCase()]) {
				case ['source', 'move']:
					
				case ['source', 'remove']:
					for (match in matches) match.parentNode.removeChild( match );
					
				case _:
					
			}
			
		}
		
	}
	
	public function detachedCallback() {
		window.document.removeEventListener('DocumentHtmlData', process);
	}
	
}
