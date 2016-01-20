package types;

class CsHelper
{
    public function new()
    {
    }

    public static function log(msg: String): Void
    {
        cs.system.Console.WriteLine(msg);
    }
}
