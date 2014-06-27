package ;


/**
 * ...
 * @author Skial Bainn
 * @see https://github.com/audreyr/favicon-cheat-sheet
 */
class Favicon {
	
	public static var ico:Array<Int> = [16, 24, 32, 48, 64];
	public static var sizes:Array<Int> = [57, 72, 96, 114, 120, 128, 144, 152, 195, 228];
	
	public static function main() {
		for (size in sizes.concat( ico )) {
			// make sure inkscape is installed and in your PATH
			// @see https://stackoverflow.com/questions/9853325/how-to-convert-a-svg-to-a-png-with-image-magick
			Sys.command(
				'inkscape', 
				['-z', '-e', './src/img/favicon/$size.png', '-w', '$size', '-h', '$size', '-b', '#f15922', './src/svg/logo_white.min.svg']
			);
		}
		
		// create favicon.ico in the root directory using 
		// imagemagicks convert command out of the ico array sizes.
		Sys.command('convert', [for (s in ico) './src/img/favicon/$s.png'].concat( ['./src/favicon.ico'] ));
	}
	
}