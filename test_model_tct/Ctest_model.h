﻿// ****************** Ctest_model.h *******************************
// Generated by TwinCAT Target for MATLAB/Simulink (TE1400)
// MATLAB R2018b (win64)
// TwinCAT 3.1.4022
// TwinCAT Target 1.2.1235
// Beckhoff Automation GmbH & Co. KG     (www.beckhoff.com)
// *************************************************************

#pragma once

#include "rtwtypes.h"
#include "TcPch.h"
#include "TcMatSim.h"
#include "TcIoInterfaces.h"
#include "TcInterfaces.h"
#include "TcRtInterfaces.h"
#include "test_modelInterfaces.h"
#include "test_model.h"








typedef struct{
	CLSID ClassId;
	unsigned int BuildTimeStamp;
	unsigned int ModelCheckSum[4];
	unsigned int ModelVersion[4];
	unsigned int TwinCatVersion[4];
	unsigned int TcTargetVersion[4];
	unsigned int MatlabVersion[4];
	unsigned int SimulinkVersion[4];
	unsigned int CoderVersion[4];
	GUID TcTargetLicenseId;
} TctModuleInfoType;

typedef struct{
	bool Debug;
} TctModuleBuildInfoType;

typedef struct{
	double TCADSSyncWrite;
} test_model_TcAdsSyncWrite_Type;


typedef struct{
	int FromWorkspace_IWORK;
	int FromWorkspace1_IWORK;
	int FromWorkspace2_IWORK;
	int TCADSSyncWrite_IWORK[6];
} DW_test_model_T01;


///////////////////////////////////////////////////////////////////////////////
// Module class
///////////////////////////////////////////////////////////////////////////////
class Ctest_model:
  public ITcCyclic,
  public ITcPostCyclic,
  public ITcADI,
  public ITcWatchSource,
  public CTcMatSimModuleBase
{
public:
	DECLARE_IUNKNOWN()
	DECLARE_IPERSIST(CID_test_model)
	DECLARE_ITCOMOBJECT_SETSTATE()
	DECLARE_PARA();
	DECLARE_ITCOMOBJECT_LOCKOP_IMPL()

	Ctest_model();
	~Ctest_model();

	static int GetInstanceCnt();
	
	// ITcCyclic
	HRESULT TCOMAPI CycleUpdate(ITcTask* ipTask, ITcUnknown* ipCaller, ULONG_PTR context);

	// ITcPostCyclic
	HRESULT TCOMAPI PostCyclicUpdate(ITcTask* ipTask, ITcUnknown* ipCaller, ULONG_PTR context);

	// ITcADI
	DECLARE_ITCADI();

	// ITcWatchSource
	DECLARE_ITCWATCHSOURCE();
	
	// parameters and signals
	bool m_CycleUpdateExecuted;
	TctModuleInfoType m_ModuleInfo;
	TctModuleBuildInfoType m_ModuleBuildInfo;
	DW_test_model_T m_DWork;
	RT_MODEL_test_model_T m_SimStruct;
	test_model_TcAdsSyncWrite_Type m_TcAdsSyncWrite;
	B_test_model_T m_BlockIO;

	
private:

	// private methods
    DECLARE_OBJPARAWATCH_MAP();
    DECLARE_OBJDATAAREA_MAP();
	HRESULT InitMembers();
	HRESULT CheckAndAdaptCycleTimes();
	
	real_T rtGetInf (void);
	real32_T rtGetInfF (void);
	real_T rtGetMinusInf (void);
	real32_T rtGetMinusInfF (void);
	real_T rtGetNaN (void);
	real32_T rtGetNaNF (void);
	void rt_InitInfAndNaN (size_t realSize);
	boolean_T rtIsInf (real_T value);
	boolean_T rtIsInfF (real32_T value);
	boolean_T rtIsNaN (real_T value);
	boolean_T rtIsNaNF (real32_T value);
	void test_model_output (void);
	void test_model_update (void);
	void test_model_initialize (void);
	void test_model_terminate (void);
	void MdlOutputs (int_T tid);
	void MdlUpdate (int_T tid);
	void MdlInitializeSizes (void);
	void MdlInitializeSampleTimes (void);
	void MdlInitialize (void);
	void MdlStart (void);
	void MdlTerminate (void);
	RT_MODEL_test_model_T* test_model (void);


	// static members
	static int _InstanceCnt;

};