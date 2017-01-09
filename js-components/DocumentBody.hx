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
		console.log( this, this.parentElement );
		
		var parent:Element = cast this.parentElement == null ? this.parentNode : this.parentElement;
		//var self = window.document.querySelectorAll('[uid="$uid"]');
		var insertionPoints = root.querySelectorAll('content');
		for (point in insertionPoints) {
			var content:ContentElement = untyped point;
			var distributed:Array<Node> = [for (node in content.getDistributedNodes()) node];
			
			for (child in distributed) {
				var nodelist = [];
				
				if (child.nodeType == Node.ELEMENT_NODE) {
					var ele:Element = cast child;
					ele.setAttribute( 'from', uid );
					ele.setAttribute( 'sub_uid', stampUid(ele) );
					nodelist = cast parent.querySelectorAll( parent.nodeName + ' > ' + ele.nodeName.toLowerCase() + [for (a in ele.attributes) '[${a.name}="${a.value}"]'].join('') );
					
				}
				
				//console.log( parent.nodeName, child.nodeName, nodelist.length );
				//for (node in nodelist) trace( node );
				
				/*var match = false;
				for (node in nodelist) {
					match = node == child;
					if (match) break;
					
				}*/
				
				
				//if (!match) {
				if (nodelist.length == 0) {
					var clone = window.document.importNode( child, true );
					parent.insertBefore(clone, this);
					
				}
				
			}
			
		}
		
	}
	
}
