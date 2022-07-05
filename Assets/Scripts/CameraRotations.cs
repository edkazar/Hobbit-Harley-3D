using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotations : MonoBehaviour
{
    [SerializeField] Camera myCamera;

    [SerializeField] private float sensitivity = 0.07f;

    [SerializeField] private Transform playerTransform;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void LateUpdate()
    {
        Vector3 vp = myCamera.ScreenToViewportPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, myCamera.nearClipPlane));
        vp.x -= 0.5f;
        vp.y -= 0.5f;
        vp.x *= sensitivity * Time.deltaTime * 10;
        vp.y *= sensitivity * Time.deltaTime * 10;
        vp.x += 0.5f;
        vp.y += 0.5f;
        Vector3 sp = myCamera.ViewportToScreenPoint(vp);

        Vector3 v = myCamera.ScreenToWorldPoint(sp);

        transform.LookAt(v, Vector3.up);

        //transform.LookAt(myCamera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, myCamera.nearClipPlane)), Vector3.up);
    }
}
