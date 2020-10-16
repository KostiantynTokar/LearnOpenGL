module stringalloc;

import std.typecons : Yes, No, Flag;
import std.traits : isSomeChar, isSomeString, isInstanceOf, Unqual;
import std.utf : encode;
import std.algorithm : copy;
import stdx.allocator.mallocator : Mallocator;
import containers.dynamicarray;
import automem.ref_counted : RefCounted;

enum isSomeAllocString(T) = isInstanceOf!(String, T);
enum isSomeStringGeneral(T) = isSomeString!T || isSomeAllocString!T;
template charTypeOfString(T)
if(isSomeStringGeneral!T)
{
    static if(is(T == U[], U))
    {
        alias charTypeOfString = Unqual!U;
    }
    else static if(is(T == String!(U, f, A), U, Flag!"zeroTerminated" f, A))
    {
        alias charTypeOfString = Unqual!U;
    }
    else
    {
        static assert(0);
    }
}
template representedString(T)
if(isSomeAllocString!T)
{
    alias representedString = T.RepresentedString;
}
template isZeroTerminated(T)
if(isSomeAllocString!T)
{
    static if(is(T == String!(U, f, A), U, Flag!"zeroTerminated" f, A))
    {
        enum isZeroTerminated = f;
    }
    else
    {
        static assert(0);
    }
}

template String(Char, Flag!"zeroTerminated" zeroTerminated = No.zeroTerminated, Allocator = Mallocator)
if(isSomeChar!Char && !is(Char == Unqual!Char))
{
    alias String = String!(Unqual!Char, zeroTerminated, Allocator);
}

