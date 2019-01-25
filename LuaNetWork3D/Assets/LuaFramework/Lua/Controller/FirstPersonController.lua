require "Common/define"
require "FairyGUI"
require "3rd/pblua/MoveDTO_pb"
require "3rd/pblua/test_pb"
require "3rd/pbc/protobuf"
FirstPersonController = {}
local this = FirstPersonController

local m_IsWalking = true
local m_WalkSpeed = 5
local m_RunSpeed = 10
local m_RunstepLenghten
local m_JumpSpeed = 10
local m_StickToGroundForce = 0
local m_GravityMultiplier = 2
local m_MouseLook = MouseLook.New()
local m_UseFovKick = true
local m_FovKick = FOVKick.New()
local m_HeadBob = CurveControlledBob.New()
local m_JumpBob = LerpControlledBob.New()
local m_StepInterval = 5
local m_FootstepSounds
local m_JumpSound
local m_LandSound

local m_Camera
local m_Jump = false
local m_YRotation
local m_Input = Vector2.New()
local m_MoveDir = Vector3.zero
local m_CharacterController
local m_CollisionFlags = CollisionFlags
local m_PreviouslyGrounded = false
local m_OriginalCameraPosition
local m_StepCycle
local m_NextStep
local m_Jumping = false
local m_AudioSource
local animator
local gamemodal
local windex = 0
local transform
local ismobile = false
local runable= false;
local isrun= false;
--构建函数--
function FirstPersonController.New(mobile)
    logWarn("FirstPersonController.New--->>")
    ismobile = mobile
    return this
end
--构建函数--
function FirstPersonController.Start(obj)
    transform = obj.transform
    m_CharacterController = obj:GetComponent("CharacterController")
    gamemodal = obj.transform:Find("modal").gameObject
    m_Camera = Camera.main
    m_OriginalCameraPosition = m_Camera.transform.localPosition
    m_FovKick:Setup(m_Camera)
    m_HeadBob:Setup(m_Camera, m_StepInterval)
    m_StepCycle = 0
    m_NextStep = m_StepCycle / 2
    m_Jumping = false
    m_AudioSource = obj:GetComponent("AudioSource")
    m_MouseLook:Init(obj.transform, m_Camera.transform)
    animator = obj:GetComponent("Animator")
end

function FirstPersonController.Update()
    this.RotateView()
    if (m_Jump ~= true) then
        m_Jump = Input.GetButtonDown("Jump")
    end
    if (m_PreviouslyGrounded ~= true and m_CharacterController.isGrounded) then
        --StartCoroutine(m_JumpBob.DoBobCycle());
        coroutine.start(this.DoBobCyclecoroutine)
        --this.PlayLandingSound();
        m_MoveDir.y = 0
        m_Jumping = false
    end
    if (m_CharacterController.isGrounded ~= true and m_Jumping ~= true and m_PreviouslyGrounded) then
        m_MoveDir.y = 0
    end
    animator:SetBool("jump", m_Jumping)
    m_PreviouslyGrounded = m_CharacterController.isGrounded
end
function FirstPersonController.DoBobCyclecoroutine()
    m_JumpBob:DoBobCycle()
end

function FirstPersonController.PlayLandingSound()
    m_AudioSource.clip = m_LandSound
    m_AudioSource:Play()
    m_NextStep = m_StepCycle + 0.5
end

