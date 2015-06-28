//
//  SPOpenGL.m
//  Sparrow
//
//  Created by Robert Carone on 10/8/13.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPOpenGL.h>

const char* sglGetErrorString(uint error)
{
	switch (error)
    {
        case GL_NO_ERROR:                       return "GL_NO_ERROR";
		case GL_INVALID_ENUM:                   return "GL_INVALID_ENUM";
		case GL_INVALID_OPERATION:              return "GL_INVALID_OPERATION";
		case GL_INVALID_VALUE:                  return "GL_INVALID_VALUE";
		case GL_INVALID_FRAMEBUFFER_OPERATION:  return "GL_INVALID_FRAMEBUFFER_OPERATION";
		case GL_OUT_OF_MEMORY:                  return "GL_OUT_OF_MEMORY";
	}

	return "UNKNOWN_ERROR";
}

/** --------------------------------------------------------------------------------------------- */
#pragma mark - OpenGL State Cache
/** --------------------------------------------------------------------------------------------- */

#if SP_ENABLE_GL_STATE_CACHE

// undefine previous 'shims'
#undef glActiveTexture
#undef glBindBuffer
#undef glBindFramebuffer
#undef glBindRenderbuffer
#undef glBindTexture
#undef glBindVertexArray
#undef glBlendFunc
#undef glClearColor
#undef glCreateProgram
#undef glDeleteBuffers
#undef glDeleteFramebuffers
#undef glDeleteProgram
#undef glDeleteRenderbuffers
#undef glDeleteTextures
#undef glDeleteVertexArrays
#undef glDisable
#undef glEnable
#undef glGetIntegerv
#undef glLinkProgram
#undef glScissor
#undef glUseProgram
#undef glViewport

// redefine extension mappings
#define glBindVertexArray       glBindVertexArrayOES
#define glDeleteVertexArrays    glDeleteVertexArraysOES

// constants
#define MAX_TEXTURE_UNITS   32
#define INVALID_STATE      -1

// state definition
struct SGLStateCache
{
    char enabledCaps[10];
    int  textureUnit;
    int  texture[MAX_TEXTURE_UNITS];
    int  buffer[2];
    int  program;
    int  framebuffer;
    int  renderbuffer;
    int  vertexArray;
    int  blendSrc;
    int  blendDst;
    int  viewport[4];
    int  scissor[4];
};

// global cache
static SGLStateCacheRef currentStateCache = NULL;

/** --------------------------------------------------------------------------------------------- */
#pragma mark Internal
/** --------------------------------------------------------------------------------------------- */

SP_INLINE int __getIndexForCapability(uint cap)
{
    switch (cap)
    {
        case GL_BLEND:                      return 0;
        case GL_CULL_FACE:                  return 1;
        case GL_DEPTH_TEST:                 return 2;
        case GL_DITHER:                     return 3;
        case GL_POLYGON_OFFSET_FILL:        return 4;
        case GL_SAMPLE_ALPHA_TO_COVERAGE:   return 5;
        case GL_SAMPLE_COVERAGE:            return 6;
        case GL_SCISSOR_TEST:               return 7;
        case GL_STENCIL_TEST:               return 8;
        case GL_TEXTURE_2D:                 return 9;
    }

    return INVALID_STATE;
}

SP_INLINE uint __getCapabilityForIndex(int index)
{
    switch (index)
    {
        case 0: return GL_BLEND;
        case 1: return GL_CULL_FACE;
        case 2: return GL_DEPTH_TEST;
        case 3: return GL_DITHER;
        case 4: return GL_POLYGON_OFFSET_FILL;
        case 5: return GL_SAMPLE_ALPHA_TO_COVERAGE;
        case 6: return GL_SAMPLE_COVERAGE;
        case 7: return GL_SCISSOR_TEST;
        case 8: return GL_STENCIL_TEST;
        case 9: return GL_TEXTURE_2D;
    }

    return GL_NONE;
}

SP_INLINE void __getChar(GLenum pname, GLchar* state, GLint* outParam)
{
    if (*state == INVALID_STATE)
    {
        GLint i;
        glGetIntegerv(pname, &i);
        *state = (GLchar)i;
    }

    *outParam = *state;
}

SP_INLINE void __getInt(GLenum pname, GLint* state, GLint* outParam)
{
    if (*state == INVALID_STATE)
        glGetIntegerv(pname, state);

    *outParam = *state;
}

