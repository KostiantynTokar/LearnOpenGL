import std.stdio;
import std.string;
import std.conv;
import std.math;
import std.range;
import std.algorithm;
import std.typecons;
import bindbc.glfw;
import glad.gl.enums;
import glad.gl.loader;
import gfm.math;
import imagefmt;
import glsu;

int width = 800;
int height = 600;

bool firstMouse = true;
float mouseLastX;
float mouseLastY;
float FoV = 45.0f;

Camera camera;

static this()
{
    camera = Camera(vec3f(0.0f, 0.0f, 3.0f));
}

void main()
{
    GLFW.activate(3, 3);
    scope (exit)
        GLFW.deactivate();

    GLFWwindow* window = GLFW.createWindow(800, 600, "LearnOpenGL");
    if (window == null)
    {
        stderr.writeln("Failed to create GLFW window");
        return;
    }
    glfwMakeContextCurrent(window);

    if (!gladLoadGL())
    {
        stderr.writeln("Failed to initialize GLAD");
        return;
    }

    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    GLFWframebuffersizefun framebufferSizeCallback = (GLFWwindow* window, int newWidth,
            int newHeight) {
        width = newWidth;
        height = newHeight;
        glViewport(0, 0, newWidth, newHeight);
    };
    glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    GLFWcursorposfun cursorPosCallback = (GLFWwindow* window, double x, double y) {
        if (firstMouse)
        {
            mouseLastX = x;
            mouseLastY = y;
            firstMouse = false;
        }

        float xoffset = x - mouseLastX;
        float yoffset = mouseLastY - y; // reversed since y-coordinates go from bottom to top
        mouseLastX = x;
        mouseLastY = y;

        float sensitivity = 0.25f;
        xoffset *= sensitivity;
        yoffset *= sensitivity;

        camera.rotate(radians(xoffset), radians(yoffset));
    };
    glfwSetCursorPosCallback(window, cursorPosCallback);

    GLFWscrollfun scrollCallback = (GLFWwindow* window, double xoffset, double yoffset) {
        float sensitivity = 2f;
        FoV = std.algorithm.comparison.clamp(FoV - yoffset * sensitivity, 1.0f, 90.0f);
    };
    glfwSetScrollCallback(window, scrollCallback);

    struct Vertex
    {
        @VertexAttrib(0)
        vec3f pos;

        @VertexAttrib(1)
        vec2f texCoord;
    }

    //dfmt off
    Vertex[] vertices = [
        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f( 0.5f, -0.5f, -0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f( 0.5f,  0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f( 0.5f,  0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f(-0.5f,  0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 0.0f) ),

        Vertex( vec3f(-0.5f, -0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f( 0.5f, -0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f(-0.5f,  0.5f,  0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f(-0.5f, -0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),

        Vertex( vec3f(-0.5f,  0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f(-0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f(-0.5f, -0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f(-0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),

        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f( 0.5f,  0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f( 0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f( 0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f( 0.5f, -0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),

        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f( 0.5f, -0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f( 0.5f, -0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f( 0.5f, -0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f(-0.5f, -0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f(-0.5f, -0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),

        Vertex( vec3f(-0.5f,  0.5f, -0.5f),  vec2f(0.0f, 1.0f) ),
        Vertex( vec3f( 0.5f,  0.5f, -0.5f),  vec2f(1.0f, 1.0f) ),
        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f( 0.5f,  0.5f,  0.5f),  vec2f(1.0f, 0.0f) ),
        Vertex( vec3f(-0.5f,  0.5f,  0.5f),  vec2f(0.0f, 0.0f) ),
        Vertex( vec3f(-0.5f,  0.5f, -0.5f),  vec2f(0.0f, 1.0f) )
    ];
    vec3f[] cubePositions = [
        vec3f( 0.0f,  0.0f,  0.0f), 
        vec3f( 2.0f,  5.0f, -15.0f), 
        vec3f(-1.5f, -2.2f, -2.5f),  
        vec3f(-3.8f, -2.0f, -12.3f),  
        vec3f( 2.4f, -0.4f, -3.5f),  
        vec3f(-1.7f,  3.0f, -7.5f),  
        vec3f( 1.3f, -2.0f, -2.5f),  
        vec3f( 1.5f,  2.0f, -2.5f), 
        vec3f( 1.5f,  0.2f, -1.5f), 
        vec3f(-1.3f,  1.0f, -1.5f)
    ];
    //dfmt on

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    scope(exit) VAO.destroy();

    // auto VBO = VertexBufferObject(vertices, DataUsage.staticDraw);
    // scope(exit) VBO.destroy();

    // VertexBufferLayout layout;
    // // layout.push!float(3);
    // // layout.push!float(2);
    // layout.pushUsingPattern!Vertex();

    // auto VAO = VertexArrayObject(VBO, layout);
    // scope(exit) VAO.destroy();

    auto texture1 = Texture.create("resources\\container.jpg").assertNoError!Texture();
    texture1.setWrapMode(Texture.Coord.s, Texture.Wrap.clamptoBorder);
    texture1.setWrapMode(Texture.Coord.t, Texture.Wrap.clamptoBorder);
    texture1.setMinFilter(Texture.Filter.linearMipmapLinear);
    texture1.setMagFilter(Texture.Filter.linear);
    scope(exit) texture1.destroy();

    auto texture2 = Texture.create("resources\\awesomeface.png").assertNoError!Texture();
    texture2.setWrapMode(Texture.Coord.s, Texture.Wrap.repeat);
    texture2.setWrapMode(Texture.Coord.t, Texture.Wrap.repeat);
    texture2.setMinFilter(Texture.Filter.linearMipmapLinear);
    texture2.setMagFilter(Texture.Filter.linear);
    scope(exit) texture2.destroy();

    auto shaderProgram = ShaderProgram.create!("shader.vert", "shader.frag")
        .assertNoError!ShaderProgram();
    scope(exit) shaderProgram.destroy();

    float deltaTime = 0.0f;
    float lastFrameTime = 0.0f;

    void processInput(GLFWwindow* window)
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, true);
        }

        immutable float cameraSpeed = 2.5f * deltaTime;
        if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        {
            // camera.moveFront(cameraSpeed);
            auto front = camera.front;
            camera.move(cameraSpeed * vec3f(front.x, 0.0f, front.z).normalized);
        }
        if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        {
            // camera.moveFront(-cameraSpeed);
            auto front = camera.front;
            camera.move(-cameraSpeed * vec3f(front.x, 0.0f, front.z).normalized);
        }
        if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        {
            camera.moveRight(-cameraSpeed);
        }
        if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        {
            camera.moveRight(cameraSpeed);
        }
    }

    glEnable(GL_DEPTH_TEST);

    while (!glfwWindowShouldClose(window))
    {
        float currentFrameTime = glfwGetTime();
        deltaTime = currentFrameTime - lastFrameTime;
        lastFrameTime = currentFrameTime;

        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        auto view = camera.getView();
        auto projection = mat4f.perspective(radians(FoV), to!float(width) / height, 0.1f, 100.0f);

        shaderProgram.use();
        shaderProgram.setTextures(tuple(texture1, "texture1"), tuple(texture2, "texture2"));
        shaderProgram.setUniform("view", view);
        shaderProgram.setUniform("projection", projection);

        foreach (i, pos; cubePositions)
        {
            auto model = mat4f.translation(pos);
            model *= mat4f.rotation(currentFrameTime * radians(20.0f * i), vec3f(1.0f, 0.3f, 0.5f));
            shaderProgram.setUniform("model", model);
            VAO.draw(RenderMode.triangles, 0, cast(int) vertices.length);
        }

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

}
