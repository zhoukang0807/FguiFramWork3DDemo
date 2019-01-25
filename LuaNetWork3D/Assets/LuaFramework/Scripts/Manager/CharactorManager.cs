using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharactorManager : Manager
{
    private CharacterController m_CharacterController;
    // Use this for initialization
    void Start () {
        m_CharacterController = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        LuaManager.CallFunction("GameCtrl.FixedUpdate");
    }
    private void OnCollisionEnter2D(Collision2D collision)
    {
        LuaManager.CallFunction("GameCtrl.OnCollisionEnter2D", collision);
    }
    private void OnControllerColliderHit(ControllerColliderHit hit)
    {
        Rigidbody body = hit.collider.attachedRigidbody;
        //dont move the rigidbody if the character is on top of it 

        if (body == null || body.isKinematic)
        {
            return;
        }
        body.AddForceAtPosition(m_CharacterController.velocity * 0.1f, hit.point, ForceMode.Impulse);
    }
}
