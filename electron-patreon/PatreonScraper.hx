package ;

import js.Node.*;
import js.node.Fs;
import tink.Json.*;
import js.Browser.*;
import js.html.Node;
import uhx.sys.Seri;
import js.html.Element;
import haxe.Serializer;
import haxe.extern.Rest;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.DynamicAccess;
import js.html.DOMElement;
import haxe.Constraints.Function;

import CommunityPatreon.PatreonData;
import CommunityPatreon.PatreonPayload;
import CommunityPatreon.PatreonDuration;

using StringTools;
using unifill.Unifill;

typedef Patreon = {
	var data:{
		attributes:CreatorAttributes,
	};
	var included:Array<{
		?attributes:CampaignAttributes
	}>;
}
typedef CreatorAttributes = {
	var created_at:String;
	var creation_name:String;
	var is_monthly:Bool;
	var one_liner:Null<String>;
	var patron_count:Int;
	var pay_per_name:String;
	var pledge_sum:Int;
}
typedef CampaignAttributes = {
	@:optional var about:String;
	@:optional var facebook:String;
	@:optional var full_name:String;
	@:optional var twitter:String;
	@:optional var url:String;
	@:optional var vanity:String;
}


class PatreonScraper {
	
	private static var whitespace = [for (codepoint in Seri.getCategory('Zs')) codepoint];
	private var electron:Dynamic;
	private var ipcRenderer:{on:String->Function->Dynamic, once:String->Function->Dynamic, send:String->Rest<Dynamic>->Void};
	
	public static function main() {
		var con:PatreonScraper = null;
		
		switch (window.document.readyState) {
			case 'complete':
				con = new PatreonScraper();
				
			case _:
				window.document.addEventListener(
					'DOMContentLoaded', 
					function() con = new PatreonScraper(),
					false
				);
				
		}
	}
	
	public function new() {
		trace( window.location );
		electron = require('electron');
		ipcRenderer = electron.ipcRenderer;
		if (window.document.documentElement.outerHTML != '<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;"></pre></body></html>') {
			ipcRenderer.on('payload', function(e, d) process( parse(d) ));
			
		}
		
	}
	
	private function process(data:PatreonData):Void {
		trace( 'recieved payload' );
		/*inline function qsa(selector:String):Array<Node> {
			return [for (n in window.document.querySelectorAll( selector )) n];
		}*/
		
		//try {
		trace( data );
		var content = window.document.body.textContent;
		var start = content.indexOf('creator = {');
		var end = content.indexOf('};', start);
		var slice = content.substr(start+10, end-(start+10)+1).trim();
		//trace( start, end, slice );
		var json:Patreon = parse(slice);//tink.Json.parse(slice);
		trace( json.data.attributes, json.included );
		/*var status:Array<Node> = qsa( '[class*="creatorInfoValue"], [class*="creatorInfoLabel"]' );
				while (status.length > 0) {
				var pair = [status.pop().textContent, status.pop().textContent];
				switch (pair) {
				case [count, 'patrons'] | ['patrons', count] | [count, 'patron'] | ['patron', count]:
				trace( count, 'patrons' );
				data.patrons = Std.parseInt( count );
				
				case [value = _.startsWith('$') => true, duration] | [duration, value = _.startsWith('$') => true]:
				trace( pair[0], pair[1] );
				data.income = Std.parseFloat( value.substring(1) );
				data.duration = clean( duration );
				
				case [_, _]:
				trace( pair );
			}
			
		}

		var name = qsa( '[class*="creatorTitleName"]' )[0];
		var isCreating = qsa( '[class*="IsCreating"]' )[0];
		var lastUpdated = qsa( '[class*="timestamp"]' )[0];
		var socials = qsa( '[class*="social"][href]' );
		var description = qsa( '[class*="ToggleableContent"][class*="stackable"]' )[0];*/
		
		if (json.included == null) json.included = [];
		var included:CampaignAttributes = json.included.length == 0 ? {
			about:'', facebook:'', full_name:'', twitter:'', url:'', vanity:''
		} : json.included.filter(function(a) return a.attributes.about != null )[0].attributes;
		var name = clean(included.full_name);
		var isCreating = json.data.attributes.creation_name != null ? clean(json.data.attributes.creation_name) : '';
		if (isCreating == null || isCreating == '') {
			isCreating = 'is creating ' + json.data.attributes.one_liner;
		} else {
			isCreating = 'is creating $isCreating';
		}
		//var lastUpdated = qsa( '[class*="timestamp"]' )[0];
		var socials = [for (i in [included.facebook, included.twitter]) if (i != null && i != '') i];
		//var description = json.included[0].attributes.about;
		data.patrons = json.data.attributes.patron_count != null ? json.data.attributes.patron_count : 0;
		data.duration = json.data.attributes.is_monthly != null ? json.data.attributes.is_monthly ? Month : Creation : Creation;
		data.income = data.duration == Month ? json.data.attributes.pledge_sum / 12 : json.data.attributes.pledge_sum;
		data.income = data.income == null ? 0 : data.income;
		//data.uri = included.url != null ? included.url : '' + window.location;
		
		/*if (name != null) data.name = clean( name.textContent.trim() );
		if (isCreating != null) data.summary = clean( isCreating.textContent.trim() );
		if (lastUpdated != null) data.update = clean( lastUpdated.textContent.trim() );
		data.links = [for (social in socials) cast (social,DOMElement).getAttribute('href')];*/
		
		if (name != null) data.name = name;
		if (isCreating != null) data.summary = isCreating;
		//if (lastUpdated != null) data.update = lastUpdated;
		if (socials != null) data.links = socials;
		
		trace( data );
		trace( stringify(data) );
		
		ipcRenderer.send(data.uri, stringify(data));
	}
	
	private static function clean(value:String):String {
		for (codepoint in whitespace) {
			value = value.uSplit( codepoint ).join(' ');
			
		}
		
		for (char in [',', '.']) if (value.endsWith(char)) {
			value = value.substring(0, value.length-1);
			
		}
		
		return value.trim();
	}
	
}
