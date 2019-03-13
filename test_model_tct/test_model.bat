set "VSCMD_START_DIR=%CD%"
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\VCVARSALL.BAT " amd64

call  "\\DESKTOP-V7H5BUD\D$\Program Files\MATLAB\R2018b\bin\win64\checkMATLABRootForDriveMap.exe" "\\DESKTOP-V7H5BUD\D$\Program Files\MATLAB\R2018b"  > mlEnv.txt
for /f %%a in (mlEnv.txt) do set "%%a"\n

cd .
nmake -f test_model.mk MATLAB_ROOT=%MATLAB_ROOT% ALT_MATLAB_ROOT=%ALT_MATLAB_ROOT% MATLAB_BIN=%MATLAB_BIN% ALT_MATLAB_BIN=%ALT_MATLAB_BIN%  MODELLIB=test_modellib.lib TCT_MODULENAME="$<MODELNAME>" TCT_PUBLISHMODULE=1 TCT_BUILD_PLATFORMTOOLSET="Auto" TCT_BUILD_PREFERX64TOOLSET="off" TCT_BUILD_CONFIGURATION="Release" TCT_BUILD_TWINCAT_RT_X86=1 TCT_BUILD_TWINCAT_UM_X86=0 TCT_BUILD_TWINCAT_RT_X64=1 TCT_BUILD_TWINCAT_UM_X64=0 TCT_BUILD_TWINCAT_CE7_X86="off" TCT_BUILD_TWINCAT_CE7_ARMV7="off" TCT_BUILD_TWINCAT_OS_X86="off" TCT_BUILD_TWINCAT_OS_X64="off" TCT_BUILD_TWINCAT_OS_ARMV7="off" TCT_BUILD_TWINCAT_OS_ARMV7T2="off" TCT_SupportTcAnalytics="on" TCT_LowestCompatibleTcBuild=4022 TCT_CodeGenPlaceholders="" TCT_MsBuildPublishProperties="" TCT_MsBuildProjProperties="" TCT_ModuleProperties="" TCT_PreCodeGenerationCallbackFcn="" TCT_PostCodeGenerationCallbackFcn="" TCT_PostPublishCallbackFcn="" TCT_SignCertWindowsLoaderX64="$(TWINCATTESTCERTIFICATE)" TCT_Access_Input=1 TCT_ADS_Input="ReadWrite_CreateSymbols" TCT_ProcImg_Input="Input-Destination DataArea" TCT_Properties_Input="" TCT_SymbolProperties_Input="" TCT_Access_Output=1 TCT_ADS_Output="ReadOnly_CreateSymbols" TCT_ProcImg_Output="Output-Source DataArea" TCT_Properties_Output="" TCT_SymbolProperties_Output="" TCT_Access_Parameter=1 TCT_ADS_Parameter="ReadWrite_CreateSymbols" TCT_ProcImg_Parameter="Internal DataArea" TCT_Properties_Parameter="" TCT_SymbolProperties_Parameter="" TCT_Access_BlockIO=1 TCT_ADS_BlockIO="ReadOnly_CreateSymbols" TCT_ProcImg_BlockIO="Internal DataArea" TCT_Properties_BlockIO="" TCT_SymbolProperties_BlockIO="" TCT_Access_ContState=1 TCT_ADS_ContState="ReadOnly_CreateSymbols" TCT_ProcImg_ContState="Internal DataArea" TCT_Properties_ContState="" TCT_SymbolProperties_ContState="" TCT_Access_DWork=1 TCT_ADS_DWork="ReadWrite_CreateSymbols" TCT_ProcImg_DWork="Internal DataArea" TCT_Properties_DWork="" TCT_SymbolProperties_DWork="" ExtMode=0 TCT_ExtModeRtExecCommands=0 TCT_ExtModeRtWaitForStartCommand=0 TCT_ExtModeRtAllowParameterChange=0 ExtModeMexFile="TctExtModeClient" TCT_TaskAssignmentMechanism="ManualConfig" TCT_TaskPriorityDefault=5 TCT_CallBy="CyclicTask" TCT_ExecutionSequence="StateUpdateAfterOutputMapping" TCT_StepSize="RequireMatchingTaskCycleTime" TCT_AutoStartModel=1 TCT_ExecutionTimeMonitoring=0 TCT_ModelInitStateTransition="PreOp->SafeOp" TCT_ModelStartStateTransition="Auto" TCT_DefaultInitSequence="PSO" TCT_ExportBlockDiagram=1 TCT_ResolveMaskedBlocks=0 TCT_UnrefBlockVarAccess_Input="Hide in block diagram" TCT_UnrefBlockVarAccess_Output="Hide in block diagram" TCT_UnrefBlockVarAccess_Parameter="Assign to parent block" TCT_UnrefBlockVarAccess_BlockIO="Assign to parent block" TCT_UnrefBlockVarAccess_ContState="Assign to parent block" TCT_UnrefBlockVarAccess_DWork="Hide in block diagram" TCT_IncludeBlockDiagramInTmc="off" TCT_ExportBlockDebugInfo=1 TCT_ShowParametersTable=1 TCT_UseOriginalInOutBlockNames=0 TCT_AddTestpointsAtScopeInputs=0 TCT_MaxVisibleArrayElements=200 TCT_HideTypesTmcFiles="$<TwinCat3Dir>\CustomConfig\Modules\$<CLASSFACTORYNAME>\$<CLASSFACTORYNAME>.tmc;$<BUILD_DIR>\$<CLASSFACTORYNAME>.tmc" TCT_SkipCallerVerification=0 TCT_PlcPousToGenerate="Module specific FB" TCT_OEMID="" TCT_OEMLicIDs="" COMBINE_OUTPUT_UPDATE_FCNS=0 INCLUDE_MDL_TERMINATE_FCN=1 MULTI_INSTANCE_CODE=0 MODELREF_TARGET_TYPE=NONE RELATIVE_PATH_TO_ANCHOR=.. ISPROTECTINGMODEL=NOTPROTECTING
@if errorlevel 1 goto error_exit
exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
An_error_occurred_during_the_call_to_make
