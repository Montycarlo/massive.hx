package;

import haxe.macro.Context;
import haxe.macro.Expr;

class ExampleModel{

  public var propertyA:Int;
  public var propertyB:Int;

  public function new(a:Int,b:Int){
    this.propertyA = a;
    this.propertyB = b;
  }

}

@:final class Main{

  public static function main():Void{
    var oldModel = new ExampleModel(1, 2);
    var newModel = new ExampleModel(3, 4);

    // How I want it to end up looking?
    //@massive(propertyA) oldModel = newModel;

    // Selective properties
    massive(oldModel, newModel, ["propertyA", "propertyB"]);

    // Assign all properties that oldModel has
    massive(oldModel, newModel);

    trace('oldModel (reassigned) propertyA: ${oldModel.propertyA}');
    trace('oldModel (reassigned) propertyB: ${oldModel.propertyB}');
  }

  public static macro function massive(a:Expr, b:Expr, ?props:Array<String>){
    props = (props == null) ? extractFields(a) : props;

    var aID:String = extrIdentifier(a);
    var bID:String = extrIdentifier(b);
    var code = '{\n' + [for(p in props) '$aID.$p = $bID.$p;'].join('\n') + '}';
    return Context.parse(code, Context.currentPos());
  }

#if macro
  private static function extractFields(x:Expr){
    var x_type = Context.typeof(x);
    switch(x_type){
      case TInst(class_t, params):
         return [ for(f in class_t.get().fields.get()) f.name ];
      default: 
         var e = 'Massive Assignment Error: Object instance expected instead of $x_type';
         return Context.error(e, x.pos);
    }
  }

  private static function extrIdentifier(a:Expr){
    switch(a.expr){
      case EConst(CIdent(x)): return '$x';
      default:
        return Context.error('Object identifier expected instead of $a',a.pos);
    }
  }
#end

}
