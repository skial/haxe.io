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
	private static var tuli:Tuli;
	
	public function new(t:Tuli) {
		tuli = t;
		
		tuli.onExtension( 'html', handler, After );
		tuli.onFinish( finish, After );
	}
	
	public function handler(file:File) {
		files.push( file.path );
		
	}
	
	public function finish() {
		for (file in files) if (tuli.config.files.exists( file )) {
			var f = tuli.config.files.get( file );
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