package ;

import js.html.*;
import js.Browser.*;
import haxe.ds.IntMap;
import haxe.DynamicAccess;

using ConvertTag;
using StringTools;
using haxe.io.Path;

/**
D == Data object to search, an array, object or map etc.
S == Single data type contained in the D object.
*/
class ConvertTag<D, S> extends Component {
	
	public static function main() {
		new ConvertTag();
	}
	
	private var to(get, null):Null<String>;
	private var replacement:Element = null;
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function processComponent() {
		if (to != null) {
			replacement = window.document.createElement( to );
			
			for (child in this.childNodes) {
				var clone = window.document.importNode( child, true );
				replacement.appendChild( clone );
				
			}
			
			for (attribute in this.attributes) switch attribute.name {
				case _.startsWith('_') => true:
					var name = attribute.name.substring(1);
					replacement.setAttribute( name, ((this.hasAttribute( name )) ? this.getAttribute( name ) : '') + attribute.value );
					
				case _.indexOf(':') == -1 && !_.startsWith('_') && _ != 'uid' && _ != 'select' && _ != 'to' => true:
					replacement.setAttribute( attribute.name, attribute.value );
					
				case _:
					
			}
			
			cleanNode( this );
			
		} else {
			console.log( this, this.parentNode, this.parentElement );
			var parent:Element = this.parentElement != null ? this.parentElement : cast this.parentNode;
			if (parent != null) for (child in this.childNodes) {
				var clone = window.document.importNode( child, true );
				parent.insertBefore( clone, this );
				
			} else {
				finish();
				
			}
			
		}
		
	}
	
	private function cleanNode(node:Element):Void {
		//console.log( window.document.importNode(node, true) );
		for (attribute in node.attributes) if (attribute.name.startsWith('_')) {
			node.setAttribute( attribute.name.substring(1), attribute.value );
			
		}
		
	}
	
	private override function removeSelf():Void {
		console.log( this.outerHTML );
		var parent:Element = cast this.parentElement == null ? this.parentNode : this.parentElement;
		
		if (parent != null) {
			if (to != null) {
				parent.replaceChild( replacement, this );
				
			} else {
				parent.removeChild( this );
				
			}
			
		} else {
			super.removeSelf();
			
		}
		
	}
	
	private function get_to():Null<String> {
		var result = null;
		
		for (attribute in this.attributes) switch attribute.name {
			case _.startsWith('to:') => true:
				result = attribute.name.split(':')[1];
				break;
				
			case 'to':
				result = attribute.value;
				break;
				
			case _:
				
		}
		
		return result;
	}
	
	private function find(data:D, selector:String):Array<S> {
		return [];
	}
	
	private function stringify(data:D):String {
		return '$data';
	}
	
	private function handleMatch(child:Node, match:Null<S>):Array<Node> {
		return [window.document.importNode( child, true )];
	}
	
	private function iterateNode(node:Element, data:D):Element {
		var results = [];
		var selector = node.getAttribute('select');
		var children = [for (child in node.childNodes) child];
		var newChildren = [];
		// process each attribute, then each child.
		replaceAttributePlaceholders(node, data);
		
		var converted = convertNode( node, data );
		var isKnown = false;
		if (node != converted) {
			node = cast converted;
			//isKnown = Component.KnownComponents.getItem(node.nodeName.toLowerCase()) != null;
			isKnown = Component.KnownComponents.indexOf(node.nodeName.toLowerCase()) > 1;
			
		}
		
		console.log( node, isKnown, node.nodeType == Node.ELEMENT_NODE );
		if (!isKnown) {
			if (node.nodeType == Node.ELEMENT_NODE && selector != null && selector != '') {
				var matches = find(data, selector);
				
				matches = modifyData( node, matches, data );
				console.log( matches, children );
				if (matches.length > 0 && children.length > 0) for (match in matches) for (child in children) {
					console.log( match, child );
					// Pass each child the filtered json data.
					/*if (child.nodeType == Node.ELEMENT_NODE) {
						newChildren.push( cast iterateNode( cast window.document.importNode(child, true), cast match ) );
						
					} else {
						newChildren.push( window.document.importNode(child, true) );
						
					}*/
					
					//newChildren.push( handleMatch( child, match ) );
					for (node in handleMatch( child, match )) newChildren.push( node );
					
				} else {
					console.log( matches );
					// Append the matches as a TEXT_NODE.
					newChildren.push( window.document.importNode( window.document.createTextNode( stringify( cast matches ) ) ) );
					
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
		
		return recreateNode(node, isKnown, newChildren);
		
	}
	
	private function insertNewNode(parent:Node, newChild:Node):Void {
		parent.appendChild( newChild );
	}
	
	private function recreateNode(node:Element, isKnown:Bool, newChildren:Array<Node>):Element {
		// Replace old children with processed children. Only if node is still an element.
		if (node.nodeType == Node.ELEMENT_NODE && newChildren.length > 0) {
			console.log( untyped node.outerHTML );
			console.log( newChildren );
			node.innerHTML = '';
			
			for (newChild in newChildren) {
				console.log( newChild );
				if (!isKnown && newChild.nodeType == Node.ELEMENT_NODE) {
					cleanNode( cast newChild );
					
					var removables = [for (attribute in cast (newChild, Element).attributes) switch attribute.name.charCodeAt(0) {
						case '_'.code, ':'.code: attribute.name;
						case _: '';
					}];
					
					for (removable in removables) cast (newChild,Element).removeAttribute( removable );
					
				}
				
				//node.appendChild( newChild );
				insertNewNode( node, newChild );
			
			}
			console.log( untyped node.outerHTML );
			
		}
		
		return node;
	}
	
	private function convertNode(node:Element, data:D):Node {
		for (attribute in node.attributes) {
			switch attribute.name {
				case _.startsWith(':to') => true:
					var replacement:Element = null;
					var match = processAttribute(attribute.name, attribute.value, data);
					
					if (match.value != attribute.value) {
						replacement = cast window.document.createTextNode( match.value );
						
					} else {
						replacement = cast window.document.createElement( 'div' );
						replacement.innerHTML = '<${attribute.value} ' + [for (a in node.attributes) if (a.name != ':to')'${a.name}="${a.value}"'].join(' ') + '>${node.innerHTML}</${attribute.value}>';
						replacement = cast replacement.firstChild;
						
					}
					
					if (replacement != null) {
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
	
	private function replaceAttributePlaceholders(node:Element, data:D):Void {
		// Iterate over an array instead of the live attribute list, as updating mid
		// loop _appears_ to break early.
		for (attribute in [for (a in node.attributes)a]) {
			switch attribute.name {
				case _.startsWith(':') && _ != ':to' => true:
					if (attribute.value != null && attribute.value != '') {
						var result = processAttribute(attribute.name, attribute.value, data);
						
						if (result.name != attribute.name) {
							if (node.hasAttribute(result.name)) result.value = node.getAttribute(result.name) + result.value;
							
							node.setAttribute(result.name, result.value);
							node.removeAttribute( attribute.name );
							
						}
						
					}
					
				case _:
					
					
			}
			
		}
		
	}
	
	public function modifyData(node:Element, matches:Array<S>, data:D):Array<S> {
		return cast matches;
	}
	
	public function processAttribute(attrName:String, attrValue:String, data:D):{name:String, value:String} {
		return {name:attrName, value:attrValue};
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
				var _value = _info.value;
				match = true;
				pos = index += _info.length + 2;
				result += _value;

			} else {
				result += String.fromCharCode( character );
				pos = index++;
				
			}

		}
		
		return {matched:match, length:pos, value:resolve(result)};
	}
	
}
