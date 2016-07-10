package ;

import js.html.*;
import js.Browser.*;

using StringTools;
using haxe.io.Path;

class ConvertTag extends Component {
	
	public static function main() {
		new ConvertTag();
	}
	
	private var to(get, null):String;
	private var replacement:Element = null;
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function processComponent() {
		replacement = window.document.createElement( to );
		
		for (child in this.childNodes) {
			var clone = window.document.importNode( child, true );
			replacement.appendChild( clone );
			
		}
		
	}
	
	private override function removeSelf():Void {
		this.parentNode.replaceChild(replacement, this);
	}
	
	private function get_to():String {
		var result = null;
		
		for (attribute in this.attributes) if (attribute.name.startsWith('to:')) {
			result = attribute.name.split(':')[1];
			break;
			
		}
		
		return result;
	}
	
}
