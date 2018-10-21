# hxComposer
Modular hscript-ing for Haxe


## Import and Export Modules for hscript 

Example:
```hx
var Math = {
    minus : function(x, y){
        return x - y;
    }
}


exports.set("Math", Math);
```

```hx
import("module2", ["Math"]);

extend("MyModule", {
    sum : function(x , y){
        return x+y;
    }
}, Math);

exports.set("MyModule", MyModule);
```

```hx
import("module", ["MyModule"]);

log(MyModule.minus(5, 8));
```
