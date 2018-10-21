package composer;

using composer.Loader;
using StringTools;

class Loader {
	public var system:hscript.Interp;

	var parser:hscript.Parser;
	var program:hscript.Expr;
	var exports:haxe.ds.StringMap<Dynamic>;
	var mainPath:String;
	var fileName:String;
	var currPath:String;

	public function new(path:String) {
		mainPath = path;
		var script = sys.io.File.getContent(path);
		parser = new hscript.Parser();
		parser.allowTypes = true;
		program = parser.parseString(script);
		system = new hscript.Interp();
		exports = new haxe.ds.StringMap<Dynamic>();

		this.set("import", function(path, exports) {
			return eval(path, exports);
		});
		this.set("exports", exports);
		this.set("extend", extend);
		this.set("log", function(s) {
			Sys.println('${fileName}: ${s}');
		});

		// this.set("loadPackage", loadPackage);
		this.loadPackage();
	}

	public function set(name:String, val:Dynamic) {
		system.variables.set(name, val);
	}

	public function get(name:String) {
		return system.variables.get(name);
	}

	public function eval(path:String, ?exports:Array<String>) {
		var file = mainPath;
		fileName = mainPath.split("/")[mainPath.split("/").length - 1];
		currPath = mainPath.replace(fileName, "");
		var ext = fileName.split(".")[1];

		var loader = new Loader('${currPath}${path}.${ext}');
		var ret = loader.run();

		if (exports != null) {
			for (export in exports) {
				if (!loader.get("exports").exists(export))
					throw 'there is no export \'${export}\' in script ${path}';
				set(export, loader.get("exports").get(export));
			}
			return loader.get("exports");
		}

		return ret;
	}

	public function loadPackage() {
		var _classes = CompileTime.getAllClasses();

		for (_class in _classes) {
			this.set(Type.getClassName(_class), _class);
		}
	}

	public function extend(name:String, struct:Dynamic, module:Dynamic) {
		var fields:Array<String>;
		if (Type.typeof(module) == Type.ValueType.TObject) {
			fields = Reflect.fields(module);
			for (key in fields) {
				Reflect.setField(struct, key, Reflect.getProperty(module, key));
			}
		}

		set(name, struct);
	}

	public function run():Dynamic {
		return system.execute(program);
	}
}
