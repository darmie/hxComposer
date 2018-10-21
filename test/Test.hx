package;

import composer.Loader;

import TestClass;

class Test {

    static function main(){
        var loader = new Loader('${Sys.getCwd()}test/scripts/main.hscript');
        loader.set("TestClass", TestClass);
        loader.run();
    }

}