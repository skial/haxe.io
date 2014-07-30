package ;

import uhx.sys.Tuli;
import uhx.tuli.util.File;

using Detox;

/**
 * ...
 * @author Skial Bainn
 */
class ImageFigure {
	
	public static function main() return ImageFigure;
	private static var tuli:Tuli;

	public function new(t:Tuli) {
		tuli = t;
		
		tuli.onExtension( 'html', handler, After );
	}
	
	public function handler(file:File) {
		var dom = file.content.parse();
		
		for (img in dom.find( 'p > img:not([alt*="grid"])' )) {
			var caption = img.attr( 'title' );
			img = img.replaceWith( '<figure>${img.html()}<figcaption>$caption</figcaption></figure>'.parse() );
		}
		
		file.content = dom.html();
	}
	
}