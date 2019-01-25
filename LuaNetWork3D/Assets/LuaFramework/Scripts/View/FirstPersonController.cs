using UnityEngine;
namespace LuaFramework
{
    public class FirstPersonController : Manager
    {
        private CharacterController m_CharacterController;
        // Use this for initialization
        private void Start()
        {
            m_CharacterController = GetComponent<CharacterController>();
            LuaManager.DoFile("Controller/FirstPersonController");
            if (Application.isMobilePlatform)
            {
                LuaManager.CallFunction("GameCtrl.New", true);
            }
            else
            {
                LuaManager.CallFunction("GameCtrl.New", false);
            }
            LuaManager.CallFunction("FirstPersonController.Start", gameObject);
        }

        private void Update()
        {
            LuaManager.CallFunction("FirstPersonController.Update", m_CharacterController);
        }

        private void FixedUpdate()
        {
            RaycastHit hitInfo;
            Physics.SphereCast(transform.position, m_CharacterController.radius, Vector3.down, out hitInfo,
                               m_CharacterController.height / 2f, Physics.AllLayers, QueryTriggerInteraction.Ignore);
            LuaManager.CallFunction("FirstPersonController.FixedUpdate", hitInfo);
        }

    }
}