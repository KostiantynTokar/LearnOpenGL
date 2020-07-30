import std.stdio;
import std.string;
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
        vec3 pos;
    }

    //dfmt off
    Vertex[] newVertices = [
        Vertex(vec3( 0.5f,  0.5f, 0.0f)),
        Vertex(vec3( 0.5f, -0.5f, 0.0f)),
        Vertex(vec3(-0.5f, -0.5f, 0.0f)),
        Vertex(vec3(-0.5f,  0.5f, 0.0f))
    ];
    uint[] indices = [
        0, 1, 3,
        1, 2, 3
    ];
    //dfmt on

    auto VAO = VertexArrayObject(newVertices, DataUsage.staticDraw);
    auto EBO = ElementBufferArray(indices, DataUsage.staticDraw);
    VAO.bindElementBufferArray(EBO);

    int success;
    int infoLogLength;

    const(char)* vertexShaderSource = import("shader.vert").toStringz;
    uint vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, null);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (!success)
    {
        char[] infoLog = new char[infoLogLength];
        glGetShaderInfoLog(vertexShader, infoLogLength, null, infoLog.ptr);
        writeln("ERROR::SHADER::VERTEX::COMPILATION_FAILED");
        writeln(infoLog);
        return;
    }

    const(char)* fragmentShaderSource = import("shader.frag").toStringz;
    uint fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, null);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    glGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (!success)
    {
        char[] infoLog = new char[infoLogLength];
        glGetShaderInfoLog(fragmentShader, infoLogLength, null, infoLog.ptr);
        writeln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED");
        writeln(infoLog);
        return;
    }

    uint shaderProgram;
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (!success)
    {
        char[] infoLog = new char[infoLogLength];
        glGetProgramInfoLog(shaderProgram, infoLogLength, null, infoLog.ptr);
        writeln("ERROR::SHADER::PROGRAM::LINK_FAILED");
        writeln(infoLog);
        return;
    }
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    while (!glfwWindowShouldClose(window))
    {
        processInput(window);

        glUseProgram(shaderProgram);
        auto bindedVAO = binder(&VAO);
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        // glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawElements(GL_TRIANGLES, cast(int) indices.length, GL_UNSIGNED_INT, null);

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
