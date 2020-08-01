import std.stdio;
import std.string;
import std.math;
import std.range;
import std.algorithm;
import bindbc.glfw;
import glad.gl.all;
import glad.gl.loader;
import glsu;
import dlib;
import imagefmt;

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

        @VertexAttrib(2)
        vec2 texCoord;
    }

    //dfmt off
    Vertex[] vertices = [
        Vertex( vec2( 0.5f,  0.5f), vec3( 1.0f,  0.0f, 0.0f), vec2(1.0f, 1.0f) ),
        Vertex( vec2( 0.5f, -0.5f), vec3( 0.0f,  1.0f, 0.0f), vec2(1.0f, 0.0f) ),
        Vertex( vec2(-0.5f, -0.5f), vec3( 0.0f,  0.0f, 1.0f), vec2(0.0f, 0.0f) ),
        Vertex( vec2(-0.5f,  0.5f), vec3( 1.0f,  1.0f, 0.0f), vec2(0.0f, 1.0f) ),
    ];
    uint[] indices = [  
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    ];
    //dfmt on

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    auto EBO = ElementBufferArray(indices, DataUsage.staticDraw);
    auto VAOInd = VAO.bindElementBufferArray(EBO);

    set_yaxis_up_on_load(true);
    auto image = read_image("resources\\container.jpg");
    uint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, cast(int) GL_RGB, image.w, image.h, 0,
            GL_RGB, GL_UNSIGNED_BYTE, image.buf8.ptr);
    glGenerateMipmap(GL_TEXTURE_2D);

    auto image2 = read_image("resources\\awesomeface.png");
    uint texture2;
    glGenTextures(1, &texture2);
    glBindTexture(GL_TEXTURE_2D, texture2);
    glTexImage2D(GL_TEXTURE_2D, 0, cast(int) GL_RGB, image2.w, image2.h, 0,
            GL_RGBA, GL_UNSIGNED_BYTE, image2.buf8.ptr);
    glGenerateMipmap(GL_TEXTURE_2D);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

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

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture2);

        shaderProgram.use();
        shaderProgram.setUniform("texture1", 0);
        shaderProgram.setUniform("texture2", 1);
        VAOInd.drawElements(RenderMode.triangles, cast(int) indices.length);

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
