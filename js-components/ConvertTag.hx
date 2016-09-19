package ;

import js.html.*;
import js.Browser.*;

using StringTools;
using haxe.io.Path;

class ConvertTag extends Component {
	
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
			//console.log( this );
			for (child in this.childNodes) {
				var clone = window.document.importNode( child, true );
				this.parentNode.insertBefore( clone, this );
				
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
		if (to != null) {
			this.parentNode.replaceChild( replacement, this );
			
		} else {
			this.parentNode.removeChild( this );
			
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
	
}
