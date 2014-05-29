package ;

import uhx.sys.Tuli;

using Detox;

/**
 * ...
 * @author Skial Bainn
 */
class ImageFigure {
	
	public static function main() return ImageFigure;

	public function new(tuli:Class<Tuli>) {
		untyped Tuli = tuli;
		
		Tuli.onExtension( 'html', handler, After );
	}
	
	public function handler(file:TuliFile, content:String):String {
		var dom = content.parse();
		
		for (img in dom.find( 'p > img:not([alt*="grid"])' )) {
			var caption = img.attr( 'title' );
			img = img.replaceWith( null, '<figure>${img.html()}<figcaption>$caption</figcaption></figure>'.parse() );
		}
		
		return dom.html();
	}
	
}