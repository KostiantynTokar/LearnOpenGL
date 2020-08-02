import std.stdio;
import std.string;
import std.math;
import std.range;
import std.algorithm;
import std.typecons;
import bindbc.glfw;
import glad.gl.all;
import glad.gl.loader;
import glsu;
import gfm.math;
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
        vec2f pos;

        @VertexAttrib(1)
        vec3f color;

        @VertexAttrib(2)
        vec2f texCoord;
    }

    //dfmt off
    Vertex[] vertices = [
        Vertex( vec2f( 0.5f,  0.5f), vec3f( 1.0f,  0.0f, 0.0f), vec2f(1.0f, 1.0f) ),
        Vertex( vec2f( 0.5f, -0.5f), vec3f( 0.0f,  1.0f, 0.0f), vec2f(1.0f, 0.0f) ),
        Vertex( vec2f(-0.5f, -0.5f), vec3f( 0.0f,  0.0f, 1.0f), vec2f(0.0f, 0.0f) ),
        Vertex( vec2f(-0.5f,  0.5f), vec3f( 1.0f,  1.0f, 0.0f), vec2f(0.0f, 1.0f) ),
    ];
    uint[] indices = [  
        0, 1, 3, // first triangle
        1, 2, 3  // second triangle
    ];
    //dfmt on

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    auto EBO = ElementBufferArray(indices, DataUsage.staticDraw);
    auto VAOInd = VAO.bindElementBufferArray(EBO);

    auto texture1 = Texture.create("resources\\container.jpg").checkError!Texture();
    texture1.setWrapMode(Texture.Coord.s, Texture.Wrap.clamptoBorder);
    texture1.setWrapMode(Texture.Coord.t, Texture.Wrap.clamptoBorder);
    texture1.setMinFilter(Texture.Filter.linearMipmapLinear);
    texture1.setMagFilter(Texture.Filter.linear);

    auto texture2 = Texture.create("resources\\awesomeface.png").checkError!Texture();
    texture2.setWrapMode(Texture.Coord.s, Texture.Wrap.repeat);
    texture2.setWrapMode(Texture.Coord.t, Texture.Wrap.repeat);
    texture2.setMinFilter(Texture.Filter.linearMipmapLinear);
    texture2.setMagFilter(Texture.Filter.linear);

    auto shaderProgram = Shader.create!("shader.vert", "shader.frag").checkError!Shader();

    shaderProgram.use();
    shaderProgram.setTextures(tuple(texture1, "texture1"), tuple(texture2, "texture2"));

    float mixParam = 0.5f;

    void processInput(GLFWwindow* window)
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, true);
        }
        if (glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS)
        {
           mixParam -= 0.05; 
        }
        if (glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS)
        {
           mixParam += 0.05; 
        }
    }

    while (!glfwWindowShouldClose(window))
    {
        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        shaderProgram.use();
        shaderProgram.setUniform("mixParam", mixParam);
        VAOInd.drawElements(RenderMode.triangles, cast(int) indices.length);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

}


