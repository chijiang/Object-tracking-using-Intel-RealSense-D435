﻿// ****************** Ctest_model.cpp *******************************
// Generated by TwinCAT Target for MATLAB/Simulink (TE1400)
// MATLAB R2018b (win64)
// TwinCAT 3.1.4022
// TwinCAT Target 1.2.1235
// Beckhoff Automation GmbH & Co. KG     (www.beckhoff.com)
// *************************************************************

#include "TcPch.h"
#pragma hdrstop  

#include "AdsLog.h"
#include "TcStructuredExceptionHandling.h"
#include "Ctest_model.h"
#include "test_model_private.h"
#include "TcIoServices.h"
#include "TcServices.h"

///////////////////////////////////////////////////////////////////////////////
// Check TcMatSim.h version
///////////////////////////////////////////////////////////////////////////////
#if TC_VER<301
#error "The code, generated by TE1400 version 1.2, is incompatible with the SDK of TwinCAT 3.0. Please use a TwinCAT version >= 3.1 or a TE1400 version <= 1.1."
#endif
#if !defined TC_MATSIM_HEADER_VERSION || TC_MATSIM_HEADER_VERSION < 1200
#error "The included version of TcMatSim.h is out of date. Please update the TE1400 components of the TwinCAT SDK."
#endif

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////
#ifdef _DEBUG
#define new DEBUG_NEW
#endif
DEFINE_THIS_FILE()

///////////////////////////////////////////////////////////////////////////////
// External global variables
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// External global functions
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Ctest_model
///////////////////////////////////////////////////////////////////////////////
// Constructor
Ctest_model::Ctest_model() : CTcMatSimModuleBase(1,NUMST)
{
	_InstanceCnt++;
}

// Destructor
Ctest_model::~Ctest_model()
{
	_InstanceCnt--;
}

// Instance counter
///////////////////////////////////////////////////////////////////////////////
int Ctest_model::GetInstanceCnt(){
	return _InstanceCnt;
}
int Ctest_model::_InstanceCnt = 0;

///////////////////////////////////////////////////////////////////////////////
// Provided interfaces map
BEGIN_INTERFACE_MAP(Ctest_model)
	INTERFACE_ENTRY_ITCOMOBJECT()
    INTERFACE_ENTRY(IID_ITcCyclic, ITcCyclic)
    INTERFACE_ENTRY(IID_ITcPostCyclic, ITcPostCyclic)
    INTERFACE_ENTRY(IID_ITcADI,ITcADI)
    INTERFACE_ENTRY(IID_ITcWatchSource, ITcWatchSource)
END_INTERFACE_MAP()


