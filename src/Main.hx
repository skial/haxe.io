package ;

import byte.ByteData;
import uhx.lexer.MarkdownParser;

#if macro
import uhx.macro.Tuli;
import haxe.macro.Context;
import haxe.macro.Expr.ExprOf;
#end

using Detox;
using StringTools;
using haxe.io.Path;

/**
 * ...
 * @author Skial Bainn
 */
class Main {
	
	public static function main() {
		
	}
	
}

class Markdown implements Klas {
	
	#if macro
	public static function initialize() {
		Tuli.onExtension('md', handler);
	}
	
	private static var fileCache:Map<String, String> = new Map();
	
	public static function handler(path:String, content:String):String {
		// I hate this, need to spend some time on UTF8 so I dont have to manually
		// add international characters.
		var characters = ['№' => '&#8470;', 'ê' => '&ecirc;', 'ä'=>'&auml;', 'é'=>'&eacute;'];
		for (key in characters.keys()) content = content.replace(key, characters.get(key));
		
		var parser = new MarkdownParser();
		var tokens = parser.toTokens( ByteData.ofString( content ), path );
		var resources = new Map<String, {url:String,title:String}>();
		parser.filterResources( tokens, resources );
		
		var html = [for (token in tokens) parser.printHTML( token, resources )].join('');
		
		var template = resources.exists('_template') ? resources.get('_template') : { url:'', title:'' };
		var location = (path.directory() + '/${template.url}').normalize();
		
		// Look for a template in the markdown `[_template]: /path/file.html`
		if (template.title == null || template.title == '') {
			template.title = switch (tokens.filter(function(t) return switch (t.token) {
				case Keyword(Header(_, _, _)): true;
				case _: false;
			})[0].token) {
				case Keyword(Header(_, _, t)): t;
				case _: '';
			}
		}
		
		var content = '';
		
		if (!fileCache.exists( location )) {
			// Remove `template` from the list of files Tuli has found.
			if (Tuli.files.indexOf( location ) > -1) {
				Tuli.files.remove( location );
			}
			
			// If `template` has been loaded into the Tuli's `fileCache` remove it.
			// But not before getting its content for later use.
			if (Tuli.fileCache.exists( location )) {
				content = Tuli.fileCache.get(location);
				fileCache.set(location, content);
				Tuli.fileCache.remove( location );
			}
			
			// Tell Tuli to ignore this extension.
			if (Tuli.config.ignore.indexOf('md') == -1) {
				Tuli.config.ignore.push( 'md' );
			}
		} else {
			content = fileCache.get( location );
		}
		
		var data:Dynamic = Reflect.copy( Tuli.config );
		data.file = {
			name: path.withoutExtension().withoutDirectory(),
			title: template.title,
			content: html,
		}
		
		var dom = content.parse();
		dom.find('title').setText( data.file.title );
		dom.find('main').setInnerHTML( data.file.content );
		content = dom.html().replace('&amp;', '&').replace('&amp;', '&');
		
		// Add the new file location and contents into Tuli's `fileCache` which
		// it will save for us.
		Tuli.fileCache.set( path.withoutExtension() + '/index.html', content );
		
		return content;
	}
	#end
	
}

class SocialMetadata implements Klas {
	
	#if macro
	public static function initialize() {
		Tuli.onExtension( 'html', handler, After );
	}
	
	public static function handler(path:String, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		
		if (head != null) {
			
			
			
		}
		
		return content;
	}
	#end
	
}

class ImportHTML implements Klas {
	
	#if macro
	public static var partialCache:Map<String, String> = null;
	
	public static function initialize() {
		partialCache = new Map();
		Tuli.onExtension( 'html', handler, After );
	}
	
	public static function handler(path:String, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		var isPartial = head == null;
		
		
		
		if (isPartial && !partialCache.exists(path)) {
			partialCache.set( path, content );
		}
		
		return content;
	}
	#end
	
}