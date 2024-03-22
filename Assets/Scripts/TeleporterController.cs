using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleporterController : MonoBehaviour
{
    private Material originalMaterial;
    [SerializeField] MovementControllerScript myMovementController;

    [SerializeField] Transform playerTransform;

    [SerializeField] private Material hoverMaterial;

    // Start is called before the first frame update
    void Start()
    {
        originalMaterial = GetComponent<MeshRenderer>().material;
        this.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnMouseDown()
    {
        Debug.Log("Teleport to:" + this.name);
        playerTransform.position = transform.position + new Vector3(0,1.5f,-0.3f);
    }

    private void OnMouseEnter()
    {
        GetComponent<MeshRenderer>().material = hoverMaterial;
    }

    private void OnMouseExit()
    {
        GetComponent<MeshRenderer>().material = originalMaterial;
    }
}
