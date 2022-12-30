#!/usr/bin/python
# -*- coding: utf-8 -*-

from ...common.traces import Trace
from .CW305 import CW305, CW305_USB
import numpy as np

from chipwhisperer.logging import *

class CW305_ML(CW305):

     _name = "ChipWhisperer CW305 (Artix-7)"

     def __init__(self):
        import chipwhisperer as cw
        self.REG_NN_INPUTS = 0
        self.REG_NN_WEIGHTS = 0
        self.REG_NN_BIAS = 0
        self.REG_NN_RES = 0

        super().init()
        self.default_verilog_defines = 'cw305_ml_defines.v'
        self.default_verilog_defines_full_path = os.path.dirname(cw.__file__)+ '/../../hardware/victims/cw305_artixtarget/fpga/ml/hdl/' + self.default_verilog_defines
        self.registers = 12 # number of registers we expect to find
        self.bytecount_size = 4 # pBYTECNT_SIZE in Verilog
        self.target_name =  'Neural Network Infrastructure for FPGA Accelerators'


    def capture_trace(self, scope, operation="weight"):
        
        scope.arm()
        if scope._is_husky:
            start_cycles = 0
        else: 
            start_cycles = scope.adc.trig_count

        if operation == 'weight':
            textout = self.run_ml_evaluator()
        else:
            target_logger.error("Please supply a valid operation to run.")
        textin = {'operation': operation}
        ret = scope.capture()    
        cycles = scope.adc.trig_count - start_cycles
        if ret:
            target_logger.warning("Timeout happened during capture")
            return None
        wave = scope.get_last_trace()
            
        if len(wave) >= 1:
            return Trace(wave, textin, textout, None)
        else: 
            return None


    def run_ml_evaluator(self):
        tr_res = []
        print("CW305_ML: Running evaluator")
        for i in range(0, 2**self.bytecount_size)
            self.fpga_write(self.REG_NN_INPUTS, bytes(bin(i), 'utf-8'))
            sleep(0.05)
            print("CW305_ML: Writing to REG_NN_INPUTS (%s)", bytes(bin(i), 'utf-8'))
            res = self.fpga_read(self.REG_NN_RES, 1)
            print("CW305_ML: Reading from REG_NN_RES (%s)", res)
            sleep(0.05)
            tr_res.append(res)
        return {tr_res}

    def pearsonCoeff(X, Y):
        return cov(X, Y) / (std_dev(X) * std_dev(Y) )

    def mean(X):
        return np.sum(X, axis=0)/len(X)
    
    def std_dev(X, X_bar=mean(X)):
        return np.sqrt(np.sum((X-X_bar)**2, axis=0))

    def cov(X, Y, X_bar=mean(X), Y_bar=mean(Y)):
        return np.sum((X-X_bar)*(Y-Y_bar), axis=0) 