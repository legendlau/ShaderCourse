using UnityEngine;
using System.Collections;

/// <summary>
/// 首先SetTex 设置初始化的 rendertexture纹理
/// ShowAnim 启动动画
/// SwitchTex 切换动画的每一帧 
/// </summary>
public class SetRenderTex : MonoBehaviour {
    public RenderTexture temp1;
    public RenderTexture temp2;

    public GameObject cube;

    private Material mat;

    public bool initYet = false;
    Camera cam;

    float timePass = 0;

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
        //temp1 = createTexture();
        //temp2 = createTexture();

        cam = GetComponent<Camera>();

        var mr = cube.GetComponent<MeshRenderer>();
        mat = mr.material;

        //temp1.generateMips = false;
        //temp1.useMipMap = false;
        //temp2.generateMips = false;
        //temp2.useMipMap = false;
    }

    [ButtonCallFunc()]
    public bool SetTex;

    public void SetTexMethod() {
        cam.targetTexture = temp2;
        mat.mainTexture = temp1;
    }

    [ButtonCallFunc()]
    public bool SwitchTex;
    public void SwitchTexMethod() {
        var temp = temp1;
        temp1 = temp2;
        temp2 = temp;
        SetTexMethod();
    }

    private bool isFast =false;

    [ButtonCallFunc()]
    public bool FastAnim;
    public void FastAnimMethod() {
        isFast = !isFast;
    }

    [ButtonCallFunc()]
    public bool ShowAnim;
    public void ShowAnimMethod() {
        mat.SetFloat("inInit", 1);
    }
	
	// Update is called once per frame
	void Update () {
        if(isFast) {
            SwitchTexMethod();
        }

        /*
        if(initYet) {

            timePass += Time.deltaTime;
            if(timePass > 1) {
                timePass -= 1;

                var temp = temp1;
                temp1 = temp2;
                temp2 = temp;

                cam.targetTexture = temp1;  
                mat.mainTexture = temp1;

                mat.SetFloat("doAnim", 1);
                //initYet = false;

                mat.SetFloat("inInit", 1);
            }else {
                mat.SetFloat("doAnim", 0);
            }
        }else {
            timePass = 0;
            mat.SetFloat("inInit", 0);
            mat.SetFloat("doAnim", 0);
        }
        */
	}
}
