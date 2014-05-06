package ;

import haxe.Json;
import byte.ByteData;
import uhx.lexer.MarkdownParser;

using Lambda;
using Detox;
using Reflect;
using StringTools;
using haxe.io.Path;

#if macro
//using uhx.macro.Tuli;
#end

/**
 * ...
 * @author Skial Bainn
 */
class Main {
	
	public static function main() {
		
	}
	
}



/*
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
		//Tuli.onData(dataHandler, Before);
	}
	
	public static function dataHandler(data:Dynamic):Dynamic {
		var process:Process;
		var directory = Tuli.config.input.addTrailingSlash().normalize().replace(Sys.getCwd().normalize(), '');
		
		for (file in Tuli.config.files) {
			if (file.extra.github == null) {
				file.extra.github = { };
			}
			
			var url = 'https://api.github.com/repos/skial/haxe.io/commits?path=' + '/$directory${file.path}'.normalize();
			
			// If OAuth token and secret have been placed in
			// `secrets.json` then pass them along as this
			// increases the rate limit from 60 reqs per hour
			// to 5000.
			if (Tuli.secrets.github != null) {
				url += '&client_id=' + Tuli.secrets.github.id + '&client_secret=' + Tuli.secrets.github.secret;
			}
			
			// I'm only interested in the latest commits.
			if (file.extra.github.modified != null) {
				url += '&since=' + file.extra.github.modified;
			}
			
			// We use `curl` as https connections cant be requested
			// during macro mode.
			process = new Process('curl', [
				// On windows at least, curl fails when checking the ssl cert.
				// This forces it to be ignored.
				'-k',
				// Github needs a `User-Agent:` header to allow access to 
				// the api.
				'-A', 'skial/haxe.io tuli static site generator', 
				url
			]);
			
			var commits:Array<Commit> = Json.parse( process.stdout.readAll().toString() );
			if (commits.length > 0) {
				var first = commits[commits.length-1];
				
				// The first commit should be set as the author of the file.
				if (file.extra.github.modified == null) {
					file.extra.author = first.commit.author.name;
				}
				
				// Every other commit author to be listed as a contributor.
				file.extra.contributors = commits
					.map( function(s) return s.commit.author.name )
					.filter( function(s) return s != file.extra.author );
				
				// Set the github modified field to the last commit date.
				file.extra.github.modified = commits[0].commit.author.date;
				
				var userMap = new Map<String, Commit>();
				for (entry in commits) if (!userMap.exists(entry.commit.author.name)) {
					userMap.set(entry.commit.author.name, entry);
				}
				
				var fieldMap = [
					'login' => 'name',
					'url' => 'api_url',
					'html_url' => 'html_url',
				];
				
				for (contributor in (file.extra.contributors:Array<String>).concat([file.extra.author])) {
					var entry = userMap.get(contributor);
					var user = Tuli.config.users.filter( function(s) return s.name == contributor )[0];
					
					if (user == null) {
						user =  {
							name: contributor, 
							email: entry.commit.author.email, 
							avatar_url: 'https://secure.gravatar.com/avatar/' + entry.author.gravatar_id + '.png',
							profiles: [],
							isAuthor: false,
							isContributor: false,
						};
						Tuli.config.users.push(user);
					}
					
					if (!user.isAuthor) user.isAuthor = file.extra.author == contributor;
					if (!user.isContributor) user.isContributor = (file.extra.contributors:Array<String>).indexOf(user.name) > -1;
					if (user.avatar_url == null || user.avatar_url == '') {
						user.avatar_url = 'https://secure.gravatar.com/avatar/' + entry.author.gravatar_id + '.png';
					}
					
					var profiles = user.profiles.filter( function(s) return s.service == 'github' && user.name == contributor );
					
					if (profiles.length == 0) {
						user.profiles.push( { service: 'github', data: { name: contributor } } );
						profiles = user.profiles.filter( function(s) return s.service == 'github' );
					}
					
					for (profile in profiles) {
						var author = entry.author;
						
						for (key in fieldMap.keys()) {
							profile.data.setField( fieldMap.get(key), author.field(key) );
						}
					}
				}
			}
		}
		return data;
	}
	#end
	
}

class Markdown implements Klas {
	
	#if macro
	public static function initialize() {
		fileCache = new Map();
		Tuli.onExtension('md', handler, After);
	}
	
	private static var fileCache:Map<String, String> = null;
	
	public static function handler(file:TuliFile, content:String):String {
		// The output location to save the generated html.
		var spawned = file.path.withoutExtension() + '/index.html';
		var skip = FileSystem.exists( spawned ) && FileSystem.stat( spawned ).mtime.getTime() < file.stats.mtime.getTime();
		
		if (!skip) {
			// I hate this, need to spend some time on UTF8 so I dont have to manually
			// add international characters.
			var characters = ['ş' => '&#x015F;', '№' => '&#8470;', 'ê' => '&ecirc;', 'ä'=>'&auml;', 'é'=>'&eacute;', 'ø' => '&oslash;', '“'=>'&ldquo;', '”'=>'&rdquo;' ];
			for (key in characters.keys()) content = content.replace(key, characters.get(key));
			
			var parser = new MarkdownParser();
			var tokens = parser.toTokens( ByteData.ofString( content ), file.path );
			var resources = new Map<String, {url:String,title:String}>();
			parser.filterResources( tokens, resources );
			
			var html = [for (token in tokens) parser.printHTML( token, resources )].join('');
			
			// Look for a template in the markdown `[_template]: /path/file.html`
			var template = resources.exists('_template') ? resources.get('_template') : { url:'', title:'' };
			var location = if (template.url == '') {
				'/_template.html';
			} else {
				(file.path.directory() + '/${template.url}').normalize();
			}
			
			if (template.title == null || template.title == '') {
				var token = tokens.filter(function(t) return switch (t.token) {
					case Keyword(Header(_, _, _)): true;
					case _: false;
				})[0];
				
				if (token != null) {
					template.title = switch (token.token) {
						case Keyword(Header(_, _, t)): t;
						case _: '';
					}
				}
			}
			
			var content = '';
			
			var tuliFiles = Tuli.config.files.filter( function(f) return [location, file.path].indexOf( f.path ) > -1 );
			for (tuliFile in tuliFiles) tuliFile.ignore = true;
			
			if (!fileCache.exists( location )) {
				// Grab the templates content.
				if (Tuli.fileCache.exists( location )) {
					content = Tuli.fileCache.get(location);
					fileCache.set(location, content);
				} else {
					content = File.getContent( (Tuli.config.input + location).normalize() );
					Tuli.fileCache.set( location, content );
					fileCache.set( location, content );
				}
			} else {
				content = fileCache.get( location );
			}
			
			var dom = content.parse();
			
			dom.find('content[select="markdown"]').replaceWith( null, dtx.Tools.parse( html ) );
			var edit = dom.find('.article.details div:last-of-type a');
			edit.setAttr('href', (edit.attr('href') + file.path).normalize());
			content = dom.html();
			
			// Add the new file location and contents into Tuli's `fileCache` which
			// it will save for us.
			Tuli.fileCache.set( spawned, content );
			
			var tuliFile = tuliFiles.filter( function(f) return f.path == file.path );
			if (tuliFile.length > 0) {
				if (tuliFile[0].spawned.indexOf( spawned ) == -1) {
					tuliFile[0].spawned.push( spawned );
					Tuli.config.spawn.push( {
						size: 0,
						extra: {},
						spawned: [],
						ext: 'html',
						ignore: false,
						path: spawned,
						parent: tuliFile[0].path,
						created: Tuli.asISO8601(Date.now()),
						modified: Tuli.asISO8601(Date.now()),
						name: spawned.withoutDirectory().withoutExtension(),
					} );
				}
			}
			
		}
		
		return content;
	}
	#end
	
}

class ImportHTML implements Klas {
	
	#if macro
	public static var partials:Array<TuliFile> = null;
	public static var templates:Array<TuliFile> = null;
	
	public static function initialize() {
		partials = [];
		templates = [];
		Tuli.onExtension( 'html', handler, After );
		Tuli.onFinish( finish, After );
	}
	
	public static function handler(file:TuliFile, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		var isPartial = head.length == 0;
		var hasInjectPoint = dom.find('content[select]').length > 0;
		
		if (isPartial) {
			partials.push( file );
		} else if (hasInjectPoint) {
			templates.push( file );
		}
		
		return content;
	}
	
	public static function finish() {
		// Loop through and replace any `<content select="*" />` with
		// a matching `<link rel="import" />`.
		for (template in templates) {
			var output = '${Tuli.config.output}/${template.path}'.normalize();
			//var skip = FileSystem.exists( output ) && template.stats != null && FileSystem.stat( output ).mtime.getTime() < template.stats.mtime.getTime();
			var skip = template.isNewer();
			
			if (!skip) {
				var dom = Tuli.fileCache.get( template.path ).parse();
				if (template.path == 'index.html') {
					trace(dom.length);
				}
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
				contents = dom.find('content[select]:not(content[targets])');

				
				for (content in contents) {
					var selector = content.get('select');
					var items = dom.find( selector );
					/*trace( selector );
					trace( items );*/
					/*if (items.length > 0) {
						if ([for (att in content.attributes()) att].indexOf('text') == -1) {
							content = content.replaceWith(null, items);
						} else {
							content = content.replaceWith(items.text().parse());
						}
					}
				}
				
				// Remove all '<content />` from the DOM.
				dom.find('content[select]').remove();
				if (template.path == 'index.html') {
					trace( template );
					trace(dom.html());
				}
				Tuli.fileCache.set( template.path, dom.html() );
			}
			
		}
		
		for (partial in partials) {
			partial.ignore = true;
		}
	}
	#end
	
}*/

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
/*
class SocialMetadata implements Klas {
	
	#if macro
	private static var files:Array<String> = null;
	
	public static function initialize() {
		files = [];
		Tuli.onExtension( 'html', handler, After );
		Tuli.onFinish( finish, After );
	}
	
	public static function handler(file:TuliFile, content:String):String {
		var dom = content.parse();
		var head = dom.find('head');
		var isPartial = head.length == 0;
		
		if (!isPartial) {
			files.push( file.path );
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
	
	public static function handler(file:TuliFile, content:String) {
		files.push( file.path );
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
			
			/*Tuli.fileCache.set( file, c );
		}
	}
	#end
	
}*/