package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;
import uhx.select.Json;
import haxe.Constraints.Function;

using StringTools;
using haxe.io.Path;

class JsonData extends ConvertTag {
	
	public static var data:Map<String, Dynamic> = new Map();
	
	public static function main() {
		window.document.addEventListener('DocumentJsonData', processJsonData);
		new JsonData();
	}
	
	public static function processJsonData(e:CustomEvent) {
		var stringly = haxe.Json.stringify(e.detail);
		if (!data.exists(stringly)) data.set(stringly, e.detail);
	}
	
	public function new() {
		self = this;
		super();
		
	}
	
	public override function createdCallback():Void {
		window.document.addEventListener('DocumentJsonData', storeAndUse);
		super.createdCallback();
	}
	
	private override function process() {
		for (key in data.keys()) {
			trace( key );
			useJsonData(data.get(key));
			
		}
		
	}
	
	private override function removeEvents():Void {
		window.document.removeEventListener('DocumentJsonData', storeAndUse);
		super.removeEvents();
	}
	
	public function storeAndUse(e:CustomEvent) {
		processJsonData(e);
		useJsonData(e.detail);
	}
	
	public function useJsonData(json:Dynamic) {
		trace( 'using json data' );
		console.log( json );
		
		var selector = this.getAttribute('select');
		console.log( selector );
		var results = [];
		
		for (key in data.keys()) {
			if (selector != null) results = results.concat( uhx.select.Json.find(data.get( key ), selector) );
			
			for (attribute in this.attributes) {
				switch (attribute.name.toLowerCase()) {
					case _.startsWith(':') => true if (attribute.value != ''):
						var _selector = attribute.value;
						var _matches = [].concat(uhx.select.Json.find(data.get( key ), _selector));
						if (_matches.length > 0) {
							var name = '_' + attribute.name.substring(1);
							var value = _matches.join(' ');
							
							if (this.hasAttribute( name )) value = this.getAttribute( name ) + ' $value';
							
							this.setAttribute( name, value );
							
						}
						
					case _:
						
				}
				
				
			}
			
		}
		
		console.log( results );
		
		for (result in results) {
			this.appendChild( window.document.createTextNode( result ) );
			
		}
		
		processComponent();
		done();
		removeSelf();
		
	}
	
}
