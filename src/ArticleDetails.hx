package ;

import sys.io.FileInput;
import uhx.sys.Tuli;

using Detox;
using StringTools;
using haxe.io.Path;

/**
 * ...
 * @author Skial Bainn
 */
class ArticleDetails {

	public static function main() return ArticleDetails;
	
	public var processed:Array<String> = [];
	
	public function new(tuli:Tuli) {
		untyped Tuli = tuli;
		
		Tuli.onExtension( 'html', handler, After );
	}
	
	public function handler(file:TuliFile, content:String):String {
		return if (processed.indexOf( file.path ) == -1 && file.extra.md != null) {
			var dom = content.parse();
			var resources:Map<String, {url:String,title:String}> = file.extra.md.resources;
			
			var edit = dom.find('article aside > a:last-of-type');
			var path = Reflect.hasField(file, 'parent') ? Reflect.field(file, 'parent') : file.path;
			edit.setAttr('href', (edit.attr('href') + path).normalize());
			
			var handle = '@skial';
			var handleUrl = 'http://twitter.com/skial';
			if (resources.exists('_author')) {
				handle = resources.get('_author').title;
				handleUrl = resources.get('_author').url;
			}
			
			var details = dom.find('a[rel*="author"]');
			if (details.length > 0) {
				details.setAttr('href', handleUrl);
				details.setAttr('title', handle);
			}
			
			var time = dom.find('.details time');
			if (time.length > 0) {
				//time.setAttr( 'datetime', DateTools.format(file.stats.ctime, '%Y-%m-%d %H:%M') );
				time.setAttr( 'datetime', DateTools.format(file.created(), '%Y-%m-%d %H:%M') );
				// For some reason file.stats.ctime.getDate() throws an error...
				//var day = Std.parseInt( DateTools.format(file.stats.ctime, '%d') );
				var day = Std.parseInt( DateTools.format(file.created(), '%d') );
				//var value = DateTools.format(file.stats.ctime, '%A :: %B %Y');
				var value = DateTools.format(file.created(), '%A :: %B %Y');
				// http://www.if-not-true-then-false.com/2010/php-1st-2nd-3rd-4th-5th-6th-php-add-ordinal-number-suffix/
				value = value.replace( '::', switch ([11, 12, 13].indexOf(day) == -1 ? day % 10 : -1) {
					case 1: '${day}st';
					case 2: '${day}nd';
					case 3: '${day}rd';
					case _: '${day}th';
				} );
				time.setText( value );
			}
			
			dom.html();
		} else {
			content;
			
		}
		
		
	}
	
}