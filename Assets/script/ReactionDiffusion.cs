using UnityEngine;
using System.Collections;

/// <summary>
/// 首先SetTex 设置初始化的 rendertexture纹理
/// ShowAnim 启动动画
/// SwitchTex 切换动画的每一帧 
/// </summary>
public class ReactionDiffusion : MonoBehaviour {
    public RenderTexture temp1;
    public RenderTexture temp2;

    public GameObject cube;

    private Material mat;

    public bool initYet = false;
    Camera cam;

    float timePass = 0;
    public int iterNum = 20;
    private RenderTexture createTexture() {
        var t = new RenderTexture(512, 512, 0, RenderTextureFormat.ARGBFloat);
        t.filterMode = FilterMode.Point;
        t.anisoLevel = 1;
        t.generateMips = false;
        t.useMipMap = false;
        t.Create();
        return t;
    }
    void Awake() {
        temp1 = createTexture();
        temp2 = createTexture();

        cam = GetComponent<Camera>();
        cam.targetTexture = temp1;
        cam.enabled = false;


        /*
        var mr = cube.GetComponent<MeshRenderer>();
        mat = mr.material;
        mat.mainTexture = temp2;
        */


        mat = new Material(Shader.Find("Custom/ReactionDiffusion"));
        mat.mainTexture = temp2;
        var mr = cube.GetComponent<MeshRenderer>();
        mr.material = mat;
    }

    [ButtonCallFunc()]
    public bool InitTex;
    public void InitTexMethod() {
        cam.enabled = true;
    }

    [ButtonCallFunc()]
    public bool SetTex;

    public void SetTexMethod() {
        cam.enabled = false;
        cam.targetTexture = temp2;
        mat.mainTexture = temp1;
    }

    [ButtonCallFunc()]
    public bool ShowAnim;
    public void ShowAnimMethod() {
        mat.SetFloat("inInit", 1);
    }





    private bool isFast =false;

    [ButtonCallFunc()]
    public bool FastAnim;
    public void FastAnimMethod() {
        isFast = !isFast;
    }


	
	// Update is called once per frame
	void Update () {

        if(isFast) {
            for(var i = 0; i < iterNum; i++) {
                SwitchTexMethod();
            }
        }
	}

    [ButtonCallFunc()]
    public bool SwitchTex;
    public void SwitchTexMethod() {
        Graphics.Blit(temp1, temp2, mat);
        Graphics.Blit(temp2, temp1, mat);
    }
    void OnGUI() {
        GUI.DrawTexture (new Rect (0, 0, Screen.width, Screen.height), temp1, ScaleMode.StretchToFill);
    }
}