struct String(Char = char, Flag!"zeroTerminated" zeroTerminated = No.zeroTerminated, Allocator = Mallocator)
if(isSomeChar!Char && is(Char == Unqual!Char))
{
public:
    alias InternalChar = immutable(Char);
    alias RepresentedString = InternalChar[];
    alias Storage = RefCounted!(DynamicArray!(InternalChar, Allocator), Allocator);

    @disable this();

    static if(zeroTerminated)
    {
        invariant((*_data)[$ - 1] == '\0');
    }

    this(in RepresentedString str) nothrow
    {
        _data = Storage.construct();
        assignImpl(str);
    }

    this(U, Flag!"zeroTerminated" f, A)(return in String!(U, f, A) str) nothrow
    {
        _data = Storage.construct();
        assignImpl(str);
    }

    size_t length() const pure nothrow @nogc @safe
    {
        static if(zeroTerminated)
        {
            return _data.length - 1;
        }
        else
        {
            return _data.length;
        }
    }

    scope ref typeof(this) opAssign(Str)(in Str str) nothrow
    if(isSomeString!Str || isInstanceOf!(String, Str))
    {
        return assignImpl(str);
    }

    scope ref typeof(this) opOpAssign(string op)(in Unqual!Char c) nothrow
    if(op == "~")
    {
        static if(zeroTerminated)
        {
            (*_data)[$ - 1] = c;
            _data.insert('\0');
        }
        else
        {
            _data.insert(c);
        }
        return this;
    }

    InternalChar opIndex(in size_t index) const pure nothrow @nogc
    in(index < length)
    {
        return (*_data)[index];
    }

    scope RepresentedString opIndex() const pure nothrow @nogc
    {
        return (*_data)[0 .. length];
    }

    scope RepresentedString opIndex(in size_t[2] slice) const pure nothrow @nogc
    in(slice[0] <= slice[1] && slice[1] <= length)
    {
        return (*_data)[slice[0] .. slice[1]];
    }

    size_t[2] opSlice(size_t dim : 0)(size_t start, size_t end) const pure nothrow @nogc @safe
    {
        return [start, end];
    }

    size_t opDollar(size_t dim : 0)() const pure nothrow @nogc @safe
    {
        return length;
    }

    scope RepresentedString rawString() const pure nothrow @nogc
    {
        return (*_data)[];
    }

    // auto opCast(Str)() const nothrow
    // if(isSomeAllocString!Str)
    // {
    //     import std.algorithm : each;

    //     alias StrChar = charTypeOfString!Str;

    //     Str res = representedString!Str.init;
    //     static if(isZeroTerminated!Str)
    //     {
    //         res._data.reserve(length + 1);
    //     }
    //     else
    //     {
    //         res._data.reserve(length);
    //     }
    //     static if(Char.sizeof <= StrChar.sizeof)
    //     {
    //         (*_data)[0 .. length].each!(c => res._data.insert(c));
    //     }
    //     else
    //     {
    //         StrChar[dchar.sizeof / StrChar.sizeof] buf;
    //         (*_data)[0 .. length].each!((c)
    //             {
    //                 immutable n = encode!(Yes.useReplacementDchar)(buf, c);
    //                 buf[0 .. n].each!(cc => res._data.insert(cc));
    //             });
    //     }
    //     static if(isZeroTerminated!Str)
    //     {
    //         res._data.insert('\0');
    //     }
    //     return res;
    // }
    // unittest
    // {
    //     import std.conv : castFrom;
    //     import std.meta : AliasSeq, Erase;
    //     import std.algorithm : equal;

    //     String source = cast(RepresentedString) "Hello";

    //     static foreach(C; Erase!(Char, AliasSeq!(char, wchar, dchar)))
    //     {{
    //         auto target = castFrom!(String).to!(String!(C, zeroTerminated, Allocator))(source);
    //     }}
    // }

    typeof(this) idup() const nothrow
    {
        return String(rawString[0 .. length]);
    }

    scope RepresentedString toString() const pure nothrow
    {
        return (*_data)[0 .. length];
    }

    import std.format : FormatSpec;
    void toString(W, C)(ref W w, scope const ref FormatSpec!C fmt) const
    {
        import std.format : formatValue;

        w.formatValue(toString(), fmt);
    }

    static if(zeroTerminated)
    {
        scope RepresentedString toStringz() const pure nothrow
        {
            return (*_data)[];
        }
    }
private:
    Storage _data;

    scope ref typeof(this) assignImpl(in RepresentedString str) nothrow
    {
        _data.resize(0);
        _data.reserve(str.length + (zeroTerminated ? 1 : 0));
        import std.algorithm : each;
        str.each!(c => _data.insert(c));
        static if(zeroTerminated)
        {
            _data.insert('\0');
        }
        return this;
    }

    scope ref typeof(this) assignImpl(U, Flag!"zeroTerminated" f, A)(return in String!(U, f, A) str) nothrow
    if(is(Unqual!U == Char))
    {
        import std.algorithm : each;

        _data.resize(0);
        _data.reserve(str.length + (zeroTerminated ? 1 : 0));
        static if(zeroTerminated == f)
        {
            str._data[].each!(c => _data.insert(c));
        }
        else static if(zeroTerminated && !f)
        {
            str._data[].each!(c => _data.insert(c));
            _data.insert('\0');
        }
        else
        {
            str._data[0 .. $ - 1].each!(c => _data.insert(c));
        }
        return this;
    }
}

alias StringC = String!(char);
alias StringW = String!(wchar);
alias StringD = String!(dchar);

alias StringCZ = String!(char, Yes.zeroTerminated);
alias StringWZ = String!(wchar, Yes.zeroTerminated);
alias StringDZ = String!(dchar, Yes.zeroTerminated);

//@nogc
unittest
{
    import std.conv : castFrom;
    import std.algorithm : equal;

    StringC sc = "Hello";
    assert(sc.length == 5);
    assert(sc.rawString.equal("Hello"));

    StringW sw = "Hello"w;
    assert(sw.length == 5);
    assert(sw.rawString.equal("Hello"w));

    StringCZ scz = "Hello";
    assert(scz.length == 5);
    assert(scz.rawString.equal("Hello\0"));
    
    StringC sc2 = sc.idup;
    assert(sc2.length == 5);
    assert(sc2.rawString.equal("Hello"));

    static assert(is(String!(const char) == String!(char)));
}
