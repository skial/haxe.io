package ;

import haxe.Json;
import byte.ByteData;
import uhx.lexer.MarkdownParser;

#if macro
import sys.io.Process;
import sys.FileSystem;
import uhx.macro.Tuli;
import haxe.macro.Context;
import haxe.macro.Expr.ExprOf;
#end

using Detox;
using Reflect;
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

private typedef Commit = {
	var sha:String;
	var commit: {
		author: { name:String, email:String, date:String },
		committer: { name:String, email:String, date:String },
		message:String,
		tree: { sha:String, url:String },
		url:String,
		comment_count:Int
	};
	var url:String;
	var html_url:String;
	var comments_url:String;
	var author: {
		login:String, id:String, avatar_url:String, gravatar_id:String,
		url:String, html_url:String, followers_url:String, following_url:String,
		gists_url:String, starred_url:String, subscriptions_url:String,
		organizations_url:String, repos_url:String, events_url:String,
		received_events_url:String, type:String, site_admin:Bool
	};
	var committer: {
		login:String, id:String, avatar_url:String, gravatar_id:String,
		url:String, html_url:String, followers_url:String, following_url:String,
		gists_url:String, starred_url:String, subscriptions_url:String,
		organizations_url:String, repos_url:String, events_url:String,
		received_events_url:String, type:String, site_admin:Bool
	};
	var parents: {
		sha:String, url:String, html_url:String
	};
}

class GithubInformation implements Klas {
	
	#if macro
	public static function initialize() {
		Tuli.onData(dataHandler, Before);
	}
	
	public static function dataHandler(data:Dynamic):Dynamic {
		var process:Process;
		var directory = Tuli.config.input.normalize().replace(Sys.getCwd().normalize(), '');
		for (file in Tuli.config.files) {
			process = new Process('curl', [
				// On windows, curl fails on checking the ssl cert.
				// This forces it to be ignored.
				'-k',
				// Github needs a `User-Agent:` header to access the api.
				'-A', 'skial/haxe.io tuli static site generator', 
				'https://api.github.com/repos/skial/haxe.io/commits?path=' + '/$directory/${file.path}'.normalize()
			]);
			
			var commits:Array<Commit> = Json.parse( process.stdout.readAll().toString() );
			var first = commits[commits.length-1];
			
			// The first commit should be set as the author of the file.
			file.extra.author = first.commit.author.name;
			// Every other commit author to be listed as a contributor.
			file.extra.contributors = commits
			.map( function(s) return s.commit.author.name )
			.filter( function(s) return s != file.extra.author );
			
			var user_map = new Map<String, Commit>();
			for (entry in commits) if (!user_map.exists(entry.commit.author.name)) {
				user_map.set(entry.commit.author.name, entry);
			}
			
			var field_map = [
				'login' => 'name',
				'url' => 'api_url',
				'html_url' => 'html_url',
				'gravatar_id' => 'gravatar_url',
			];
			
			for (contributor in (file.extra.contributors:Array<String>)) {
				var entry = user_map.get(contributor);
				
				if (Tuli.config.users.filter( function(s) return s.name == contributor ).length == 0) {
					Tuli.config.users.push( {
						name: contributor, 
						email: entry.commit.author.email, 
						avatar_url: 'https://secure.gravatar.com/avatar/' + entry.author.gravatar_id + '.png',
						profiles: [],
					} );
				}
				
				for (user in Tuli.config.users) {
					var profiles = user.profiles.filter( function(s) return s.service == 'github' && user.name == contributor );
					
					if (profiles.length == 0) {
						user.profiles.push( { service: 'github', data: { name: contributor } } );
						profiles = user.profiles.filter( function(s) return s.service == 'github' );
					}
					
					for (profile in profiles) {
						var author = entry.author;
						
						for (key in field_map.keys()) {
							profile.data.setField( field_map.get(key), author.field(key) );
						}
					}
				}
			}
			//file.extra.github = ;
		}
		return data;
	}
	#end
	
}

class Markdown implements Klas {
	
	#if macro
	public static function initialize() {
		remove = [];
		fileCache = new Map();
		Tuli.onExtension('md', handler, After);
		Tuli.onFinish( finish, After );
	}
	
	private static var remove:Array<String> = null;
	private static var fileCache:Map<String, String> = null;
	
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
		
		// Remove location from `Tuli.files`.
		//Tuli.files.remove( location );
		remove.push( location );
		
		if (!fileCache.exists( location )) {
			// Grab the templates content. Then remove it
			// from `Tuli.fileCache`.
			if (Tuli.fileCache.exists( location )) {
				content = Tuli.fileCache.get(location);
				fileCache.set(location, content);
				//Tuli.fileCache.remove( location );
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
		//dom.find('title').setText( data.file.title );
		dom.find('content[select="markdown"]').replaceWith( null, dtx.Tools.parse(data.file.content) );
		var edit = dom.find('.article.details div:last-of-type a');
		edit.setAttr('href', (edit.attr('href') + path).normalize());
		content = dom.html();
		
		// Add the new file location and contents into Tuli's `fileCache` which
		// it will save for us.
		Tuli.fileCache.set( path.withoutExtension() + '/index.html', content );
		
		return content;
	}
	
	public static function finish() {
		for (r in remove) {
			if (Tuli.files.indexOf( r ) > -1) Tuli.files.remove( r );
			if (Tuli.fileCache.exists( r )) Tuli.fileCache.remove( r );
		}
		remove = [];
	}
	#end
	
}

class ImportHTML implements Klas {
	
	#if macro
	public static var partials:Array<String> = null;
	public static var templates:Array<String> = null;
	
