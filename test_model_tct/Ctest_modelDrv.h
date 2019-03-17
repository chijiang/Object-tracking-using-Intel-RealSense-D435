﻿// ****************** Ctest_modelDrv.h *******************************
// Generated by TwinCAT Target for MATLAB/Simulink (TE1400)
// MATLAB R2018b (win64)
// TwinCAT 3.1.4022
// TwinCAT Target 1.2.1235
// Beckhoff Automation GmbH & Co. KG     (www.beckhoff.com)
// *************************************************************
#ifndef CTEST_MODELDRV_H_INCLUDED
#define CTEST_MODELDRV_H_INCLUDED

#include "TcPch.h"

#define test_modelDRV_NAME			"test_model"
#define test_modelDRV_Major			1
#define test_modelDRV_Minor			0

#if defined DEVICE_MAIN		// is supposed to be __cplusplus

#define DEVICE_CLASS			Ctest_modelDrv

#include "ObjDriver.h"

class Ctest_modelDrv : public CObjDriver
{
public:
	virtual IOSTATUS	OnLoad( );
	virtual VOID		OnUnLoad( );
	
  //////////////////////////////////////////////////////
  // VxD-Services exported by this driver
  static unsigned long _cdecl test_model_GetVersion( );
};

#endif	// #if defined DEVICE_MAIN

Begin_VxD_Service_Table( test_modelDRV)
	VxD_Service( test_model_GetVersion		)
End_VxD_Service_Table


#endif