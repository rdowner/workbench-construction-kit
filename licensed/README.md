Licensed Files
==============

These contain files which are NOT freely distributable and are therefore omitted
from the repository.


Workbench hardfile
------------------

If the file `workbench-310.hdf` is present, then `makedisk` will:

* Extract `FastFileSystem` and load it onto the RDB
* Copy all of the contents onto DH0:
* Perform the postprocessing described elsewhere, such as installing monitor
  drivers

If this file is not present, then `makedisk` is unlikely to be able to do
anything useful.


Apollo 68060 accelerator libraries
----------------------------------

If the folder `Apollo-68060` is present, then inside is expected to contain the
`cpu60` executable and a number of libraries. These will be patched into the
Workbench image.


Keyfiles
--------

The various scripts will recognise the keyfiles named below, and install them.
If any of them are not found they will be ignored. In most cases this means that
the associated piece of software will run in trial mode.

* Executive/Executive.key
* GoldED3/keyfile
* GoldED4/golded.keyfile
* Gotcha/Gotcha.key
* MUI/MUI.key
* Miami/Miami.key1 and .key2
* Monsoon/Monsoon.Key
* Spot/spot.key

