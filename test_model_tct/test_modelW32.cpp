﻿// ****************** test_modelW32.cpp *******************************
// Generated by TwinCAT Target for MATLAB/Simulink (TE1400)
// MATLAB R2018b (win64)
// TwinCAT 3.1.4022
// TwinCAT Target 1.2.1235
// Beckhoff Automation GmbH & Co. KG     (www.beckhoff.com)
// *************************************************************
#include "TcPch.h"
#pragma hdrstop

#include "TcPch.h"
#include "test_modelCtrl.h"
#include "TcSysW32_i.c"

CComModule _Module;

const   CLSID   IID_test_modelCtrl		=  {0x16902959,0x6dee,0x4d5c,{0x83,0xfe,0x6a,0xd2,0xa9,0x0a,0x23,0x6a}};
const   CLSID   LIBID_test_modelW32Lib	=  {0x16902959,0x6dee,0x4d5c,{0x83,0xfe,0x6a,0xd2,0xa9,0x0a,0x23,0x6a}};
const   CLSID   CLSID_test_modelCtrl   =  {0x16902959,0x6dee,0x4d5c,{0x83,0xfe,0x6a,0xd2,0xa9,0x0a,0x23,0x6a}};

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_test_modelCtrl, Ctest_modelCtrl)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HANDLE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
	if (dwReason == DLL_PROCESS_ATTACH)
	{
		_Module.Init(ObjectMap, (HINSTANCE)hInstance);
#ifndef UNDER_CE
		DisableThreadLibraryCalls((HINSTANCE)hInstance);
#endif
	}
	else if (dwReason == DLL_PROCESS_DETACH)
		_Module.Term();
	return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
	return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
	return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
	// registers object, typelib and all interfaces in typelib
	return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
	_Module.UnregisterServer();
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
STDAPI DllGetTcCtrl(ITcCtrl** ppCtrl)
{
	if ( ppCtrl == NULL )
		return E_POINTER;

	CComObject<Ctest_modelCtrl>* pCtest_modelCtrl = new CComObject<Ctest_modelCtrl>();
	if (pCtest_modelCtrl == NULL) return E_POINTER;
	return pCtest_modelCtrl->QueryInterface(IID_ITcCtrl, reinterpret_cast<void**>(ppCtrl));
}