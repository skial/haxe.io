package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;
import haxe.DynamicAccess;
import uhx.select.JsonQuery;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

class JsonData extends ConvertTag {
	
	public static var data:DynamicAccess<Dynamic> = {};
	
	public static function main() {
		window.document.addEventListener('DocumentJsonData', processJsonData);
		new JsonData();
	}
	
	public static function processJsonData(e:CustomEvent) {
		var stringly = haxe.Json.stringify(e.detail);
		if (!data.exists(stringly)) data.set(stringly, e.detail);
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function createdCallback():Void {
		window.document.addEventListener('DocumentJsonData', storeAndUse);
		super.createdCallback();
	}
	
	private override function process() {
		for (key in data.keys()) {
			trace( key );
			useJsonData(data.get(key));
			
		}
		
	}
	
	private override function removeEvents():Void {
		window.document.removeEventListener('DocumentJsonData', storeAndUse);
		super.removeEvents();
	}
	
	public function storeAndUse(e:CustomEvent) {
		processJsonData(e);
		useJsonData(e.detail);
	}
	
	public function useJsonData(json:Dynamic) {
		trace( 'using json data' );
		//console.log( json );
		
		iterateNode(this, data);
		
		processComponent();
		done();
		removeSelf();
		
	}
	
	private function iterateNode(node:Element, data:DynamicAccess<Dynamic>):Element {
		var results = [];
		var selector = node.getAttribute('select');
		
		var children = [for (child in node.childNodes) /*window.document.importNode(child, true)*/ child];
		var newChildren = [];
		console.log( selector, node, data );
		// process each attribute, then each child.
		replaceAttributePlaceholders(node, data);
		
		var converted = convertNode( node, data );
		console.log( node, converted, node != converted );
		if (node != converted) {
			return converted;
			
		}
		
		if (selector != null && selector != '') {
			// filter json data based on the selector.
			var matches = uhx.select.JsonQuery.find(data, selector);
			
			if (children.length > 0) for (child in children) {
				// Pass each child the filtered json data.
				if (child.nodeType == Node.ELEMENT_NODE) for (match in matches) child = iterateNode( cast child, match );
				newChildren.push( child );
				
			} else {
				// Append the matches as a TEXT_NODE.
				newChildren.push( window.document.createTextNode( matches.join(' ') ) );
				
			}
			
		} else {
			if (children.length > 0) for (child in children) {
				// Pass each child the filtered json data.
				if (child.nodeType == Node.ELEMENT_NODE) child = iterateNode( cast child, data );
				newChildren.push( child );
				
			}
			
		}
		
		if (node.nodeType == Node.ELEMENT_NODE && newChildren.length > 0) {
			console.log( newChildren );
			node.innerHTML = '';
			
			for (newChild in newChildren) {
				
				if (newChild.nodeType == Node.ELEMENT_NODE) {
					cleanNode( cast newChild );
					
					var removables = [for (attribute in cast (newChild, Element).attributes) switch (attribute.name.charCodeAt(0)) {
						case '_'.code, ':'.code: attribute.name;
						case _: '';
					}];
					
					for (removable in removables) cast (newChild,Element).removeAttribute( removable );
					
				}
				
				node.appendChild( newChild );
			
			}
			
			
		}
		
		return node;
		
	}
	
	private function convertNode(node:Element, data:Dynamic):Element {
		for (attribute in node.attributes) {
			switch attribute.name {
				case _.startsWith(':to') => true:
					var matches = uhx.select.JsonQuery.find(data, attribute.value);
					var replacement:Node = null;
					
					if (matches.length > 0) {
						replacement = window.document.createTextNode( matches.join(' ') );
						
					} else {
						replacement = window.document.createElement( attribute.value );
						
					}
					
					if (replacement != null) {
						console.log( node, node.parentNode, replacement, matches, attribute.value );
						return cast replacement;
						
					}
					
					break;
					
				case _:
					
			}
		}
		
		return node;
	}
	
	private function replaceAttributePlaceholders(node:Element, data:Dynamic):Void {
		for (attribute in node.attributes) {
			switch attribute.name {
				case !_.startsWith('to:') && _ != ':to' && _ != 'to' && _ != 'select' => true:
					var selector = attribute.value;
					
					if (selector != null && selector != '') {
						if (attribute.value.indexOf('{{') > -1) {
							var name = '_' + attribute.name.substring(1);
							var result = attribute.value;
							var value = attribute.value;
							
							for (i in 0...value.length) if (value.charCodeAt(i) == '{'.code && value.charCodeAt(i+1) == '{'.code) {
								var selector = value.substring(i+2, value.indexOf('}}', i+1));
								var matches = uhx.select.JsonQuery.find(data, selector);
								
								result = result.replace('{{$selector}}', matches.join(' '));	// TODO Look into using separator attributes.
								
							}
							
							if (node.hasAttribute(name)) result = node.getAttribute(name) + result;
							
							node.setAttribute(name, result);
							
						} else {
							var matches = uhx.select.JsonQuery.find(data, selector);
							
							if (matches.length > 0) {
								var name = '_' + attribute.name.substring(1);
								var value = matches.join(' ');	// TODO Look into using separator attributes.
								
								if (node.hasAttribute(name)) value = node.getAttribute(name) + value;
								
								node.setAttribute(name, value);
								
							}
							
						}
						
					}
					
				case _:
					
			}
			
		}
		
	}
	
}
