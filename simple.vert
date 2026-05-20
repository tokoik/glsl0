#version 120

// simple.vert

void main(void)
{
  // 頂点位置
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
