package ;

import js.html.*;
import js.Browser.*;
import haxe.ds.IntMap;
import uhx.uid.Hashids;
import haxe.DynamicAccess;
import uhx.select.JsonQuery;
import haxe.Constraints.Function;
import unifill.*;

using ConvertTag;
using StringTools;
using haxe.io.Path;
using unifill.Unifill;

class JsonData extends ConvertTag<Any, Any> {
	
	public static var data:DynamicAccess<Dynamic> = {};
	
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
			//trace( key );
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
		iterateNode(this, data);
		
		processComponent();
		
		finish();
		
	}
	
	private override function find(data:Any, selector:String):Array<Any> {
		//console.log( data, selector, [for (c in new CodePointIter(selector)) c], [for (c in new CodePointIter(selector)) c].uToString() );
		return cast uhx.select.JsonQuery.find(data, selector);
	}
	
	private override function stringify(data:Any):String {
		return if (Std.is(data, Array)) {
			(data:Array<Any>).join(' ');
			
		} else {
			'$data';
			
		}
		
	}
	
	private override function handleMatch(child:Node, match:Null<Any>):Array<Node> {
		return if (child.nodeType == Node.ELEMENT_NODE) {
			[iterateNode( cast window.document.importNode(child, true), cast match )];
			
		} else {
			[window.document.importNode(child, true)];
			
		}
		
	}
	
	public override function modifyData(node:Element, matches:Array<Any>, data:Any):Array<Any> {
		for (attribute in node.attributes) switch attribute.name {
			case _.startsWith('$') => true:
				if (attribute.value != null && attribute.value != '') {
					var result = processAttribute(attribute.name, attribute.value, data);
					
					for (match in matches) if ((Type.typeof(match) == TObject)) {
						var access:DynamicAccess<Any> = match;
						if (!access.exists(result.name.substring(1))) {
							access.set( result.name.substring(1), result.value );
							
						}
						
					}
					
				}
				
			case _:
				
		}
		
		return matches;
	}
	
	public override function processAttribute(attrName:String, attrValue:String, data:Any):{name:String, value:String} {
		var result = {name:attrName, value:attrValue};
		
		if (attrValue.indexOf('{') > -1) {
			result.name = '_' + attrName.substring(1);
			var info = result.value.trackAndInterpolate('}'.code, ['{'.code => '}'.code], function(s) {
				var results = find(data, s);
				
				return results.length > 0 ? results.join(' ') : s;
			});
			
			result.value = info.value;
			
		} else {
			var matches = find(data, attrValue);
			
			if (matches.length > 0) {
				result.name = '_' + attrName.substring(1);
				var value = matches.join(' ');	// TODO Look into using separator attributes.
				
				result.value = value;
				
			}
			
		}
		
		return result;
	}
	
}
