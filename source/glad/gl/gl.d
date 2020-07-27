module glad.gl.gl;


public import glad.gl.types;
public import glad.gl.funcs :
glMultiTexCoordP2uiv, glCopyTexImage1D, glVertexAttribI3ui, glStencilMaskSeparate, glVertexAttribP1uiv, 
glLinkProgram, glHint, glGetUniformiv, glFramebufferRenderbuffer, glGetString, 
glVertexAttribP2uiv, glCompressedTexSubImage3D, glDetachShader, glTexCoordP3uiv, glVertexAttrib1sv, 
glBindSampler, glLineWidth, glColorP3uiv, glGetIntegeri_v, glVertexAttribI2ui, 
glCompileShader, glGetTransformFeedbackVarying, glColorMask, glDeleteTextures, glStencilOpSeparate, 
glCopyBufferSubData, glDeleteQueries, glNormalP3uiv, glVertexAttrib4f, glUniformMatrix3x4fv, 
glGetBufferParameteri64v, glVertexAttribIPointer, glMultiTexCoordP3ui, glBeginConditionalRender, glDrawElementsBaseVertex, 
glVertexP4ui, glEnablei, glSampleCoverage, glSamplerParameteri, glSamplerParameterf, 
glUniform1f, glGetVertexAttribfv, glGetCompressedTexImage, glVertexAttribP4ui, glCreateShader, 
glIsBuffer, glGetMultisamplefv, glGenRenderbuffers, glCopyTexSubImage2D, glCompressedTexImage2D, 
glVertexAttrib1f, glVertexP3ui, glBlendFuncSeparate, glLogicOp, glDrawBuffers, 
glVertexAttrib1s, glUniform4ui, glSampleMaski, glVertexP2ui, glBindFramebuffer, 
glCullFace, glUniformMatrix3x2fv, glPointSize, glVertexAttribI2uiv, glVertexAttrib2dv, 
glDeleteProgram, glVertexAttrib4Nuiv, glRenderbufferStorage, glWaitSync, glAttachShader, 
glUniformMatrix4x3fv, glUniform3i, glClearBufferfv, glQueryCounter, glProvokingVertex, 
glUniform3f, glVertexAttrib4ubv, glGetBufferParameteriv, glTexCoordP2ui, glDrawElements, 
glColorMaski, glClearBufferfi, glGenVertexArrays, glVertexAttribI4sv, glMultiTexCoordP2ui, 
glGetQueryObjectiv, glGetSamplerParameterIiv, glGetFragDataIndex, glSecondaryColorP3uiv, glTexParameterIuiv, 
glDrawArraysInstanced, glMultiDrawArrays, glGenerateMipmap, glGetVertexAttribdv, glSamplerParameteriv, 
glVertexAttrib3f, glVertexAttrib4uiv, glVertexAttrib3d, glBlendColor, glSamplerParameterIuiv, 
glUnmapBuffer, glPointParameterf, glMultiTexCoordP4ui, glVertexAttribI4iv, glEndQuery, 
glBindRenderbuffer, glDeleteFramebuffers, glDrawArrays, glUniform1ui, glIsProgram, 
glVertexAttrib4bv, glTexCoordP1ui, glVertexAttribI2i, glClear, glVertexAttrib4fv, 
glGetActiveUniformName, glUniform4i, glActiveTexture, glEnableVertexAttribArray, glDrawRangeElements, 
glBindTexture, glIsEnabled, glStencilOp, glReadPixels, glVertexAttribI3iv, 
glUniform4f, glFramebufferTexture2D, glGetFramebufferAttachmentParameteriv, glVertexAttrib4Nub, glUniformMatrix3fv, 
glGetFragDataLocation, glTexImage1D, glDrawElementsInstancedBaseVertex, glTexParameteriv, glGetTexImage, 
glGetTexLevelParameterfv, glUniform1iv, glGetQueryObjecti64v, glGenFramebuffers, glStencilFunc, 
glGetAttachedShaders, glUniformBlockBinding, glIsRenderbuffer, glDeleteVertexArrays, glMapBufferRange, 
glVertexAttrib4Nubv, glIsVertexArray, glDisableVertexAttribArray, glReadBuffer, glGetQueryiv, 
glGetSamplerParameterfv, glGetShaderInfoLog, glGetUniformIndices, glIsShader, glVertexAttribI4ubv, 
glGetInteger64v, glVertexAttribI4i, glPointParameteriv, glDisable, glGetBufferSubData, 
glBindAttribLocation, glEnable, glGetActiveUniformsiv, glBindBufferRange, glTexParameterfv, 
glBlendEquationSeparate, glVertexAttribI1ui, glGenBuffers, glGetAttribLocation, glVertexAttrib4dv, 
glTexCoordP1uiv, glVertexAttrib2fv, glBlendFunc, glCreateProgram, glTexImage3D, 
glMultiTexCoordP3uiv, glVertexAttribP3ui, glIsFramebuffer, glPrimitiveRestartIndex, glGetUniformfv, 
glGetUniformuiv, glGetVertexAttribIiv, glDrawBuffer, glColorP4ui, glClearBufferuiv, 
glDrawElementsInstanced, glVertexAttrib4d, glGetBooleanv, glVertexP2uiv, glGetTexParameteriv, 
glFlush, glGetRenderbufferParameteriv, glClearColor, glVertexAttribI2iv, glGetUniformBlockIndex, 
glVertexAttrib4Niv, glClearBufferiv, glPointParameteri, glGetVertexAttribPointerv, glColorP4uiv, 
glGetStringi, glFenceSync, glUniform3ui, glColorP3ui, glVertexAttrib3sv, 
glVertexAttrib4s, glVertexAttribI4uiv, glGetTexLevelParameteriv, glUniform2fv, glMultiTexCoordP4uiv, 
glGetSamplerParameterIuiv, glStencilFuncSeparate, glTexCoordP3ui, glGenSamplers, glClampColor, 
glUniform4iv, glClearStencil, glVertexAttrib2sv, glUniformMatrix2x3fv, glGetVertexAttribIuiv, 
glVertexAttrib4Nusv, glGenTextures, glDepthFunc, glCompressedTexSubImage2D, glGetTexParameterIuiv, 
glVertexAttribI4bv, glVertexAttrib4Nbv, glGetTexParameterfv, glMultiTexCoordP1ui, glVertexAttrib3s, 
glIsSync, glGetActiveUniformBlockName, glClientWaitSync, glUniform2i, glUniform2f, 
glShaderSource, glGetProgramiv, glVertexAttribPointer, glFramebufferTextureLayer, glTexParameterIiv, 
glBlendEquation, glGetUniformLocation, glGetSamplerParameteriv, glEndTransformFeedback, glFlushMappedBufferRange, 
glVertexAttrib4usv, glUniform4fv, glBeginTransformFeedback, glVertexAttribI1iv, glIsSampler, 
glVertexAttribP4uiv, glVertexAttribDivisor, glGenQueries, glCompressedTexImage1D, glVertexAttribP1ui, 
glCopyTexSubImage1D, glDrawRangeElementsBaseVertex, glCheckFramebufferStatus, glTexSubImage3D, glGetInteger64i_v, 
glDeleteSamplers, glCopyTexImage2D, glVertexP3uiv, glBlitFramebuffer, glIsEnabledi, 
glUniformMatrix4x2fv, glSecondaryColorP3ui, glBindFragDataLocationIndexed, glVertexAttrib1dv, glUniform2iv, 
glGetQueryObjectuiv, glSamplerParameterIiv, glBufferSubData, glVertexAttrib4iv, glUniform4uiv, 
glFramebufferTexture, glUniform1i, glFramebufferTexture1D, glGetShaderiv, glVertexP4uiv, 
glGetActiveAttrib, glBindFragDataLocation, glVertexAttrib2d, glPolygonOffset, glDisablei, 
glGetDoublev, glTexCoordP4ui, glVertexAttrib1d, glVertexAttribI3uiv, glTexSubImage2D, 
glGetSynciv, glVertexAttrib1fv, glTexCoordP2uiv, glVertexAttribI4ui, glTexImage2DMultisample, 
glBeginQuery, glMultiTexCoordP1uiv, glUniform3fv, glDepthRange, glMapBuffer, 
glUniformMatrix2x4fv, glBindBuffer, glBufferData, glGetTexParameterIiv, glCompressedTexImage3D, 
glDeleteSync, glCopyTexSubImage3D, glGetError, glDeleteRenderbuffers, glGetVertexAttribiv, 
glMultiDrawElements, glVertexAttrib3fv, glGetFloatv, glTexSubImage1D, glUniform3iv, 
glNormalP3ui, glPolygonMode, glVertexAttribI1i, glVertexAttribP3uiv, glGetActiveUniformBlockiv, 
glGetIntegerv, glGetBufferPointerv, glFramebufferTexture3D, glRenderbufferStorageMultisample, glIsQuery, 
glUniformMatrix2fv, glUseProgram, glVertexAttrib4sv, glTexImage2D, glGetProgramInfoLog, 
glStencilMask, glSamplerParameterfv, glBindVertexArray, glIsTexture, glUniform1fv, 
glDeleteBuffers, glMultiDrawElementsBaseVertex, glEndConditionalRender, glScissor, glTexCoordP4uiv, 
glUniform2uiv, glCompressedTexSubImage1D, glFinish, glDeleteShader, glPointParameterfv, 
glVertexAttrib4Nsv, glViewport, glBindBufferBase, glVertexAttribI1uiv, glUniform1uiv, 
glTransformFeedbackVaryings, glVertexAttrib2f, glVertexAttrib3dv, glGetQueryObjectui64v, glUniform2ui, 
glDepthMask, glVertexAttribI3i, glVertexAttrib2s, glTexImage3DMultisample, glUniformMatrix4fv, 
glClearDepth, glGetActiveUniform, glVertexAttribI4usv, glTexParameterf, glTexParameteri, 
glFrontFace, glGetShaderSource, glTexBuffer, glPixelStorei, glValidateProgram, 
glPixelStoref, glUniform3uiv, glVertexAttribP2ui, glGetBooleani_v;

