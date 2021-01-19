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
import glsu;

void main()
{
    GLFW.activate(3, 3);
    scope (exit)
        GLFW.deactivate();

    debug
    {
        GLFWwindow* window = GLFW.createWindow(1600, 900, "LearnOpenGL");
    }
    else
    {
        GLFWwindow* window = GLFW.createFullScreenWindow("LearnOpenGL");
    }
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

    lighting(window);
}

void basic(GLFWwindow* window)
{
    static bool firstMouse = true;
    static float mouseLastX;
    static float mouseLastY;
    static float FoV = 45.0f;

    static Camera camera;
    camera = Camera(vec3f(0.0f, 0.0f, 3.0f));

    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    GLFWframebuffersizefun framebufferSizeCallback = (GLFWwindow* window, int newWidth,
            int newHeight) {
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

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    scope(exit) VAO.destroy();

    auto texture1 = Texture.create("resources\\container.jpg");
    scope(exit) texture1.destroy();

    auto texture2 = Texture.create("resources\\awesomeface.png");
    scope(exit) texture2.destroy();

    auto shaderProgram = ShaderProgram.create!("basic/shader.vert", "basic/shader.frag");
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
        int width, height;
        glfwGetFramebufferSize(window, &width, &height);
        auto projection = mat4f.perspective(radians(FoV), to!float(width) / height, 0.1f, 100.0f);

        shaderProgram.setTextures(tuple(texture1, "texture1"), tuple(texture2, "texture2"));
        shaderProgram.setUniform("view", view);
        shaderProgram.setUniform("projection", projection);

        foreach (i, pos; cubePositions)
        {
            auto model = mat4f.translation(pos);
            model *= mat4f.rotation(currentFrameTime * radians(20.0f * i), vec3f(1.0f, 0.3f, 0.5f));
            shaderProgram.setUniform("model", model);
            shaderProgram.bind();
            VAO.draw(RenderMode.triangles, 0, cast(int) vertices.length);
        }

        glfwSwapBuffers(window);
        glfwPollEvents();
    }
}

