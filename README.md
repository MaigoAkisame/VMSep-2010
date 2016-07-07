# VMSep-2010

The Matlab code in this repository can separate the singing voice and the accompaniment from monaural audio recordings. This was the topic of my bachelor thesis in Tsinghua University.

You can run the code in either of the following two ways. If you have the mixture signal in the Matlab workspace, you can call:
```
[voice accom] = main(mix);
```
The input argument ```mix``` specifies the mixture signal (must be **monaural** and sampled at **16kHz**). The output arguments ```voice``` and ```accom``` will be the singing voice and accompaniment, respectively.

If the mixture signal is stored in a file (also must be **monaural wav files** sampled at **16kHz**), you can call:
```
vmsep(fileMix, fileVoice, fileAccom);
```
where the three input arguments specify the names of the input mixture file, output singing voice file and output accompaniment file, respectively. You can omit the ```.wav``` extension. You can also omit ```fileVoice``` and ```fileAccom```, in which case the main names of the output files will be the main name of the input file plus the suffices ```_voice``` and ```_accom```.

For how the code works, please check out the paper in the ```ref``` folder.

This work was done a long time ago, and the code will no longer be updated (sorry T_T). But feel free to adapt it for your own purpose.