SP_INLINE void __getIntv(GLenum pname, GLint count, GLint statev[], GLint* outParams)
{
    if (*statev == INVALID_STATE)
        glGetIntegerv(pname, statev);

    memcpy(outParams, statev, sizeof(GLint)*count);
}

SP_INLINE SGLStateCacheRef __getDefaultStateCache(void)
{
    static SGLStateCacheRef defaultStateCache;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultStateCache = malloc(sizeof(struct SGLStateCache));
        memset(defaultStateCache, INVALID_STATE, sizeof(struct SGLStateCache));
    });

    return defaultStateCache;
}

SP_INLINE SGLStateCacheRef __getCurrentStateCache(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentStateCache = __getDefaultStateCache();
    });

    return currentStateCache;
}

/** --------------------------------------------------------------------------------------------- */
#pragma mark State
/** --------------------------------------------------------------------------------------------- */

SGLStateCacheRef sglStateCacheCreate(void)
{
    SGLStateCacheRef newStateCache = malloc(sizeof(struct SGLStateCache));
    memset(newStateCache, INVALID_STATE, sizeof(struct SGLStateCache));
    return newStateCache;
}

SGLStateCacheRef sglStateCacheCopy(SGLStateCacheRef stateCache)
{
    SGLStateCacheRef stateCacheCopy = malloc(sizeof(struct SGLStateCache));
    memcpy(stateCacheCopy, stateCache, sizeof(struct SGLStateCache));
    return stateCacheCopy;
}

void sglStateCacheRelease(SGLStateCacheRef stateCache)
{
    if (stateCache == __getCurrentStateCache())
        sglStateCacheSetCurrent(__getDefaultStateCache());

    if (!stateCache || stateCache == __getDefaultStateCache())
        return sglStateCacheSetCurrent(__getDefaultStateCache());

    free(stateCache);
}

void sglStateCacheReset(SGLStateCacheRef stateCache)
{
    memset(stateCache, INVALID_STATE, sizeof(*stateCache));
}

SGLStateCacheRef sglStateCacheGetCurrent(void)
{
    return __getCurrentStateCache();
}

void sglStateCacheSetCurrent(SGLStateCacheRef stateCache)
{
    if (!stateCache) stateCache = __getDefaultStateCache();
    if (stateCache == __getCurrentStateCache()) return;

    // don't alter the current state
    struct SGLStateCache tempStateCache = *currentStateCache;
    currentStateCache = &tempStateCache;

    if (stateCache->framebuffer != INVALID_STATE)
        sglBindFramebuffer(GL_FRAMEBUFFER, stateCache->framebuffer);

    if (stateCache->renderbuffer != INVALID_STATE)
        sglBindRenderbuffer(GL_RENDERBUFFER, stateCache->renderbuffer);

    if (stateCache->buffer[0] != INVALID_STATE)
        sglBindBuffer(GL_ARRAY_BUFFER, stateCache->buffer[0]);

    if (stateCache->buffer[1] != INVALID_STATE)
        sglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, stateCache->buffer[1]);

    if (stateCache->vertexArray != INVALID_STATE)
        sglBindVertexArray(stateCache->vertexArray);

    if (stateCache->blendSrc != INVALID_STATE && stateCache->blendDst != INVALID_STATE)
        sglBlendFunc(stateCache->blendSrc, stateCache->blendDst);

    if (stateCache->program != INVALID_STATE)
        sglUseProgram(stateCache->program);

    if (stateCache->viewport[0] != INVALID_STATE &&
        stateCache->viewport[1] != INVALID_STATE &&
        stateCache->viewport[2] != INVALID_STATE &&
        stateCache->viewport[3] != INVALID_STATE)
        sglViewport(stateCache->viewport[0], stateCache->viewport[1],
                    stateCache->viewport[2], stateCache->viewport[3]);

    if (stateCache->scissor[0] != INVALID_STATE &&
        stateCache->scissor[1] != INVALID_STATE &&
        stateCache->scissor[2] != INVALID_STATE &&
        stateCache->scissor[3] != INVALID_STATE)
        sglScissor(stateCache->scissor[0], stateCache->scissor[1],
                   stateCache->scissor[2], stateCache->scissor[3]);

    for (int i=0; i<32; ++i)
    {
        if (stateCache->texture[i] != INVALID_STATE)
        {
            sglActiveTexture(GL_TEXTURE0 + i);
            sglBindTexture(GL_TEXTURE_2D, stateCache->texture[i]);
        }
    }

    for (int i=0; i<10; ++i)
    {
        if (stateCache->enabledCaps[i] == true)
            sglEnable(__getCapabilityForIndex(i));
        else if (stateCache->enabledCaps[i] == false)
            sglDisable(__getCapabilityForIndex(i));
    }

    currentStateCache = stateCache;
}

