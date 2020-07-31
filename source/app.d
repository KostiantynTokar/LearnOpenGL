import std.stdio;
import std.string;
import std.math;
import bindbc.glfw;
import glad.gl.all;
import glad.gl.loader;
import glsu;
import dlib;

void main()
{
    GLFW.activate(3, 3);
    scope (exit)
        GLFW.deactivate();

    GLFWwindow* window = GLFW.createWindow(800, 600, "LearnOpenGL");
    if (window == null)
    {
        writeln("Failed to create GLFW window");
        return;
    }
    glfwMakeContextCurrent(window);

    if (!gladLoadGL())
    {
        writeln("Failed to initialize GLAD");
        return;
    }

    GLFWframebuffersizefun framebufferSizeCallback = (GLFWwindow* window, int width, int height) {
        glViewport(0, 0, width, height);
    };
    glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    struct Vertex
    {
        @VertexAttrib(0)
        vec2 pos;

        @VertexAttrib(1)
        vec3 color;
    }

    //dfmt off
    Vertex[] vertices = [
        Vertex( vec2( 0.5f, -0.5f), vec3( 1.0f,  0.0f, 0.0f) ),
        Vertex( vec2(-0.5f, -0.5f), vec3( 0.0f,  1.0f, 0.0f) ),
        Vertex( vec2( 0.0f,  0.5f), vec3( 0.0f,  0.0f, 1.0f) ),
    ];
    //dfmt on
    
    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);

    auto shaderOrError = Shader.create!("shader.vert", "shader.frag");
    if (string* error = shaderOrError.peek!string)
    {
        writeln(*error);
        return;
    }
    Shader shaderProgram = shaderOrError.get!Shader;

    while (!glfwWindowShouldClose(window))
    {
        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        shaderProgram.use();
        float time = glfwGetTime();
        float horOffset = sin(time) / 2.0f;
        shaderProgram.setUniform("horOffset", horOffset);
        shaderProgram.setUniform("time", time);
        VAO.draw(RenderMode.triangles, 0, 3);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

}

void processInput(GLFWwindow* window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
    {
        glfwSetWindowShouldClose(window, true);
    }
}
