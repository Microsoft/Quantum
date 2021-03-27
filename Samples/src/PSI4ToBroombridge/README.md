Authored by Julian Roth, March 20th, 2019

To use psi4_to_broombridge you will need the Psi4 and Ruamel package.

Psi4 files are specified in Psithon, a slightly adjusted version of Python to make it easier to use Psi4. This is then parsed and turned into Python code by the Psithon compiler. Because of this, you cannot import local files in Psithon.
To still be able to use psi4_to_broombridge.py, one can either
    - copy the file to either PYTHONPATH or an installation dependent default directory one can access via sys.path in Python. Then you can simply import psi4_to_broombridge in your Psi4 files.
    - copy the code from psi4_to_broombridge.py into your Psi4 file. This is a lot easier, but more tedious if one needs to convert many Psi4 files.

Included are two Example files:
  - H2.dat
  - H4.dat

and for convenience the psi4 code was pasted into these files to easily test them.

Note that at the moment the Conversion code doesn't suggest any initial states. This field is optional in Broombridge and requires ground state and excitation state specifications that Psi4 cannot provide. You can still run Trotterization or Qubitization using the YAML files, however our VQE algorithm relies on the suggested initial ground state and therefore doesn't work with the output of Psi4.
