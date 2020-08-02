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

int width = 800;
int height = 600;

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

    GLFWframebuffersizefun framebufferSizeCallback = (GLFWwindow* window, int newWidth,
            int newHeight) {
        width = newWidth;
        height = newHeight;
        glViewport(0, 0, newWidth, newHeight);
    };
    glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    struct Vertex
    {
        @VertexAttrib(0)
        vec3f pos;

        @VertexAttrib(1)
        vec2f texCoord;
    }

    //dfmt off
    // Vertex[] vertices = [
    //     Vertex( vec2f( 0.5f,  0.5f), vec3f( 1.0f,  0.0f, 0.0f), vec2f(1.0f, 1.0f) ),
    //     Vertex( vec2f( 0.5f, -0.5f), vec3f( 0.0f,  1.0f, 0.0f), vec2f(1.0f, 0.0f) ),
    //     Vertex( vec2f(-0.5f, -0.5f), vec3f( 0.0f,  0.0f, 1.0f), vec2f(0.0f, 0.0f) ),
    //     Vertex( vec2f(-0.5f,  0.5f), vec3f( 1.0f,  1.0f, 0.0f), vec2f(0.0f, 1.0f) ),
    // ];
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

    auto shaderProgram = Shader.create!("shader.vert", "shader.frag")
        .checkError!Shader();

    shaderProgram.use();
    shaderProgram.setTextures(tuple(texture1, "texture1"), tuple(texture2, "texture2"));

    float FoV = radians(45.0f);
    float aspectRatioFactor = 1.0f;

    void processInput(GLFWwindow* window)
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        {
            glfwSetWindowShouldClose(window, true);
        }
        if (glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS)
        {
            aspectRatioFactor = max(0.05, aspectRatioFactor - 0.05f);
        }
        if (glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS)
        {
            aspectRatioFactor += 0.05f;
        }
        if(glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS)
        {
            FoV += radians(1.0f);
        }
        if(glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS)
        {
            FoV = max(radians(10.0f), FoV - radians(1.0f));
        }
    }

    glEnable(GL_DEPTH_TEST);

    while (!glfwWindowShouldClose(window))
    {
        processInput(window);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        shaderProgram.use();

        auto view = mat4f.translation(vec3f(0.0f, 0.0f, -3.0f));
        auto projection = mat4f.perspective(FoV, (aspectRatioFactor * width) / height, 0.1f, 100.0f);

        shaderProgram.setUniform("view", view);
        shaderProgram.setUniform("projection", projection);

        foreach(i, pos; cubePositions)
        {
            auto time = glfwGetTime();
            auto model = mat4f.translation(pos);
            model *= mat4f.rotation(time * radians(20.0f * i), vec3f(1.0f, 0.3f, 0.5f));
            shaderProgram.setUniform("model", model);
            VAO.draw(RenderMode.triangles, 0, cast(int) vertices.length);
        }

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

}
