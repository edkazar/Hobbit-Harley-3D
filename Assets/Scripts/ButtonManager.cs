using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButtonManager : MonoBehaviour
{
    [SerializeField]
    private GameObject welcomeElements;

    [SerializeField]
    private GameObject finalElements;

    [SerializeField]
    Transform playerTransform;

    private Transform lastWayPoint;

    private UITaskController myUIController;

    // Start is called before the first frame update
    void Start()
    {
        welcomeElements.SetActive(true);
        finalElements.SetActive(false);
        Time.timeScale = 0f;

        lastWayPoint = GameObject.Find("WayPoint6").transform;

        GameObject UIController = GameObject.Find("UI_Checklist");
        myUIController = UIController.GetComponent<UITaskController>();
    }

    // Update is called once per frame
    void Update()
    {
        if (playerTransform.position == lastWayPoint.position)
        {
            finalElements.SetActive(true);
            myUIController.hideObjectives();
            Time.timeScale = 0f; 
        }
    }

    public void startExperience()
    {
        welcomeElements.SetActive(false);
        Time.timeScale = 1f;
    }

    public void endExperience()
    {
        Application.Quit();
    }
}
