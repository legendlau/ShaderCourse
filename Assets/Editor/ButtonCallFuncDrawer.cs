using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Reflection;

[CustomPropertyDrawer(typeof(ButtonCallFunc))] 
public class ButtonCallFuncDrawer : PropertyDrawer{
    const int butHeight = 16;
    const int pad = 5;

    ButtonCallFunc cutsceneAttribute {
        get {
            return (ButtonCallFunc) attribute;
        }
    }
    public override float GetPropertyHeight(SerializedProperty prop, GUIContent label) {
        return base.GetPropertyHeight (prop, label)+pad;
    }
    public override void OnGUI(Rect position, SerializedProperty prop, GUIContent label) {
        //Rect textFieldPosition = position;
        //textFieldPosition.height = butHeight;
        //cutsceneAttribute.dialog = EditorGUI.TextField (textFieldPosition, new GUIContent(label), cutsceneAttribute.dialog);

        Rect butPosition = position;
        //butPosition.y += butHeight;
        //butPosition.height = butHeight;

        if (GUI.Button (butPosition, prop.propertyPath)) {
            var cs =  prop.serializedObject.targetObject;
            MethodInfo mi = cs.GetType().GetMethod(prop.propertyPath+"Method");
            //object[] paramsArr = new object[]{cutsceneAttribute.dialog};
            mi.Invoke(cs, null);
        }
    }
}
