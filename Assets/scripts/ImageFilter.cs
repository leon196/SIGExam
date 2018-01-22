using UnityEngine;
using System.Collections;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode]
public class ImageFilter : MonoBehaviour 
{
	public Shader shader;
	private Material material;

	void OnRenderImage (RenderTexture source, RenderTexture destination) 
	{
		if (material == null) material = new Material(shader);
		Graphics.Blit (source, destination, material);
	}
}