/** --------------------------------------------------------------------------------------------- */
#pragma mark OpenGL
/** --------------------------------------------------------------------------------------------- */

void sglActiveTexture(GLenum texture)
{
    int textureUnit = texture-GL_TEXTURE0;
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();

    if (textureUnit != currentStateCache->textureUnit)
    {
        currentStateCache->textureUnit = textureUnit;
        glActiveTexture(texture);
    }
}

void sglBindBuffer(GLenum target, GLuint buffer)
{
    int index = target-GL_ARRAY_BUFFER;
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();

    if (buffer != currentStateCache->buffer[index])
    {
        currentStateCache->buffer[index] = buffer;
        glBindBuffer(target, buffer);
    }
}

void sglBindFramebuffer(GLenum target, GLuint framebuffer)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (framebuffer != currentStateCache->framebuffer)
    {
        currentStateCache->framebuffer = framebuffer;
        glBindFramebuffer(target, framebuffer);
    }
}

void sglBindRenderbuffer(GLenum target, GLuint renderbuffer)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (renderbuffer != currentStateCache->renderbuffer)
    {
        currentStateCache->renderbuffer = renderbuffer;
        glBindRenderbuffer(target, renderbuffer);
    }
}

void sglBindTexture(GLenum target, GLuint texture)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (currentStateCache->textureUnit == INVALID_STATE)
        sglActiveTexture(GL_TEXTURE0);

    if (texture != currentStateCache->texture[currentStateCache->textureUnit])
    {
        currentStateCache->texture[currentStateCache->textureUnit] = texture;
        glBindTexture(target, texture);
    }
}

void sglBindVertexArray(GLuint array)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (array != currentStateCache->vertexArray)
    {
        currentStateCache->vertexArray = array;
        glBindVertexArray(array);
    }
}

void sglBlendFunc(GLenum sfactor, GLenum dfactor)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (sfactor != currentStateCache->blendSrc || dfactor != currentStateCache->blendDst)
    {
        currentStateCache->blendSrc = sfactor;
        currentStateCache->blendDst = dfactor;
        glBlendFunc(sfactor, dfactor);
    }
}

void sglDeleteBuffers(GLsizei n, const GLuint* buffers)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    for (int i=0; i<n; i++)
    {
        if (currentStateCache->buffer[0] == buffers[i]) currentStateCache->buffer[0] = INVALID_STATE;
        if (currentStateCache->buffer[1] == buffers[i]) currentStateCache->buffer[1] = INVALID_STATE;
    }

    glDeleteBuffers(n, buffers);
}

void sglDeleteFramebuffers(GLsizei n, const GLuint* framebuffers)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    for (int i=0; i<n; i++)
    {
        if (currentStateCache->framebuffer == framebuffers[i])
            currentStateCache->framebuffer = INVALID_STATE;
    }

    glDeleteFramebuffers(n, framebuffers);
}

void sglDeleteProgram(GLuint program)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (currentStateCache->program == program)
        currentStateCache->program = INVALID_STATE;

    glDeleteProgram(program);
}

void sglDeleteRenderbuffers(GLsizei n, const GLuint* renderbuffers)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    for (int i=0; i<n; i++)
    {
        if (currentStateCache->renderbuffer == renderbuffers[i])
            currentStateCache->renderbuffer = INVALID_STATE;
    }

    glDeleteRenderbuffers(n, renderbuffers);
}

void sglDeleteTextures(GLsizei n, const GLuint* textures)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    for (int i=0; i<n; i++)
    {
        for (int j=0; j<32; j++)
        {
            if (currentStateCache->texture[j] == textures[i])
                currentStateCache->texture[j] = INVALID_STATE;
        }
    }

    glDeleteTextures(n, textures);
}

