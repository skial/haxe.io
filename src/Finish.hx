package ;

import uhx.sys.Tuli;
import uhx.tuli.util.File;

using Detox;
using StringTools;
using haxe.io.Path;
using sys.FileSystem;
using uhx.tuli.util.File.Util;

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
		Tuli.onFinish( finish, After );
	}
	
	public function handler(file:File) {
		files.push( file.path );
		
	}
	
	public function finish() {
		for (file in files) if (Tuli.files.exists( file )) {
			var f = Tuli.files.get( file );
			var c = f.content;
			
			/*var dom = c.parse();
			
			
			c = dom.html();*/
			
			while (c.indexOf('&amp;') > -1) {
				c = c.replace('&amp;', '&');
			}
			
			f.content = c;
		}
	}
	
}