package ;

import js.html.*;
import js.Browser.*;

using haxe.io.Path;

class ConvertTag extends Component {
	
	public static function main() {
		new ConvertTag();
	}
	
	private var to(get, set):String;
	private var replacement:Element = null;
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function processComponent() {
		replacement = window.document.createElement( to );
		// TODO figure out why CssSelector suddenly matches converted tags.
		//replacement.setAttribute('ct:uid', uid);
		for (child in this.childNodes) {
			var clone = window.document.importNode( child, true );
			replacement.appendChild( clone );
			
		}
		
	}
	
	private override function removeSelf():Void {
		this.parentNode.replaceChild(replacement, this);
	}
	
	private function get_to():String return this.getAttribute('to');
	private function set_to(v:String):String {
		this.setAttribute('to', v);
		return v;
	}
	
}