function FirstPersonController.FixedUpdate(info)
    LogingCtrl.runable = runable;
    LogingCtrl.windex = windex;
    LogingCtrl.isrun = isrun;
    LogingCtrl.m_Jumping = m_Jumping;
    local speed = 0
    speed = this.GetInput(speed)
    local desiredMove = transform.forward * m_Input.y + transform.right * m_Input.x

    local hitInfo = info
    -- Physics.SphereCast(transform.position, m_CharacterController.radius, Vector3.down, hitInfo,m_CharacterController.height / 2, Physics.AllLayers, QueryTriggerInteraction.Ignore);
    desiredMove = Vector3.ProjectOnPlane(desiredMove, hitInfo.normal).normalized --hitInfo.normal

    m_MoveDir.x = desiredMove.x * speed
    m_MoveDir.z = desiredMove.z * speed

    if (m_Input.x == 0 and m_Input.y >= 0) then
        windex = 0
    end
    if (m_Input.x > 0) then
        windex = 3
    end
    if (m_Input.x < 0) then
        windex = 2
    end
    if (m_Input.y < 0) then
        windex = 1
    end
    animator:SetFloat("windex", windex)

    if (m_Input.x ~= 0 or m_Input.y ~= 0) then
        animator:SetBool("runable", true)
        runable = true;
        isrun = m_IsWalking ~= true;
        animator:SetBool("isrun", m_IsWalking ~= true)
    else
        runable = false;
        isrun = false;
        animator:SetBool("runable", false)
        animator:SetBool("isrun", false)
    end
    if (m_CharacterController.isGrounded) then
        m_MoveDir.y = -m_StickToGroundForce

        if (m_Jump) then
            m_MoveDir.y = m_JumpSpeed
            --this.PlayJumpSound();
            m_Jump = false
            m_Jumping = true
        end
    else
        m_MoveDir = m_MoveDir + Physics.gravity * m_GravityMultiplier * Time.fixedDeltaTime
    end
    m_CollisionFlags = m_CharacterController:Move(m_MoveDir * Time.fixedDeltaTime)

    --this.ProgressStepCycle(speed);

    m_MouseLook:UpdateCursorLock()
end
function FirstPersonController.PlayJumpSound()
    m_AudioSource.clip = m_JumpSound
    m_AudioSource.Play()
end
function FirstPersonController.ProgressStepCycle(speed)
    if (m_CharacterController.velocity.sqrMagnitude > 0 and (m_Input.x ~= 0 or m_Input.y ~= 0)) then
        m_StepCycle =
            m_StepCycle +
            (m_CharacterController.velocity.magnitude + (speed * (m_IsWalking and 1 or m_RunstepLenghten))) *
                Time.fixedDeltaTime
    end

    if ((m_StepCycle > m_NextStep) ~= true) then
        return
    end

    m_NextStep = m_StepCycle + m_StepInterval

    --this.PlayFootStepAudio();
end

function FirstPersonController.PlayFootStepAudio()
    if (m_CharacterController.isGrounded ~= true) then
        return
    end
    local n = Random.Range(1, m_FootstepSounds.Length)
    m_AudioSource.clip = m_FootstepSounds[n]
    m_AudioSource.PlayOneShot(m_AudioSource.clip)
    m_FootstepSounds[n] = m_FootstepSounds[0]
    m_FootstepSounds[0] = m_AudioSource.clip
end

function FirstPersonController.GetInput(speed)
    local horizontal = Input.GetAxis("Horizontal")
    local vertical = Input.GetAxis("Vertical")
    local waswalking = m_IsWalking
    if ismobile ~= true then
        m_IsWalking = (Input.GetKey(KeyCode.LeftShift) ~= true)
    end

    speed = m_IsWalking and m_WalkSpeed or m_RunSpeed
    m_Input = Vector2.New(horizontal, vertical)

    if (m_Input.sqrMagnitude > 1) then
        m_Input:Normalize()
    end

    if (m_IsWalking ~= waswalking and m_UseFovKick and m_CharacterController.velocity.sqrMagnitude > 0) then
        --    StopAllCoroutines();
        --    coroutine.start(m_IsWalking~=true and m_FovKick.FOVKickUp() or m_FovKick.FOVKickDown());
        --     StartCoroutine(m_IsWalking~=true and m_FovKick.FOVKickUp() or m_FovKick.FOVKickDown());
        coroutine.start(this.FOVKickCoroutine)
    end
    return speed
end
function FirstPersonController.FOVKickCoroutine()
    if m_IsWalking ~= true then
        m_FovKick:FOVKickUp()
    else
        m_FovKick:FOVKickDown()
    end
end

function FirstPersonController.RotateView()
    m_MouseLook:LookRotation(transform, m_Camera.transform)
end

function FirstPersonController.OnControllerColliderHit(hit)
    local body = hit.collider.attachedRigidbody
    if (m_CollisionFlags == CollisionFlags.Below) then
        return
    end

    if (body == null or body.isKinematic) then
        return
    end
    body.AddForceAtPosition(m_CharacterController.velocity * 0.1, hit.point, ForceMode.Impulse)
end
