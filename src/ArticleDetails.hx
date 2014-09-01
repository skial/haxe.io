package ;

import sys.io.FileInput;
import uhx.sys.Tuli;
import uhx.tuli.util.File;

using Detox;
using StringTools;
using haxe.io.Path;

/**
 * ...
 * @author Skial Bainn
 */
class ArticleDetails {

	public static function main() return ArticleDetails;
	private static var tuli:Tuli;
	
	public var processed:Array<String> = [];
	
	public function new(t:Tuli) {
		tuli = t;
		
		tuli.onExtension( 'html', handler, After );
	}
	
	public function handler(file:File) {
		if (processed.indexOf( file.path ) == -1 && file.extra.md != null) {
			var dom = file.content.parse();
			var resources:Map<String, {url:String,title:String}> = file.extra.md.resources;
			
			var edit = dom.find('article aside > a:last-of-type');
			var path = Reflect.hasField(file, 'parent') ? Reflect.field(file, 'parent') : file.path;
			edit.setAttr('href', (
				edit.attr('href') + path.replace( tuli.config.input, '' ).replace( tuli.config.output, '' )
			).normalize());
			
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
				time.setAttr( 'datetime', DateTools.format(file.created, '%Y-%m-%d %H:%M') );
				// For some reason file.stats.ctime.getDate() throws an error...
				var day = Std.parseInt( DateTools.format(file.created, '%d') );
				var value = DateTools.format(file.created, '%A :: %B %Y');
				
				// http://www.if-not-true-then-false.com/2010/php-1st-2nd-3rd-4th-5th-6th-php-add-ordinal-number-suffix/
				value = value.replace( '::', switch ([11, 12, 13].indexOf(day) == -1 ? day % 10 : -1) {
					case 1: '${day}st';
					case 2: '${day}nd';
					case 3: '${day}rd';
					case _: '${day}th';
				} );
				time.setText( value );
			}
			
			// Video specific changes
			var meta = dom.find('meta[name="twitter:player"]');
			var iframe = dom.find('iframe[src*="youtube"]');
			if (meta.length > 0 && iframe.length > 0) {
				meta.setAttr('content', 'https:' + iframe.attr('src') );
				meta.afterThisInsert('<meta />'.parse().setAttr('name', 'twitter:player:height').setAttr('content', '360'));
				meta.afterThisInsert('<meta />'.parse().setAttr('name', 'twitter:player:width').setAttr('content', '640'));
			}
			
			file.content = dom.html();
			
		}
		
	}
	
}