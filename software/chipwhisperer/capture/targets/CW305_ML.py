
#!/usr/bin/python
# -*- coding: utf-8 -*-

from ...common.traces import Trace
from .CW305 import CW305, CW305_USB
import numpy as np
from ...hardware.naeusb.naeusb import NAEUSB,packuint32
from ...hardware.naeusb.fpga import FPGA
from ...hardware.naeusb.pll_cdce906 import PLLCDCE906
from datetime import datetime
import io
import os.path
import re

from chipwhisperer.logging import *

class CW305_USB(object):
    REQ_SYSCFG = 0x22
    REQ_VCCINT = 0x31
    SYSCFG_CLKOFF = 0x04
    SYSCFG_CLKON = 0x05
    SYSCFG_TOGGLE = 0x06
    VCCINT_XORKEY = 0xAE

class CW305_ML(CW305):

    _name = "ChipWhisperer CW305 (Artix-7)"

    def __init__(self):
        import chipwhisperer as cw
        
        # define register objects for linter satisfaction
        self.REG_NN_INPUTS = None
        self.REG_NN_WEIGHTS = None
        self.REG_NN_BIAS = None
        self.REG_NN_RES = None
        
        self._naeusb = NAEUSB()
        self.pll = PLLCDCE906(self._naeusb, ref_freq = 12.0E6)
        self.fpga = FPGA(self._naeusb)
        
        self.hw = None
        self.oa = None
        
        self._woffset_sam3U = 0x000
        self.default_verilog_defines = 'cw305_ml_defines.v'
        self.default_verilog_defines_full_path = os.path.dirname(cw.__file__)+ '/../../hardware/victims/cw305_artixtarget/fpga/ml/cw305_verilog_files/src/' + self.default_verilog_defines
        self.registers = 8 # number of registers we expect to find
        self.bytecount_size = 2 # pBYTECNT_SIZE in Verilog
        self.target_name =  'Binary Neural Network'

        

    def _getNAEUSB(self):
        return self._naeusb
    
    def slurp_defines(self, define_files=None):
        self.verilog_define_matches = 0
        defines_files = [self.default_verilog_defines_full_path]
        if (defines_files is None) or (type(defines_files) != list):
            raise ValueError('defines_files must be provided as a list (even if it contains a single element)')
        for i,defines_file in enumerate(defines_files):
            if type(defines_file) == io.BytesIO:
                defines = io.TextIOWrapper(defines_file)
            else:
                if not os.path.isfile(defines_file):
                    target_logger.error('Cannot find %s. Please specify the location of %s on your filesystem.' % 
                                   (defines_files, self.default_verilog_defines))
                defines = open(defines_file, 'r', encoding='utf-8')
            define_regex_base  =   re.compile(r'`define')
            define_regex_reg   =   re.compile(r'`define\s+?REG_')
            define_regex_radix =   re.compile(r'`define\s+?(\w+).+?\'([bdh])([0-9a-fA-F]+)')
            define_regex_noradix = re.compile(r'`define\s+?(\w+?)\s+?(\d+?)')
            block_offset = 0
            for define in defines:
                if define_regex_base.search(define):
                    reg = define_regex_reg.search(define)
                    match = define_regex_radix.search(define)
                    if match:
                        self.verilog_define_matches += 1
                        if match.group(2) == 'b':
                            radix = 2
                        elif match.group(2) == 'h':
                            radix = 16
                        else:
                            radix = 10
                        setattr(self, match.group(1), int(match.group(3),radix) + block_offset)
                    else:
                        match = define_regex_noradix.search(define)
                        if match:
                            self.verilog_define_matches += 1
                            setattr(self, match.group(1), int(match.group(2),10) + block_offset)
                        else:
                            target_logger.warning("Couldn't parse line: %s", define)
            defines.close()
        # make sure everything is cool:
        if self.verilog_define_matches != self.registers:
            target_logger.warning("Trouble parsing Verilog defines files (%s): didn't find the right number of defines; expected %d, got %d.\n" % (defines_files, self.registers, self.verilog_define_matches) +
                            "Ensure that the Verilog defines files above are the same that were used to build the bitfile.")
            
    def get_fpga_results(self):
        
        if self.REG_NN_RES is None:
            target_logger.error("target.REG_NN_RES unset. Have you given target a verilog defines file?")
            raw = self.fpga_read(self.REG_NN_RES, 1)
            value = raw[0] & 0xF
            return "Results: {}".format(value)
        
    def fpga_read(self, addr, readlen):
        
        if readlen <= 0:
            raise ValueError("Invalid read len {}".format(readlen))
        addr = addr << self.bytecount_size
        data = self._naeusb.cmdReadMem(addr, readlen)
        return data
    
    def fpga_write(self, addr, data):
        
        if len(data) <= 0:
            raise ValueError("Invalid data {}".format(data))
        addr = addr << self.bytecount_size
        return self._naeusb.cmdWriteMem(addr, data)
    
    def vccint_set(self, vccint=1.0):
        """ Set the VCC-INT for the FPGA """

        # print "vccint = " + str(vccint)

        if (vccint < 0.6) or (vccint > 1.1):
            raise ValueError("VCC-Int out of range 0.6V-1.1V")

        # Convert to mV
        vccint = int(vccint * 1000)
        vccsetting = [vccint & 0xff, (vccint >> 8) & 0xff, 0]

        # calculate checksum
        vccsetting[2] = vccsetting[0] ^ vccsetting[1] ^ CW305_USB.VCCINT_XORKEY

        self._naeusb.sendCtrl(CW305_USB.REQ_VCCINT, 0, vccsetting)

        resp = self._naeusb.readCtrl(CW305_USB.REQ_VCCINT, dlen=3)
        if resp[0] != 2:
            raise IOError("VCC-INT Write Error, response = %d" % resp[0])
    
    def vccint_get(self):
        """ Get the last set value for VCC-INT """

        resp = self._naeusb.readCtrl(CW305_USB.REQ_VCCINT, dlen=3)
        return float(resp[1] | (resp[2] << 8)) / 1000.0
    
    def _con(self, scope=None, bsfile=None, force=False, fpga_id=None, defines_files=None, slurp=True, prog_speed=20E6, hw_location=None, sn=None):
        """Connect to CW305 board, and download bitstream.

        If the target has already been programmed it skips reprogramming
        unless forced.

        Args:
            scope (ScopeTemplate): An instance of a scope object.
            bsfile (path): The path to the bitstream file to program the FPGA with.
            force (bool): Whether or not to force reprogramming.
            fpga_id (string): '100t', '35t', or None. If bsfile is None and fpga_id specified,
                              program with AES firmware for fpga_id
            defines_files (list, optional): path to cw305_defines.v
            slurp (bool, optional): Whether or not to slurp the Verilog defines.
        """
        self._naeusb.con(idProduct=[0xC305], serial_number=sn, hw_location=hw_location)
        if not fpga_id is None:
            if fpga_id not in ('100t'):
                raise ValueError(f"Invalid fpga {fpga_id}")
        self._fpga_id = fpga_id
        print(self.fpga)
        if self.fpga.isFPGAProgrammed() == False or force:
            if bsfile is None:
                if not fpga_id is None:
                    from chipwhisperer.hardware.firmware.cw305 import getsome
                    if self.target_name == 'ML':
                        bsdata = getsome(f"cw305_ml_top.bit")
                    starttime = datetime.now()
                    status = self.fpga.FPGAProgram(bsdata, exceptOnDoneFailure=False, prog_speed=prog_speed)
                    stoptime = datetime.now()
                    if status:
                        target_logger.info('FPGA Config OK, time: %s' % str(stoptime - starttime))
                    else:
                        print("\n\n\n\n\nstatus", status)
                        print("self.fpga", self.fpga)
                        print("bsfile", bsfile)
                        target_logger.error('FPGA Done pin failed to go high, check bitstream is for target device.')
                else:
                    target_logger.warning("No FPGA Bitstream file specified.")
            elif not os.path.isfile(bsfile):
                target_logger.warning(("FPGA Bitstream not configured or '%s' not a file." % str(bsfile)))
            else:
                starttime = datetime.now()
                status = self.fpga.FPGAProgram(bitstream=open(bsfile, "rb"), exceptOnDoneFailure=False, prog_speed=prog_speed)
                stoptime = datetime.now()
                if status:
                    target_logger.info('FPGA Config OK, time: %s' % str(stoptime - starttime))
                else:
                    print("\n\n\n\n\nstatus", status)
                    print("self.fpga", self.fpga)
                    print("bsfile", bsfile)
                    target_logger.warning('FPGA Done pin failed to go high, check bitstream is for target device.')

        self.usb_clk_setenabled(True)
        self.pll.cdce906init()

        if slurp:
            # If fpga_id is provided, Verilog defines are obtained from CW305.py.
            # Otherwise, we look for it in a default location; if that doesn't exist, revert to CW305.py and warn user.
            found_defines = False
            if defines_files is None:
                if fpga_id is None:
                    verilog_defines = [self.default_verilog_defines_full_path]
                    if os.path.isfile(verilog_defines[0]):
                        found_defines = True
                    else:
                        target_logger.warning("Verilog defines not found in default location (%s).\nUsing defines from CW305.py.If this isn't what you want, either add 'slurp=False', or provide defines location in 'defines_files'" % verilog_defines[0])
                if not found_defines:
                    from chipwhisperer.hardware.firmware.cw305 import getsome
                    verilog_defines = [getsome(self.default_verilog_defines)]
            else:
                verilog_defines = defines_files
            self.slurp_defines(verilog_defines)


    def dis(self):
        # if self._naeusb:
        self._naeusb.close()
        
    def loadInput(self, inputtext):
        
        if self.REG_NN_INPUTS is None:
            target_logger.error("target.REG_NN_INPUTS unset. Have you given target a verilog defines file?")
            return
        self.input = inputtext
        text = inputtext[::-1]
        self.fpga_write(self.REG_NN_INPUTS, text)
        
    def loadWeights(self, weights):
        
        if self.REG_NN_WEIGHTS is None:
            target_logger.error("target.REG_NN_WEIGHT unset. Have you given target a verilog defines file?")
            return
        self.weights = weights
        weights = weights[::-1]
        self.fpga_write(self.REG_NN_WEIGHTS, weights)

        
    def readOutputs(self):
        
        if self.REG_NN_RES is None:
            target_logger.error("target.REG_NN_RES unset. Have you given target a verilog defines file?")
            return
        data = self.fpga_read(self.REG_NN_RES, 1)
        data = data[::-1]
        return data
    
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
        for i in range(0, 2**int(self.bytecount_size)):
            self.fpga_write(self.REG_NN_INPUTS, bytes(bin(i), 'utf-8'))
            sleep(0.05)
            print("CW305_ML: Writing to REG_NN_INPUTS (%s)", bytes(bin(i), 'utf-8'))
            res = self.fpga_read(self.REG_NN_RES, 2**int(self.bytecount_size))
            print("CW305_ML: Reading from REG_NN_RES (%s)", res)
            sleep(0.05)
            tr_res.append(res)
        return {tr_res}

    def pearsonCoeff(X, Y):
        return cov(X, Y) / (std_dev(X) * std_dev(Y) )

    def mean(X):
        return np.sum(X, axis=0)/len(X)
    
    def std_dev(X, X_bar=0):
        X_bar = mean(X) if X_bar == 0  else X_bar
        return np.sqrt(np.sum((X-X_bar)**2, axis=0))

    def cov(X, Y, X_bar=0, Y_bar=0):
        X_bar = mean(X) if X_bar == 0  else X_bar
        Y_bar = mean(Y) if Y_bar == 0  else Y_bar
        return np.sum((X-X_bar)*(Y-Y_bar), axis=0) 