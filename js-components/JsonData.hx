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
		console.log( json );
		
		iterateNode(this, data);
		
		processComponent();
		done();
		removeSelf();
		
	}
	
	private function iterateNode(node:Element, data:DynamicAccess<Dynamic>):Void {
		var results = [];
		var selector = node.getAttribute('select');
		
		// Find values to be used for this components attribute values.
		replaceAttributePlaceholders(node, data);
		var children = [for (child in node.childNodes) window.document.importNode(child, true)];
		var newChildren = [];
		
		if (children.length > 0) {
			// Find values to be used for this components children.
			if (selector != null) for (key in data.keys()) for (value in uhx.select.JsonQuery.find(data.get( key ), selector)) results.push(value);
			
			if (results.length > 0) {
				var defaultSeparator = (node.hasAttribute('separator')) ? node.getAttribute('separator') : '';
				
				for (i in 0...results.length) {
					var result = results[i];
					
					for (child in children) {
						var clone = window.document.importNode(child, true);
						if (clone.nodeType == Node.ELEMENT_NODE) iterateNode( cast clone, result );
						
						newChildren.push( clone );
						
						if (results.length > 1 && clone.nodeType == Node.ELEMENT_NODE) {
							var separator = defaultSeparator;
							var checks = ['separator:$i', 'separator:length-${results.length - i}'];
							
							if (i == 0) checks.push('separator:first');
							if (i == results.length - 1) checks.push('separator:last');
							
							for (check in checks) if (node.hasAttribute( check )) {
								separator = node.getAttribute( check );
								
							}
							
							newChildren.push( window.document.createTextNode( separator ) );
						
						}
						
					}
					
				}
									
			} else {
				for (child in children) if (child.nodeType == Node.ELEMENT_NODE) {
					var clone:Element = cast window.document.importNode(child, true);
					
					for (attribute in cast (child, Element).attributes) {
						switch (attribute.name.toLowerCase()) {
							case _.startsWith(':to') => true:
								var _selector = attribute.value;
								var _matches = uhx.select.JsonQuery.find(data, _selector);
								
								if (_matches.length > 0) {
									console.log( _matches );
									clone = cast window.document.createTextNode( _matches.join('') );
									
								}
							
							case _:
								// nout
								
						}
						
					}
					
					if (clone.nodeType == Node.ELEMENT_NODE) replaceAttributePlaceholders( clone, data );
					
					newChildren.push( clone );
					
				}
				
			}
			
		} else {
			if (selector != null) for (key in data.keys()) for (value in uhx.select.JsonQuery.find(data.get( key ), selector)) results.push(value);
			
			if (results.length > 0) {
				newChildren.push( window.document.createTextNode( results.join('') ) );
				
			}
			
		}
		
		if (newChildren.length > 0) {
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
		
	}
	
	private function replaceAttributePlaceholders(node:Element, data:Dynamic):Void {
		console.log( data );
		console.log( node );
		for (attribute in node.attributes) {
			trace( attribute.name, attribute.value );
			
			switch (attribute.name.toLowerCase()) {
				case !_.startsWith(':to') && attribute.value.indexOf('{{') == -1 && attribute.value.indexOf('}}') == -1 && _.startsWith(':') => true if (attribute.value != ''):
					var _selector = attribute.value;
					var _matches = uhx.select.JsonQuery.find(data, _selector);
					
					if (_matches.length > 0) {
						console.log( _matches );
						var name = '_' + attribute.name.substring(1);
						var value = _matches.join(' ');
						
						if (node.hasAttribute( name )) value = node.getAttribute( name ) + ' $value';
						
						node.setAttribute( name, value );
						
					}
					
				case !_.startsWith(':to') && attribute.value.indexOf('{{') > -1 && attribute.value.indexOf('}}') > -1 => true:
					var result = attribute.value;
					var value = attribute.value;
					for (i in 0...value.length) if (value.charCodeAt(i) == '{'.code && value.charCodeAt(i+1) == '{'.code) {
						var _selector = value.substring(i+2, value.indexOf('}}', i+1));
						var _matches = uhx.select.JsonQuery.find(data, _selector);
						
						console.log( _matches );
						result = result.replace('{{$_selector}}', _matches.join(' '));
						
					}
					
					var name = '_' + attribute.name.substring(1);
					node.setAttribute( name, result );
					
				case _:
					
			}
			
		}
		
	}
	
}
