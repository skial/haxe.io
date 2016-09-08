package ;

import js.html.*;
import js.Browser.*;
import haxe.ds.IntMap;
import uhx.uid.Hashids;
import haxe.DynamicAccess;
import uhx.select.JsonQuery;
import haxe.Constraints.Function;

using JsonData;
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
		console.log( window.document.importNode(node, true) );
		var children = [for (child in node.childNodes) child];
		var newChildren = [];
		console.log( selector, window.document.importNode(node, true), data );
		// process each attribute, then each child.
		replaceAttributePlaceholders(node, data);
		console.log( window.document.importNode(node, true) );
		var converted = convertNode( node, data );
		var isSpecial = false;
		if (node != converted) {
			node = converted;
			isSpecial = Component.KnownComponents.getItem(node.nodeName.toLowerCase()) != null;
			
		}
		console.log( window.document.importNode(node, true), isSpecial );
		
		if (!isSpecial && selector != null && selector != '') {
			// filter json data based on the selector.
			var matches = uhx.select.JsonQuery.find(data, selector);
			console.log( selector, data, matches );
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
		
		if (isSpecial) {
			console.log( window.document.importNode(node, true) );
			newChildren = children;
		
		}
		
		// Replace old children with processed children. Only if node is still an element.
		if (node.nodeType == Node.ELEMENT_NODE && newChildren.length > 0) {
			console.log( newChildren, window.document.importNode(node, true), isSpecial );
			node.innerHTML = '';
			
			for (newChild in newChildren) {
				
				if (!isSpecial && newChild.nodeType == Node.ELEMENT_NODE) {
					// This is from the extended class `ConvertTag`.
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
					var replacement:Element = null;
					
					if (matches.length > 0) {
						replacement = cast window.document.createTextNode( matches.join(' ') );
						
					} else {
						replacement = cast window.document.createElement( attribute.value );
						
					}
					
					if (replacement != null) {
						console.log( window.document.importNode(node, true), node.parentNode, replacement, matches, attribute.value );
						if (replacement.nodeType == Node.ELEMENT_NODE) for (attribute in node.attributes) {
							if (!replacement.hasAttribute(attribute.name)) {
								replacement.setAttribute( attribute.name, attribute.value );
								
							}
							
						}
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
				case _.startsWith(':') && _ != ':to' => true:
					var selector = attribute.value;
					console.log( window.document.importNode(node, true), data, selector, attribute.value.indexOf('{') > -1 );
					if (selector != null && selector != '') {
						if (attribute.value.indexOf('{') > -1) {
							var name = '_' + attribute.name.substring(1);
							var result = attribute.value;
							var value = attribute.value;
							
							
							var info = attribute.value.trackAndInterpolate('}'.code, ['{'.code => '}'.code], function(s) {
								var results = uhx.select.JsonQuery.find(data, s);
								console.log( s, data, results );
								return results.length > 0 ? results.join(' ') : s;
							});
							
							console.log( info );
							result = info.value;
							
							/*for (i in 0...value.length) if (value.charCodeAt(i) == '{'.code) {
								var selector = value.substring(i+2, value.indexOf('}', i+1));
								var matches = uhx.select.JsonQuery.find(data, selector);
								console.log( matches );
								result = result.replace('{$selector}', matches.join(' '));	// TODO Look into using separator attributes.
								
							}*/
							
							if (node.hasAttribute(name)) result = node.getAttribute(name) + result;
							
							node.setAttribute(name, result);
							node.removeAttribute( attribute.name );
							
						} else {
							var matches = uhx.select.JsonQuery.find(data, selector);
							console.log( matches, data, selector );
							if (matches.length > 0) {
								var name = '_' + attribute.name.substring(1);
								var value = matches.join(' ');	// TODO Look into using separator attributes.
								
								if (node.hasAttribute(name)) value = node.getAttribute(name) + value;
								
								node.setAttribute(name, value);
								node.removeAttribute( attribute.name );
								
							}
							
						}
						
					}
					
				case _:
					
			}
			
		}
		
	}
	
	public static function trackAndConsume(value:String, until:Int, track:IntMap<Int>):String {
		var result = '';
		var length = value.length;
		var index = 0;
		var character = -1;

		while (index < length) {
			character = value.fastCodeAt( index );
			if (character == until) {
				break;

			}
			if (track.exists( character )) {
				var _char = track.get( character );
				var _value = value.substr( index + 1 ).trackAndConsume( _char, track );
				result += String.fromCharCode( character ) + _value + String.fromCharCode( _char );
				index += _value.length + 1;

			} else {
				result += String.fromCharCode( character );
				index++;

			}

		}

		return result;
	}

	public static function trackAndSplit(value:String, split:Int, track:IntMap<Int>):Array<String> {
		var pos = 0;
		var results = [];
		var length = value.length;
		var index = 0;
		var character = -1;
		var current = '';

		while (index < length) {
			character = value.fastCodeAt( index );
			if (character == split) {

				if (results.length == 0) {
					results.push( value.substr(0, index) );

				} else if (current != '') {
					results.push( current );

				}
				pos = index;
				index++;
				current = '';
				continue;

			}
			if (track.exists( character )) {
				var _char = track.get( character );
				var _value = value.substr( index + 1 ).trackAndConsume( _char, track );
				current += String.fromCharCode( character ) + _value + String.fromCharCode( _char );
				index += _value.length + 2;

			} else {
				current += String.fromCharCode( character );
				index++;

			}

		}

		if (current != '') results.push( current );

		return results;
	}
	
	public static function trackAndInterpolate(value:String, until:Int, track:IntMap<Int>, resolve:String->String):{matched:Bool, length:Int, value:String} {
		var result = '';
		var length = value.length;
		var index = 0;
		var character = -1;
		var pos = 0;
		var match = false;

		while (index < length) {
			character = value.fastCodeAt( index );
			if (character == until) {
				pos = index++;
				break;

			}
			if (track.exists( character )) {
				var _char = track.get( character );
				var _info = value.substr( index + 1 ).trackAndInterpolate( until, track, resolve );
				console.log( value.substr( index+1) );
				console.log( value.substr( index + _info.length + 2) );
				var _value = _info.value;
				match = true;
				pos = index += _info.length + 2;
				result += _value;

			} else {
				result += String.fromCharCode( character );
				pos = index++;
				
			}

		}
		console.log( value.length, pos, result, match );
		return {matched:match, length:pos, value:resolve(result)};
	}
	
}
