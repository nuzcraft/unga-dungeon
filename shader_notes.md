# 3D Screenspace Shader Notes

1. Create a new MeshInstance3D in your 3D scene
2. Add a QuadMesh mesh to the instance
3. In `Geometry` for the instance, increase the `Extra Cull Margin` to the max
    - As of writing, 16384 m
4. In the Quadmesh, increase the size from 1x1 m to 2x2 m
5. In the Quadmesh, check the `Flip Faces` box so that it's True
6. In the Quadmesh, in `Material`, choose `New Shader Material`
7. In the Material, in `Shader`, choose `New Shader`
8. Here you can choose a name for your shader and we can start customizing!

## Depth-based Edge Detection

