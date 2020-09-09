/// Package specific exceptions.
module glsu.exceptions;

import std.exception : basicExceptionCtors;

/** 
 * Exception type raised on failed loading of data and constructing objects with loaded data.
 */
class CreateException : Exception
{
    ///
    mixin basicExceptionCtors;
}