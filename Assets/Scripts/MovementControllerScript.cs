using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementControllerScript : MonoBehaviour
{
    [SerializeField] Transform playerTransform;

    [SerializeField] float movementSpeed = 3.0f;

    private int currentTargetPos;

    private List<Transform> WayPoints;

    public bool hasCrossed = false;
    public bool fulfilledTest = false;
    public bool startTest = false;

    private UITaskController myUIController;

    private bool experienceDone = false;

    // Start is called before the first frame update
    void Start()
    {
        WayPoints = new List<Transform>();
        WayPoints.Add(GameObject.Find("WayPoint2").transform);
        WayPoints.Add(GameObject.Find("WayPoint3").transform);
        WayPoints.Add(GameObject.Find("WayPoint4").transform);
        WayPoints.Add(GameObject.Find("WayPoint5").transform);
        WayPoints.Add(GameObject.Find("WayPoint6").transform);

        currentTargetPos = 0;

        GameObject UIController = GameObject.Find("UI_Checklist");
        myUIController = UIController.GetComponent<UITaskController>();
    }

    // Update is called once per frame
    void Update()
    {
        playerTransform.position = Vector3.MoveTowards(playerTransform.position, WayPoints[currentTargetPos].position, movementSpeed * Time.deltaTime);

        updateTargetPosition();
    }

    void updateTargetPosition()
    {
        if (playerTransform.position == WayPoints[currentTargetPos].position)
        {
            if (fulfilledTest)
            {
                if (currentTargetPos < WayPoints.Count - 1)
                {
                    currentTargetPos++;
                    fulfilledTest = false;
                }
            }
            else
            {
                startTest = true;
                if (!myUIController.ongoingTest && currentTargetPos != 2 && currentTargetPos < 4)
                {
                    myUIController.showObjectives();
                    myUIController.ongoingTest = true;
                }
            }
        }

        if (playerTransform.position == WayPoints[4].position)
        {
            experienceDone = true;
        }
    }

    public void setStartTestFalse()
    {
        startTest = false;
        fulfilledTest = true;
        myUIController.ongoingTest = false;
    }

    public int getWaypointsLength()
    {
        return WayPoints.Count;
    }

    public bool getExperienceDone()
    {
        return experienceDone;
    }
}
