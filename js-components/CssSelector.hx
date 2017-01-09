package ;

import js.html.*;
import js.Browser.*;

using ConvertTag;
using StringTools;
using haxe.io.Path;

class CssSelector extends ConvertTag<Array<Node>, Node> {
	
	public static function main() {
		new CssSelector();
	}
	
	public function new() {
		self = this;
		super();
		console.log( 'CssSelector');
	}
	
	public override function createdCallback() {
		super.createdCallback();
		window.document.addEventListener('DocumentHtmlData', process);
	}
	
	public override function attachedCallback():Void {
		stampContents();
	}
	
	private override function removeEvents():Void {
		window.document.removeEventListener('DocumentHtmlData', process);
		super.removeEvents();
	}
	
	/*private override function process() {
		console.log( 'running CssSelector process');
		var selector = this.getAttribute('select');
		var matches = window.document.querySelectorAll(selector);
		var attributes = this.attributes;
		var results = [];
		
		console.log( selector, matches );
		
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith(':') => true if (attribute.value != ''):
					var _selector = attribute.value;
					var _matches = [for (match in window.document.querySelectorAll( _selector )) match.textContent];
					if (_matches.length > 0) {
						var name = '_' + attribute.name.substring(1);
						var value = _matches.join(' ');
						
						if (this.hasAttribute( name )) value = this.getAttribute( name ) + ' $value';
						
						this.setAttribute( name, value );
						
					}
					
				case _.startsWith('use:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'text':
							results.push(window.document.createTextNode( [for (match in matches) match.textContent].join('') ));
							
						case _:
							
					}
					
				case 'clone':
					
				case _:
					
			}
			
		}
		
		switch ([this.hasAttribute('+:'), this.hasAttribute(':+')]) {
			case [true, _]:
				trace( '+:' );
				for (result in results) {
					this.insertBefore(result, this.childNodes[0]);
					
				}
				
			case [_, true]:
				trace( ':+' );
				for (result in results) {
					this.appendChild( result );
					
				}
				
			case _:
				trace( 'default' );
				for (result in results) {
					this.appendChild( result );
					
				}
				
		}
		
		processComponent();
		done();
		removeSelf();
		
		for (attribute in attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith('source:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'remove':
							for (match in matches) match.parentNode.removeChild( match );
							
						case _:
						
					}
					
				case _:
					
			}
			
		}
		
	}*/
	
	private override function process() {
		var selector:Null<String> = this.hasAttribute('select') ? this.getAttribute('select') : null;
		if (selector != null) {
			console.log( selector );
			iterateNode(this, qsa( selector ));
			
		}
		
		processComponent();
		finish();
		
		for (attribute in this.attributes) {
			switch (attribute.name.toLowerCase()) {
				case _.startsWith('source:') => true:
					switch (attribute.name.split(':')[1]) {
						case 'remove':
							for (match in qsa(selector)) match.parentNode.removeChild( match );
							
						case _:
						
					}
					
				case _:
					
			}
			
		}
	}
	
	// Returns an editable array of nodes.
	private inline function qsa(selector:String, ?element:Null<Element>):Array<Node> {
		return [for (n in (element == null ? window.document : untyped element.parentElement).querySelectorAll( selector )) n];
	}
	
	private override function find(data:Array<Node>, selector:String):Array<Node> {
		return qsa( selector );
	}
	
	private override function stringify(data:Array<Node>):String {
		console.log( data );
		return [for (d in data) d.textContent].join(' ');
	}
	