void lighting(GLFWwindow* window)
{
    static bool firstMouse = true;
    static float mouseLastX;
    static float mouseLastY;
    static Camera camera;
    camera = Camera(vec3f(1.25f, 0.0f, 3.0f), -PI_2 - radians(22.5f));

    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    GLFWframebuffersizefun framebufferSizeCallback = (GLFWwindow* window, int newWidth,
            int newHeight) {
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

    void processInput(GLFWwindow* window, float deltaTime)
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
        if(glfwGetKey(window, GLFW_KEY_V) == GLFW_PRESS)
        {
            camera.moveWorldUp(cameraSpeed);
        }
        if(glfwGetKey(window, GLFW_KEY_C) == GLFW_PRESS)
        {
            camera.moveWorldUp(-cameraSpeed);
        }
    }

    struct Vertex
    {
        @VertexAttrib(0)
        vec3f pos;

        @VertexAttrib(1)
        vec3f normal;

        @VertexAttrib(2)
        vec2f texCoords;
    }

    struct Material
    {
        Sampler2Df diffuse;
        Sampler2Df specular;
        float shininess;
    }

    struct DirectionalLight
    {
        vec3f direction;
        vec3f ambient;
        vec3f diffuse;
        vec3f specular;
    }

    struct Attenuation
    {
        float constant;
        float linear;
        float quadratic;
    }

    struct PointLight
    {
        vec3f position;
        vec3f ambient;
        vec3f diffuse;
        vec3f specular;
        Attenuation attenuation;
    }

    struct SpotLight
    {
        vec3f position;
        vec3f direction;
        float cosInnerCutOff;
        float cosOuterCutOff;
        vec3f ambient;
        vec3f diffuse;
        vec3f specular;
        Attenuation attenuation;
    }

    auto vertices = zip(cube!float[], cubeNormals!float[], octagonTextureCoordinates!float[])
        .map!(t => Vertex(t[0], t[1], t[2]))
        .staticArray!36;

    auto VAO = VertexArrayObject(vertices, DataUsage.staticDraw);
    scope(exit) VAO.destroy();

    // auto lightSourceSP = ShaderProgram.create!("lighting/lightSource.vert", "lighting/lightSource.frag");
    // scope(exit) lightSourceSP.destroy();
    auto lightingSP = ShaderProgram.create!("lighting/lighting.vert", "lighting/lighting.frag");
    scope(exit) lightingSP.destroy();

    auto diffuseMap = Texture.create("resources\\container2.png");
    scope(exit) diffuseMap.destroy();
    auto specularMap = Texture.create("resources\\container2_specular.png");
    scope(exit) specularMap.destroy();
    auto material = Material(Sampler2Df(0), Sampler2Df(1), 32.0f);
    lightingSP.setUniform("material", material);

    glEnable(GL_DEPTH_TEST);

    void frameFunc(GLFWwindow* window, double deltaTime) nothrow
    {
        processInput(window, deltaTime);

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        auto view = camera.getView();
        int width, height;
        glfwGetFramebufferSize(window, &width, &height);
        auto projection = mat4f.perspective(radians(45.0f), to!float(width) / height, 0.1f, 100.0f);

        // auto lightColor = vec3f(1.0f);
        // auto lightDir = vec3f(0.0f, -1.0f, 0.0f);
        // // Note 0.0f as w-coordinate, it is because this vec represents direction.
        // auto viewLightDir = (view * vec4f(lightDir, 0.0f)).xyz;
        // auto directionalLight = DirectionalLight(viewLightDir,
        //                                          0.1f * lightColor,
        //                                          lightColor,
        //                                          vec3f(1.0f, 1.0f, 1.0f));

        // auto lightColor = vec3f(1.0f);
        // auto lightPos = vec3f(1.2f + 10 * abs(sin(0.5 * glfwGetTime())), 0.0f, 0.0f);
        // auto viewLightPos = (view * vec4f(lightPos, 1.0f)).xyz;
        // auto pointLight = PointLight(viewLightPos,
        //                              0.1f * lightColor,
        //                              lightColor,
        //                              vec3f(1.0f, 1.0f, 1.0f),
        //                              Attenuation(1.0f, 0.09f, 0.032f));

        auto lightColor = vec3f(1.0f);
        auto lightPos = camera.position;
        auto viewLightPos = (view * vec4f(lightPos, 1.0f)).xyz;
        auto lightDir = camera.front;
        // Note 0.0f as w-coordinate, it is because this vec represents direction.
        auto viewLightDir = (view * vec4f(lightDir, 0.0f)).xyz;
        auto spotLight = SpotLight(viewLightPos,
                                   viewLightDir,
                                   cos(15.0f.radians),
                                   cos(20.0f.radians),
                                   0.1f * lightColor,
                                   lightColor,
                                   vec3f(1.0f, 1.0f, 1.0f),
                                   Attenuation(1.0f, 0.09f, 0.032f));

        // point light source rendering
        // {
        //     auto model = mat4f.translation(lightPos);
        //     model.scale(vec3f(0.2f));

        //     lightSourceSP.setUniform("model", model);
        //     lightSourceSP.setUniform("view", view);
        //     lightSourceSP.setUniform("projection", projection);
        //     lightSourceSP.setUniform("lightColor", lightColor);

        //     lightSourceSP.bind();
        //     VAO.draw(RenderMode.triangles, 0, cast(int) vertices.length);
        // }

        {
            auto model = mat4f.identity;

            lightingSP.setUniform("model", model);
            lightingSP.setUniform("view", view);
            lightingSP.setUniform("projection", projection);
            lightingSP.setUniform("spotLight", spotLight);

            diffuseMap.setActive(material.diffuse);
            specularMap.setActive(material.specular);
            lightingSP.bind();
            VAO.draw(RenderMode.triangles, 0, cast(int) vertices.length);
        }
    }

    GLFW.mainLoop(window, &frameFunc);
}
