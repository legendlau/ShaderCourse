using UnityEngine;
using System.Collections;
using System.IO;

public class ExportToImg : MonoBehaviour {
    public RenderTexture rt;

    [ButtonCallFunc()]
    public bool Export;

    public void ExportMethod() {
        DoExport();
    }

    //public Texture2D  tex;
	// Use this for initialization
	void DoExport  () {
        RenderTexture.active = rt;
        var tex = new Texture2D(rt.width, rt.height);
        tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        tex.Apply();

        var fd = tex.EncodeToPNG();
        var hp = Path.Combine(Application.dataPath, "height.png");
        Debug.Log(hp);
        File.WriteAllBytes(hp, fd);
	}
	

    public Texture2D heightMap;

    [ButtonCallFunc()]
    public bool SetTerrain;

    public void SetTerrainMethod() {
        var td = Terrain.activeTerrain.terrainData;
        var w = heightMap.width;
        var h = heightMap.height;

        var w2 = td.heightmapWidth;
        var h2 = td.heightmapHeight;

        var hd = td.GetHeights(0, 0, w2, h2);
        var colors = heightMap.GetPixels();

        Debug.Log("Widht: "+w+" "+ h+" "+w2+" "+h2);
        for(var y = 0; y < w2; y++) {
            for(var x = 0; x < w2; x++) {
                hd[y, x] = colors[y*w2+x].grayscale;
            }
        }
        td.SetHeights(0, 0, hd);
    }
}
