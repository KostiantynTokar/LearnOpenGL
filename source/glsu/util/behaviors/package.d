module glsu.util.behaviors;

/** 
 * Mixin template to add selected behaviors to a struct.
 *
 * Behaviors should be located one per module and module name must be a lower case of behavior name.
 */
mixin template Behaviors(Names...)
{
    import std.string : toLower;

    static foreach(name; Names)
    {
        mixin("import glsu.util.behaviors." ~ name.toLower ~ " : " ~ name ~ ";");
        mixin("mixin glsu.util.behaviors." ~ name.toLower ~ "." ~ name ~ "!();");
    }
}