	public static function initialize() {
		partials = [];
		templates = [];
		Tuli.onExtension( 'html', handler, After );
		Tuli.onFinish( finish, After );
	}
	
	public static function handler(path:String, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		var isPartial = head.length == 0;
		var hasInjectPoint = dom.find('content[select]').length > 0;
		
		if (isPartial) {
			partials.push( path );
		} else if (hasInjectPoint) {
			templates.push( path );
		}
		
		return content;
	}
	
	public static function finish() {
		// Loop through and replace any `<content select="*" />` with
		// a matching `<link rel="import" />`.
		for (template in templates) {
			var dom = Tuli.fileCache.get( template ).parse();
			var contents = dom.find('content[select]');
			
			for (content in contents) {
				var selector = content.get('select');
				
				if (selector.startsWith('#')) {
					selector = selector.substring(1);
					var key = '$selector.html';
					var partial = Tuli.fileCache.get( key ).parse();
					
					content = content.replaceWith(null, partial.first().children());
					
				} else {
					// You have to be fecking difficult, we have to
					// loop through EACH partial and check the top
					// most element for a match. Thanks.
				}
				
			}
			dom.find('link[rel="import"]').remove();
			
			// Find any remaining `<content />` and try filling them
			// with anything that matches their own selector.
			// TODO Either move this part to another "plugin" or move the markdown renderer before this plugin runs.
			contents = dom.find('content[select]:not(content[data-targets])');
			
			for (content in contents) {
				var selector = content.get('select');
				var items = dom.find( selector );
				/*trace( selector );
				trace( items );*/
				if (items.length > 0) {
					if ([for (att in content.attributes()) att].indexOf('data-text') == -1) {
						content = content.replaceWith(null, items);
					} else {
						content = content.replaceWith(items.text().parse());
					}
				}
			}
			
			// Remove all '<content />` from the DOM.
			dom.find('content[select]').remove();
			
			Tuli.fileCache.set( template, dom.html() );
			
		}
		
		for (partial in partials) {
			Tuli.files.remove(partial);
			Tuli.fileCache.remove(partial);
		}
	}
	#end
	
}

/*class RoundupFooter implements Klas {
	
	#if macro
	public static function initialize() {
		Tuli.onExtension( 'html', handler, After );
	}
	
	public static function handler(path:String, content:String):String {
		if (path.indexOf('roundups') > -1) {
			// Remove the `index.html` and `roundups` which should
			// leave the issue number `193`.
			var issue = path.directory().withoutDirectory();
			
			if (issue != '' && issue != 'roundups') {
				var dom = content.parse();
				var footer = dom.find('footer');
				
				var prevPath = path.replace(issue, '' + (Std.parseInt(issue) - 1));
				var hasPrev = Tuli.fileCache.exists( prevPath );
				
				var nextPath = path.replace(issue, '' + (Std.parseInt(issue) + 1));
				var hasNext = Tuli.fileCache.exists( nextPath );
				
				if (hasPrev) {
					var dom = Tuli.fileCache.get( prevPath ).parse();
					var title = dom.find('h1:first-of-type');
					footer.find('ul').addCollection( '<li>${title.html()}</li>'.parse() );
				}
				
				trace( content = dom.html() );
			}
		}
		return content;
	}
	#end
	
}*/

class SocialMetadata implements Klas {
	
	#if macro
	private static var files:Array<String> = null;
	
	public static function initialize() {
		files = [];
		Tuli.onExtension( 'html', handler, After );
		Tuli.onFinish( finish, After );
	}
	
	public static function handler(path:String, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		var isPartial = head.length == 0;
		
		if (!isPartial) {
			files.push( path );
		}
		
		return content;
	}
	
	public static function finish() {
		for (file in files) {
			var dom = Tuli.fileCache.get( file ).parse();
			var metaTitle = dom.find('meta[property="og:title"]');
			var metaDesc = dom.find('meta[property="og:description"]');
			var metaUrl = dom.find('meta[property="og:url"]');
			
			if (metaTitle.length > 0) metaTitle.setAttr('content', dom.find('title').text());
			
			if (metaDesc.length > 0) {
				var paragraphs = dom.find('p');
				var desc = ~/\s+/g.replace(paragraphs.text(), ' ').substring(0, 200);
				desc = desc.substring(0, desc.lastIndexOf(' '));
				metaDesc.setAttr('content', '$desc...');
			}
			
			if (metaUrl.length > 0) {
				var url = 'http://haxe.io/$file'.normalize();
				if (url.endsWith('index.html')) url = url.directory().addTrailingSlash();
				metaUrl.setAttr('content', url);
			}
			
			Tuli.fileCache.set( file, dom.html() );
		}
	}
	#end
	
}

// Hate this.
class Finish implements Klas {
	
	#if macro
	private static var files:Array<String> = null;
	
	public static function initialize() {
		files = [];
		Tuli.onExtension( 'html', handler, After );
		Tuli.onFinish( finish, After );
	}
	
	public static function handler(path:String, content:String) {
		files.push( path );
		return content;
	}
	
	public static function finish() {
		for (file in files) if (Tuli.fileCache.exists( file )) {
			var c = Tuli.fileCache.get(file);
			while (c.indexOf('&amp;') > -1) {
				c = c.replace('&amp;', '&');
			}
			// HTML5 tidy application during html=>xml conversion
			// wraps javascript wrapped in <script> tags with CDATA.
			// Adding type="text/javascript" seems to force the CDATA
			// to be commented out.
			/*while (c.indexOf('<![CDATA[') > -1) {
				c = c.replace('<![CDATA[', '');
			}
			while (c.indexOf(']]>') > -1) {
				c = c.replace(']]>', '');
			}*/
			
			Tuli.fileCache.set( file, c );
		}
	}
	#end
	
}