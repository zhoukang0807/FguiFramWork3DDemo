﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class FairyGUI_HitTestModeWrap
{
	public static void Register(LuaState L)
	{
		L.BeginEnum(typeof(FairyGUI.HitTestMode));
		L.RegVar("Default", get_Default, null);
		L.RegVar("Raycast", get_Raycast, null);
		L.RegFunction("IntToEnum", IntToEnum);
		L.EndEnum();
		TypeTraits<FairyGUI.HitTestMode>.Check = CheckType;
		StackTraits<FairyGUI.HitTestMode>.Push = Push;
	}

	static void Push(IntPtr L, FairyGUI.HitTestMode arg)
	{
		ToLua.Push(L, arg);
	}

	static bool CheckType(IntPtr L, int pos)
	{
		return TypeChecker.CheckEnumType(typeof(FairyGUI.HitTestMode), L, pos);
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Default(IntPtr L)
	{
		ToLua.Push(L, FairyGUI.HitTestMode.Default);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Raycast(IntPtr L)
	{
		ToLua.Push(L, FairyGUI.HitTestMode.Raycast);
		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int IntToEnum(IntPtr L)
	{
		int arg0 = (int)LuaDLL.lua_tonumber(L, 1);
		FairyGUI.HitTestMode o = (FairyGUI.HitTestMode)arg0;
		ToLua.Push(L, o);
		return 1;
	}
}
