#version 120

// simple.vert

void main()
{
  // 頂点位置
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