	private override function handleMatch(child:Node, match:Null<Node>):Array<Node> {
		console.log( child, match );
		return if (child.nodeType == Node.TEXT_NODE && match != null && match.nodeType == Node.TEXT_NODE) {
			var a = stringify( [child] );
			var b = stringify( [match] );
			var parent = child.parentElement;
			var before = parent.hasAttribute('+:') || !parent.hasAttribute(':+');
			var node = window.document.createTextNode( before ? b + a : a + b );
			
			[window.document.importNode( node, true )];
			
		} else if (match != null) {
			// Don't process whitespace between elements.
			if (child.nodeType == Node.TEXT_NODE && ~/^[\n\r\s]+$/m.match(child.textContent)) {
				return [window.document.importNode(child, true)];
				
			}
			
			var parent = child.parentElement;
			var useText = parent.hasAttribute('use:text');
			var before = parent.hasAttribute('+:') || !parent.hasAttribute(':+');
			var matched = useText ? 
				window.document.createTextNode( match.textContent ) 
			: match;
			
			var data = match.nodeType == Node.ELEMENT_NODE ? [match] : [];
			var child = child.nodeType == Node.ELEMENT_NODE ? cast iterateNode( cast child, data ) : child;
			
			before ? 
				[window.document.importNode( matched, true ), window.document.importNode( child, true )] 
			:	[window.document.importNode( child, true ), window.document.importNode( matched, true )];
			
		} else {
			[window.document.importNode( cast iterateNode( cast child, [match] ), true )];
			
		}
		
	}
	
	private inline function insertNode(self:Node, child:Node, before:Bool = false):Void {
		console.log( untyped self.outerHTML );
		if (before && self.childNodes.length > 0) {
			self.insertBefore(child, self.childNodes[0]);
			
		} else {
			self.appendChild(child);
			
		}
		console.log( untyped self.outerHTML );
	}
	
	private override function insertNewNode(parent:Node, newChild:Node):Void {
		var p:Element = cast parent;
		
		if (p.attributes.length > 0) for (attribute in [for (a in p.attributes)a]) {
			console.log( attribute );
			switch attribute.name {
				case _.startsWith('use:') => true:
					
					switch (attribute.name.split(':')[1]) {
						case 'text':
							console.log( parent, newChild );
							insertNode(parent, newChild, p.hasAttribute('+:') || !p.hasAttribute(':+'));
							
						case _:
							insertNode(parent, newChild);
							
					}
					
				case 'clone':
				
				
				case _:
					insertNode(parent, newChild);
					
			}
			
		} else {
			insertNode(parent, newChild);
			
		}
		
	}
	
	public override function modifyData(node:Element, matches:Array<Node>, data:Array<Node>):Array<Node> {
		console.log( data );
		console.log( node );
		console.log( matches, matches.length );
		for (attribute in node.attributes) switch attribute.name {
			case _.startsWith('$') => true:
				if (attribute.value != null && attribute.value != '') {
					var result = processAttribute(attribute.name, attribute.value, data);
					
					for (match in matches) {
						var element:Element = cast match;
						
						if (!element.hasAttribute(result.name.substring(1))) {
							node.setAttribute( result.name.substring(1), result.value );
							
						}
						
					}
					
				}
				
			case _:
				
		}
		console.log( matches );
		return matches;
	}
	
	public override function processAttribute(attrName:String, attrValue:String, data:Array<Node>):{name:String, value:String} {
		var result = {name:attrName, value:attrValue};
		
		if (attrValue.indexOf('{') > -1) {
			result.name = '_' + attrName.substring(1);
			var info = result.value.trackAndInterpolate('}'.code, ['{'.code => '}'.code], function(s) {
				//var results = uhx.select.JsonQuery.find(data, s);
				console.log( attrName, attrValue, data, s );
				var results = [for (n in qsa( s )) n];
				console.log( results );
				return results.length > 0 ? [for (r in results) r.textContent].join(' ') : s;
			});
			
			result.value = info.value;
			
		} else {
			//var matches = uhx.select.JsonQuery.find(data, attrValue);
			var matches = [for (n in qsa( attrValue )) n];
			console.log( matches );
			if (matches.length > 0) {
				result.name = '_' + attrName.substring(1);
				var value = [for (r in matches) r.textContent].join(' ');	// TODO Look into using separator attributes.
				
				result.value = value;
				
			}
			
		}
		console.log( attrName, attrValue, result );
		return result;
	}
	
}
