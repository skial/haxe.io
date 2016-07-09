package ;

import js.html.*;
import js.Browser.*;

using haxe.io.Path;

class DocumentBody extends Component {
	
	public static function main() {
		new DocumentBody();
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function attachedCallback() {
		var contents = root.querySelectorAll('content:not([uid])');
		for (i in 0...contents.length) {
			var content:ContentElement = untyped contents[i];
			content.setAttribute('uid', '$_uid.$i' );
			trace( content );
		}
		
		var customElements = this.querySelectorAll(':root > [uid]:not(content)');
		//console.log( customElements );
		pending = max = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
	}
	
	public override function process() {
		var parent = this.parentElement;
		var self = window.document.querySelectorAll('[uid="$_uid"]');
		var insertionPoints = root.querySelectorAll('content');
		for (point in insertionPoints) {
			var content:ContentElement = untyped point;
			var distributed:Array<Node> = [for (node in content.getDistributedNodes()) node];
			
			for (child in distributed) {
				var nodelist = parent.querySelectorAll( parent.nodeName + ' > ' + child.nodeName );
				trace( parent.nodeName, child.nodeName, nodelist.length );
				for (node in nodelist) trace( node );
				
				var match = false;
				for (node in nodelist) {
					match = node == child;
					if (match) break;
					
				}
				
				if (!match) {
					var clone = window.document.importNode( child, true );
					this.parentElement.insertBefore(clone, this);
					
				}
				
			}
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
			var self = window.document.querySelectorAll( '[uid="$_uid"]' );
			//console.log( self );
			for (s in self) s.parentNode.removeChild( s );
			
		}
		
	}
	
}
