#line 1
struct Frustum {
    vec4 planes[6];
};

layout(binding = 0, std140) uniform SceneUniform {
    mat4 MVP;
    ivec3 baseSectionPos;
    int sectionCount;
    Frustum frustum;
    vec3 cameraSubPos;
    uint frameId;
};

struct BlockModel {
    uint faceData[6];
    uint flagsA;
    uint colourTint;
    uint _pad[8];
};

struct SectionMeta {
    uint posA;
    uint posB;
    uint AABB;
    uint ptr;
    uint cntA;
    uint cntB;
    uint cntC;
    uint cntD;
};

//TODO: see if making the stride 2*4*4 bytes or something cause you get that 16 byte write
struct DrawCommand {
    uint  count;
    uint  instanceCount;
    uint  firstIndex;
    int  baseVertex;
    uint  baseInstance;
};

layout(binding = 0) uniform sampler2D blockModelAtlas;

#ifndef Quad
#define Quad ivec2
#endif
layout(binding = 1, std430) readonly restrict buffer GeometryBuffer {
    Quad geometryPool[];
};

layout(binding = 2, std430) restrict buffer DrawBuffer {
    DrawCommand drawCmd;
};

#ifndef MESHLET_ACCESS
#define MESHLET_ACCESS readonly writeonly
#endif
layout(binding = 3, std430) MESHLET_ACCESS restrict buffer MeshletListData {
    uint meshlets[];
};

layout(binding = 4, std430) readonly restrict buffer SectionBuffer {
    SectionMeta sectionData[];
};

#ifndef VISIBILITY_ACCESS
#define VISIBILITY_ACCESS readonly
#endif
layout(binding = 5, std430) VISIBILITY_ACCESS restrict buffer VisibilityBuffer {
    uint visibilityData[];
};

layout(binding = 6, std430) readonly restrict buffer ModelBuffer {
    BlockModel modelData[];
};

layout(binding = 7, std430) readonly restrict buffer ModelColourBuffer {
    uint colourData[];
};

layout(binding = 8, std430) readonly restrict buffer LightingBuffer {
    uint lightData[];
};

vec4 getLighting(uint index) {
    uvec4 arr = uvec4(lightData[index]);
    arr = arr>>uvec4(16,8,0,24);
    arr = arr & uvec4(0xFF);
    return vec4(arr)*vec4(1.0f/255.0f);
}