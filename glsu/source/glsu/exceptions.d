/** 
 * Package specific exceptions.
 * 
 * Authors: Kostiantyn Tokar.
 * Copyright: (c) 2020 Kostiantyn Tokar.
 * License: MIT License.
 */
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