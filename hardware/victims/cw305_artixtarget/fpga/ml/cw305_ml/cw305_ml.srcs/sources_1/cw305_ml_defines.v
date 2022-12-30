/*

Author: Christian Moser
Date:   12-20-22
Desc:   ML component for CW305 target for NN Accelerator implementations
*/

`define REG_CLKSETTINGS                 'h00
`define REG_USER_LED                    'h01
`define REG_CRYPT_TYPE                  'h02
`define REG_CRYPT_REV                   'h03
`define REG_IDENTIFY                    'h04
`define REG_BUILDTIME                   'h0b
`define REG_CRYPT_GO                    'h05

`define REG_NN_INPUTS                   'h06
`define REG_NN_WEIGHTS                  'h07
`define REG_NN_BIAS                     'h08
`define REG_NN_RES                      'h09
