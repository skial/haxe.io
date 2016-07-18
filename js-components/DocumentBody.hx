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
	
	public override function processComponent() {
		var parent = this.parentElement;
		var self = window.document.querySelectorAll('[uid="$uid"]');
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
		
	}
	
}
