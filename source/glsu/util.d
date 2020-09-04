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
struct UDA
{
}