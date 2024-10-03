@echo off
REM ****************************************************************************
REM Vivado (TM) v2024.1.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : AMD Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Thu Oct 03 15:36:39 +0530 2024
REM SW Build 5094488 on Fri Jun 14 08:59:21 MDT 2024
REM
REM Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
REM Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim adder_float_tb_1_behav -key {Behavioral:sim_1:Functional:adder_float_tb_1} -tclbatch adder_float_tb_1.tcl -log simulate.log"
call xsim  adder_float_tb_1_behav -key {Behavioral:sim_1:Functional:adder_float_tb_1} -tclbatch adder_float_tb_1.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
