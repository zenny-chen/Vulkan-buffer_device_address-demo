#version 450
#extension GL_ARB_gpu_shader_int64 : enable
#extension GL_EXT_buffer_reference : enable
#extension GL_EXT_buffer_reference2 : enable

layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(constant_id = 0) const highp uint total_data_elem_count = 1024U;

layout(buffer_reference, std430) buffer DataBufferType {
    highp int data[total_data_elem_count];
};

layout(buffer_reference, std430, buffer_reference_align = 16) buffer BufferOfBufferType {
    DataBufferType bufferArray;
};

layout(std430, set = 0, binding = 0) buffer readonly src {
    DataBufferType srcWrapperBuffer[];
};

void main(void)
{
    DataBufferType dstBuffer = srcWrapperBuffer[0];
    DataBufferType srcBuffer = srcWrapperBuffer[1];
    DataBufferType dummyBuffer = srcWrapperBuffer[2];
    if (uint64_t(dstBuffer) == 0 || uint64_t(srcBuffer) == 0 || uint64_t(dummyBuffer) != 0) {
        //return;
    }

    const uint gid = gl_GlobalInvocationID.x;
    dstBuffer.data[gid] = srcBuffer.data[gid] + srcBuffer.data[gid];

    if (gid == 0) {
        dstBuffer.data[gid] = int(total_data_elem_count);
    }
}

