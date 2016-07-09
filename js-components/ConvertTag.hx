package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class ConvertTag extends Component {
	
	public static function main() {
		new ConvertTag();
	}
	
	private var to(get, set):String;
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function attachedCallback() {
		var contents = root.querySelectorAll('content');
		for (i in 0...contents.length) {
			var content:ContentElement = untyped contents[i];
			content.setAttribute('uid', '$_uid.$i' );
			trace( content );
		}
		
		var customElements = this.querySelectorAll('[uid]:not(content)');
		console.log( customElements );
		pending = max = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
		
	}
	
	public override function process() {
		var toElement = window.document.createElement( to );
		for (child in this.childNodes) {
			var clone = window.document.importNode( child, true );
			toElement.appendChild( clone );
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
		}
		
		console.log( toElement );
		this.parentNode.replaceChild(toElement, this);
		
	}
	
	private function get_to():String return this.getAttribute('to');
	private function set_to(v:String):String {
		this.setAttribute('to', v);
		return v;
	}
	
}
