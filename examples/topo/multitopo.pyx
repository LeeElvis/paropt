# For the use of MPI
from mpi4py.libmpi cimport *
cimport mpi4py.MPI as MPI

# Import numpy 
cimport numpy as np

# Ensure that numpy is initialized
np.import_array()

# Import the definition required for const strings
from libc.string cimport const_char

# Import C methods for python
from cpython cimport PyObject, Py_INCREF

# Import the TACS module
from tacs.python.TACS cimport *
from tacs.python.constitutive cimport *

cdef extern from "mpi-compat.h":
    pass

cdef extern from "PSMultiTopo.h":
    cdef cppclass PSMultiTopo(PlaneStressStiffness):
        PSMultiTopo(TacsScalar*, TacsScalar*, TacsScalar*,
                    int, int, TacsScalar)
        void setLinearization(TacsScalar, const TacsScalar*, int)

cdef class MultiTopo(PlaneStress):
    def __cinit__(self,
                  np.ndarray[TacsScalar, ndim=1, mode='c'] rho,
                  np.ndarray[TacsScalar, ndim=1, mode='c'] E,
                  np.ndarray[TacsScalar, ndim=1, mode='c'] nu,
                  int dv_off, double eps):
        '''Multimaterial topology optimization'''
        assert((len(rho) == len(E)) and (len(rho) == len(nu)))

        self.ptr = new PSMultiTopo(<TacsScalar*>rho.data,
                                   <TacsScalar*>E.data,
                                   <TacsScalar*>nu.data,
                                   len(rho), dv_off, eps)
        self.ptr.incref()
        return

    def setLinearization(self, double q,
                         np.ndarray[TacsScalar, ndim=1, mode='c'] dvs):
        self.ptr.setLinearization(q, <TacsScalar*>dvs.data, len(dvs))
        return

    def __dealloc__(self):
        self.ptr.decref()
        return
    