///////////////////////////////////////////////////////////////////////////////
// State Transitions 
///////////////////////////////////////////////////////////////////////////////
// Init -> PreOp
HRESULT Ctest_model::SetObjStateIP(ITComObjectServer* ipSrv,PTComInitDataHdr pInitData){
	// Preinitialize base class members
	// Mapping between context id and Simulink task id
	m_ContextInfoArr[0].SimulinkTid = 1;

	// Preinitialize parameters



	// Preinitialize other members
	InitMembers();
	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// PreOp -> Init
HRESULT Ctest_model::SetObjStatePI(){
	return S_OK;
}






///////////////////////////////////////////////////////////////////////////////
// PreOp -> SaveOp
HRESULT Ctest_model::SetObjStatePS(PTComInitDataHdr pInitData)
{
	HRESULT hr = S_OK;

	

	m_MdlInitialized = false;



	// (Re)Initialize members
	InitMembers();

	// (Re)Initialize model
	if (SUCCEEDED(hr))
		TcMatSimTryExeptCodeHr(test_model();,hr,"test_model()");
	if (SUCCEEDED(hr))
		TcMatSimTryExeptCodeHr(MdlInitializeSizes();,hr,"MdlInitializeSizes()");
	if (SUCCEEDED(hr))
		TcMatSimTryExeptCodeHr(MdlInitializeSampleTimes();,hr,"MdlInitializeSampleTimes()");
	
	if (SUCCEEDED(hr))
		hr = CheckAndAdaptCycleTimes();


	if (SUCCEEDED(hr))
		TcMatSimTryExeptCodeHr(MdlStart();,hr,"MdlStart()");
	if (SUCCEEDED(hr))
		m_MdlInitialized = true;
	if (FAILED(hr) && m_MdlInitialized){
		TcMatSimTryExeptCode(MdlTerminate();,"MdlTerminate()");
		m_MdlInitialized = false;
	}

	return hr;
}

///////////////////////////////////////////////////////////////////////////////
// SaveOp -> PreOp
HRESULT Ctest_model::SetObjStateSP()
{
	HRESULT hr = S_OK;

	if (m_MdlInitialized){
		TcMatSimTryExeptCode(MdlTerminate();,"MdlTerminate()");
		m_MdlInitialized = false;
	}





	return hr;
}

///////////////////////////////////////////////////////////////////////////////
// SaveOp -> Op
HRESULT Ctest_model::SetObjStateSO() {
	HRESULT hr = S_OK;
	return hr;
}

///////////////////////////////////////////////////////////////////////////////
// Op -> SaveOp
HRESULT Ctest_model::SetObjStateOS() {
	HRESULT hr = WaitOnTasks();
	return hr;
}

///////////////////////////////////////////////////////////////////////////////
// Interface ITcCyclic: Cyclic execution
///////////////////////////////////////////////////////////////////////////////
HRESULT Ctest_model::CycleUpdate(ITcTask* ipTask, ITcUnknown* ipCaller, ULONG_PTR context)
{
	HRESULT hr = S_OK;
	TCMATSIM_FPUCTRL_INIT
	TcTry{
		if (SUCCEEDED(hr))
			hr = VerifyCaller(ipTask, context);
		if (SUCCEEDED(hr))
			hr = GetLastMdlErrorStatus();
	
		if (SUCCEEDED(hr)){
			m_ContextInfoArr[context].ExecutingCyclicCall = true;

			switch(m_ExecutionSequence){
			case ExecutionSequence_IoAtTaskBegin:
				break;
			case ExecutionSequence_StateUpdateAfterOutputMapping:
				MdlOutputs(m_ContextInfoArr[context].SimulinkTid);
				break;
			case ExecutionSequence_StateUpdateBeforeOutputUpdate:
				MdlUpdate(m_ContextInfoArr[context].SimulinkTid);
				MdlOutputs(m_ContextInfoArr[context].SimulinkTid);
				break;
			}
			m_CycleUpdateExecuted = true;
		}
	
	

		if (SUCCEEDED(hr))
			hr = EvalMdlErrorStatus(rtmGetErrorStatus((&m_SimStruct)));
	}
	TcFinally{
		TCMATSIM_FPUCTRL_RESTORE
		m_ContextInfoArr[context].ExecutingCyclicCall = false;
	}
	return hr;
}

///////////////////////////////////////////////////////////////////////////////
// Interface ITcPostCyclic: Cyclic execution (post output update)
///////////////////////////////////////////////////////////////////////////////
HRESULT Ctest_model::PostCyclicUpdate(ITcTask* ipTask, ITcUnknown* ipCaller, ULONG_PTR context)
{
	HRESULT hr = S_OK;
	TCMATSIM_FPUCTRL_INIT
	TcTry{
		if (SUCCEEDED(hr))
			hr = VerifyCaller(ipTask, context);
		if (SUCCEEDED(hr))
			hr = GetLastMdlErrorStatus();
	
		if (SUCCEEDED(hr) && m_CycleUpdateExecuted){
			m_ContextInfoArr[context].ExecutingPostCyclicCall = true;
			switch(m_ExecutionSequence){
			case ExecutionSequence_IoAtTaskBegin:
				MdlUpdate(m_ContextInfoArr[context].SimulinkTid);
				MdlOutputs(m_ContextInfoArr[context].SimulinkTid);
				break;
			case ExecutionSequence_StateUpdateAfterOutputMapping:
				MdlUpdate(m_ContextInfoArr[context].SimulinkTid);
				break;
			case ExecutionSequence_StateUpdateBeforeOutputUpdate:
				break;
			}
		}

	
	

		if (SUCCEEDED(hr))
			hr = EvalMdlErrorStatus(rtmGetErrorStatus((&m_SimStruct)));
	}
	TcFinally{
		TCMATSIM_FPUCTRL_RESTORE
		m_ContextInfoArr[context].ExecutingPostCyclicCall = false;
	}
	return hr;
}


///////////////////////////////////////////////////////////////////////////////
// Maps of Parameters and DataAreas
///////////////////////////////////////////////////////////////////////////////
// Set parameters of Ctest_model
BEGIN_SETOBJPARA_MAP(Ctest_model)
	SETOBJPARA_DATAAREA_MAP();
	SETOBJPARA_VALUE(0x00000000,m_CallBy)
	SETOBJPARA_VALUE(0x00000001,m_ExecutionSequence)
	SETOBJPARA_VALUE(0x00000002,m_StepSize)
	SETOBJPARA_VALUE_DENIED(0x00000003,m_MdlInitialized)
	SETOBJPARA_VALUE_DENIED(0x00000004,m_CycleUpdateExecuted)
	SETOBJPARA_VALUE_DENIED(0x00000005,m_ModuleInfo)
	SETOBJPARA_VALUE_DENIED(0x00000006,m_ModuleBuildInfo)
	SETOBJPARA_VALUE(0x00000007,m_ExecuteModelCode)
	SETOBJPARA_VALUE_DENIED(0x00000008,rtmGetT((&m_SimStruct)))
END_SETOBJPARA_MAP2(CTcMatSimModuleBase)


///////////////////////////////////////////////////////////////////////////////
// Get parameters of Ctest_model
BEGIN_GETOBJPARA_MAP(Ctest_model)
	GETOBJPARA_DATAAREA_MAP();
	GETOBJPARA_VALUE(0x00000000,m_CallBy)
	GETOBJPARA_VALUE(0x00000001,m_ExecutionSequence)
	GETOBJPARA_VALUE(0x00000002,m_StepSize)
	GETOBJPARA_VALUE(0x00000003,m_MdlInitialized)
	GETOBJPARA_VALUE(0x00000004,m_CycleUpdateExecuted)
	GETOBJPARA_VALUE(0x00000005,m_ModuleInfo)
	GETOBJPARA_VALUE(0x00000006,m_ModuleBuildInfo)
	GETOBJPARA_VALUE(0x00000007,m_ExecuteModelCode)
	GETOBJPARA_VALUE_MATSIM_LOCK(0x00000008, rtmGetT((&m_SimStruct)), -1, TC_VARACCESS_MATSIM_STARTUP_OP(TC_VARACCESS_MATSIM_NONE,TC_VARACCESS_MATSIM_READ))
END_GETOBJPARA_MAP2(CTcMatSimModuleBase)


///////////////////////////////////////////////////////////////////////////////
// Get watch entries of Ctest_model
BEGIN_OBJPARAWATCH_MAP(Ctest_model)
	OBJPARAWATCH_DATAAREA_MAP();
	OBJPARAWATCH_VALUE(0x00000000,m_CallBy)
	OBJPARAWATCH_VALUE(0x00000001,m_ExecutionSequence)
	OBJPARAWATCH_VALUE(0x00000002,m_StepSize)
	OBJPARAWATCH_VALUE(0x00000003,m_MdlInitialized)
	OBJPARAWATCH_VALUE(0x00000004,m_CycleUpdateExecuted)
	OBJPARAWATCH_VALUE(0x00000005,m_ModuleInfo)
	OBJPARAWATCH_VALUE(0x00000006,m_ModuleBuildInfo)
	OBJPARAWATCH_VALUE(0x00000007,m_ExecuteModelCode)
	OBJPARAWATCH_VALUE(0x00000008,rtmGetT((&m_SimStruct)))
END_OBJPARAWATCH_MAP2(CTcMatSimModuleBase)


///////////////////////////////////////////////////////////////////////////////
// Get data area members of Ctest_model
BEGIN_OBJDATAAREA_MAP(Ctest_model)
	OBJDATAAREA_VALUE_FLAGS( 0, m_TcAdsSyncWrite, OBJDATAAREA_DISABLE_SET)
	OBJDATAAREA_VALUE_FLAGS( 1, m_BlockIO, OBJDATAAREA_DISABLE_SET)
	OBJDATAAREA_SPAN_PTR_SIZE_FLAGS( 2, 1, &(m_DWork.FromWorkspace_IWORK), 36, 0)
END_OBJDATAAREA_MAP()



///////////////////////////////////////////////////////////////////////////////
// ITcADI
///////////////////////////////////////////////////////////////////////////////
IMPLEMENT_ITCADI(Ctest_model)

///////////////////////////////////////////////////////////////////////////////
// ITcWatchSource
///////////////////////////////////////////////////////////////////////////////
IMPLEMENT_ITCWATCHSOURCE(Ctest_model)



///////////////////////////////////////////////////////////////////////////////
// Preinitialize members
///////////////////////////////////////////////////////////////////////////////
HRESULT Ctest_model::InitMembers(){
	memset(&m_CycleUpdateExecuted,0,sizeof(m_CycleUpdateExecuted));
	memset(&m_ModuleInfo,0,sizeof(m_ModuleInfo));
	memset(&m_ModuleBuildInfo,0,sizeof(m_ModuleBuildInfo));
	memset(&m_DWork,0,sizeof(m_DWork));
	memset(&m_SimStruct,0,sizeof(m_SimStruct));
	memset(&m_TcAdsSyncWrite,0,sizeof(m_TcAdsSyncWrite));
	memset(&m_BlockIO,0,sizeof(m_BlockIO));

	m_ModuleInfo.ClassId.Data1 = 0x3bbbbf53;
	m_ModuleInfo.ClassId.Data2 = 0x40ad;
	m_ModuleInfo.ClassId.Data3 = 0x420a;
	m_ModuleInfo.ClassId.Data4[0] = 0x83;
	m_ModuleInfo.ClassId.Data4[1] = 0x29;
	m_ModuleInfo.ClassId.Data4[2] = 0xa9;
	m_ModuleInfo.ClassId.Data4[3] = 0xa2;
	m_ModuleInfo.ClassId.Data4[4] = 0x32;
	m_ModuleInfo.ClassId.Data4[5] = 0x8b;
	m_ModuleInfo.ClassId.Data4[6] = 0xa0;
	m_ModuleInfo.ClassId.Data4[7] = 0xdd;
	m_ModuleInfo.BuildTimeStamp = 1552481826;
	m_ModuleInfo.ModelCheckSum[0] = 3335356357;
	m_ModuleInfo.ModelCheckSum[1] = 4265731611;
	m_ModuleInfo.ModelCheckSum[2] = 2655106586;
	m_ModuleInfo.ModelCheckSum[3] = 1855179228;
	m_ModuleInfo.ModelVersion[0] = 1;
	m_ModuleInfo.ModelVersion[1] = 3;
	m_ModuleInfo.ModelVersion[2] = 0;
	m_ModuleInfo.ModelVersion[3] = 0;
	m_ModuleInfo.TwinCatVersion[0] = 3;
	m_ModuleInfo.TwinCatVersion[1] = 1;
	m_ModuleInfo.TwinCatVersion[2] = 4022;
	m_ModuleInfo.TwinCatVersion[3] = 0;
	m_ModuleInfo.TcTargetVersion[0] = 1;
	m_ModuleInfo.TcTargetVersion[1] = 2;
	m_ModuleInfo.TcTargetVersion[2] = 1235;
	m_ModuleInfo.TcTargetVersion[3] = 0;
	m_ModuleInfo.MatlabVersion[0] = 9;
	m_ModuleInfo.MatlabVersion[1] = 5;
	m_ModuleInfo.MatlabVersion[2] = 0;
	m_ModuleInfo.MatlabVersion[3] = 0;
	m_ModuleInfo.SimulinkVersion[0] = 9;
	m_ModuleInfo.SimulinkVersion[1] = 2;
	m_ModuleInfo.SimulinkVersion[2] = 0;
	m_ModuleInfo.SimulinkVersion[3] = 0;
	m_ModuleInfo.CoderVersion[0] = 9;
	m_ModuleInfo.CoderVersion[1] = 0;
	m_ModuleInfo.CoderVersion[2] = 0;
	m_ModuleInfo.CoderVersion[3] = 0;
	m_ModuleInfo.TcTargetLicenseId.Data1 = 0x00000000;
	m_ModuleInfo.TcTargetLicenseId.Data2 = 0x0000;
	m_ModuleInfo.TcTargetLicenseId.Data3 = 0x0000;
	m_ModuleInfo.TcTargetLicenseId.Data4[0] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[1] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[2] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[3] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[4] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[5] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[6] = 0x00;
	m_ModuleInfo.TcTargetLicenseId.Data4[7] = 0x00;

#ifdef _DEBUG
	m_ModuleBuildInfo.Debug = true;
#else
	m_ModuleBuildInfo.Debug = false;
#endif

  return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// Check and adapt cycle times
///////////////////////////////////////////////////////////////////////////////
HRESULT Ctest_model::CheckAndAdaptCycleTimes(){
	double fCycleTimeMultiplier = 1;
	if (m_SimStruct.Timing.sampleTimes[0]==0)
		m_SimStruct.Timing.sampleTimes[0]=m_SimStruct.Timing.stepSize0;
	if (m_SimStruct.Timing.sampleTimes[1]==0)
		m_SimStruct.Timing.sampleTimes[1]=m_SimStruct.Timing.stepSize1;
	HRESULT hr = CheckCycleTimes(m_SimStruct.Timing.sampleTimes,fCycleTimeMultiplier);
	
	if (SUCCEEDED(hr)){
		if (m_StepSize==StepSize_UseTaskCycleTime && fCycleTimeMultiplier != 1){
			// adapt solver sample times
			m_SimStruct.solverInfo.fixedStepSize *= fCycleTimeMultiplier;
			m_SimStruct.Timing.stepSize *= fCycleTimeMultiplier;
			m_SimStruct.Timing.stepSize0 *= fCycleTimeMultiplier;
			m_SimStruct.Timing.stepSize1 *= fCycleTimeMultiplier;
			for (UINT sIdx=0;sIdx<NUMST;sIdx++){
				m_SimStruct.Timing.sampleTimesArray[sIdx] *= fCycleTimeMultiplier;
				m_SimStruct.Timing.offsetTimesArray[sIdx] *= fCycleTimeMultiplier;
			}
		}
	}
	
	return hr;
}
