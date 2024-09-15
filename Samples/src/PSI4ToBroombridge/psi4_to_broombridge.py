# Authored by Julian Roth

import sys
import numpy as np
import psi4

emitter_yaml = False
emitter_ruamel = False

try:
    try:
        import ruamel.yaml as ruamel
    except ImportError:
        import ruamel_yaml as ruamel
    emitter_ruamel = True
except ImportError:
    import yaml
    emitter_yaml = True


preamble="""
"$schema": https://raw.githubusercontent.com/Microsoft/Quantum/master/Chemistry/Schema/broombridge-0.1.schema.json
"""

def extract_fields(mol, scf=None, scf_corr_en=None, fci=None, ccsd=None):
    # get basis set of first atom
    #basis = mol.basis_on_atom(0)
    # set all atoms to same basis set
    #mol.set_basis_all_atoms(basis)

    # get the geometry in bohr units
    geom = np.array(mol.geometry())
    symm = mol.symmetry_from_input()

    # energy and wavefunction from scf
    if scf is None or scf_corr_en is None:
      scf_en, scf_wfn = psi4.energy('scf', molecule=mol, return_wfn=True)
      # energy offset
      scf_corr_en = psi4.core.scalar_variable('CURRENT CORRELATION ENERGY')
    else:
      scf_en, scf_wfn = scf

    # number of alpha & beta electrons
    alpha = scf_wfn.nalpha()
    beta = scf_wfn.nbeta()

    # number of orbitals
    orbitals = scf_wfn.nmo()

    # energy and wavefunction of fci (exponential time)
    if fci is not None:
      fci_en, fci_wfn = fci
    elif scf is not None:
      # approximate fci with scf
      fci_en, fci_wfn = scf
    else:
      fci_en, fci_wfn = psi4.energy('fci', molecule=mol, return_wfn=True)

    if ccsd is not None:
      ccsd_en, ccsd_wfn = ccsd
    else:
      ccsd_en, ccsd_wfn = psi4.energy('ccsd', molecule=mol, return_wfn=True)

    # one electron integrals
    mints = psi4.core.MintsHelper(ccsd_wfn.basisset())
    one_elec = ccsd_wfn.H()
    # turn it into MO basis
    one_elec.transform(ccsd_wfn.Ca())
    # two electron integral in MO basis
    two_elec = mints.mo_eri(ccsd_wfn.Ca(), ccsd_wfn.Ca(), ccsd_wfn.Ca(), ccsd_wfn.Ca())
    # turn them into numpy arrays
    one_elec = np.array(one_elec)
    two_elec = np.array(two_elec)

    data = {}
    data['format'] = {'version' : '0.1'}
    data['bibliography'] = [{'url' : 'http://www.psicode.org/psi4manual/1.2/index.html'}]
    data['generator'] = {'source' : 'psi4',
        'version' : '1.2'}

    skip_input_geometry = False
    geometry = {
        'coordinate_system': 'cartesian',
        'units' : 'bohr', # for now all geometries are converted to bohr by default
        'atoms' : [],
        'symmetry' : symm
    }
    N, _ = geom.shape
    for i in range(N):
        geometry['atoms'].append({
            'name' : mol.symbol(i),
            'coords' : [geom.item((i, 0)), geom.item((i, 1)), geom.item((i, 2))]
        })
    # coulomb repulsion = nuclear repulsion energy
    coulomb_repulsion = {
        'units' : 'hartree',
        'value' : mol.nuclear_repulsion_energy()
    }
    scf_energy = {
        'units' : 'hartree',
        'value' : scf_en
    }
    scf_energy_offset = {
        'units' : 'hartree',
        'value' : scf_corr_en
    }
    energy_offset = {
        'units' : 'hartree',
        'value' : scf_corr_en
    }
    one_electron_integrals = {
        'units' : 'hartree',
        'format' : 'sparse',
        'values' : []
    }
    N, _ = one_elec.shape
    for i in range(N):
        for j in range(i+1):
            if (i + j) % 2 == 0:
                one_electron_integrals['values'].append([
                    i+1,
                    j+1,
                    one_elec.item((i, j))
                ])
    two_electron_integrals = {
        'units' : 'hartree',
        'format' : 'sparse',
        'index_convention' : 'mulliken',
        'values' : []
    }
    N, _, _, _ = two_elec.shape
    # mulliken index convention:
    # if element with indices (i, j, k, l) is present, then indices
    # (i, j, l, k), (j, i, k, l), (j, i, l, k), (k, l, i, j),
    # (k, l, j, i), (l, k, j, i) are not present
    for i in range(N):
        for j in range(i+1):
            for k in range(i+1):
                for l in range(k+1):
                  if (i + j + k + l) % 2 == 0 and (i != k or l <= j):
                    two_electron_integrals['values'].append([
                        i+1,
                        j+1,
                        k+1,
                        l+1,
                        two_elec.item((i, j, k, l))
                    ])
    n_electrons_alpha = alpha
    basis_set = {
        'name' : 'unknown',
        'type' : 'gaussian'
    }
    n_electrons_beta = beta
    n_orbitals = orbitals
    initial_state = None
    ccsd_energy = ccsd_en
    reader_mode = ""
    excited_state_count = 1
    excitation_energy = 0.0
    fci_energy = {
        'units' : 'hartree',
        'value' : fci_en,
        'upper' : fci_en+0.1,
        'lower' : fci_en-0.1
    }


    hamiltonian = {'one_electron_integrals' : one_electron_integrals,
                   'two_electron_integrals' : two_electron_integrals}
    integral_sets =  [{"metadata": { 'molecule_name' : 'unknown'},
                       "geometry":geometry,
                       "basis_set":basis_set,
                       "coulomb_repulsion" : coulomb_repulsion,
                       "scf_energy" : scf_energy,
                       "scf_energy_offset" : scf_energy_offset,
                       "energy_offset" : energy_offset,
                       "fci_energy" : fci_energy,
                       "hamiltonian" : hamiltonian,
                       "n_orbitals" : n_orbitals,
                       "n_electrons" : n_electrons_alpha + n_electrons_beta
                       }]
    if initial_state is not None:
        integral_sets[-1]["initial_state_suggestions"] = initial_state
    data['integral_sets'] = integral_sets

    return data


def emitter_ruamel_func(mol, name=None, scf=None, scf_corr_en=None, fci=None, ccsd=None):
    yaml = ruamel.YAML(typ="safe")
    yaml.default_flow_style = False
    with open(name, "w") as f:
      f.write(preamble)
      f.write('\n')
      data = extract_fields(mol, scf, scf_corr_en, fci, ccsd)
      yaml.dump(data, f)

def emitter_yaml_func(mol, name=None, scf=None, scf_corr_en=None, fci=None, ccsd=None):
    with open(name, "w") as f:
      f.write(preamble)
      f.write('\n')
      data = extract_fields(mol, scf, scf_corr_en, fci, ccsd)
      yaml.dump(data, f, default_flow_style=False)

def to_broombridge(mol, name=None, scf=None, scf_corr_en=None, fci=None, ccsd=None):
    assert emitter_yaml or emitter_ruamel, "Extraction failed: could not import YAML or RUAMEL packages."

    if name is None:
      name = 'out.yaml'

    if emitter_yaml:
        emitter_yaml_func(mol, name, scf, scf_corr_en, fci, ccsd)
    elif emitter_ruamel:
        emitter_ruamel_func(mol, name, scf, scf_corr_en, fci, ccsd)
    else:
        assert False, "Unreachable code"
    print("output written to:", name)
