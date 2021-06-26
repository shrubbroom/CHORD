# CHORD - CORDIC Hardware of RISC-V Device

CHORD is a hardware accelerator for trigonometrical functions. The accelerator is implemented with the T-HEAD's [wujian100 platform](https://github.com/T-head-Semi/wujian100_open). The CHORD is verified in HDL level and implemented with XC7A200T FPGA.

```bash
Directory structure
.
├── FPGA # SoC project
│   ├── case # cvs simulation test cases
│   │   ├── chord
│   │  ...  └── chord_test.c # test case for chord
│   │
│   ├── soc # SoC RTL source code
│   │   ├── chord_top.v -> ../../HDL/chord_top.v # symbolic link to RTL source code of CHORD
│   │   ...
│   ├── fpga # FPGA synthesis work directory
│   ... ├── vivado # Vivado work directory
│       ...
├── HDL # RTL source code of CHORD
│   ├── core # CORDIC core code
│   │   ├── ex_top.v
│   │   ├── pipeline.v
│   │   ├── interface_in.v
│   │   ├── interface_out.v
│   │   └── verify # verification work directory
│   │       └── pipeline_verify.py # python script for verification
│   ├── bus # AHB bus interface code
│   │   ├── bus_top.v
│   │   ├── ahb_lite_cordic.v
│   │   └── fifo.v
│   └── chord_top.v # CHORD top
└── Driver # C drivers
    ├── wj_chord.c
    └── drv_chord.h
```

# Get Started

Please read [wujian100's user guide](https://github.com/T-head-Semi/wujian100_open/blob/master/README.md) first for tool-chain used in SoC simulation and bit generation. To get the source code of CHORD, run

```bash
$ git clone https://github.com/shrubbroom/CHORD.git
$ git submodule update --init --recursive
```

## Simulate CHORD

A test script written in python is used for CHORD's functionality verification, run

```bash
$ cd CHORD/HDL/core/verify
$ pip install -r requirements.txt
$ ./pipeline_verify.py
```

The program return 0 without any output if no error happens in the test. Otherwise, if the code doesn't pass the test, the output will be like

```bash
Check failed, arctan error exceeds upper bound
upper bound is: 0.0621
error is: 0.1
```

## Simulate CHORD with wujian100

For our VLSI virtual machine with full Synopsys tool-chain, run

```bash
$ cd CHORD/FPGA
$ source tools/setup.bash
$ cd workdir
$ ../tools/run_case -sim_tool vcs ../case/chord/chord_test.c
```

To watch wave, run `dve`.

## Emulate with XC7A200T FPGA

Open the vivado project in `FPGA/fpga/vivado/CHORD_wujian100`, directly run `generate bitstream` to get `FPGA/fpga/vivado/CHORD_wujian100/CHORD_wujian100.run/impl_1/wujian100_open_top.bit`.  Further steps can be found in `FPGA/doc/XC7A-FPGA开发板用户手册(FMX7AR3B).v1.0.docx`.

# How to use the driver

We provide driver program written in `C` for CHORD. The `drv_chord.h` provides four functions

```c
int16_t chord_cos(int16_t); // scalar
int16_t chord_sin(int16_t); // scalar
int16_t chord_arctan(int16_t); // scalar
void chord_cos_sin_v(int16_t*, int16_t*, int16_t*, int); // vector
void chord_arctan_v(int16_t*, int16_t*, int);  // vector
```

Note that the vector length should not exceed `CHORD_BUFFER_SIZE`.

# Reference and Thanks

This is the course project of MR334 (VLSI 数字通信原理与设计, 2021) by [shrubbroom](oracle0133@gmail.com) and [miracle3310](miracle3310@sjtu.edu.cn). For the report see [CHORD.pdf](./report/CHORD.pdf).