void sglDeleteVertexArrays(GLsizei n, const GLuint* arrays)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    for (int i=0; i<n; i++)
    {
        if (currentStateCache->vertexArray == arrays[i])
            currentStateCache->vertexArray = INVALID_STATE;
    }

    glDeleteVertexArrays(n, arrays);
}

void sglDisable(GLenum cap)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    int index = __getIndexForCapability(cap);

    if (currentStateCache->enabledCaps[index] != false)
    {
        currentStateCache->enabledCaps[index] = false;
        glDisable(cap);
    }
}

void sglEnable(GLenum cap)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    int index = __getIndexForCapability(cap);

    if (currentStateCache->enabledCaps[index] != true)
    {
        currentStateCache->enabledCaps[index] = true;
        glEnable(cap);
    }
}

void sglGetIntegerv(GLenum pname, GLint* params)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();

    switch (pname)
    {
        case GL_BLEND:
        case GL_CULL_FACE:
        case GL_DEPTH_TEST:
        case GL_DITHER:
        case GL_POLYGON_OFFSET_FILL:
        case GL_SAMPLE_ALPHA_TO_COVERAGE:
        case GL_SAMPLE_COVERAGE:
        case GL_SCISSOR_TEST:
        case GL_STENCIL_TEST:
            __getChar(pname, &currentStateCache->enabledCaps[__getIndexForCapability(pname)], params);
            return;

        case GL_ACTIVE_TEXTURE:
            __getInt(pname, &currentStateCache->textureUnit, params);
            return;

        case GL_ARRAY_BUFFER_BINDING:
            __getInt(pname, &currentStateCache->buffer[0], params);
            return;

        case GL_CURRENT_PROGRAM:
            __getInt(pname, &currentStateCache->program, params);
            return;

        case GL_ELEMENT_ARRAY_BUFFER_BINDING:
            __getInt(pname, &currentStateCache->buffer[1], params);
            return;

        case GL_FRAMEBUFFER_BINDING:
            __getInt(pname, &currentStateCache->framebuffer, params);
            return;

        case GL_RENDERBUFFER_BINDING:
            __getInt(pname, &currentStateCache->renderbuffer, params);
            return;

        case GL_SCISSOR_BOX:
            __getIntv(pname, 4, currentStateCache->scissor, params);
            return;

        case GL_TEXTURE_BINDING_2D:
            __getInt(pname, &currentStateCache->textureUnit, params);
            return;

        case GL_VERTEX_ARRAY_BINDING:
            __getInt(pname, &currentStateCache->vertexArray, params);
            return;

        case GL_VIEWPORT:
            __getIntv(pname, 4, currentStateCache->viewport, params);
            return;
    }

    glGetIntegerv(pname, params);
}

void sglScissor(GLint x, GLint y, GLsizei width, GLsizei height)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (x      != currentStateCache->scissor[0] ||
        y      != currentStateCache->scissor[1] ||
        width  != currentStateCache->scissor[2] ||
        height != currentStateCache->scissor[3])
    {
        currentStateCache->scissor[0] = x;
        currentStateCache->scissor[1] = y;
        currentStateCache->scissor[2] = width;
        currentStateCache->scissor[3] = height;

        glScissor(x, y, width, height);
    }
}

void sglUseProgram(GLuint program)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (program != currentStateCache->program)
    {
        currentStateCache->program = program;
        glUseProgram(program);
    }
}

void sglViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
    SGLStateCacheRef currentStateCache = __getCurrentStateCache();
    if (width  != currentStateCache->viewport[2] ||
        height != currentStateCache->viewport[3] ||
        x      != currentStateCache->viewport[0] ||
        y      != currentStateCache->viewport[1])
    {
        currentStateCache->viewport[0] = x;
        currentStateCache->viewport[1] = y;
        currentStateCache->viewport[2] = width;
        currentStateCache->viewport[3] = height;
        
        glViewport(x, y, width, height);
    }
}

#else

SGLStateCacheRef sglStateCacheCreate(void)                                      { return NULL; }
SGLStateCacheRef sglStateCacheCopy(SGLStateCacheRef stateCache __unused)        { return NULL; }
void             sglStateCacheRelease(SGLStateCacheRef stateCache __unused)     {}
void             sglStateCacheReset(SGLStateCacheRef stateCache __unused)       {}
SGLStateCacheRef sglStateCacheGetCurrent(void)                                  { return NULL; }
void             sglStateCacheSetCurrent(SGLStateCacheRef stateCache __unused)  {}

#endif
