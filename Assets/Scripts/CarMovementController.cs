using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarMovementController : MonoBehaviour
{
    [SerializeField]
    private Transform carTransform;

    private CarSpeedController mySpeedController;
    private TestControllerManager myTestManager;

    [SerializeField] private int carResetDistance;

    private GameObject movementController;

    private const int slowMovementID = 0;
    private const int stopMovementID = 1;

    private Vector3 initialPos;

    // Start is called before the first frame update
    void Start()
    {
        initialPos = carTransform.position;

        movementController = GameObject.Find("MovementController");
        GameObject speedController = GameObject.Find("CarMovementController");
        mySpeedController = speedController.GetComponent<CarSpeedController>();

        mySpeedController.resetSpeed(movementController.GetComponent<MovementControllerScript>().hasCrossed);
    }

    // Update is called once per frame
    void Update()
    {
        carTransform.position = carTransform.position - new Vector3(0, 0, mySpeedController.currentMovementSpeed * Time.deltaTime/2);
        resetPosition();

        if(mySpeedController.justCrossed)
        {
            checkCarPosition();
            if (mySpeedController.crossCounter <= 2)
            {
                mySpeedController.crossCounter += 1;
            }
            else
            {
                mySpeedController.justCrossed = false;
            }
        }
    }

    void OnMouseOver()
    {
        //If your mouse hovers over the GameObject with the script attached, output this message
        mySpeedController.changeMovementspeed(slowMovementID);
    }

    void OnMouseExit()
    {
        //If your mouse hovers over the GameObject with the script attached, output this message
        mySpeedController.changeMovementspeed(-1);
    }

    void checkCarPosition()
    {
        if (carTransform.position.z < 50 || carTransform.position.z > 100)
        {
            carTransform.position = carTransform.position + new Vector3(0.0f, -30.0f, 0.0f);
        }
    }

    void resetPosition()
    {
        float distanceZ = Mathf.Abs(initialPos.z - carTransform.position.z);

        if (distanceZ >= carResetDistance)
        {
            carTransform.position = initialPos;
            if (movementController.GetComponent<MovementControllerScript>().hasCrossed)
            {
                carTransform.position = carTransform.position + new Vector3(0.0f, -30.0f, 0.0f);
            }
        }


    }
}
