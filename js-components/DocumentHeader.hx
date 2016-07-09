package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;

using haxe.io.Path;

class DocumentHeader extends Component {
	
	public static function main() {
		new DocumentHeader();
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function attachedCallback() {
		var customElements = this.querySelectorAll(':root > [uid]:not(content)');
		pending = max = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
	}
	
	public override function process() {
		var link = window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
		
		for (insertion in root.querySelectorAll('content:not([is])')) {
			var point:ContentElement = untyped insertion;
			var parent = link.parentElement;
			var children = point.getDistributedNodes();
			
			for (child in children) {
				var childUid = uid( child );
				var nodelist = parent.querySelectorAll( link.parentElement.nodeName + ' > ' + child.nodeName );
				
				var match = false;
				for (node in nodelist) {
					var nodeUid = uid( node );
					match = nodeUid == childUid;
					if (match) break;
					
				}
				
				if (!match) {
					var clone = window.document.importNode( child, true );
					parent.insertBefore(clone, link);
					
				}
				
			}
			
		}
		
		if (max > -1) {
			this.removeEventListener('DOMCustomElementFinished', check);
			trace( 'dispatching DOMCustomElementFinished from $htmlName - $_uid' );
			this.dispatchEvent( new CustomEvent('DOMCustomElementFinished', {detail:_uid, bubbles:true, cancelable:true}) );
			
			pending = max = -1;
			
			#if !debug
			for (node in window.document.querySelectorAll( '[uid="${this.getAttribute("uid")}"]' )) {
				node.parentNode.removeChild( node );
				
			}
			#end
			
		}
	}
	
}
