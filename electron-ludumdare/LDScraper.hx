package ;

import js.Node.*;
import tink.Json.*;
import js.Browser.*;
import LDController;
import js.html.Node;
import js.html.Element;
import haxe.extern.Rest;
import haxe.Constraints.Function;

import electron.renderer.IpcRenderer;

using StringTools;

class LDScraper {
	
	private var framework:String;
	//private var electron:Dynamic;
	//private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
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
		//electron = require('electron');
		//ipcRenderer = electron.ipcRenderer;
		IpcRenderer.once('payload', function(event, data) {
			framework = data;
			console.log( framework );
			search();
		});
		IpcRenderer.once('entry', function(event, data) {
			trace( data );
			var entry:LDEntry = parse(data);
			var timeout = null;
			timeout = setTimeout( function() {
				clearTimeout( timeout );
				completeUpdate( entry );
			}, 1000 );
			update( entry );
		});
	}
	
	private function qsa(selector:String):Array<Node> {
		console.log( selector );
		return [for (n in window.document.querySelectorAll( selector )) n];
	}
	
	private function search():Void {
		var entries:Array<Element> = cast qsa('.entry.body .preview tr td a');
		
		console.log( entries );
		
		var results = [for (entry in entries) {
			author:{ name:entry.childNodes[entry.childNodes.length -1].textContent, url:'' }, 
			url: entry.getAttribute('href'),
			name: entry.querySelectorAll('.title')[0].textContent,
			type: Compo, platforms: [], links: [], frameworks: [framework],
		}];
		
		console.log( results );
		console.log( stringify( {data:(results:Array<LDEntry>)} ) );
		
		IpcRenderer.send(framework, stringify( {data:(results:Array<LDEntry>)} ));
		
	}
	
	private function update(entry:LDEntry):Void {
		console.log( 'updating ${entry.name}' );
		
		var links:Array<Element> = cast qsa('.links ul li a');
		for (link in links) entry.links.push( {url: link.getAttribute('href'), label: link.textContent.toLowerCase()} );
		console.log( links );
		
		var type = Compo;
		var possibleTypes:Array<Element> = cast qsa('div i');
		if (possibleTypes.length > 0) for (t in possibleTypes) if (t.textContent.toLowerCase().indexOf('jam entry') > -1) {
			type = Jam;
			
		}
		
		// TODO download query page and entry pages for testing, instead of hitting LD hard.
		entry.type = type;
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
		
		completeUpdate( entry );
	}
	
	private function completeUpdate(entry:LDEntry):Void {
		IpcRenderer.send('' + window.location, stringify( entry ));
	}
	
}
