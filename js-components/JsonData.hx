package ;

import js.html.*;
import js.Browser.*;
import uhx.uid.Hashids;
import uhx.select.Json;
import haxe.Constraints.Function;

using haxe.io.Path;

class JsonData extends Component {
	
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
			results = results.concat( uhx.select.Json.find(data.get( key ), selector) );
			
		}
		
		console.log( results );
		
		if (results.length > 0) {
			done();
			this.parentNode.insertBefore(window.document.createTextNode(results[0]), this);
			removeSelf();
			
		}
		
	}
	
	private override function removeSelf():Void {
		this.parentNode.removeChild(this);
	}
	
}
