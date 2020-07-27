module glsu;

@nogc pure nothrow:

/** 
 * Import as expression
 * Params:
 *   moduleName = name of a module to import from
 */
template from(string moduleName)
{
    mixin("import from = " ~ moduleName ~ ";");
}

struct GLFW
{
    @disable this();

static:
    bool isActive()
    {
        return active;
    }

    bool activate(uint major, uint minor)
    {
        if (isActive)
        {
            return GLFW.major == major && GLFW.minor;
        }

        GLFW.major = major;
        GLFW.minor = minor;
        active = true;
        initLib();
        return true;
    }

    bool deactivate()
    {
        if (!isActive)
        {
            return false;
        }
        import bindbc.glfw : glfwTerminate;

        glfwTerminate();
        return true;
    }

    from!"bindbc.glfw".GLFWwindow* createWindow(int width, int height, string label)
    {
        import bindbc.glfw : glfwCreateWindow;
        import std.string : toStringz;

        return glfwCreateWindow(width, height, label.toStringz, null, null);
    }

private:
    bool active = false;
    uint major;
    uint minor;

    void initLib()
    {
        import bindbc.glfw : glfwInit, glfwWindowHint;
        import bindbc.glfw.types : GLFW_CONTEXT_VERSION_MAJOR,
            GLFW_CONTEXT_VERSION_MINOR, GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE;

        glfwInit();
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, major);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, minor);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    }
}
