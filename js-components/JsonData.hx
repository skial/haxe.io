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
			//trace( key );
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
		//console.log( window.document.importNode(node, true), data );
		var selector = node.getAttribute('select');
		//console.log(selector);
		//console.log( window.document.importNode(node, true) );
		var children = [for (child in node.childNodes) child];
		var newChildren = [];
		//console.log( selector, window.document.importNode(node, true), data );
		// process each attribute, then each child.
		replaceAttributePlaceholders(node, data);
		//console.log( window.document.importNode(node, true) );
		var converted = convertNode( node, data );
		var isKnown = false;
		if (node != converted) {
			node = cast converted;
			isKnown = Component.KnownComponents.getItem(node.nodeName.toLowerCase()) != null;
			
		}
		
		if (!isKnown) {
			if (node.nodeType == Node.ELEMENT_NODE && selector != null && selector != '') {
				// filter json data based on the selector.
				var matches = uhx.select.JsonQuery.find(data, selector);
				//console.log( selector, matches, children );
				if (children.length > 0) for (match in matches) for (child in children) {
					// Pass each child the filtered json data.
					if (child.nodeType == Node.ELEMENT_NODE) {
						newChildren.push( cast iterateNode( cast window.document.importNode(child, true), match ) );
						
					} else {
						newChildren.push( window.document.importNode(child, true) );
						
					}
					
				} else {
					// Append the matches as a TEXT_NODE.
					newChildren.push( window.document.createTextNode( matches.join(' ') ) );
					
				}
				
			} else {
				if (children.length > 0) for (child in children) {
					// Pass each child the filtered json data.
					if (child.nodeType == Node.ELEMENT_NODE) {
						newChildren.push( iterateNode( cast window.document.importNode(child, true), data ) );
						
					} else {
						newChildren.push( window.document.importNode(child, true) );
						
					}
					
				}
				
			}
			
		}
		
		// Replace old children with processed children. Only if node is still an element.
		if (node.nodeType == Node.ELEMENT_NODE && newChildren.length > 0) {
			//console.log( 'new children', window.document.importNode(node, true), [for (n in newChildren) window.document.importNode(n, true)], isKnown );
			node.innerHTML = '';
			
			for (newChild in newChildren) {
				
				if (!isKnown && newChild.nodeType == Node.ELEMENT_NODE) {
					// This is from the extended class `ConvertTag`.
					cleanNode( cast newChild );
					
					var removables = [for (attribute in cast (newChild, Element).attributes) switch attribute.name.charCodeAt(0) {
						case '_'.code, ':'.code: attribute.name;
						case _: '';
					}];
					
					for (removable in removables) cast (newChild,Element).removeAttribute( removable );
					
				}
				
				node.appendChild( newChild );
			
			}
			
			
		}
		//console.log( 'returning node', window.document.importNode(node, true) );
		return node;
		
	}
	
	private function convertNode(node:Element, data:Dynamic):Node {
		//console.log( data );
		for (attribute in node.attributes) {
			switch attribute.name {
				case _.startsWith(':to') => true:
					var replacement:Element = null;
					var match = processAttribute(attribute.name, attribute.value, data);
					
					if (match.value != attribute.value) {
						replacement = cast window.document.createTextNode( match.value );
						
					} else {
						//console.log( 'innerhtml', node.innerHTML );
						replacement = cast window.document.createElement( 'div' );
						//console.log( '<${attribute.value} ' + [for (a in node.attributes) if (a.name != ':to')'${a.name}="${a.value}"'].join(' ') + '>${node.innerHTML}</${attribute.value}>' );
						replacement.innerHTML = '<${attribute.value} ' + [for (a in node.attributes) if (a.name != ':to')'${a.name}="${a.value}"'].join(' ') + '>${node.innerHTML}</${attribute.value}>';
						replacement = cast replacement.firstChild;
						
					}
					
					if (replacement != null) {
						//console.log( window.document.importNode(node, true), node.parentNode, replacement, matches, attribute.value );
						if (replacement.nodeType == Node.ELEMENT_NODE) for (attribute in node.attributes) {
							if (attribute.name != ':to' && !replacement.hasAttribute(attribute.name)) {
								replacement.setAttribute( attribute.name, attribute.value );
								
							}
							
						}
						
						return replacement;
						
					}
					
					break;
					
				case _:
					
			}
		}
		
		return node;
	}
	
	private function replaceAttributePlaceholders(node:Element, data:Dynamic):Void {
		// Iterate over an array instead of the live attribute list, as updating mid
		// loop _appears_ to break early.
		for (attribute in [for (a in node.attributes)a]) {
			switch attribute.name {
				case _.startsWith(':') && _ != ':to' => true:
					//console.log( window.document.importNode(node, true), data, attribute.name, attribute.value );
					if (attribute.value != null && attribute.value != '') {
						var result = processAttribute(attribute.name, attribute.value, data);
						
						if (result.name != attribute.name) {
							if (node.hasAttribute(result.name)) result.value = node.getAttribute(result.name) + result.value;
							
							node.setAttribute(result.name, result.value);
							node.removeAttribute( attribute.name );
							
						}
						
					}
					
				case _:
					//console.log( attribute.name, attribute.value );
					
			}
			
		}
		
	}
	
	public function processAttribute(attrName:String, attrValue:String, data:Any):{name:String, value:String} {
		var result = {name:attrName, value:attrValue};
		
		if (attrValue.indexOf('{') > -1) {
			result.name = '_' + attrName.substring(1);
			var info = result.value.trackAndInterpolate('}'.code, ['{'.code => '}'.code], function(s) {
				var results = uhx.select.JsonQuery.find(data, s);
				console.log( 'json matches', s, data, results );
				return results.length > 0 ? results.join(' ') : s;
			});
			
			console.log( 'inter attr', info );
			result.value = info.value;
			
		} else {
			var matches = uhx.select.JsonQuery.find(data, attrValue);
			console.log( 'json matches', matches, data, attrValue );
			if (matches.length > 0) {
				result.name = '_' + attrName.substring(1);
				var value = matches.join(' ');	// TODO Look into using separator attributes.
				
				result.value = value;
				
			}
			
		}
		console.log( 'attr result', result );
		return result;
	}
	
	/** All these are from an internal project likely never to see the light of day */
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
				//console.log( value.substr( index+1) );
				//console.log( value.substr( index + _info.length + 2) );
				var _value = _info.value;
				match = true;
				pos = index += _info.length + 2;
				result += _value;

			} else {
				result += String.fromCharCode( character );
				pos = index++;
				
			}

		}
		//console.log( value.length, pos, result, match );
		return {matched:match, length:pos, value:resolve(result)};
	}
	
}
