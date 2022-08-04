using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UITaskController : MonoBehaviour
{
    private List<GameObject> objectives;
    private List<Image> completeImages;
    private List<GameObject> completedUIs;

    private int activeCounter;
    private int completeImagesCounter;
    private int objectivesCounter;

    public bool ongoingTest = false;

    AudioSource audioData;

    // Start is called before the first frame update
    void Start()
    {
        loadUI();
        hideUI();

        activeCounter = 0;
        completeImagesCounter = 0;
        objectivesCounter = 0;

        audioData = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void loadUI()
    {
        objectives = new List<GameObject>();
        completeImages = new List<Image>();
        completedUIs = new List<GameObject>();

        for (int i = 0; i < this.transform.childCount; i++)
        {
            if (i > 0)
            {  
                Transform child = this.transform.GetChild(i);
                if (i == 1)
                {            
                    for (int j = 0; j < child.childCount; j++)
                    {
                        Transform grandchild = child.transform.GetChild(j);
                        completeImages.Add(grandchild.gameObject.GetComponent<Image>());

                        for (int k = 0; k < grandchild.childCount; k++)
                        {
                            completedUIs.Add(grandchild.GetChild(k).gameObject);
                        }
                    }
                }
                else
                {
                    objectives.Add(child.gameObject);
                }
            }
        }
    }

    void hideUI()
    {
        for(int i = 0; i < completedUIs.Count; i++)
        {
            completedUIs[i].SetActive(false);
        }

        for (int i = 0; i < objectives.Count; i++)
        {
            objectives[i].SetActive(false);
        }

        for (int i = 0; i < completeImages.Count; i++)
        {
            completeImages[i].enabled = false;
        }
    }

    public void unhideCompleted()
    {
        completedUIs[activeCounter].SetActive(true);
        audioData.PlayDelayed(0);

        if (activeCounter == 2 || activeCounter == 5 || activeCounter == 9)
        {
            completeImages[completeImagesCounter].enabled = true;
            completeImagesCounter++;
        }

        activeCounter++;
    }

    public void showObjectives()
    {
        hideObjectives();

        objectives[objectivesCounter].SetActive(true);
        objectivesCounter++;
    }

    public void hideObjectives()
    {
        for (int i = 0; i < objectives.Count; i++)
        {
            objectives[i].SetActive(false);
        }
    }
}
