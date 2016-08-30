package ;

import js.Node.*;
import tink.Json.*;
import js.Browser.*;
import LDController;
import js.html.Node;
import js.html.Element;
import haxe.extern.Rest;
import haxe.Constraints.Function;

using StringTools;

class LDScraper {
	
	private var framework:String;
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var scraper:LDScraper = null;
		
		switch (window.document.readyState) {
			case 'complete':
				scraper = new LDScraper();
				
			case _:
				window.document.addEventListener(
					'DOMContentLoaded', 
					function() scraper = new LDScraper(),
					false
				);
				
		}
	}
	
	public function new() {
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		ipcRenderer.on('payload', function(event, data) {
			framework = data;
			search();
		});
		ipcRenderer.on('entry', function(event, data) {
			trace( data );
			update( parse(data) );
		});
	}
	
	private function qsa(selector:String):Array<Node> {
		return [for (n in window.document.querySelectorAll( selector )) n];
	}
	
	private function search():Void {
		var entries:Array<Element> = cast qsa('.entry.body .ld-post.post .entry.body .preview tr td a');
		
		var results = [for (entry in entries) {
			author:{ name:entry.childNodes[entry.childNodes.length -1].textContent, url:'' }, 
			url: entry.getAttribute('href'),
			name: entry.querySelectorAll('.title')[0].textContent,
			type: Compo, platforms: [], frameworks: [framework],
		}];
		
		console.log( results );
		console.log( stringify( {data:(results:Array<LDEntry>)} ) );
		
		ipcRenderer.send(framework, stringify( {data:(results:Array<LDEntry>)} ));
		
	}
	
	private function update(entry:LDEntry):Void {
		console.log( 'updating ${entry.name}' );
		
		var links:Array<Element> = cast qsa('.links ul li');
		for (link in links) entry.platforms.push( {url: link.getAttribute('href'), label: link.textContent.toLowerCase()} );
		console.log( links );
		
		var type = Compo;
		var possibleTypes:Array<Element> = cast qsa('div i');
		if (possibleTypes.length > 0) for (t in possibleTypes) if (t.textContent.toLowerCase().indexOf('jam entry') > -1) {
			type = Jam;
			
		}
		
		// TODO add backing off strategy into requesting entry pages.
		// TODO download query page and entry pages for testing, instead of hitting LD hard.
		/*e*/ntry.type = type;
		console.log( entry.type );
		
		var authors:Array<Element> = cast qsa('[href*="author"]');
		if (authors.length > 0) for (author in authors) {
			if (author.textContent.toLowerCase() == entry.author.name.toLowerCase()) {
				entry.author.url = author.getAttribute('href').replace('..', '');
				break;
				
			}
			
		}
		
		console.log( entry );
		console.log( window.location );
		
		ipcRenderer.send('' + window.location, stringify( entry ));
	}
	
}
