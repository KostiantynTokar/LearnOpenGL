module glsu.util;

/** 
 * Import as expression.
 * Params:
 *   moduleName = name of a module to import from
 */
template from(string moduleName)
{
    mixin("import from = " ~ moduleName ~ ";");
}

/** 
 * UDA for UDAs.
 * All UDAs are attributed by this type.
 */
package struct UDA
{
}

/** 
* Hack to use until compiler bug with relaxed nothrow checks in nothrow context is fixed.
* Params:
*   a = delegate that is to used in nothrow context
* Examples:
* ---
* void foo() {}
* @safe nothrow @nogc pure void main()
* {
*     debug debugHack({foo();});
* }    
* ---
*/
void debugHack(scope void delegate() a) nothrow @nogc @trusted
{
    auto hack = cast(void delegate() @nogc) a;
    try
    hack();
    catch(Exception e)
        assert(0, e.msg);
}