public import glad.gl.enums :
GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER, GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE, GL_UNSIGNED_INT_VEC2, GL_UNSIGNED_INT_VEC3, GL_UNSIGNED_INT_VEC4, 
GL_UNSIGNED_SHORT_5_6_5, GL_VERTEX_ATTRIB_ARRAY_SIZE, GL_DEPTH_ATTACHMENT, GL_DITHER, GL_RGB16UI, 
GL_QUERY_RESULT, GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE, GL_FLOAT_VEC2, GL_FLOAT_VEC3, GL_R16_SNORM, 
GL_FLOAT_VEC4, GL_FLOAT, GL_RGB32UI, GL_TEXTURE_MAX_LOD, GL_BUFFER_MAP_OFFSET, 
GL_TEXTURE17, GL_MIN_PROGRAM_TEXEL_OFFSET, GL_BUFFER_SIZE, GL_RGB16_SNORM, GL_SAMPLER_2D_RECT, 
GL_RGB9_E5, GL_UNIFORM_BUFFER_START, GL_TEXTURE_COMPRESSED, GL_TEXTURE_COMPRESSION_HINT, GL_RGBA32UI, 
GL_UNSIGNED_INT_SAMPLER_2D, GL_TEXTURE_MIN_LOD, GL_TEXTURE8, GL_TEXTURE9, GL_MAX_VARYING_FLOATS, 
GL_TEXTURE4, GL_TEXTURE5, GL_TEXTURE6, GL_TEXTURE7, GL_TEXTURE0, 
GL_LINEAR_MIPMAP_LINEAR, GL_TEXTURE2, GL_TEXTURE3, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_X, 
GL_DOUBLE, GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_BYTE, GL_BOOL_VEC3, GL_BOOL_VEC2, 
GL_TIMEOUT_IGNORED, GL_RENDERBUFFER_SAMPLES, GL_ONE, GL_RG, GL_TEXTURE_2D_MULTISAMPLE_ARRAY, 
GL_COLOR_CLEAR_VALUE, GL_MAX_SAMPLES, GL_DEPTH_WRITEMASK, GL_WAIT_FAILED, GL_UNPACK_IMAGE_HEIGHT, 
GL_GREEN_INTEGER, GL_TEXTURE_DEPTH_SIZE, GL_FLOAT_MAT3x2, GL_TRIANGLE_STRIP, GL_NOOP, 
GL_TRANSFORM_FEEDBACK_BUFFER_BINDING, GL_FLOAT_MAT3x4, GL_CONTEXT_FLAGS, GL_FRONT_LEFT, GL_COLOR_ATTACHMENT28, 
GL_COLOR_ATTACHMENT29, GL_COLOR_ATTACHMENT24, GL_COLOR_ATTACHMENT25, GL_COLOR_ATTACHMENT26, GL_COLOR_ATTACHMENT27, 
GL_COLOR_ATTACHMENT20, GL_COLOR_ATTACHMENT21, GL_COMPRESSED_RGBA, GL_COLOR_ATTACHMENT23, GL_RGBA32I, 
GL_TRANSFORM_FEEDBACK_BUFFER, GL_BLEND_COLOR, GL_QUERY_WAIT, GL_UNSIGNED_SHORT_5_5_5_1, GL_TIMEOUT_EXPIRED, 
GL_QUERY_NO_WAIT, GL_PROVOKING_VERTEX, GL_UNPACK_SWAP_BYTES, GL_STENCIL_FUNC, GL_MAX_TEXTURE_LOD_BIAS, 
GL_ALIASED_LINE_WIDTH_RANGE, GL_STENCIL_INDEX8, GL_POINT_SIZE, GL_INVERT, GL_BACK, 
GL_TEXTURE_COMPARE_FUNC, GL_TRANSFORM_FEEDBACK_BUFFER_MODE, GL_RGB12, GL_INT, GL_RGB10, 
GL_RGB16, GL_CLIP_DISTANCE1, GL_BGRA, GL_POLYGON_OFFSET_FILL, GL_CLIP_DISTANCE2, 
GL_CLIP_DISTANCE5, GL_CLIP_DISTANCE4, GL_CLIP_DISTANCE7, GL_CLIP_DISTANCE6, GL_DOUBLEBUFFER, 
GL_FRONT_AND_BACK, GL_R8, GL_POINT, GL_RGB_INTEGER, GL_SMOOTH_LINE_WIDTH_GRANULARITY, 
GL_STENCIL_CLEAR_VALUE, GL_SRGB, GL_SYNC_FENCE, GL_ONE_MINUS_CONSTANT_COLOR, GL_UNSIGNED_INT_8_8_8_8, 
GL_SHADING_LANGUAGE_VERSION, GL_TEXTURE_BUFFER_DATA_STORE_BINDING, GL_RGB8_SNORM, GL_TEXTURE_ALPHA_SIZE, GL_UPPER_LEFT, 
GL_FLOAT_32_UNSIGNED_INT_24_8_REV, GL_FRAGMENT_SHADER, GL_UNSIGNED_INT_2_10_10_10_REV, GL_UNSIGNED_SHORT_4_4_4_4, GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS, 
GL_FRAGMENT_SHADER_DERIVATIVE_HINT, GL_TEXTURE_DEPTH, GL_NO_ERROR, GL_VIEWPORT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, 
GL_BLEND_SRC_ALPHA, GL_DRAW_BUFFER6, GL_DRAW_BUFFER7, GL_DRAW_BUFFER4, GL_DRAW_BUFFER5, 
GL_DRAW_BUFFER2, GL_DRAW_BUFFER3, GL_AND_REVERSE, GL_DRAW_BUFFER1, GL_RENDERBUFFER, 
GL_COPY, GL_QUERY_RESULT_AVAILABLE, GL_BLEND_SRC, GL_DRAW_BUFFER9, GL_MAX_DRAW_BUFFERS, 
GL_KEEP, GL_VERTEX_ARRAY_BINDING, GL_ONE_MINUS_DST_ALPHA, GL_TEXTURE_CUBE_MAP_SEAMLESS, GL_R32UI, 
GL_RGBA8_SNORM, GL_FILL, GL_INT_SAMPLER_3D, GL_SRC_COLOR, GL_SAMPLER_BINDING, 
GL_AND, GL_DEPTH24_STENCIL8, GL_SAMPLE_BUFFERS, GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE, GL_MAJOR_VERSION, 
GL_STATIC_COPY, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, GL_EXTENSIONS, GL_BGR_INTEGER, GL_PROXY_TEXTURE_RECTANGLE, 
GL_PROXY_TEXTURE_3D, GL_UNIFORM_BUFFER_BINDING, GL_UNIFORM_TYPE, GL_RENDERBUFFER_BLUE_SIZE, GL_TEXTURE_COMPARE_MODE, 
GL_ANY_SAMPLES_PASSED, GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE, GL_DEPTH_BUFFER_BIT, GL_STENCIL_BACK_PASS_DEPTH_FAIL, GL_UNSIGNALED, 
GL_UNIFORM_BUFFER, GL_MAP_WRITE_BIT, GL_SMOOTH_POINT_SIZE_RANGE, GL_SAMPLE_MASK, GL_CCW, 
GL_FRONT_RIGHT, GL_RGB32I, GL_MAP_INVALIDATE_BUFFER_BIT, GL_DEPTH_COMPONENT24, GL_UNSIGNED_INT_5_9_9_9_REV, 
GL_DEPTH_TEST, GL_SYNC_GPU_COMMANDS_COMPLETE, GL_UNSIGNED_INT_SAMPLER_BUFFER, GL_VERTEX_ATTRIB_ARRAY_INTEGER, GL_VERTEX_ATTRIB_ARRAY_POINTER, 
GL_MULTISAMPLE, GL_MAX_GEOMETRY_OUTPUT_VERTICES, GL_MAX_VERTEX_UNIFORM_BLOCKS, GL_ONE_MINUS_SRC1_COLOR, GL_STREAM_READ, 
GL_LINEAR, GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, GL_FUNC_SUBTRACT, GL_R32F, GL_OR_REVERSE, 
GL_MAX_VARYING_COMPONENTS, GL_SAMPLER_BUFFER, GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING, GL_CLAMP_TO_BORDER, GL_UNSIGNED_SHORT_5_6_5_REV, 
GL_COLOR_ATTACHMENT14, GL_COLOR_ATTACHMENT17, GL_DEPTH_RANGE, GL_GREATER, GL_CLAMP_TO_EDGE, 
GL_COLOR_ATTACHMENT13, GL_COLOR_ATTACHMENT12, GL_NEAREST, GL_MAX_GEOMETRY_UNIFORM_COMPONENTS, GL_COMPRESSED_TEXTURE_FORMATS, 
GL_COLOR_ATTACHMENT19, GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER, GL_MAX_TEXTURE_IMAGE_UNITS, GL_RGB32F, GL_FLOAT_MAT2, 
GL_FLOAT_MAT3, GL_FRONT_FACE, GL_DEPTH, GL_REPLACE, GL_VERTEX_ATTRIB_ARRAY_STRIDE, 
GL_MAX_DUAL_SOURCE_DRAW_BUFFERS, GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE, GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT, GL_SAMPLER_2D_RECT_SHADOW, GL_TEXTURE30, 
GL_TEXTURE31, GL_RG8I, GL_UNSIGNED_INT_SAMPLER_1D, GL_RGBA8I, GL_RG8UI, 
GL_DEPTH_CLEAR_VALUE, GL_GEOMETRY_INPUT_TYPE, GL_BACK_LEFT, GL_BUFFER_MAP_POINTER, GL_LINE_SMOOTH, 
GL_RENDERBUFFER_BINDING, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, GL_STENCIL_REF, GL_MAX_3D_TEXTURE_SIZE, GL_COPY_WRITE_BUFFER, 
GL_BLEND, GL_MIRRORED_REPEAT, GL_R16UI, GL_TEXTURE_BINDING_3D, GL_UNSIGNED_SHORT, 
GL_MIN, GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER, GL_COMPRESSED_SRGB_ALPHA, GL_ONE_MINUS_DST_COLOR, GL_ONE_MINUS_SRC_COLOR, 
GL_DELETE_STATUS, GL_TEXTURE, GL_PROXY_TEXTURE_1D_ARRAY, GL_MAX_CLIP_DISTANCES, GL_TIMESTAMP, 
GL_COLOR_BUFFER_BIT, GL_DONT_CARE, GL_ACTIVE_UNIFORMS, GL_VERTEX_PROGRAM_POINT_SIZE, GL_TEXTURE_BINDING_CUBE_MAP, 
GL_SAMPLER_2D, GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE, GL_SRGB_ALPHA, GL_DRAW_BUFFER12, GL_NEAREST_MIPMAP_NEAREST, 
GL_NUM_COMPRESSED_TEXTURE_FORMATS, GL_PACK_SKIP_ROWS, GL_TEXTURE_MAG_FILTER, GL_STENCIL_INDEX1, GL_TEXTURE1, 
GL_BLEND_EQUATION_RGB, GL_CONTEXT_COMPATIBILITY_PROFILE_BIT, GL_LINK_STATUS, GL_TEXTURE_MAX_LEVEL, GL_R32I, 
GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY, GL_SAMPLER_CUBE, GL_BOOL_VEC4, GL_ONE_MINUS_CONSTANT_ALPHA, GL_NEAREST_MIPMAP_LINEAR, 
GL_INT_2_10_10_10_REV, GL_SAMPLER_CUBE_SHADOW, GL_LEFT, GL_AND_INVERTED, GL_MAX_GEOMETRY_OUTPUT_COMPONENTS, 
GL_FRAMEBUFFER_SRGB, GL_SAMPLER_1D, GL_LINE, GL_POLYGON_OFFSET_POINT, GL_INT_SAMPLER_1D_ARRAY, 
GL_MAX_TEXTURE_SIZE, GL_SAMPLER_2D_MULTISAMPLE, GL_SAMPLES_PASSED, GL_ARRAY_BUFFER, GL_STENCIL_INDEX, 
GL_DEPTH_COMPONENT16, GL_RENDERBUFFER_RED_SIZE, GL_MAX_SAMPLE_MASK_WORDS, GL_TEXTURE_COMPRESSED_IMAGE_SIZE, GL_BLUE_INTEGER, 
GL_RGBA16_SNORM, GL_TEXTURE_1D, GL_BLEND_SRC_RGB, GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH, GL_BGRA_INTEGER, 
GL_PROXY_TEXTURE_2D_MULTISAMPLE, GL_SYNC_FLAGS, GL_FALSE, GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS, GL_ONE_MINUS_SRC_ALPHA, 
GL_RG32I, GL_UNSIGNED_BYTE_2_3_3_REV, GL_SAMPLE_ALPHA_TO_ONE, GL_RENDERBUFFER_INTERNAL_FORMAT, GL_COMPRESSED_SIGNED_RED_RGTC1, 
GL_TEXTURE_HEIGHT, GL_PROGRAM_POINT_SIZE, GL_RGBA16I, GL_R8I, GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER, 
GL_SAMPLE_ALPHA_TO_COVERAGE, GL_INT_SAMPLER_2D, GL_RG32F, GL_TEXTURE_FIXED_SAMPLE_LOCATIONS, GL_STENCIL_PASS_DEPTH_FAIL, 
GL_RED, GL_POLYGON_OFFSET_LINE, GL_FUNC_REVERSE_SUBTRACT, GL_RGBA8UI, GL_COLOR_ATTACHMENT15, 
GL_GREEN, GL_INVALID_OPERATION, GL_FIXED_ONLY, GL_CLAMP_READ_COLOR, GL_RED_INTEGER, 
GL_NONE, GL_POLYGON_MODE, GL_COLOR_ATTACHMENT5, GL_MAX_FRAGMENT_UNIFORM_COMPONENTS, GL_COLOR_ATTACHMENT7, 
GL_UNIFORM_BLOCK_NAME_LENGTH, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT3, GL_COLOR_ATTACHMENT2, 
GL_UNIFORM_BLOCK_INDEX, GL_FRAMEBUFFER_DEFAULT, GL_COLOR_ATTACHMENT9, GL_COLOR_ATTACHMENT8, GL_LINE_SMOOTH_HINT, 
GL_COLOR_ATTACHMENT10, GL_PACK_IMAGE_HEIGHT, GL_NAND, GL_UNIFORM_BLOCK_DATA_SIZE, GL_BUFFER_USAGE, 
GL_CULL_FACE_MODE, GL_UNSIGNED_INT_8_8_8_8_REV, GL_RG32UI, GL_NUM_EXTENSIONS, GL_UNIFORM_IS_ROW_MAJOR, 
GL_MAX_UNIFORM_BLOCK_SIZE, GL_BOOL, GL_MAX_COMBINED_UNIFORM_BLOCKS, GL_FRAMEBUFFER_BINDING, GL_VERTEX_ATTRIB_ARRAY_ENABLED, 
GL_ALPHA, GL_SET, GL_COLOR_WRITEMASK, GL_DST_COLOR, GL_UNSIGNED_INT_SAMPLER_1D_ARRAY, 
GL_UNSIGNED_INT, GL_DEPTH_FUNC, GL_TEXTURE_WRAP_R, GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T, 
GL_DST_ALPHA, GL_STENCIL_BACK_VALUE_MASK, GL_INT_SAMPLER_2D_ARRAY, GL_POINT_SPRITE_COORD_ORIGIN, GL_POINT_SIZE_RANGE, 
GL_COMPRESSED_RGB, GL_TIME_ELAPSED, GL_DEPTH_COMPONENT, GL_SRC1_COLOR, GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES, 
GL_SAMPLER_2D_MULTISAMPLE_ARRAY, GL_TEXTURE_RECTANGLE, GL_SHADER_TYPE, GL_RG16_SNORM, GL_COMPARE_REF_TO_TEXTURE, 
GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE, GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE, GL_TRUE, GL_TEXTURE_MIN_FILTER, GL_FLOAT_MAT4, 
GL_QUERY_COUNTER_BITS, GL_RG_INTEGER, GL_TEXTURE_SWIZZLE_R, GL_PACK_SWAP_BYTES, GL_EQUAL, 
GL_TEXTURE_SWIZZLE_G, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER_HEIGHT, GL_RG16UI, GL_TEXTURE_BINDING_1D_ARRAY, 
GL_INTERLEAVED_ATTRIBS, GL_TEXTURE_ALPHA_TYPE, GL_TEXTURE_BINDING_2D_MULTISAMPLE, GL_COMPRESSED_RED_RGTC1, GL_BLUE, 
GL_DRAW_BUFFER14, GL_SHADER_SOURCE_LENGTH, GL_POINT_FADE_THRESHOLD_SIZE, GL_INT_SAMPLER_BUFFER, GL_COLOR_ATTACHMENT6, 
GL_TEXTURE_BLUE_TYPE, GL_UNPACK_ALIGNMENT, GL_COMPILE_STATUS, GL_STEREO, GL_ALREADY_SIGNALED, 
GL_LINE_STRIP, GL_STREAM_COPY, GL_PACK_ROW_LENGTH, GL_TEXTURE_CUBE_MAP, GL_COLOR_ATTACHMENT22, 
GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, GL_COLOR, GL_INT_SAMPLER_2D_RECT, GL_TRIANGLE_STRIP_ADJACENCY, GL_RENDERBUFFER_DEPTH_SIZE, 
GL_DYNAMIC_READ, GL_TEXTURE_BUFFER, GL_TEXTURE_BINDING_RECTANGLE, GL_DEPTH_STENCIL, GL_UNPACK_SKIP_PIXELS, 
GL_VERTEX_ATTRIB_ARRAY_DIVISOR, GL_MAX_VERTEX_OUTPUT_COMPONENTS, GL_POINTS, GL_SYNC_STATUS, GL_READ_WRITE, 
GL_PROXY_TEXTURE_2D, GL_UNIFORM_NAME_LENGTH, GL_FASTEST, GL_SYNC_CONDITION, GL_FRONT, 
GL_HALF_FLOAT, GL_ACTIVE_UNIFORM_MAX_LENGTH, GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS, GL_SCISSOR_BOX, GL_OR, 
GL_MAP_INVALIDATE_RANGE_BIT, GL_TEXTURE23, GL_TEXTURE22, GL_TEXTURE21, GL_LINE_WIDTH_GRANULARITY, 
GL_TEXTURE27, GL_TEXTURE26, GL_TEXTURE25, GL_TEXTURE24, GL_R8_SNORM, 
GL_TEXTURE29, GL_TEXTURE28, GL_SAMPLER_1D_ARRAY, GL_ELEMENT_ARRAY_BUFFER_BINDING, GL_PRIMITIVE_RESTART_INDEX, 
GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TRIANGLES_ADJACENCY, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, GL_LINE_LOOP, GL_READ_BUFFER, 
GL_MAP_FLUSH_EXPLICIT_BIT, GL_PACK_SKIP_PIXELS, GL_BACK_RIGHT, GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS, GL_RGBA, 
GL_R16F, GL_RIGHT, GL_GEQUAL, GL_R3_G3_B2, GL_UNIFORM_BLOCK_BINDING, 
GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT, GL_LINE_WIDTH, GL_UNIFORM_OFFSET, GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY, GL_LEQUAL, 
GL_UNSIGNED_INT_SAMPLER_CUBE, GL_TEXTURE_WIDTH, GL_ONE_MINUS_SRC1_ALPHA, GL_COLOR_ATTACHMENT4, GL_UNIFORM_SIZE, 
GL_SRC1_ALPHA, GL_FUNC_ADD, GL_FLOAT_MAT4x2, GL_FLOAT_MAT4x3, GL_BUFFER_ACCESS, 
GL_UNSIGNED_BYTE, GL_VERSION, GL_COMPRESSED_RG, GL_SIGNED_NORMALIZED, GL_CURRENT_VERTEX_ATTRIB, 
GL_ARRAY_BUFFER_BINDING, GL_TEXTURE_2D, GL_MAX_COLOR_TEXTURE_SAMPLES, GL_DYNAMIC_DRAW, GL_OUT_OF_MEMORY, 
GL_LINES_ADJACENCY, GL_NICEST, GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS, GL_UNSIGNED_SHORT_4_4_4_4_REV, GL_UNPACK_ROW_LENGTH, 
GL_CURRENT_PROGRAM, GL_BUFFER_MAPPED, GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS, GL_GEOMETRY_OUTPUT_TYPE, GL_RASTERIZER_DISCARD, 
GL_RENDERBUFFER_GREEN_SIZE, GL_LINE_STRIP_ADJACENCY, GL_STREAM_DRAW, GL_POLYGON_SMOOTH_HINT, GL_MAX_UNIFORM_BUFFER_BINDINGS, 
GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE, GL_SIGNALED, GL_PIXEL_PACK_BUFFER, GL_FRAMEBUFFER, GL_INT_SAMPLER_2D_MULTISAMPLE, 
GL_STENCIL_TEST, GL_R16, GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION, GL_R11F_G11F_B10F, GL_SRGB8, 
GL_PIXEL_UNPACK_BUFFER_BINDING, GL_DECR, GL_PROXY_TEXTURE_1D, GL_STENCIL_BACK_FAIL, GL_POLYGON_OFFSET_FACTOR, 
GL_TRANSFORM_FEEDBACK_VARYINGS, GL_DEPTH_COMPONENT32F, GL_TRIANGLE_FAN, GL_SYNC_FLUSH_COMMANDS_BIT, GL_DRAW_FRAMEBUFFER_BINDING, 
GL_MAX_ELEMENTS_VERTICES, GL_STENCIL_BACK_WRITEMASK, GL_UNSIGNED_INT_SAMPLER_2D_ARRAY, GL_INVALID_FRAMEBUFFER_OPERATION, GL_BUFFER_ACCESS_FLAGS, 
GL_UNIFORM_BUFFER_SIZE, GL_TEXTURE_BINDING_BUFFER, GL_TRIANGLES, GL_SAMPLER_2D_ARRAY_SHADOW, GL_DEPTH32F_STENCIL8, 
GL_MAX_ARRAY_TEXTURE_LAYERS, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, GL_UNIFORM_MATRIX_STRIDE, GL_MAX_DEPTH_TEXTURE_SAMPLES, GL_MAX_SERVER_WAIT_TIMEOUT, 
GL_QUERY_BY_REGION_WAIT, GL_NOR, GL_SRGB8_ALPHA8, GL_RGBA16F, GL_FLOAT_MAT2x3, 
GL_PACK_ALIGNMENT, GL_SAMPLER_2D_ARRAY, GL_RENDERER, GL_UNPACK_LSB_FIRST, GL_MAX_COLOR_ATTACHMENTS, 
GL_CLIP_DISTANCE0, GL_ACTIVE_UNIFORM_BLOCKS, GL_CLIP_DISTANCE3, GL_UNPACK_SKIP_IMAGES, GL_STENCIL_BACK_FUNC, 
GL_RGB16I, GL_ACTIVE_TEXTURE, GL_TEXTURE_BASE_LEVEL, GL_RGB16F, GL_SMOOTH_LINE_WIDTH_RANGE, 
GL_FIRST_VERTEX_CONVENTION, GL_COLOR_LOGIC_OP, GL_MINOR_VERSION, GL_LAST_VERTEX_CONVENTION, GL_UNSIGNED_INT_SAMPLER_3D, 
GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH, GL_ALWAYS, GL_INT_VEC4, GL_INT_VEC3, GL_INT_VEC2, 
GL_STENCIL_FAIL, GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS, GL_MAX_VERTEX_ATTRIBS, GL_CONDITION_SATISFIED, GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT, 
GL_LINE_WIDTH_RANGE, GL_XOR, GL_FRAMEBUFFER_UNSUPPORTED, GL_INVALID_ENUM, GL_CONTEXT_PROFILE_MASK, 
GL_DYNAMIC_COPY, GL_LESS, GL_MAX_CUBE_MAP_TEXTURE_SIZE, GL_FRAMEBUFFER_UNDEFINED, GL_TEXTURE_1D_ARRAY, 
GL_TEXTURE_STENCIL_SIZE, GL_RENDERBUFFER_WIDTH, GL_READ_FRAMEBUFFER_BINDING, GL_FRAMEBUFFER_ATTACHMENT_LAYERED, GL_TEXTURE_BLUE_SIZE, 
GL_TEXTURE_DEPTH_TYPE, GL_INT_SAMPLER_1D, GL_RGBA2, GL_RGBA4, GL_DRAW_BUFFER10, 
GL_DRAW_BUFFER11, GL_RGBA8, GL_DRAW_BUFFER13, GL_UNSIGNED_INT_10_10_10_2, GL_DRAW_BUFFER15, 
GL_INFO_LOG_LENGTH, GL_COMPRESSED_RG_RGTC2, GL_POLYGON_OFFSET_UNITS, GL_SRC_ALPHA_SATURATE, GL_RENDERBUFFER_STENCIL_SIZE, 
GL_REPEAT, GL_R16I, GL_RG8_SNORM, GL_POINT_SIZE_GRANULARITY, GL_STATIC_READ, 
GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER, GL_SCISSOR_TEST, GL_VALIDATE_STATUS, GL_MAP_READ_BIT, GL_RG16, 
GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS, GL_STENCIL, GL_SAMPLE_MASK_VALUE, GL_STENCIL_BUFFER_BIT, GL_TEXTURE_2D_MULTISAMPLE, 
GL_SAMPLER_1D_ARRAY_SHADOW, GL_TEXTURE_SWIZZLE_B, GL_BLEND_EQUATION_ALPHA, GL_RGBA_INTEGER, GL_ACTIVE_ATTRIBUTES, 
GL_MAX_RENDERBUFFER_SIZE, GL_COLOR_ATTACHMENT31, GL_COLOR_ATTACHMENT30, GL_STENCIL_PASS_DEPTH_PASS, GL_INCR_WRAP, 
GL_RENDERBUFFER_ALPHA_SIZE, GL_TEXTURE20, GL_COLOR_ATTACHMENT16, GL_DECR_WRAP, GL_TEXTURE_RED_TYPE, 
GL_POLYGON_SMOOTH, GL_ATTACHED_SHADERS, GL_SAMPLE_POSITION, GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY, GL_QUERY_BY_REGION_NO_WAIT, 
GL_SAMPLE_COVERAGE_INVERT, GL_INCR, GL_TEXTURE18, GL_TEXTURE19, GL_TEXTURE16, 
GL_TEXTURE_BORDER_COLOR, GL_RGBA12, GL_TEXTURE15, GL_TEXTURE12, GL_COLOR_ATTACHMENT11, 
GL_RGBA16, GL_UNPACK_SKIP_ROWS, GL_DEPTH_CLAMP, GL_BLEND_DST_ALPHA, GL_RGB, 
GL_INT_SAMPLER_CUBE, GL_CURRENT_QUERY, GL_VERTEX_ATTRIB_ARRAY_NORMALIZED, GL_RGB5_A1, GL_VERTEX_SHADER, 
GL_UNSIGNED_SHORT_1_5_5_5_REV, GL_TRANSFORM_FEEDBACK_BUFFER_START, GL_COPY_INVERTED, GL_MAX_PROGRAM_TEXEL_OFFSET, GL_MAX_GEOMETRY_INPUT_COMPONENTS, 
GL_LOWER_LEFT, GL_CONSTANT_COLOR, GL_UNSIGNED_INT_SAMPLER_2D_RECT, GL_RGBA32F, GL_TEXTURE_BINDING_1D, 
GL_VERTEX_ATTRIB_ARRAY_TYPE, GL_PIXEL_UNPACK_BUFFER, GL_LINEAR_MIPMAP_NEAREST, GL_STENCIL_WRITEMASK, GL_RG8, 
GL_RGB10_A2, GL_STENCIL_BACK_PASS_DEPTH_PASS, GL_INVALID_VALUE, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_SEPARATE_ATTRIBS, 
GL_MAP_UNSYNCHRONIZED_BIT, GL_ZERO, GL_PRIMITIVE_RESTART, GL_ELEMENT_ARRAY_BUFFER, GL_CONTEXT_CORE_PROFILE_BIT, 
GL_BUFFER_MAP_LENGTH, GL_READ_ONLY, GL_MAX_FRAGMENT_INPUT_COMPONENTS, GL_MAX_ELEMENTS_INDICES, GL_UNSIGNED_NORMALIZED, 
GL_CONSTANT_ALPHA, GL_SRC_ALPHA, GL_TEXTURE_3D, GL_GEOMETRY_VERTICES_OUT, GL_RGB8, 
GL_NOTEQUAL, GL_UNIFORM_ARRAY_STRIDE, GL_TEXTURE_SAMPLES, GL_RGB4, GL_RGB5, 
GL_LINES, GL_CULL_FACE, GL_COMPRESSED_RED, GL_BGR, GL_SAMPLE_COVERAGE_VALUE, 
GL_TEXTURE_RED_SIZE, GL_PROXY_TEXTURE_CUBE_MAP, GL_MAX_VIEWPORT_DIMS, GL_TEXTURE_SWIZZLE_A, GL_MAX_RECTANGLE_TEXTURE_SIZE, 
GL_COMPRESSED_SIGNED_RG_RGTC2, GL_PIXEL_PACK_BUFFER_BINDING, GL_TEXTURE11, GL_TEXTURE14, GL_NEVER, 
GL_STENCIL_VALUE_MASK, GL_BLEND_DST, GL_TEXTURE13, GL_TEXTURE_INTERNAL_FORMAT, GL_TEXTURE_SHARED_SIZE, 
GL_TEXTURE10, GL_LOGIC_OP_MODE, GL_FRAMEBUFFER_COMPLETE, GL_MAX_FRAGMENT_UNIFORM_BLOCKS, GL_COPY_READ_BUFFER, 
GL_STENCIL_ATTACHMENT, GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, GL_TEXTURE_SWIZZLE_RGBA, GL_DEPTH_COMPONENT32, GL_SUBPIXEL_BITS, 
GL_SHORT, GL_READ_FRAMEBUFFER, GL_CW, GL_UNSIGNED_INT_24_8, GL_SMOOTH_POINT_SIZE_GRANULARITY, 
GL_MAX_TEXTURE_BUFFER_SIZE, GL_MAX_VERTEX_UNIFORM_COMPONENTS, GL_VENDOR, GL_TEXTURE_2D_ARRAY, GL_UNSIGNED_INT_10F_11F_11F_REV, 
GL_TEXTURE_BINDING_2D, GL_OBJECT_TYPE, GL_BLEND_EQUATION, GL_GEOMETRY_SHADER, GL_R8UI, 
GL_STATIC_DRAW, GL_PACK_LSB_FIRST, GL_PACK_SKIP_IMAGES, GL_RGBA16UI, GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER, 
GL_UNSIGNED_BYTE_3_3_2, GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE, GL_FLOAT_MAT2x4, GL_RGB8I, GL_COLOR_ATTACHMENT18, 
GL_TRANSFORM_FEEDBACK_BUFFER_SIZE, GL_DRAW_BUFFER, GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY, GL_PRIMITIVES_GENERATED, GL_DRAW_BUFFER0, 
GL_STENCIL_INDEX4, GL_SAMPLER_3D, GL_MAX, GL_TEXTURE_GREEN_TYPE, GL_PROXY_TEXTURE_2D_ARRAY, 
GL_MAX_INTEGER_SAMPLES, GL_COMPRESSED_SRGB, GL_OR_INVERTED, GL_RGB8UI, GL_STENCIL_INDEX16, 
GL_STENCIL_BACK_REF, GL_INVALID_INDEX, GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS, GL_SAMPLER_1D_SHADOW, GL_BLEND_DST_RGB, 
GL_SAMPLER_2D_SHADOW, GL_EQUIV, GL_TEXTURE_BINDING_2D_ARRAY, GL_MAX_GEOMETRY_UNIFORM_BLOCKS, GL_RG16F, 
GL_CLEAR, GL_DRAW_BUFFER8, GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL, GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT, GL_RG16I, 
GL_WRITE_ONLY, GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, GL_TEXTURE_GREEN_SIZE, GL_SAMPLE_COVERAGE, GL_DRAW_FRAMEBUFFER, 
GL_RGB10_A2UI, GL_TEXTURE_LOD_BIAS, GL_SAMPLES;

