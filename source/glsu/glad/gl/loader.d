module glad.gl.loader;


private import glad.gl.funcs;
private import glad.gl.ext;
private import glad.gl.enums;
private import glad.gl.types;
alias Loader = void* delegate(const(char)*);

version(Windows) {
    private import core.sys.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
} else {
    private __gshared void* libGL;
}
extern(System) private @nogc alias gladGetProcAddressPtrType = void* function(const(char)*);
private __gshared gladGetProcAddressPtrType gladGetProcAddressPtr;

private
bool open_gl() @nogc {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))GetProcAddress(
                libGL, "wglGetProcAddress");
            return gladGetProcAddressPtr !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum const(char)*[] NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL",
                "/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
            ];
        } else {
            enum const(char)*[] NAMES = ["libGL.so.1", "libGL.so"];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))dlsym(libGL,
                        "glXGetProcAddressARB");
                    return gladGetProcAddressPtr !is null;
                }
            }
        }

        return false;
    }
}

private
void* get_proc(const(char)* namez) @nogc {
    if(libGL is null) return null;
    void* result;

    if(gladGetProcAddressPtr !is null) {
        result = gladGetProcAddressPtr(namez);
    }
    if(result is null) {
        version(Windows) {
            result = GetProcAddress(libGL, namez);
        } else {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

private
void close_gl() @nogc {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}

bool gladLoadGL() {
    bool status = false;

    if(open_gl()) {
        status = gladLoadGL(x => get_proc(x));
        close_gl();
    }

    return status;
}

static struct GLVersion { static int major = 0; static int minor = 0; }
private extern(C) char* strstr(const(char)*, const(char)*) @nogc;
private extern(C) int strcmp(const(char)*, const(char)*) @nogc;
private extern(C) int strncmp(const(char)*, const(char)*, size_t) @nogc;
private extern(C) size_t strlen(const(char)*) @nogc;
private bool has_ext(const(char)* ext) @nogc {
    if(GLVersion.major < 3) {
        const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);
        const(char)* loc;
        const(char)* terminator;

        if(extensions is null || ext is null) {
            return false;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc is null) {
                return false;
            }

            terminator = loc + strlen(ext);
            if((loc is extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\0')) {
                return true;
            }
            extensions = terminator;
        }
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}
bool gladLoadGL(Loader load) {
	glGetString = cast(typeof(glGetString))load("glGetString");
	if(glGetString is null) { return false; }
	if(glGetString(GL_VERSION) is null) { return false; }

	find_coreGL();
	load_GL_VERSION_1_0(load);
	load_GL_VERSION_1_1(load);
	load_GL_VERSION_1_2(load);
	load_GL_VERSION_1_3(load);
	load_GL_VERSION_1_4(load);
	load_GL_VERSION_1_5(load);
	load_GL_VERSION_2_0(load);
	load_GL_VERSION_2_1(load);
	load_GL_VERSION_3_0(load);
	load_GL_VERSION_3_1(load);
	load_GL_VERSION_3_2(load);
	load_GL_VERSION_3_3(load);

	find_extensionsGL();
	return GLVersion.major != 0 || GLVersion.minor != 0;
}

private {

void find_coreGL() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - '0';
    int minor = glversion[2] - '0';
    GLVersion.major = major; GLVersion.minor = minor;
	GL_VERSION_1_0 = (major == 1 && minor >= 0) || major > 1;
	GL_VERSION_1_1 = (major == 1 && minor >= 1) || major > 1;
	GL_VERSION_1_2 = (major == 1 && minor >= 2) || major > 1;
	GL_VERSION_1_3 = (major == 1 && minor >= 3) || major > 1;
	GL_VERSION_1_4 = (major == 1 && minor >= 4) || major > 1;
	GL_VERSION_1_5 = (major == 1 && minor >= 5) || major > 1;
	GL_VERSION_2_0 = (major == 2 && minor >= 0) || major > 2;
	GL_VERSION_2_1 = (major == 2 && minor >= 1) || major > 2;
	GL_VERSION_3_0 = (major == 3 && minor >= 0) || major > 3;
	GL_VERSION_3_1 = (major == 3 && minor >= 1) || major > 3;
	GL_VERSION_3_2 = (major == 3 && minor >= 2) || major > 3;
	GL_VERSION_3_3 = (major == 3 && minor >= 3) || major > 3;
	return;
}

void find_extensionsGL() {
	return;
}

void load_GL_VERSION_1_0(Loader load) {
	if(!GL_VERSION_1_0) return;
	glCullFace = cast(typeof(glCullFace))load("glCullFace");
	glFrontFace = cast(typeof(glFrontFace))load("glFrontFace");
	glHint = cast(typeof(glHint))load("glHint");
	glLineWidth = cast(typeof(glLineWidth))load("glLineWidth");
	glPointSize = cast(typeof(glPointSize))load("glPointSize");
	glPolygonMode = cast(typeof(glPolygonMode))load("glPolygonMode");
	glScissor = cast(typeof(glScissor))load("glScissor");
	glTexParameterf = cast(typeof(glTexParameterf))load("glTexParameterf");
	glTexParameterfv = cast(typeof(glTexParameterfv))load("glTexParameterfv");
	glTexParameteri = cast(typeof(glTexParameteri))load("glTexParameteri");
	glTexParameteriv = cast(typeof(glTexParameteriv))load("glTexParameteriv");
	glTexImage1D = cast(typeof(glTexImage1D))load("glTexImage1D");
	glTexImage2D = cast(typeof(glTexImage2D))load("glTexImage2D");
	glDrawBuffer = cast(typeof(glDrawBuffer))load("glDrawBuffer");
	glClear = cast(typeof(glClear))load("glClear");
	glClearColor = cast(typeof(glClearColor))load("glClearColor");
	glClearStencil = cast(typeof(glClearStencil))load("glClearStencil");
	glClearDepth = cast(typeof(glClearDepth))load("glClearDepth");
	glStencilMask = cast(typeof(glStencilMask))load("glStencilMask");
	glColorMask = cast(typeof(glColorMask))load("glColorMask");
	glDepthMask = cast(typeof(glDepthMask))load("glDepthMask");
	glDisable = cast(typeof(glDisable))load("glDisable");
	glEnable = cast(typeof(glEnable))load("glEnable");
	glFinish = cast(typeof(glFinish))load("glFinish");
	glFlush = cast(typeof(glFlush))load("glFlush");
	glBlendFunc = cast(typeof(glBlendFunc))load("glBlendFunc");
	glLogicOp = cast(typeof(glLogicOp))load("glLogicOp");
	glStencilFunc = cast(typeof(glStencilFunc))load("glStencilFunc");
	glStencilOp = cast(typeof(glStencilOp))load("glStencilOp");
	glDepthFunc = cast(typeof(glDepthFunc))load("glDepthFunc");
	glPixelStoref = cast(typeof(glPixelStoref))load("glPixelStoref");
	glPixelStorei = cast(typeof(glPixelStorei))load("glPixelStorei");
	glReadBuffer = cast(typeof(glReadBuffer))load("glReadBuffer");
	glReadPixels = cast(typeof(glReadPixels))load("glReadPixels");
	glGetBooleanv = cast(typeof(glGetBooleanv))load("glGetBooleanv");
	glGetDoublev = cast(typeof(glGetDoublev))load("glGetDoublev");
	glGetError = cast(typeof(glGetError))load("glGetError");
	glGetFloatv = cast(typeof(glGetFloatv))load("glGetFloatv");
	glGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv");
	glGetString = cast(typeof(glGetString))load("glGetString");
	glGetTexImage = cast(typeof(glGetTexImage))load("glGetTexImage");
	glGetTexParameterfv = cast(typeof(glGetTexParameterfv))load("glGetTexParameterfv");
	glGetTexParameteriv = cast(typeof(glGetTexParameteriv))load("glGetTexParameteriv");
	glGetTexLevelParameterfv = cast(typeof(glGetTexLevelParameterfv))load("glGetTexLevelParameterfv");
	glGetTexLevelParameteriv = cast(typeof(glGetTexLevelParameteriv))load("glGetTexLevelParameteriv");
	glIsEnabled = cast(typeof(glIsEnabled))load("glIsEnabled");
	glDepthRange = cast(typeof(glDepthRange))load("glDepthRange");
	glViewport = cast(typeof(glViewport))load("glViewport");
	return;
}

void load_GL_VERSION_1_1(Loader load) {
	if(!GL_VERSION_1_1) return;
	glDrawArrays = cast(typeof(glDrawArrays))load("glDrawArrays");
	glDrawElements = cast(typeof(glDrawElements))load("glDrawElements");
	glPolygonOffset = cast(typeof(glPolygonOffset))load("glPolygonOffset");
	glCopyTexImage1D = cast(typeof(glCopyTexImage1D))load("glCopyTexImage1D");
	glCopyTexImage2D = cast(typeof(glCopyTexImage2D))load("glCopyTexImage2D");
	glCopyTexSubImage1D = cast(typeof(glCopyTexSubImage1D))load("glCopyTexSubImage1D");
	glCopyTexSubImage2D = cast(typeof(glCopyTexSubImage2D))load("glCopyTexSubImage2D");
	glTexSubImage1D = cast(typeof(glTexSubImage1D))load("glTexSubImage1D");
	glTexSubImage2D = cast(typeof(glTexSubImage2D))load("glTexSubImage2D");
	glBindTexture = cast(typeof(glBindTexture))load("glBindTexture");
	glDeleteTextures = cast(typeof(glDeleteTextures))load("glDeleteTextures");
	glGenTextures = cast(typeof(glGenTextures))load("glGenTextures");
	glIsTexture = cast(typeof(glIsTexture))load("glIsTexture");
	return;
}

void load_GL_VERSION_1_2(Loader load) {
	if(!GL_VERSION_1_2) return;
	glDrawRangeElements = cast(typeof(glDrawRangeElements))load("glDrawRangeElements");
	glTexImage3D = cast(typeof(glTexImage3D))load("glTexImage3D");
	glTexSubImage3D = cast(typeof(glTexSubImage3D))load("glTexSubImage3D");
	glCopyTexSubImage3D = cast(typeof(glCopyTexSubImage3D))load("glCopyTexSubImage3D");
	return;
}

void load_GL_VERSION_1_3(Loader load) {
	if(!GL_VERSION_1_3) return;
	glActiveTexture = cast(typeof(glActiveTexture))load("glActiveTexture");
	glSampleCoverage = cast(typeof(glSampleCoverage))load("glSampleCoverage");
	glCompressedTexImage3D = cast(typeof(glCompressedTexImage3D))load("glCompressedTexImage3D");
	glCompressedTexImage2D = cast(typeof(glCompressedTexImage2D))load("glCompressedTexImage2D");
	glCompressedTexImage1D = cast(typeof(glCompressedTexImage1D))load("glCompressedTexImage1D");
	glCompressedTexSubImage3D = cast(typeof(glCompressedTexSubImage3D))load("glCompressedTexSubImage3D");
	glCompressedTexSubImage2D = cast(typeof(glCompressedTexSubImage2D))load("glCompressedTexSubImage2D");
	glCompressedTexSubImage1D = cast(typeof(glCompressedTexSubImage1D))load("glCompressedTexSubImage1D");
	glGetCompressedTexImage = cast(typeof(glGetCompressedTexImage))load("glGetCompressedTexImage");
	return;
}

void load_GL_VERSION_1_4(Loader load) {
	if(!GL_VERSION_1_4) return;
	glBlendFuncSeparate = cast(typeof(glBlendFuncSeparate))load("glBlendFuncSeparate");
	glMultiDrawArrays = cast(typeof(glMultiDrawArrays))load("glMultiDrawArrays");
	glMultiDrawElements = cast(typeof(glMultiDrawElements))load("glMultiDrawElements");
	glPointParameterf = cast(typeof(glPointParameterf))load("glPointParameterf");
	glPointParameterfv = cast(typeof(glPointParameterfv))load("glPointParameterfv");
	glPointParameteri = cast(typeof(glPointParameteri))load("glPointParameteri");
	glPointParameteriv = cast(typeof(glPointParameteriv))load("glPointParameteriv");
	glBlendColor = cast(typeof(glBlendColor))load("glBlendColor");
	glBlendEquation = cast(typeof(glBlendEquation))load("glBlendEquation");
	return;
}

void load_GL_VERSION_1_5(Loader load) {
	if(!GL_VERSION_1_5) return;
	glGenQueries = cast(typeof(glGenQueries))load("glGenQueries");
	glDeleteQueries = cast(typeof(glDeleteQueries))load("glDeleteQueries");
	glIsQuery = cast(typeof(glIsQuery))load("glIsQuery");
	glBeginQuery = cast(typeof(glBeginQuery))load("glBeginQuery");
	glEndQuery = cast(typeof(glEndQuery))load("glEndQuery");
	glGetQueryiv = cast(typeof(glGetQueryiv))load("glGetQueryiv");
	glGetQueryObjectiv = cast(typeof(glGetQueryObjectiv))load("glGetQueryObjectiv");
	glGetQueryObjectuiv = cast(typeof(glGetQueryObjectuiv))load("glGetQueryObjectuiv");
	glBindBuffer = cast(typeof(glBindBuffer))load("glBindBuffer");
	glDeleteBuffers = cast(typeof(glDeleteBuffers))load("glDeleteBuffers");
	glGenBuffers = cast(typeof(glGenBuffers))load("glGenBuffers");
	glIsBuffer = cast(typeof(glIsBuffer))load("glIsBuffer");
	glBufferData = cast(typeof(glBufferData))load("glBufferData");
	glBufferSubData = cast(typeof(glBufferSubData))load("glBufferSubData");
	glGetBufferSubData = cast(typeof(glGetBufferSubData))load("glGetBufferSubData");
	glMapBuffer = cast(typeof(glMapBuffer))load("glMapBuffer");
	glUnmapBuffer = cast(typeof(glUnmapBuffer))load("glUnmapBuffer");
	glGetBufferParameteriv = cast(typeof(glGetBufferParameteriv))load("glGetBufferParameteriv");
	glGetBufferPointerv = cast(typeof(glGetBufferPointerv))load("glGetBufferPointerv");
	return;
}

void load_GL_VERSION_2_0(Loader load) {
	if(!GL_VERSION_2_0) return;
	glBlendEquationSeparate = cast(typeof(glBlendEquationSeparate))load("glBlendEquationSeparate");
	glDrawBuffers = cast(typeof(glDrawBuffers))load("glDrawBuffers");
	glStencilOpSeparate = cast(typeof(glStencilOpSeparate))load("glStencilOpSeparate");
	glStencilFuncSeparate = cast(typeof(glStencilFuncSeparate))load("glStencilFuncSeparate");
	glStencilMaskSeparate = cast(typeof(glStencilMaskSeparate))load("glStencilMaskSeparate");
	glAttachShader = cast(typeof(glAttachShader))load("glAttachShader");
	glBindAttribLocation = cast(typeof(glBindAttribLocation))load("glBindAttribLocation");
	glCompileShader = cast(typeof(glCompileShader))load("glCompileShader");
	glCreateProgram = cast(typeof(glCreateProgram))load("glCreateProgram");
	glCreateShader = cast(typeof(glCreateShader))load("glCreateShader");
	glDeleteProgram = cast(typeof(glDeleteProgram))load("glDeleteProgram");
	glDeleteShader = cast(typeof(glDeleteShader))load("glDeleteShader");
	glDetachShader = cast(typeof(glDetachShader))load("glDetachShader");
	glDisableVertexAttribArray = cast(typeof(glDisableVertexAttribArray))load("glDisableVertexAttribArray");
	glEnableVertexAttribArray = cast(typeof(glEnableVertexAttribArray))load("glEnableVertexAttribArray");
	glGetActiveAttrib = cast(typeof(glGetActiveAttrib))load("glGetActiveAttrib");
	glGetActiveUniform = cast(typeof(glGetActiveUniform))load("glGetActiveUniform");
	glGetAttachedShaders = cast(typeof(glGetAttachedShaders))load("glGetAttachedShaders");
	glGetAttribLocation = cast(typeof(glGetAttribLocation))load("glGetAttribLocation");
	glGetProgramiv = cast(typeof(glGetProgramiv))load("glGetProgramiv");
	glGetProgramInfoLog = cast(typeof(glGetProgramInfoLog))load("glGetProgramInfoLog");
	glGetShaderiv = cast(typeof(glGetShaderiv))load("glGetShaderiv");
	glGetShaderInfoLog = cast(typeof(glGetShaderInfoLog))load("glGetShaderInfoLog");
	glGetShaderSource = cast(typeof(glGetShaderSource))load("glGetShaderSource");
	glGetUniformLocation = cast(typeof(glGetUniformLocation))load("glGetUniformLocation");
	glGetUniformfv = cast(typeof(glGetUniformfv))load("glGetUniformfv");
	glGetUniformiv = cast(typeof(glGetUniformiv))load("glGetUniformiv");
	glGetVertexAttribdv = cast(typeof(glGetVertexAttribdv))load("glGetVertexAttribdv");
	glGetVertexAttribfv = cast(typeof(glGetVertexAttribfv))load("glGetVertexAttribfv");
	glGetVertexAttribiv = cast(typeof(glGetVertexAttribiv))load("glGetVertexAttribiv");
	glGetVertexAttribPointerv = cast(typeof(glGetVertexAttribPointerv))load("glGetVertexAttribPointerv");
	glIsProgram = cast(typeof(glIsProgram))load("glIsProgram");
	glIsShader = cast(typeof(glIsShader))load("glIsShader");
	glLinkProgram = cast(typeof(glLinkProgram))load("glLinkProgram");
	glShaderSource = cast(typeof(glShaderSource))load("glShaderSource");
	glUseProgram = cast(typeof(glUseProgram))load("glUseProgram");
	glUniform1f = cast(typeof(glUniform1f))load("glUniform1f");
	glUniform2f = cast(typeof(glUniform2f))load("glUniform2f");
	glUniform3f = cast(typeof(glUniform3f))load("glUniform3f");
	glUniform4f = cast(typeof(glUniform4f))load("glUniform4f");
	glUniform1i = cast(typeof(glUniform1i))load("glUniform1i");
	glUniform2i = cast(typeof(glUniform2i))load("glUniform2i");
	glUniform3i = cast(typeof(glUniform3i))load("glUniform3i");
	glUniform4i = cast(typeof(glUniform4i))load("glUniform4i");
	glUniform1fv = cast(typeof(glUniform1fv))load("glUniform1fv");
	glUniform2fv = cast(typeof(glUniform2fv))load("glUniform2fv");
	glUniform3fv = cast(typeof(glUniform3fv))load("glUniform3fv");
	glUniform4fv = cast(typeof(glUniform4fv))load("glUniform4fv");
	glUniform1iv = cast(typeof(glUniform1iv))load("glUniform1iv");
	glUniform2iv = cast(typeof(glUniform2iv))load("glUniform2iv");
	glUniform3iv = cast(typeof(glUniform3iv))load("glUniform3iv");
	glUniform4iv = cast(typeof(glUniform4iv))load("glUniform4iv");
	glUniformMatrix2fv = cast(typeof(glUniformMatrix2fv))load("glUniformMatrix2fv");
	glUniformMatrix3fv = cast(typeof(glUniformMatrix3fv))load("glUniformMatrix3fv");
	glUniformMatrix4fv = cast(typeof(glUniformMatrix4fv))load("glUniformMatrix4fv");
	glValidateProgram = cast(typeof(glValidateProgram))load("glValidateProgram");
	glVertexAttrib1d = cast(typeof(glVertexAttrib1d))load("glVertexAttrib1d");
	glVertexAttrib1dv = cast(typeof(glVertexAttrib1dv))load("glVertexAttrib1dv");
	glVertexAttrib1f = cast(typeof(glVertexAttrib1f))load("glVertexAttrib1f");
	glVertexAttrib1fv = cast(typeof(glVertexAttrib1fv))load("glVertexAttrib1fv");
	glVertexAttrib1s = cast(typeof(glVertexAttrib1s))load("glVertexAttrib1s");
	glVertexAttrib1sv = cast(typeof(glVertexAttrib1sv))load("glVertexAttrib1sv");
	glVertexAttrib2d = cast(typeof(glVertexAttrib2d))load("glVertexAttrib2d");
	glVertexAttrib2dv = cast(typeof(glVertexAttrib2dv))load("glVertexAttrib2dv");
	glVertexAttrib2f = cast(typeof(glVertexAttrib2f))load("glVertexAttrib2f");
	glVertexAttrib2fv = cast(typeof(glVertexAttrib2fv))load("glVertexAttrib2fv");
	glVertexAttrib2s = cast(typeof(glVertexAttrib2s))load("glVertexAttrib2s");
	glVertexAttrib2sv = cast(typeof(glVertexAttrib2sv))load("glVertexAttrib2sv");
	glVertexAttrib3d = cast(typeof(glVertexAttrib3d))load("glVertexAttrib3d");
	glVertexAttrib3dv = cast(typeof(glVertexAttrib3dv))load("glVertexAttrib3dv");
	glVertexAttrib3f = cast(typeof(glVertexAttrib3f))load("glVertexAttrib3f");
	glVertexAttrib3fv = cast(typeof(glVertexAttrib3fv))load("glVertexAttrib3fv");
	glVertexAttrib3s = cast(typeof(glVertexAttrib3s))load("glVertexAttrib3s");
	glVertexAttrib3sv = cast(typeof(glVertexAttrib3sv))load("glVertexAttrib3sv");
	glVertexAttrib4Nbv = cast(typeof(glVertexAttrib4Nbv))load("glVertexAttrib4Nbv");
	glVertexAttrib4Niv = cast(typeof(glVertexAttrib4Niv))load("glVertexAttrib4Niv");
	glVertexAttrib4Nsv = cast(typeof(glVertexAttrib4Nsv))load("glVertexAttrib4Nsv");
	glVertexAttrib4Nub = cast(typeof(glVertexAttrib4Nub))load("glVertexAttrib4Nub");
	glVertexAttrib4Nubv = cast(typeof(glVertexAttrib4Nubv))load("glVertexAttrib4Nubv");
	glVertexAttrib4Nuiv = cast(typeof(glVertexAttrib4Nuiv))load("glVertexAttrib4Nuiv");
	glVertexAttrib4Nusv = cast(typeof(glVertexAttrib4Nusv))load("glVertexAttrib4Nusv");
	glVertexAttrib4bv = cast(typeof(glVertexAttrib4bv))load("glVertexAttrib4bv");
	glVertexAttrib4d = cast(typeof(glVertexAttrib4d))load("glVertexAttrib4d");
	glVertexAttrib4dv = cast(typeof(glVertexAttrib4dv))load("glVertexAttrib4dv");
	glVertexAttrib4f = cast(typeof(glVertexAttrib4f))load("glVertexAttrib4f");
	glVertexAttrib4fv = cast(typeof(glVertexAttrib4fv))load("glVertexAttrib4fv");
	glVertexAttrib4iv = cast(typeof(glVertexAttrib4iv))load("glVertexAttrib4iv");
	glVertexAttrib4s = cast(typeof(glVertexAttrib4s))load("glVertexAttrib4s");
	glVertexAttrib4sv = cast(typeof(glVertexAttrib4sv))load("glVertexAttrib4sv");
	glVertexAttrib4ubv = cast(typeof(glVertexAttrib4ubv))load("glVertexAttrib4ubv");
	glVertexAttrib4uiv = cast(typeof(glVertexAttrib4uiv))load("glVertexAttrib4uiv");
	glVertexAttrib4usv = cast(typeof(glVertexAttrib4usv))load("glVertexAttrib4usv");
	glVertexAttribPointer = cast(typeof(glVertexAttribPointer))load("glVertexAttribPointer");
	return;
}

void load_GL_VERSION_2_1(Loader load) {
	if(!GL_VERSION_2_1) return;
	glUniformMatrix2x3fv = cast(typeof(glUniformMatrix2x3fv))load("glUniformMatrix2x3fv");
	glUniformMatrix3x2fv = cast(typeof(glUniformMatrix3x2fv))load("glUniformMatrix3x2fv");
	glUniformMatrix2x4fv = cast(typeof(glUniformMatrix2x4fv))load("glUniformMatrix2x4fv");
	glUniformMatrix4x2fv = cast(typeof(glUniformMatrix4x2fv))load("glUniformMatrix4x2fv");
	glUniformMatrix3x4fv = cast(typeof(glUniformMatrix3x4fv))load("glUniformMatrix3x4fv");
	glUniformMatrix4x3fv = cast(typeof(glUniformMatrix4x3fv))load("glUniformMatrix4x3fv");
	return;
}

void load_GL_VERSION_3_0(Loader load) {
	if(!GL_VERSION_3_0) return;
	glColorMaski = cast(typeof(glColorMaski))load("glColorMaski");
	glGetBooleani_v = cast(typeof(glGetBooleani_v))load("glGetBooleani_v");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	glEnablei = cast(typeof(glEnablei))load("glEnablei");
	glDisablei = cast(typeof(glDisablei))load("glDisablei");
	glIsEnabledi = cast(typeof(glIsEnabledi))load("glIsEnabledi");
	glBeginTransformFeedback = cast(typeof(glBeginTransformFeedback))load("glBeginTransformFeedback");
	glEndTransformFeedback = cast(typeof(glEndTransformFeedback))load("glEndTransformFeedback");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glTransformFeedbackVaryings = cast(typeof(glTransformFeedbackVaryings))load("glTransformFeedbackVaryings");
	glGetTransformFeedbackVarying = cast(typeof(glGetTransformFeedbackVarying))load("glGetTransformFeedbackVarying");
	glClampColor = cast(typeof(glClampColor))load("glClampColor");
	glBeginConditionalRender = cast(typeof(glBeginConditionalRender))load("glBeginConditionalRender");
	glEndConditionalRender = cast(typeof(glEndConditionalRender))load("glEndConditionalRender");
	glVertexAttribIPointer = cast(typeof(glVertexAttribIPointer))load("glVertexAttribIPointer");
	glGetVertexAttribIiv = cast(typeof(glGetVertexAttribIiv))load("glGetVertexAttribIiv");
	glGetVertexAttribIuiv = cast(typeof(glGetVertexAttribIuiv))load("glGetVertexAttribIuiv");
	glVertexAttribI1i = cast(typeof(glVertexAttribI1i))load("glVertexAttribI1i");
	glVertexAttribI2i = cast(typeof(glVertexAttribI2i))load("glVertexAttribI2i");
	glVertexAttribI3i = cast(typeof(glVertexAttribI3i))load("glVertexAttribI3i");
	glVertexAttribI4i = cast(typeof(glVertexAttribI4i))load("glVertexAttribI4i");
	glVertexAttribI1ui = cast(typeof(glVertexAttribI1ui))load("glVertexAttribI1ui");
	glVertexAttribI2ui = cast(typeof(glVertexAttribI2ui))load("glVertexAttribI2ui");
	glVertexAttribI3ui = cast(typeof(glVertexAttribI3ui))load("glVertexAttribI3ui");
	glVertexAttribI4ui = cast(typeof(glVertexAttribI4ui))load("glVertexAttribI4ui");
	glVertexAttribI1iv = cast(typeof(glVertexAttribI1iv))load("glVertexAttribI1iv");
	glVertexAttribI2iv = cast(typeof(glVertexAttribI2iv))load("glVertexAttribI2iv");
	glVertexAttribI3iv = cast(typeof(glVertexAttribI3iv))load("glVertexAttribI3iv");
	glVertexAttribI4iv = cast(typeof(glVertexAttribI4iv))load("glVertexAttribI4iv");
	glVertexAttribI1uiv = cast(typeof(glVertexAttribI1uiv))load("glVertexAttribI1uiv");
	glVertexAttribI2uiv = cast(typeof(glVertexAttribI2uiv))load("glVertexAttribI2uiv");
	glVertexAttribI3uiv = cast(typeof(glVertexAttribI3uiv))load("glVertexAttribI3uiv");
	glVertexAttribI4uiv = cast(typeof(glVertexAttribI4uiv))load("glVertexAttribI4uiv");
	glVertexAttribI4bv = cast(typeof(glVertexAttribI4bv))load("glVertexAttribI4bv");
	glVertexAttribI4sv = cast(typeof(glVertexAttribI4sv))load("glVertexAttribI4sv");
	glVertexAttribI4ubv = cast(typeof(glVertexAttribI4ubv))load("glVertexAttribI4ubv");
	glVertexAttribI4usv = cast(typeof(glVertexAttribI4usv))load("glVertexAttribI4usv");
	glGetUniformuiv = cast(typeof(glGetUniformuiv))load("glGetUniformuiv");
	glBindFragDataLocation = cast(typeof(glBindFragDataLocation))load("glBindFragDataLocation");
	glGetFragDataLocation = cast(typeof(glGetFragDataLocation))load("glGetFragDataLocation");
	glUniform1ui = cast(typeof(glUniform1ui))load("glUniform1ui");
	glUniform2ui = cast(typeof(glUniform2ui))load("glUniform2ui");
	glUniform3ui = cast(typeof(glUniform3ui))load("glUniform3ui");
	glUniform4ui = cast(typeof(glUniform4ui))load("glUniform4ui");
	glUniform1uiv = cast(typeof(glUniform1uiv))load("glUniform1uiv");
	glUniform2uiv = cast(typeof(glUniform2uiv))load("glUniform2uiv");
	glUniform3uiv = cast(typeof(glUniform3uiv))load("glUniform3uiv");
	glUniform4uiv = cast(typeof(glUniform4uiv))load("glUniform4uiv");
	glTexParameterIiv = cast(typeof(glTexParameterIiv))load("glTexParameterIiv");
	glTexParameterIuiv = cast(typeof(glTexParameterIuiv))load("glTexParameterIuiv");
	glGetTexParameterIiv = cast(typeof(glGetTexParameterIiv))load("glGetTexParameterIiv");
	glGetTexParameterIuiv = cast(typeof(glGetTexParameterIuiv))load("glGetTexParameterIuiv");
	glClearBufferiv = cast(typeof(glClearBufferiv))load("glClearBufferiv");
	glClearBufferuiv = cast(typeof(glClearBufferuiv))load("glClearBufferuiv");
	glClearBufferfv = cast(typeof(glClearBufferfv))load("glClearBufferfv");
	glClearBufferfi = cast(typeof(glClearBufferfi))load("glClearBufferfi");
	glGetStringi = cast(typeof(glGetStringi))load("glGetStringi");
	glIsRenderbuffer = cast(typeof(glIsRenderbuffer))load("glIsRenderbuffer");
	glBindRenderbuffer = cast(typeof(glBindRenderbuffer))load("glBindRenderbuffer");
	glDeleteRenderbuffers = cast(typeof(glDeleteRenderbuffers))load("glDeleteRenderbuffers");
	glGenRenderbuffers = cast(typeof(glGenRenderbuffers))load("glGenRenderbuffers");
	glRenderbufferStorage = cast(typeof(glRenderbufferStorage))load("glRenderbufferStorage");
	glGetRenderbufferParameteriv = cast(typeof(glGetRenderbufferParameteriv))load("glGetRenderbufferParameteriv");
	glIsFramebuffer = cast(typeof(glIsFramebuffer))load("glIsFramebuffer");
	glBindFramebuffer = cast(typeof(glBindFramebuffer))load("glBindFramebuffer");
	glDeleteFramebuffers = cast(typeof(glDeleteFramebuffers))load("glDeleteFramebuffers");
	glGenFramebuffers = cast(typeof(glGenFramebuffers))load("glGenFramebuffers");
	glCheckFramebufferStatus = cast(typeof(glCheckFramebufferStatus))load("glCheckFramebufferStatus");
	glFramebufferTexture1D = cast(typeof(glFramebufferTexture1D))load("glFramebufferTexture1D");
	glFramebufferTexture2D = cast(typeof(glFramebufferTexture2D))load("glFramebufferTexture2D");
	glFramebufferTexture3D = cast(typeof(glFramebufferTexture3D))load("glFramebufferTexture3D");
	glFramebufferRenderbuffer = cast(typeof(glFramebufferRenderbuffer))load("glFramebufferRenderbuffer");
	glGetFramebufferAttachmentParameteriv = cast(typeof(glGetFramebufferAttachmentParameteriv))load("glGetFramebufferAttachmentParameteriv");
	glGenerateMipmap = cast(typeof(glGenerateMipmap))load("glGenerateMipmap");
	glBlitFramebuffer = cast(typeof(glBlitFramebuffer))load("glBlitFramebuffer");
	glRenderbufferStorageMultisample = cast(typeof(glRenderbufferStorageMultisample))load("glRenderbufferStorageMultisample");
	glFramebufferTextureLayer = cast(typeof(glFramebufferTextureLayer))load("glFramebufferTextureLayer");
	glMapBufferRange = cast(typeof(glMapBufferRange))load("glMapBufferRange");
	glFlushMappedBufferRange = cast(typeof(glFlushMappedBufferRange))load("glFlushMappedBufferRange");
	glBindVertexArray = cast(typeof(glBindVertexArray))load("glBindVertexArray");
	glDeleteVertexArrays = cast(typeof(glDeleteVertexArrays))load("glDeleteVertexArrays");
	glGenVertexArrays = cast(typeof(glGenVertexArrays))load("glGenVertexArrays");
	glIsVertexArray = cast(typeof(glIsVertexArray))load("glIsVertexArray");
	return;
}

void load_GL_VERSION_3_1(Loader load) {
	if(!GL_VERSION_3_1) return;
	glDrawArraysInstanced = cast(typeof(glDrawArraysInstanced))load("glDrawArraysInstanced");
	glDrawElementsInstanced = cast(typeof(glDrawElementsInstanced))load("glDrawElementsInstanced");
	glTexBuffer = cast(typeof(glTexBuffer))load("glTexBuffer");
	glPrimitiveRestartIndex = cast(typeof(glPrimitiveRestartIndex))load("glPrimitiveRestartIndex");
	glCopyBufferSubData = cast(typeof(glCopyBufferSubData))load("glCopyBufferSubData");
	glGetUniformIndices = cast(typeof(glGetUniformIndices))load("glGetUniformIndices");
	glGetActiveUniformsiv = cast(typeof(glGetActiveUniformsiv))load("glGetActiveUniformsiv");
	glGetActiveUniformName = cast(typeof(glGetActiveUniformName))load("glGetActiveUniformName");
	glGetUniformBlockIndex = cast(typeof(glGetUniformBlockIndex))load("glGetUniformBlockIndex");
	glGetActiveUniformBlockiv = cast(typeof(glGetActiveUniformBlockiv))load("glGetActiveUniformBlockiv");
	glGetActiveUniformBlockName = cast(typeof(glGetActiveUniformBlockName))load("glGetActiveUniformBlockName");
	glUniformBlockBinding = cast(typeof(glUniformBlockBinding))load("glUniformBlockBinding");
	glBindBufferRange = cast(typeof(glBindBufferRange))load("glBindBufferRange");
	glBindBufferBase = cast(typeof(glBindBufferBase))load("glBindBufferBase");
	glGetIntegeri_v = cast(typeof(glGetIntegeri_v))load("glGetIntegeri_v");
	return;
}

void load_GL_VERSION_3_2(Loader load) {
	if(!GL_VERSION_3_2) return;
	glDrawElementsBaseVertex = cast(typeof(glDrawElementsBaseVertex))load("glDrawElementsBaseVertex");
	glDrawRangeElementsBaseVertex = cast(typeof(glDrawRangeElementsBaseVertex))load("glDrawRangeElementsBaseVertex");
	glDrawElementsInstancedBaseVertex = cast(typeof(glDrawElementsInstancedBaseVertex))load("glDrawElementsInstancedBaseVertex");
	glMultiDrawElementsBaseVertex = cast(typeof(glMultiDrawElementsBaseVertex))load("glMultiDrawElementsBaseVertex");
	glProvokingVertex = cast(typeof(glProvokingVertex))load("glProvokingVertex");
	glFenceSync = cast(typeof(glFenceSync))load("glFenceSync");
	glIsSync = cast(typeof(glIsSync))load("glIsSync");
	glDeleteSync = cast(typeof(glDeleteSync))load("glDeleteSync");
	glClientWaitSync = cast(typeof(glClientWaitSync))load("glClientWaitSync");
	glWaitSync = cast(typeof(glWaitSync))load("glWaitSync");
	glGetInteger64v = cast(typeof(glGetInteger64v))load("glGetInteger64v");
	glGetSynciv = cast(typeof(glGetSynciv))load("glGetSynciv");
	glGetInteger64i_v = cast(typeof(glGetInteger64i_v))load("glGetInteger64i_v");
	glGetBufferParameteri64v = cast(typeof(glGetBufferParameteri64v))load("glGetBufferParameteri64v");
	glFramebufferTexture = cast(typeof(glFramebufferTexture))load("glFramebufferTexture");
	glTexImage2DMultisample = cast(typeof(glTexImage2DMultisample))load("glTexImage2DMultisample");
	glTexImage3DMultisample = cast(typeof(glTexImage3DMultisample))load("glTexImage3DMultisample");
	glGetMultisamplefv = cast(typeof(glGetMultisamplefv))load("glGetMultisamplefv");
	glSampleMaski = cast(typeof(glSampleMaski))load("glSampleMaski");
	return;
}

void load_GL_VERSION_3_3(Loader load) {
	if(!GL_VERSION_3_3) return;
	glBindFragDataLocationIndexed = cast(typeof(glBindFragDataLocationIndexed))load("glBindFragDataLocationIndexed");
	glGetFragDataIndex = cast(typeof(glGetFragDataIndex))load("glGetFragDataIndex");
	glGenSamplers = cast(typeof(glGenSamplers))load("glGenSamplers");
	glDeleteSamplers = cast(typeof(glDeleteSamplers))load("glDeleteSamplers");
	glIsSampler = cast(typeof(glIsSampler))load("glIsSampler");
	glBindSampler = cast(typeof(glBindSampler))load("glBindSampler");
	glSamplerParameteri = cast(typeof(glSamplerParameteri))load("glSamplerParameteri");
	glSamplerParameteriv = cast(typeof(glSamplerParameteriv))load("glSamplerParameteriv");
	glSamplerParameterf = cast(typeof(glSamplerParameterf))load("glSamplerParameterf");
	glSamplerParameterfv = cast(typeof(glSamplerParameterfv))load("glSamplerParameterfv");
	glSamplerParameterIiv = cast(typeof(glSamplerParameterIiv))load("glSamplerParameterIiv");
	glSamplerParameterIuiv = cast(typeof(glSamplerParameterIuiv))load("glSamplerParameterIuiv");
	glGetSamplerParameteriv = cast(typeof(glGetSamplerParameteriv))load("glGetSamplerParameteriv");
	glGetSamplerParameterIiv = cast(typeof(glGetSamplerParameterIiv))load("glGetSamplerParameterIiv");
	glGetSamplerParameterfv = cast(typeof(glGetSamplerParameterfv))load("glGetSamplerParameterfv");
	glGetSamplerParameterIuiv = cast(typeof(glGetSamplerParameterIuiv))load("glGetSamplerParameterIuiv");
	glQueryCounter = cast(typeof(glQueryCounter))load("glQueryCounter");
	glGetQueryObjecti64v = cast(typeof(glGetQueryObjecti64v))load("glGetQueryObjecti64v");
	glGetQueryObjectui64v = cast(typeof(glGetQueryObjectui64v))load("glGetQueryObjectui64v");
	glVertexAttribDivisor = cast(typeof(glVertexAttribDivisor))load("glVertexAttribDivisor");
	glVertexAttribP1ui = cast(typeof(glVertexAttribP1ui))load("glVertexAttribP1ui");
	glVertexAttribP1uiv = cast(typeof(glVertexAttribP1uiv))load("glVertexAttribP1uiv");
	glVertexAttribP2ui = cast(typeof(glVertexAttribP2ui))load("glVertexAttribP2ui");
	glVertexAttribP2uiv = cast(typeof(glVertexAttribP2uiv))load("glVertexAttribP2uiv");
	glVertexAttribP3ui = cast(typeof(glVertexAttribP3ui))load("glVertexAttribP3ui");
	glVertexAttribP3uiv = cast(typeof(glVertexAttribP3uiv))load("glVertexAttribP3uiv");
	glVertexAttribP4ui = cast(typeof(glVertexAttribP4ui))load("glVertexAttribP4ui");
	glVertexAttribP4uiv = cast(typeof(glVertexAttribP4uiv))load("glVertexAttribP4uiv");
	glVertexP2ui = cast(typeof(glVertexP2ui))load("glVertexP2ui");
	glVertexP2uiv = cast(typeof(glVertexP2uiv))load("glVertexP2uiv");
	glVertexP3ui = cast(typeof(glVertexP3ui))load("glVertexP3ui");
	glVertexP3uiv = cast(typeof(glVertexP3uiv))load("glVertexP3uiv");
	glVertexP4ui = cast(typeof(glVertexP4ui))load("glVertexP4ui");
	glVertexP4uiv = cast(typeof(glVertexP4uiv))load("glVertexP4uiv");
	glTexCoordP1ui = cast(typeof(glTexCoordP1ui))load("glTexCoordP1ui");
	glTexCoordP1uiv = cast(typeof(glTexCoordP1uiv))load("glTexCoordP1uiv");
	glTexCoordP2ui = cast(typeof(glTexCoordP2ui))load("glTexCoordP2ui");
	glTexCoordP2uiv = cast(typeof(glTexCoordP2uiv))load("glTexCoordP2uiv");
	glTexCoordP3ui = cast(typeof(glTexCoordP3ui))load("glTexCoordP3ui");
	glTexCoordP3uiv = cast(typeof(glTexCoordP3uiv))load("glTexCoordP3uiv");
	glTexCoordP4ui = cast(typeof(glTexCoordP4ui))load("glTexCoordP4ui");
	glTexCoordP4uiv = cast(typeof(glTexCoordP4uiv))load("glTexCoordP4uiv");
	glMultiTexCoordP1ui = cast(typeof(glMultiTexCoordP1ui))load("glMultiTexCoordP1ui");
	glMultiTexCoordP1uiv = cast(typeof(glMultiTexCoordP1uiv))load("glMultiTexCoordP1uiv");
	glMultiTexCoordP2ui = cast(typeof(glMultiTexCoordP2ui))load("glMultiTexCoordP2ui");
	glMultiTexCoordP2uiv = cast(typeof(glMultiTexCoordP2uiv))load("glMultiTexCoordP2uiv");
	glMultiTexCoordP3ui = cast(typeof(glMultiTexCoordP3ui))load("glMultiTexCoordP3ui");
	glMultiTexCoordP3uiv = cast(typeof(glMultiTexCoordP3uiv))load("glMultiTexCoordP3uiv");
	glMultiTexCoordP4ui = cast(typeof(glMultiTexCoordP4ui))load("glMultiTexCoordP4ui");
	glMultiTexCoordP4uiv = cast(typeof(glMultiTexCoordP4uiv))load("glMultiTexCoordP4uiv");
	glNormalP3ui = cast(typeof(glNormalP3ui))load("glNormalP3ui");
	glNormalP3uiv = cast(typeof(glNormalP3uiv))load("glNormalP3uiv");
	glColorP3ui = cast(typeof(glColorP3ui))load("glColorP3ui");
	glColorP3uiv = cast(typeof(glColorP3uiv))load("glColorP3uiv");
	glColorP4ui = cast(typeof(glColorP4ui))load("glColorP4ui");
	glColorP4uiv = cast(typeof(glColorP4uiv))load("glColorP4uiv");
	glSecondaryColorP3ui = cast(typeof(glSecondaryColorP3ui))load("glSecondaryColorP3ui");
	glSecondaryColorP3uiv = cast(typeof(glSecondaryColorP3uiv))load("glSecondaryColorP3uiv");
	return;
}


} /* private */

