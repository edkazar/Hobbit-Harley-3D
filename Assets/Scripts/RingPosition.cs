using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RingPosition : MonoBehaviour
{
    [SerializeField] private Transform myPos;
    [SerializeField] Transform camera;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        transform.position = myPos.position + new Vector3(-0.50f, 0.705f, -0.75f);
        transform.forward = new Vector3(camera.forward.x, transform.forward.y, camera.forward.z);
    }
}
