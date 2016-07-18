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
		pending = total = customElements.length;
		if (customElements.length > 0) {
			trace(pending);
			this.addEventListener('DOMCustomElementFinished', check);
			
		} else {
			process();
			
		}
	}
	
	public override function processComponent() {
		var host:Element = cast window.document.querySelectorAll('link[href*="${local.URL.withoutDirectory()}"]')[0];
		var add:Node->Void = null;
		
		if (host == null) {
			host = window.document.getElementsByTagName('head')[0];
			
		} else if (add == null) {
			host.insertBefore.bind(_, this);
			
		}
		
		if (host == null) {
			add = host.appendChild;
			host = this.parentElement;
			
		} else if (add == null) {
			add = host.appendChild;
			
		}
		
		for (insertion in root.querySelectorAll('content:not([is])')) {
			var point:ContentElement = untyped insertion;
			//var parent = this.parentElement;
			var children = point.getDistributedNodes();
			
			for (child in children) {
				var childUid = stampUid( child );
				//var nodelist = head.querySelectorAll( this.parentElement.nodeName + ' > ' + child.nodeName );
				var nodelist = host.querySelectorAll( host.nodeName + ' > ' + child.nodeName );
				
				var match = false;
				for (node in nodelist) {
					var nodeUid = stampUid( node );
					match = nodeUid == childUid;
					if (match) break;
					
				}
				
				if (!match) {
					var clone = window.document.importNode( child, true );
					//head.insertBefore(clone, this);
					add( clone );
					
				}
				
			}
			
		}
		
	}
	
}
