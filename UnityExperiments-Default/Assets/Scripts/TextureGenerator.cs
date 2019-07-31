using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TextureGenerator : MonoBehaviour
{
    public Material Material;
    public Gradient Gradient;
    public float NormalOffset;

    private const int TextureResolution = 50;
    private Texture2D _texture;

    private void Initialize()
    {
        if (_texture == null || _texture.width != TextureResolution)
        {
            _texture = new Texture2D(TextureResolution, 1, TextureFormat.RGBA32, false);
        }
    }

    private void Update()
    {
        Initialize();
        UpdateTexture();
        Material.SetTexture("_MainTex", _texture);
    }

    private void UpdateTexture()
    {
        if (Gradient != null)
        {
            Color[] colours = new Color[_texture.width];
            for (int i = 0; i < TextureResolution; i++)
            {
                Color gradientCol = Gradient.Evaluate(i / (TextureResolution - 1f));
                colours[i] = gradientCol;
            }

            _texture.SetPixels(colours);
            _texture.Apply();
        }
    }
}
