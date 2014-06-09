package ;

import sys.io.File;
import uhx.sys.Tuli;

using Detox;
using StringTools;
using haxe.io.Path;
using sys.FileSystem;

/**
 * ...
 * @author Skial Bainn
 */
class Finish {
	
	private static var files:Array<String> = [];
	
	public static function main() return Finish;
	
	public function new(tuli:Class<Tuli>) {
		untyped Tuli = tuli;
		
		Tuli.onExtension( 'html', handler, After );
		trace('adding fin after');
		Tuli.onFinish( finish, After );
	}
	
	public function handler(file:TuliFile, content:String) {
		files.push( file.path );
		return content;
	}
	
	public function finish() {
		for (file in files) if (Tuli.fileCache.exists( file )) {
			var c = Tuli.fileCache.get(file);
			
			var dom = c.parse();
			// Strip all empty <p> elements.
			var ps = dom.find('p').filter( function(n) return n.children(true).length == 0 );
			ps.remove();
			
			c = dom.html();
			
			while (c.indexOf('&amp;') > -1) {
				c = c.replace('&amp;', '&');
			}
			
			Tuli.fileCache.set( file, c );
		}
	}
	
}