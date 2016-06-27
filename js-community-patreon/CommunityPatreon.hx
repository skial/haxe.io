package ;

import haxe.Http;
import tink.Json.*;
import js.Browser.*;
import js.html.DOMElement;

typedef PatreonPayload = {
	var data:Array<PatreonData>;
}

typedef PatreonData = {
	var uri:String;
	@:optional var name:String;
	@:optional var patrons:Int;
	@:optional var income:Float;
	@:optional var profile:String;
	@:optional var summary:String;
	@:optional var description:String;
	@:optional var update:Null<String>;
	@:optional var links:Array<String>;
	@:optional var keywords:Array<String>;
	@:optional var duration:PatreonDuration;
}

@:enum abstract PatreonDuration(String) from String to String {
	public var Month = 'per month';
	public var Creation = 'per creation';
}

class CommunityPatreon {
	
	public static function main() {
		new CommunityPatreon();
	}
	
	private var locationSelectors:Map<String, String>;
	private var locationHandlers:Map<String, PatreonData->DOMElement>;
	
	public function new() {
		var url = window.document.querySelectorAll( 'script[data-community-patreons*=".json"]' )[0];
		if (url != null) {
			var href = '';
			var http = new Http( href = cast (url, DOMElement).getAttribute('data-community-patreons') );
			trace( href );
			locationSelectors = ['/frontpage' => 'main ul li:nth-child(5)', '/roundups' => 'article aside :last-child'];
			locationHandlers = [
			'/frontpage' => function(data) {
				trace( 'building /frontpage ${data.uri} dom' );
				var action = data.patrons > 0 ? 'Become their next' : 'Be the first';
				var supported = data.patrons > 0 ? 'currently unsupported.' : 'supported by <span class="patrons">${data.patrons}</span> people.';
				var ele = window.document.createLIElement();
				ele.setAttribute('class', 'community patreon');
				ele.innerHTML = '<a href="${data.uri}"><div class="name">${data.name}</div><p>${data.summary}, $supported</p><a href="${data.uri}" class="button">$action Patron</a></a>';
				return ele;
			},
			'/roundups' => function (data) {
				trace( 'building /roundups ${data.uri} dom' );
				var action = data.patrons > 0 ? 'Become their next' : 'Be the first';
				var supported = data.patrons > 0 ? 'currently unsupported.' : 'supported by <span class="patrons">${data.patrons}</span> people.';
				var ele = window.document.createDivElement();
				ele.setAttribute('class', 'community patreon');
				ele.innerHTML = '<a href="${data.uri}"><div class="name">${data.name}</div><p>${data.summary}, $supported</p><a href="${data.uri}" class="button">$action Patron</a></a>';
				return ele;
			}
			];
			
			#if debug
			http.onError = error;
			#end
			http.onData = recieved;
			http.request();
		}
	}
	
	private function recieved(data:String):Void {
		trace( 'data recieved' );
		var payload:PatreonPayload = parse(data);
		var location = untyped window.document.querySelectorAll( 'html[class]' )[0].classList;
		var match:String = '';
		var target:Null<String> = null;
		trace( location );
		if (location != null && location.length > 0) {
			for (key in locationSelectors.keys()) if (location.contains( key )) {
				target = locationSelectors.get( match = key );
				break;
				
			}
			
		}
		
		if (target != null) {
			var targetEle = window.document.querySelectorAll( target )[0];
			var builder = locationHandlers.get( match );
			trace( target, match );
			if (targetEle != null) {
				trace( 'adding patreon dom' );
				targetEle.parentNode.insertBefore( builder(payload.data[0]), targetEle.nextSibling );
				
			}
			
		}
		
	}
	
	#if debug
	private function error(reason:String):Void {
		trace( reason );
	}
	#end
	
}
